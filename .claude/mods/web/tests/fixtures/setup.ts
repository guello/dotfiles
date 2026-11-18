import type { On } from 'claude-code'
import { mock } from 'claude-code/testing'

interface Options {
  records?: Record<string, unknown>
  openExit?: number
}

export const setup = (on: On, options: Options = {}) => {
  const records = options.records ?? {}
  const state = { toasts: [] as string[], opened: [] as string[][] }
  mock.env(on, { HOME: '/home' })
  on('command.register', () => ({ value: { command: 'web' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('session.id', () => ({ value: 'local-1' }))
  on('fs.list', () => ({
    value: Object.keys(records).map(name => ({
      name,
      kind: 'file',
      size: 1,
      mtimeMs: 0,
      isLink: false,
    })),
  }))
  on('fs.read', ($, e) => ({ value: JSON.stringify(records[e.path.split('/').pop() ?? '']) }))
  on('process.run', ($, e) => {
    state.opened.push([...e.argv])
    return {
      value: {
        exitCode: options.openExit ?? 0,
        stdout: '',
        stderr: '',
        isStdoutTruncated: false,
        isStderrTruncated: false,
      },
    }
  })
  on('ui.toast', ($, e) => {
    state.toasts.push(e.text)
    return { value: undefined }
  })
  return state
}
