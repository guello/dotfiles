import { homedir } from 'node:os'
import { join } from 'node:path'
import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent'
import { spawn } from 'node:child_process'

const KEBAB_CASE = /^[a-z0-9]+(-[a-z0-9]+)*$/

function runHook(hook: string, input: string, cwd: string, signal: AbortSignal) {
  return new Promise<string>((resolve, reject) => {
    if (signal.aborted) {
      resolve('')
      return
    }
    const child = spawn('sh', [hook, '--pi'], {
      cwd,
      detached: true,
      stdio: ['pipe', 'pipe', 'ignore'],
    })
    let output = ''
    let stopped = false
    let forceKill: ReturnType<typeof setTimeout> | undefined
    const kill = (kind: NodeJS.Signals) => {
      if (!child.pid) return
      try {
        process.kill(-child.pid, kind)
      } catch (error) {
        if (!(error instanceof Error && 'code' in error && error.code === 'ESRCH')) reject(error)
      }
    }
    const stop = () => {
      if (stopped) return
      stopped = true
      kill('SIGTERM')
      forceKill = setTimeout(() => kill('SIGKILL'), 1000)
      forceKill.unref()
    }
    const timeout = setTimeout(stop, 20_000)
    signal.addEventListener('abort', stop, { once: true })
    child.stdout.setEncoding('utf8')
    child.stdout.on('data', (data: string) => {
      output += data
      if (output.length > 4096) stop()
    })
    child.stdin.on('error', () => stop())
    child.on('error', reject)
    child.on('close', code => {
      if (stopped) kill('SIGKILL')
      clearTimeout(timeout)
      if (forceKill) clearTimeout(forceKill)
      signal.removeEventListener('abort', stop)
      resolve(code === 0 && !stopped ? output : '')
    })
    child.stdin.end(input)
    if (signal.aborted) stop()
  })
}

export default function (pi: ExtensionAPI, generate = runHook) {
  let pending: Promise<void> | undefined
  let controller: AbortController | undefined

  const nameSession = async (prompt: string, ctx: ExtensionContext, signal: AbortSignal) => {
    try {
      const sessionId = ctx.sessionManager.getSessionId()
      const originalName = pi.getSessionName()
      const result = await generate(
        join(homedir(), '.agents/hooks/autoname-session.sh'),
        JSON.stringify({
          session_id: `pi-${sessionId}`,
          session_title: originalName ?? '',
          transcript_path: ctx.sessionManager.getSessionFile() ?? '',
          prompt: prompt.slice(0, 1000),
        }),
        ctx.cwd,
        signal
      )
      if (!result.trim() || signal.aborted) return
      const output: unknown = JSON.parse(result)
      if (!output || typeof output !== 'object' || !('hookSpecificOutput' in output)) return
      const hook = output.hookSpecificOutput
      if (!hook || typeof hook !== 'object' || !('sessionTitle' in hook)) return
      const name = hook.sessionTitle
      if (typeof name !== 'string' || name.length > 120 || !KEBAB_CASE.test(name)) return
      if (ctx.sessionManager.getSessionId() !== sessionId || pi.getSessionName() !== originalName)
        return
      pi.setSessionName(name)
    } catch (error) {
      if (!signal.aborted) {
        console.warn(`Pi autoname: ${error instanceof Error ? error.message : 'hook failed'}`)
      }
    }
  }

  pi.on('before_agent_start', (event, ctx) => {
    if (event.messageType !== 'user' || pending) return
    const current = pi.getSessionName()
    if (current && !KEBAB_CASE.test(current)) return
    const prompt = event.prompt.trim()
    if (!prompt || /^[/!#]/.test(prompt)) return
    controller = new AbortController()
    const { signal } = controller
    const run = async () => {
      try {
        await nameSession(prompt, ctx, signal)
      } finally {
        pending = undefined
      }
    }
    pending = run()
  })

  pi.on('session_shutdown', async event => {
    if (event.reason !== 'quit') controller?.abort()
    await pending
  })
}
