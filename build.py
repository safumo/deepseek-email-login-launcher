#!/usr/bin/env python3
"""Bake launcher.applescript into site/index.html.

Replaces:
  {{APPLESCRIPT_URL}}    -> applescript://com.apple.ScriptEditor2?action=new&script=<urlencoded>
  {{APPLESCRIPT_SOURCE}} -> the raw AppleScript source (HTML-escaped)
Output goes to dist/index.html.
"""
from html import escape
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).parent
script = (ROOT / "launcher.applescript").read_text(encoding="utf-8")
template = (ROOT / "site" / "index.html").read_text(encoding="utf-8")

url = "applescript://com.apple.ScriptEditor2?action=new&script=" + quote(script)
out = template.replace("{{APPLESCRIPT_URL}}", url).replace(
    "{{APPLESCRIPT_SOURCE}}", escape(script)
)

if "{{APPLESCRIPT" in out:
    raise SystemExit("build failed: unsubstituted placeholder remains")

dist = ROOT / "dist"
dist.mkdir(exist_ok=True)
(dist / "index.html").write_text(out, encoding="utf-8")
print(f"built dist/index.html ({len(out)} bytes, applescript URL {len(url)} chars)")
