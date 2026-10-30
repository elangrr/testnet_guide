#!/usr/bin/env bash
# Removes the Redbelly monitor and its certificate hook. The node, its certificates and certbot stay untouched.
set -u
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
systemctl disable --now redbelly-monitor redbelly-certbot.timer 2>/dev/null
rm -f /etc/systemd/system/redbelly-monitor.service /etc/systemd/system/redbelly-certbot.service /etc/systemd/system/redbelly-certbot.timer
rm -f /etc/letsencrypt/renewal-hooks/deploy/redbelly-cert.sh
systemctl daemon-reload
rm -rf /opt/redbelly-monitor
echo "Removed. Settings kept in /etc/redbelly-monitor (delete with: sudo rm -rf /etc/redbelly-monitor)."
