#!/usr/bin/env python3
"""MO audio briefing generator.

No ffmpeg / no pip. Uses the public Google Translate TTS endpoint
(works through this sandbox's egress proxy) and concatenates chunks
into a single playable MP3.
"""
import sys, time, urllib.parse, urllib.request

UA = "Mozilla/5.0 (X11; Linux x86_64)"
ENDPOINT = "https://translate.google.com/translate_tts"
MAX = 190  # chars per request


def chunk(text):
    """Split into <=MAX char pieces on sentence/word boundaries."""
    text = " ".join(text.split())
    out, cur = [], ""
    for token in text.replace(" — ", ". ").split(" "):
        if len(cur) + len(token) + 1 <= MAX:
            cur = (cur + " " + token).strip()
        else:
            if cur:
                out.append(cur)
            cur = token
    if cur:
        out.append(cur)
    return out


def say(piece, lang="en", speed=1):
    params = urllib.parse.urlencode(
        {"ie": "UTF-8", "tl": lang, "client": "tw-ob",
         "ttsspeed": speed, "q": piece}
    )
    req = urllib.request.Request(ENDPOINT + "?" + params, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()


def main():
    src, dst = sys.argv[1], sys.argv[2]
    text = open(src, encoding="utf-8").read()
    pieces = chunk(text)
    audio = bytearray()
    for i, p in enumerate(pieces, 1):
        for attempt in range(4):
            try:
                audio += say(p)
                break
            except Exception as e:  # noqa
                print(f"  retry {attempt+1} chunk {i}: {e}", file=sys.stderr)
                time.sleep(1.5)
        else:
            print(f"  FAILED chunk {i}", file=sys.stderr)
        time.sleep(0.25)
    open(dst, "wb").write(bytes(audio))
    print(f"wrote {dst}: {len(pieces)} chunks, {len(audio)} bytes")


if __name__ == "__main__":
    main()
