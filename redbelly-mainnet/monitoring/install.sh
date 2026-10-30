#!/usr/bin/env bash
# Redbelly node monitor + certificate auto-renew: one-command setup.
#   curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/install.sh -o install.sh
#   sudo bash install.sh
# It finds your node's settings by itself and asks only what it cannot find (press Enter to accept a suggestion).
# Non-interactive: RB_TG_TOKEN=... RB_TG_CHAT=... [RB_MIN_BALANCE=10] [RB_REWARD=0x...] [RB_SERVICE=redbelly]
#   [RB_CERT=/path/fullchain.pem RB_KEY=/path/privkey.pem RB_DNS=node.example.com RB_PORT=6540 RB_NODE_USER=rbnuser] RB_YES=1 sudo -E bash install.sh
# It never reads your signing key, never restarts or edits your node, and only talks to the node's local status server.
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
ask() { # ask VAR "question" suggestion   (env value wins; Enter keeps the suggestion)
  local v=${!1:-}; if [ -z "$v" ] && [ -t 0 ]; then read -r -p "  $2 ${3:+[$3]} " v; fi; printf -v "$1" '%s' "${v:-${3:-}}"; }
confirm() { [ "${RB_YES:-}" = 1 ] && return 0; [ -t 0 ] || return 1; read -r -p "  $1 [y/N] " a; [[ $a =~ ^[Yy] ]]; }
fetch() { if [ -f "$HERE/$1" ]; then cp "$HERE/$1" "$2"; else curl -fsSL "$RAW/$1" -o "$2"; fi; }
icfg() { [ -r "$NODECFG" ] && grep -E "^$1=" "$NODECFG" | head -1 | cut -d= -f2- | tr -d '"' || true; }
flag() { # flag NAME: value of --NAME=x or --NAME x in the node's start command
  printf '%s' "$EXEC" | grep -oE -- "--$1[= ]\"?[^\" ;]+" | head -1 | sed -E "s/^--$1[= ]\"?//" || true; }

[ "$(id -u)" = 0 ] || die "run with sudo: sudo bash install.sh"

b "1/6 Finding your node"
SERVICE=${RB_SERVICE:-}
if [ -z "$SERVICE" ]; then
  if systemctl cat redbelly.service 2>/dev/null | grep -q rbbc; then SERVICE=redbelly
  else
    for u in $(systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}'); do
      systemctl show -p ExecStart --value "$u" 2>/dev/null | grep -q rbbc && { SERVICE=${u%.service}; break; }
    done
  fi
fi
EXEC=""; NODE_USER=${RB_NODE_USER:-}
if [ -n "$SERVICE" ]; then
  EXEC=$(systemctl show -p ExecStart --value "$SERVICE" 2>/dev/null || true)
  NODE_USER=${NODE_USER:-$(systemctl show -p User --value "$SERVICE" 2>/dev/null || true)}
  ok "node service: $SERVICE ($(systemctl is-active "$SERVICE" 2>/dev/null || echo unknown))"
else
  warn "no systemd service running rbbc found (Docker or custom setup?): the monitor will skip the service check"
fi
NODE_USER=${NODE_USER:-root}
CERT=${RB_CERT:-$(flag tls.cert)}; CERT=${CERT:-$(icfg FULL_PATH_FOR_CERTIFICATE_FILE)}
KEY=${RB_KEY:-$(flag tls.key)};   KEY=${KEY:-$(icfg FULL_PATH_FOR_CERTIFICATE_KEY)}
PORT=${RB_PORT:-$(flag statusserver.udp.port)}; PORT=${PORT:-$(icfg STATUS_SERVER_PORT)}; PORT=${PORT:-6540}
DNS=${RB_DNS:-$(icfg DNS)}
[ -z "$DNS" ] && [ -r "$CERT" ] && DNS=$(openssl x509 -in "$CERT" -noout -subject 2>/dev/null | sed -E 's/.*CN ?= ?//')
echo "  Found these settings. Press Enter to keep each one, or type the right value:"
ask CERT "Node TLS certificate file:" "$CERT"
ask KEY "Node TLS key file:" "$KEY"
ask DNS "Node domain:" "$DNS"
ask PORT "Status server UDP port:" "$PORT"
[ -n "$CERT" ] && [ -n "$DNS" ] || die "certificate file and domain are needed (see README: Different setups)"
if ! printf '%s' "$EXEC" | grep -q -- '--statusserver.udp.port' && [ "$(icfg ENABLE_STATUS_SERVER)" != y ]; then
  warn "the status server does not look enabled. Add to the node start command:"
  warn "  --statusserver.udp.addr=127.0.0.1 --statusserver.udp.port=$PORT   (needs a node restart, at a time you choose)"
fi

b "2/6 Packages"
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l
NEED=""; for p in python3-venv openssl curl; do dpkg -s "$p" >/dev/null 2>&1 || NEED="$NEED $p"; done
command -v certbot >/dev/null || NEED="$NEED certbot"
[ -z "$NEED" ] || { apt-get update -qq && apt-get install -y -qq $NEED >/dev/null; }
ok "python3-venv, openssl, curl, certbot present"

b "3/6 Telegram"
OLD=$ETC/config.json
if [ -r "$OLD" ]; then
  RB_TG_TOKEN=${RB_TG_TOKEN:-$(python3 -c "import json;print(json.load(open('$OLD')).get('telegram_token',''))")}
  RB_TG_CHAT=${RB_TG_CHAT:-$(python3 -c "import json;print(json.load(open('$OLD')).get('telegram_chat_id',''))")}
  RB_REWARD=${RB_REWARD:-$(python3 -c "import json;print(json.load(open('$OLD')).get('reward_address',''))")}
  ok "keeping your earlier Telegram settings"
fi
[ -n "${RB_TG_TOKEN:-}" ] || echo "  Bot token: in Telegram open @BotFather, send /newbot, copy the token. Chat id: open @userinfobot, send /start."
ask RB_TG_TOKEN "Telegram bot token (Enter = no Telegram):" ""
ask RB_TG_CHAT "Telegram chat id:" ""
ask RB_MIN_BALANCE "Warn me when the signing wallet has less than (RBNT):" "10"
ask RB_REWARD "Reward address to show (optional, Enter to skip):" ""

b "4/6 Installing the monitor"
id rbmon >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin rbmon
install -d -m 755 "$APP"; install -d -m 750 -g rbmon "$ETC"
fetch monitor.py "$APP/monitor.py"
[ -x "$APP/venv/bin/python" ] || python3 -m venv "$APP/venv"
"$APP/venv/bin/pip" install -q --upgrade requests python-dateutil psutil >/dev/null
TMP=$(mktemp)
RB_TG_TOKEN="$RB_TG_TOKEN" RB_TG_CHAT="$RB_TG_CHAT" RB_MIN_BALANCE="$RB_MIN_BALANCE" RB_REWARD="$RB_REWARD" \
PORT="$PORT" SERVICE="$SERVICE" CERT="$CERT" python3 - "$OLD" > "$TMP" <<'EOF'
import json, os, sys
c = {}
try: c = json.load(open(sys.argv[1]))
except Exception: pass
e = os.environ
c.update({"udp_host": "127.0.0.1", "udp_port": int(e["PORT"]), "service_name": e["SERVICE"], "cert_file": e["CERT"],
          "telegram_token": e["RB_TG_TOKEN"], "telegram_chat_id": e["RB_TG_CHAT"],
          "min_balance": float(e["RB_MIN_BALANCE"]), "reward_address": e["RB_REWARD"]})
print(json.dumps(c, indent=2))
EOF
install -m 640 -o root -g rbmon "$TMP" "$ETC/config.json"; rm -f "$TMP"
cat > /etc/systemd/system/redbelly-monitor.service <<EOF
[Unit]
Description=Redbelly node monitor (Telegram alerts)
After=network-online.target ${SERVICE:+$SERVICE.service}
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
sleep 3; systemctl is-active --quiet redbelly-monitor && ok "monitor running as service redbelly-monitor (starts on boot)" || die "service failed: journalctl -u redbelly-monitor -n 30"
MAIN=$(systemctl show -p MainPID --value redbelly-monitor 2>/dev/null || echo 0)
if pgrep -f 'monitor.py|redbelly_monitor.py' | grep -vx "$MAIN" >/dev/null; then
  warn "an older monitor is still running (screen session?). Stop it to avoid double messages: screen -ls"
fi

b "5/6 Certificate auto-renew"
LIVE=/etc/letsencrypt/live/$DNS
if [ ! -d "$LIVE" ]; then   # lineage may have another name: match by domain
  for d in /etc/letsencrypt/live/*/; do
    [ -r "$d/cert.pem" ] && openssl x509 -in "$d/cert.pem" -noout -ext subjectAltName 2>/dev/null | grep -q "DNS:$DNS" && { LIVE=${d%/}; break; }
  done
fi
if [ ! -d "$LIVE" ]; then
  warn "no Let's Encrypt certificate for $DNS on this server yet"
  if systemctl is-active --quiet nginx; then MODE=--nginx; else MODE=--standalone; fi
  if confirm "Get one now with certbot $MODE? ($DNS must point to this server, port 80 open)"; then
    certbot certonly $MODE -d "$DNS" --non-interactive --agree-tos --register-unsafely-without-email && LIVE=/etc/letsencrypt/live/$DNS
  else
    warn "skipped. Later: sudo certbot certonly $MODE -d $DNS   then run this installer again"
  fi
fi
if [ -d "$LIVE" ]; then
  RESTART_NODE=0; [ -r "$ETC/cert-hook.conf" ] && RESTART_NODE=$(grep -E '^RESTART_NODE=' "$ETC/cert-hook.conf" | cut -d= -f2 || echo 0)
  cat > "$ETC/cert-hook.conf" <<EOF
# Used by $HOOK after every certbot renewal.
LINEAGE_NAME=$(basename "$LIVE")
CERT=$CERT
KEY=$KEY
NODE_USER=$NODE_USER
SERVICE=$SERVICE
# 1 = restart the node after a renewal. Not needed on rbbc 1.3.x (it reloads the files itself); the monitor tells you if it is.
RESTART_NODE=${RESTART_NODE:-0}
EOF
  install -d /etc/letsencrypt/renewal-hooks/deploy
  fetch redbelly-cert.sh "$HOOK"; chmod 755 "$HOOK"
  ok "after each renewal the new certificate is copied to $(dirname "$CERT") (owner $NODE_USER)"
  if systemctl is-active --quiet certbot.timer || systemctl is-active --quiet snap.certbot.renew.timer; then
    ok "certbot checks twice a day and renews 30 days before expiry"
  else
    printf '[Unit]\nDescription=certbot renew\n[Service]\nType=oneshot\nExecStart=%s renew -q\n' "$(command -v certbot)" > /etc/systemd/system/redbelly-certbot.service
    printf '[Unit]\nDescription=certbot renew twice a day\n[Timer]\nOnCalendar=*-*-* 03,15:17\nRandomizedDelaySec=1h\nPersistent=true\n[Install]\nWantedBy=timers.target\n' > /etc/systemd/system/redbelly-certbot.timer
    systemctl daemon-reload; systemctl enable --now redbelly-certbot.timer >/dev/null 2>&1
    ok "added a twice-a-day renewal timer (redbelly-certbot.timer)"
  fi
  echo "  testing a renewal (dry run, changes nothing)..."
  if certbot renew --dry-run --cert-name "$(basename "$LIVE")" >/tmp/rb-dryrun.log 2>&1; then ok "renewal test passed"
  else warn "renewal test FAILED, see /tmp/rb-dryrun.log (usually: port 80 closed or the domain does not point here)"; fi
fi

b "6/6 Check"
"$APP/venv/bin/python" "$APP/monitor.py" --config "$ETC/config.json" --once 2>/dev/null | sed 's/^/  /'
if [ -n "$RB_TG_TOKEN" ]; then
  "$APP/venv/bin/python" "$APP/monitor.py" --config "$ETC/config.json" --test-telegram 2>/dev/null && ok "test message sent: check Telegram" || warn "Telegram test failed: check the token and chat id (run the installer again to change them)"
fi
cat <<EOF

All set. Useful commands:
  Live view:  sudo -u rbmon $APP/venv/bin/python $APP/monitor.py --config $ETC/config.json --console
  Logs:       journalctl -u redbelly-monitor -f
  Change:     run this installer again (it remembers your answers)
  Remove:     curl -fsSL $RAW/uninstall.sh | sudo bash
EOF
