import { QueryClient } from '@tanstack/react-query'
import {
  Outlet,
  createRootRouteWithContext,
  createRoute,
  createRouter,
  lazyRouteComponent,
  redirect,
} from '@tanstack/react-router'
import type { AnyRoute } from '@tanstack/react-router'

import {
  requireAuthenticatedSession,
  requirePermission,
  requireProtectedDestination,
} from '@/shared/auth/route-guards'
import { ErrorState } from '@/shared/ui/feedback-states'
import { NoAccessPage, RootLayout, RouteError } from './route-components'
import { PROTECTED_DESTINATIONS } from '@/app/navigation/route-manifest'
import { AppShell, ComingSoonPage } from '@/app/shell/app-shell'

const FoundationPreview = lazyRouteComponent(() => import('@/app/FoundationPreview'), 'default')
const BiometricPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/biometric-page'),
  'BiometricPage',
)
const ForgotPasswordPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/forgot-password-page'),
  'ForgotPasswordPage',
)
const LoginPage = lazyRouteComponent(() => import('@/modules/auth/routes/login-page'), 'LoginPage')
const ResetPasswordPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/reset-password-page'),
  'ResetPasswordPage',
)
const SplashPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/splash-page'),
  'SplashPage',
)
const TwoFactorVerifyPage = lazyRouteComponent(
  () => import('@/modules/auth/routes/two-factor-verify-page'),
  'TwoFactorVerifyPage',
)
const WorkspaceOverviewPage = lazyRouteComponent(
  () => import('@/modules/dashboard/routes/workspace-overview-page'),
  'WorkspaceOverviewPage',
)
const CompanyOverviewPage = lazyRouteComponent(
  () => import('@/modules/company/routes/company-overview-page'),
  'CompanyOverviewPage',
)
const HRDashboardPage = lazyRouteComponent(
  () => import('@/modules/hr/routes/hr-dashboard-page'),
  'HRDashboardPage',
)

export interface AppRouterContext {
  queryClient: QueryClient
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { refetchOnWindowFocus: false, retry: 1 },
    mutations: { retry: 0 },
  },
})

function validateLoginSearch(search: Record<string, unknown>) {
  const result: { returnTo?: string; expired?: boolean; reset?: boolean } = {}
  if (typeof search.returnTo === 'string') result.returnTo = search.returnTo
  if (search.expired === true || search.expired === 'true' || search.expired === '1') {
    result.expired = true
  }
  if (search.reset === true || search.reset === 'true' || search.reset === '1') {
    result.reset = true
  }
  return result
}

const rootRoute = createRootRouteWithContext<AppRouterContext>()({
  component: RootLayout,
  errorComponent: RouteError,
  notFoundComponent: () => (
    <main className="bg-background text-text-primary flex min-h-svh items-center justify-center p-6">
      <ErrorState
        title="Page not found"
        description="This page is not available in the React port yet."
      />
    </main>
  ),
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  beforeLoad: () => {
    throw redirect({ to: '/splash' })
  },
})

const splashRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/splash',
  validateSearch: validateLoginSearch,
  beforeLoad: async ({ context, location }) => {
    await requireAuthenticatedSession(context, location)
  },
  component: SplashPage,
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  validateSearch: validateLoginSearch,
  component: LoginPage,
})

const forgotPasswordRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/forgot-password',
  component: ForgotPasswordPage,
})

const resetPasswordRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/reset-password',
  component: ResetPasswordPage,
})

const biometricRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/biometric',
  component: BiometricPage,
})

const twoFactorRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/two-factor-verify',
  validateSearch: validateLoginSearch,
  component: TwoFactorVerifyPage,
})

const protectedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: '_protected',
  beforeLoad: async ({ context, location }) => {
    await requireAuthenticatedSession(context, location)
  },
  component: () => (
    <AppShell>
      <Outlet />
    </AppShell>
  ),
})

const noAccessRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: 'no-access',
  component: NoAccessPage,
})

const foundationPreviewRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/__foundation',
  component: FoundationPreview,
})

const protectedDestinationRoutes = PROTECTED_DESTINATIONS.map(
  (destination) =>
    createRoute({
      getParentRoute: () => protectedLayoutRoute,
      path: destination.path,
      beforeLoad: async ({ context, location }) => {
        await requireProtectedDestination(context, location, destination)
      },
      component: () => {
        if (destination.path === '/dashboard') return <WorkspaceOverviewPage />
        if (destination.path === '/company/overview') return <CompanyOverviewPage />
        if (destination.path === '/hr') return <HRDashboardPage />
        return <ComingSoonPage destination={destination} />
      },
    }) as AnyRoute,
)

const routeTree = rootRoute.addChildren([
  indexRoute,
  splashRoute,
  loginRoute,
  forgotPasswordRoute,
  resetPasswordRoute,
  biometricRoute,
  twoFactorRoute,
  protectedLayoutRoute.addChildren([noAccessRoute, ...protectedDestinationRoutes]),
  ...(import.meta.env.DEV ? [foundationPreviewRoute] : []),
])

export const router = createRouter({
  routeTree,
  context: { queryClient },
  defaultPreload: 'intent',
  scrollRestoration: true,
})

export async function protectByPermission(
  context: AppRouterContext,
  location: { pathname: string; searchStr: string; hash: string },
  resource: string,
  action: string,
) {
  await requirePermission(context, location, resource, action)
}

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
