import { useEffect } from 'react'
import { SearchX } from 'lucide-react'
import { useQueryClient } from '@tanstack/react-query'
import { Outlet, useRouter } from '@tanstack/react-router'

import { SESSION_EXPIRED_EVENT } from '@/shared/api/api-client'
import { safeInternalTarget } from '@/shared/auth/navigation'
import { AUTH_SESSION_QUERY_KEY, SessionBootstrapError } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
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
  const bootstrapError = error instanceof SessionBootstrapError ? error : null
  const cause = bootstrapError?.cause
  const presentation = presentError(cause ?? error, 'page-load')
  const title =
    bootstrapError && cause === undefined
      ? 'Workspace access could not be verified'
      : presentation.title
  const detail =
    bootstrapError && cause === undefined
      ? bootstrapError.stage === 'permissions'
        ? 'Your access permissions could not be verified. Retry to continue securely.'
        : 'Your employee profile could not be loaded. Retry to continue.'
      : presentation.message

  async function retry() {
    await queryClient.resetQueries({ queryKey: AUTH_SESSION_QUERY_KEY })
    reset()
    await router.invalidate()
  }

  return (
    <main className="bg-background flex min-h-svh items-center justify-center px-4 py-8">
      <ErrorState
        title={title}
        description={detail}
        action={<Button onClick={() => void retry()}>Try again</Button>}
      />
    </main>
  )
}

export function NotFoundPage() {
  const router = useRouter()

  return (
    <main className="bg-background flex min-h-svh items-center justify-center px-4 py-8">
      <section
        className="bg-surface border-border-subtle shadow-elevation-sm rounded-surface phone:p-8 w-full max-w-xl border p-6 text-center"
        aria-labelledby="not-found-title"
      >
        <span className="bg-primary-subtle text-primary rounded-control mx-auto flex size-14 items-center justify-center">
          <SearchX aria-hidden="true" className="size-7" />
        </span>
        <p className="text-caption text-primary mt-5 font-semibold tracking-wide">404</p>
        <h1 id="not-found-title" className="text-h2 text-text-primary mt-1 font-semibold">
          Page not found
        </h1>
        <p className="text-body-sm text-text-secondary mx-auto mt-2 max-w-md">
          We couldn’t find the page you’re looking for. The address may be incorrect, or the page
          may have moved.
        </p>
        <Button className="mt-6" onClick={() => void router.navigate({ to: '/dashboard' })}>
          Go to dashboard
        </Button>
      </section>
    </main>
  )
}

export function NoAccessPage() {
  return <NoAccessContent />
}
