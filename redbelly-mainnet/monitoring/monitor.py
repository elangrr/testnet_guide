#!/usr/bin/env python3
"""
Redbelly Node Monitor v3
- Reads the node's UDP status server (default 127.0.0.1:6540)
- Telegram: periodic status report + instant alerts when a problem starts and when it is fixed
  (no repeated spam: each problem alerts once, then again only after `realert_hours`)
- TLS certificate watch: what the node has loaded, what is on disk, and whether auto-renew is overdue
- Signing / reward balance, governor status, CPU / RAM / disk
- Runs as a systemd service (install.sh) or in a terminal with a live dashboard (--console)
"""

import argparse
import json
import logging
import os
import socket
import subprocess
import sys
import time
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

import requests
from dateutil import parser as date_parser

try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False

VERSION = "3.0"
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)-7s %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
log = logging.getLogger("redbelly-monitor")

WEI = Decimal(10) ** 18
UDP_MSG = b"getStatus"
INSTALLER_CONFIG = Path("/etc/redbelly/rbninstaller-config")
CONFIG_PATHS = [Path("/etc/redbelly-monitor/config.json"), Path("redbelly_config.json")]

DEFAULT_CFG = {
    "udp_host": "127.0.0.1",
    "udp_port": 6540,
    "service_name": "redbelly",
    "min_balance": 10,
    "refresh_seconds": 15,
    "telegram_interval": 21600,      # status report every 6 h (0 = alerts only)
    "realert_hours": 6,              # repeat an unresolved alert after this many hours
    "telegram_token": "",
    "telegram_chat_id": "",
    "reward_address": "",
    "rpc_url": "https://governors.mainnet.redbelly.network",
    "cert_file": "",                 # empty = read from /etc/redbelly/rbninstaller-config
    "cert_warn_days": 21,            # certbot renews at 30 days left; under 21 means auto-renew is failing
    "cert_critical_days": 7,
    "max_blocks_behind": 100,
    "max_minutes_no_block": 30,      # Redbelly only makes blocks when there are transactions
    "max_minutes_gov_sync": 5,
    "disk_warn_pct": 85,
}

_block_samples: list[tuple[int, datetime]] = []


# ── helpers ──────────────────────────────────────────────────────────────────

def fmt_duration(td: timedelta | None) -> str:
    if td is None:
        return "N/A"
    secs = int(td.total_seconds())
    neg, secs = secs < 0, abs(secs)
    d, r = divmod(secs, 86400)
    h, r = divmod(r, 3600)
    m = r // 60
    out = f"{d}d {h}h" if d else (f"{h}h {m}m" if h else f"{m}m")
    return "-" + out if neg else out


def parse_ts(raw) -> datetime | None:
    if not raw:
        return None
    try:
        from dateutil.tz import tzoffset
        tz = {k: tzoffset(k, v) for k, v in {"CET": 3600, "CEST": 7200, "UTC": 0, "GMT": 0}.items()}
        dt = date_parser.parse(str(raw), tzinfos=tz)
        return (dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)).astimezone(timezone.utc)
    except Exception:
        return None


def block_rate() -> float:
    if len(_block_samples) < 2:
        return 0.0
    (b0, t0), (b1, t1) = _block_samples[0], _block_samples[-1]
    dt = (t1 - t0).total_seconds()
    return 0.0 if dt <= 0 else (b1 - b0) / dt


def read_installer_config() -> dict:
    out = {}
    try:
        for line in INSTALLER_CONFIG.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip().strip('"')
    except OSError:
        pass
    return out


def cert_file_expiry(path: str) -> datetime | None:
    """Expiry of the certificate file on disk (public cert only; the private key is never read)."""
    if not path or not os.path.exists(path):
        return None
    try:
        r = subprocess.run(["openssl", "x509", "-in", path, "-noout", "-enddate"], capture_output=True, text=True, timeout=10)
        return parse_ts(r.stdout.strip().split("=", 1)[1]) if r.returncode == 0 else None
    except Exception:
        return None


# ── data sources ─────────────────────────────────────────────────────────────

def fetch_status_udp(host: str, port: int) -> dict:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.settimeout(3)
        try:
            s.sendto(UDP_MSG, (host, port))
            data, _ = s.recvfrom(65535)
            return json.loads(data.decode())
        except socket.timeout:
            raise ConnectionError(f"no reply from status server {host}:{port}")
        except (OSError, ValueError) as e:
            raise ConnectionError(f"status server error: {e}")


def get_governor_status() -> str:
    for url in ("http://localhost:8080/metrics", "http://localhost:8080/debug/metrics"):
        try:
            r = requests.get(url, timeout=3)
            for line in r.text.splitlines() if r.ok else []:
                if line.startswith("is_governor "):
                    return "Governor" if line.split()[1].startswith("1") else "Candidate"
        except requests.RequestException:
            pass
    return "Unknown"


def get_balance(rpc: str, address: str) -> Decimal | None:
    try:
        r = requests.post(rpc, json={"jsonrpc": "2.0", "method": "eth_getBalance", "params": [address, "latest"], "id": 1}, timeout=10)
        r.raise_for_status()
        return Decimal(int(r.json().get("result") or "0x0", 16)) / WEI
    except Exception as e:
        log.warning(f"balance fetch failed: {e}")
        return None


def service_active(name: str) -> bool:
    try:
        return subprocess.run(["systemctl", "is-active", name], capture_output=True, text=True, timeout=5).stdout.strip() == "active"
    except Exception:
        return False


def system_info() -> dict:
    if not HAS_PSUTIL:
        return {}
    try:
        vm, du = psutil.virtual_memory(), psutil.disk_usage("/")
        return {"cpu": psutil.cpu_percent(interval=1), "ram": vm.percent, "disk": du.percent,
                "disk_used": du.used / 1024 ** 3, "disk_total": du.total / 1024 ** 3,
                "uptime": datetime.now(timezone.utc) - datetime.fromtimestamp(psutil.boot_time(), tz=timezone.utc)}
    except Exception:
        return {}


# ── status model ─────────────────────────────────────────────────────────────

def parse_status(d: dict, cfg: dict) -> dict:
    now = datetime.now(timezone.utc)

    def ago(key):
        t = parse_ts(d.get(key))
        return (now - t) if t else None

    cert_node = parse_ts(d.get("certificatesValidUpto"))
    cert_disk = cert_file_expiry(cfg["cert_file"])
    raw_bal = d.get("signingAddressBalance") or "0"
    return {
        "now": now,
        "block": int(d.get("currentBlock", 0)),
        "gov_block": int(d.get("lastBlockFromGovernors", 0)),
        "sb": int(d.get("currentSuperblock", 0)),
        "boot_sb": int(d.get("lastSuperblockFromBootnodes", 0)),
        "synced": bool(d.get("isRecoveryComplete", False)),
        "signing_addr": str(d.get("signingAddress", "")),
        "signing_bal": Decimal(str(raw_bal)) / WEI,
        "version": str(d.get("version", "?")).split()[0],
        "cert_dns": d.get("certificateDnsNames") or [],
        "since_block": ago("lastCommittedBlockAt"),
        "since_gov_sync": ago("lastSyncedWithGovernorNodes"),
        "cert_node_left": (cert_node - now) if cert_node else None,
        "cert_disk_left": (cert_disk - now) if cert_disk else None,
    }


def problems(s: dict | None, cfg: dict, sysi: dict, err: str | None) -> dict:
    """Current problems as {key: text}. Keys stay stable so each problem alerts once."""
    p = {}
    if cfg["service_name"] and not service_active(cfg["service_name"]):
        p["service"] = f"systemd service {cfg['service_name']} is NOT active"
    if err:
        p["status"] = f"Status server unreachable: {err}"
    if s:
        behind = s["gov_block"] - s["block"]
        if not s["synced"]:
            p["sync"] = "Node is still syncing"
        if behind > cfg["max_blocks_behind"]:
            p["behind"] = f"Node is {behind:,} blocks behind the governors"
        if s["since_block"] and s["since_block"] > timedelta(minutes=cfg["max_minutes_no_block"]) and behind > 0:
            p["stall"] = f"No new block for {fmt_duration(s['since_block'])} while governors are ahead"
        if s["since_gov_sync"] and s["since_gov_sync"] > timedelta(minutes=cfg["max_minutes_gov_sync"]):
            p["govsync"] = f"Last governor sync {fmt_duration(s['since_gov_sync'])} ago"
        if s["signing_bal"] < cfg["min_balance"]:
            p["balance"] = f"Signing balance low: {s['signing_bal']:.4f} RBNT (min {cfg['min_balance']})"
        node, disk = s["cert_node_left"], s["cert_disk_left"]
        if node is not None:
            if node.total_seconds() <= 0:
                p["cert"] = "TLS certificate EXPIRED"
            elif node < timedelta(days=cfg["cert_critical_days"]):
                p["cert"] = f"TLS certificate expires in {fmt_duration(node)}"
            elif node < timedelta(days=cfg["cert_warn_days"]):
                p["cert"] = (f"TLS certificate has {fmt_duration(node)} left: auto-renew should have run at 30 days. "
                             "Check: sudo certbot renew --dry-run")
        if node is not None and disk is not None and disk - node > timedelta(days=1):
            p["certload"] = (f"Renewed certificate is on disk ({fmt_duration(disk)} left) but the node still uses the "
                             f"old one ({fmt_duration(node)} left). Restart the node at a quiet moment.")
    if sysi.get("disk", 0) >= cfg["disk_warn_pct"]:
        p["disk"] = f"Disk {sysi['disk']:.0f}% full ({sysi['disk_used']:.0f}/{sysi['disk_total']:.0f} GB)"
    return p


# ── output ───────────────────────────────────────────────────────────────────

def cert_line(left: timedelta | None, cfg: dict) -> str:
    if left is None:
        return "N/A"
    if left.total_seconds() <= 0:
        return "🔴 EXPIRED"
    if left < timedelta(days=cfg["cert_critical_days"]):
        icon = "🔴"
    elif left < timedelta(days=cfg["cert_warn_days"]):
        icon = "🟡"
    else:
        icon = "🟢"
    return f"{icon} {fmt_duration(left)} left"


def report(s: dict | None, gov: str, reward, sysi: dict, probs: dict, cfg: dict) -> str:
    if not s:
        return "📊 <b>Redbelly Node</b>\n🔴 status server unreachable\n\n" + "\n".join(f"• {v}" for v in probs.values())
    behind = s["gov_block"] - s["block"]
    head = "🟢 OK" if not probs else f"⚠️ {len(probs)} issue(s)"
    lines = [
        f"📊 <b>Redbelly Node</b> ({head})",
        f"🔧 v{s['version']} · {'synced' if s['synced'] else 'syncing'} · {gov}",
        f"📦 Block {s['block']:,} (behind {behind:,}) · last {fmt_duration(s['since_block'])} ago",
        f"🏗 Superblock {s['sb']:,} (behind {s['boot_sb'] - s['sb']:,})",
        f"💰 Signing {s['signing_bal']:.4f} RBNT" + (f" · Reward {reward:.4f} RBNT" if reward is not None else ""),
        f"🔐 Cert {', '.join(s['cert_dns'])}: node {cert_line(s['cert_node_left'], cfg)} · file {cert_line(s['cert_disk_left'], cfg)}",
    ]
    if sysi:
        lines.append(f"💻 CPU {sysi['cpu']:.0f}% · RAM {sysi['ram']:.0f}% · Disk {sysi['disk']:.0f}% · up {fmt_duration(sysi['uptime'])}")
    if probs:
        lines += ["", "⚠️ <b>Issues</b>"] + [f"• {v}" for v in probs.values()]
    return "\n".join(lines)


class Telegram:
    def __init__(self, token: str, chat: str):
        self.url, self.chat = f"https://api.telegram.org/bot{token}/sendMessage", chat

    def send(self, text: str) -> bool:
        try:
            r = requests.post(self.url, json={"chat_id": self.chat, "text": text, "parse_mode": "HTML",
                                              "disable_web_page_preview": True}, timeout=15)
            r.raise_for_status()
            return True
        except Exception as e:
            log.error(f"telegram send failed: {type(e).__name__}")   # never log the URL: it holds the token
            return False


# ── main loop ────────────────────────────────────────────────────────────────

def collect(cfg: dict):
    try:
        raw, err = fetch_status_udp(cfg["udp_host"], cfg["udp_port"]), None
    except ConnectionError as e:
        raw, err = None, str(e)
    s = parse_status(raw, cfg) if raw else None
    if s:
        _block_samples.append((s["block"], s["now"]))
        del _block_samples[:-20]
    return s, err


def run(cfg: dict, tg, console: bool):
    open_alerts: dict = {}
    epoch = datetime.min.replace(tzinfo=timezone.utc)
    last_report, reward, reward_ts = epoch, None, epoch
    if tg:
        tg.send(f"🚀 <b>Redbelly Monitor v{VERSION} started</b>")
    while True:
        s, err = collect(cfg)
        sysi = system_info()
        now = datetime.now(timezone.utc)
        if cfg["reward_address"] and now - reward_ts > timedelta(minutes=10):
            reward, reward_ts = get_balance(cfg["rpc_url"], cfg["reward_address"]), now
        gov = get_governor_status() if s else "Unknown"
        probs = problems(s, cfg, sysi, err)

        if tg:
            for k, text in probs.items():
                if k not in open_alerts or now - open_alerts[k] > timedelta(hours=cfg["realert_hours"]):
                    if tg.send(f"🚨 <b>Redbelly alert</b>\n{text}"):
                        open_alerts[k] = now
            for k in [k for k in open_alerts if k not in probs]:
                tg.send(f"✅ <b>Redbelly recovered</b>\n{k} is OK again")
                del open_alerts[k]
            if cfg["telegram_interval"] and (now - last_report).total_seconds() >= cfg["telegram_interval"]:
                if tg.send(report(s, gov, reward, sysi, probs, cfg)):
                    last_report = now

        if console:
            plain = report(s, gov, reward, sysi, probs, cfg).replace("<b>", "").replace("</b>", "")
            print("\033[2J\033[H" + plain + f"\n\nrate {block_rate():.3f} blk/s · {now:%H:%M:%S} UTC · Ctrl+C to stop", flush=True)
        elif probs:
            log.warning("issues: " + " | ".join(probs.values()))
        time.sleep(cfg["refresh_seconds"])


def load_config(path: str | None) -> dict:
    cfg = dict(DEFAULT_CFG)
    for p in ([Path(path)] if path else CONFIG_PATHS):
        if p.exists():
            cfg.update(json.loads(p.read_text()))
            log.info(f"config: {p}")
            break
    for key, val in DEFAULT_CFG.items():   # REDBELLY_<KEY> environment overrides, e.g. REDBELLY_MIN_BALANCE=20
        env = os.getenv("REDBELLY_" + key.upper())
        if env:
            cfg[key] = env if isinstance(val, str) else type(val)(env)
    if not cfg["cert_file"]:
        cfg["cert_file"] = read_installer_config().get("FULL_PATH_FOR_CERTIFICATE_FILE", "")
    return cfg


def main():
    ap = argparse.ArgumentParser(description=f"Redbelly Node Monitor v{VERSION}")
    ap.add_argument("--config", help="config file (default /etc/redbelly-monitor/config.json or ./redbelly_config.json)")
    ap.add_argument("--console", action="store_true", help="live dashboard in the terminal")
    ap.add_argument("--once", action="store_true", help="print one report and exit")
    ap.add_argument("--test-telegram", action="store_true", help="send one report to Telegram and exit")
    ap.add_argument("--test-udp", action="store_true", help="print the raw status JSON and exit")
    a = ap.parse_args()
    cfg = load_config(a.config)
    tg = Telegram(cfg["telegram_token"], cfg["telegram_chat_id"]) if cfg["telegram_token"] and cfg["telegram_chat_id"] else None

    if a.test_udp:
        try:
            print(json.dumps(fetch_status_udp(cfg["udp_host"], cfg["udp_port"]), indent=2))
        except ConnectionError as e:
            sys.exit(f"FAILED: {e}")
        return
    if a.once or a.test_telegram:
        s, err = collect(cfg)
        sysi = system_info()
        reward = get_balance(cfg["rpc_url"], cfg["reward_address"]) if cfg["reward_address"] else None
        text = report(s, get_governor_status() if s else "Unknown", reward, sysi, problems(s, cfg, sysi, err), cfg)
        if a.test_telegram:
            if not tg:
                sys.exit("No telegram_token / telegram_chat_id in the config")
            sys.exit(0 if tg.send(text) else "Telegram send failed: check the token and chat id")
        print(text.replace("<b>", "").replace("</b>", ""))
        return
    if not tg:
        log.info("no Telegram settings: console/log only")
    try:
        run(cfg, tg, a.console)
    except KeyboardInterrupt:
        if tg:
            tg.send("🛑 <b>Redbelly Monitor stopped</b>")


if __name__ == "__main__":
    main()
