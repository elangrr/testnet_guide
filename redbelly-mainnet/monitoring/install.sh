#!/usr/bin/env bash
# Redbelly node monitor + certificate auto-renew: one-command setup.
#   curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/install.sh -o install.sh
#   sudo bash install.sh
# Non-interactive: RB_TG_TOKEN=... RB_TG_CHAT=... [RB_MIN_BALANCE=10] [RB_REWARD=0x...] [RB_YES=1] sudo -E bash install.sh
# It never touches the node's signing key, never restarts the node, and only reads the node through its local status server.
set -euo pipefail

RAW=${RB_RAW:-https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring}
APP=/opt/redbelly-monitor
ETC=/etc/redbelly-monitor
NODECFG=/etc/redbelly/rbninstaller-config
HOOK=/etc/letsencrypt/renewal-hooks/deploy/redbelly-cert.sh
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo .)

b() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die() { printf '  \033[31m✗ %s\033[0m\n' "$*"; exit 1; }
ask() { # ask VAR "question" default
  local v=${!1:-}; if [ -z "$v" ] && [ -t 0 ]; then read -r -p "  $2 ${3:+[$3]} " v; fi; printf -v "$1" '%s' "${v:-${3:-}}"; }
confirm() { [ "${RB_YES:-}" = 1 ] && return 0; [ -t 0 ] || return 1; read -r -p "  $1 [y/N] " a; [[ $a =~ ^[Yy] ]]; }
fetch() { # fetch FILE DEST: local copy next to install.sh, else GitHub
  if [ -f "$HERE/$1" ]; then cp "$HERE/$1" "$2"; else curl -fsSL "$RAW/$1" -o "$2"; fi; }

[ "$(id -u)" = 0 ] || die "run with sudo: sudo bash install.sh"

b "1/6 Checking the node"
[ -r "$NODECFG" ] || die "$NODECFG not found: install the Redbelly node with the official installer first"
get() { grep -E "^$1=" "$NODECFG" | head -1 | cut -d= -f2- | tr -d '"'; }
DNS=$(get DNS); CERT=$(get FULL_PATH_FOR_CERTIFICATE_FILE); PORT=$(get STATUS_SERVER_PORT); PORT=${PORT:-6540}
ok "domain $DNS, certificate $CERT"
[ "$(get ENABLE_STATUS_SERVER)" = y ] && ok "status server enabled (UDP $PORT)" || warn "ENABLE_STATUS_SERVER is not 'y': the monitor needs --statusserver.udp.port=$PORT on the node"
systemctl is-active --quiet redbelly && ok "redbelly service active" || warn "redbelly service is not active right now"

b "2/6 Packages"
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l
NEED=""; for p in python3-venv openssl curl; do dpkg -s "$p" >/dev/null 2>&1 || NEED="$NEED $p"; done
command -v certbot >/dev/null || NEED="$NEED certbot"
[ -z "$NEED" ] || { apt-get update -qq && apt-get install -y -qq $NEED >/dev/null; }
ok "python3-venv, openssl, curl, certbot present"

b "3/6 Telegram settings"
OLD=$ETC/config.json
if [ -r "$OLD" ]; then
  RB_TG_TOKEN=${RB_TG_TOKEN:-$(python3 -c "import json;print(json.load(open('$OLD')).get('telegram_token',''))")}
  RB_TG_CHAT=${RB_TG_CHAT:-$(python3 -c "import json;print(json.load(open('$OLD')).get('telegram_chat_id',''))")}
  RB_REWARD=${RB_REWARD:-$(python3 -c "import json;print(json.load(open('$OLD')).get('reward_address',''))")}
  ok "keeping settings from $OLD (set RB_* variables to change them)"
fi
echo "  Bot token: create a bot with @BotFather. Chat id: send /start to @userinfobot. Leave empty for no Telegram."
ask RB_TG_TOKEN "Telegram bot token:" ""
ask RB_TG_CHAT "Telegram chat id:" ""
ask RB_MIN_BALANCE "Alert when the signing balance is below (RBNT):" "10"
ask RB_REWARD "Reward address to show (optional, 0x...):" ""

b "4/6 Installing the monitor"
id rbmon >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin rbmon
install -d -m 755 "$APP"; install -d -m 750 -g rbmon "$ETC"
fetch monitor.py "$APP/monitor.py"
[ -x "$APP/venv/bin/python" ] || python3 -m venv "$APP/venv"
"$APP/venv/bin/pip" install -q --upgrade requests python-dateutil psutil >/dev/null
TMP=$(mktemp)
RB_TG_TOKEN="$RB_TG_TOKEN" RB_TG_CHAT="$RB_TG_CHAT" RB_MIN_BALANCE="$RB_MIN_BALANCE" RB_REWARD="$RB_REWARD" PORT="$PORT" \
python3 - "$OLD" > "$TMP" <<'EOF'
import json, os, sys
c = {}
try: c = json.load(open(sys.argv[1]))
except Exception: pass
c.update({"udp_host": "127.0.0.1", "udp_port": int(os.environ["PORT"]), "telegram_token": os.environ["RB_TG_TOKEN"],
          "telegram_chat_id": os.environ["RB_TG_CHAT"], "min_balance": float(os.environ["RB_MIN_BALANCE"]),
          "reward_address": os.environ["RB_REWARD"]})
print(json.dumps(c, indent=2))
EOF
install -m 640 -o root -g rbmon "$TMP" "$ETC/config.json"; rm -f "$TMP"
cat > /etc/systemd/system/redbelly-monitor.service <<EOF
[Unit]
Description=Redbelly node monitor (Telegram alerts)
After=network-online.target redbelly.service
Wants=network-online.target

[Service]
User=rbmon
Group=rbmon
ExecStart=$APP/venv/bin/python $APP/monitor.py --config $ETC/config.json
Restart=always
RestartSec=30
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now redbelly-monitor >/dev/null 2>&1 && systemctl restart redbelly-monitor
sleep 3; systemctl is-active --quiet redbelly-monitor && ok "redbelly-monitor service running" || die "service failed: journalctl -u redbelly-monitor -n 30"
if pgrep -f 'monitor.py|redbelly_monitor.py' | grep -v "^$(systemctl show -p MainPID --value redbelly-monitor)$" >/dev/null; then
  warn "an older monitor is still running (screen session?). Stop it so you don't get double messages: screen -ls"
fi

b "5/6 Certificate auto-renew"
LIVE=/etc/letsencrypt/live/$DNS
if [ ! -d "$LIVE" ]; then
  warn "no Let's Encrypt certificate for $DNS on this server"
  if confirm "Get one now with certbot (port 80 must be free and $DNS must point to this server)?"; then
    certbot certonly --standalone -d "$DNS" --non-interactive --agree-tos --register-unsafely-without-email
  else
    warn "skipped: run later  sudo certbot certonly --standalone -d $DNS  then this installer again"
  fi
fi
if [ -d "$LIVE" ]; then
  install -d /etc/letsencrypt/renewal-hooks/deploy
  fetch redbelly-cert.sh "$HOOK"; chmod 755 "$HOOK"
  ok "deploy hook installed: after each renewal it copies the new certificate to $(dirname "$CERT")"
  [ -f /etc/letsencrypt/renewal-hooks/post/redbelly.sh ] && ok "the Redbelly installer's post hook also exists: both copy the same files, that is fine"
  [ -f "$ETC/cert-hook.conf" ] || printf '# RESTART_NODE=1 restarts the node after a renewal (not needed on rbbc 1.3.x)\nRESTART_NODE=0\n' > "$ETC/cert-hook.conf"
  if systemctl is-active --quiet certbot.timer || systemctl is-active --quiet snap.certbot.renew.timer; then
    ok "certbot renewal timer active (checks twice a day, renews 30 days before expiry)"
  else
    printf '[Unit]\nDescription=certbot renew\n[Service]\nType=oneshot\nExecStart=%s renew -q\n' "$(command -v certbot)" > /etc/systemd/system/redbelly-certbot.service
    printf '[Unit]\nDescription=certbot renew twice a day\n[Timer]\nOnCalendar=*-*-* 03,15:17\nRandomizedDelaySec=1h\nPersistent=true\n[Install]\nWantedBy=timers.target\n' > /etc/systemd/system/redbelly-certbot.timer
    systemctl daemon-reload; systemctl enable --now redbelly-certbot.timer >/dev/null 2>&1
    ok "added redbelly-certbot.timer (no certbot timer was active)"
  fi
  echo "  testing a renewal (dry run, changes nothing)..."
  if certbot renew --dry-run --cert-name "$DNS" >/tmp/rb-dryrun.log 2>&1; then ok "dry-run renewal works"
  else warn "dry-run renewal FAILED, see /tmp/rb-dryrun.log (often: port 80 blocked or DNS not pointing here)"; fi
fi

b "6/6 Check"
"$APP/venv/bin/python" "$APP/monitor.py" --config "$ETC/config.json" --once 2>/dev/null | sed 's/^/  /'
if [ -n "$RB_TG_TOKEN" ]; then
  "$APP/venv/bin/python" "$APP/monitor.py" --config "$ETC/config.json" --test-telegram 2>/dev/null && ok "test report sent to Telegram" || warn "Telegram test failed: check token and chat id in $ETC/config.json"
fi
cat <<EOF

Done.
  Logs:          journalctl -u redbelly-monitor -f
  Live view:     sudo -u rbmon $APP/venv/bin/python $APP/monitor.py --config $ETC/config.json --console
  Settings:      sudo nano $ETC/config.json && sudo systemctl restart redbelly-monitor
  Cert renewals: cat /var/log/redbelly-cert-hook.log
  Update:        run this installer again (settings are kept)
  Remove:        sudo bash uninstall.sh
EOF
