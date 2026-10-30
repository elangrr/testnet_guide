# Redbelly Mainnet Node Monitor + Certificate Auto-Renew

A Telegram monitor for a Redbelly node, plus automatic renewal of the node's TLS certificate.
One command installs both. The script asks for your Telegram bot token and chat id and sets up everything else.

## What it does

**Monitor**
- Block height, sync status, how far behind the governors, superblocks
- Governor / Candidate status, node version
- Signing wallet balance (alert below your minimum) and, optionally, your reward address balance
- TLS certificate: what the node has loaded **and** what is on disk
- CPU, RAM, disk, uptime

**Telegram**
- A status report every 6 hours
- An instant alert when something goes wrong, and a ✅ message when it is fixed
- Each problem alerts once (repeats after 6 h if still open), so no spam

**Certificate auto-renew**
- certbot renews the Let's Encrypt certificate 30 days before it expires (checked twice a day)
- A certbot hook copies the new certificate to the node's certificate folder with the right owner and permissions
- You get a Telegram message after every renewal
- The monitor warns you if the certificate gets below 21 days (auto-renew failing) and if a renewed certificate is on disk but the node still uses the old one
- The node does not need a restart: rbbc 1.3.x picks up the new files by itself (if yours does not, the monitor tells you; you can also set `RESTART_NODE=1` in `/etc/redbelly-monitor/cert-hook.conf`)

## Requirements

- A Redbelly node installed with the official installer (it creates `/etc/redbelly/rbninstaller-config`)
- The status server enabled: `--statusserver.udp.addr=127.0.0.1 --statusserver.udp.port=6540` (the installer enables it by default)
- Ubuntu / Debian with `sudo`
- For auto-renew: your node domain points to this server and port 80 is reachable for Let's Encrypt
- A Telegram bot token from [@BotFather](https://t.me/BotFather) and your chat id from [@userinfobot](https://t.me/userinfobot)

## Install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/install.sh -o install.sh && sudo bash install.sh
```

The installer:
1. checks your node (domain, certificate path, status server)
2. installs what is missing (python3-venv, openssl, certbot)
3. asks for your Telegram token, chat id, minimum balance and (optional) reward address
4. installs the monitor as a service (`redbelly-monitor`, runs as its own user `rbmon`, starts on boot)
5. sets up certificate auto-renew and tests it with a dry run
6. prints one report and sends a test message to Telegram

It never reads or touches your signing key, and it never restarts your node.

**No prompts** (for scripts):
```bash
RB_TG_TOKEN="123:abc" RB_TG_CHAT="123456" RB_MIN_BALANCE=10 RB_REWARD="0x..." RB_YES=1 sudo -E bash install.sh
```

## Daily use

| What | Command |
|---|---|
| Live dashboard | `sudo -u rbmon /opt/redbelly-monitor/venv/bin/python /opt/redbelly-monitor/monitor.py --config /etc/redbelly-monitor/config.json --console` |
| One report now | same command with `--once` instead of `--console` |
| Logs | `journalctl -u redbelly-monitor -f` |
| Change settings | `sudo nano /etc/redbelly-monitor/config.json && sudo systemctl restart redbelly-monitor` |
| Certificate renewals | `cat /var/log/redbelly-cert-hook.log` |
| Test renewal | `sudo certbot renew --dry-run` |
| Update | run the install command again (your settings are kept) |
| Remove | `curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/uninstall.sh \| sudo bash` |

## Settings (`/etc/redbelly-monitor/config.json`)

| Key | Default | Meaning |
|---|---|---|
| `telegram_token`, `telegram_chat_id` | | Telegram bot and chat |
| `min_balance` | 10 | Alert when the signing balance is below this (RBNT) |
| `reward_address` | | Optional address whose balance is shown |
| `telegram_interval` | 21600 | Seconds between status reports (0 = alerts only) |
| `realert_hours` | 6 | Repeat an unresolved alert after this many hours |
| `cert_warn_days`, `cert_critical_days` | 21, 7 | Certificate warning levels |
| `max_blocks_behind` | 100 | Alert when this far behind the governors |
| `max_minutes_no_block` | 30 | Alert when no block for this long **and** the governors are ahead (a quiet chain is normal) |
| `disk_warn_pct` | 85 | Disk usage alert |
| `udp_port` | 6540 | Node status server port |

Any setting can also be overridden with an environment variable `REDBELLY_<KEY>`, e.g. `REDBELLY_MIN_BALANCE=20`.

## Coming from the old screen setup

If you ran `monitor.py` in `screen`, stop it after installing so you don't get double messages:
```bash
screen -ls                    # find the session
screen -r redbelly_monitor    # then Ctrl+C, and exit
```

## Troubleshooting

- **"Status server unreachable"**: check the node flags include `--statusserver.udp.port=6540`, then `sudo -u rbmon /opt/redbelly-monitor/venv/bin/python /opt/redbelly-monitor/monitor.py --test-udp`.
- **Dry-run renewal fails**: port 80 must be open to the internet (`sudo ufw allow 80/tcp`) and your domain must point to this server. If nginx uses port 80, certbot's nginx plugin handles it.
- **No Telegram messages**: `sudo -u rbmon /opt/redbelly-monitor/venv/bin/python /opt/redbelly-monitor/monitor.py --config /etc/redbelly-monitor/config.json --test-telegram`
