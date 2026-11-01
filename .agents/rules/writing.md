---
description: "Use when producing text that people read: docs, READMEs, rules, specs, commit messages, PR, issue, and release text, review comments, essays, marketing or UI copy, emails. Enforces Simplified Technical English for technical text and the humanizer skill for other prose."
applyTo: "**/*.markdown,**/*.md,**/*.mdc,**/*.mdx,**/*.rst,**/*.txt,**/README*,**/docs/**"
paths:
  - "**/*.markdown"
  - "**/*.md"
  - "**/*.mdc"
  - "**/*.mdx"
  - "**/*.rst"
  - "**/*.txt"
  - "**/README*"
  - "**/docs/**"
---

# Writing and prose

Applies to text that people read in files, chat, commits, PRs, issues, releases, reviews, and UI copy.

## Scope

- Write technical text in ASD-STE100 Simplified Technical English (STE): docs, READMEs, rules, specs, plans, commit messages, PR, issue, and release text, review comments, and chat answers.
- STE does not apply to code, identifiers, quotations, UI copy, marketing, announcements, essays, or personal writing.
- The mechanics section applies to all committed text. The dash ban has no exception.

## STE

The `simplified-technical-english` skill holds the full rules, the approved word list, and examples. Load it for long text and for vocabulary checks.

- Use approved words with their approved meaning and part of speech. Technical names and technical verbs keep their exact form.
- Use one word for one meaning. Do not use phrasal verbs. Keep noun clusters at 3 words or fewer.
- Use the simple present, simple past, or future tense. Use the active voice, and the imperative for instructions.
- Use only `can`, `must`, and `will` as helping verbs. Do not use `-ing` forms, except approved words and technical names.
- Keep procedural sentences at 20 words or fewer and descriptive sentences at 25 or fewer. Keep paragraphs at 6 sentences or fewer.
- Write one instruction in each sentence. Keep the articles, except in commit messages and PR titles. Do not write contractions or semicolons.
- Use a vertical list for steps or complex text, with a colon at the end of the lead line.
- A Conventional Commits header keeps its `type(scope):` format. STE applies to its description and to the body.
- In commit messages and PR titles, omit every article that the meaning does not need: `build: set up pnpm workspace`, not `build: set up the pnpm workspace`. This overrides the STE article rule.
- Never claim that a word is approved without a check against the word list.

## Enforcement

- `guard-committed-writing.sh` blocks net-new semicolons, contractions, and sentences over 25 words in committed markdown and text files, and in commit and GitHub text.
- The hook returns the other checker findings as advice. Fix each finding, or keep the word when it is a technical name.

## Mechanics

- Never write an em or en dash into any committed file, these rule and config docs included. Live chat output is the only exception.
- Replace a dash with a period, comma, colon, hyphen, parentheses, or a rewrite.
- Never hard-wrap committed markdown. Write each paragraph and list item as one physical line.
- Follow a project wrap convention only where one exists. Code and its comments keep the wrap style of the language.
- Use sentence-case headings, straight quotes, no decorative emoji, and no mechanical boldface or inline-header bullet lists.
- Before you return file content, scan it for em and en dashes. A hit means that the work is not done.

## Prose outside STE

- For marketing, announcements, essays, and personal writing longer than a few sentences, run the `humanizer` skill: draft, audit, then final.
- For shorter prose of that type, cut AI tells inline: promotional inflation, filler, signposts, and collaborative artifacts such as "I hope this helps".
- UI copy follows `design.md`: plain verbs, sentence case, and the product voice.
- Add opinion or voice only to essays and personal writing.
- Edit for clusters of tells, not isolated ones. Read the humanizer "What NOT to flag" section before you cut legitimate prose.
- The humanizer voice guidance never overrides the mechanics above.
- To audit the human docs of a repository, run `/sync-docs`.
