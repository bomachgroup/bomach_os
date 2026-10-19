import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routerMocks = vi.hoisted(() => ({
  navigate: vi.fn(),
  invalidate: vi.fn(async () => undefined),
  router: {
    state: { location: { href: '/hr/employees?status=active' } },
    navigate: vi.fn(),
    invalidate: vi.fn(async () => undefined),
  },
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Outlet: () => null,
    useRouter: () => routerMocks.router,
    useNavigate: () => routerMocks.navigate,
  }
})

import { RouteError, RootLayout } from './route-components'
import { SESSION_EXPIRED_EVENT } from '@/shared/api/api-client'
import { SessionBootstrapError } from '@/shared/auth/session'

function renderWithClient(children: ReactNode, queryClient = new QueryClient()) {
  return {
    queryClient,
    ...render(createElement(QueryClientProvider, { client: queryClient }, children)),
  }
}

describe('auth route boundaries', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    window.sessionStorage.clear()
  })

  it('blocks on permission bootstrap failure and offers an explicit retry', async () => {
    const user = userEvent.setup()
    const reset = vi.fn()
    const queryClient = new QueryClient()
    renderWithClient(
      <RouteError error={new SessionBootstrapError('permissions')} reset={reset} />,
      queryClient,
    )

    expect(screen.getByText(/Access is paused until they can be verified/)).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))

    await waitFor(() => expect(reset).toHaveBeenCalledOnce())
    expect(routerMocks.router.invalidate).toHaveBeenCalledOnce()
  })

  it('clears protected query state and redirects once when the session expires', async () => {
    const queryClient = new QueryClient()
    queryClient.setQueryData(['protected'], { record: 'private' })
    renderWithClient(<RootLayout />, queryClient)

    window.dispatchEvent(new Event(SESSION_EXPIRED_EVENT))

    await waitFor(() =>
      expect(routerMocks.router.navigate).toHaveBeenCalledWith({
        to: '/login',
        search: { expired: true, returnTo: '/hr/employees?status=active' },
      }),
    )
    expect(queryClient.getQueryData(['protected'])).toBeUndefined()
  })
})
