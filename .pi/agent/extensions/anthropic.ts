import { type Api, type Model, getSupportedThinkingLevels } from '@earendil-works/pi-ai'
import { anthropicProvider } from '@earendil-works/pi-ai/providers/anthropic'
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent'

export default function (pi: ExtensionAPI) {
  const unrouted = (): never => {
    throw new Error('Anthropic is a Claude Bridge alias; select a routed Claude model.')
  }

  pi.registerProvider({
    id: 'anthropic',
    name: 'Anthropic',
    auth: {
      apiKey: {
        name: 'Claude Code subscription via Claude Bridge',
        resolve: () => Promise.resolve({ auth: {}, source: 'claude-bridge alias' }),
      },
    },
    getModels: () => [],
    stream: unrouted,
    streamSimple: unrouted,
  })

  const registered = new Set<string>()
  const registerAliases = (models: readonly Model<Api>[], withLimits: boolean) => {
    for (const model of models) {
      if (/-20\d{6}$/.test(model.id)) continue
      registered.add(model.id)
      pi.registerVirtualModel({
        provider: 'anthropic',
        id: model.id,
        name: model.name,
        input: model.input,
        thinkingLevels: getSupportedThinkingLevels(model),
        ...(withLimits ? { contextWindow: model.contextWindow, maxTokens: model.maxTokens } : {}),
        route: (request, ctx) => {
          const target = ctx.modelRegistry.find('claude-bridge', model.id)
          if (!target) {
            throw new Error(
              `Claude Bridge model ${model.id} is unavailable; no direct API fallback.`
            )
          }
          return { model: target, thinkingLevel: request.thinkingLevel }
        },
      })
    }
  }

  registerAliases(anthropicProvider().getModels(), false)
  pi.on('session_start', (_event, ctx) => {
    const models = ctx.modelRegistry.getAll().filter(model => model.provider === 'claude-bridge')
    const available = new Set(models.map(model => model.id))
    for (const id of registered) {
      if (available.has(id)) continue
      pi.unregisterVirtualModel('anthropic', id)
      registered.delete(id)
    }
    registerAliases(models, true)
  })
}
