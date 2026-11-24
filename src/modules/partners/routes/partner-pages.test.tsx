import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { ReactNode } from 'react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  deskSearch: { search: '', page: 1 },
  portalSearch: { tab: 'home' as string },
  detailSearch: { tab: 'contacts' as string, conversation: undefined as number | undefined },
  params: { partnerId: '5' },
  searchFrom: '' as string | undefined,
  navigateFrom: '' as string | undefined,
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    useSearch: (options?: { from?: string }) => {
      routeState.searchFrom = options?.from
      if (options?.from === '/partners/app') return routeState.portalSearch
      if (options?.from?.includes('/company/partners/$partnerId')) return routeState.detailSearch
      return routeState.deskSearch
    },
    useParams: () => routeState.params,
    useNavigate: (options?: { from?: string }) => {
      routeState.navigateFrom = options?.from
      return routeState.navigate
    },
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { authApi } from '@/shared/auth/auth.api'
import { getWorkspaceMode, WORKSPACE_MODE_KEY } from '@/shared/auth/workspace-mode'
import { ToastContext } from '@/shared/feedback/toast-context'
import {
  partnerAdminApi,
  partnerQueryKeys,
  partnerPortalApi,
  type PartnerAdminDto,
  type PartnerInvitationDto,
  type PartnerProfileDto,
} from '@/modules/partners/partner.api'
import { PartnerDeskPage } from './partner-desk-page'
import { PartnerDetailPage } from './partner-detail-page'
import { PartnerLoginPage, PartnerSetupPage } from './partner-auth-pages'
import { PartnerPortalPage } from './partner-portal-page'

const staffSession: AuthenticatedSession = {
  user: {
    id: 11,
    email: 'staff@example.com',
    username: 'staff',
    first_name: 'Staff',
    last_name: 'User',
    is_verified: true,
    created_at: '2026-11-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    user_id: 11,
    employee_id: 'EMP-011',
    username: 'staff',
    email: 'staff@example.com',
    first_name: 'Staff',
    last_name: 'User',
  },
  roles: [],
  permissions: { partners: ['list', 'invite'] },
}

const partnerProfile: PartnerProfileDto = {
  id: 5,
  code: 'PT-005',
  name: 'Martha Partner',
  email: 'martha@example.com',
  phone: '',
  address: '',
  category: 'professional_services',
  partner_role: 'surveyor',
  status: 'active',
  kyc_status: 'pending',
  commission_rate: 0,
  territory: '',
  primary_branch_id: 12,
  branches: [{ id: 12, branch_name: 'Enugu', branch_id: 'EN-01' }],
  profile_completed: false,
  profile_completed_at: null,
  capabilities: { professional_jobs: true },
}

let queryClient: QueryClient
const showToast = vi.fn()

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

function renderPage(element: ReactNode, session: AuthenticatedSession = staffSession) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>{element}</QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('partner Batch 1 pages', () => {
  beforeEach(() => {
    window.localStorage.removeItem(WORKSPACE_MODE_KEY)
    window.localStorage.removeItem('bomach.partner.sidebar.collapsed')
    routeState.deskSearch = { search: '', page: 1 }
    routeState.portalSearch = { tab: 'home' }
    routeState.detailSearch = { tab: 'contacts', conversation: undefined }
    routeState.params = { partnerId: '5' }
    routeState.searchFrom = undefined
    routeState.navigateFrom = undefined
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(partnerAdminApi, 'partners').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 5,
          code: 'PT-005',
          name: 'Martha Surveyor',
          email: 'martha@example.com',
          phone: '',
          address: '',
          category: 'professional_services',
          status: 'pending',
          status_display: 'Pending',
          kyc_status: 'pending',
          kyc_status_display: 'Pending',
          commission_rate: 0,
          partner_role: 'surveyor',
          partner_role_display: 'Surveyor',
          primary_branch_id: 12,
          primary_branch_name: 'Enugu',
          authorized_branch_ids: [12],
          has_login: false,
          created_at: '2026-11-01T00:00:00Z',
          updated_at: '2026-11-01T00:00:00Z',
        } as PartnerAdminDto,
      ],
    })
    vi.spyOn(partnerAdminApi, 'partner').mockResolvedValue({
      id: 5,
      code: 'PT-005',
      name: 'Martha Surveyor',
      email: 'martha@example.com',
      phone: '',
      address: '',
      category: 'professional_services',
      status: 'active',
      status_display: 'Active',
      kyc_status: 'pending',
      kyc_status_display: 'Pending',
      commission_rate: 0,
      partner_role: 'surveyor',
      partner_role_display: 'Surveyor',
      primary_branch_id: 12,
      primary_branch_name: 'Enugu',
      authorized_branch_ids: [12],
      has_login: true,
      created_at: '2026-11-01T00:00:00Z',
      updated_at: '2026-11-01T00:00:00Z',
    })
    vi.spyOn(partnerAdminApi, 'contacts').mockResolvedValue({
      contacts: [],
      history: [],
      effective_contacts: [],
      eligible_staff: [],
    })
    vi.spyOn(partnerAdminApi, 'conversations').mockResolvedValue([])
    vi.spyOn(partnerAdminApi, 'staffConversationMessages').mockResolvedValue([])
    vi.spyOn(partnerAdminApi, 'invitations').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(partnerAdminApi, 'unassignedConversations').mockResolvedValue([])
    vi.spyOn(partnerAdminApi, 'invitationChoices').mockResolvedValue({
      branches: [{ id: 12, name: 'Enugu', code: 'EN-01' }],
      roles: [{ value: 'realtor', label: 'Realtor' }],
    })
    vi.spyOn(partnerAdminApi, 'invitationContacts').mockResolvedValue({ items: [] })
    vi.spyOn(partnerAdminApi, 'invite').mockResolvedValue({
      partner: {} as PartnerAdminDto,
      invitation: {
        id: 32,
        email: 'new@example.com',
        status: 'sent',
        delivery_status: 'pending',
        expires_at: '2026-11-30T00:00:00Z',
      } as PartnerInvitationDto,
    })
    vi.spyOn(partnerPortalApi, 'me').mockResolvedValue(partnerProfile)
    vi.spyOn(partnerPortalApi, 'jobs').mockResolvedValue([])
    vi.spyOn(partnerPortalApi, 'unreadNotificationCount').mockResolvedValue({ unread_count: 0 })
    vi.spyOn(partnerPortalApi, 'unreadMessageCount').mockResolvedValue({ unread_count: 0 })
    vi.spyOn(partnerPortalApi, 'conversations').mockResolvedValue({
      contacts: [],
      conversations: [],
      primary_staff_user_id: null,
      support_available: false,
    })
    vi.spyOn(partnerPortalApi, 'conversationMessages').mockResolvedValue([])
    vi.spyOn(partnerPortalApi, 'markConversationRead').mockResolvedValue({
      conversation_id: 0,
      updated_count: 0,
    })
    vi.spyOn(partnerPortalApi, 'startConversation').mockResolvedValue({
      id: 99,
      partner_id: partnerProfile.id,
      kind: 'direct',
      status: 'active',
      staff_user_id: 100,
      staff_name: 'Bomach Contact',
      last_message_at: null,
      can_reply: true,
      merged_into_id: null,
    })
    vi.spyOn(partnerPortalApi, 'updateProfile').mockResolvedValue({
      id: partnerProfile.id,
      name: 'Martha Partner',
      email: partnerProfile.email,
      phone: '+2348012345678',
      address: '',
      profile_completed: true,
      profile_completed_at: '2026-11-21T10:00:00Z',
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('invites a partner using the selected role and authorized branch', async () => {
    const user = userEvent.setup()
    renderPage(<PartnerDeskPage />)

    expect(await screen.findByText('Martha Surveyor')).toBeInTheDocument()
    expect(routeState.searchFrom).toBe('/_protected/company/partners')
    expect(routeState.navigateFrom).toBe('/company/partners')
    expect(screen.queryByText('Bring trusted expertise into the work.')).not.toBeInTheDocument()
    const inviteButton = screen.getByRole('button', { name: 'Invite partner' })
    expect(screen.getByRole('heading', { name: 'Partners' }).closest('header')).toContainElement(
      inviteButton,
    )
    await user.click(inviteButton)
    expect(await screen.findByRole('heading', { name: 'Invite a partner' })).toBeInTheDocument()
    expect(screen.queryByText('Secure setup link')).not.toBeInTheDocument()
    expect(screen.getByRole('dialog')).toHaveClass('tablet:max-w-[50rem]')
    expect(
      screen.getByRole('textbox', { name: /Email address/ }).parentElement?.parentElement,
    ).toHaveClass('phone:grid-cols-2')
    await user.type(screen.getByRole('textbox', { name: /Email address/ }), 'new@example.com')
    await user.click(screen.getByRole('button', { name: 'Send invitation' }))

    await waitFor(() =>
      expect(partnerAdminApi.invite).toHaveBeenCalledWith({
        email: 'new@example.com',
        partner_role: 'realtor',
        branch_id: 12,
        contact_employee_ids: [],
        primary_contact_employee_id: null,
      }),
    )
    expect(await screen.findByText('Invitation history')).toBeInTheDocument()
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Invitation sent' }))
  })

  it('keeps partner identity details grouped and separates status and actions responsively', async () => {
    renderPage(<PartnerDeskPage />)

    const name = await screen.findByRole('heading', { name: 'Martha Surveyor' })
    const card = name.closest('article')
    expect(card).not.toBeNull()
    expect(card).toHaveClass('desktop:grid-cols-[minmax(0,1fr)_auto]')
    expect(card).not.toHaveClass('tablet:grid-cols-[minmax(0,1fr)_auto]')
    expect(card).toHaveTextContent('martha@example.com')
    expect(card).toHaveTextContent(/Surveyor\s*·\s*Enugu/)
    expect(card).toHaveTextContent('Setup pending')
    expect(within(card as HTMLElement).getByRole('button', { name: 'Open' })).toBeInTheDocument()
  })

  it('explains that a branch is required before eligible message contacts can load', async () => {
    const user = userEvent.setup()
    vi.mocked(partnerAdminApi.invitationChoices).mockResolvedValue({
      branches: [
        { id: 12, name: 'Enugu', code: 'EN-01' },
        { id: 13, name: 'Lagos', code: 'LA-01' },
      ],
      roles: [{ value: 'realtor', label: 'Realtor' }],
    })
    vi.mocked(partnerAdminApi.invitationContacts).mockResolvedValue({
      items: [
        {
          employee_id: 44,
          staff_user_id: 100,
          name: 'Staff Contact',
          email: 'contact@example.com',
          designation: 'Operations manager',
        },
      ],
    })
    renderPage(<PartnerDeskPage />)

    await user.click(await screen.findByRole('button', { name: 'Invite partner' }))
    expect(
      await screen.findByText(
        'Select an owning branch to see staff who can access partner messages there.',
      ),
    ).toBeInTheDocument()
    expect(screen.queryByLabelText('Loading eligible contacts')).not.toBeInTheDocument()
    expect(partnerAdminApi.invitationContacts).not.toHaveBeenCalled()

    await user.click(screen.getByRole('combobox', { name: /Owning branch/ }))
    await user.click(screen.getByRole('option', { name: /Enugu/ }))
    expect(await screen.findByText('Staff Contact')).toBeInTheDocument()
    expect(screen.getByText('Operations manager · contact@example.com')).toBeInTheDocument()
    expect(screen.getByText('1 eligible staff member')).toBeInTheDocument()
    expect(partnerAdminApi.invitationContacts).toHaveBeenCalledWith(12, expect.anything())
    await user.click(
      screen.getByRole('checkbox', { name: 'Assign Staff Contact as a partner contact' }),
    )
    expect(
      screen.getByRole('radio', { name: 'Set Staff Contact as primary contact' }),
    ).toBeChecked()
  })

  it('shows the unassigned-message tab only when the authorized queue contains conversations', async () => {
    const permissions = {
      partners: ['list', 'invite'],
      partner_messages: ['list', 'receive_unassigned'],
    }
    const conversation = {
      id: 71,
      partner_id: 5,
      kind: 'unassigned' as const,
      status: 'queued' as const,
      staff_user_id: null,
      staff_name: '',
      last_message_at: '2026-11-23T09:00:00Z',
      can_reply: false,
      can_claim: true,
      merged_into_id: null,
      partner_name: 'Martha Surveyor',
      partner_code: 'PT-005',
    }

    renderPage(<PartnerDeskPage />, { ...staffSession, permissions })
    await screen.findByText('Martha Surveyor')
    await waitFor(() => expect(partnerAdminApi.unassignedConversations).toHaveBeenCalled())
    expect(screen.queryByRole('tab', { name: 'Unassigned messages' })).not.toBeInTheDocument()

    vi.mocked(partnerAdminApi.unassignedConversations).mockResolvedValue([conversation])
    await queryClient.invalidateQueries({
      queryKey: partnerQueryKeys.unassignedConversations(staffSession.user.id),
    })

    const queueTab = await screen.findByRole('tab', { name: 'Unassigned messages' })
    expect(queueTab).toBeInTheDocument()
    await userEvent.setup().click(queueTab)
    expect(await screen.findByRole('button', { name: 'Review and claim' })).toBeInTheDocument()

    vi.mocked(partnerAdminApi.unassignedConversations).mockResolvedValue([])
    await queryClient.invalidateQueries({
      queryKey: partnerQueryKeys.unassignedConversations(staffSession.user.id),
    })
    await waitFor(() =>
      expect(screen.queryByRole('tab', { name: 'Unassigned messages' })).not.toBeInTheDocument(),
    )
    expect(await screen.findByText('Queue is clear')).toBeInTheDocument()
    await userEvent
      .setup()
      .click(screen.getByRole('button', { name: 'Return to partner directory' }))
    expect(screen.getByRole('tab', { name: 'Partner directory' })).toHaveAttribute(
      'aria-selected',
      'true',
    )
  })

  it('does not treat an unavailable queue as empty without showing retry feedback', async () => {
    vi.mocked(partnerAdminApi.unassignedConversations).mockRejectedValue(
      new Error('Temporary queue failure'),
    )
    renderPage(<PartnerDeskPage />, {
      ...staffSession,
      permissions: {
        partners: ['list', 'invite'],
        partner_messages: ['list', 'receive_unassigned'],
      },
    })

    expect(await screen.findByRole('button', { name: 'Try again' })).toBeInTheDocument()
    expect(screen.queryByRole('tab', { name: 'Unassigned messages' })).not.toBeInTheDocument()
  })

  it('shows a private conversation workspace for a selected partner thread', async () => {
    routeState.detailSearch = { tab: 'messages', conversation: 18 }
    vi.mocked(partnerAdminApi.conversations).mockResolvedValue([
      {
        id: 18,
        partner_id: 5,
        kind: 'direct',
        status: 'read_only',
        staff_user_id: 100,
        staff_name: 'Staff Contact',
        last_message_at: '2026-11-22T10:00:00Z',
        can_reply: false,
        merged_into_id: null,
      },
    ])
    vi.mocked(partnerAdminApi.staffConversationMessages).mockResolvedValue([
      {
        id: 31,
        conversation_id: 18,
        subject: 'Site coordination',
        body: 'This message is private to the assigned contact.',
        is_from_partner: true,
        is_read: true,
        created_at: '2026-11-22T10:00:00Z',
        sender_name: 'Martha Surveyor',
      },
    ])

    renderPage(<PartnerDetailPage />)

    expect(
      await screen.findByText('This message is private to the assigned contact.'),
    ).toBeInTheDocument()
    expect(screen.getAllByText('Read only').length).toBeGreaterThan(0)
    expect(screen.queryByRole('button', { name: 'Send reply' })).not.toBeInTheDocument()
    expect(partnerAdminApi.staffConversationMessages).toHaveBeenCalledWith(5, 18, expect.anything())
  })

  it('keeps oversight message access read-only and does not start another contact thread', async () => {
    routeState.detailSearch = { tab: 'messages', conversation: 18 }
    vi.mocked(partnerAdminApi.contacts).mockResolvedValue({
      contacts: [
        {
          employee_id: 100,
          staff_user_id: 100,
          name: 'Assigned Contact',
          email: 'contact@example.com',
          designation: 'Partner contact',
          is_primary: true,
        },
      ],
      history: [],
      effective_contacts: [
        {
          staff_user_id: 100,
          name: 'Assigned Contact',
          designation: 'Partner contact',
          is_primary: true,
          source: 'assigned',
        },
      ],
      eligible_staff: [],
    })
    vi.mocked(partnerAdminApi.conversations).mockResolvedValue([
      {
        id: 18,
        partner_id: 5,
        kind: 'direct',
        status: 'active',
        staff_user_id: 100,
        staff_name: 'Assigned Contact',
        last_message_at: '2026-11-22T10:00:00Z',
        can_reply: false,
        merged_into_id: null,
      },
    ])
    vi.mocked(partnerAdminApi.staffConversationMessages).mockResolvedValue([
      {
        id: 31,
        conversation_id: 18,
        subject: 'Site coordination',
        body: 'Oversight can review this private thread.',
        is_from_partner: true,
        is_read: false,
        created_at: '2026-11-22T10:00:00Z',
      },
    ])
    const markRead = vi
      .spyOn(partnerAdminApi, 'markStaffConversationRead')
      .mockResolvedValue({ conversation_id: 18, updated_count: 1 })
    const startConversation = vi
      .spyOn(partnerAdminApi, 'startStaffConversation')
      .mockResolvedValue({
        id: 19,
        partner_id: 5,
        kind: 'direct',
        status: 'active',
        staff_user_id: 11,
        staff_name: 'Staff User',
        last_message_at: null,
        can_reply: true,
        merged_into_id: null,
      })

    renderPage(<PartnerDetailPage />, {
      ...staffSession,
      permissions: {
        partners: ['view'],
        partner_messages: ['list', 'create', 'mark_read', 'view_all'],
      },
    })

    expect(await screen.findByText('Oversight can review this private thread.')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Start my conversation' })).not.toBeInTheDocument()
    await waitFor(() => {
      expect(markRead).not.toHaveBeenCalled()
      expect(startConversation).not.toHaveBeenCalled()
    })
  })

  it('allows invite-only staff to invite without reading partner records', async () => {
    renderPage(<PartnerDeskPage />, {
      ...staffSession,
      permissions: { partners: ['invite'] },
    })

    expect(await screen.findByText('Invitation access only')).toBeInTheDocument()
    expect(partnerAdminApi.partners).not.toHaveBeenCalled()
    expect(partnerAdminApi.invitations).not.toHaveBeenCalled()
    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Invite partner' })).toBeEnabled(),
    )
  })

  it('blocks invitations when no authorized active branch is available', async () => {
    vi.mocked(partnerAdminApi.invitationChoices).mockResolvedValue({ branches: [], roles: [] })
    renderPage(<PartnerDeskPage />)

    expect(await screen.findByText('Branch access is required')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Invite partner' })).toBeDisabled()
  })

  it('uses the Bomach sign-in design and routes authenticated partners to their workspace', async () => {
    const user = userEvent.setup()
    const login = vi.spyOn(authApi, 'login').mockResolvedValue({
      success: true,
      requires_2fa: false,
      detail: 'Signed in',
    })
    renderPage(<PartnerLoginPage />)

    expect(screen.getByRole('img', { name: 'Bomach' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Welcome back' })).toBeInTheDocument()
    expect(screen.getByText(/Bomach partner workspace/)).toBeInTheDocument()
    expect(screen.queryByText(/demo/i)).not.toBeInTheDocument()

    await user.type(screen.getByRole('textbox', { name: 'Email' }), 'partner@example.com')
    await user.type(screen.getByLabelText(/Password/), 'SecurePass123!')
    await user.click(screen.getByRole('button', { name: 'Sign in' }))

    await waitFor(() =>
      expect(login).toHaveBeenCalledWith({
        email: 'partner@example.com',
        password: 'SecurePass123!',
      }),
    )
    expect(partnerPortalApi.me).toHaveBeenCalled()
    expect(getWorkspaceMode()).toBe('partner')
    expect(routeState.navigate).toHaveBeenCalledWith({
      to: '/partners/app',
      search: { tab: 'home' },
      replace: true,
    })
  })

  it('requires an invitation token before showing password setup', async () => {
    const user = userEvent.setup()
    renderPage(<PartnerSetupPage />)

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'This setup link is missing or no longer available.',
    )
    expect(screen.queryByLabelText('Password')).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Return to partner sign in' }))
    expect(routeState.navigate).toHaveBeenCalledWith({ to: '/partners/login' })
  })

  it('requires profile completion while keeping profile data private and self-service', async () => {
    const user = userEvent.setup()
    routeState.portalSearch = { tab: 'profile' }
    renderPage(<PartnerPortalPage />)

    const profileDialog = await screen.findByRole('dialog', { name: 'Complete your profile' })
    expect(profileDialog).toBeInTheDocument()
    await waitFor(() => expect(getWorkspaceMode()).toBe('partner'))
    await user.clear(screen.getByRole('textbox', { name: /Full name/ }))
    await user.type(screen.getByRole('textbox', { name: /Full name/ }), 'Martha Partner')
    await user.type(screen.getByRole('textbox', { name: /Phone number/ }), '+2348012345678')
    await user.click(within(profileDialog).getByRole('button', { name: 'Finish setup' }))

    await waitFor(() =>
      expect(partnerPortalApi.updateProfile).toHaveBeenCalledWith({
        name: 'Martha Partner',
        phone: '+2348012345678',
        address: '',
      }),
    )
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Profile saved' }))
  })

  it('opens onboarding automatically and leaves a compact reminder when dismissed', async () => {
    const user = userEvent.setup()
    renderPage(<PartnerPortalPage />)

    expect(await screen.findByRole('dialog', { name: 'Complete your profile' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Not now' }))

    expect(screen.queryByRole('dialog', { name: 'Complete your profile' })).not.toBeInTheDocument()
    expect(screen.getByText('Profile incomplete')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Finish setup' }))
    expect(screen.getByRole('dialog', { name: 'Complete your profile' })).toBeInTheDocument()
  })

  it('folds the desktop partner sidebar like the OS shell and remembers the preference', async () => {
    const user = userEvent.setup()
    vi.mocked(partnerPortalApi.me).mockResolvedValue({
      ...partnerProfile,
      profile_completed: true,
    })
    const { container } = renderPage(<PartnerPortalPage />)

    await screen.findByRole('navigation', { name: 'Partner navigation' })
    const sidebar = container.querySelector('aside')
    expect(sidebar).not.toBeNull()
    expect(sidebar).toHaveClass('desktop:w-[300px]')
    expect(
      within(sidebar as HTMLElement).queryByText(/partner access|workspace/i),
    ).not.toBeInTheDocument()

    await user.click(
      within(sidebar as HTMLElement).getByRole('button', { name: 'Collapse sidebar' }),
    )

    expect(sidebar).toHaveClass('desktop:w-[72px]')
    expect(within(sidebar as HTMLElement).getByRole('button', { name: 'Home' })).toBeInTheDocument()
    expect(within(sidebar as HTMLElement).queryByText('Home')).not.toBeInTheDocument()
    await waitFor(() =>
      expect(window.localStorage.getItem('bomach.partner.sidebar.collapsed')).toBe('true'),
    )

    await user.click(within(sidebar as HTMLElement).getByRole('button', { name: 'Expand sidebar' }))

    expect(sidebar).toHaveClass('desktop:w-[300px]')
    await waitFor(() =>
      expect(window.localStorage.getItem('bomach.partner.sidebar.collapsed')).toBe('false'),
    )
  })

  it('lets a partner switch between private staff conversations', async () => {
    const user = userEvent.setup()
    routeState.portalSearch = { tab: 'messages' }
    vi.mocked(partnerPortalApi.me).mockResolvedValue({
      ...partnerProfile,
      profile_completed: true,
      phone: '+2348012345678',
    })
    vi.mocked(partnerPortalApi.conversations).mockResolvedValue({
      contacts: [
        {
          staff_user_id: 100,
          name: 'First Contact',
          designation: 'Partner manager',
          is_primary: true,
          source: 'assigned',
        },
        {
          staff_user_id: 101,
          name: 'Second Contact',
          designation: 'Operations officer',
          is_primary: false,
          source: 'assigned',
        },
      ],
      conversations: [
        {
          id: 40,
          partner_id: 5,
          kind: 'direct',
          status: 'active',
          staff_user_id: 100,
          staff_name: 'First Contact',
          last_message_at: '2026-11-20T10:00:00Z',
          can_reply: true,
          merged_into_id: null,
        },
        {
          id: 41,
          partner_id: 5,
          kind: 'direct',
          status: 'active',
          staff_user_id: 101,
          staff_name: 'Second Contact',
          last_message_at: '2026-11-21T10:00:00Z',
          can_reply: true,
          merged_into_id: null,
        },
      ],
      primary_staff_user_id: 100,
      support_available: false,
    })
    vi.mocked(partnerPortalApi.conversationMessages).mockImplementation(async (id) => [
      {
        id,
        conversation_id: id,
        subject: 'Thread note',
        body: id === 41 ? 'Second contact private thread.' : 'Primary contact private thread.',
        is_from_partner: false,
        is_read: true,
        created_at: '2026-11-22T10:00:00Z',
        sender_name: 'Bomach staff',
      },
    ])

    renderPage(<PartnerPortalPage />)
    expect(await screen.findByText('Primary contact private thread.')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: /Second Contact/ }))
    expect(await screen.findByText('Second contact private thread.')).toBeInTheDocument()
    expect(partnerPortalApi.conversationMessages).toHaveBeenCalledWith(41, expect.anything())
  })

  it('uses a mobile navigation drawer and confirms sign out', async () => {
    const user = userEvent.setup()
    const profile = { ...partnerProfile, profile_completed: true }
    vi.mocked(partnerPortalApi.me).mockResolvedValue(profile)
    renderPage(<PartnerPortalPage />)

    await user.click(await screen.findByRole('button', { name: 'Open navigation menu' }))
    const navigation = screen.getByRole('dialog', { name: 'Partner navigation menu' })
    expect(navigation).toBeInTheDocument()
    await user.click(within(navigation).getByRole('button', { name: 'Sign out' }))

    const confirmDialog = screen.getByRole('dialog', {
      name: 'Sign out?',
    })
    expect(confirmDialog).toBeInTheDocument()
    expect(within(confirmDialog).getByText('martha@example.com')).toBeInTheDocument()
  })
})
