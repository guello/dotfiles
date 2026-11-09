@~/.agents/AGENTS.md

# Claude Code

Claude-only additions to the shared instructions.

## Delegation

- Workflow and orchestration stages never run Fable-class models, even with approval. When a Fable-class review is necessary, run it after the workflow as a standalone subagent.
- Ask the user before you start a standalone Fable-class subagent. A fork inherits the context and cannot change its model, so this rule does not apply there.

## Artifacts

- Before you create an artifact, list your artifacts to find one about the same or a related topic.
- If a related artifact exists, add your work to it on a new page. Do not change other pages.
- Create a new artifact only when no related artifact exists.
