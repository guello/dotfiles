# Commit handoff format

The commit safety and proposal format routed from `../AGENTS.md`. Read this file completely before a commit-worthy handoff or an authorized commit.

## Commit safety

- Commits are signed via Git's `ssh-keygen` signer; never disable signing or pass `--no-gpg-sign`.
- Follow the repository's commit convention; never add a session link or a `Claude-Session:` trailer to a commit or pull request.
- In the `$HOME` repository, use the commit types and scopes in `../rules/dotfiles.md`.

## Proposal format

Choose between a fold into an existing commit, a new commit, and a split per the "Commit decision" section of `verification.md`. Prefer the fold.

Render the block itself, never a description of it, even when the prompt asks what you would do.

Render this block with the structure unchanged. Fill the change list from the actual diff, one entry per change in the shape shown.

Adapt only the proposal part, using the repository's commit convention and inferring the type and optional scope from the changes:

````markdown
### Changes

- [file:line](path/to/file:line) - describes the resulting behavior.

I suggest creating a new commit:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

Want me to run it?
````

Write the message per the "Message format" section.

For an amend or squash, keep the change list and adapt only the proposal lines.

Name the target's short hash and subject, include the resulting message only when it changes, and end with the matching question.

For a split, keep one `### Changes` block divided by a `####` subheader per commit, each with a short imperative title and its own change list.

Close a split with one question covering every commit.

When the changes span repositories, the subheaders name the repositories, and a repository with several commits nests its commit subheaders one level down.

## Message format

### Header

- Choose the type from the effect on users. Use `feat` and `fix` only for changes that users can see, and `build`, `ci`, `test`, or `chore` for other changes.
- A fix to a change that is not released yet is not a `fix`. Fold it into that change per the "Commit decision" section of `verification.md`.
- Use a scope only when one noun names the affected area, such as a package or module. Never invent a scope or use a file path as a scope.
- Keep the exact case of identifiers. Do not repeat the type as the verb: `fix(parser): handle empty input`, not `fix(parser): fix empty input`.
- Omit every unneeded article: `docs: restructure agent docs`, not `docs: restructure the agent docs`.
- Name the effect for a changelog reader, not the implementation steps.
- Keep the header at 72 characters or fewer. Never write a `(#123)` suffix, because GitHub adds the PR number at squash merge.
- For a revert, write `revert: <reverted header>` and start the body with `This reverts commit <sha>.` and the reason.

### Body

- Include a body only when the header cannot explain the full intent.
- Write prose for a future reader of `git log`. State the problem or the reason first, then how the behavior changes.
- Do not restate the header, describe the diff, or list the edited files.
- Do not refer to the session, the request, or the author: no "as requested", "this commit", or "this PR".
- Do not use Markdown headings, tables, checkboxes, or bold text.
- Use bullets only for independent changes that one reason cannot join: hyphen, lower-case imperative fragment, no terminal period.
- Many bullets show mixed concerns, so examine a split.
- Write the whole message unwrapped. Hard-wrap only when the repository declares a convention or sets commitlint's `body-max-line-length`.

### Footers

- For a breaking change, add `!` to the header and a `BREAKING CHANGE:` footer that tells users how to migrate.
- Give each issue its own footer: `Fixes #12` for a bug, `Closes #12` for other resolved work, `Refs #12` for an issue that stays open.
- Never invent an issue number.
