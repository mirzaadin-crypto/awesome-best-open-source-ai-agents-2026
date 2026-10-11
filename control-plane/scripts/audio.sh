#!/usr/bin/env bash
# MO audio: turn any text file into a listenable MP3.  Usage: scripts/audio.sh in.txt out.mp3
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
python3 "$HERE/tts.py" "$1" "$2"
