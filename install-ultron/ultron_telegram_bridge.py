#!/usr/bin/env python3
"""ULTRON Telegram Bridge — remote control + memory logging for @Klinac_bot.

Security: the token is NEVER hardcoded. It is read from
  1) env var  TELEGRAM_BOT_TOKEN, or
  2) %LOCALAPPDATA%\\BrahmaAI\\config\\telegram.json  {"token": "..."}
Standard library only (no pip needed).

Run:  python ultron_telegram_bridge.py
"""
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


def load_token() -> str:
    tok = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
    if tok:
        return tok
    cfg = data_dir() / "config" / "telegram.json"
    if cfg.exists():
        return json.loads(cfg.read_text(encoding="utf-8")).get("token", "").strip()
    raise SystemExit(
        "No token. Set TELEGRAM_BOT_TOKEN or create "
        f"{cfg} with {{\"token\": \"...\"}}"
    )


def call(token, method, **params):
    url = API.format(token=token, method=method)
    data = urllib.parse.urlencode(params).encode()
    with urllib.request.urlopen(url, data=data, timeout=35) as r:
        return json.loads(r.read())


def memory_path() -> Path:
    return data_dir() / "memory" / "long_term.json"


def rules_path() -> Path:
    return data_dir() / "config" / "learned_rules.json"


def log_memory(agent, change, why="", nxt=""):
    p = memory_path()
    p.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "agent": agent, "change": change, "why": why, "next": nxt,
    }
    try:
        mem = json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}
    except Exception:
        mem = {}
    mem.setdefault("log", []).append(entry)
    p.write_text(json.dumps(mem, indent=2, ensure_ascii=False), encoding="utf-8")
    line = f"{entry['ts']} | {agent} | {change} | {why} | {nxt}\n"
    with open(p.parent / "MEMORY.md", "a", encoding="utf-8") as f:
        f.write(line)


def status_text():
    mem_lines = []
    if (memory_path().parent / "MEMORY.md").exists():
        mem_lines = (memory_path().parent / "MEMORY.md").read_text(encoding="utf-8").strip().splitlines()
    n_rules = 0
    if rules_path().exists():
        try:
            n_rules = len(json.loads(rules_path().read_text(encoding="utf-8")))
        except Exception:
            pass
    return (
        "🟢 ULTRON online\n"
        f"• memory entries: {max(0, len(mem_lines) - 2)}\n"
        f"• learned rules: {n_rules}\n"
        f"• last: {mem_lines[-1] if mem_lines else '—'}"
    )


HELP = (
    "ULTRON commands\n"
    "/status — system state\n"
    "/rules — list learned rules\n"
    "/remember <text> — add a rule\n"
    "/note <text> — append to memory\n"
    "/help — this"
)


def handle(token, msg):
    text = (msg.get("text") or "").strip()
    cid = msg["chat"]["id"]

    def send(t):
        call(token, "sendMessage", chat_id=cid, text=t)

    if text in ("/start", "/help"):
        send(HELP)
    elif text == "/status":
        send(status_text())
    elif text == "/rules":
        r = []
        if rules_path().exists():
            r = json.loads(rules_path().read_text(encoding="utf-8"))
        send("\n".join(f"{i+1}. {x.get('rule','?')}" for i, x in enumerate(r)) or "no rules yet")
    elif text.startswith("/remember "):
        t = text[len("/remember "):].strip()
        r = json.loads(rules_path().read_text(encoding="utf-8")) if rules_path().exists() else []
        r.append({"id": f"tg-{int(time.time())}", "rule": t, "category": "telegram", "origin": "mo"})
        rules_path().parent.mkdir(parents=True, exist_ok=True)
        rules_path().write_text(json.dumps(r, indent=2, ensure_ascii=False), encoding="utf-8")
        send(f"✅ rule saved: {t}")
    elif text.startswith("/note "):
        t = text[len("/note "):].strip()
        log_memory("telegram", t)
        send("📝 logged to memory")
    else:
        log_memory("telegram", text)
        send("(logged) Use /help")


def main():
    token = load_token()
    print("ULTRON Telegram bridge running. Ctrl+C to stop.")
    log_memory("telegram", "bridge started")
    offset = 0
    while True:
        try:
            res = call(token, "getUpdates", offset=offset, timeout=30)
            for u in res.get("result", []):
                offset = u["update_id"] + 1
                if "message" in u:
                    handle(token, u["message"])
        except KeyboardInterrupt:
            print("stopped")
            break
        except Exception as e:
            print("poll error:", e)
            time.sleep(3)


if __name__ == "__main__":
    main()
