import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { act, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import type { BranchDto } from '@/modules/company/branches.api'
import type { BranchDirectorySearch } from '@/modules/company/branches.search'
import { BranchRowActions } from './branch-row-actions'

const branch: BranchDto = {
  id: 44,
  branch_name: 'QA North Office',
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

const search: BranchDirectorySearch = {
  search: '',
  operationalStatus: 'all',
  branchRole: 'all',
  recordState: 'all',
  page: 1,
}

Object.defineProperty(window, 'scrollTo', { configurable: true, value: vi.fn() })

async function renderActions({
  canView = true,
  canEdit = true,
  onEdit = vi.fn(),
}: {
  canView?: boolean
  canEdit?: boolean
  onEdit?: () => void
} = {}) {
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const directoryRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/branch',
    validateSearch: (input: Record<string, unknown>) => input as BranchDirectorySearch,
    component: () => (
      <div>
        <BranchRowActions
          branch={branch}
          search={search}
          canView={canView}
          canEdit={canEdit}
          onEdit={onEdit}
        />
        <button type="button">After row</button>
      </div>
    ),
  })
  const detailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/branch/$branchId',
    component: () => <h1>Branch details loaded</h1>,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([directoryRoute, detailRoute])]),
    history: createMemoryHistory({ initialEntries: ['/company/branch'] }),
  })
  await router.load()
  await act(async () => {
    render(<RouterProvider router={router} />)
  })
  return { onEdit, router }
}

describe('BranchRowActions', () => {
  it('opens a More menu, supports keyboard navigation and closes with focus restored', async () => {
    const user = userEvent.setup()
    await renderActions()

    await screen.findByRole('button', { name: 'After row' })
    const trigger = screen.getByRole('button', { name: 'More actions for QA North Office' })
    expect(trigger).toHaveTextContent('More')
    expect(trigger).toHaveAttribute('aria-expanded', 'false')
    await user.click(trigger)

    const menu = await screen.findByRole('menu', { name: 'Actions for QA North Office' })
    const details = screen.getByRole('menuitem', { name: 'View details for QA North Office' })
    const edit = screen.getByRole('menuitem', { name: 'Edit branch' })
    await waitFor(() => expect(details).toHaveFocus())
    await user.keyboard('{ArrowDown}')
    expect(edit).toHaveFocus()
    await user.keyboard('{Escape}')

    expect(menu).not.toBeInTheDocument()
    await waitFor(() => expect(trigger).toHaveFocus())
    expect(trigger).toHaveAttribute('aria-expanded', 'false')
  })

  it('shows only permitted actions and invokes edit from the menu', async () => {
    const user = userEvent.setup()
    const onEdit = vi.fn()
    await renderActions({ canView: false, canEdit: true, onEdit })

    await screen.findByRole('button', { name: 'After row' })
    await user.click(screen.getByRole('button', { name: 'More actions for QA North Office' }))
    expect(screen.queryByRole('menuitem', { name: /view details/i })).not.toBeInTheDocument()
    await user.click(screen.getByRole('menuitem', { name: 'Edit branch' }))

    expect(onEdit).toHaveBeenCalledOnce()
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  })

  it('navigates to the branch details route and preserves directory search state', async () => {
    const user = userEvent.setup()
    const { router } = await renderActions({ canEdit: false })
    await screen.findByRole('button', { name: 'After row' })
    await user.click(screen.getByRole('button', { name: 'More actions for QA North Office' }))
    await user.click(screen.getByRole('menuitem', { name: 'View details for QA North Office' }))

    expect(
      await screen.findByRole('heading', { name: 'Branch details loaded' }),
    ).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/company/branch/44')
  })

  it('does not render controls when neither action is permitted', async () => {
    await renderActions({ canView: false, canEdit: false })
    expect(screen.getByRole('button', { name: 'After row' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /more actions/i })).not.toBeInTheDocument()
  })
})
