#!/usr/bin/env python3
"""Prune consumed verdict lines from REVIEW.md (user-side cleanup, invoked by the
nvim plugin). Removes any verdict the daemon has already acted on, keeping comments
and any still-pending verdict (collapsed to its latest line per id). The daemon's
memory lives in .taskloop/state.json (`consumed`), so dropping acted lines is safe.

Usage: taskloop-prune.py <repo-root>
Prints: "pruned <N>" (lines removed).
"""
import os, sys, re, json, hashlib

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
REVIEW = os.path.join(ROOT, "REVIEW.md")
STATE = os.path.join(ROOT, ".taskloop", "state.json")

def h(s):
    return hashlib.sha1(s.encode("utf-8")).hexdigest()[:12]

try:
    consumed = json.load(open(STATE)).get("consumed", {})
except Exception:
    consumed = {}
try:
    lines = open(REVIEW, encoding="utf-8").read().split("\n")
except FileNotFoundError:
    print("pruned 0"); sys.exit(0)

# Parse verdict entries with their line ranges (mirrors the daemon's parse_review).
entries = []  # (id, verdict_text, start, end_exclusive)
i, n = 0, len(lines)
while i < n:
    m = re.match(r"^\s*#(\d+)\s*(.*)$", lines[i])
    if not m:
        i += 1; continue
    tid, rest = m.group(1), m.group(2).strip()
    if rest == "<<":                       # fenced multi-line
        start, i, body = i, i + 1, []
        while i < n and lines[i].strip() != ">>":
            body.append(lines[i]); i += 1
        end = i + 1; i = end
        entries.append((tid, "\n".join(body).strip(), start, end))
    elif rest:
        entries.append((tid, rest, i, i + 1)); i += 1
    else:
        i += 1

def is_consumed(tid, hsh):
    v = consumed.get(tid)
    if v is None:
        return False
    return (v == hsh) if isinstance(v, str) else (hsh in v)

# Drop verdicts the daemon has already acted on; keep still-pending ones (and
# collapse duplicate pending lines for the same id).
drop, kept_pending = set(), set()
for tid, v, s, e in entries:
    hv = h(v)
    if is_consumed(tid, hv) or (tid, hv) in kept_pending:
        for k in range(s, e):
            drop.add(k)
    else:
        kept_pending.add((tid, hv))

if not drop:
    print("pruned 0"); sys.exit(0)

kept = [l for idx, l in enumerate(lines) if idx not in drop]
# tidy trailing blank runs
while len(kept) > 1 and kept[-1].strip() == "" and kept[-2].strip() == "":
    kept.pop()
tmp = REVIEW + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    f.write("\n".join(kept))
os.replace(tmp, REVIEW)
print(f"pruned {len(drop)}")
