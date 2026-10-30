# Redbelly Node Monitor + Certificate Auto-Renew

Get a Telegram message when your Redbelly node has a problem, and never let its TLS certificate expire.

- ✅ Alerts when the node stops syncing, falls behind, runs low on signing balance, or the disk fills up
- ✅ A ✅ message when the problem is fixed, and a short status report every 6 hours
- 🔐 Renews the node's certificate automatically (30 days before it expires) and tells you when it did
- 🛡️ Read-only: it never touches your signing key and never restarts your node

Works with the official Redbelly installer **and** with custom setups (other service names, users, folders or ports): the installer finds your settings by itself.

---

## Before you start (5 minutes)

You need three things:

**1. A Telegram bot token**
1. In Telegram, open **[@BotFather](https://t.me/BotFather)** and send `/newbot`
2. Pick a name, then a username ending in `bot`
3. BotFather replies with a token like `7123456789:AAH...`. Copy it.
4. Open your new bot and press **Start** (otherwise it cannot message you)

**2. Your Telegram chat id**
- Open **[@userinfobot](https://t.me/userinfobot)** and press **Start**. It replies with your id, e.g. `123456789`.

**3. Your node's domain points to this server**
- The same domain your node certificate is for (e.g. `mynode.example.com`), and **port 80** open: `sudo ufw allow 80/tcp`

---

## Install (one command)

Log in to your node server and run:

```bash
curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/install.sh -o install.sh && sudo bash install.sh
```

The installer shows what it found and asks a few questions. **Press Enter** to accept a suggestion:

```
== 1/6 Finding your node
  ✓ node service: redbelly (active)
  Node TLS certificate file: [/etc/redbelly/certs/mynode.example.com/fullchain.pem]   <- Enter
  Node domain: [mynode.example.com]                                                    <- Enter
== 3/6 Telegram
  Telegram bot token (Enter = no Telegram):   <- paste the token
  Telegram chat id:                            <- paste your id
  Warn me when the signing wallet has less than (RBNT): [10]
== 5/6 Certificate auto-renew
  ✓ certbot checks twice a day and renews 30 days before expiry
  ✓ renewal test passed
== 6/6 Check
  ✓ test message sent: check Telegram
```

That's it. You should now have a test message in Telegram. The monitor runs in the background and starts again after a reboot.

---

## Everyday commands

```bash
# live dashboard (Ctrl+C to quit)
sudo -u rbmon /opt/redbelly-monitor/venv/bin/python /opt/redbelly-monitor/monitor.py --config /etc/redbelly-monitor/config.json --console

# logs
journalctl -u redbelly-monitor -f

# certificate renewal history
cat /var/log/redbelly-cert-hook.log
```

- **Change a setting** (token, minimum balance...): just run the install command again. It remembers your answers.
- **Update** to the newest version: run the install command again.
- **Remove**: `curl -fsSL https://raw.githubusercontent.com/elangrr/testnet_guide/main/redbelly-mainnet/monitoring/uninstall.sh | sudo bash`

---

## Different setups

The installer reads your node's systemd service (`--tls.cert`, `--tls.key`, `--statusserver.udp.port`, the `User=`) and, if present, the official installer's `/etc/redbelly/rbninstaller-config`. If something is not found, it asks you.

**The status server must be on.** Your node start command needs:
```
--statusserver.udp.addr=127.0.0.1 --statusserver.udp.port=6540
```
The official installer turns it on by default. If you add it yourself, the node needs a restart (choose a quiet time).

**Docker or no systemd service?** The installer cannot read your settings, so it asks for the certificate path and status port. Or give them up front:
```bash
RB_CERT=/path/fullchain.pem RB_KEY=/path/privkey.pem RB_DNS=mynode.example.com RB_PORT=6540 RB_NODE_USER=root sudo -E bash install.sh
```

**No certificate from Let's Encrypt yet?** The installer offers to get one (using nginx if it runs, otherwise certbot on port 80).

**Your node does not pick up a renewed certificate by itself?** (rbbc 1.3.x does; the monitor warns you if yours does not.) Set `RESTART_NODE=1` in `/etc/redbelly-monitor/cert-hook.conf` and the node restarts right after each renewal.

**No questions at all** (for scripts):
```bash
RB_TG_TOKEN="7123456789:AAH..." RB_TG_CHAT="123456789" RB_MIN_BALANCE=10 RB_YES=1 sudo -E bash install.sh
```

---

## Settings

Stored in `/etc/redbelly-monitor/config.json`. After editing: `sudo systemctl restart redbelly-monitor`.

| Setting | Default | What it does |
|---|---|---|
| `min_balance` | 10 | Alert when the signing wallet has less RBNT than this |
| `reward_address` | empty | Also show this address's balance |
| `telegram_interval` | 21600 | Seconds between status reports (0 = only alerts) |
| `realert_hours` | 6 | Repeat an alert that is still open after this many hours |
| `max_blocks_behind` | 100 | Alert when the node is this far behind |
| `max_minutes_no_block` | 30 | Alert when no new block for this long **while others are ahead** (a quiet chain is normal) |
| `cert_warn_days` / `cert_critical_days` | 21 / 7 | Certificate warnings (renewal normally happens at 30) |
| `disk_warn_pct` | 85 | Disk usage alert |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Status server unreachable" | The node needs `--statusserver.udp.port=6540` (see above). Test: `sudo -u rbmon /opt/redbelly-monitor/venv/bin/python /opt/redbelly-monitor/monitor.py --config /etc/redbelly-monitor/config.json --test-udp` |
| No Telegram message | Did you press **Start** in your bot? Then run the installer again and re-enter the token and chat id. |
| "renewal test FAILED" | Port 80 must be open (`sudo ufw allow 80/tcp`) and your domain must point to this server. Details: `/tmp/rb-dryrun.log` |
| Double messages | An old monitor still runs in `screen`: `screen -ls`, open it with `screen -r <name>`, press Ctrl+C. |

Coming from the old `screen` + `monitor.py` setup? Install as above, then stop the old screen session.
