# typescript-workspace-lsp

TypeScript/JavaScript language server for Claude Code. It follows the workspace TypeScript version and provides code intelligence features like go-to-definition, find references, and error checking.

The plugin replaces `typescript-lsp@claude-plugins-official` to support TypeScript 7 projects.

## Supported Extensions

`.ts`, `.tsx`, `.js`, `.jsx`, `.mts`, `.cts`, `.mjs`, `.cjs`

## Installation

Install TypeScript globally via npm:

```bash
npm install -g typescript
```

For TypeScript 6 or earlier, also install the TypeScript language server:

```bash
npm install -g typescript-language-server
```

## Requirements

The plugin starts the server from the nearest `node_modules/typescript`.

| TypeScript              | Server                               |
| ----------------------- | ------------------------------------ |
| 7 or later              | `tsc --lsp --stdio`                  |
| 6 or earlier            | `typescript-language-server --stdio` |
| No project installation | The global `tsc --lsp --stdio`       |

`typescript-lsp@claude-plugins-official` must be disabled when using this plugin, because both register the `typescript` server.

Claude's plugin cannot start in projects using TypeScript 7 because it requires a `tsserver.js` file that is no longer included in the TypeScript package.

## More Information

- [TypeScript on npm](https://www.npmjs.com/package/typescript)
- [typescript-language-server on npm](https://www.npmjs.com/package/typescript-language-server)
- [TypeScript native port on GitHub](https://github.com/microsoft/typescript-go)
