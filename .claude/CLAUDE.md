@~/.agents/AGENTS.md

# Claude Code

Claude-only additions to the shared instructions.

## Delegation

- Workflow and orchestration stages never run Fable-class models, even with approval. A warranted Fable-class review runs afterwards as a standalone subagent.
- Ask before you start a standalone Fable-class subagent. Forks that inherit context cannot change model, so they are exempt.
