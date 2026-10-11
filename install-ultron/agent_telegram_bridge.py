#!/usr/bin/env python3
"""Agent Telegram Bridge — one bot per agent (ULTRON, VISKO, ...).

Each agent reads its OWN token; nothing is shared.
Token source (in order):
  1) env var  <AGENT>_TELEGRAM_TOKEN      e.g. ULTRON_TELEGRAM_TOKEN / VISKO_TELEGRAM_TOKEN
  2) file     %LOCALAPPDATA%\\BrahmaAI\\config\\telegram_<agent>.json  {"token": "..."}

Run:  python agent_telegram_bridge.py --agent VISKO
"""
import argparse
import json
import os
import time
import urllib.request
import urllib.parse
from pathlib import Path
from datetime import datetime, timezone

API = "https://api.telegram.org/bot{token}/{method}"


def data_dir() -> Path:
    base = os.getenv("LOCALAPPDATA", os.path.expanduser("~"))
    d = Path(base) / "BrahmaAI"
    d.mkdir(parents=True, exist_ok=True)
    return d


def load_token(agent: str) -> str:
    env_name = f"{agent.upper()}_TELEGRAM_TOKEN"
    tok = os.getenv(env_name, "").strip()
    if tok:
        return tok
    cfg = data_dir() / "config" / f"telegram_{agent.lower()}.json"
    if cfg.exists():
        return json.loads(cfg.read_text(encoding="utf-8")).get("token", "").strip()
    raise SystemExit(f"No token for {agent}. Set {env_name} or create {cfg}")


def call(token, method, **params):
    url = API.format(token=token, method=method)
    with urllib.request.urlopen(url, data=urllib.parse.urlencode(params).encode(), timeout=35) as r:
        return json.loads(r.read())


def memory_path() -> Path:
    return data_dir() / "memory" / "long_term.json"


def rules_path() -> Path:
    return data_dir() / "config" / "learned_rules.json"


def log_memory(agent, change, why="", nxt=""):
    p = memory_path()
    p.parent.mkdir(parents=True, exist_ok=True)
    entry = {"ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
             "agent": agent, "change": change, "why": why, "next": nxt}
    try:
        mem = json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}
    except Exception:
        mem = {}
    mem.setdefault("log", []).append(entry)
    p.write_text(json.dumps(mem, indent=2, ensure_ascii=False), encoding="utf-8")
    with open(p.parent / "MEMORY.md", "a", encoding="utf-8") as f:
        f.write(f"{entry['ts']} | {agent} | {change} | {why} | {nxt}\n")


def status_text(agent):
    m = memory_path().parent / "MEMORY.md"
    lines = m.read_text(encoding="utf-8").strip().splitlines() if m.exists() else []
    n_rules = 0
    if rules_path().exists():
        try:
            n_rules = len(json.loads(rules_path().read_text(encoding="utf-8")))
        except Exception:
            pass
    return (f"🟢 {agent} online\n• memory entries: {max(0, len(lines) - 2)}\n"
            f"• learned rules: {n_rules}\n• last: {lines[-1] if lines else '—'}")


def handle(token, agent, msg):
    text = (msg.get("text") or "").strip()
    cid = msg["chat"]["id"]

    def send(t):
        call(token, "sendMessage", chat_id=cid, text=t)

    if text in ("/start", "/help"):
        send(f"{agent} commands\n/status\n/rules\n/remember <text>\n/note <text>\n/help")
    elif text == "/status":
        send(status_text(agent))
    elif text == "/rules":
        r = json.loads(rules_path().read_text(encoding="utf-8")) if rules_path().exists() else []
        send("\n".join(f"{i+1}. {x.get('rule','?')}" for i, x in enumerate(r)) or "no rules yet")
    elif text.startswith("/remember "):
        t = text[len("/remember "):].strip()
        r = json.loads(rules_path().read_text(encoding="utf-8")) if rules_path().exists() else []
        r.append({"id": f"{agent.lower()}-{int(time.time())}", "rule": t, "category": "telegram", "origin": agent})
        rules_path().parent.mkdir(parents=True, exist_ok=True)
        rules_path().write_text(json.dumps(r, indent=2, ensure_ascii=False), encoding="utf-8")
        send(f"✅ rule saved: {t}")
    elif text.startswith("/note "):
        log_memory(agent, text[len("/note "):].strip())
        send("📝 logged to memory")
    else:
        log_memory(agent, text)
        send("(logged) Use /help")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--agent", default=os.getenv("AGENT_NAME", "ULTRON"))
    args = ap.parse_args()
    agent = args.agent.upper()
    token = load_token(agent)
    print(f"{agent} Telegram bridge running. Ctrl+C to stop.")
    log_memory(agent, "bridge started")
    offset = 0
    while True:
        try:
            for u in call(token, "getUpdates", offset=offset, timeout=30).get("result", []):
                offset = u["update_id"] + 1
                if "message" in u:
                    handle(token, agent, u["message"])
        except KeyboardInterrupt:
            print("stopped"); break
        except Exception as e:
            print("poll error:", e); time.sleep(3)


if __name__ == "__main__":
    main()
