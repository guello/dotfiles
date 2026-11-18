# Claude Code Web

Claude Code mod that opens the current session on [claude.ai](https://claude.ai/code/<session>), also while running.

## Usage

- `/web`: opens `https://claude.ai/code/<session>` in the default browser.

The command runs while Claude works and adds nothing to the transcript or context of Claude.

The mod reads the bridge session id from the registry in `~/.claude/sessions` (or `$CLAUDE_CONFIG_DIR/sessions`).

## Limitations

- The session must have Remote Control on. Without it, the session has no claude.ai URL and a toast suggests running `/remote-control` first.
- The URL opens on the machine that runs the session, also run from a remote client.
