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
} from '@/modules/company/company-organization.api'
import {
  complianceApi,
  governanceApi,
  governanceQueryKeys,
  type BoardMeetingDto,
  type BoardResolutionDto,
  type ComplianceRecordDto,
  type AssociateDto,
  type PartnerDto,
  type ShareholderDto,
} from '@/modules/company/governance.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateBoardSearch, validateComplianceSearch } from '../governance.search'
import { BoardPage } from './board-page'
import { BoardRecordDetailPage } from './board-record-detail-page'
import { CompliancePage } from './compliance-page'
import { ComplianceRecordDetailPage } from './compliance-record-detail-page'

const showToast = vi.fn()
let queryClient: QueryClient

const department: DepartmentDto = { id: 8, name: 'operations', description: 'Operations team.' }

const meeting: BoardMeetingDto = {
  id: 41,
  meeting_id: 'MTG-QA-41',
  title: 'Quarterly governance review',
  agenda: 'Review delivery, risk, and policy updates.',
  meeting_date: '2026-11-04',
  meeting_time: '10:30:00',
  duration_minutes: 60,
  duration_display: '1 hour',
  status: 'scheduled',
  status_display: 'Scheduled',
  location_type: 'virtual',
  location_type_display: 'Virtual',
  location: 'https://meet.example.test/board',
  attendees: [],
  attendee_count: 0,
  organizer_id: 7,
  organizer_name: 'QA Admin',
  file_url: null,
  notes: null,
  created_at: '2026-10-23T10:00:00Z',
  updated_at: '2026-10-23T10:00:00Z',
}

const resolution: BoardResolutionDto = {
  id: 43,
  resolution_id: 'RES-QA-43',
  title: 'QA governance resolution',
  description: 'A synthetic resolution fixture.',
  resolution_type: 'governance',
  resolution_type_display: 'Governance',
  status: 'pending',
  status_display: 'Pending review',
  resolution_date: '2026-10-23',
  attachment_url: null,
  notes: null,
  created_by_id: 7,
  created_by_name: 'QA Admin',
  approved_by_id: null,
  approved_by_name: null,
  approved_at: null,
  created_at: '2026-10-23T10:00:00Z',
  updated_at: '2026-10-23T10:00:00Z',
}

const shareholder: ShareholderDto = {
  id: 44,
  shareholder_id: 'SH-QA-44',
  user_id: 74,
  first_name: 'QA',
  last_name: 'Shareholder',
  email: 'shareholder@example.test',
  phone_number: '+2348000000000',
  profile_picture: null,
  title: 'board_member',
  title_display: 'Board Member',
  share_percentage: 1.25,
  share_count: 10,
  is_board_member: true,
  is_active: true,
  notes: 'Synthetic fixture.',
  created_at: '2026-10-23T10:00:00Z',
  updated_at: '2026-10-23T10:00:00Z',
}

const associate: AssociateDto = {
  id: 46,
  user_id: 76,
  employee_id: 'EMP-QA-46',
  first_name: 'QA',
  last_name: 'Associate',
  email: 'associate@example.test',
  phone_number: '+2348000000001',
  designation: 'Surveyor',
  employment_type: 'surveyor-associate',
  employment_status: 'Active',
  is_active: true,
  branch_name: 'Lagos Branch',
  department_name: 'Operations',
}

const partner: PartnerDto = {
  id: 45,
  code: 'QA-PARTNER-45',
  name: 'QA Partner',
  email: 'partner@example.test',
  phone: '+2348000000000',
  address: 'Synthetic test address',
  category: 'other',
  category_display: 'Other',
  status: 'active',
  status_display: 'Active',
  kyc_status: 'pending',
  kyc_status_display: 'Pending',
  commission_rate: 0,
  notes: 'Synthetic partner fixture.',
  agreement_count: 0,
  created_at: '2026-10-23T10:00:00Z',
  updated_at: '2026-10-23T10:00:00Z',
}

const complianceRecord: ComplianceRecordDto = {
  id: 52,
  full_name: 'QA Compliance Owner',
  email_address: 'owner@example.test',
  phone_number: '+2348000000000',
  department_id: department.id,
  compliance_type: 'real_estate_license',
  reference_number: 'QA-COMP-52',
  date_of_issue: '2026-01-01',
  expiry_date: '2027-01-01',
  issuing_authority: 'QA Authority',
  status: 'pending',
  description: 'Synthetic test record.',
  contact_person: 'QA Contact',
  contact_email: 'contact@example.test',
  cost: 0,
  priority_level: 'medium',
  is_expired: false,
  days_until_expiry: 70,
  documents: [],
  created_at: '2026-10-23T10:00:00Z',
  updated_at: '2026-10-23T10:00:00Z',
}

function makeSession(permissions: AuthenticatedSession['permissions']): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'qa-admin@example.test',
      username: 'qa-admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-QA-7',
      username: 'qa-admin',
      email: 'qa-admin@example.test',
    },
    roles: [],
    permissions,
  }
}

const boardPermissions = {
  meetings: ['list', 'view', 'create', 'update', 'delete'],
  board_resolutions: ['list', 'view', 'create', 'update', 'approve', 'delete'],
  shareholders: ['list', 'view', 'create', 'update'],
  employees: ['list', 'view'],
  partners: ['list', 'view', 'create', 'update', 'delete'],
}

const compliancePermissions = {
  compliance_records: ['list', 'view', 'create', 'update', 'delete'],
  departments: ['list'],
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

function renderGovernanceRoute(path: string, permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession(permissions))
  const rootRoute = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const boardRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/board',
    validateSearch: validateBoardSearch,
    component: BoardPage,
  })
  const boardRecordDetailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/board/$section/$recordId',
    validateSearch: validateBoardSearch,
    component: BoardRecordDetailPage,
  })
  const complianceRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/compliance',
    validateSearch: validateComplianceSearch,
    component: CompliancePage,
  })
  const complianceRecordDetailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/compliance/$recordId',
    validateSearch: validateComplianceSearch,
    component: ComplianceRecordDetailPage,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      protectedRoute.addChildren([
        boardRoute,
        boardRecordDetailRoute,
        complianceRoute,
        complianceRecordDetailRoute,
      ]),
    ]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

async function selectDate(
  user: ReturnType<typeof userEvent.setup>,
  scope: HTMLElement,
  fieldName: RegExp,
  value: string,
) {
  const [year, month, day] = value.split('-').map(Number)
  const date = new Date(year, month - 1, day)
  const monthLabel = new Intl.DateTimeFormat(undefined, { month: 'long' }).format(date)
  const dateLabel = new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  }).format(date)

  await user.click(within(scope).getByRole('button', { name: fieldName }))
  const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
  await user.click(within(calendar).getByRole('combobox', { name: 'Month' }))
  await user.click(await screen.findByRole('option', { name: monthLabel }))
  await user.click(within(calendar).getByRole('combobox', { name: 'Year' }))
  await user.click(await screen.findByRole('option', { name: String(year) }))
  fireEvent.click(within(calendar).getByRole('button', { name: dateLabel }))
  await waitFor(() =>
    expect(screen.queryByRole('dialog', { name: 'Choose a date' })).not.toBeInTheDocument(),
  )
}

describe('Board and Compliance governance pages', () => {
  beforeEach(() => {
    showToast.mockReset()
    vi.spyOn(governanceApi, 'meetings').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'meeting').mockResolvedValue(meeting)
    vi.spyOn(governanceApi, 'meetingChoices').mockResolvedValue({
      statuses: [{ value: 'scheduled', label: 'Scheduled' }],
      location_types: [{ value: 'virtual', label: 'Virtual' }],
    })
    vi.spyOn(governanceApi, 'meetingAttendeeChoices').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'createMeeting').mockResolvedValue(meeting)
    vi.spyOn(governanceApi, 'updateMeeting').mockResolvedValue(meeting)
    vi.spyOn(governanceApi, 'resolutions').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'resolution').mockResolvedValue(resolution)
    vi.spyOn(governanceApi, 'resolutionChoices').mockResolvedValue({ statuses: [] })
    vi.spyOn(governanceApi, 'createResolution').mockResolvedValue(resolution)
    vi.spyOn(governanceApi, 'updateResolution').mockResolvedValue(resolution)
    vi.spyOn(governanceApi, 'shareholders').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'shareholder').mockResolvedValue(shareholder)
    vi.spyOn(governanceApi, 'createShareholder').mockResolvedValue(shareholder)
    vi.spyOn(governanceApi, 'associates').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'associate').mockResolvedValue({
      ...associate,
      username: 'qa-associate',
      middle_name: '',
      gender: '',
      marital_status: '',
      nationality: '',
      other_phone: null,
      personal_email: null,
      date_of_birth: null,
      address: null,
      city: 'Lagos',
      state: 'Lagos',
      country: 'Nigeria',
      profile_picture: null,
      location: 'Lagos office',
      start_date: '2024-01-01',
      work_schedule: 'Monday to Friday',
      role_name: 'Surveyor',
      department_units: [],
    })
    vi.spyOn(governanceApi, 'updateShareholder').mockResolvedValue(shareholder)
    vi.spyOn(governanceApi, 'partners').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(governanceApi, 'partner').mockResolvedValue(partner)
    vi.spyOn(governanceApi, 'updatePartner').mockResolvedValue(partner)
    vi.spyOn(governanceApi, 'partnerChoices').mockResolvedValue({
      category: [],
      status: [],
      kyc_status: [],
    })
    vi.spyOn(governanceApi, 'uploadFile').mockResolvedValue({
      url: 'http://127.0.0.1:8000/media/qa-governance-image.png',
    })
    vi.spyOn(complianceApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(complianceApi, 'detail').mockResolvedValue(complianceRecord)
    vi.spyOn(complianceApi, 'create').mockResolvedValue(complianceRecord)
    vi.spyOn(complianceApi, 'update').mockResolvedValue(complianceRecord)
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({
      count: 1,
      items: [department],
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('keeps the Board header free of refresh and creates an uploaded meeting attachment', async () => {
    const user = userEvent.setup()
    const createSpy = vi
      .mocked(governanceApi.createMeeting)
      .mockRejectedValueOnce(new Error('Temporary create failure'))
      .mockResolvedValueOnce(meeting)
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    expect(await screen.findByRole('heading', { name: 'Meetings' })).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
    const newButton = screen.getByRole('button', { name: 'New' })
    expect(newButton.parentElement).toHaveClass('justify-between')
    await user.click(newButton)

    const dialog = screen.getByRole('dialog', { name: 'New meeting' })
    expect(within(dialog).queryByLabelText('Document link')).not.toBeInTheDocument()
    expect(within(dialog).getByRole('group', { name: 'Attendees' })).toHaveClass('min-w-0')
    const dateControl = within(dialog).getByLabelText(/^Date/).parentElement
    const timeControl = within(dialog).getByLabelText(/^Time/).parentElement
    expect(dateControl?.parentElement?.parentElement?.parentElement).toBe(
      timeControl?.parentElement?.parentElement?.parentElement,
    )
    await user.type(within(dialog).getByLabelText(/Meeting title/), 'QA Board Review')
    await selectDate(user, dialog, /^Date/, '2026-11-04')
    await user.click(document.getElementById('meeting-time')!)
    await user.click(within(dialog).getByRole('combobox', { name: 'Hour' }))
    await user.click(within(dialog).getByRole('option', { name: '10' }))
    await user.click(within(dialog).getByRole('combobox', { name: 'Minute' }))
    await user.click(within(dialog).getByRole('option', { name: '30' }))
    await user.click(within(dialog).getByRole('button', { name: 'Set time' }))
    fireEvent.change(within(dialog).getByLabelText(/Duration in minutes/), {
      target: { value: '45' },
    })
    await user.type(within(dialog).getByLabelText(/Agenda/), 'Review the synthetic test agenda.')
    const image = new File(['synthetic image bytes'], 'qa-meeting-image.png', {
      type: 'image/png',
    })
    await user.upload(within(dialog).getByLabelText('Choose image or PDF'), image)
    expect(await within(dialog).findByText('qa-meeting-image.png')).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    await waitFor(() => expect(governanceApi.uploadFile).toHaveBeenCalledWith(image))
    await waitFor(() =>
      expect(createSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'QA Board Review',
          meeting_date: '2026-11-04',
          meeting_time: '10:30',
          duration_minutes: 45,
          file_url: 'http://127.0.0.1:8000/media/qa-governance-image.png',
        }),
      ),
    )
    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(screen.getByRole('dialog', { name: 'New meeting' })).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))
    await waitFor(() => expect(createSpy).toHaveBeenCalledTimes(2))
    expect(governanceApi.uploadFile).toHaveBeenCalledTimes(1)
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record created' }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  }, 10_000)

  it('preserves an edited meeting after a save error and retries successfully', async () => {
    const user = userEvent.setup()
    const updateSpy = vi
      .mocked(governanceApi.updateMeeting)
      .mockRejectedValueOnce(new Error('Temporary save failure'))
      .mockResolvedValueOnce({ ...meeting, title: 'QA Updated Board Meeting' })
    vi.mocked(governanceApi.meetings).mockResolvedValueOnce({ count: 1, items: [meeting] })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries')

    const card = (await screen.findByRole('heading', { name: meeting.title })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit meeting' })
    const title = within(dialog).getByLabelText(/Meeting title/)
    fireEvent.change(title, { target: { value: 'QA Updated Board Meeting' } })
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(title).toHaveValue('QA Updated Board Meeting')
    expect(screen.getByRole('dialog', { name: 'Edit meeting' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(updateSpy).toHaveBeenLastCalledWith(
        meeting.id,
        expect.objectContaining({
          title: 'QA Updated Board Meeting',
          meeting_date: meeting.meeting_date,
          meeting_time: '10:30',
          duration_minutes: meeting.duration_minutes,
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record updated' }))
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: governanceQueryKeys.detail(7, 'EMP-QA-7', 'meetings', meeting.id),
    })
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('keeps every Board section and search on the Board route', async () => {
    const user = userEvent.setup()
    const associatesSpy = vi.mocked(governanceApi.associates).mockResolvedValue({
      count: 0,
      items: [],
    })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)
    expect(await screen.findByRole('heading', { name: 'Meetings' })).toBeVisible()
    expect(screen.getByRole('navigation', { name: 'Board sections' })).toHaveClass(
      'w-full',
      'grid-cols-2',
      'phone:grid-cols-3',
      'tablet:grid-cols-5',
    )

    const sections = [
      { label: 'Resolutions', query: governanceApi.resolutions },
      { label: 'Investors', query: governanceApi.shareholders },
      { label: 'Associates', query: associatesSpy },
      { label: 'Partners', query: governanceApi.partners },
      { label: 'Meetings', query: governanceApi.meetings },
    ]

    for (const section of sections) {
      await user.click(screen.getByRole('button', { name: section.label }))
      expect(await screen.findByRole('heading', { name: section.label })).toBeVisible()
      await waitFor(() => expect(section.query).toHaveBeenCalled())
      expect(screen.queryByText(/Showing \d+–\d+ of \d+/)).not.toBeInTheDocument()
      expect(screen.queryByRole('heading', { name: 'Page not found' })).not.toBeInTheDocument()
    }

    await user.type(screen.getByRole('searchbox'), 'QA edge search')
    await waitFor(() =>
      expect(governanceApi.meetings).toHaveBeenLastCalledWith(
        expect.objectContaining({ limit: 10, offset: 0, search: 'QA edge search' }),
        expect.anything(),
      ),
    )
    expect(screen.getByRole('heading', { name: 'Meetings' })).toBeVisible()
    expect(screen.queryByRole('heading', { name: 'Page not found' })).not.toBeInTheDocument()
  })

  it('recovers from a Board list load failure with a clear retry state', async () => {
    const user = userEvent.setup()
    vi.mocked(governanceApi.meetings)
      .mockRejectedValueOnce(new Error('Temporary network failure'))
      .mockResolvedValueOnce({ count: 0, items: [] })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    expect(await screen.findByRole('status')).toHaveTextContent('An unexpected problem occurred')
    expect(screen.getByRole('button', { name: 'Try again' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))

    expect(await screen.findByRole('heading', { name: 'No meetings found' })).toBeVisible()
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Page not found' })).not.toBeInTheDocument()
    expect(governanceApi.meetings).toHaveBeenCalledTimes(2)
  })

  it('paginates a full Board list and sends the matching page offsets', async () => {
    const user = userEvent.setup()
    const items = Array.from({ length: 11 }, (_, index) => ({
      ...meeting,
      id: 100 + index,
      meeting_id: `MTG-QA-${100 + index}`,
      title: `QA meeting ${index + 1}`,
    }))
    vi.mocked(governanceApi.meetings)
      .mockResolvedValueOnce({ count: items.length, items: items.slice(0, 10) })
      .mockResolvedValueOnce({ count: items.length, items: items.slice(10) })
      .mockResolvedValueOnce({ count: items.length, items: items.slice(0, 10) })
    renderGovernanceRoute('/company/board?tab=meetings&search=QA&page=1', boardPermissions)

    expect(await screen.findByRole('heading', { name: 'QA meeting 1' })).toBeVisible()
    expect(screen.getByText('Page 1 of 2')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Next' }))
    expect(await screen.findByRole('heading', { name: 'QA meeting 11' })).toBeVisible()
    expect(screen.getByText('Page 2 of 2')).toBeVisible()
    await waitFor(() =>
      expect(governanceApi.meetings).toHaveBeenLastCalledWith(
        expect.objectContaining({ limit: 10, offset: 10, search: 'QA' }),
        expect.anything(),
      ),
    )
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    expect(await screen.findByRole('heading', { name: 'QA meeting 1' })).toBeVisible()
    await waitFor(() =>
      expect(governanceApi.meetings).toHaveBeenLastCalledWith(
        expect.objectContaining({ limit: 10, offset: 0, search: 'QA' }),
        expect.anything(),
      ),
    )
  })

  it('merges the Associate types, recovers when one type fails, and keeps the section read-only', async () => {
    const user = userEvent.setup()
    let shouldFailLawyerRequest = true
    const associateTypes = [
      'surveyor-associate',
      'lawyer-associate',
      'architect-associate',
      'engineer-associate',
    ]
    const associatesSpy = vi.mocked(governanceApi.associates).mockImplementation(async (params) => {
      if (params.employmentType === 'lawyer-associate' && shouldFailLawyerRequest) {
        shouldFailLawyerRequest = false
        throw new Error('Temporary employee query failure')
      }
      const typeIndex = associateTypes.indexOf(params.employmentType)
      const item = {
        ...associate,
        id: associate.id + typeIndex,
        user_id: associate.user_id + typeIndex,
        employment_type: params.employmentType,
        email: `associate-${typeIndex}@example.test`,
      }
      return {
        count: 1,
        items: [
          {
            ...item,
            first_name: params.employmentType === 'architect-associate' ? 'Ari' : 'Zoe',
            last_name: params.employmentType,
            employee_id: `EMP-${params.employmentType}`,
          },
        ],
      }
    })
    renderGovernanceRoute('/company/board?tab=associates&search=&page=1', boardPermissions)

    expect(await screen.findByRole('button', { name: 'Try again' })).toBeVisible()
    expect(associatesSpy).toHaveBeenCalledTimes(associateTypes.length)
    for (const employmentType of associateTypes) {
      expect(associatesSpy).toHaveBeenCalledWith(
        expect.objectContaining({ employmentType, limit: 100, offset: 0 }),
        expect.anything(),
      )
    }

    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByRole('heading', { name: /Ari architect-associate/ })).toBeVisible()
    expect(screen.getByRole('heading', { name: /Zoe surveyor-associate/ })).toBeVisible()
    expect(screen.getAllByRole('heading', { name: /Zoe / })).toHaveLength(3)
    expect(screen.getAllByText('Operations')).toHaveLength(4)
    expect(screen.getAllByText('Lagos Branch')).toHaveLength(4)
    expect(screen.getAllByText(/associate-\d@example\.test/)).toHaveLength(4)
    expect(screen.queryByRole('button', { name: 'New' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Delete' })).not.toBeInTheDocument()
  })

  it('keeps meeting cancellation recoverable and confirms success only after the API succeeds', async () => {
    const user = userEvent.setup()
    const cancelSpy = vi
      .spyOn(governanceApi, 'cancelMeeting')
      .mockRejectedValueOnce(new Error('Temporary network failure'))
      .mockResolvedValueOnce({ detail: 'Meeting cancelled.' })
    vi.mocked(governanceApi.meetings).mockResolvedValue({ count: 1, items: [meeting] })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: meeting.title })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Cancel meeting' }))
    let dialog = screen.getByRole('dialog', { name: 'Cancel this meeting?' })
    await user.click(within(dialog).getByRole('button', { name: 'Keep record' }))
    expect(cancelSpy).not.toHaveBeenCalled()

    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Cancel meeting' }))
    dialog = screen.getByRole('dialog', { name: 'Cancel this meeting?' })
    await user.click(within(dialog).getByRole('button', { name: 'Cancel meeting' }))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Meeting could not be cancelled', tone: 'danger' }),
      ),
    )
    expect(screen.getByRole('dialog', { name: 'Cancel this meeting?' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Cancel meeting' }))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Meeting cancelled', tone: 'success' }),
      ),
    )
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
    expect(cancelSpy).toHaveBeenCalledTimes(2)
  })

  it('uses resolution-specific approve and archive confirmations', async () => {
    const user = userEvent.setup()
    const approveSpy = vi.spyOn(governanceApi, 'approveResolution').mockResolvedValue(resolution)
    const archiveSpy = vi
      .spyOn(governanceApi, 'archiveResolution')
      .mockResolvedValue({ detail: 'Resolution archived.' })
    vi.mocked(governanceApi.resolutions).mockResolvedValue({ count: 1, items: [resolution] })
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: resolution.title })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Approve' }))
    let dialog = screen.getByRole('dialog', { name: 'Approve this resolution?' })
    expect(dialog).toHaveTextContent('marks the resolution as approved')
    await user.click(within(dialog).getByRole('button', { name: 'Approve resolution' }))
    await waitFor(() => expect(approveSpy).toHaveBeenCalledWith(resolution.id))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Resolution approved', tone: 'success' }),
    )

    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Archive' }))
    dialog = screen.getByRole('dialog', { name: 'Archive resolution?' })
    expect(dialog).toHaveTextContent('moves the resolution to the archived state')
    await user.click(within(dialog).getByRole('button', { name: 'Archive resolution' }))
    await waitFor(() => expect(archiveSpy).toHaveBeenCalledWith(resolution.id))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Resolution archived', tone: 'success' }),
    )
  })

  it('keeps a failed resolution approval open and reports the failure before retrying', async () => {
    const user = userEvent.setup()
    const approveSpy = vi
      .spyOn(governanceApi, 'approveResolution')
      .mockRejectedValueOnce(new Error('Temporary approval failure'))
      .mockResolvedValueOnce(resolution)
    vi.mocked(governanceApi.resolutions).mockResolvedValueOnce({ count: 1, items: [resolution] })
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: resolution.title })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Approve' }))
    const dialog = screen.getByRole('dialog', { name: 'Approve this resolution?' })
    await user.click(within(dialog).getByRole('button', { name: 'Approve resolution' }))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Resolution could not be updated', tone: 'danger' }),
      ),
    )
    expect(screen.getByRole('dialog', { name: 'Approve this resolution?' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Approve resolution' }))
    await waitFor(() => expect(approveSpy).toHaveBeenCalledTimes(2))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Resolution approved', tone: 'success' }),
    )
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('creates a partner with validated commission and keeps the editor open on save failure', async () => {
    const user = userEvent.setup()
    const createSpy = vi
      .spyOn(governanceApi, 'createPartner')
      .mockRejectedValueOnce(new Error('Temporary save failure'))
      .mockResolvedValueOnce(partner)
    renderGovernanceRoute('/company/board?tab=partners&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: /^New$/ }))
    const dialog = screen.getByRole('dialog', { name: 'New partner' })
    await user.type(within(dialog).getByLabelText(/Partner name/), 'QA Partner Create')
    const rate = within(dialog).getByLabelText(/Commission rate/)
    fireEvent.change(rate, { target: { value: '120' } })
    expect(rate).toBeInvalid()
    fireEvent.change(rate, { target: { value: '12.5' } })
    expect(rate).toBeValid()

    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))
    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(screen.getByRole('dialog', { name: 'New partner' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))
    await waitFor(() =>
      expect(createSpy).toHaveBeenLastCalledWith(
        expect.objectContaining({ name: 'QA Partner Create', commission_rate: 12.5 }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record created' }))
  })

  it('creates a shareholder with a bounded share percentage', async () => {
    const user = userEvent.setup()
    const createSpy = vi
      .mocked(governanceApi.createShareholder)
      .mockRejectedValueOnce(new Error('Temporary create failure'))
      .mockResolvedValueOnce(shareholder)
    renderGovernanceRoute('/company/board?tab=investors&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: /^New$/ }))
    const dialog = screen.getByRole('dialog', { name: 'New investor' })
    await user.type(within(dialog).getByLabelText(/First name/), 'QA')
    await user.type(within(dialog).getByLabelText(/Last name/), 'New Shareholder')
    await user.type(within(dialog).getByLabelText(/Email/), 'new.shareholder@example.test')
    const percentage = within(dialog).getByLabelText(/Share percentage/)
    fireEvent.change(percentage, { target: { value: '100.01' } })
    expect(percentage).toBeInvalid()
    fireEvent.change(percentage, { target: { value: '2.5' } })
    expect(percentage).toBeValid()
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(screen.getByRole('dialog', { name: 'New investor' })).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))
    await waitFor(() =>
      expect(createSpy).toHaveBeenLastCalledWith(
        expect.objectContaining({
          first_name: 'QA',
          last_name: 'New Shareholder',
          email: 'new.shareholder@example.test',
          share_percentage: 2.5,
          share_count: null,
          password: null,
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record created' }))
  })

  it('requires explicit confirmation before deleting a partner', async () => {
    const user = userEvent.setup()
    const deleteSpy = vi
      .spyOn(governanceApi, 'deletePartner')
      .mockRejectedValueOnce(new Error('Temporary delete failure'))
      .mockResolvedValueOnce({ detail: 'Partner deleted.' })
    vi.mocked(governanceApi.partners).mockResolvedValueOnce({ count: 1, items: [partner] })
    renderGovernanceRoute('/company/board?tab=partners&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: partner.name })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: /^Delete$/ }))
    let dialog = screen.getByRole('dialog', { name: 'Delete this partner?' })
    expect(dialog).toHaveTextContent('permanently removes the partner')
    await user.click(within(dialog).getByRole('button', { name: 'Keep record' }))
    expect(deleteSpy).not.toHaveBeenCalled()

    await user.click(within(card as HTMLElement).getByRole('button', { name: /^Delete$/ }))
    dialog = screen.getByRole('dialog', { name: 'Delete this partner?' })
    await user.click(within(dialog).getByRole('button', { name: /^Delete$/ }))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Partner could not be deleted', tone: 'danger' }),
      ),
    )
    expect(screen.getByRole('dialog', { name: 'Delete this partner?' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: /^Delete$/ }))
    await waitFor(() => expect(deleteSpy).toHaveBeenCalledWith(partner.id))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Partner removed', tone: 'success' }),
    )
  })

  it('clears a saved resolution attachment without asking users to type a document URL', async () => {
    const user = userEvent.setup()
    const savedResolution = {
      ...resolution,
      attachment_url: 'https://files.example.test/board.pdf',
    }
    vi.mocked(governanceApi.resolutions).mockResolvedValueOnce({
      count: 1,
      items: [savedResolution],
    })
    vi.mocked(governanceApi.updateResolution).mockResolvedValue(savedResolution)
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: resolution.title })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit resolution' })
    expect(within(dialog).queryByLabelText('Document link')).not.toBeInTheDocument()
    expect(within(dialog).getByRole('link', { name: 'View saved file' })).toHaveAttribute(
      'href',
      savedResolution.attachment_url,
    )
    await user.click(within(dialog).getByRole('button', { name: 'Remove attachment' }))
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(governanceApi.updateResolution).toHaveBeenCalledWith(
        resolution.id,
        expect.objectContaining({ attachment_url: '' }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record updated' }))
  })

  it('presents meeting schedule details and actions in a labeled responsive card', async () => {
    vi.mocked(governanceApi.meetings).mockResolvedValueOnce({ count: 1, items: [meeting] })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: meeting.title })).closest('article')
    expect(card).toBeInTheDocument()
    expect(screen.queryByText('Governance & oversight')).not.toBeInTheDocument()
    expect(screen.queryByText('1 record in this section')).not.toBeInTheDocument()
    expect(within(card as HTMLElement).getByText('Nov 4, 2026')).toBeVisible()
    expect(within(card as HTMLElement).getByText('10:30 · 1 hour')).toBeVisible()
    expect(
      within(card as HTMLElement).getByText(/Virtual · https:\/\/meet\.example\.test/),
    ).toBeVisible()
    expect(within(card as HTMLElement).getByText('0 people')).toBeVisible()
    expect(within(card as HTMLElement).getByText(meeting.agenda)).toBeVisible()
    expect(within(card as HTMLElement).getByRole('button', { name: 'Edit' })).toBeVisible()
    expect(
      within(card as HTMLElement).getByRole('button', { name: 'Cancel meeting' }),
    ).toBeVisible()
    expect(within(card as HTMLElement).getByText(`Record ID · ${meeting.meeting_id}`)).toBeVisible()
    expect(card?.querySelector('dl')).toHaveClass('phone:grid-cols-2', 'desktop:grid-cols-4')
    expect(card?.querySelector('dl > div')).not.toHaveClass('rounded-control', 'bg-surface-muted')
  })

  it('keeps the Board editor open with an upload error and does not create the meeting', async () => {
    const user = userEvent.setup()
    vi.mocked(governanceApi.uploadFile).mockRejectedValueOnce(new Error('Upload unavailable'))
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: 'New' }))
    const dialog = screen.getByRole('dialog', { name: 'New meeting' })
    await user.type(within(dialog).getByLabelText(/Meeting title/), 'QA Upload Failure')
    fireEvent.change(within(dialog).getByLabelText(/^Date/), { target: { value: '2026-11-04' } })
    fireEvent.change(within(dialog).getByLabelText(/^Time/), { target: { value: '10:30' } })
    fireEvent.change(within(dialog).getByLabelText(/Duration in minutes/), {
      target: { value: '45' },
    })
    await user.type(within(dialog).getByLabelText(/Agenda/), 'Test upload recovery.')
    await user.upload(
      within(dialog).getByLabelText('Choose image or PDF'),
      new File(['image'], 'qa-fail.png', { type: 'image/png' }),
    )
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(governanceApi.createMeeting).not.toHaveBeenCalled()
    expect(screen.getByRole('dialog', { name: 'New meeting' })).toBeVisible()
  })

  it('uploads a resolution attachment to the saved URL field', async () => {
    const user = userEvent.setup()
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    expect(await screen.findByRole('heading', { name: 'Resolutions' })).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: /^New$/ }))
    const dialog = screen.getByRole('dialog', { name: 'New resolution' })
    await user.type(within(dialog).getByLabelText(/^Title/), 'QA Policy Resolution')
    await selectDate(user, dialog, /Resolution date/, '2026-10-23')
    await user.type(within(dialog).getByLabelText(/Description/), 'A synthetic resolution for QA.')
    const pdf = new File(['synthetic PDF bytes'], 'qa-resolution.pdf', {
      type: 'application/pdf',
    })
    await user.upload(within(dialog).getByLabelText('Choose image or PDF'), pdf)
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    await waitFor(() => expect(governanceApi.uploadFile).toHaveBeenCalledWith(pdf))
    await waitFor(() =>
      expect(governanceApi.createResolution).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'QA Policy Resolution',
          resolution_type: 'governance',
          attachment_url: 'http://127.0.0.1:8000/media/qa-governance-image.png',
        }),
      ),
    )
  })

  it('keeps a resolution draft after a create failure and saves it on retry', async () => {
    const user = userEvent.setup()
    const createSpy = vi
      .mocked(governanceApi.createResolution)
      .mockRejectedValueOnce(new Error('Temporary create failure'))
      .mockResolvedValueOnce(resolution)
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: /^New$/ }))
    const dialog = screen.getByRole('dialog', { name: 'New resolution' })
    await user.type(within(dialog).getByLabelText(/^Title/), 'QA Retry Resolution')
    await selectDate(user, dialog, /Resolution date/, '2026-10-23')
    await user.type(within(dialog).getByLabelText(/Description/), 'Keep this draft after failure.')
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(within(dialog).getByLabelText(/^Title/)).toHaveValue('QA Retry Resolution')
    expect(screen.getByRole('dialog', { name: 'New resolution' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))
    await waitFor(() =>
      expect(createSpy).toHaveBeenLastCalledWith(
        expect.objectContaining({
          title: 'QA Retry Resolution',
          resolution_date: '2026-10-23',
          description: 'Keep this draft after failure.',
          attachment_url: '',
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record created' }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('uploads a shareholder profile photo when saving an existing shareholder', async () => {
    const user = userEvent.setup()
    vi.mocked(governanceApi.shareholders).mockResolvedValueOnce({
      count: 1,
      items: [shareholder],
    })
    renderGovernanceRoute('/company/board?tab=investors&search=&page=1', boardPermissions)

    expect(await screen.findByRole('heading', { name: 'Investors' })).toBeVisible()
    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit investor' })
    const photo = new File(['synthetic avatar bytes'], 'qa-shareholder.png', { type: 'image/png' })
    await user.upload(within(dialog).getByLabelText('Choose profile photo'), photo)
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    await waitFor(() => expect(governanceApi.uploadFile).toHaveBeenCalledWith(photo))
    await waitFor(() =>
      expect(governanceApi.updateShareholder).toHaveBeenCalledWith(
        shareholder.id,
        expect.objectContaining({
          profile_picture: 'http://127.0.0.1:8000/media/qa-governance-image.png',
        }),
      ),
    )
    expect(governanceApi.updateShareholder).toHaveBeenCalledWith(
      shareholder.id,
      expect.not.objectContaining({ email: expect.anything() }),
    )
  })

  it('keeps an investor edit recoverable when the update request fails', async () => {
    const user = userEvent.setup()
    const updateSpy = vi
      .mocked(governanceApi.updateShareholder)
      .mockRejectedValueOnce(new Error('Temporary update failure'))
      .mockResolvedValueOnce(shareholder)
    vi.mocked(governanceApi.shareholders).mockResolvedValueOnce({
      count: 1,
      items: [shareholder],
    })
    renderGovernanceRoute('/company/board?tab=investors&search=&page=1', boardPermissions)

    const card = (await screen.findByRole('heading', { name: 'QA Shareholder' })).closest('article')
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit investor' })
    expect(within(dialog).getByLabelText(/Email/)).toBeDisabled()
    const notes = within(dialog).getByLabelText(/Notes/)
    await user.clear(notes)
    await user.type(notes, 'Recovered after a temporary server error.')
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(notes).toHaveValue('Recovered after a temporary server error.')
    expect(screen.getByRole('dialog', { name: 'Edit investor' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(updateSpy).toHaveBeenLastCalledWith(
        shareholder.id,
        expect.objectContaining({ notes: 'Recovered after a temporary server error.' }),
      ),
    )
    expect(updateSpy).toHaveBeenLastCalledWith(
      shareholder.id,
      expect.not.objectContaining({ email: expect.anything() }),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record updated' }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('round-trips an edit through the Board resolution update contract', async () => {
    const user = userEvent.setup()
    const updateSpy = vi
      .mocked(governanceApi.updateResolution)
      .mockRejectedValueOnce(new Error('Temporary update failure'))
      .mockResolvedValueOnce(resolution)
    vi.mocked(governanceApi.resolutions).mockResolvedValueOnce({ count: 1, items: [resolution] })
    renderGovernanceRoute('/company/board?tab=resolutions&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit resolution' })
    await user.type(within(dialog).getByLabelText(/Notes/), 'Updated in the QA edit flow.')
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(screen.getByRole('dialog', { name: 'Edit resolution' })).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(updateSpy).toHaveBeenLastCalledWith(
        resolution.id,
        expect.objectContaining({
          attachment_url: '',
          notes: 'Updated in the QA edit flow.',
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record updated' }))
  })

  it('round-trips an edit through the Board partner update contract', async () => {
    const user = userEvent.setup()
    const updateSpy = vi
      .mocked(governanceApi.updatePartner)
      .mockRejectedValueOnce(new Error('Temporary update failure'))
      .mockResolvedValueOnce(partner)
    vi.mocked(governanceApi.partners).mockResolvedValueOnce({ count: 1, items: [partner] })
    renderGovernanceRoute('/company/board?tab=partners&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit partner' })
    const notes = within(dialog).getByLabelText(/Notes/)
    await user.clear(notes)
    await user.type(notes, 'Updated in the QA edit flow.')
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'An unexpected problem occurred. Please try again.',
    )
    expect(screen.getByRole('dialog', { name: 'Edit partner' })).toBeVisible()
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(updateSpy).toHaveBeenLastCalledWith(
        partner.id,
        expect.objectContaining({ notes: 'Updated in the QA edit flow.' }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Record updated' }))
  })

  it('keeps Compliance actions compact, pairs status with priority, and validates expiry', async () => {
    const user = userEvent.setup()
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )

    expect(await screen.findByRole('heading', { name: 'Compliance register' })).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
    const newButton = screen.getByRole('button', { name: 'New' })
    expect(newButton).toHaveClass('shrink-0')
    expect(newButton.parentElement).toHaveClass('justify-between')
    await user.click(newButton)

    const dialog = screen.getByRole('dialog', { name: 'New compliance record' })
    expect(within(dialog).queryByLabelText(/Document URLs/)).not.toBeInTheDocument()
    expect(within(dialog).getByLabelText('Choose image or PDF')).toBeInTheDocument()
    const statusControl = within(dialog).getByLabelText(/Status/).parentElement
    const priorityControl = within(dialog).getByLabelText(/Priority/).parentElement
    expect(statusControl?.parentElement?.parentElement?.parentElement).toBe(
      priorityControl?.parentElement?.parentElement?.parentElement,
    )

    await user.type(within(dialog).getByLabelText(/Full name/), 'QA Compliance Holder')
    await user.type(within(dialog).getByLabelText(/Email/), 'holder@example.test')
    await user.type(within(dialog).getByLabelText(/Phone/), '+2348000000000')
    await user.click(within(dialog).getByRole('combobox', { name: /Department/ }))
    await user.click(await screen.findByRole('option', { name: 'operations' }))
    expect(within(dialog).getByRole('button', { name: 'Create record' })).toBeEnabled()
    await user.type(within(dialog).getByLabelText(/Issuing authority/), 'QA Regulator')
    await selectDate(user, dialog, /Date of issue/, '2026-10-10')
    await selectDate(user, dialog, /Expiry date/, '2026-10-10')
    expect(within(dialog).getByLabelText(/Date of issue/)).toHaveTextContent('October 10, 2026')
    expect(within(dialog).getByLabelText(/Expiry date/)).toHaveTextContent('October 10, 2026')
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Expiry date must be after the date of issue.',
    )
    expect(complianceApi.create).not.toHaveBeenCalled()
    await selectDate(user, dialog, /Expiry date/, '2026-10-11')
    expect(within(dialog).queryByRole('alert')).not.toBeInTheDocument()
  })

  it('searches, filters, and paginates Compliance records without losing the selected view', async () => {
    const user = userEvent.setup()
    const listSpy = vi.mocked(complianceApi.list).mockImplementation(async (params) => {
      if (params.search || params.complianceType) return { count: 0, items: [] }
      const items = Array.from({ length: params.offset ? 1 : 10 }, (_, index) => ({
        ...complianceRecord,
        id: 100 + params.offset + index,
        full_name: `QA Compliance Result ${params.offset + index + 1}`,
      }))
      return { count: 11, items }
    })
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )

    expect(await screen.findByText('Page 1 of 2')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Next' }))
    await waitFor(() =>
      expect(listSpy).toHaveBeenLastCalledWith(
        expect.objectContaining({ limit: 10, offset: 10, search: '', complianceType: '' }),
        expect.any(AbortSignal),
      ),
    )
    expect(await screen.findByText('Page 2 of 2')).toBeVisible()
    expect(screen.getByText('QA Compliance Result 11')).toBeVisible()

    await user.type(screen.getByRole('searchbox', { name: 'Search records' }), 'no match')
    await waitFor(() => expect(screen.getByText('No compliance records found')).toBeVisible())
    expect(listSpy).toHaveBeenLastCalledWith(
      expect.objectContaining({ offset: 0, search: 'no match', complianceType: '' }),
      expect.any(AbortSignal),
    )
    expect(screen.queryByText('Page 2 of 2')).not.toBeInTheDocument()

    await user.click(screen.getByRole('combobox', { name: 'Compliance type' }))
    await user.click(await screen.findByRole('option', { name: 'Broker License' }))
    await waitFor(() =>
      expect(listSpy).toHaveBeenLastCalledWith(
        expect.objectContaining({
          offset: 0,
          search: 'no match',
          complianceType: 'broker_license',
        }),
        expect.any(AbortSignal),
      ),
    )
    expect(screen.getByText('Try a different search or clear the type filter.')).toBeVisible()
  })

  it('uploads selected Compliance files into the saved document URLs', async () => {
    const user = userEvent.setup()
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )
    await user.click(await screen.findByRole('button', { name: 'New' }))
    const dialog = screen.getByRole('dialog', { name: 'New compliance record' })
    await user.type(within(dialog).getByLabelText(/Full name/), 'QA Compliance Holder')
    await user.type(within(dialog).getByLabelText(/Email/), 'holder@example.test')
    await user.type(within(dialog).getByLabelText(/Phone/), '+2348000000000')
    await user.click(within(dialog).getByRole('combobox', { name: /Department/ }))
    await user.click(await screen.findByRole('option', { name: 'operations' }))
    await user.type(within(dialog).getByLabelText(/Issuing authority/), 'QA Regulator')
    await selectDate(user, dialog, /Date of issue/, '2026-10-10')
    await selectDate(user, dialog, /Expiry date/, '2027-10-10')
    expect(within(dialog).getByLabelText(/Date of issue/)).toHaveTextContent('October 10, 2026')
    expect(within(dialog).getByLabelText(/Expiry date/)).toHaveTextContent('October 10, 2027')
    const image = new File(['synthetic image bytes'], 'qa-compliance-image.png', {
      type: 'image/png',
    })
    await user.upload(within(dialog).getByLabelText('Choose image or PDF'), image)
    expect(await within(dialog).findByText('qa-compliance-image.png')).toBeVisible()
    await waitFor(() =>
      expect(within(dialog).getByRole('button', { name: 'Create record' })).toBeEnabled(),
    )
    await user.click(within(dialog).getByRole('button', { name: 'Create record' }))

    await waitFor(() => expect(governanceApi.uploadFile).toHaveBeenCalledWith(image))
    await waitFor(() =>
      expect(complianceApi.create).toHaveBeenCalledWith(
        expect.objectContaining({
          full_name: 'QA Compliance Holder',
          department_id: department.id,
          documents: ['http://127.0.0.1:8000/media/qa-governance-image.png'],
        }),
      ),
    )
  })

  it('opens an existing Compliance record in edit mode and saves its changes', async () => {
    const user = userEvent.setup()
    const recordWithDocument = {
      ...complianceRecord,
      documents: ['https://files.example.test/current-license.pdf'],
    }
    vi.mocked(complianceApi.list).mockResolvedValueOnce({ count: 1, items: [recordWithDocument] })
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit compliance record' })
    expect(within(dialog).queryByLabelText(/Document URLs/)).not.toBeInTheDocument()
    expect(within(dialog).getByText('Current attachments')).toBeInTheDocument()
    expect(within(dialog).getByRole('link', { name: 'Document 1' })).toHaveAttribute(
      'href',
      'https://files.example.test/current-license.pdf',
    )
    const fullName = within(dialog).getByLabelText(/Full name/)
    await user.clear(fullName)
    await user.type(fullName, 'QA Compliance Holder Updated')
    const image = new File(['new attachment'], 'qa-compliance-update.png', {
      type: 'image/png',
    })
    await user.upload(within(dialog).getByLabelText('Choose image or PDF'), image)
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    await waitFor(() => expect(governanceApi.uploadFile).toHaveBeenCalledWith(image))
    await waitFor(() =>
      expect(complianceApi.update).toHaveBeenCalledWith(
        complianceRecord.id,
        expect.objectContaining({
          full_name: 'QA Compliance Holder Updated',
          documents: [
            'https://files.example.test/current-license.pdf',
            'http://127.0.0.1:8000/media/qa-governance-image.png',
          ],
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Compliance record updated' }),
    )
  })

  it('removes a saved Compliance attachment from the edit draft when requested', async () => {
    const user = userEvent.setup()
    vi.mocked(complianceApi.list).mockResolvedValueOnce({
      count: 1,
      items: [{ ...complianceRecord, documents: ['https://files.example.test/remove-me.pdf'] }],
    })
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = screen.getByRole('dialog', { name: 'Edit compliance record' })
    await user.click(within(dialog).getByRole('button', { name: 'Remove document 1' }))
    expect(within(dialog).queryByRole('link', { name: 'Document 1' })).not.toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(complianceApi.update).toHaveBeenCalledWith(
        complianceRecord.id,
        expect.objectContaining({ documents: [] }),
      ),
    )
  })

  it('requires confirmation and reports Compliance delete errors before succeeding', async () => {
    const user = userEvent.setup()
    const deleteSpy = vi
      .spyOn(complianceApi, 'delete')
      .mockRejectedValueOnce(new Error('Temporary delete failure'))
      .mockResolvedValueOnce({ detail: 'Compliance record deleted.' })
    vi.mocked(complianceApi.list).mockResolvedValueOnce({ count: 1, items: [complianceRecord] })
    renderGovernanceRoute(
      '/company/compliance?search=&complianceType=&page=1',
      compliancePermissions,
    )

    const card = (await screen.findByRole('heading', { name: 'Real Estate License' })).closest(
      'article',
    )
    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Delete' }))
    let dialog = screen.getByRole('dialog', { name: 'Delete compliance record?' })
    expect(dialog).toHaveTextContent('QA Compliance Owner')
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))
    expect(deleteSpy).not.toHaveBeenCalled()

    await user.click(within(card as HTMLElement).getByRole('button', { name: 'Delete' }))
    dialog = screen.getByRole('dialog', { name: 'Delete compliance record?' })
    await user.click(within(dialog).getByRole('button', { name: 'Delete record' }))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Record could not be deleted', tone: 'danger' }),
      ),
    )
    expect(screen.getByRole('dialog', { name: 'Delete compliance record?' })).toBeVisible()

    await user.click(within(dialog).getByRole('button', { name: 'Delete record' }))
    await waitFor(() => expect(deleteSpy).toHaveBeenCalledWith(complianceRecord.id))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Compliance record deleted', tone: 'success' }),
      ),
    )
    expect(
      screen.queryByRole('dialog', { name: 'Delete compliance record?' }),
    ).not.toBeInTheDocument()
  })

  it('opens a Compliance details page with the full record and safe attachment links', async () => {
    const user = userEvent.setup()
    vi.mocked(complianceApi.list).mockResolvedValueOnce({
      count: 1,
      items: [
        {
          ...complianceRecord,
          documents: ['https://files.example.test/current-license.png', 'javascript:alert(1)'],
        },
      ],
    })
    vi.mocked(complianceApi.detail).mockResolvedValueOnce({
      ...complianceRecord,
      days_until_expiry: 1,
      documents: ['https://files.example.test/current-license.png', 'javascript:alert(1)'],
    })
    renderGovernanceRoute(
      '/company/compliance?search=license&complianceType=real_estate_license&page=2',
      compliancePermissions,
    )

    await user.click(await screen.findByRole('link', { name: 'Details' }))

    expect(await screen.findByRole('heading', { name: 'Real Estate License' })).toBeVisible()
    expect(screen.getByRole('heading', { name: 'QA Compliance Owner' })).toBeVisible()
    expect(screen.getByText('Synthetic test record.')).toBeVisible()
    expect(screen.getByText('Jan 1, 2026')).toBeVisible()
    expect(screen.getByText('1 day remaining')).toBeVisible()
    expect(screen.getByRole('link', { name: 'Open current-license.png' })).toHaveAttribute(
      'href',
      'https://files.example.test/current-license.png',
    )
    expect(screen.queryByRole('link', { name: /javascript:/ })).not.toBeInTheDocument()
    expect(screen.getByText('Document 2 · link unavailable')).toBeVisible()
    expect(screen.getByRole('link', { name: 'Back to Compliance register' })).toHaveAttribute(
      'href',
      '/company/compliance?search=license&complianceType=real_estate_license&page=2',
    )
    expect(complianceApi.detail).toHaveBeenCalledWith(complianceRecord.id, expect.any(AbortSignal))
    await user.click(screen.getByRole('link', { name: 'Back to Compliance register' }))
    expect(await screen.findByRole('heading', { name: 'Compliance register' })).toBeVisible()
  })

  it('shows a not-found state for removed Compliance details and an invalid-id state without fetching', async () => {
    const user = userEvent.setup()
    vi.mocked(complianceApi.detail).mockRejectedValueOnce(
      new ApiError('Not found', { status: 404 }),
    )
    const rendered = renderGovernanceRoute(
      '/company/compliance/999?search=&complianceType=&page=1',
      compliancePermissions,
    )

    expect(
      await screen.findByRole('heading', { level: 2, name: 'Compliance record not found' }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Back to Compliance' }))
    expect(await screen.findByRole('heading', { name: 'Compliance register' })).toBeVisible()

    rendered.unmount()
    renderGovernanceRoute(
      '/company/compliance/not-a-number?search=&complianceType=&page=1',
      compliancePermissions,
    )
    expect(await screen.findByText('This record link is invalid')).toBeVisible()
    expect(complianceApi.detail).toHaveBeenCalledTimes(1)
  })

  it('retries a transient Compliance detail error without losing the route', async () => {
    const user = userEvent.setup()
    vi.mocked(complianceApi.detail)
      .mockRejectedValueOnce(new ApiError('Temporary failure', { status: 503 }))
      .mockResolvedValueOnce(complianceRecord)
    renderGovernanceRoute(
      '/company/compliance/52?search=&complianceType=&page=1',
      compliancePermissions,
    )

    await user.click(await screen.findByRole('button', { name: 'Retry details' }))

    expect(await screen.findByRole('heading', { name: 'QA Compliance Owner' })).toBeVisible()
    expect(complianceApi.detail).toHaveBeenCalledTimes(2)
  })

  it('opens the meeting details screen from its list card', async () => {
    const user = userEvent.setup()
    vi.mocked(governanceApi.meetings).mockResolvedValueOnce({ count: 1, items: [meeting] })
    vi.mocked(governanceApi.meeting).mockResolvedValueOnce({
      ...meeting,
      attendees: [{ user_id: 91, full_name: 'QA Attendee', email: 'attendee@example.test' }],
      attendee_count: 1,
      file_url: 'https://files.example.test/meeting-agenda.pdf',
    })
    renderGovernanceRoute('/company/board?tab=meetings&search=&page=1', boardPermissions)

    await user.click(await screen.findByRole('link', { name: 'Details' }))

    expect(
      await screen.findByRole('heading', { name: 'Quarterly governance review' }),
    ).toBeVisible()
    expect(screen.getByRole('heading', { name: 'Schedule and location' })).toBeVisible()
    expect(screen.getByText('Review delivery, risk, and policy updates.')).toBeVisible()
    expect(screen.getByText('QA Attendee')).toBeVisible()
    expect(screen.getByRole('link', { name: 'Open file' })).toHaveAttribute(
      'href',
      'https://files.example.test/meeting-agenda.pdf',
    )
    expect(governanceApi.meeting).toHaveBeenCalledWith(meeting.id, expect.any(AbortSignal))
  })

  it.each([
    ['meetings', meeting.id, 'Quarterly governance review', 'Schedule and location'],
    ['resolutions', resolution.id, 'QA governance resolution', 'Approval history'],
    ['investors', shareholder.id, 'QA Shareholder', 'Ownership'],
    ['associates', associate.user_id, 'QA Associate', 'Employment'],
    ['partners', partner.id, 'QA Partner', 'Partner profile'],
  ] as const)(
    'shows a tailored details view for %s records',
    async (section, id, title, sectionHeading) => {
      renderGovernanceRoute(
        `/company/board/${section}/${id}?tab=${section}&search=&page=1`,
        boardPermissions,
      )

      expect(await screen.findByRole('heading', { name: title })).toBeVisible()
      expect(screen.getByRole('heading', { name: sectionHeading })).toBeVisible()
      expect(screen.getByRole('link', { name: 'Back to Board' })).toBeVisible()
    },
  )

  it('keeps associates details limited to work information', async () => {
    renderGovernanceRoute(
      `/company/board/associates/${associate.user_id}?tab=associates&search=&page=1`,
      boardPermissions,
    )

    expect(await screen.findByRole('heading', { name: 'QA Associate' })).toBeVisible()
    expect(screen.getByText('Lagos office')).toBeVisible()
    expect(screen.queryByText(/gross salary|bank account|tax id/i)).not.toBeInTheDocument()
  })

  it('shows a retryable error when a Board detail request fails', async () => {
    const user = userEvent.setup()
    vi.mocked(governanceApi.meeting).mockRejectedValueOnce(new Error('Temporary API failure'))
    renderGovernanceRoute(
      `/company/board/meetings/${meeting.id}?tab=meetings&search=&page=1`,
      boardPermissions,
    )

    expect(
      await screen.findByRole('heading', { name: 'Meeting details could not load' }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Retry details' }))
    expect(
      await screen.findByRole('heading', { name: 'Quarterly governance review' }),
    ).toBeVisible()
  })
})
