#!/usr/bin/env bash
# certbot deploy hook for a Redbelly node (installed by install.sh as
# /etc/letsencrypt/renewal-hooks/deploy/redbelly-cert.sh).
# certbot runs it after EVERY successful renewal; it acts only for the node's own domain:
#   1. copies the new fullchain + key to the paths the node uses (from /etc/redbelly/rbninstaller-config)
#   2. fixes owner/permissions (rbnuser, key 600)
#   3. optional: restarts the node if RESTART_NODE=1 in /etc/redbelly-monitor/cert-hook.conf
#      (not needed on rbbc 1.3.x: it picks up the new files by itself, the monitor shows it)
#   4. optional: Telegram message using the monitor's config
set -euo pipefail
CFG=/etc/redbelly/rbninstaller-config
HOOKCONF=/etc/redbelly-monitor/cert-hook.conf
LOG=/var/log/redbelly-cert-hook.log
log() { echo "$(date -u '+%F %T') $*" | tee -a "$LOG"; }

[ -r "$CFG" ] || { log "skip: $CFG not found"; exit 0; }
get() { grep -E "^$1=" "$CFG" | head -1 | cut -d= -f2- | tr -d '"'; }
DNS=$(get DNS); CERT=$(get FULL_PATH_FOR_CERTIFICATE_FILE); KEY=$(get FULL_PATH_FOR_CERTIFICATE_KEY)
RESTART_NODE=0; NODE_USER=rbnuser; SERVICE=redbelly
[ -r "$HOOKCONF" ] && . "$HOOKCONF"

LINEAGE=${RENEWED_LINEAGE:-/etc/letsencrypt/live/$DNS}
[ "$(basename "$LINEAGE")" = "$DNS" ] || exit 0          # another domain was renewed: nothing to do
[ -n "$CERT" ] && [ -n "$KEY" ] || { log "skip: certificate paths missing in $CFG"; exit 1; }

install -d -m 755 -o "$NODE_USER" -g "$NODE_USER" "$(dirname "$CERT")" "$(dirname "$KEY")"
install -m 644 -o "$NODE_USER" -g "$NODE_USER" "$(realpath "$LINEAGE/fullchain.pem")" "$CERT.new" && mv -f "$CERT.new" "$CERT"
install -m 600 -o "$NODE_USER" -g "$NODE_USER" "$(realpath "$LINEAGE/privkey.pem")" "$KEY.new" && mv -f "$KEY.new" "$KEY"
END=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
log "renewed $DNS: copied to $(dirname "$CERT"), valid until $END"

if [ "$RESTART_NODE" = "1" ]; then
  systemctl restart "$SERVICE" && log "restarted $SERVICE"
fi

MON=/etc/redbelly-monitor/config.json
if [ -r "$MON" ] && command -v python3 >/dev/null; then
  python3 - "$MON" "$DNS" "$END" <<'EOF' || true
import json, sys, urllib.request
c = json.load(open(sys.argv[1]))
if c.get("telegram_token") and c.get("telegram_chat_id"):
    body = json.dumps({"chat_id": c["telegram_chat_id"], "text": f"🔐 Redbelly certificate renewed: {sys.argv[2]}, valid until {sys.argv[3]}"}).encode()
    req = urllib.request.Request(f"https://api.telegram.org/bot{c['telegram_token']}/sendMessage", body, {"content-type": "application/json"})
    urllib.request.urlopen(req, timeout=15)
EOF
fi
