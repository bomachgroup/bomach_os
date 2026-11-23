import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routerMocks = vi.hoisted(() => ({
  navigate: vi.fn(),
  invalidate: vi.fn(async () => undefined),
  router: {
    state: { location: { pathname: '/hr/employees', href: '/hr/employees?status=active' } },
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
    useRouterState: ({
      select,
    }: {
      select: (state: { location: typeof routerMocks.router.state.location }) => unknown
    }) => select({ location: routerMocks.router.state.location }),
    useNavigate: () => routerMocks.navigate,
  }
})

import { NotFoundPage, PartnerNotFoundPage, RouteError, RootLayout } from './route-components'
import { SESSION_EXPIRED_EVENT } from '@/shared/api/api-client'
import { SessionBootstrapError } from '@/shared/auth/session'
import { setWorkspaceMode } from '@/shared/auth/workspace-mode'

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
    window.localStorage.clear()
    routerMocks.router.state.location = {
      pathname: '/hr/employees',
      href: '/hr/employees?status=active',
    }
  })

  it('blocks on permission bootstrap failure and offers an explicit retry', async () => {
    const user = userEvent.setup()
    const reset = vi.fn()
    const queryClient = new QueryClient()
    renderWithClient(
      <RouteError error={new SessionBootstrapError('permissions')} reset={reset} />,
      queryClient,
    )

    expect(screen.getByText(/Your access permissions could not be verified/)).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))

    await waitFor(() => expect(reset).toHaveBeenCalledOnce())
    expect(routerMocks.router.invalidate).toHaveBeenCalledOnce()
  })

  it('shows a real not-found page and offers a route back to the dashboard', async () => {
    const user = userEvent.setup()
    renderWithClient(<NotFoundPage />)

    expect(screen.getByText('404')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Page not found' })).toBeInTheDocument()
    expect(
      screen.getByText(/address may be incorrect, or the page may have moved/i),
    ).toBeInTheDocument()
    expect(screen.queryByText(/React port/i)).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Go to dashboard' }))
    expect(routerMocks.router.navigate).toHaveBeenCalledWith({ to: '/dashboard' })
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

  it('returns expired partner sessions to partner sign-in', async () => {
    const queryClient = new QueryClient()
    routerMocks.router.state.location = {
      pathname: '/partners/app',
      href: '/partners/app?tab=messages',
    }
    renderWithClient(<RootLayout />, queryClient)

    window.dispatchEvent(new Event(SESSION_EXPIRED_EVENT))

    await waitFor(() =>
      expect(routerMocks.router.navigate).toHaveBeenCalledWith({
        to: '/partners/login',
        search: { expired: true },
      }),
    )
  })

  it('shows partners a neutral 404 instead of rendering a staff route', async () => {
    setWorkspaceMode('partner')
    routerMocks.router.state.location = {
      pathname: '/dashboard',
      href: '/dashboard?tab=overview',
    }
    const queryClient = new QueryClient()
    renderWithClient(<RootLayout />, queryClient)

    expect(screen.getByRole('heading', { name: 'Page not found' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Go back' })).toBeInTheDocument()
    expect(screen.queryByText(/staff|employee|dashboard/i)).not.toBeInTheDocument()
    await waitFor(() =>
      expect(routerMocks.router.navigate).toHaveBeenCalledWith({
        to: '/partners/not-found',
        replace: true,
      }),
    )
  })

  it('returns from the partner 404 to the partner home without exposing staff navigation', async () => {
    const user = userEvent.setup()
    renderWithClient(<PartnerNotFoundPage />)

    await user.click(screen.getByRole('button', { name: 'Go back' }))
    expect(routerMocks.router.navigate).toHaveBeenCalledWith({
      to: '/partners/app',
      search: { tab: 'home' },
      replace: true,
    })
  })

  it('uses the stored partner mode for session expiry even on a staff-looking URL', async () => {
    setWorkspaceMode('partner')
    routerMocks.router.state.location = { pathname: '/dashboard', href: '/dashboard' }
    renderWithClient(<RootLayout />)

    window.dispatchEvent(new Event(SESSION_EXPIRED_EVENT))

    await waitFor(() =>
      expect(routerMocks.router.navigate).toHaveBeenCalledWith({
        to: '/partners/login',
        search: { expired: true },
      }),
    )
  })
})
