#!/usr/bin/env python3
"""Pre-renders JuicyCloud's built-in lines with ElevenLabs into voice/clips/.

Both apps play a clip when one matches the bubble text exactly, and fall back to the
system voice for anything else (custom lines, lines with numbers in them).

  python3 voice/generate.py            generate missing or out-of-date clips
  python3 voice/generate.py --list     show every line and what it will cost
  python3 voice/generate.py --check    exit 1 if any clip is missing or stale (no API calls)
  python3 voice/generate.py --only "POA&M"   re-render lines containing some text
  python3 voice/generate.py --force    re-render everything

Voice, model, and pronunciations live in voice/config.json. The API key is read from the
macOS Keychain (service "elevenlabs-api-key") and never written anywhere:

  security add-generic-password -a "$USER" -s elevenlabs-api-key -w
"""
import argparse
import hashlib
import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VOICE = ROOT / "voice"
CLIPS = VOICE / "clips"
MANIFEST = CLIPS / "manifest.json"
API = "https://api.elevenlabs.io/v1"

LITERAL = r'"((?:[^"\\\n]|\\.)*)"'


def unescape(raw):
    return raw.replace('\\"', '"').replace("\\\\", "\\")


def block(src, start, end):
    i = src.index(start)
    return src[i:src.index(end, i)]


def literals(text, skip_keys=False):
    out = []
    for m in re.finditer(LITERAL, text):
        raw = m.group(1)
        if "\\(" in raw:                       # interpolated: can't be pre-rendered
            continue
        if skip_keys and re.match(r"\s*:", text[m.end():]):   # dictionary key (bundle ID)
            continue
        out.append(unescape(raw))
    return out


def built_in_lines():
    """Every fixed string either app can speak, in source order."""
    mac = (ROOT / "mac/main.swift").read_text()
    ios_lines = (ROOT / "ios/Shared/Lines.swift").read_text()
    ios_app = "".join(p.read_text() for p in sorted((ROOT / "ios/App").glob("*.swift")))

    mac_lines = literals(block(mac, "let defaultLines", "\n]"))
    ios_all = literals(block(ios_lines, "static let all", "\n    ]"))
    if mac_lines != ios_all:
        print("Warning: defaultLines in mac/main.swift and Lines.all in ios/Shared/Lines.swift differ.")

    found = []
    found += [unescape(m) for m in re.findall(r'let greeting = ' + LITERAL, mac)]
    found += mac_lines
    found += literals(block(mac, "let appLines", "\n]"), skip_keys=True)
    found += [unescape(m) for m in re.findall(r'\bsay\(' + LITERAL, mac) if "\\(" not in m]
    found += [unescape(m) for m in re.findall(r'static let greeting = ' + LITERAL, ios_lines)]
    found += ios_all
    found += [unescape(m) for m in re.findall(r'speak\((?:spokenText\()?' + LITERAL, ios_app)]
    return list(dict.fromkeys(found))


def key(text):
    """Must match Clips.key(_:) in mac/main.swift and ios/App/Speaker.swift."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def spoken(text, cfg):
    """What ElevenLabs is asked to say for a bubble line."""
    s = text.replace('"', "")
    for word, sound in cfg["pronunciations"]:
        s = s.replace(word, sound)
    return s


def api_key():
    r = subprocess.run(["security", "find-generic-password", "-s", "elevenlabs-api-key", "-w"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit('No ElevenLabs key in the Keychain. Add one with:\n'
                 '  security add-generic-password -a "$USER" -s elevenlabs-api-key -w')
    return r.stdout.strip()


def request(path, key, body=None):
    req = urllib.request.Request(API + path, data=json.dumps(body).encode() if body else None,
                                 headers={"xi-api-key": key, "Content-Type": "application/json"})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503) and attempt < 4:
                time.sleep(2 ** attempt * 2)
                continue
            sys.exit(f"ElevenLabs error {e.code} on {path}: {e.read()[:300].decode(errors='replace')}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--only", metavar="TEXT")
    ap.add_argument("--yes", action="store_true", help="skip the cost confirmation")
    args = ap.parse_args()

    cfg = json.loads((VOICE / "config.json").read_text())
    lines = built_in_lines()
    manifest = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {"clips": {}}
    same_voice = (manifest.get("voice_id"), manifest.get("model_id")) == (cfg["voice_id"], cfg["model_id"])

    def stale(t):
        entry = manifest["clips"].get(key(t))
        return (args.force or not same_voice or entry is None or entry.get("spoken") != spoken(t, cfg)
                or not (CLIPS / f"{key(t)}.mp3").exists())

    todo = [t for t in lines if stale(t) and (args.only is None or args.only in t)]

    if args.list:
        for t in lines:
            print(f"{'*' if t in todo else ' '} {key(t)}  {spoken(t, cfg)}")
        print(f"\n{len(lines)} lines, {sum(len(spoken(t, cfg)) for t in lines)} characters in all; "
              f"{len(todo)} to render ({sum(len(spoken(t, cfg)) for t in todo)} characters). * = to render")
        return
    if args.check:
        if todo:
            print(f"{len(todo)} of {len(lines)} voice clips are missing or out of date. "
                  "Run: python3 voice/generate.py")
            sys.exit(1)
        print(f"All {len(lines)} voice clips are up to date ({cfg['voice_name']}).")
        return

    key_ = api_key()
    cost = sum(len(spoken(t, cfg)) for t in todo)
    if todo:
        sub = json.loads(request("/user/subscription", key_))
        left = sub["character_limit"] - sub["character_count"]
        print(f"Rendering {len(todo)} lines with {cfg['voice_name']} ({cfg['model_id']}): "
              f"about {cost} characters; {left} left this month.")
        if cost > left:
            sys.exit("Not enough characters left this month.")
        if not args.yes and input("Continue? [y/N] ").strip().lower() != "y":
            sys.exit("Cancelled.")

    CLIPS.mkdir(parents=True, exist_ok=True)
    if not same_voice:
        manifest = {"clips": {}}
    for i, t in enumerate(todo, 1):
        audio = request(f"/text-to-speech/{cfg['voice_id']}?output_format={cfg['output_format']}", key_, {
            "text": spoken(t, cfg),
            "model_id": cfg["model_id"],
            "voice_settings": cfg["voice_settings"],
        })
        (CLIPS / f"{key(t)}.mp3").write_bytes(audio)
        manifest["clips"][key(t)] = {"text": t, "spoken": spoken(t, cfg)}
        print(f"[{i}/{len(todo)}] {t[:70]}")

    # Drop clips for lines that no longer exist.
    keep = {key(t) for t in lines}
    for k in [k for k in manifest["clips"] if k not in keep]:
        del manifest["clips"][k]
    for f in CLIPS.glob("*.mp3"):
        if f.stem not in keep:
            f.unlink()

    manifest.update(voice_name=cfg["voice_name"], voice_id=cfg["voice_id"], model_id=cfg["model_id"])
    MANIFEST.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    print(f"Done. {len(keep)} clips in voice/clips.")


if __name__ == "__main__":
    main()
