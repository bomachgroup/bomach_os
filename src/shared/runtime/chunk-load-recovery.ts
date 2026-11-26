const RELOAD_GUARD_KEY = 'bomach:chunk-reload-build'

type RecoveryStorage = Pick<Storage, 'getItem' | 'setItem' | 'removeItem'>

interface ChunkLoadRecoveryOptions {
  buildId: string
  storage?: RecoveryStorage | null
  reload?: () => void
  target?: Pick<Window, 'addEventListener' | 'removeEventListener'>
}

/** Recover an old tab when a Vite lazy chunk has been removed by a deployment. */
export function installChunkLoadRecovery({
  buildId,
  storage: suppliedStorage,
  reload = () => window.location.reload(),
  target = window,
}: ChunkLoadRecoveryOptions): () => void {
  let storage = suppliedStorage
  if (storage === undefined) {
    try {
      storage = window.sessionStorage
    } catch {
      return () => undefined
    }
  }
  if (!storage) return () => undefined

  try {
    const attemptedBuildId = storage.getItem(RELOAD_GUARD_KEY)
    if (attemptedBuildId && attemptedBuildId !== buildId) {
      storage.removeItem(RELOAD_GUARD_KEY)
    }
  } catch {
    return () => undefined
  }

  const onPreloadError = (event: Event) => {
    try {
      if (storage.getItem(RELOAD_GUARD_KEY) === buildId) return
      storage.setItem(RELOAD_GUARD_KEY, buildId)
    } catch {
      // Keep Vite's normal import error behavior if the reload guard cannot persist.
      return
    }

    event.preventDefault()
    reload()
  }

  target.addEventListener('vite:preloadError', onPreloadError)
  return () => target.removeEventListener('vite:preloadError', onPreloadError)
}
