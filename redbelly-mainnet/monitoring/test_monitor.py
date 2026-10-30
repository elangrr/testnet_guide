"""Offline checks for monitor.problems(): cert, balance, stall rules. Run: python test_monitor.py"""
from datetime import timedelta
from decimal import Decimal
import monitor as m

m.service_active = lambda name: True
cfg = dict(m.DEFAULT_CFG)


def st(**kw):
    s = {"block": 100, "gov_block": 100, "sb": 1, "boot_sb": 1, "synced": True, "signing_bal": Decimal(50),
         "since_block": timedelta(minutes=1), "since_gov_sync": timedelta(seconds=10),
         "cert_node_left": timedelta(days=60), "cert_disk_left": timedelta(days=60)}
    s.update(kw)
    return s


cases = [
    ("healthy", st(), set()),
    ("cert 15d = auto-renew late", st(cert_node_left=timedelta(days=15), cert_disk_left=timedelta(days=15)), {"cert"}),
    ("cert 3d critical", st(cert_node_left=timedelta(days=3), cert_disk_left=timedelta(days=3)), {"cert"}),
    ("cert expired", st(cert_node_left=timedelta(days=-1), cert_disk_left=timedelta(days=-1)), {"cert"}),
    ("renewed on disk, node old", st(cert_node_left=timedelta(days=40), cert_disk_left=timedelta(days=89)), {"certload"}),
    ("low balance", st(signing_bal=Decimal(2)), {"balance"}),
    ("quiet chain is fine", st(since_block=timedelta(hours=3)), set()),
    ("stalled while behind", st(since_block=timedelta(hours=1), gov_block=150), {"stall"}),
    ("far behind", st(gov_block=500, since_block=timedelta(minutes=1)), {"behind"}),
]
bad = 0
for name, s, want in cases:
    got = set(m.problems(s, cfg, {}, None))
    ok = got == want
    bad += not ok
    print(("ok  " if ok else "FAIL"), name, sorted(got))
got = set(m.problems(None, cfg, {}, "no reply"))
print("ok  " if got == {"status"} else "FAIL", "status server down", sorted(got))
bad += got != {"status"}
raise SystemExit(bad)
