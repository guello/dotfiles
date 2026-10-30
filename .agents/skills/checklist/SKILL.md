---
name: checklist
description: "Publishes a synced checklist Artifact of manual steps. Use when the user asks for a checklist, to-do page, or tracker of tasks to finish later."
---

# checklist

Publish a checklist page whose checks persist and sync through the artifact database.

The design is fixed in `assets/checklist.html`. You write only the content, and `scripts/render.py` builds the page.

## Write the content

Write `checklist.json` in the session scratchpad or job temp directory, unless the user names a location:

```json
{
  "name": "Rename checklist",
  "title": "Rename `old-name` to `new-name`",
  "subtitle": "Manual steps after the username change. The archived repos are out of scope.",
  "groups": [
    {
      "name": "Accounts",
      "items": [
        { "id": "gh-cli", "title": "Refresh the gh CLI login", "description": "Run `gh auth refresh`." },
        { "id": "chatbot", "title": "Fix the `chatbot` remote", "description": "`origin` points to a repo that does not exist.", "flag": "missing" }
      ]
    }
  ]
}
```

- `name`: 2 to 4 words for the browser tab and the gallery, shorter than `title`.
- `title`: the visible heading. `subtitle`: one sentence of scope, with the exclusions and your assumptions.
- Groups: 2 to 5. Name them by phase (Prepare, Cleanup) when the steps follow a sequence, else by area.
- `id`: a short kebab-case slug that never changes, because the database stores each check by its id.
- `title` of an item: one imperative action, under 10 words.
- `description`: the exact place, command, or value, so the user can copy it from the page. Put commands, paths, and handles in backticks.
- `flag`: one word for a blocker that is outside the list, such as `missing` or `blocked`. An earlier step in the list is not a blocker.
- `title`, `subtitle`, item `title`, and `description` support `` `code` `` and `[text](https://url)`. Everything else is escaped.

## Choose the steps

- Do the steps that your tools can do before you publish, such as edits, searches, and local commands.
- List only the steps that need the user, such as dashboards, logins, and payments.
- Check each value that you put in a description, such as a DNS record or a menu path.
- If you cannot check a value, write "Check the current value" in the item.

## Build and publish

1. Run `python3 <skill-dir>/scripts/render.py <dir>/checklist.json <dir>/checklist.html` with absolute paths. It rejects missing fields and invalid ids.
2. Publish `checklist.html` as the page and `checklist.json` as a second file, so a later update can read the content. Use the icon `checklist`.
3. Declare the `db` capability with default settings. The page stores each check in the `checks` collection.
4. Give the user the link.

Use the artifact tools of the session, and follow their own rules for capabilities and publishing:

| Step            | `Artifact` tool                                       | `claude-artifacts` MCP tools                                   |
| --------------- | ----------------------------------------------------- | -------------------------------------------------------------- |
| Capability docs | Load the `artifact-capabilities` skill                | `describe_capabilities` with `db`                              |
| Publish         | `publish` with `files` and `capabilities: {"db": {}}` | `publish_files`, then `declare_capabilities` with `{"db": {}}` |
| Read the JSON   | `read` with `path: "checklist.json"`                  | `read_file` with `path: "checklist.json"`                      |
| Mark a check    | `ArtifactData` `set`                                  | `db_write` with `op: "set"`                                    |

The template already meets the artifact page contract: theme tokens, dark mode, Google Fonts only, and a 16px gutter.

Keep its design, and change it only when the user asks.

## Update a published checklist

- Read the artifact and its `checklist.json` first.
- Edit the JSON, render it again, and publish both files to the same artifact.
- Keep the id of each existing item, so its check stays. A new id starts unchecked.
- When you finish a step for the user, write the document `checks/<item id>` with `{"done": true, "updatedAt": "<ISO time>"}`.
- A check needs no new publish: the page shows the change live.

## Without artifact tools

When the session has no artifact tools, render the page and give the user its path. Open it with `open` only when the user asks.

The checks then save in that browser only, and the page shows "this browser only".
