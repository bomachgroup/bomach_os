import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { search: '', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return { ...actual, useSearch: () => routeState.search, useNavigate: () => routeState.navigate }
})

import {
  kpiManagementApi,
  type KpiMetricDto,
  type RoleKpiDto,
} from '@/modules/company/kpi-management.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { ToastContext } from '@/shared/feedback/toast-context'

import { KpiManagementPage } from './kpi-management-page'

const metric: KpiMetricDto = {
  id: 31,
  name: 'Client follow-ups completed',
  description: 'Completed customer follow-ups.',
  unit: 'count',
}

const roleKpi: RoleKpiDto = {
  id: 61,
  role_id: 7,
  metric_id: metric.id,
  metric,
  tracking_mode: 'manual',
  target_value: '25',
  weight: '20',
  period: 'monthly',
  sequence: 1,
  is_active: true,
  created_at: '2026-10-01T09:00:00Z',
  updated_at: '2026-10-01T09:00:00Z',
}

const roles = [{ id: 7, name: 'Client Relations Officer' }]
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

function makeSession(permissions: AuthenticatedSession['permissions']): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'kpi-admin@example.test',
      username: 'kpi-admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'kpi-admin',
      email: 'kpi-admin@example.test',
    },
    roles: [],
    permissions,
  }
}

const fullPermissions = {
  role_kpis: ['list', 'create', 'update', 'delete'],
  roles: ['list'],
  kpis: ['list', 'create'],
}

function renderPage(
  permissions: AuthenticatedSession['permissions'] = fullPermissions,
  initialSearch = { search: '', page: 1 },
) {
  routeState.search = initialSearch
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession(permissions))
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <KpiManagementPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('KpiManagementPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    showToast.mockReset()
    routeState.navigate.mockReset()
    routeState.search = { search: '', page: 1 }
    vi.spyOn(kpiManagementApi, 'list').mockResolvedValue({ count: 1, items: [roleKpi] })
    vi.spyOn(kpiManagementApi, 'roles').mockResolvedValue(roles)
    vi.spyOn(kpiManagementApi, 'metrics').mockResolvedValue([metric])
    vi.spyOn(kpiManagementApi, 'roleAssignments').mockResolvedValue([])
    vi.spyOn(kpiManagementApi, 'create').mockResolvedValue({ ...roleKpi, id: 62 })
    vi.spyOn(kpiManagementApi, 'update').mockResolvedValue({ ...roleKpi, target_value: '30' })
    vi.spyOn(kpiManagementApi, 'remove').mockResolvedValue({
      detail: 'Role KPI deleted successfully.',
    })
    vi.spyOn(kpiManagementApi, 'createMetric').mockResolvedValue({
      ...metric,
      id: 32,
      name: 'New QA metric',
    })
  })

  afterEach(() => queryClient?.clear())

  it('renders role KPI details in a responsive card and gates unavailable actions', async () => {
    const { container } = renderPage({ role_kpis: ['list'], roles: ['list'] })

    expect(await screen.findByRole('heading', { name: metric.name })).toBeInTheDocument()
    const assignmentHeading = screen.getByRole('heading', { name: metric.name })
    const assignmentGrid = Array.from(
      container.querySelectorAll('[class~="tablet:grid-cols-2"]'),
    ).find((grid) => grid.contains(assignmentHeading))
    expect(assignmentGrid).toBeInTheDocument()
    expect(assignmentGrid).not.toHaveClass('desktop:grid-cols-3')
    expect(await screen.findByText('Client Relations Officer')).toBeInTheDocument()
    expect(screen.getByText('25 count')).toBeInTheDocument()
    expect(screen.getByText('Monthly')).toBeInTheDocument()
    expect(screen.getByText('Active')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Add KPI' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
  })

  it('keeps the create action on the page title row and removes the redundant explainer', async () => {
    renderPage()

    const pageTitle = screen.getByRole('heading', { name: 'KPI Management' })
    const pageAction = screen.getByRole('button', { name: 'Add KPI' })
    expect(pageTitle.parentElement?.parentElement).toBe(pageAction.parentElement?.parentElement)
    expect(
      screen.queryByText(/Set shared measures, targets, and review periods/),
    ).not.toBeInTheDocument()
    expect(await screen.findByRole('heading', { name: metric.name })).toBeInTheDocument()
  })

  it('opens the editor and preserves client validation before a create request', async () => {
    const user = userEvent.setup()
    renderPage()
    await user.click(await screen.findByRole('button', { name: 'Add KPI' }))

    const dialog = await screen.findByRole('dialog', { name: 'Add KPI' })
    await user.click(within(dialog).getByRole('combobox', { name: 'Role' }))
    await user.click(await screen.findByRole('option', { name: 'Client Relations Officer' }))
    await user.click(within(dialog).getByRole('combobox', { name: 'Shared metric' }))
    await user.click(await screen.findByRole('option', { name: /Client follow-ups completed/ }))
    await user.type(within(dialog).getByLabelText(/Target value/), '-1')
    await user.click(within(dialog).getByRole('button', { name: 'Add KPI' }))
    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Target value must be a number greater than or equal to zero.',
    )

    await user.clear(within(dialog).getByLabelText(/Target value/))
    await user.type(within(dialog).getByLabelText('Weight'), '101')
    await user.click(within(dialog).getByRole('button', { name: 'Add KPI' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Weight must be a number between 0 and 100.',
    )
    expect(kpiManagementApi.create).not.toHaveBeenCalled()
    expect(dialog).toBeInTheDocument()
  })

  it('keeps a duplicate assignment error in the open form and does not announce success', async () => {
    vi.spyOn(kpiManagementApi, 'create').mockRejectedValue(
      new ApiError('This metric is already assigned to the role.', { status: 409 }),
    )
    const user = userEvent.setup()
    renderPage()
    await user.click(await screen.findByRole('button', { name: 'Add KPI' }))

    const dialog = await screen.findByRole('dialog', { name: 'Add KPI' })
    await user.click(within(dialog).getByRole('combobox', { name: 'Role' }))
    await user.click(await screen.findByRole('option', { name: 'Client Relations Officer' }))
    await user.click(within(dialog).getByRole('combobox', { name: 'Shared metric' }))
    await user.click(await screen.findByRole('option', { name: /Client follow-ups completed/ }))
    await user.click(within(dialog).getByRole('button', { name: 'Add KPI' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'This metric is already assigned to this role. Choose another metric or edit the existing assignment.',
    )
    expect(dialog).toBeInTheDocument()
    expect(showToast).not.toHaveBeenCalled()
  })

  it('creates a shared metric from the nested dialog and selects it for the assignment', async () => {
    const user = userEvent.setup()
    renderPage()
    await user.click(await screen.findByRole('button', { name: 'Add KPI' }))
    const editor = await screen.findByRole('dialog', { name: 'Add KPI' })
    await user.click(within(editor).getByRole('combobox', { name: 'Role' }))
    await user.click(await screen.findByRole('option', { name: 'Client Relations Officer' }))
    await user.click(within(editor).getByRole('button', { name: 'Create metric' }))

    const metricDialog = await screen.findByRole('dialog', { name: 'Create shared metric' })
    expect(metricDialog.className).toContain('max-h-[calc(100dvh-2rem)]')
    expect(within(metricDialog).queryByRole('textbox', { name: 'Unit' })).not.toBeInTheDocument()
    await user.type(within(metricDialog).getByLabelText(/Metric name/), 'New QA metric')
    await user.click(within(metricDialog).getByRole('combobox', { name: 'Unit' }))
    for (const unit of ['Percentage', 'Count', 'Currency', 'Rating']) {
      expect(await screen.findByRole('option', { name: unit })).toBeInTheDocument()
    }
    await user.click(await screen.findByRole('option', { name: 'Count' }))
    await user.click(within(metricDialog).getByRole('button', { name: 'Create metric' }))

    expect(await screen.findByRole('dialog', { name: 'Add KPI' })).toBeInTheDocument()
    expect(kpiManagementApi.createMetric).toHaveBeenCalled()
    expect(vi.mocked(kpiManagementApi.createMetric).mock.calls[0]?.[0]).toEqual({
      name: 'New QA metric',
      unit: 'count',
      description: '',
    })
    expect(within(editor).getByRole('combobox', { name: 'Shared metric' })).toHaveTextContent(
      'New QA metric',
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Shared metric created' }),
    )
  })

  it('updates and removes an assignment with success feedback', async () => {
    const user = userEvent.setup()
    renderPage()
    await screen.findByRole('heading', { name: metric.name })
    await user.click(screen.getByRole('button', { name: 'Edit' }))
    const editor = await screen.findByRole('dialog', { name: 'Edit KPI' })
    await user.click(within(editor).getByText('Assignment settings'))
    const activeToggle = within(editor).getByRole('checkbox', { name: /Active for this role/ })
    await user.click(activeToggle)
    expect(activeToggle).not.toBeChecked()
    expect(routeState.navigate).not.toHaveBeenCalled()
    await user.clear(within(editor).getByLabelText(/Target value/))
    await user.type(within(editor).getByLabelText(/Target value/), '30')
    await user.click(within(editor).getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(kpiManagementApi.update).toHaveBeenCalledWith(
        7,
        roleKpi.id,
        expect.objectContaining({ is_active: false, target_value: 30 }),
      ),
    )
    expect(routeState.navigate).not.toHaveBeenCalled()
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'KPI updated' }))

    await user.click(await screen.findByRole('button', { name: 'Remove' }))
    const confirmation = await screen.findByRole('dialog', { name: 'Remove KPI from role?' })
    expect(confirmation).toHaveClass('max-h-[calc(100dvh-2rem)]', '-translate-y-1/2')
    expect(confirmation.querySelector(':scope > div.min-h-0.overflow-y-auto')).toHaveClass(
      'flex-auto',
    )
    expect(
      within(confirmation).getByText(/historical employee KPI data will remain/),
    ).toBeInTheDocument()
    await user.click(within(confirmation).getByRole('button', { name: 'Remove from role' }))

    await waitFor(() => expect(kpiManagementApi.remove).toHaveBeenCalledWith(7, roleKpi.id))
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'KPI removed' }))
  })

  it('keeps a failed removal confirmation open and shows a safe permission error', async () => {
    vi.spyOn(kpiManagementApi, 'remove').mockRejectedValue(
      new ApiError('Forbidden', { status: 403 }),
    )
    const user = userEvent.setup()
    renderPage()
    await screen.findByRole('heading', { name: metric.name })
    await user.click(screen.getByRole('button', { name: 'Remove' }))
    const confirmation = await screen.findByRole('dialog', { name: 'Remove KPI from role?' })
    await user.click(within(confirmation).getByRole('button', { name: 'Remove from role' }))

    expect(await within(confirmation).findByRole('alert')).toHaveTextContent(
      'You do not have permission to complete this action.',
    )
    expect(confirmation).toBeInTheDocument()
    expect(showToast).not.toHaveBeenCalled()
  })

  it('keeps a failed active-state save in the editor without navigating away', async () => {
    vi.spyOn(kpiManagementApi, 'update').mockRejectedValue(
      new ApiError('The assignment could not be updated.', { status: 400 }),
    )
    const user = userEvent.setup()
    renderPage()
    await screen.findByRole('heading', { name: metric.name })
    await user.click(screen.getByRole('button', { name: 'Edit' }))

    const editor = await screen.findByRole('dialog', { name: 'Edit KPI' })
    await user.click(within(editor).getByText('Assignment settings'))
    await user.click(within(editor).getByRole('checkbox', { name: /Active for this role/ }))
    await user.click(within(editor).getByRole('button', { name: 'Save changes' }))

    expect(await within(editor).findByRole('alert')).toHaveTextContent(
      'The assignment could not be updated.',
    )
    expect(editor).toBeInTheDocument()
    expect(routeState.navigate).not.toHaveBeenCalled()
    expect(kpiManagementApi.update).toHaveBeenCalledWith(
      7,
      roleKpi.id,
      expect.objectContaining({ is_active: false }),
    )
  })

  it('does not expose create without the role list needed to select an assignment target', async () => {
    renderPage({ role_kpis: ['list', 'create'], kpis: ['list'] })

    await screen.findByRole('heading', { name: metric.name })
    expect(screen.queryByRole('button', { name: 'Add KPI' })).not.toBeInTheDocument()
  })

  it('shows a retry state when the initial assignment list fails', async () => {
    vi.spyOn(kpiManagementApi, 'list').mockRejectedValueOnce(
      new ApiError('Unavailable', { status: 503 }),
    )
    renderPage()
    expect(await screen.findByText('Service temporarily unavailable')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument()
  })

  it('shows an empty-search state and keeps the URL-backed search behavior', async () => {
    vi.spyOn(kpiManagementApi, 'list').mockResolvedValue({ count: 0, items: [] })
    renderPage(fullPermissions, { search: 'no match', page: 1 })

    expect(await screen.findByRole('heading', { name: 'No matching KPIs' })).toBeInTheDocument()
    expect(screen.getByText(/Try another metric name or description/)).toBeInTheDocument()
  })
})
