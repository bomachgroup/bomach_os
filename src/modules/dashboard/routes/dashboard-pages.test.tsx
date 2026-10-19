import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, className }: { to: string; children: ReactNode; className?: string }) =>
      createElement('a', { href: to, className }, children),
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { dashboardApi, type PersonalOverviewDto } from '../dashboard.api'
import { personalWorkApi } from '../personal-work.api'
import type { PersonalLeaveRequestDto, PersonalTaskDto } from '../personal-work.api'
import {
  companyDashboardApi,
  type CompanyOverviewDto,
} from '@/modules/company/company-dashboard.api'
import { hrDashboardApi, type HROverviewDto } from '@/modules/hr/hr-dashboard.api'
import {
  operationsDashboardApi,
  type OperationsOverviewDto,
} from '@/modules/operations/operations-dashboard.api'
import { notificationApi, type NotificationDto } from '@/shared/notifications/notifications.api'
import { CompanyOverviewPage } from '@/modules/company/routes/company-overview-page'
import { HRDashboardPage } from '@/modules/hr/routes/hr-dashboard-page'
import { WorkspaceOverviewPage } from './workspace-overview-page'

const personalOverview: PersonalOverviewDto = {
  attendance: {
    required_workdays: 10,
    attended_workdays: 9,
    attendance_rate_percent: 90,
    on_time_arrivals: 8,
    late_arrivals: 1,
    punctuality_rate_percent: 89,
    completed_shifts: 8,
  },
  work_reports: {
    reports_submitted: 3,
    approved_reports: 2,
    average_rating: 4,
    score_percent: 80,
  },
}

const emptyCompany: CompanyOverviewDto = {
  total_employees: null,
  new_employees_30_days: null,
  total_branches: null,
  inactive_branches_30_days: null,
  pending_approvals: null,
  overdue_approvals: null,
  asset_inventory: null,
  new_inventory_30_days: null,
  departments_count: null,
  units_count: null,
  asset_count: null,
  assets_added_30_days: null,
  approval_queue: null,
}

const emptyHR: HROverviewDto = {
  total_employees: null,
  new_hires_mtd: null,
  headcount_by_department: null,
  open_roles: null,
  pending_leaves: null,
  review_queue: null,
}

const emptyOperations: OperationsOverviewDto = {
  total_projects: null,
  allocated_project_budget: null,
  total_worksites: null,
  total_contracts: null,
  total_timelines: null,
  scope_limited: false,
}

function createTask(id: number, overrides: Partial<PersonalTaskDto> = {}): PersonalTaskDto {
  return {
    id,
    name: `Task ${id}`,
    status: 'pending',
    priority: 'medium',
    due_date: '2026-10-20',
    created_at: '2026-10-18T08:00:00Z',
    updated_at: '2026-10-18T08:00:00Z',
    project: { name: 'Workspace rollout' },
    ...overrides,
  }
}

function createNotification(id: number, overrides: Partial<NotificationDto> = {}): NotificationDto {
  return {
    id,
    title: `Update ${id}`,
    message: `Notification message ${id}`,
    notification_type: 'info',
    is_read: false,
    link: '',
    metadata: {},
    created_at: `2026-10-18T${String(8 + (id % 10)).padStart(2, '0')}:00:00Z`,
    event_type: null,
    priority: 'normal',
    action: '',
    entity_type: '',
    entity_id: '',
    ...overrides,
  }
}

function createSession(permissions: Record<string, string[]>): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'person@example.com',
      username: 'person',
      first_name: 'Avery',
      last_name: 'Person',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'person',
      email: 'person@example.com',
      first_name: 'Avery',
      last_name: 'Person',
    },
    roles: [],
    permissions,
    permissionsCatalog: {},
  }
}

function renderWithSession(children: ReactNode, permissions: Record<string, string[]>) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, createSession(permissions))
  return render(<QueryClientProvider client={queryClient}>{children}</QueryClientProvider>)
}

describe('dashboard pages', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.spyOn(dashboardApi, 'personalOverview').mockResolvedValue(personalOverview)
    vi.spyOn(personalWorkApi, 'attendanceToday').mockResolvedValue({
      date: '2026-10-19',
      state: 'clocked_out',
      next_action: null,
      day_policy: { required: true, reason: null, label: 'Workday', non_working_day_name: null },
      clock_in: null,
      clock_out: null,
    })
    vi.spyOn(personalWorkApi, 'tasks').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(personalWorkApi, 'completedTasks').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(personalWorkApi, 'reports').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(personalWorkApi, 'leaveRequests').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(personalWorkApi, 'loans').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(notificationApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(companyDashboardApi, 'overview').mockResolvedValue(emptyCompany)
    vi.spyOn(hrDashboardApi, 'overview').mockResolvedValue(emptyHR)
    vi.spyOn(operationsDashboardApi, 'overview').mockResolvedValue(emptyOperations)
  })

  it('loads only personal sections allowed by the current permissions', async () => {
    const companyRequest = vi.mocked(companyDashboardApi.overview)
    const hrRequest = vi.mocked(hrDashboardApi.overview)
    const operationsRequest = vi.mocked(operationsDashboardApi.overview)

    renderWithSession(<WorkspaceOverviewPage />, { attendance: ['list_own'] })

    expect(await screen.findByRole('img', { name: 'Attendance rate: 90%' })).toBeInTheDocument()
    expect(screen.getByText('90%')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Punctuality' })).toBeInTheDocument()
    expect(screen.getByRole('progressbar', { name: 'Punctuality score' })).toHaveAttribute(
      'aria-valuenow',
      '89',
    )
    expect(screen.getByText('Absent')).toBeInTheDocument()
    expect(screen.queryByText('Work report score')).not.toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Work reports' })).not.toBeInTheDocument()
    expect(screen.queryByRole('region', { name: 'Organization pulse' })).not.toBeInTheDocument()
    expect(companyRequest).not.toHaveBeenCalled()
    expect(hrRequest).not.toHaveBeenCalled()
    expect(operationsRequest).not.toHaveBeenCalled()
    expect(personalWorkApi.tasks).not.toHaveBeenCalled()
    expect(personalWorkApi.completedTasks).not.toHaveBeenCalled()
  })

  it('shows attendance, work-report, and punctuality summaries from personal metrics', async () => {
    renderWithSession(<WorkspaceOverviewPage />, {
      attendance: ['list_own'],
      work_reports: ['list_own'],
    })

    const performance = await screen.findByRole('region', { name: 'Performance overview' })
    await within(performance).findByRole('heading', { name: 'Punctuality' })
    expect(within(performance).getByRole('heading', { name: 'Attendance' })).toBeInTheDocument()
    expect(within(performance).getByRole('heading', { name: 'Work reports' })).toBeInTheDocument()
    expect(within(performance).getByRole('heading', { name: 'Punctuality' })).toBeInTheDocument()
    expect(
      within(performance).getByRole('progressbar', { name: 'Work reports score' }),
    ).toHaveAttribute('aria-valuenow', '80')
    expect(
      within(performance).getByRole('progressbar', { name: 'Punctuality score' }),
    ).toHaveAttribute('aria-valuenow', '89')
  })

  it('keeps the organization pulse to three permission-scoped signals', async () => {
    vi.mocked(companyDashboardApi.overview).mockResolvedValue({
      ...emptyCompany,
      total_branches: 3,
      pending_approvals: 4,
      asset_count: 12,
      departments_count: 6,
    })
    vi.mocked(hrDashboardApi.overview).mockResolvedValue({
      ...emptyHR,
      total_employees: 75,
      pending_leaves: 9,
      open_roles: 2,
    })
    vi.mocked(operationsDashboardApi.overview).mockResolvedValue({
      ...emptyOperations,
      total_projects: 8,
      total_worksites: 11,
      total_contracts: 5,
    })

    renderWithSession(<WorkspaceOverviewPage />, {
      approval_requests: ['list'],
      branches: ['list'],
      assets: ['list'],
      departments: ['list'],
      employees: ['list'],
      leave_requests: ['list'],
      job_postings: ['list'],
      projects: ['list'],
      worksites: ['list'],
      contracts: ['list'],
    })

    const pulse = await screen.findByRole('region', { name: 'Organization pulse' })
    expect(within(pulse).getAllByRole('listitem')).toHaveLength(3)
    expect(await within(pulse).findByText('Pending approvals')).toBeInTheDocument()
    expect(within(pulse).getByText('Pending leave requests')).toBeInTheDocument()
    expect(within(pulse).getByText('Branches')).toBeInTheDocument()
    expect(within(pulse).queryByText('Active employees')).not.toBeInTheDocument()
  })

  it('caps action and update lists and deduplicates notification/domain events', async () => {
    vi.mocked(personalWorkApi.tasks).mockResolvedValue({
      count: 8,
      items: Array.from({ length: 8 }, (_, index) => createTask(index + 1)),
    })
    vi.mocked(personalWorkApi.completedTasks).mockResolvedValue({
      count: 1,
      items: [
        createTask(22, {
          name: 'Prepare final review',
          status: 'completed',
          updated_at: '2026-10-18T12:30:00Z',
        }),
      ],
    })
    vi.mocked(personalWorkApi.reports).mockResolvedValue({
      count: 1,
      items: [
        {
          id: 31,
          day: '2026-10-17',
          status: 'approved',
          work_summary: 'Completed safety review',
          created_at: '2026-10-17T10:00:00Z',
          updated_at: '2026-10-18T10:00:00Z',
          rating: 4,
        },
      ],
    })
    const leaveRequest: PersonalLeaveRequestDto = {
      id: 44,
      request_kind: 'leave',
      leave_type: 'annual_leave',
      start_date: '2026-10-25',
      end_date: '2026-10-26',
      status: 'approved',
      created_at: '2026-10-16T10:00:00Z',
      updated_at: '2026-10-18T11:00:00Z',
    }
    vi.mocked(personalWorkApi.leaveRequests).mockResolvedValue({ count: 1, items: [leaveRequest] })
    vi.mocked(personalWorkApi.loans).mockResolvedValue({
      count: 1,
      items: [
        {
          id: 51,
          loan_amount: '250000.00',
          repayment_date: '2026-12-01',
          reason: 'Emergency home repair',
          status: 'Approved',
          created_at: '2026-10-15T10:00:00Z',
          updated_at: '2026-10-18T14:00:00Z',
        },
      ],
    })
    vi.mocked(notificationApi.list).mockResolvedValue({
      count: 5,
      items: [
        createNotification(1, {
          title: 'Task 1 changed',
          entity_type: 'project_task',
          entity_id: '1',
        }),
        createNotification(2, {
          title: 'Leave request approved',
          message: 'Your leave was approved.',
          entity_type: 'leave_request',
          entity_id: '44',
        }),
        createNotification(3, {
          title: 'Task completion notification',
          entity_type: 'project_task',
          entity_id: '22',
        }),
        createNotification(4),
        createNotification(5, {
          title: 'Loan approved',
          entity_type: 'loan',
          entity_id: '51',
        }),
      ],
    })

    renderWithSession(<WorkspaceOverviewPage />, {
      tasks: ['list_own'],
      work_reports: ['list_own'],
      leave_requests: ['list_own'],
      loans: ['list_own'],
      notifications: ['list'],
    })

    const attention = await screen.findByRole('region', { name: 'Needs your attention' })
    await waitFor(() => expect(within(attention).getAllByRole('listitem')).toHaveLength(5))
    const updatesRegion = screen.getByRole('region', { name: 'Recent updates' })
    // The domain record has a newer updated_at than the matching notification, so
    // keep the latest event and render the entity only once.
    expect(await within(updatesRegion).findByText('Request approved')).toBeInTheDocument()
    await waitFor(() => expect(within(updatesRegion).getAllByRole('listitem')).toHaveLength(5))
    expect(within(updatesRegion).queryByText('Task 1 changed')).not.toBeInTheDocument()
    expect(
      within(updatesRegion).queryByText('Task completion notification'),
    ).not.toBeInTheDocument()
    expect(within(updatesRegion).getAllByText('Task completed')).toHaveLength(1)
    expect(within(updatesRegion).queryByText('Leave request approved')).not.toBeInTheDocument()
    expect(within(updatesRegion).getAllByText('Request approved')).toHaveLength(1)
    expect(within(updatesRegion).queryByText('Loan approved')).not.toBeInTheDocument()
    expect(within(updatesRegion).getAllByText('Loan request approved')).toHaveLength(1)
  })

  it('shows attendance status with a workflow link and no clock control', async () => {
    const user = userEvent.setup()
    vi.mocked(personalWorkApi.attendanceToday).mockResolvedValue({
      date: '2026-10-19',
      state: 'not_clocked_in',
      next_action: 'clock_in',
      day_policy: { required: true, reason: null, label: 'Workday', non_working_day_name: null },
      clock_in: null,
      clock_out: null,
    })

    renderWithSession(<WorkspaceOverviewPage />, { attendance: ['list_own'] })

    const today = await screen.findByRole('region', { name: 'Today' })
    expect(await within(today).findByText('Not recorded yet')).toBeInTheDocument()
    expect(await within(today).findByRole('link', { name: /Not recorded yet/ })).toHaveAttribute(
      'href',
      '/hr/attendance',
    )
    expect(within(today).queryByRole('button', { name: /clock/i })).not.toBeInTheDocument()
    await user.tab()
    expect(screen.getByRole('link', { name: /Not recorded yet/ })).toHaveFocus()

  })

  it('keeps other Today data visible when one personal source fails', async () => {
    vi.mocked(personalWorkApi.attendanceToday).mockRejectedValueOnce(
      new Error('Attendance status unavailable'),
    )
    vi.mocked(personalWorkApi.tasks).mockResolvedValue({
      count: 1,
      items: [createTask(20, { name: 'Prepare weekly handoff' })],
    })

    renderWithSession(<WorkspaceOverviewPage />, {
      attendance: ['list_own'],
      tasks: ['list_own'],
    })

    const today = await screen.findByRole('region', { name: 'Today' })
    expect(await within(today).findByText('Unavailable')).toBeInTheDocument()
    expect(await within(today).findByRole('link', { name: /1 active task/ })).toHaveAttribute(
      'href',
      '/dashboard/my-tasks',
    )
  })

  it('keeps Company summary focused on structure and caps the approvals preview', async () => {
    vi.mocked(companyDashboardApi.overview).mockResolvedValue({
      ...emptyCompany,
      total_employees: 30,
      total_branches: 3,
      departments_count: 6,
      units_count: 14,
      pending_approvals: 8,
      overdue_approvals: 2,
      asset_count: 20,
      approval_queue: Array.from({ length: 7 }, (_, index) => ({
        id: index + 1,
        request_id: `APR-${index + 1}`,
        title: `Governance request ${index + 1}`,
        action_type: 'Policy change',
        requester_name: 'Avery Person',
        created_at: '2026-10-18T09:00:00Z',
      })),
    })

    renderWithSession(<CompanyOverviewPage />, {
      employees: ['list'],
      branches: ['list'],
      departments: ['list'],
      department_units: ['list'],
      approval_requests: ['list'],
      assets: ['list'],
    })

    expect(await screen.findByText('Tracked assets')).toBeInTheDocument()
    expect(screen.getAllByText('Branches').length).toBeGreaterThan(0)
    expect(screen.getByText('Departments')).toBeInTheDocument()
    expect(screen.getByText('Pending approvals')).toBeInTheDocument()
    expect(screen.queryByText('Total employees')).not.toBeInTheDocument()
    expect(screen.queryByText('30')).not.toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /Workflows/ })).not.toBeInTheDocument()
    const approvals = screen.getByRole('region', { name: 'Approval queue' })
    await waitFor(() => expect(within(approvals).getAllByRole('listitem')).toHaveLength(5))
  })

  it('retries the Company summary without replacing the page with a full error state', async () => {
    const user = userEvent.setup()
    vi.mocked(companyDashboardApi.overview)
      .mockRejectedValueOnce(new Error('Company summary unavailable'))
      .mockResolvedValue({ ...emptyCompany, total_branches: 4 })

    renderWithSession(<CompanyOverviewPage />, { branches: ['list'] })

    expect(await screen.findByRole('status')).toHaveTextContent(
      'These summary figures could not be loaded',
    )
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('4')).toBeInTheDocument()
    expect(companyDashboardApi.overview).toHaveBeenCalledTimes(2)
  })

  it('shows five largest HR departments and at most five review requests', async () => {
    vi.mocked(hrDashboardApi.overview).mockResolvedValue({
      total_employees: 30,
      new_hires_mtd: 2,
      headcount_by_department: [
        { department: 'Operations', count: 12 },
        { department: 'Finance', count: 9 },
        { department: 'HR', count: 7 },
        { department: 'Legal', count: 6 },
        { department: 'IT', count: 5 },
        { department: 'Marketing', count: 3 },
      ],
      open_roles: 4,
      pending_leaves: 2,
      review_queue: Array.from({ length: 7 }, (_, index) => ({
        id: index + 1,
        request_kind: 'leave',
        request_label: 'Annual Leave',
        employee_name: `Employee ${index + 1}`,
        start_date: '2026-10-22',
        end_date: '2026-10-24',
        created_at: '2026-10-18T09:00:00Z',
      })),
    })

    renderWithSession(<HRDashboardPage />, {
      employees: ['list'],
      job_postings: ['list'],
      leave_requests: ['list'],
    })

    expect(await screen.findByText('Employee 5')).toBeInTheDocument()
    const headcount = screen.getByRole('region', { name: 'Headcount by department' })
    await waitFor(() => expect(within(headcount).getAllByRole('listitem')).toHaveLength(5))
    expect(within(headcount).queryByText('Marketing')).not.toBeInTheDocument()
    const queue = screen.getByRole('region', { name: 'Requests awaiting review' })
    await waitFor(() => expect(within(queue).getAllByRole('listitem')).toHaveLength(5))
  })

  it('filters HR metrics, review queue, and shortcuts by their permissions', async () => {
    vi.mocked(hrDashboardApi.overview).mockResolvedValue({
      ...emptyHR,
      total_employees: 2,
      new_hires_mtd: 1,
      headcount_by_department: [{ department: 'Operations', count: 2 }],
      open_roles: 8,
      pending_leaves: 6,
      review_queue: [],
    })

    renderWithSession(<HRDashboardPage />, { employees: ['list'] })

    expect(await screen.findByRole('img', { name: 'Operations: 2 employees' })).toBeInTheDocument()
    expect(screen.getByText('New hires this month')).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'Operations: 2 employees' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /Employees/ })).toHaveAttribute('href', '/hr/employees')
    expect(screen.queryByRole('link', { name: /Recruitment/ })).not.toBeInTheDocument()
    expect(
      screen.queryByRole('region', { name: 'Requests awaiting review' }),
    ).not.toBeInTheDocument()
    expect(screen.queryByText('Open roles')).not.toBeInTheDocument()
    expect(screen.queryByText('Pending leave requests')).not.toBeInTheDocument()
    expect(screen.queryByText(/birthday/i)).not.toBeInTheDocument()
  })
})
