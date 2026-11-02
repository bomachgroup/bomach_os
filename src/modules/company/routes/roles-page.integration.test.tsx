import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
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

import { branchesApi } from '@/modules/company/branches.api'
import { rolesApi, type RoleDto } from '@/modules/company/roles.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateRolesSearch } from '@/modules/company/roles.search'
import { RolesPage } from './roles-page'

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

const role: RoleDto = {
  id: 6,
  name: 'Operations Coordinator',
  branches: [],
  permissions: { employees: ['view'] },
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-02T00:00:00Z',
}

const permissions = {
  roles: ['view', 'create', 'update'],
  role_descriptions: ['view', 'create', 'update'],
}

async function chooseDropdownOption(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  optionName: RegExp,
) {
  await user.click(screen.getByRole('combobox', { name: new RegExp(`^${label}`) }))
  await user.click(await screen.findByRole('option', { name: optionName }))
}

function makeSession(): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'admin@example.test',
      username: 'admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'admin',
      email: 'admin@example.test',
    },
    roles: [],
    permissions,
  }
}

function renderRolesPage() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession())
  const rootRoute = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const rolesRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/roles',
    validateSearch: validateRolesSearch,
    component: RolesPage,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([protectedRoute.addChildren([rolesRoute])]),
    history: createMemoryHistory({
      initialEntries: ['/company/roles?search=&page=1'],
    }),
  })
  const showToast = vi.fn()
  render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
  return { queryClient, showToast }
}

describe('RolesPage create and edit mutations', () => {
  afterEach(() => vi.restoreAllMocks())

  it('shows a retryable error when the roles API returns an invalid response shape', async () => {
    const list = vi.spyOn(rolesApi, 'list').mockRejectedValue(
      new ApiError('The server returned role data in an unexpected format.', {
        status: 502,
        code: 'INVALID_ROLE_RESPONSE',
      }),
    )
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({ permissions_map: {} })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })

    renderRolesPage()

    await waitFor(() => expect(list).toHaveBeenCalled())
    expect(
      await screen.findByRole('heading', { name: 'Service temporarily unavailable' }),
    ).toBeVisible()
    expect(screen.getByRole('button', { name: 'Try again' })).toBeEnabled()
  })

  it('creates a role only after reviewing it, preserves the draft after a save error, then confirms success', async () => {
    const user = userEvent.setup()
    const { showToast } = renderRolesPage()
    vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: { employees: ['view', 'create'] },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    const create = vi
      .spyOn(rolesApi, 'create')
      .mockRejectedValueOnce(new ApiError('Save conflict', { status: 409 }))
      .mockResolvedValue(role)

    await user.click(await screen.findByRole('button', { name: 'New role' }))
    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Operations Lead')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByRole('textbox', { name: 'Purpose' }), 'Coordinate operations')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await chooseDropdownOption(user, 'Work area', /People/)
    const people = screen.getByRole('region', { name: 'People permissions' })
    await user.click(within(people).getByRole('checkbox', { name: /View/ }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))

    expect(screen.getByRole('heading', { name: 'Review role' })).toBeInTheDocument()
    expect(create).not.toHaveBeenCalled()
    const expectedInput = {
      name: 'Operations Lead',
      branch_ids: [],
      permissions: { employees: ['view'] },
      description: {
        purpose: 'Coordinate operations',
        responsibilities: '',
        job_description: '',
      },
    }
    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() => expect(create).toHaveBeenCalledWith(expectedInput))
    expect(await screen.findByRole('alert')).toHaveTextContent('The record has changed')
    expect(screen.getByRole('heading', { name: 'Operations Lead' })).toBeInTheDocument()
    expect(create).toHaveBeenCalledOnce()

    await user.click(screen.getByRole('button', { name: 'Create role' }))
    await waitFor(() => expect(create).toHaveBeenCalledTimes(2))
    await waitFor(() =>
      expect(screen.queryByRole('dialog', { name: 'Create role' })).not.toBeInTheDocument(),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ tone: 'success', title: 'Role created' }),
    )
  }, 15_000)

  it('updates an existing role and description after the final review confirmation', async () => {
    const user = userEvent.setup()
    const { showToast } = renderRolesPage()
    vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 1, items: [role] })
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: { employees: ['view', 'create'] },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(rolesApi, 'description').mockResolvedValue({
      purpose: 'Coordinate business operations',
      responsibilities: 'Keep teams aligned',
      job_description: '',
    })
    const update = vi.spyOn(rolesApi, 'update').mockResolvedValue({
      ...role,
      name: 'Operations Lead',
    })

    await user.click(await screen.findByRole('button', { name: 'Edit Operations Coordinator' }))
    await user.clear(screen.getByRole('textbox', { name: /Role name/ }))
    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Operations Lead')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.clear(screen.getByRole('textbox', { name: 'Purpose' }))
    await user.type(screen.getByRole('textbox', { name: 'Purpose' }), 'Lead service delivery')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await chooseDropdownOption(user, 'Work area', /People/)
    const people = screen.getByRole('region', { name: 'People permissions' })
    await user.click(within(people).getByRole('checkbox', { name: /Create/ }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))

    expect(screen.getByRole('heading', { name: 'Operations Lead' })).toBeInTheDocument()
    expect(update).not.toHaveBeenCalled()
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(6, {
        name: 'Operations Lead',
        branch_ids: [],
        permissions: { employees: ['create', 'view'] },
        description: {
          purpose: 'Lead service delivery',
          responsibilities: 'Keep teams aligned',
          job_description: '',
        },
      }),
    )
    await waitFor(() =>
      expect(screen.queryByRole('dialog', { name: 'Edit role' })).not.toBeInTheDocument(),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ tone: 'success', title: 'Role updated' }),
    )
  })

  it('keeps an edited role on the review step after a permission error and allows retry', async () => {
    const user = userEvent.setup()
    const { showToast } = renderRolesPage()
    vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 1, items: [role] })
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: { employees: ['view', 'create'] },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(rolesApi, 'description').mockResolvedValue({
      purpose: 'Coordinate business operations',
      responsibilities: 'Keep teams aligned',
      job_description: '',
    })
    const update = vi
      .spyOn(rolesApi, 'update')
      .mockRejectedValueOnce(
        new ApiError('You do not have permission to update this role.', { status: 403 }),
      )
      .mockResolvedValue({ ...role, name: 'Operations Lead' })

    await user.click(await screen.findByRole('button', { name: 'Edit Operations Coordinator' }))
    await user.clear(screen.getByRole('textbox', { name: /Role name/ }))
    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Operations Lead')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Review role' }))

    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'You do not have permission to complete this action.',
    )
    expect(screen.getByRole('heading', { name: 'Review role' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Operations Lead' })).toBeInTheDocument()
    expect(showToast).not.toHaveBeenCalledWith(expect.objectContaining({ tone: 'success' }))

    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() => expect(update).toHaveBeenCalledTimes(2))
    await waitFor(() =>
      expect(screen.queryByRole('dialog', { name: 'Edit role' })).not.toBeInTheDocument(),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ tone: 'success', title: 'Role updated' }),
    )
  })

  it('discards an unsaved edit on cancel and reopens the unchanged role', async () => {
    const user = userEvent.setup()
    renderRolesPage()
    vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 1, items: [role] })
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: { employees: ['view', 'create'] },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(rolesApi, 'description').mockResolvedValue({
      purpose: 'Coordinate business operations',
      responsibilities: 'Keep teams aligned',
      job_description: '',
    })
    const update = vi.spyOn(rolesApi, 'update')

    await user.click(await screen.findByRole('button', { name: 'Edit Operations Coordinator' }))
    await user.clear(screen.getByRole('textbox', { name: /Role name/ }))
    await user.type(screen.getByRole('textbox', { name: /Role name/ }), 'Unsaved role name')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.clear(screen.getByRole('textbox', { name: 'Purpose' }))
    await user.type(screen.getByRole('textbox', { name: 'Purpose' }), 'Unsaved purpose')
    await user.click(screen.getByRole('button', { name: 'Cancel' }))
    await waitFor(() =>
      expect(screen.queryByRole('dialog', { name: 'Edit role' })).not.toBeInTheDocument(),
    )

    await user.click(screen.getByRole('button', { name: 'Edit Operations Coordinator' }))
    expect(screen.getByRole('textbox', { name: /Role name/ })).toHaveValue('Operations Coordinator')
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByRole('textbox', { name: 'Purpose' })).toHaveValue(
      'Coordinate business operations',
    )
    expect(update).not.toHaveBeenCalled()
  })
})
