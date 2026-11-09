import { act, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { lazy, type ComponentType } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Link,
  Outlet,
  redirect,
  RouterProvider,
} from '@tanstack/react-router'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { AppShell } from './app-shell'
import { NotFoundPage } from '@/app/router/route-components'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastProvider } from '@/shared/feedback/toast-provider'

vi.mock('@/shared/auth/auth.api', () => ({
  authApi: { logout: vi.fn(async () => ({ success: true })) },
}))

vi.mock('@/shared/notifications/notifications.api', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/shared/notifications/notifications.api')>()
  return { ...actual, notificationApi: { ...actual.notificationApi } }
})

function session(): AuthenticatedSession {
  const permissions = { employees: ['list'] }
  return {
    user: {
      id: 7,
      email: 'staff@example.com',
      username: 'staff',
      first_name: 'Staff',
      last_name: 'User',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'staff',
      email: 'staff@example.com',
      first_name: 'Staff',
      last_name: 'User',
      designation: 'Coordinator',
    },
    roles: [],
    permissions,
  }
}

function deferred<T>() {
  let resolve!: (value: T) => void
  let reject!: (reason?: unknown) => void
  const promise = new Promise<T>((resolvePromise, rejectPromise) => {
    resolve = resolvePromise
    reject = rejectPromise
  })
  return { promise, resolve, reject }
}

function createHarness({
  denyEmployees = false,
  redirectEmployees = false,
  initialPath = '/dashboard',
}: { denyEmployees?: boolean; redirectEmployees?: boolean; initialPath?: string } = {}) {
  const delayedModule = deferred<{ default: ComponentType }>()
  const guardGate = deferred<void>()
  const DelayedEmployeesPage = lazy<ComponentType>(() => delayedModule.promise)
  Object.assign(DelayedEmployeesPage, {
    preload: () => delayedModule.promise.then(() => undefined),
  })

  const rootRoute = createRootRoute({ component: () => <Outlet /> })
  const protectedLayoutRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: () => (
      <AppShell>
        <Outlet />
      </AppShell>
    ),
  })
  const dashboardRoute = createRoute({
    getParentRoute: () => protectedLayoutRoute,
    path: '/dashboard',
    component: () => (
      <section>
        <h1>Workspace overview</h1>
        <Link to="/hr/employees">Open employees from this page</Link>
      </section>
    ),
  })
  const employeesRoute = createRoute({
    getParentRoute: () => protectedLayoutRoute,
    path: '/hr/employees',
    beforeLoad: async () => {
      if (redirectEmployees) {
        await guardGate.promise
        throw redirect({ to: '/dashboard' })
      }
      if (denyEmployees) throw redirect({ to: '/no-access' })
    },
    component: DelayedEmployeesPage,
    errorComponent: () => <div data-testid="destination-error">Destination failed to load</div>,
  })
  const noAccessRoute = createRoute({
    getParentRoute: () => protectedLayoutRoute,
    path: '/no-access',
    component: () => <h1>Access denied</h1>,
  })
  const notFoundRoute = createRoute({
    getParentRoute: () => protectedLayoutRoute,
    path: '$',
    component: NotFoundPage,
  })
  const routeTree = rootRoute.addChildren([
    protectedLayoutRoute.addChildren([
      dashboardRoute,
      employeesRoute,
      noAccessRoute,
      notFoundRoute,
    ]),
  ])
  const history = createMemoryHistory({ initialEntries: [initialPath] })
  const router = createRouter({ routeTree, history, defaultPreload: false })
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session())

  return { delayedModule, guardGate, history, queryClient, router }
}

async function renderHarness(options?: {
  denyEmployees?: boolean
  redirectEmployees?: boolean
  initialPath?: string
}) {
  const harness = createHarness(options)
  const view = render(
    <QueryClientProvider client={harness.queryClient}>
      <ToastProvider>
        <RouterProvider router={harness.router} />
      </ToastProvider>
    </QueryClientProvider>,
  )
  await screen.findByRole('heading', {
    name: options?.initialPath === '/me' ? 'Page not found' : 'Workspace overview',
  })
  return { ...harness, ...view }
}

beforeEach(() => {
  localStorage.clear()
  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: query === '(min-width: 1100px)',
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
})

describe('route transition feedback', () => {
  it('renders unknown workspace paths inside the authenticated shell', async () => {
    await renderHarness({ initialPath: '/me' })

    expect(screen.getByRole('heading', { name: 'Page not found' })).toBeInTheDocument()
    expect(screen.getByRole('banner', { name: 'Workspace header' })).toBeInTheDocument()
    expect(screen.getByRole('navigation', { name: 'Main navigation' })).toBeInTheDocument()
  })

  it('replaces the current page and highlights a sidebar destination while its lazy module loads', async () => {
    const user = userEvent.setup()
    const { delayedModule } = await renderHarness()

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))
    const employeesLink = screen.getByRole('link', { name: 'Employees' })
    employeesLink.focus()
    await user.keyboard('{Enter}')

    expect(await screen.findByRole('status', { name: 'Loading destination page' })).toHaveAttribute(
      'aria-busy',
      'true',
    )
    expect(screen.queryByRole('heading', { name: 'Workspace overview' })).not.toBeInTheDocument()
    expect(employeesLink).toHaveAttribute('aria-current', 'page')
    expect(document.activeElement).toBe(employeesLink)

    await act(async () => {
      delayedModule.resolve({
        default: () => <h1>Employee directory</h1>,
      })
    })

    expect(await screen.findByRole('heading', { name: 'Employee directory' })).toBeInTheDocument()
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
  })

  it('closes the mobile navigation drawer while the destination content is pending', async () => {
    const user = userEvent.setup()
    const { delayedModule } = await renderHarness()

    await user.click(screen.getByRole('button', { name: 'Open navigation menu' }))
    const drawer = screen.getByRole('dialog', { name: 'Workspace navigation' })
    await user.click(within(drawer).getByRole('button', { name: 'HR/Admin navigation group' }))
    await user.click(within(drawer).getByRole('link', { name: 'Employees' }))

    expect(
      await screen.findByRole('status', { name: 'Loading destination page' }),
    ).toBeInTheDocument()
    expect(screen.queryByRole('dialog', { name: 'Workspace navigation' })).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Employees' })).toHaveAttribute('aria-current', 'page')

    await act(async () => {
      delayedModule.resolve({ default: () => <h1>Employee directory</h1> })
    })

    expect(await screen.findByRole('heading', { name: 'Employee directory' })).toBeInTheDocument()
  })

  it('shows and clears transition feedback for an in-page link and browser history navigation', async () => {
    const user = userEvent.setup()
    const { delayedModule, history, router } = await renderHarness()
    const shellHeader = screen.getByRole('banner', { name: 'Workspace header' })
    const shellSidebar = screen.getByRole('complementary')
    const hrAdminGroup = screen.getByRole('button', { name: 'HR/Admin navigation group' })

    await user.click(screen.getByRole('link', { name: 'Open employees from this page' }))
    const transition = await screen.findByRole('status', { name: 'Loading destination page' })
    expect(transition).toBeInTheDocument()
    expect(screen.getByRole('banner', { name: 'Workspace header' })).toBe(shellHeader)
    expect(screen.getByRole('complementary')).toBe(shellSidebar)
    expect(hrAdminGroup).toHaveAttribute('aria-expanded', 'false')
    expect(hrAdminGroup).toHaveClass('border-primary/15')
    expect(transition.firstElementChild?.firstElementChild).toHaveClass('min-h-16', 'py-3')

    await act(async () => {
      delayedModule.resolve({ default: () => <h1>Employee directory</h1> })
    })
    expect(await screen.findByRole('heading', { name: 'Employee directory' })).toBeInTheDocument()
    expect(hrAdminGroup).toHaveAttribute('aria-expanded', 'true')

    await act(async () => {
      history.back()
    })
    await waitFor(() => expect(router.state.location.pathname).toBe('/dashboard'))
    expect(await screen.findByRole('heading', { name: 'Workspace overview' })).toBeInTheDocument()
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
  })

  it('lets a newer navigation replace a still-pending destination', async () => {
    const user = userEvent.setup()
    const { router } = await renderHarness()

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))
    await user.click(screen.getByRole('link', { name: 'Employees' }))
    expect(
      await screen.findByRole('status', { name: 'Loading destination page' }),
    ).toBeInTheDocument()

    await act(async () => {
      await router.navigate({ to: '/dashboard' })
    })

    expect(await screen.findByRole('heading', { name: 'Workspace overview' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Overview' })).toHaveAttribute('aria-current', 'page')
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
  })

  it('clears pending feedback and renders the route error state when a chunk fails', async () => {
    const user = userEvent.setup()
    const { delayedModule } = await renderHarness()

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))
    await user.click(screen.getByRole('link', { name: 'Employees' }))
    expect(
      await screen.findByRole('status', { name: 'Loading destination page' }),
    ).toBeInTheDocument()

    await act(async () => {
      delayedModule.reject(new Error('Chunk unavailable'))
    })

    expect(await screen.findByTestId('destination-error')).toBeInTheDocument()
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
  })

  it('moves the pending selection through a guard redirect and clears it after resolution', async () => {
    const user = userEvent.setup()
    const { guardGate } = await renderHarness({ redirectEmployees: true })

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))
    await user.click(screen.getByRole('link', { name: 'Employees' }))
    expect(
      await screen.findByRole('status', { name: 'Loading destination page' }),
    ).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Employees' })).toHaveAttribute('aria-current', 'page')

    await act(async () => {
      guardGate.resolve()
    })

    expect(await screen.findByRole('heading', { name: 'Workspace overview' })).toBeInTheDocument()
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Overview' })).toHaveAttribute('aria-current', 'page')
  })

  it('clears transition feedback after a permission denial redirects to no access', async () => {
    const user = userEvent.setup()
    await renderHarness({ denyEmployees: true })

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))
    await user.click(screen.getByRole('link', { name: 'Employees' }))

    expect(await screen.findByRole('heading', { name: 'Access denied' })).toBeInTheDocument()
    expect(
      screen.queryByRole('status', { name: 'Loading destination page' }),
    ).not.toBeInTheDocument()
  })
})
