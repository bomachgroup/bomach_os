import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import {
  companyOrganizationApi,
  type DepartmentDto,
  type DepartmentUnitDto,
  type ReportingChartDto,
} from '@/modules/company/company-organization.api'
import { complianceQueryKeys } from '@/modules/company/governance.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateDepartmentSearch, validateOrgChartSearch } from '../company-organization.search'
import { DepartmentsUnitsPage } from './departments-units-page'
import { OrgChartPage } from './org-chart-page'

const showToast = vi.fn()
let queryClient: QueryClient

const department: DepartmentDto = {
  id: 1,
  name: 'operations',
  description: 'Coordinates day-to-day work.',
}

const departmentPage = { count: 1, items: [department] }
const choices = {
  items: [
    { value: 'operations', label: 'Operations' },
    { value: 'finance', label: 'Finance' },
    { value: 'hr', label: 'Human Resources' },
  ],
}

const unit: DepartmentUnitDto = {
  id: 7,
  name: 'Field team',
  department_id: 1,
  department_name: 'operations',
  description: 'Local field support.',
}

function session(permissions: AuthenticatedSession['permissions']): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'org-admin@example.test',
      username: 'org-admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'org-admin',
      email: 'org-admin@example.test',
    },
    roles: [],
    permissions,
  }
}

function renderOrganizationRoute(path: string, permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const departmentsRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/department',
    validateSearch: validateDepartmentSearch,
    component: DepartmentsUnitsPage,
  })
  const orgChartRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/org-chart',
    validateSearch: validateOrgChartSearch,
    component: OrgChartPage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([departmentsRoute, orgChartRoute])]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })
  const result = render(
    createElement(
      ToastContext.Provider,
      { value: { showToast, dismissToast: vi.fn() } },
      createElement(
        QueryClientProvider,
        { client: queryClient },
        createElement(RouterProvider, { router }),
      ),
    ) as ReactNode,
  )
  return { ...result, router }
}

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

describe('company organization pages', () => {
  beforeEach(() => {
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue(departmentPage)
    vi.spyOn(companyOrganizationApi, 'departmentChoices').mockResolvedValue(choices)
    vi.spyOn(companyOrganizationApi, 'units').mockResolvedValue({ count: 1, items: [unit] })
    vi.spyOn(companyOrganizationApi, 'createDepartment').mockImplementation(async (input) => ({
      id: 2,
      ...input,
    }))
    vi.spyOn(companyOrganizationApi, 'updateDepartment').mockResolvedValue(department)
    vi.spyOn(companyOrganizationApi, 'createUnit').mockResolvedValue(unit)
    vi.spyOn(companyOrganizationApi, 'updateUnit').mockResolvedValue(unit)
    vi.spyOn(companyOrganizationApi, 'reportingChart').mockResolvedValue({
      roles: [],
      scopes: [
        {
          key: 'company',
          label: 'Company-wide',
          branch_id: null,
          branch: null,
          department_id: null,
          department: null,
          unit_id: null,
          unit: null,
          role_ids: [],
          reporting_lines: [],
        },
      ],
    } satisfies ReportingChartDto)
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
    showToast.mockReset()
  })

  it('shows department descriptions and saves a supported category through the department endpoint', async () => {
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list', 'create', 'update'],
      department_units: ['list'],
    })
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries')

    expect(await screen.findAllByText('Coordinates day-to-day work.')).toHaveLength(2)
    expect(screen.getByRole('group', { name: 'Organization catalog view' })).toHaveClass(
      'w-full',
      'grid-cols-2',
    )
    await user.click(screen.getByRole('button', { name: 'Add department' }))
    const dialog = screen.getByRole('dialog', { name: 'Add department' })
    await user.click(within(dialog).getByRole('combobox', { name: 'Department category' }))
    await user.click(await screen.findByRole('option', { name: 'Finance' }))
    await user.type(within(dialog).getByLabelText('Description'), 'Owns budgeting and controls.')
    await user.click(within(dialog).getByRole('button', { name: 'Save department' }))

    await waitFor(() =>
      expect(companyOrganizationApi.createDepartment).toHaveBeenCalledWith({
        name: 'finance',
        description: 'Owns budgeting and controls.',
      }),
    )
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: complianceQueryKeys.departments(7, 'EMP-007'),
    })
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Department added' }))
  })

  it('updates department details and confirms the save', async () => {
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list', 'update'],
    })
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries')

    await user.click(await screen.findByRole('button', { name: 'Edit Operations department' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit department' })
    const description = within(dialog).getByLabelText(/^Description$/)
    await user.clear(description)
    await user.type(description, 'Coordinates regional operations.')
    await user.click(within(dialog).getByRole('button', { name: 'Save department' }))

    await waitFor(() =>
      expect(companyOrganizationApi.updateDepartment).toHaveBeenCalledWith(1, {
        name: 'operations',
        description: 'Coordinates regional operations.',
      }),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Department saved' }),
      ),
    )
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: complianceQueryKeys.departments(7, 'EMP-007'),
    })
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: complianceQueryKeys.lists(7, 'EMP-007'),
    })
    expect(screen.queryByRole('dialog', { name: 'Edit department' })).not.toBeInTheDocument()
  })

  it('explains when all supported department categories are already in use', async () => {
    const allCategories: DepartmentDto[] = [
      'operations',
      'marketing',
      'finance',
      'it',
      'hr',
      'legal',
    ].map((name, index) => ({ id: index + 1, name, description: '' }))
    vi.mocked(companyOrganizationApi.departments).mockResolvedValue({
      count: allCategories.length,
      items: allCategories,
    })
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list', 'create'],
    })

    await user.click(await screen.findByRole('button', { name: 'Add department' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add department' })
    expect(
      within(dialog).getByText(/All supported department categories are already in use/),
    ).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Save department' })).toBeDisabled()
  })

  it('does not show a zero department count before the first result loads', () => {
    vi.mocked(companyOrganizationApi.departments).mockReturnValue(
      new Promise<typeof departmentPage>(() => undefined),
    )
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list'],
    })

    expect(screen.queryByText('0 saved department categories')).not.toBeInTheDocument()
  })

  it('shows friendly feedback when the API rejects a duplicate department category', async () => {
    vi.mocked(companyOrganizationApi.createDepartment).mockRejectedValue(
      new ApiError('__all__: %(model_name)s with this %(field_labels)s already exists.', {
        status: 400,
        fieldErrors: {
          __all__: ['%(model_name)s with this %(field_labels)s already exists.'],
        },
      }),
    )
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list', 'create'],
    })

    await user.click(await screen.findByRole('button', { name: 'Add department' }))
    const dialog = screen.getByRole('dialog', { name: 'Add department' })
    await user.click(within(dialog).getByRole('combobox', { name: 'Department category' }))
    await user.click(await screen.findByRole('option', { name: 'Finance' }))
    await user.click(within(dialog).getByRole('button', { name: 'Save department' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'That department category already exists.',
    )
    expect(within(dialog).queryByText(/%\(model_name\)s/)).not.toBeInTheDocument()
  })

  it('recovers an out-of-range department page to the last available page', async () => {
    vi.mocked(companyOrganizationApi.departments).mockImplementation(async (params) => ({
      count: 11,
      items:
        params.offset === 10
          ? [{ id: 2, name: 'marketing', description: 'Brand and communications.' }]
          : [],
    }))
    const { router } = renderOrganizationRoute('/company/department?tab=departments&page=99', {
      departments: ['list', 'update'],
    })

    expect(await screen.findAllByText('Marketing')).toHaveLength(2)
    await waitFor(() => expect(router.state.location.search.page).toBe(2))
    expect(companyOrganizationApi.departments).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 980 }),
      expect.anything(),
    )
    expect(companyOrganizationApi.departments).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 10 }),
      expect.anything(),
    )
  })

  it('normalizes malformed unit department filters before requesting the API', async () => {
    const { router } = renderOrganizationRoute(
      '/company/department?tab=units&departmentId=not-a-number&page=1',
      { departments: ['list'], department_units: ['list'] },
    )

    expect(await screen.findAllByText('Field team')).toHaveLength(2)
    await waitFor(() => expect(router.state.location.search.departmentId).toBe('all'))
    expect(companyOrganizationApi.units).toHaveBeenCalledWith(
      expect.objectContaining({ departmentId: null }),
      expect.anything(),
    )
  })

  it('gives desktop edit actions record-specific accessible names', async () => {
    renderOrganizationRoute('/company/department?tab=departments', {
      departments: ['list', 'update'],
    })

    expect(
      await screen.findByRole('button', { name: 'Edit Operations department' }),
    ).toBeInTheDocument()
  })

  it('filters units by department and persists a unit with its parent and description', async () => {
    const user = userEvent.setup()
    const { router } = renderOrganizationRoute(
      '/company/department?tab=units&departmentId=all&page=1',
      { departments: ['list'], department_units: ['list', 'create', 'update'] },
    )

    expect(await screen.findAllByText('Field team')).toHaveLength(2)
    await user.click(screen.getByRole('button', { name: 'Add unit' }))
    const dialog = screen.getByRole('dialog', { name: 'Add unit' })
    await user.type(within(dialog).getByLabelText(/Unit name/), 'Customer care')
    await user.click(within(dialog).getByRole('combobox', { name: 'Parent department' }))
    await user.click(await screen.findByRole('option', { name: 'Operations' }))
    const descriptionField = within(dialog).getByLabelText(/^Description$/)
    fireEvent.change(descriptionField, { target: { value: 'Handles customer requests.' } })
    expect(descriptionField).toHaveValue('Handles customer requests.')
    await user.click(within(dialog).getByRole('button', { name: 'Save unit' }))

    await waitFor(() =>
      expect(companyOrganizationApi.createUnit).toHaveBeenCalledWith({
        name: 'Customer care',
        department_id: 1,
        description: 'Handles customer requests.',
      }),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Unit added' })),
    )
    expect(router.state.location.search).toMatchObject({ tab: 'units', departmentId: 'all' })
  })

  it('updates a unit and confirms the save', async () => {
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=units&departmentId=all&page=1', {
      departments: ['list'],
      department_units: ['list', 'update'],
    })

    await user.click((await screen.findAllByRole('button', { name: 'Edit Field team' }))[0]!)
    const dialog = screen.getByRole('dialog', { name: 'Edit unit' })
    const description = within(dialog).getByLabelText(/^Description$/)
    await user.clear(description)
    await user.type(description, 'Supports regional field operations.')
    await user.click(within(dialog).getByRole('button', { name: 'Save unit' }))

    await waitFor(() =>
      expect(companyOrganizationApi.updateUnit).toHaveBeenCalledWith(7, {
        name: 'Field team',
        department_id: 1,
        description: 'Supports regional field operations.',
      }),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Unit saved' })),
    )
    expect(screen.queryByRole('dialog', { name: 'Edit unit' })).not.toBeInTheDocument()
  })

  it('shows friendly feedback when the API rejects a duplicate unit name', async () => {
    vi.mocked(companyOrganizationApi.createUnit).mockRejectedValue(
      new ApiError('__all__: %(model_name)s with this %(field_labels)s already exists.', {
        status: 400,
        fieldErrors: {
          __all__: ['%(model_name)s with this %(field_labels)s already exists.'],
        },
      }),
    )
    const user = userEvent.setup()
    renderOrganizationRoute('/company/department?tab=units&departmentId=all&page=1', {
      departments: ['list'],
      department_units: ['list', 'create'],
    })

    await user.click(await screen.findByRole('button', { name: 'Add unit' }))
    const dialog = screen.getByRole('dialog', { name: 'Add unit' })
    await user.type(within(dialog).getByLabelText(/Unit name/), 'Field team')
    await user.click(within(dialog).getByRole('combobox', { name: 'Parent department' }))
    await user.click(await screen.findByRole('option', { name: 'Operations' }))
    await user.click(within(dialog).getByRole('button', { name: 'Save unit' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'A unit with this name already exists in the selected department.',
    )
    expect(within(dialog).queryByText(/%\(model_name\)s/)).not.toBeInTheDocument()
    expect(companyOrganizationApi.createUnit).toHaveBeenCalledWith({
      name: 'Field team',
      department_id: 1,
      description: '',
    })

    await user.clear(within(dialog).getByLabelText(/Unit name/))
    await user.type(within(dialog).getByLabelText(/Unit name/), 'Customer support')
    expect(within(dialog).queryByRole('alert')).not.toBeInTheDocument()
  })

  it('keeps units readable without department-list access and withholds parent-dependent actions', async () => {
    renderOrganizationRoute('/company/department?tab=units', {
      department_units: ['list', 'create', 'update'],
    })

    expect(await screen.findAllByText('Field team')).toHaveLength(2)
    expect(screen.getByText('Department restricted')).toBeInTheDocument()
    expect(
      screen.getByText(/Department list access is needed to choose or verify a unit’s parent/),
    ).toBeInTheDocument()
    expect(screen.getByRole('group', { name: 'Organization catalog view' })).toHaveClass(
      'grid-cols-1',
    )
    expect(screen.queryByRole('button', { name: 'Add unit' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit Field team' })).not.toBeInTheDocument()
  })

  it('renders role positions without allowing relationship editing', async () => {
    const chart: ReportingChartDto = {
      roles: [
        { id: 1, name: 'Operations Lead' },
        { id: 2, name: 'Field Officer' },
        { id: 3, name: 'QA Role Preview: Senior Access Analyst With a Long Reporting Scope Name' },
      ],
      scopes: [
        {
          key: 'company',
          label: 'Company-wide',
          branch_id: null,
          branch: null,
          department_id: null,
          department: null,
          unit_id: null,
          unit: null,
          role_ids: [1, 2, 3],
          reporting_lines: [
            {
              id: 3,
              role_id: 2,
              role: { id: 2, name: 'Field Officer' },
              reports_to_role_id: 1,
              reports_to_role: { id: 1, name: 'Operations Lead' },
              relationship_type: 'direct',
              branch_id: null,
              branch: null,
              department_id: null,
              department: null,
              unit_id: null,
              unit: null,
              sequence: 1,
              is_active: true,
              created_at: '2026-01-01T00:00:00Z',
              updated_at: '2026-01-01T00:00:00Z',
            },
          ],
        },
      ],
    }
    vi.mocked(companyOrganizationApi.reportingChart).mockResolvedValue(chart)
    renderOrganizationRoute('/company/org-chart?scope=company', {
      roles: ['list'],
      role_reporting_lines: ['list'],
    })

    expect(await screen.findByRole('heading', { name: 'Operations Lead' })).toBeInTheDocument()
    expect(screen.getAllByRole('heading', { name: 'Field Officer' })).toHaveLength(1)
    expect(
      screen.getByRole('heading', {
        name: 'QA Role Preview: Senior Access Analyst With a Long Reporting Scope Name',
      }),
    ).not.toHaveClass('truncate')
    expect(screen.getByText('Role positions')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /edit|add|create/i })).not.toBeInTheDocument()
  })
})
