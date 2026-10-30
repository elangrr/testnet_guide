#!/usr/bin/env bash
# certbot deploy hook for a Redbelly node (install.sh puts it in /etc/letsencrypt/renewal-hooks/deploy/).
# certbot runs it after EVERY successful renewal; it acts only for the node's own certificate:
#   1. copies the new fullchain + key to the files the node uses
#   2. sets owner (the node's user) and permissions (key 600)
#   3. optional: restarts the node if RESTART_NODE=1 (not needed on rbbc 1.3.x, it reloads the files itself)
#   4. optional: Telegram message using the monitor's settings
# Settings: /etc/redbelly-monitor/cert-hook.conf (written by install.sh); falls back to /etc/redbelly/rbninstaller-config.
set -euo pipefail
HOOKCONF=/etc/redbelly-monitor/cert-hook.conf
NODECFG=/etc/redbelly/rbninstaller-config
LOG=/var/log/redbelly-cert-hook.log
log() { echo "$(date -u '+%F %T') $*" | tee -a "$LOG"; }

LINEAGE_NAME=""; CERT=""; KEY=""; NODE_USER=root; SERVICE=""; RESTART_NODE=0
if [ -r "$HOOKCONF" ]; then
  # shellcheck disable=SC1090
  . "$HOOKCONF"
elif [ -r "$NODECFG" ]; then
  get() { grep -E "^$1=" "$NODECFG" | head -1 | cut -d= -f2- | tr -d '"'; }
  LINEAGE_NAME=$(get DNS); CERT=$(get FULL_PATH_FOR_CERTIFICATE_FILE); KEY=$(get FULL_PATH_FOR_CERTIFICATE_KEY)
  NODE_USER=rbnuser; SERVICE=redbelly
else
  exit 0
fi

LINEAGE=${RENEWED_LINEAGE:-/etc/letsencrypt/live/$LINEAGE_NAME}
[ "$(basename "$LINEAGE")" = "$LINEAGE_NAME" ] || exit 0     # another domain was renewed: nothing to do
[ -n "$CERT" ] && [ -n "$KEY" ] || { log "skip: CERT/KEY not set in $HOOKCONF"; exit 1; }

install -d -m 755 -o "$NODE_USER" -g "$NODE_USER" "$(dirname "$CERT")" "$(dirname "$KEY")"
install -m 644 -o "$NODE_USER" -g "$NODE_USER" "$(realpath "$LINEAGE/fullchain.pem")" "$CERT.new" && mv -f "$CERT.new" "$CERT"
install -m 600 -o "$NODE_USER" -g "$NODE_USER" "$(realpath "$LINEAGE/privkey.pem")" "$KEY.new" && mv -f "$KEY.new" "$KEY"
END=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
log "renewed $LINEAGE_NAME: copied to $(dirname "$CERT"), valid until $END"

if [ "$RESTART_NODE" = "1" ] && [ -n "$SERVICE" ]; then
  systemctl restart "$SERVICE" && log "restarted $SERVICE"
fi

MON=/etc/redbelly-monitor/config.json
if [ -r "$MON" ] && command -v python3 >/dev/null; then
  python3 - "$MON" "$LINEAGE_NAME" "$END" <<'EOF' || true
import json, sys, urllib.request
c = json.load(open(sys.argv[1]))
if c.get("telegram_token") and c.get("telegram_chat_id"):
    body = json.dumps({"chat_id": c["telegram_chat_id"], "text": f"🔐 Redbelly certificate renewed: {sys.argv[2]}, valid until {sys.argv[3]}"}).encode()
    req = urllib.request.Request(f"https://api.telegram.org/bot{c['telegram_token']}/sendMessage", body, {"content-type": "application/json"})
    urllib.request.urlopen(req, timeout=15)
EOF
fi
