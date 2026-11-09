# Session references

How to resolve a past Claude Code or Pi session that is named by its slug, such as `fix-login-bug-2`.

- Read the rows with that exact title in `~/.local/state/autoname-session/index.tsv`, with the columns `title`, `session`, `harness`, `date`, and `transcript`.
- Some older slugs belong to more than one session. List them with their dates, and ask which one.
- Search the transcript of the row for the part you need. Never read a full transcript.
- When the transcript file is missing, the session was deleted: report its title and date.
- Sessions with a free-form title have no row. Search the transcripts for `"customTitle":"<title>"` (Claude Code) or `"name":"<title>"` (pi).
- Codex sessions have no row. Find the `thread_name` in `~/.codex/session_index.jsonl` and get the `id` of the last row matching the given name, then the transcript with that `id` in `~/.codex/sessions`.
