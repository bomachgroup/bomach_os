import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { tab: 'announcements', search: '', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return { ...actual, useSearch: () => routeState.search, useNavigate: () => routeState.navigate }
})

import { broadcastApi } from '@/modules/company/broadcast.api'
import { branchesApi, type BranchDto } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import type { DepartmentDto } from '@/modules/company/company-organization.api'
import { notificationApi } from '@/shared/notifications/notifications.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import type { ToastOptions } from '@/shared/feedback/toast-types'
import { BroadcastPage } from './broadcast-page'

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

const session = (permissions: AuthenticatedSession['permissions']) =>
  ({
    user: {
      id: 12,
      email: 'admin@example.com',
      username: 'admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: { user_id: 12, employee_id: 'EMP-12', username: 'admin', email: 'admin@example.com' },
    roles: [],
    permissions,
  }) as AuthenticatedSession

const announcement = {
  id: 1,
  announcement_id: 'ANN-001',
  title: 'Office maintenance notice',
  content: 'The main office will be closed for maintenance on Friday.',
  announcement_type: 'general',
  announcement_type_display: 'General',
  priority: 'normal',
  priority_display: 'Normal',
  branches: [],
  departments: [],
  targets_all_branches: true,
  targets_all_departments: true,
  created_by_id: 12,
  created_by_name: 'Test Admin',
  is_active: true,
  publish_at: null,
  expires_at: null,
  created_at: '2026-10-25T09:00:00Z',
  updated_at: '2026-10-25T09:00:00Z',
}

const scopedAnnouncement = {
  ...announcement,
  branches: [{ id: 7, branch_name: 'Enugu', branch_id: 'ENUGU' }],
  departments: [{ id: 21, name: 'Operations' }],
  targets_all_branches: false,
  targets_all_departments: false,
}

const branches: BranchDto[] = [
  {
    id: 7,
    branch_name: 'Enugu',
    branch_id: 'ENUGU',
    default_currency: 'NGN',
    language_preference: 'en',
    country: 'Nigeria',
    country_code: 'NG',
    state: 'Enugu',
    state_code: 'EN',
    city: 'Enugu',
    lga: 'Enugu North',
    office_address: '1 QA Road',
    full_address: '1 QA Road, Enugu',
    operational_status: 'active',
    operational_status_display: 'Active',
    branch_role: 'branch',
    branch_role_display: 'Branch',
    contact_email: '',
    contact_phone: '',
    manager_id: null,
    manager_name: null,
    is_active: true,
    is_operational: true,
    latitude: null,
    longitude: null,
    attendance_radius_meters: 100,
    notes: null,
    created_at: '2026-01-01T00:00:00Z',
    updated_at: '2026-01-01T00:00:00Z',
  },
]

const departments: DepartmentDto[] = [
  { id: 21, name: 'Operations', description: '' },
  { id: 24, name: 'Finance', description: '' },
]

const eventStartDate = new Date()
eventStartDate.setDate(eventStartDate.getDate() + 2)
eventStartDate.setHours(9, 0, 0, 0)
const eventEndDate = new Date(eventStartDate)
eventEndDate.setHours(10, 0, 0, 0)

const event = {
  id: 8,
  event_id: 'EVT-008',
  title: 'Quarterly planning',
  event_type: 'STRATEGIC_PLANNING',
  event_type_display: 'Strategic Planning',
  event_time_from: '26-10-2026, 10:00 AM',
  event_time_to: '26-10-2026, 11:00 AM',
  event_time_from_iso: eventStartDate.toISOString(),
  event_time_to_iso: eventEndDate.toISOString(),
  meeting_location: 'Main office',
  target_audience: ['All Associates'],
  target_all_branches: true,
  target_all_departments: true,
  target_associates: true,
  target_investors: false,
  target_partners: false,
  status: 'Active',
  reminder_offset: '60 minutes before',
  is_recurring: false,
  recurrence: 'No Recurrence',
  organizer_id: 12,
  organizer_name: 'Test Admin',
  date_sent: '25-10-2026, 09:00 AM',
  created_at: '2026-10-25T09:00:00Z',
  updated_at: '2026-10-25T09:00:00Z',
}

const announcementChoices = {
  announcement_types: [{ value: 'general', label: 'General' }],
  priorities: [{ value: 'normal', label: 'Normal' }],
}

const eventChoices = {
  event_types: [{ value: 'GENERAL_MEETING', label: 'General Meeting' }],
}

async function setTime(
  user: ReturnType<typeof userEvent.setup>,
  id: string,
  hour: string,
  minute: string,
  period: 'AM' | 'PM',
) {
  const trigger = document.getElementById(id)
  expect(trigger).toBeInTheDocument()
  expect(trigger).toBeEnabled()
  await user.click(trigger!)
  expect(trigger).toHaveAttribute('aria-expanded', 'true')
  const picker = await screen.findByRole('dialog', { name: 'Choose a time', hidden: true })
  for (const [label, option] of [
    ['Hour', hour],
    ['Minute', minute],
    ['AM or PM', period],
  ]) {
    await user.click(within(picker).getByRole('combobox', { name: label }))
    await user.click(screen.getByRole('option', { name: option }))
  }
  await user.click(within(picker).getByRole('button', { name: 'Set time' }))
}

let queryClient: QueryClient
let showToastSpy: ReturnType<typeof vi.fn<(options: ToastOptions) => void>>

function renderPage(permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  showToastSpy = vi.fn<(options: ToastOptions) => void>()
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  return render(
    <ToastContext.Provider value={{ showToast: showToastSpy, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <BroadcastPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('BroadcastPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    routeState.navigate.mockReset()
    routeState.search = { tab: 'announcements', search: '', page: 1 }
    vi.spyOn(broadcastApi, 'announcements').mockResolvedValue({ count: 1, items: [announcement] })
    vi.spyOn(broadcastApi, 'events').mockResolvedValue({ count: 1, items: [event] })
    vi.spyOn(broadcastApi, 'announcementChoices').mockResolvedValue(announcementChoices)
    vi.spyOn(broadcastApi, 'eventChoices').mockResolvedValue(eventChoices)
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({
      count: departments.length,
      items: departments,
    })
    vi.spyOn(notificationApi, 'list')
  })

  it('renders the announcement register and hides tabs without list permission', async () => {
    renderPage({ announcements: ['list'] })
    expect(await screen.findByText('Office maintenance notice')).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Announcements' })).toBeInTheDocument()
    expect(screen.queryByRole('tab', { name: 'Events' })).not.toBeInTheDocument()
    expect(screen.queryByRole('tab', { name: 'Notifications' })).not.toBeInTheDocument()
    expect(screen.queryByText('Permission-aware audience')).not.toBeInTheDocument()
    expect(
      screen.queryByRole('button', { name: 'Open notification center' }),
    ).not.toBeInTheDocument()
  })

  it('places announcement actions in a footer below the content', async () => {
    renderPage({ announcements: ['list', 'update', 'delete'] })

    const title = await screen.findByRole('heading', { name: 'Office maintenance notice' })
    const card = title.closest('article')
    expect(card).not.toBeNull()
    expect(card).not.toHaveClass('tablet:flex-row')

    const actions = within(card!).getByRole('button', { name: 'View' }).parentElement
    expect(actions).toHaveClass('border-t', 'pt-3', 'justify-end')
    expect(card!.lastElementChild).toBe(actions)
    expect(within(card!).getByRole('button', { name: 'Edit' })).toBeInTheDocument()
    expect(within(card!).getByRole('button', { name: 'Deactivate' })).toBeInTheDocument()
  })

  it('renders event records from the event tab without inventing unsupported date fields', async () => {
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list'] })
    expect(await screen.findByText('Quarterly planning')).toBeInTheDocument()
    expect(screen.getByText(/Strategic Planning/)).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Events' })).toHaveAttribute('aria-selected', 'true')
  })

  it('places event actions in a right-aligned footer below the card content', async () => {
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'update', 'delete'] })

    const title = await screen.findByRole('heading', { name: 'Quarterly planning' })
    const card = title.closest('article')
    expect(card).not.toBeNull()
    expect(card).not.toHaveClass('tablet:flex-row')

    const actions = within(card!).getByRole('button', { name: 'Details' }).parentElement
    expect(actions).toHaveClass('border-t', 'pt-3', 'justify-end')
    expect(card!.lastElementChild).toBe(actions)
    expect(within(card!).getByRole('button', { name: 'Edit' })).toBeInTheDocument()
    expect(within(card!).getByRole('button', { name: 'Delete' })).toBeInTheDocument()
  })

  it('does not offer event editing after its start time has passed', async () => {
    const start = new Date()
    start.setDate(start.getDate() - 2)
    const end = new Date(start)
    end.setHours(end.getHours() + 1)
    vi.mocked(broadcastApi.events).mockResolvedValue({
      count: 1,
      items: [
        {
          ...event,
          event_time_from_iso: start.toISOString(),
          event_time_to_iso: end.toISOString(),
          status: 'Expired',
        },
      ],
    })
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'update', 'delete'] })

    const title = await screen.findByRole('heading', { name: 'Quarterly planning' })
    const card = title.closest('article')
    expect(card).not.toBeNull()
    expect(within(card!).queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(within(card!).getByText('Editing closes when an event starts.')).toBeInTheDocument()
    expect(within(card!).getByRole('button', { name: 'Details' })).toBeInTheDocument()
    expect(within(card!).getByRole('button', { name: 'Delete' })).toBeInTheDocument()
  })

  it('updates an event and closes only after the update succeeds', async () => {
    const user = userEvent.setup()
    const updateEvent = vi
      .spyOn(broadcastApi, 'updateEvent')
      .mockResolvedValue({ ...event, title: 'Quarterly planning updated' })
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'update'] })

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = await screen.findByRole('dialog', { name: 'Edit event' })
    const title = within(dialog).getByRole('textbox', { name: 'Event title' })
    await user.clear(title)
    await user.type(title, 'Quarterly planning updated')
    await user.click(within(dialog).getByRole('button', { name: 'Save event' }))

    await waitFor(() => expect(updateEvent).toHaveBeenCalledTimes(1))
    expect(updateEvent).toHaveBeenCalledWith(event.id, {
      title: 'Quarterly planning updated',
      event_type: event.event_type,
      event_time_from: event.event_time_from_iso,
      event_time_to: event.event_time_to_iso,
      meeting_location: event.meeting_location,
      target_all_branches: true,
      target_all_departments: true,
      target_associates: true,
      target_investors: false,
      target_partners: false,
      reminder_offset: 60,
      recurrence: null,
    })
    expect(screen.queryByRole('dialog', { name: 'Edit event' })).not.toBeInTheDocument()
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Event updated', tone: 'success' }),
    )
  })

  it('keeps event edits in the form when the update request fails', async () => {
    const user = userEvent.setup()
    const updateEvent = vi
      .spyOn(broadcastApi, 'updateEvent')
      .mockRejectedValue(new Error('Local API unavailable'))
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'update'] })

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    const dialog = await screen.findByRole('dialog', { name: 'Edit event' })
    const title = within(dialog).getByRole('textbox', { name: 'Event title' })
    await user.clear(title)
    await user.type(title, 'Quarterly planning retry')
    await user.click(within(dialog).getByRole('button', { name: 'Save event' }))

    await waitFor(() => expect(updateEvent).toHaveBeenCalledTimes(1))
    const saveAlert = within(dialog).getByRole('alert')
    expect(saveAlert).toHaveTextContent('Event could not be saved')
    expect(dialog.querySelector('#broadcast-event-form')).toContainElement(saveAlert)
    expect(title).toHaveValue('Quarterly planning retry')
    expect(within(dialog).getByRole('button', { name: 'Save event' })).toBeEnabled()
  })

  it('organizes announcement details by message, publication, and audience', async () => {
    const user = userEvent.setup()
    renderPage({ announcements: ['list'] })

    await user.click(await screen.findByRole('button', { name: 'View' }))
    const dialog = await screen.findByRole('dialog', { name: 'Office maintenance notice' })

    expect(within(dialog).getByRole('heading', { name: 'Message' })).toBeInTheDocument()
    expect(within(dialog).getByRole('heading', { name: 'Publication' })).toBeInTheDocument()
    expect(within(dialog).getByRole('heading', { name: 'Audience' })).toBeInTheDocument()
    expect(within(dialog).getByText('Published immediately')).toBeInTheDocument()
    expect(within(dialog).getByText('No expiry set')).toBeInTheDocument()
    expect(within(dialog).getByText('All branches')).toBeInTheDocument()
    expect(within(dialog).getByText('Company-wide')).toBeInTheDocument()
    expect(
      within(dialog).getByText('This announcement is visible across all departments.'),
    ).toBeInTheDocument()
  })

  it('presents targeted announcement audiences as readable, labeled target lists', async () => {
    const user = userEvent.setup()
    const targetedAnnouncement = {
      ...announcement,
      targets_all_branches: false,
      targets_all_departments: false,
      branches: [
        { id: 7, branch_id: 'ENUGU', branch_name: 'Enugu' },
        {
          id: 8,
          branch_id: 'PORT-HARCOURT',
          branch_name: 'Port Harcourt Regional Office',
        },
        {
          id: 9,
          branch_id: 'QA-PREVIEW',
          branch_name: 'QA Responsive Preview Branch',
        },
      ],
      departments: [
        { id: 21, name: 'Operations' },
        { id: 24, name: 'Finance' },
      ],
    }
    vi.spyOn(broadcastApi, 'announcements').mockResolvedValue({
      count: 1,
      items: [targetedAnnouncement],
    })
    renderPage({ announcements: ['list'] })

    await user.click(await screen.findByRole('button', { name: 'View' }))
    const dialog = await screen.findByRole('dialog', { name: 'Office maintenance notice' })
    const branchList = within(dialog).getByRole('list', { name: 'Selected branches' })
    const departmentList = within(dialog).getByRole('list', { name: 'Selected departments' })
    const audienceSection = within(dialog)
      .getByRole('heading', { name: 'Audience' })
      .closest('section')
    const audienceGrid = audienceSection?.querySelector(':scope > div.grid')

    expect(within(dialog).getByText('Targeted audience')).toBeInTheDocument()
    expect(within(dialog).getByText('3 branches selected')).toBeInTheDocument()
    expect(within(dialog).getByText('2 departments selected')).toBeInTheDocument()
    expect(within(branchList).getAllByRole('listitem')).toHaveLength(3)
    expect(within(branchList).getByText('Port Harcourt Regional Office')).toBeInTheDocument()
    expect(within(branchList).getByText('QA Responsive Preview Branch')).toBeInTheDocument()
    expect(within(departmentList).getAllByRole('listitem')).toHaveLength(2)
    expect(within(departmentList).getByText('Finance')).toBeInTheDocument()
    expect(audienceGrid).toHaveClass('tablet:grid-cols-2')
    expect(audienceGrid).not.toHaveClass('phone:grid-cols-2')
  })

  it('creates an announcement with selected branch and department database IDs', async () => {
    const user = userEvent.setup()
    const createAnnouncement = vi.spyOn(broadcastApi, 'createAnnouncement').mockResolvedValue({
      ...scopedAnnouncement,
      title: 'Scoped QA announcement',
      content: 'Visible only to the selected branch and department.',
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: branches.length, items: branches })
    const listDepartments = vi
      .spyOn(companyOrganizationApi, 'departments')
      .mockResolvedValue({ count: departments.length, items: departments })
    renderPage({
      announcements: ['list', 'create'],
      branches: ['list'],
      departments: ['list'],
    })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    await user.type(
      screen.getByRole('textbox', { name: 'Announcement title' }),
      'Scoped QA announcement',
    )
    await user.type(
      screen.getByRole('textbox', { name: 'Message' }),
      'Visible only to the selected branch and department.',
    )
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: 'All branches' })).toBeEnabled()
      expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeEnabled()
    })
    await user.click(screen.getByRole('checkbox', { name: 'All branches' }))
    await user.click(screen.getByRole('checkbox', { name: 'All departments' }))
    await user.click(screen.getByRole('checkbox', { name: 'Enugu' }))
    await user.click(screen.getByRole('checkbox', { name: 'Operations' }))
    await user.click(screen.getByRole('button', { name: 'Publish announcement' }))

    await waitFor(() =>
      expect(createAnnouncement).toHaveBeenCalledWith({
        title: 'Scoped QA announcement',
        content: 'Visible only to the selected branch and department.',
        announcement_type: 'general',
        priority: 'normal',
        branch_ids: [7],
        department_ids: [21],
        is_active: true,
        publish_at: null,
        expires_at: null,
      }),
    )
    expect(listDepartments).toHaveBeenCalledWith(
      { limit: 100, offset: 0, search: '' },
      expect.anything(),
    )
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Announcement published', tone: 'success' }),
    )
  })

  it('updates a scoped announcement without changing its branch and with the new department ID', async () => {
    const user = userEvent.setup()
    const updateAnnouncement = vi
      .spyOn(broadcastApi, 'updateAnnouncement')
      .mockResolvedValue({ ...scopedAnnouncement, departments: [{ id: 24, name: 'Finance' }] })
    vi.spyOn(broadcastApi, 'announcements').mockResolvedValue({
      count: 1,
      items: [scopedAnnouncement],
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: branches.length, items: branches })
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({
      count: departments.length,
      items: departments,
    })
    renderPage({
      announcements: ['list', 'update'],
      branches: ['list'],
      departments: ['list'],
    })

    await user.click(await screen.findByRole('button', { name: 'Edit' }))
    expect(await screen.findByRole('checkbox', { name: 'Enugu' })).toBeChecked()
    expect(screen.getByRole('checkbox', { name: 'Operations' })).toBeChecked()
    await user.click(screen.getByRole('checkbox', { name: 'Operations' }))
    await user.click(screen.getByRole('checkbox', { name: 'Finance' }))
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(updateAnnouncement).toHaveBeenCalledWith(
        scopedAnnouncement.id,
        expect.objectContaining({ branch_ids: [7], department_ids: [24] }),
      ),
    )
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Announcement updated', tone: 'success' }),
    )
  })

  it('sends empty audience arrays only when all branches and departments are selected', async () => {
    const user = userEvent.setup()
    const createAnnouncement = vi
      .spyOn(broadcastApi, 'createAnnouncement')
      .mockResolvedValue(announcement)
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: branches.length, items: branches })
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({
      count: departments.length,
      items: departments,
    })
    renderPage({
      announcements: ['list', 'create'],
      branches: ['list'],
      departments: ['list'],
    })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    await user.type(screen.getByRole('textbox', { name: 'Announcement title' }), 'All audience QA')
    await user.type(
      screen.getByRole('textbox', { name: 'Message' }),
      'For every branch and department.',
    )
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: 'All branches' })).toBeEnabled()
      expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeEnabled()
    })
    await user.click(screen.getByRole('button', { name: 'Publish announcement' }))

    await waitFor(() =>
      expect(createAnnouncement).toHaveBeenCalledWith(
        expect.objectContaining({ branch_ids: [], department_ids: [] }),
      ),
    )
  })

  it('requires at least one target when a specific audience is selected and focuses that option', async () => {
    const user = userEvent.setup()
    const createAnnouncement = vi
      .spyOn(broadcastApi, 'createAnnouncement')
      .mockResolvedValue(announcement)
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: branches.length, items: branches })
    vi.spyOn(companyOrganizationApi, 'departments').mockResolvedValue({
      count: departments.length,
      items: departments,
    })
    renderPage({
      announcements: ['list', 'create'],
      branches: ['list'],
      departments: ['list'],
    })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    await user.type(
      screen.getByRole('textbox', { name: 'Announcement title' }),
      'Empty audience QA',
    )
    await user.type(screen.getByRole('textbox', { name: 'Message' }), 'Selection validation.')
    await waitFor(() => {
      expect(screen.getByRole('checkbox', { name: 'All branches' })).toBeEnabled()
      expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeEnabled()
    })
    await user.click(screen.getByRole('checkbox', { name: 'All branches' }))
    await user.click(screen.getByRole('checkbox', { name: 'All departments' }))
    await user.click(screen.getByRole('button', { name: 'Publish announcement' }))

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Select at least one branch or choose All branches.',
    )
    expect(screen.getByRole('checkbox', { name: 'Enugu' })).toHaveFocus()
    expect(createAnnouncement).not.toHaveBeenCalled()
  })

  it('shows and retries a failed department audience lookup without silently widening a selection', async () => {
    const user = userEvent.setup()
    const listDepartments = vi
      .spyOn(companyOrganizationApi, 'departments')
      .mockRejectedValueOnce(new Error('Local API unavailable'))
      .mockResolvedValue({ count: departments.length, items: departments })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: branches.length, items: branches })
    renderPage({
      announcements: ['list', 'create'],
      branches: ['list'],
      departments: ['list'],
    })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    expect(await screen.findByRole('alert')).toHaveTextContent('Could not load departments')
    expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeChecked()
    expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeDisabled()
    await user.click(screen.getByRole('button', { name: 'Retry' }))
    await waitFor(() =>
      expect(screen.getByRole('checkbox', { name: 'All departments' })).toBeEnabled(),
    )
    await user.click(screen.getByRole('checkbox', { name: 'All departments' }))
    expect(await screen.findByRole('checkbox', { name: 'Operations' })).toBeInTheDocument()
    expect(listDepartments).toHaveBeenCalledTimes(2)
  })

  it('organizes event details around timing, event information, and audience', async () => {
    const user = userEvent.setup()
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list'] })

    await user.click(await screen.findByRole('button', { name: 'Details' }))
    const dialog = await screen.findByRole('dialog', { name: 'Quarterly planning' })

    expect(within(dialog).getByText('Starts')).toBeInTheDocument()
    expect(within(dialog).getByText('Ends')).toBeInTheDocument()
    expect(within(dialog).getByRole('heading', { name: 'Event details' })).toBeInTheDocument()
    expect(within(dialog).getByRole('heading', { name: 'Audience' })).toBeInTheDocument()
    expect(within(dialog).getByText('Main office')).toBeInTheDocument()
    expect(within(dialog).getByText('All Associates')).toBeInTheDocument()
  })

  it('confirms successful announcement deactivation', async () => {
    const user = userEvent.setup()
    const deactivate = vi
      .spyOn(broadcastApi, 'deactivateAnnouncement')
      .mockResolvedValue({ detail: 'Announcement deactivated successfully' })
    renderPage({ announcements: ['list', 'delete'] })

    await user.click(await screen.findByRole('button', { name: 'Deactivate' }))
    const dialog = await screen.findByRole('dialog', { name: 'Deactivate announcement' })
    await user.click(within(dialog).getByRole('button', { name: 'Deactivate' }))

    await waitFor(() => expect(deactivate).toHaveBeenCalledWith(announcement.id))
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Announcement deactivated', tone: 'success' }),
    )
  })

  it('confirms successful event deletion', async () => {
    const user = userEvent.setup()
    const removeEvent = vi.spyOn(broadcastApi, 'deleteEvent').mockResolvedValue(undefined)
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'delete'] })

    await user.click(await screen.findByRole('button', { name: 'Delete' }))
    const dialog = await screen.findByRole('dialog', { name: 'Delete event' })
    await user.click(within(dialog).getByRole('button', { name: 'Delete event' }))

    await waitFor(() => expect(removeEvent).toHaveBeenCalledWith(event.id))
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Event deleted', tone: 'success' }),
    )
  })

  it('recovers from an announcement list error without losing the current route state', async () => {
    const user = userEvent.setup()
    const listAnnouncements = vi
      .spyOn(broadcastApi, 'announcements')
      .mockRejectedValueOnce(new Error('Local API unavailable'))
      .mockResolvedValue({ count: 1, items: [announcement] })
    renderPage({ announcements: ['list'] })

    await waitFor(() => expect(listAnnouncements).toHaveBeenCalledTimes(1))
    await user.click(await screen.findByRole('button', { name: 'Try again' }))

    expect(await screen.findByText('Office maintenance notice')).toBeInTheDocument()
    expect(listAnnouncements).toHaveBeenCalledTimes(2)
  })

  it('uses the compact visual create label for announcements below tablet', async () => {
    renderPage({ announcements: ['list', 'create'] })
    const button = await screen.findByRole('button', { name: 'New announcement' })
    expect(within(button).getByText('New')).toHaveClass('max-[361px]:hidden', 'phone:hidden')
    expect(within(button).getByText('New announcement')).toHaveClass('hidden', 'phone:inline')
  })

  it('uses the compact visual create label for events below tablet', async () => {
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'create'] })
    const button = await screen.findByRole('button', { name: 'New event' })
    expect(within(button).getByText('New')).toHaveClass('max-[361px]:hidden', 'phone:hidden')
    expect(within(button).getByText('New event')).toHaveClass('hidden', 'phone:inline')
  })

  it('links to the canonical notification center without embedding a duplicate inbox', async () => {
    const user = userEvent.setup()
    renderPage({ announcements: ['list'], notifications: ['list'] })

    const notificationsLink = await screen.findByRole('button', {
      name: 'Open notification center',
    })
    expect(screen.queryByRole('tab', { name: 'Notifications' })).not.toBeInTheDocument()
    await user.click(notificationsLink)
    expect(routeState.navigate).toHaveBeenCalledWith({ to: '/notifications' })
    expect(notificationApi.list).not.toHaveBeenCalled()
  })

  it('uses the shared calendar in announcement schedule fields', async () => {
    const user = userEvent.setup()
    const { container } = renderPage({ announcements: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    const dateTrigger = document.getElementById('announcement-publish-date') as HTMLButtonElement
    expect(dateTrigger).toBeInTheDocument()
    expect(container.querySelector('input[type="datetime-local"]')).not.toBeInTheDocument()
    expect(dateTrigger).toHaveAttribute('aria-haspopup', 'dialog')
    await user.click(screen.getByRole('switch', { name: 'Publish immediately' }))
    expect(dateTrigger).toBeEnabled()

    await user.click(dateTrigger)
    expect(await screen.findByRole('dialog', { name: 'Choose a date' })).toBeInTheDocument()
    await user.keyboard('{Escape}')
    expect(screen.queryByRole('dialog', { name: 'Choose a date' })).not.toBeInTheDocument()
  })

  it('validates event dates and maps audience, reminder, and recurrence choices', async () => {
    const user = userEvent.setup()
    const createEvent = vi.spyOn(broadcastApi, 'createEvent').mockResolvedValue(event)
    routeState.search = { tab: 'events', search: '', page: 1 }
    const { container } = renderPage({ events: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New event' }))
    await screen.findByText('Schedule and location')
    expect(container.querySelector('input[type="datetime-local"]')).not.toBeInTheDocument()
    const eventForm = document.getElementById('broadcast-event-form') as HTMLFormElement
    expect(eventForm).toHaveAttribute('novalidate')
    const audienceTrigger = document.getElementById('event-audience') as HTMLButtonElement
    expect(audienceTrigger).toHaveClass('text-body-sm')
    expect(audienceTrigger).toHaveAccessibleName('Notify audience: All branches, All departments')
    expect(within(audienceTrigger).getByText('2')).toHaveClass('size-5', 'text-overline')
    await user.click(screen.getByRole('button', { name: 'Create event' }))
    const details = document.getElementById('event-information-heading')?.closest('section')
    expect(details).not.toBeNull()
    expect(within(details!).getByRole('alert')).toHaveTextContent('Enter an event title')
    expect(container.querySelector('#broadcast-event-form > [role="alert"]')).toBeNull()
    expect(createEvent).not.toHaveBeenCalled()

    await user.type(document.getElementById('event-title')!, 'Synthetic QA event')
    expect(within(details!).queryByRole('alert')).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Create event' }))
    const schedule = document.getElementById('event-schedule-heading')?.closest('section')
    expect(schedule).not.toBeNull()
    expect(within(schedule!).getByRole('alert')).toHaveTextContent(
      'Choose a valid start and end time',
    )
    expect(document.querySelector('#broadcast-event-form > [role="alert"]')).toBeNull()
    expect(createEvent).not.toHaveBeenCalled()

    const startDate = new Date()
    startDate.setDate(startDate.getDate() + 2)
    const formatDate = (date: Date) =>
      new Intl.DateTimeFormat(undefined, {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(date)
    const toDateValue = (date: Date) =>
      `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`

    await user.click(document.getElementById('event-start-date')!)
    const startCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(startCalendar).getByRole('button', { name: formatDate(startDate) }))

    const endDate = new Date(startDate)
    await user.click(document.getElementById('event-end-date')!)
    const endCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(endCalendar).getByRole('button', { name: formatDate(endDate) }))
    await setTime(user, 'event-start-time', '10', '00', 'AM')
    await setTime(user, 'event-end-time', '09', '00', 'AM')
    await user.click(screen.getByRole('button', { name: 'Create event' }))
    expect(within(schedule!).getByRole('alert')).toHaveTextContent(
      'The event end date and time must be later than its start.',
    )
    expect(createEvent).not.toHaveBeenCalled()

    await setTime(user, 'event-start-time', '09', '00', 'AM')
    await setTime(user, 'event-end-time', '10', '00', 'AM')

    await user.click(screen.getByRole('combobox', { name: 'Reminder' }))
    await user.click(screen.getByRole('option', { name: '1 hour before' }))
    await user.click(screen.getByRole('combobox', { name: 'Repeats' }))
    await user.click(screen.getByRole('option', { name: 'Weekly' }))

    await user.click(audienceTrigger)
    const audienceMenu = await screen.findByRole('dialog', { name: 'Notify audience' })
    await user.click(within(audienceMenu).getByRole('checkbox', { name: 'All branches' }))
    expect(audienceTrigger).toHaveAccessibleName('Notify audience: All departments')
    expect(within(audienceTrigger).getByText('1 group selected')).toBeInTheDocument()
    await user.click(within(audienceMenu).getByRole('checkbox', { name: 'All branches' }))
    await user.click(within(audienceMenu).getByRole('checkbox', { name: 'All associates' }))
    await user.click(within(audienceMenu).getByRole('checkbox', { name: 'All investors' }))
    await user.click(within(audienceMenu).getByRole('checkbox', { name: 'All departments' }))
    await user.keyboard('{Escape}')

    await user.click(screen.getByRole('button', { name: 'Create event' }))
    await waitFor(() => expect(createEvent).toHaveBeenCalledTimes(1))
    expect(createEvent).toHaveBeenCalledWith({
      title: 'Synthetic QA event',
      event_type: 'GENERAL_MEETING',
      event_time_from: new Date(`${toDateValue(startDate)}T09:00`).toISOString(),
      event_time_to: new Date(`${toDateValue(endDate)}T10:00`).toISOString(),
      meeting_location: null,
      target_all_branches: true,
      target_all_departments: false,
      target_associates: true,
      target_investors: true,
      target_partners: false,
      reminder_offset: 60,
      recurrence: 'RRULE:FREQ=WEEKLY;INTERVAL=1',
    })
    expect(screen.queryByRole('dialog', { name: 'Create event' })).not.toBeInTheDocument()
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Event created', tone: 'success' }),
    )
  })

  it('rejects an announcement whose expiry is not later than its publish time', async () => {
    const user = userEvent.setup()
    const createAnnouncement = vi
      .spyOn(broadcastApi, 'createAnnouncement')
      .mockResolvedValue(announcement)
    renderPage({ announcements: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    const publishImmediately = screen.getByRole('switch', { name: 'Publish immediately' })
    expect(publishImmediately).toBeChecked()
    expect(document.getElementById('announcement-publish-date')).toBeDisabled()
    await user.click(publishImmediately)
    expect(document.getElementById('announcement-publish-date')).toBeEnabled()
    await user.type(document.getElementById('announcement-title')!, 'Schedule validation')
    await user.type(
      document.getElementById('announcement-content')!,
      'Synthetic announcement content',
    )

    const publishDate = new Date()
    publishDate.setDate(publishDate.getDate() + 3)
    const dateLabel = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(publishDate)
    const fieldDateLabel = new Intl.DateTimeFormat(undefined, {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(publishDate)
    await user.click(document.getElementById('announcement-publish-date')!)
    const publishCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(publishCalendar).getByRole('button', { name: dateLabel }))
    expect(document.getElementById('announcement-publish-date')).toHaveTextContent(fieldDateLabel)
    await user.click(document.getElementById('announcement-expires-date')!)
    const expiryCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(expiryCalendar).getByRole('button', { name: dateLabel }))
    expect(document.getElementById('announcement-expires-date')).toHaveTextContent(fieldDateLabel)
    await setTime(user, 'announcement-publish-time', '09', '00', 'AM')
    await setTime(user, 'announcement-expires-time', '09', '00', 'AM')

    await user.click(screen.getByRole('button', { name: 'Publish announcement' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'must be later than the publication date and time',
    )
    expect(createAnnouncement).not.toHaveBeenCalled()
  })

  it('keeps an announcement draft when the save API fails and shows feedback', async () => {
    const user = userEvent.setup()
    const createAnnouncement = vi
      .spyOn(broadcastApi, 'createAnnouncement')
      .mockRejectedValue(new Error('Local API unavailable'))
    renderPage({ announcements: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New announcement' }))
    await user.type(
      screen.getByRole('textbox', { name: 'Announcement title' }),
      'UIQA-Broadcast-20261026 create failure',
    )
    await user.type(
      screen.getByRole('textbox', { name: 'Message' }),
      'Synthetic announcement content for failure recovery.',
    )
    await user.click(screen.getByRole('button', { name: 'Publish announcement' }))

    await waitFor(() => expect(createAnnouncement).toHaveBeenCalledTimes(1))
    expect(screen.getByRole('dialog', { name: 'Create announcement' })).toBeInTheDocument()
    expect(screen.getByRole('textbox', { name: 'Announcement title' })).toHaveValue(
      'UIQA-Broadcast-20261026 create failure',
    )
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Announcement could not be saved', tone: 'danger' }),
    )
  })

  it('keeps an event draft when the save API fails and shows feedback', async () => {
    const user = userEvent.setup()
    const createEvent = vi
      .spyOn(broadcastApi, 'createEvent')
      .mockRejectedValueOnce(new Error('Local API unavailable'))
      .mockResolvedValue(event)
    routeState.search = { tab: 'events', search: '', page: 1 }
    renderPage({ events: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New event' }))
    await user.type(
      screen.getByRole('textbox', { name: 'Event title' }),
      'UIQA-Broadcast-20261026 event failure',
    )
    const startDate = new Date()
    startDate.setDate(startDate.getDate() + 2)
    const endDate = new Date(startDate)
    endDate.setDate(endDate.getDate() + 1)
    const formatDate = (date: Date) =>
      new Intl.DateTimeFormat(undefined, {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(date)
    await user.click(document.getElementById('event-start-date')!)
    const startCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(startCalendar).getByRole('button', { name: formatDate(startDate) }))
    await user.click(document.getElementById('event-end-date')!)
    const endCalendar = await screen.findByRole('dialog', { name: 'Choose a date' })
    fireEvent.click(within(endCalendar).getByRole('button', { name: formatDate(endDate) }))
    await setTime(user, 'event-start-time', '09', '00', 'AM')
    await setTime(user, 'event-end-time', '10', '00', 'AM')
    await user.click(screen.getByRole('button', { name: 'Create event' }))

    await waitFor(() => expect(createEvent).toHaveBeenCalledTimes(1))
    const dialog = screen.getByRole('dialog', { name: 'Create event' })
    expect(dialog).toBeInTheDocument()
    expect(within(dialog).getByRole('textbox', { name: 'Event title' })).toHaveValue(
      'UIQA-Broadcast-20261026 event failure',
    )
    expect(within(dialog).getByRole('alert')).toHaveTextContent('Event could not be saved')
    expect(showToastSpy).not.toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Event could not be saved', tone: 'danger' }),
    )

    await user.click(within(dialog).getByRole('button', { name: 'Create event' }))
    await waitFor(() => expect(createEvent).toHaveBeenCalledTimes(2))
    expect(screen.queryByRole('dialog', { name: 'Create event' })).not.toBeInTheDocument()
    expect(showToastSpy).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Event created', tone: 'success' }),
    )
  })
})
