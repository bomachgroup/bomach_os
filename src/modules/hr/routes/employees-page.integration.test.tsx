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
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { branchesApi } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import { rolesApi } from '@/modules/company/roles.api'
import { employeesApi, type EmployeeDto } from '@/modules/hr/employees.api'
import { validateEmployeesSearch } from '@/modules/hr/employees.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { ToastContext } from '@/shared/feedback/toast-context'

import { EmployeesPage } from './employees-page'

const showToast = vi.fn()
let queryClient: QueryClient

const employee: EmployeeDto = {
  id: 31,
  user_id: 7,
  employee_id: 'EMP-031',
  username: 'amina.ademola',
  email: 'amina@example.test',
  first_name: 'Amina',
  middle_name: '',
  last_name: 'Ademola',
  gender: 'female',
  marital_status: 'single',
  nationality: 'Nigerian',
  phone_number: null,
  other_phone: null,
  personal_email: null,
  date_of_birth: null,
  address: null,
  city: '',
  state: '',
  zip_code: '',
  country: '',
  profile_picture: null,
  is_active: true,
  employment_is_active: true,
  account_is_active: true,
  emergency_contact_name: '',
  emergency_contact_relationship: '',
  emergency_contact_phone: '',
  designation: 'Operations Analyst',
  employment_type: 'full-time',
  employment_status: 'active',
  branch_id: null,
  branch_name: null,
  department_id: null,
  department_name: 'Operations',
  department_units: [],
  role_id: null,
  role_name: null,
  location: '',
  reporting_to_id: null,
  start_date: null,
  probation_period: null,
  work_schedule: '',
  gross_salary: null,
  salary_frequency: 'monthly',
  allowances: null,
  bank_name: '',
  account_number: '',
  tax_id: '',
  pension_number: '',
  pfa_provider: '',
  rsa_number: '',
  employer_contribution: null,
  hmo_current_plan: '',
  hmo_id_number: '',
  hmo_dependents_covered: 0,
}

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'hr-admin@example.test',
    username: 'hr-admin',
    first_name: 'HR',
    last_name: 'Admin',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: { employees: ['list', 'create', 'update', 'exit', 'view'] },
  },
  employee: {
    id: 19,
    user_id: 9,
    employee_id: 'EMP-009',
    username: 'hr-admin',
    email: 'hr-admin@example.test',
    first_name: 'HR',
    last_name: 'Admin',
  },
  roles: [],
  permissions: { employees: ['list', 'create', 'update', 'exit', 'view'] },
}

function renderEmployees(path = '/hr/employees?search=&page=1&view=active&pageSize=10') {
  queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const employeesRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/hr/employees',
    validateSearch: validateEmployeesSearch,
    component: EmployeesPage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([employeesRoute])]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })
  return render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(
        ToastContext.Provider,
        { value: { showToast, dismissToast: vi.fn() } },
        createElement(RouterProvider, { router }),
      ),
    ) as ReactNode,
  )
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

beforeEach(() => {
  vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(rolesApi, 'list').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 1, items: [employee] })
  vi.spyOn(employeesApi, 'create').mockResolvedValue(employee)
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
  showToast.mockReset()
})

async function completeRequiredEmployeeFields(user: ReturnType<typeof userEvent.setup>) {
  await user.type(screen.getByLabelText(/^First name/), 'Chika')
  await user.type(screen.getByLabelText(/^Last name/), 'Nwosu')
  await user.type(screen.getByLabelText(/^Work email/), 'chika.nwosu@example.test')
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.type(screen.getByLabelText(/^Job title/), 'People Analyst')
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.click(screen.getByRole('button', { name: 'Review details' }))
}

describe('Employees page', () => {
  it('loads the directory and keeps URL-driven pagination and page size in sync', async () => {
    vi.mocked(employeesApi.list).mockResolvedValue({ count: 12, items: [employee] })
    const user = userEvent.setup()
    renderEmployees()

    expect(await screen.findByText('Amina Ademola')).toBeVisible()
    const results = screen.getByRole('region', { name: 'Employee results' })
    expect(results.firstElementChild).toHaveClass('grid-cols-1', 'desktop:grid-cols-2')
    expect(screen.getByText('Showing 1–10 of 12 employees')).toBeVisible()
    expect(employeesApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 10, offset: 0, view: 'active' }),
      expect.any(AbortSignal),
    )

    await user.click(screen.getByRole('combobox', { name: /Rows per page/ }))
    await user.click(await screen.findByRole('option', { name: '5' }))
    expect(employeesApi.list).toHaveBeenLastCalledWith(
      expect.objectContaining({ limit: 5, offset: 0 }),
      expect.any(AbortSignal),
    )

    await user.click(screen.getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(employeesApi.list).toHaveBeenLastCalledWith(
        expect.objectContaining({ limit: 5, offset: 5 }),
        expect.any(AbortSignal),
      ),
    )
  })

  it('shows a retryable directory error and recovers without losing the page', async () => {
    vi.mocked(employeesApi.list)
      .mockRejectedValueOnce(new Error('Directory unavailable.'))
      .mockResolvedValueOnce({ count: 1, items: [employee] })
    const user = userEvent.setup()
    renderEmployees()

    expect(await screen.findByRole('button', { name: 'Try again' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('Amina Ademola')).toBeVisible()
  })

  it('switches active and past views and applies branch and department filters', async () => {
    vi.mocked(branchesApi.list).mockResolvedValue({
      count: 1,
      items: [{ id: 3, branch_name: 'Lagos HQ' } as never],
    })
    vi.mocked(companyOrganizationApi.departments).mockResolvedValue({
      count: 1,
      items: [{ id: 8, name: 'Operations' } as never],
    })
    const user = userEvent.setup()
    renderEmployees()
    await screen.findByText('Amina Ademola')

    const pastTab = screen.getByRole('tab', { name: /Past employees/ })
    await user.click(pastTab)
    await waitFor(() =>
      expect(employeesApi.list).toHaveBeenLastCalledWith(
        expect.objectContaining({ view: 'past', offset: 0 }),
        expect.any(AbortSignal),
      ),
    )
    expect(pastTab).toHaveAttribute('aria-selected', 'true')

    await user.click(screen.getByRole('combobox', { name: /Branch/ }))
    await user.click(await screen.findByRole('option', { name: 'Lagos HQ' }))
    await waitFor(() =>
      expect(employeesApi.list).toHaveBeenLastCalledWith(
        expect.objectContaining({ view: 'past', branchId: '3' }),
        expect.any(AbortSignal),
      ),
    )

    await user.click(screen.getByRole('combobox', { name: /Department/ }))
    await user.click(await screen.findByRole('option', { name: 'Operations' }))
    await waitFor(() =>
      expect(employeesApi.list).toHaveBeenLastCalledWith(
        expect.objectContaining({ view: 'past', branchId: '3', departmentId: '8' }),
        expect.any(AbortSignal),
      ),
    )
  })

  it('creates an employee and reports success after the API accepts the request', async () => {
    vi.mocked(employeesApi.create).mockResolvedValue({
      ...employee,
      user_id: 42,
      employee_id: 'EMP-042',
      first_name: 'Chika',
      last_name: 'Nwosu',
      email: 'chika.nwosu@example.test',
      designation: 'People Analyst',
    })
    const user = userEvent.setup()
    renderEmployees()

    await screen.findByText('Amina Ademola')
    await user.click(screen.getByRole('button', { name: 'Add employee' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add employee' })
    await completeRequiredEmployeeFields(user)
    await user.click(within(dialog).getByRole('button', { name: 'Create employee' }))

    await waitFor(() =>
      expect(employeesApi.create).toHaveBeenCalledWith(
        expect.objectContaining({
          first_name: 'Chika',
          last_name: 'Nwosu',
          email: 'chika.nwosu@example.test',
          designation: 'People Analyst',
        }),
      ),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ tone: 'success', title: 'Employee added' }),
      ),
    )
    await waitFor(() =>
      expect(screen.queryByRole('dialog', { name: 'Add employee' })).not.toBeInTheDocument(),
    )
  })

  it('keeps the create form open with entered values when the API rejects the request', async () => {
    vi.mocked(employeesApi.create).mockRejectedValue(
      new ApiError('A user with this email already exists.', { status: 400 }),
    )
    const user = userEvent.setup()
    renderEmployees()

    await screen.findByText('Amina Ademola')
    await user.click(screen.getByRole('button', { name: 'Add employee' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add employee' })
    await completeRequiredEmployeeFields(user)
    await user.click(within(dialog).getByRole('button', { name: 'Create employee' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'A user with this email already exists.',
    )
    await user.click(within(dialog).getByRole('button', { name: 'Back' }))
    await user.click(within(dialog).getByRole('button', { name: 'Back' }))
    expect(within(dialog).getByLabelText(/^Job title/)).toHaveValue('People Analyst')
    await user.click(within(dialog).getByRole('button', { name: 'Back' }))
    await user.click(within(dialog).getByRole('button', { name: 'Back' }))
    expect(within(dialog).getByLabelText(/^Work email/)).toHaveValue('chika.nwosu@example.test')
    expect(within(dialog).getByRole('button', { name: 'Continue' })).toBeEnabled()
  }, 10_000)
})
