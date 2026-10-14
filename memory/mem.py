#!/usr/bin/env python3
"""OSmOS memory — cross-session, cross-agent, offline. Standard library only.

    python mem.py add "shipped installer; fixed M:\\ temp + Python 3.11"
    python mem.py search "installer python"
    python mem.py tail 20
    python mem.py stats
    python mem.py export        # writes MEMORY.md
    python mem.py sync          # optional: git commit/sync the memory dir

Store: JSONL (append-only) at $OSMOS_MEMORY_DIR or %LOCALAPPDATA%/OSmOS/memory
"""
import argparse
import json
import math
import os
import re
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

WORD = re.compile(r"[a-z0-9]+")
STOP = set("the a an and or to of in on for with is are was be by at it this that from as".split())


def mem_dir() -> Path:
    env = os.getenv("OSMOS_MEMORY_DIR")
    base = Path(env) if env else Path(os.getenv("LOCALAPPDATA", str(Path.home()))) / "OSmOS" / "memory"
    base.mkdir(parents=True, exist_ok=True)
    return base


def store() -> Path:
    return mem_dir() / "memory.jsonl"


def toks(s: str):
    return [w for w in WORD.findall(s.lower()) if w not in STOP and len(w) > 1]


def load():
    p = store()
    if not p.exists():
        return []
    out = []
    for line in p.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if line:
            try:
                out.append(json.loads(line))
            except Exception:
                pass
    return out


def add(text, agent="agent", tags=None, why="", nxt=""):
    rec = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "epoch": time.time(),
        "agent": agent or "agent",
        "text": text.strip(),
        "why": why, "next": nxt,
        "tags": [t.strip() for t in (tags or "").split(",") if t.strip()],
    }
    with open(store(), "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
    export_md()
    return rec

def search(query, limit=8):
    q = toks(query)
    recs = load()
    if not q or not recs:
        return []
    df = {}
    for r in recs:
        for t in set(toks(r.get("text", "") + " " + " ".join(r.get("tags", [])))):
            df[t] = df.get(t, 0) + 1
    n = len(recs)
    now = time.time()
    scored = []
    for r in recs:
        rt = toks(r.get("text", "")) + [t.lower() for t in r.get("tags", [])]
        if not rt:
            continue
        counts = {}
        for t in rt:
            counts[t] = counts.get(t, 0) + 1
        score = 0.0
        for t in q:
            if t in counts:
                score += counts[t] * math.log(1 + n / (1 + df.get(t, 0)))
        if score > 0:
            age = (now - r.get("epoch", now)) / 86400.0
            score *= 1.0 + 0.15 / (1.0 + age)
            scored.append((score, r))
    scored.sort(key=lambda x: x[0], reverse=True)
    return scored[:limit]


def export_md():
    recs = load()
    lines = ["# OSmOS shared memory (append-only)", "",
             "Format: ts | agent | text | why | next", "", "---", ""]
    for r in recs:
        tail = " | ".join(x for x in [r.get("why", ""), r.get("next", "")] if x)
        lines.append(r.get("ts", "") + " | " + r.get("agent", "") + " | " + r.get("text", "") + ((" | " + tail) if tail else ""))
    (mem_dir() / "MEMORY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

def git(*args):
    return subprocess.run(["git", *args], cwd=mem_dir(), capture_output=True, text=True)


def main():
    ap = argparse.ArgumentParser(prog="mem", description="OSmOS cross-session memory")
    sub = ap.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("add"); a.add_argument("text"); a.add_argument("--agent", default="agent")
    a.add_argument("--tags", default=""); a.add_argument("--why", default=""); a.add_argument("--next", default="")

    s = sub.add_parser("search"); s.add_argument("query"); s.add_argument("-n", type=int, default=8)
    t = sub.add_parser("tail"); t.add_argument("n", type=int, nargs="?", default=20)
    sub.add_parser("stats"); sub.add_parser("export"); sub.add_parser("path")
    sy = sub.add_parser("sync"); sy.add_argument("-m", default="memory update")

    args = ap.parse_args()

    if args.cmd == "add":
        r = add(args.text, args.agent, args.tags, args.why, args.next)
        print("remembered [" + r["agent"] + "] " + r["text"][:80])
    elif args.cmd == "search":
        hits = search(args.query, args.n)
        if not hits:
            print("no matches")
        for sc, r in hits:
            print("[%.2f] %s | %s | %s" % (sc, r.get("ts", "")[:10], r.get("agent", ""), r.get("text", "")))
    elif args.cmd == "tail":
        for r in load()[-args.n:]:
            print("%s | %s | %s" % (r.get("ts", ""), r.get("agent", ""), r.get("text", "")))
    elif args.cmd == "stats":
        recs = load()
        print("entries: %d" % len(recs)); print("store  : %s" % store())
        if recs:
            ag = {}
            for r in recs:
                ag[r.get("agent", "?")] = ag.get(r.get("agent", "?"), 0) + 1
            print("first  : %s" % recs[0].get("ts", "")); print("last   : %s" % recs[-1].get("ts", ""))
            print("agents : " + ", ".join("%s=%d" % (k, v) for k, v in sorted(ag.items(), key=lambda x: -x[1])))
    elif args.cmd == "export":
        export_md(); print("wrote %s" % (mem_dir() / "MEMORY.md"))
    elif args.cmd == "path":
        print(store())
    elif args.cmd == "sync":
        if not (mem_dir() / ".git").exists():
            git("init"); git("add", "-A"); git("commit", "-m", args.m)
            print("initialized memory git repo (set a remote to push)")
        else:
            git("add", "-A"); git("commit", "-m", args.m); git("pull", "--no-edit"); git("push")
            print("memory synced")


if __name__ == "__main__":
    main()
