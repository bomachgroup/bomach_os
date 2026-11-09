import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  apiClient,
  SESSION_ESTABLISHED_KEY,
  SESSION_EXPIRED_EVENT,
  SESSION_EXPIRED_NOTICE_CONSUMED,
  SESSION_EXPIRED_NOTICE_KEY,
} from './api-client'

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

describe('shared cookie API client', () => {
  let fetchMock: ReturnType<typeof vi.fn<typeof fetch>>

  beforeEach(() => {
    window.sessionStorage.clear()
    fetchMock = vi.fn<typeof fetch>()
    vi.stubGlobal('fetch', fetchMock)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('sends JSON with same-origin cookies and the browser CSRF header', async () => {
    fetchMock.mockResolvedValue(jsonResponse({ saved: true }))

    await apiClient.post('/profile', { display_name: 'A User' })

    const [, request] = fetchMock.mock.calls[0] ?? []
    expect(request?.credentials).toBe('include')
    expect(request?.cache).toBe('no-store')
    expect(request?.headers).toBeInstanceOf(Headers)
    const headers = request?.headers as Headers
    expect(headers.get('X-Bomach-Request')).toBe('browser')
    expect(headers.get('Content-Type')).toBe('application/json')
    expect(request?.body).toBe(JSON.stringify({ display_name: 'A User' }))
    expect(headers.has('Authorization')).toBe(false)
  })

  it('shares one refresh request across concurrent unauthorized calls and retries each once', async () => {
    window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
    let protectedCalls = 0
    let refreshCalls = 0
    fetchMock.mockImplementation(async (input) => {
      const url = String(input)
      if (url.endsWith('/auth/browser/refresh')) {
        refreshCalls += 1
        await Promise.resolve()
        return jsonResponse({ success: true })
      }
      protectedCalls += 1
      if (protectedCalls <= 2) return jsonResponse({ detail: 'Expired' }, 401)
      return jsonResponse({ ok: true })
    })

    const [first, second] = await Promise.all([
      apiClient.get<{ ok: boolean }>('/resource/one'),
      apiClient.get<{ ok: boolean }>('/resource/two'),
    ])

    expect(first.ok).toBe(true)
    expect(second.ok).toBe(true)
    expect(refreshCalls).toBe(1)
    expect(protectedCalls).toBe(4)
  })

  it('normalizes request failures and announces an expired known session once', async () => {
    window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
    window.sessionStorage.setItem(SESSION_EXPIRED_NOTICE_KEY, SESSION_EXPIRED_NOTICE_CONSUMED)
    const expiredHandler = vi.fn()
    window.addEventListener(SESSION_EXPIRED_EVENT, expiredHandler)
    fetchMock.mockImplementation(async (input) =>
      String(input).endsWith('/auth/browser/refresh')
        ? jsonResponse({ detail: 'Expired', code: 'AUTH_SESSION_EXPIRED' }, 401)
        : jsonResponse({ detail: 'Expired' }, 401),
    )

    await expect(apiClient.get('/private')).rejects.toMatchObject({ status: 401 })
    expect(expiredHandler).toHaveBeenCalledTimes(1)
    expect(window.sessionStorage.getItem(SESSION_ESTABLISHED_KEY)).toBeNull()
    expect(window.sessionStorage.getItem(SESSION_EXPIRED_NOTICE_KEY)).toBe('1')
    window.removeEventListener(SESSION_EXPIRED_EVENT, expiredHandler)
  })
})
