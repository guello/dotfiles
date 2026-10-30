#!/usr/bin/env python3
"""Render a checklist JSON file into the checklist Artifact page.

Usage: render.py <checklist.json> <out.html>

The JSON holds name (the 2 to 4 word page title), title, optional subtitle, optional key (the localStorage key,
default derived from name), and groups. Each group has a name and items. Each item has a stable id
([a-z0-9-]+), a title, an optional description, and an optional flag such as "blocked". In every text field,
`code` becomes inline code and [text](https://url) becomes a link. All other text is HTML-escaped.
"""

import html
import json
import re
import sys
from pathlib import Path

TEMPLATE = Path(__file__).resolve().parent.parent / "assets" / "checklist.html"
ID = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
INLINE = re.compile(r"`([^`]+)`|\[([^\]]+)\]\((https?://[^)\s]+)\)")


def text(value):
    return html.escape(value, quote=False)


def inline(value):
    out, last = [], 0
    for m in INLINE.finditer(value):
        out.append(text(value[last : m.start()]))
        if m.group(1) is not None:
            out.append(f"<code>{text(m.group(1))}</code>")
        else:
            out.append(f'<a href="{html.escape(m.group(3))}" target="_blank" rel="noopener">{text(m.group(2))}</a>')
        last = m.end()
    out.append(text(value[last:]))
    return "".join(out)


def fail(message):
    sys.exit(f"render.py: {message}")


def render_item(item, seen):
    item_id = item.get("id", "")
    if not ID.fullmatch(item_id):
        fail(f"invalid item id: {item_id!r}")
    if item_id in seen:
        fail(f"duplicate item id: {item_id}")
    seen.add(item_id)
    if not item.get("title"):
        fail(f"missing title: {item_id}")
    flag = f' <span class="flag">{text(item["flag"])}</span>' if item.get("flag") else ""
    desc = f'<div class="d">{inline(item["description"])}</div>' if item.get("description") else ""
    box = f"c-{item_id}"
    return (
        f'      <li data-id="{item_id}"><div class="row"><input type="checkbox" id="{box}"><div>'
        f'<label class="t" for="{box}">{inline(item["title"])}{flag}</label>{desc}</div></div></li>'
    )


def render_group(group, seen):
    if not group.get("name") or not group.get("items"):
        fail("each group needs a name and at least one item")
    rows = "\n".join(render_item(item, seen) for item in group["items"])
    return (
        "  <section data-group>\n"
        f'    <h2>{text(group["name"])} <span class="count"></span></h2>\n'
        f"    <ul>\n{rows}\n    </ul>\n"
        "  </section>"
    )


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.split("\n\n")[1])
    try:
        data = json.loads(Path(sys.argv[1]).read_text())
    except (OSError, json.JSONDecodeError) as e:
        fail(f"cannot read {sys.argv[1]}: {e}")
    for field in ("name", "title", "groups"):
        if not data.get(field):
            fail(f"missing field: {field}")
    seen = set()
    groups = "\n\n".join(render_group(group, seen) for group in data["groups"])
    key = data.get("key") or re.sub(r"[^a-z0-9]+", "-", data["name"].lower()).strip("-")
    subtitle = f'<p class="sub">{inline(data["subtitle"])}</p>' if data.get("subtitle") else ""
    page = TEMPLATE.read_text()
    for token, value in (
        ("{{name}}", text(data["name"])),
        ("{{title}}", inline(data["title"])),
        ("{{subtitle}}", subtitle),
        ("{{groups}}", groups),
        ("{{key}}", json.dumps(key + "-checks").replace("<", "\\u003c")),
    ):
        page = page.replace(token, value)
    Path(sys.argv[2]).write_text(page)
    print(f"{sys.argv[2]}: {len(seen)} items in {len(data['groups'])} groups")


if __name__ == "__main__":
    main()
