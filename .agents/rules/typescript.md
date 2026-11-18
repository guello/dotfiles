# TypeScript

Language-level rules for all TypeScript files.

Follow the repository's existing configuration where it defines a rule. Apply the rules below where that configuration is silent.

## Idioms

- Return early with guard clauses; never `else` or `else if` after a `return`.
- Use `interface` over `type` for object shapes.
- Use `for...of` for iteration, `map` for transformation, and `reduce` for accumulation; never `.forEach`.
- Use kebab-case filenames unless the framework requires another name.
- Omit redundant type annotations; add them when inference does not express the intended type or contract.

## Functions

- At module scope, define named functions with `function` declarations, React components included.
- Inside a function body, define helpers and handlers as `const` arrows.
- Write a default export as `export default function`, never as an arrow, and name it when it is a React component.
- Keep an arrow for a function typed by its variable: `const onSave: Handler = () => {}`.

## Imports

- Use configured path aliases for imports across modules.
- Use relative imports within a module or when no suitable alias exists.
- When every imported name is a type, use `import type { Foo }`.
- Mark a type inline only in an import that also brings values: `import { type Foo, bar }`.
- Use ESM unless an existing runtime or `.cts` target requires CommonJS.

## Safety

- End a `switch` over a closed union with a `never` check in `default`, so adding a member fails to compile.
- For a lookup table that must cover every union member, use `satisfies Record<Union, T>`.
- Write `catch (error)` without a type: under `strict` it is already `unknown`, so narrow it before use.
- Never use `catch (e: any)` or an empty catch block.
- Throw `Error` instances, not strings or other values.
- Use `async`/`await` only; no `.then()` chains.
- Use `??` when only `null` and `undefined` should trigger a fallback.

## Framework docs first

- Before using a framework or library API, check documentation for the installed version.
- Prefer bundled docs when present (`node_modules/<pkg>/dist/docs/`), else the `context7` MCP.
- When a docs finding drives a non-obvious choice, state the version you targeted.
