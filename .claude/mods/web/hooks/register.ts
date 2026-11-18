import type { EngineInterface, Register } from 'claude-code'

const COMMAND = 'web'
const BASE_URL = 'https://claude.ai/code/'
const SAFE_ID = /^[A-Za-z0-9_-]+$/
const OPEN_TIMEOUT_MS = 10_000

async function sessionsDir($: EngineInterface) {
  const configDir = await $.env.get('CLAUDE_CONFIG_DIR')
  if (configDir) return configDir + '/sessions'
  return (await $.env.get('HOME')) + '/.claude/sessions'
}

async function bridgeSessionId($: EngineInterface) {
  const sessionId = await $.session.id()
  const dir = await sessionsDir($)
  const entries = await $.fs.list(dir).catch(() => [])
  for (const entry of entries) {
    if (entry.kind !== 'file' || !entry.name.endsWith('.json')) continue
    try {
      const record: { sessionId?: string; bridgeSessionId?: string | null } = JSON.parse(
        await $.fs.read(dir + '/' + entry.name)
      )
      if (record.sessionId === sessionId && record.bridgeSessionId) return record.bridgeSessionId
    } catch {}
  }
  return null
}

async function openUrl($: EngineInterface, url: string) {
  for (const argv of [
    ['open', url],
    ['xdg-open', url],
  ]) {
    try {
      const result = await $.process.run(argv, { timeoutMs: OPEN_TIMEOUT_MS })
      if (result.exitCode === 0) return true
    } catch {}
  }
  return false
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    try {
      await $.command.register({
        name: COMMAND,
        description: 'Open this session on claude.ai',
        immediate: true,
      })
    } catch (error) {
      $.ui.log('could not register /' + COMMAND + ': ' + String(error), { to: 'debug' })
    }
    return next(e)
  })

  on('command.run', { command: COMMAND }, async $ => {
    const id = (await bridgeSessionId($))?.replace(/^cse_/, 'session_')
    if (!id || !SAFE_ID.test(id)) {
      $.ui.toast('Remote Control is off. Enable it with /remote-control and try again.')
      return {}
    }
    const url = BASE_URL + id
    $.ui.toast((await openUrl($, url)) ? 'Opened ' + url : 'Could not open ' + url)
    return {}
  })
}
