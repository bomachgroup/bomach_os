import { afterEach, describe, expect, it, vi } from 'vitest'

import { installChunkLoadRecovery } from './chunk-load-recovery'

function memoryStorage(): Storage {
  const values = new Map<string, string>()
  return {
    getItem: (key) => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, String(value)),
    removeItem: (key) => values.delete(key),
    clear: () => values.clear(),
    key: (index) => [...values.keys()][index] ?? null,
    get length() {
      return values.size
    },
  }
}

describe('Vite chunk load recovery', () => {
  const cleanups: Array<() => void> = []

  afterEach(() => {
    cleanups.splice(0).forEach((cleanup) => cleanup())
    sessionStorage.clear()
  })

  it('reloads once when a lazy chunk fails in the current build', () => {
    const reload = vi.fn()
    const storage = memoryStorage()
    cleanups.push(installChunkLoadRecovery({ buildId: 'build-a', storage, reload }))

    const firstFailure = new Event('vite:preloadError', { cancelable: true })
    window.dispatchEvent(firstFailure)
    const repeatedFailure = new Event('vite:preloadError', { cancelable: true })
    window.dispatchEvent(repeatedFailure)

    expect(firstFailure.defaultPrevented).toBe(true)
    expect(repeatedFailure.defaultPrevented).toBe(false)
    expect(reload).toHaveBeenCalledTimes(1)
  })

  it('allows recovery again after a newer build is loaded', () => {
    const reload = vi.fn()
    const storage = memoryStorage()
    cleanups.push(installChunkLoadRecovery({ buildId: 'build-a', storage, reload }))
    window.dispatchEvent(new Event('vite:preloadError', { cancelable: true }))
    cleanups.splice(0).forEach((cleanup) => cleanup())

    cleanups.push(installChunkLoadRecovery({ buildId: 'build-b', storage, reload }))
    const nextBuildFailure = new Event('vite:preloadError', { cancelable: true })
    window.dispatchEvent(nextBuildFailure)

    expect(nextBuildFailure.defaultPrevented).toBe(true)
    expect(reload).toHaveBeenCalledTimes(2)
  })

  it('leaves the original Vite error intact when session storage is unavailable', () => {
    const reload = vi.fn()
    cleanups.push(installChunkLoadRecovery({ buildId: 'build-a', storage: null, reload }))
    const failure = new Event('vite:preloadError', { cancelable: true })
    window.dispatchEvent(failure)

    expect(failure.defaultPrevented).toBe(false)
    expect(reload).not.toHaveBeenCalled()
  })
})
