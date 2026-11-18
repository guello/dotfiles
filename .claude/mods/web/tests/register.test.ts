import { describe, expect, test, tier } from 'claude-code/testing'

import { run } from './fixtures/run'
import { setup } from './fixtures/setup'

tier('user')

describe('register', () => {
  test('/web opens the bridge session URL and adds no text', async ($, on) => {
    const state = setup(on, {
      records: {
        '1.json': { sessionId: 'other', bridgeSessionId: 'session_other' },
        '2.json': { sessionId: 'local-1', bridgeSessionId: 'session_01Abc' },
      },
    })
    const result = await run($)
    expect(result.text).toBe(undefined)
    expect(state.opened).toEqual([['open', 'https://claude.ai/code/session_01Abc']])
    expect(state.toasts).toEqual(['Opened https://claude.ai/code/session_01Abc'])
  })

  test('/web maps a cse_ id to the session_ form', async ($, on) => {
    const state = setup(on, {
      records: { '2.json': { sessionId: 'local-1', bridgeSessionId: 'cse_01Abc' } },
    })
    await run($)
    expect(state.opened[0]).toEqual(['open', 'https://claude.ai/code/session_01Abc'])
  })

  test('/web without Remote Control opens nothing and displays a message', async ($, on) => {
    const state = setup(on, {
      records: { '2.json': { sessionId: 'local-1', bridgeSessionId: null } },
    })
    await run($)
    expect(state.opened).toEqual([])
    expect(state.toasts).toEqual([
      'Remote Control is off. Enable it with /remote-control and try again.',
    ])
  })

  test('/web reports a failed open command', async ($, on) => {
    const state = setup(on, {
      records: { '2.json': { sessionId: 'local-1', bridgeSessionId: 'session_01Abc' } },
      openExit: 1,
    })
    await run($)
    expect(state.toasts).toEqual(['Could not open https://claude.ai/code/session_01Abc'])
  })
})
