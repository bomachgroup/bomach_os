import { useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { Outlet, useRouter } from '@tanstack/react-router'

import { SESSION_EXPIRED_EVENT } from '@/shared/api/api-client'
import { ApiError } from '@/shared/api/api-error'
import { safeInternalTarget } from '@/shared/auth/navigation'
import { AUTH_SESSION_QUERY_KEY, SessionBootstrapError } from '@/shared/auth/session'
import { Button } from '@/shared/ui/button'
import { ErrorState } from '@/shared/ui/feedback-states'
import { ToastProvider } from '@/shared/feedback/toast-provider'
import { NoAccessContent } from '@/app/shell/app-shell'

export function RootLayout() {
  const router = useRouter()
  const queryClient = useQueryClient()

  useEffect(() => {
    const onSessionExpired = () => {
      const returnTo = safeInternalTarget(router.state.location.href)
      queryClient.clear()
      void router.navigate({
        to: '/login',
        search: { expired: true, ...(returnTo ? { returnTo } : {}) },
      })
    }

    window.addEventListener(SESSION_EXPIRED_EVENT, onSessionExpired)
    return () => window.removeEventListener(SESSION_EXPIRED_EVENT, onSessionExpired)
  }, [queryClient, router])

  return (
    <ToastProvider>
      <Outlet />
    </ToastProvider>
  )
}

export function RouteError({ error, reset }: { error: unknown; reset: () => void }) {
  const router = useRouter()
  const queryClient = useQueryClient()
  const detail =
    error instanceof SessionBootstrapError
      ? error.stage === 'permissions'
        ? 'Your roles and permissions could not be loaded. Access is paused until they can be verified.'
        : 'Your employee profile could not be loaded. Check your connection and try again.'
      : error instanceof ApiError && error.status === 0
        ? 'The server could not be reached. Check your connection and try again.'
        : 'We could not load this page. Try again.'

  async function retry() {
    await queryClient.resetQueries({ queryKey: AUTH_SESSION_QUERY_KEY })
    reset()
    await router.invalidate()
  }

  return (
    <main className="bg-background flex min-h-svh items-center justify-center px-4 py-8">
      <ErrorState
        title={
          error instanceof SessionBootstrapError
            ? 'Workspace access could not be verified'
            : 'Unable to continue'
        }
        description={detail}
        action={<Button onClick={() => void retry()}>Try again</Button>}
      />
    </main>
  )
}

export function NoAccessPage() {
  return <NoAccessContent />
}
