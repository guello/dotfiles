import scopes from './scopes.json' with { type: 'json' }

interface Commit {
  type: string | null
  scope: string | null
}

type Plugin = (commit: Commit) => [boolean, string]

const scopePerType: Plugin = ({ scope, type }) => {
  const allowed: string[] = scopes[type as keyof typeof scopes] ?? []
  const valid = scope?.split(/[/\\,]/).every(name => allowed.includes(name)) ?? true
  if (allowed.length === 0) return [valid, `type ${type} takes no scope`]
  return [valid, `scope for type ${type} must be one of [${allowed.join(', ')}]`]
}

export default {
  rules: {
    'scope-per-type': [2, 'always'],
    'type-enum': [2, 'always', Object.keys(scopes)],
  },
  plugins: [
    {
      rules: { 'scope-per-type': scopePerType },
    },
  ],
}
