import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'

import { authSessionQueryOptions } from '@/shared/auth/session'
import { resolvePostLoginTarget } from '@/shared/auth/navigation'

export function SplashPage() {
  const { data: session } = useQuery(authSessionQueryOptions())
  const search = useSearch({ from: '/splash' })
  const navigate = useNavigate()

  useEffect(() => {
    if (!session) return
    const destination = resolvePostLoginTarget(search.returnTo, session)
    void navigate({ to: destination as never, replace: true })
  }, [navigate, search.returnTo, session])

  return (
    <main className="bg-background text-text-primary flex min-h-svh flex-col items-center justify-center gap-5 px-4 text-center">
      <span
        aria-hidden="true"
        className="border-primary size-10 animate-spin rounded-full border-4 border-r-transparent"
      />
      <p className="text-body-md">Loading your workspace...</p>
    </main>
  )
}
