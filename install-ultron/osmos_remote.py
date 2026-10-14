#!/usr/bin/env python3
"""OSmOS Remote - Telegram control + permission approvals for agents.

Runs on YOUR PC. Lets you approve agent actions from your phone.
Token:  <AGENT>_TELEGRAM_TOKEN   (e.g. VISKO_TELEGRAM_TOKEN)
Owner:  first chat to message the bot becomes the owner (stored in allow.json)

Commands: /help /status /run <cmd> /approve <id> /deny <id> /pending
          /mem search <q>  /mem add <text>  /note <text>  /keepalive on|off
"""
import argparse
import json
import os
import subprocess
import sys
import time
import uuid
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

API = "https://api.telegram.org/bot{token}/{method}"
DANGER = ("rm -rf", "format", "del /f", "rmdir /s", "shutdown", "diskpart", "reg delete")


def base_dir() -> Path:
    b = Path(os.getenv("LOCALAPPDATA", str(Path.home()))) / "OSmOS"
    b.mkdir(parents=True, exist_ok=True)
    return b


def allow_file() -> Path:
    return base_dir() / "telegram_allow.json"


def load_token(agent: str) -> str:
    t = os.getenv(agent.upper() + "_TELEGRAM_TOKEN", "").strip()
    if t:
        return t
    c = base_dir() / "config" / ("telegram_" + agent.lower() + ".json")
    if c.exists():
        return json.loads(c.read_text(encoding="utf-8")).get("token", "").strip()
    raise SystemExit("No token for " + agent)


def owners() -> list:
    f = allow_file()
    return json.loads(f.read_text(encoding="utf-8")) if f.exists() else []


def add_owner(cid):
    o = owners()
    if cid not in o:
        o.append(cid)
        allow_file().write_text(json.dumps(o, indent=2), encoding="utf-8")
        return True
    return False


def call(token, method, **params):
    url = API.format(token=token, method=method)
    req = urllib.request.Request(url, data=urllib.parse.urlencode(params).encode())
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


def mem(*args):
    p = Path(__file__).with_name("mem.py")
    if not p.exists():
        return "mem.py not found next to me"
    try:
        return subprocess.run([sys.executable, str(p), *args], capture_output=True, text=True, timeout=30).stdout or "ok"
    except Exception as e:
        return "mem error: " + str(e)

def pending_file() -> Path:
    return base_dir() / "pending.json"


def load_pending():
    f = pending_file()
    return json.loads(f.read_text(encoding="utf-8")) if f.exists() else {}


def save_pending(p):
    pending_file().write_text(json.dumps(p, indent=2), encoding="utf-8")


def new_request(cmd, chat):
    p = load_pending()
    pid = uuid.uuid4().hex[:6]
    p[pid] = {"cmd": cmd, "chat": chat, "ts": datetime.now(timezone.utc).isoformat(timespec="seconds")}
    save_pending(p)
    return pid


def run_cmd(cmd, timeout=120):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        out = (r.stdout or "") + (r.stderr or "")
        return "exit " + str(r.returncode) + "\n" + out.strip()[-3000:]
    except subprocess.TimeoutExpired:
        return "timed out after " + str(timeout) + "s"
    except Exception as e:
        return "error: " + str(e)

HELP = ("OSmOS Remote\n"
        "/status - system + agents\n"
        "/run <cmd> - request to run a command\n"
        "/approve <id> - approve + run\n"
        "/deny <id> - cancel\n"
        "/pending - list requests\n"
        "/mem search <q> | /mem add <text>\n"
        "/note <text> - append memory\n"
        "/keepalive - heartbeat")


def handle(token, agent, msg, state):
    text = (msg.get("text") or "").strip()
    cid = msg["chat"]["id"]

    def send(t):
        try:
            call(token, "sendMessage", chat_id=cid, text=t[:4000])
        except Exception as e:
            print("send error:", e)

    if add_owner(cid):
        send("Owner registered: " + str(cid) + "\n" + HELP)
        return
    if cid not in owners():
        send("unauthorized")
        return

    if text in ("/start", "/help"):
        send(HELP)
    elif text == "/status":
        send("agent: " + agent + "\nonline: yes\npending: " + str(len(load_pending())) + "\n" + mem("stats"))
    elif text.startswith("/run "):
        cmd = text[5:].strip()
        pid = new_request(cmd, cid)
        warn = " [DANGEROUS]" if any(d in cmd.lower() for d in DANGER) else ""
        send("PERMISSION REQUEST [" + pid + "]" + warn + "\n> " + cmd + "\n\nreply: /approve " + pid + "  or  /deny " + pid)
    elif text.startswith("/approve "):
        pid = text.split()[1]
        p = load_pending()
        if pid not in p:
            send("unknown id")
            return
        cmd = p.pop(pid)["cmd"]
        save_pending(p)
        send("running [" + pid + "]...")
        send(run_cmd(cmd))
        mem("add", "ran via telegram: " + cmd, "--agent", agent, "--tags", "remote")
    elif text.startswith("/deny "):
        pid = text.split()[1]
        p = load_pending()
        if pid in p:
            p.pop(pid); save_pending(p); send("denied " + pid)
        else:
            send("unknown id")
    elif text == "/pending":
        p = load_pending()
        send("none" if not p else "\n".join(k + ": " + v["cmd"] for k, v in p.items()))
    elif text.startswith("/mem search "):
        send(mem("search", text[len("/mem search "):]))
    elif text.startswith("/mem add "):
        send(mem("add", text[len("/mem add "):], "--agent", agent))
    elif text.startswith("/note "):
        send(mem("add", text[6:], "--agent", agent, "--tags", "telegram"))
    elif text == "/keepalive":
        state["keepalive"] = not state["keepalive"]
        send("keepalive " + ("on" if state["keepalive"] else "off"))
    else:
        mem("add", text, "--agent", agent, "--tags", "telegram")
        send("(logged) /help")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--agent", default=os.getenv("AGENT_NAME", "VISKO"))
    args = ap.parse_args()
    agent = args.agent.upper()
    token = load_token(agent)
    state = {"keepalive": True, "last": 0}
    print(agent + " remote running. Ctrl+C to stop.")
    mem("add", "remote bridge started", "--agent", agent, "--tags", "remote")
    offset = 0
    while True:
        try:
            for u in call(token, "getUpdates", offset=offset, timeout=30).get("result", []):
                offset = u["update_id"] + 1
                if "message" in u:
                    handle(token, agent, u["message"], state)
            if state["keepalive"] and time.time() - state["last"] > 1800:
                for cid in owners():
                    try:
                        call(token, "sendMessage", chat_id=cid, text=agent + " alive " + datetime.now().strftime("%H:%M") + " | pending " + str(len(load_pending())))
                    except Exception:
                        pass
                state["last"] = time.time()
        except KeyboardInterrupt:
            print("stopped"); break
        except Exception as e:
            print("poll error:", e); time.sleep(3)


if __name__ == "__main__":
    main()
