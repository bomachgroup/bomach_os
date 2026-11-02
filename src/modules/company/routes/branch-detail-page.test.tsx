import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { StrictMode } from 'react'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { branchesApi, type BranchDto } from '@/modules/company/branches.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateBranchDirectorySearch } from '../branches.search'
import { BranchDetailPage } from './branch-detail-page'

const branchBase: BranchDto = {
  id: 44,
  branch_name: 'North Office',
  branch_id: 'NTH',
  default_currency: 'NGN',
  language_preference: 'en-GB',
  country: 'Nigeria',
  country_code: 'NG',
  state: 'Lagos',
  state_code: 'LA',
  city: 'Lagos',
  lga: 'Ikeja',
  office_address: '12 Airport Road',
  full_address: '12 Airport Road, Lagos, Nigeria',
  operational_status: 'active',
  operational_status_display: 'Active',
  branch_role: 'branch',
  branch_role_display: 'Branch',
  contact_email: 'north@example.test',
  contact_phone: '+2348012345678',
  manager_id: null,
  manager_name: null,
  is_active: true,
  is_operational: true,
  latitude: null,
  longitude: null,
  attendance_radius_meters: 100,
  notes: '',
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
}

const viewAndUpdateSession: AuthenticatedSession = {
  user: {
    id: 7,
    email: 'branch-admin@example.test',
    username: 'branch-admin',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: { branches: ['view', 'update'] },
  },
  employee: {
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'branch-admin',
    email: 'branch-admin@example.test',
  },
  roles: [],
  permissions: { branches: ['view', 'update'] },
}

const showToast = vi.fn()
let queryClient: QueryClient

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.setAttribute('open', '')
  },
})
Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.removeAttribute('open')
    this.dispatchEvent(new Event('close'))
  },
})

function renderDetailPage() {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, viewAndUpdateSession)

  const rootRoute = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const directoryRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/branch',
    validateSearch: validateBranchDirectorySearch,
    component: () => <div>Branch directory</div>,
  })
  const detailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/branch/$branchId',
    validateSearch: validateBranchDirectorySearch,
    component: BranchDetailPage,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([protectedRoute.addChildren([directoryRoute, detailRoute])]),
    history: createMemoryHistory({ initialEntries: ['/company/branch/44'] }),
  })

  render(
    <StrictMode>
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <RouterProvider router={router} />
        </QueryClientProvider>
      </ToastContext.Provider>
    </StrictMode>,
  )
}

describe('BranchDetailPage geofence action', () => {
  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
    showToast.mockReset()
  })

  it.each([
    {
      description: 'a branch with a saved point',
      branch: { ...branchBase, latitude: 6.5244, longitude: 3.3792 },
      latitude: '6.5244',
      longitude: '3.3792',
    },
    {
      description: 'a branch without a saved point',
      branch: branchBase,
      latitude: '',
      longitude: '',
    },
  ])('opens and initializes Update for $description', async ({ branch, latitude, longitude }) => {
    const user = userEvent.setup()
    vi.spyOn(branchesApi, 'detail').mockResolvedValue(branch)
    vi.spyOn(branchesApi, 'businessHours').mockResolvedValue([])

    renderDetailPage()
    await screen.findByRole('heading', { name: 'Attendance geofence' })
    await user.click(screen.getByRole('button', { name: 'Update' }))

    const dialog = await screen.findByRole('dialog', {
      name: `Update geofence · ${branch.branch_name}`,
    })
    await waitFor(() => expect(dialog).toHaveAttribute('open'))
    expect(within(dialog).getByLabelText('Latitude')).toHaveValue(latitude)
    expect(within(dialog).getByLabelText('Longitude')).toHaveValue(longitude)
    expect(within(dialog).getByLabelText(/^Attendance radius \(metres\)/)).toHaveValue(100)
  })
})
