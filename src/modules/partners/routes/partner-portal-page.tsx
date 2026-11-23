import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Bell,
  BriefcaseBusiness,
  Building2,
  Check,
  Clock3,
  CircleUserRound,
  ChevronRight,
  ClipboardList,
  CircleAlert,
  Handshake,
  Home,
  LogOut,
  Mail,
  Menu,
  MapPin,
  MessageSquareText,
  ShieldCheck,
  UserRound,
  X,
} from 'lucide-react'
import { useEffect, useRef, useState, type FormEvent } from 'react'

import {
  partnerPortalApi,
  partnerQueryKeys,
  type PartnerLeadPreview,
  type PartnerProfileDto,
  type PartnerRole,
} from '@/modules/partners/partner.api'
import { authApi } from '@/shared/auth/auth.api'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { handleDrawerKeyDown } from '@/app/shell/shell-utils'
import { ShellIcon } from '@/app/shell/shell-icons'
import { Tooltip } from '@/shared/ui/tooltip'

import type { PartnerAppSearch } from '../partner.search'

const tabs = [
  { id: 'home', label: 'Home', icon: Home },
  { id: 'work', label: 'My work', icon: BriefcaseBusiness },
  { id: 'messages', label: 'Messages', icon: MessageSquareText },
  { id: 'notifications', label: 'Updates', icon: Bell },
  { id: 'profile', label: 'Profile', icon: UserRound },
] as const
const PARTNER_SIDEBAR_STATE_KEY = 'bomach.partner.sidebar.collapsed'

function readSidebarCollapsed() {
  try {
    return window.localStorage.getItem(PARTNER_SIDEBAR_STATE_KEY) === 'true'
  } catch {
    return false
  }
}

const roleLabels: Record<PartnerRole, string> = {
  realtor: 'Realtor',
  surveyor: 'Surveyor',
  lawyer: 'Legal associate',
  consultant: 'Consultant',
}

function statusTone(value: string): StatusTone {
  if (['approved', 'completed', 'won', 'paid', 'active'].includes(value)) return 'success'
  if (['pending', 'submitted', 'in_progress', 'under_review', 'new'].includes(value))
    return 'warning'
  if (['rejected', 'cancelled', 'failed', 'suspended'].includes(value)) return 'danger'
  return 'neutral'
}

function formatMoney(value: number | string | null | undefined) {
  const amount = Number(value ?? 0)
  if (!Number.isFinite(amount)) return 'Not available'
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency: 'NGN',
    maximumFractionDigits: 0,
  }).format(amount)
}

function formatDate(value: string | null | undefined) {
  if (!value) return 'Not scheduled'
  const date = new Date(value)
  return Number.isNaN(date.valueOf())
    ? 'Not scheduled'
    : date.toLocaleDateString('en-NG', { day: 'numeric', month: 'short', year: 'numeric' })
}

function roleWelcome(role: PartnerRole) {
  if (role === 'realtor') return 'Your property network, leads, and referral activity.'
  if (role === 'surveyor') return 'Your assigned surveying work and delivery updates.'
  if (role === 'lawyer') return 'Your assigned legal work and review updates.'
  return 'Your assigned consulting work and delivery updates.'
}

function BrandMark({ compact = false }: { compact?: boolean }) {
  return (
    <img
      src="/bomach-logo.png"
      alt="Bomach OS"
      className={compact ? 'h-9 w-9 object-contain' : 'h-10 w-[145px] object-contain object-left'}
    />
  )
}

function PartnerNavigation({
  selectedTab,
  unreadMessages,
  unreadNotifications,
  collapsed,
  onSelect,
}: {
  selectedTab: PartnerAppSearch['tab']
  unreadMessages: number
  unreadNotifications: number
  collapsed: boolean
  onSelect: (tab: PartnerAppSearch['tab']) => void
}) {
  return (
    <nav
      aria-label="Partner navigation"
      className={`min-h-0 flex-1 space-y-1 overflow-y-auto py-4 ${collapsed ? 'px-2' : 'px-3'}`}
    >
      {tabs.map(({ id, label, icon: Icon }) => {
        const unreadCount =
          id === 'messages' ? unreadMessages : id === 'notifications' ? unreadNotifications : 0
        return (
          <Tooltip
            key={id}
            content={label}
            placement={collapsed ? 'right' : 'top'}
            showDelayMs={1000}
            className="w-full"
          >
            <button
              type="button"
              aria-label={unreadCount > 0 ? `${label}, ${unreadCount} unread` : label}
              aria-current={selectedTab === id ? 'page' : undefined}
              onClick={() => onSelect(id)}
              className={`focus-visible:shadow-focus-ring rounded-control text-label relative flex min-h-11 w-full items-center font-medium transition-colors focus-visible:outline-none ${collapsed ? 'justify-center px-0' : 'gap-3 px-3 text-left'} ${selectedTab === id ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted hover:text-text-primary'}`}
            >
              <Icon className="size-[18px] shrink-0" aria-hidden="true" />
              {!collapsed ? <span className="min-w-0 flex-1">{label}</span> : null}
              {unreadCount > 0 ? (
                <span
                  className={`bg-danger text-text-on-primary rounded-pill px-1.5 py-0.5 text-center text-[10px] leading-none ${collapsed ? 'absolute top-0.5 right-0.5 min-w-4' : 'min-w-5'}`}
                >
                  {collapsed
                    ? unreadCount > 99
                      ? '9+'
                      : unreadCount
                    : unreadCount > 99
                      ? '99+'
                      : unreadCount}
                </span>
              ) : null}
            </button>
          </Tooltip>
        )
      })}
    </nav>
  )
}

function Metric({
  label,
  value,
  icon: Icon,
}: {
  label: string
  value: string
  icon: typeof BriefcaseBusiness
}) {
  return (
    <div className="border-border-subtle bg-surface rounded-2xl border p-4">
      <span className="flex size-9 items-center justify-center rounded-xl bg-[#EAF0FA] text-[#0B3974]">
        <Icon className="size-4" aria-hidden="true" />
      </span>
      <p className="text-text-primary mt-4 text-xl font-semibold tracking-tight">{value}</p>
      <p className="text-caption text-text-secondary mt-1">{label}</p>
    </div>
  )
}

export function PartnerPortalPage() {
  const routeSearch = useSearch({ from: '/partners/app' }) as PartnerAppSearch
  const navigate = useNavigate({ from: '/partners/app' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const profileQuery = useQuery({
    queryKey: partnerQueryKeys.me,
    queryFn: ({ signal }) => partnerPortalApi.me(signal),
    staleTime: 60_000,
  })
  const profile = profileQuery.data
  const profileIncomplete = Boolean(profile && !profile.profile_completed)
  const [profileOpen, setProfileOpen] = useState(routeSearch.tab === 'profile')
  const [onboardingDismissed, setOnboardingDismissed] = useState(false)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [signOutOpen, setSignOutOpen] = useState(false)
  const [sidebarCollapsed, setSidebarCollapsed] = useState(readSidebarCollapsed)
  const [sidebarHoverExpanded, setSidebarHoverExpanded] = useState(false)
  const drawerRef = useRef<HTMLDivElement>(null)
  const menuButtonRef = useRef<HTMLButtonElement>(null)
  const sidebarIsCollapsed = sidebarCollapsed && !sidebarHoverExpanded

  const profileDialogOpen =
    profileOpen || routeSearch.tab === 'profile' || (profileIncomplete && !onboardingDismissed)

  useEffect(() => {
    try {
      window.localStorage.setItem(PARTNER_SIDEBAR_STATE_KEY, String(sidebarCollapsed))
    } catch {
      // Sidebar preferences are optional; navigation remains usable without storage.
    }
  }, [sidebarCollapsed])

  useEffect(() => {
    if (!drawerOpen) return
    const previousFocus =
      document.activeElement instanceof HTMLElement ? document.activeElement : null
    const previousOverflow = document.body.style.overflow
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setDrawerOpen(false)
    }
    document.body.style.overflow = 'hidden'
    document.addEventListener('keydown', closeOnEscape)
    drawerRef.current?.querySelector<HTMLElement>('[data-drawer-close]')?.focus()
    return () => {
      document.body.style.overflow = previousOverflow
      document.removeEventListener('keydown', closeOnEscape)
      if (previousFocus?.isConnected) previousFocus.focus()
    }
  }, [drawerOpen])

  const isRealtor = profile?.partner_role === 'realtor'
  const leadsQuery = useQuery({
    queryKey: partnerQueryKeys.leads,
    queryFn: ({ signal }) => partnerPortalApi.leads(signal),
    enabled: Boolean(isRealtor && (routeSearch.tab === 'home' || routeSearch.tab === 'work')),
  })
  const catalogueQuery = useQuery({
    queryKey: partnerQueryKeys.catalogue,
    queryFn: ({ signal }) => partnerPortalApi.catalogue(signal),
    enabled: Boolean(isRealtor && (routeSearch.tab === 'home' || routeSearch.tab === 'work')),
  })
  const earningsQuery = useQuery({
    queryKey: partnerQueryKeys.earnings,
    queryFn: ({ signal }) => partnerPortalApi.earnings(signal),
    enabled: Boolean(isRealtor && routeSearch.tab === 'home'),
  })
  const jobsQuery = useQuery({
    queryKey: partnerQueryKeys.jobs,
    queryFn: ({ signal }) => partnerPortalApi.jobs(signal),
    enabled: Boolean(
      profile && !isRealtor && (routeSearch.tab === 'home' || routeSearch.tab === 'work'),
    ),
  })
  const messagesQuery = useQuery({
    queryKey: partnerQueryKeys.conversations,
    queryFn: ({ signal }) => partnerPortalApi.conversations(signal),
    enabled: routeSearch.tab === 'messages',
  })
  const [activeConversationId, setActiveConversationId] = useState<number | null>(null)
  const partnerConversations = messagesQuery.data?.conversations ?? []
  const primaryConversation = partnerConversations.find(
    (conversation) => conversation.staff_user_id === messagesQuery.data?.primary_staff_user_id,
  )
  const defaultConversation =
    primaryConversation ??
    partnerConversations.find((conversation) => conversation.kind !== 'legacy') ??
    partnerConversations[0]
  const selectedConversationId = partnerConversations.some(
    (conversation) => conversation.id === activeConversationId,
  )
    ? activeConversationId
    : (defaultConversation?.id ?? null)
  const selectedConversation = partnerConversations.find(
    (conversation) => conversation.id === selectedConversationId,
  )
  const conversationMessagesQuery = useQuery({
    queryKey: partnerQueryKeys.conversationMessages(selectedConversationId),
    queryFn: ({ signal }) => partnerPortalApi.conversationMessages(selectedConversationId!, signal),
    enabled: routeSearch.tab === 'messages' && selectedConversationId !== null,
  })
  const notificationsQuery = useQuery({
    queryKey: partnerQueryKeys.notifications,
    queryFn: ({ signal }) => partnerPortalApi.notifications(signal),
    enabled: routeSearch.tab === 'notifications',
  })
  const unreadNotificationsQuery = useQuery({
    queryKey: partnerQueryKeys.unreadNotifications,
    queryFn: ({ signal }) => partnerPortalApi.unreadNotificationCount(signal),
    enabled: routeSearch.tab === 'home' || routeSearch.tab === 'notifications',
  })
  const unreadMessagesQuery = useQuery({
    queryKey: partnerQueryKeys.unreadMessages,
    queryFn: ({ signal }) => partnerPortalApi.unreadMessageCount(signal),
    enabled: routeSearch.tab === 'home' || routeSearch.tab === 'messages',
  })
  const [subject, setSubject] = useState('')
  const [message, setMessage] = useState('')
  const [messageError, setMessageError] = useState('')
  const [signingOut, setSigningOut] = useState(false)

  const profileMutation = useMutation({
    mutationFn: (input: { name: string; phone: string; address: string }) =>
      partnerPortalApi.updateProfile(input),
    onSuccess: async (updatedProfile) => {
      queryClient.setQueryData<PartnerProfileDto>(partnerQueryKeys.me, (current) =>
        current ? { ...current, ...updatedProfile } : current,
      )
      setProfileOpen(false)
      setOnboardingDismissed(true)
      if (routeSearch.tab === 'profile') {
        await navigate({ search: { tab: 'home' }, replace: true })
      }
      await queryClient.invalidateQueries({ queryKey: partnerQueryKeys.me })
      showToast({
        title: 'Profile saved',
        description: 'Your partner details have been updated.',
        tone: 'success',
      })
    },
  })
  const sendMessageMutation = useMutation({
    mutationFn: () => {
      if (!selectedConversationId) throw new Error('Choose a message contact first.')
      return partnerPortalApi.sendConversationMessage(selectedConversationId, {
        subject: subject.trim(),
        body: message.trim(),
      })
    },
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.conversations }),
        queryClient.invalidateQueries({
          queryKey: partnerQueryKeys.conversationMessages(selectedConversationId),
        }),
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.unreadMessages }),
      ])
      setSubject('')
      setMessage('')
      setMessageError('')
      showToast({
        title: 'Message sent',
        description: 'Your message is now in your Bomach conversation.',
        tone: 'success',
      })
    },
    onError: (error) => setMessageError(presentError(error, 'form-submit').message),
  })
  const notificationMutation = useMutation({
    mutationFn: async (id: number | 'all') => {
      if (id === 'all') await partnerPortalApi.markAllNotificationsRead()
      else await partnerPortalApi.markNotificationRead(id)
      return true
    },
    onSuccess: async () =>
      Promise.all([
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.notifications }),
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.unreadNotifications }),
      ]),
  })
  const messageReadMutation = useMutation({
    mutationFn: (conversationId: number) => partnerPortalApi.markConversationRead(conversationId),
    onSuccess: async () =>
      Promise.all([
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.conversations }),
        queryClient.invalidateQueries({
          queryKey: partnerQueryKeys.conversationMessages(selectedConversationId),
        }),
        queryClient.invalidateQueries({ queryKey: partnerQueryKeys.unreadMessages }),
      ]),
  })

  const startConversationMutation = useMutation({
    mutationFn: (staffUserId?: number) => partnerPortalApi.startConversation(staffUserId),
    onSuccess: async (conversation) => {
      setActiveConversationId(conversation.id)
      await queryClient.invalidateQueries({ queryKey: partnerQueryKeys.conversations })
      await queryClient.invalidateQueries({
        queryKey: partnerQueryKeys.conversationMessages(conversation.id),
      })
      setMessageError('')
    },
    onError: (error) => setMessageError(presentError(error, 'background-action').message),
  })

  const unreadNotifications =
    unreadNotificationsQuery.data?.unread_count ??
    notificationsQuery.data?.filter((item) => !item.is_read).length ??
    0
  const unreadMessages = unreadMessagesQuery.data?.unread_count ?? 0

  async function performSignOut() {
    setSigningOut(true)
    await authApi.logout().catch(() => undefined)
    window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
    queryClient.clear()
    await navigate({ to: '/partners/login', replace: true })
  }

  function handleProfileOpenChange(open: boolean) {
    setProfileOpen(open)
    if (!open && profileIncomplete) setOnboardingDismissed(true)
    if (!open && routeSearch.tab === 'profile') {
      void navigate({ search: { tab: 'home' }, replace: true })
    }
  }

  function selectTab(tab: PartnerAppSearch['tab']) {
    setDrawerOpen(false)
    if (tab === 'profile') {
      setProfileOpen(true)
      return
    }
    setProfileOpen(false)
    void navigate({ search: { tab }, replace: false })
  }

  function saveProfile(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    profileMutation.mutate({
      name: String(form.get('name') ?? '').trim(),
      phone: String(form.get('phone') ?? '').trim(),
      address: String(form.get('address') ?? '').trim(),
    })
  }

  function sendMessage(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setMessageError('')
    if (!subject.trim() || !message.trim()) {
      setMessageError('Add a subject and message before sending.')
      return
    }
    if (!selectedConversation?.can_reply || selectedConversationId === null) {
      setMessageError('Choose an available partner contact before sending.')
      return
    }
    sendMessageMutation.mutate()
  }

  useEffect(() => {
    if (
      selectedConversation &&
      !conversationMessagesQuery.isPending &&
      conversationMessagesQuery.data?.some((item) => !item.is_from_partner && !item.is_read) &&
      messageReadMutation.variables !== selectedConversation.id
    ) {
      messageReadMutation.mutate(selectedConversation.id)
    }
  }, [
    conversationMessagesQuery.data,
    conversationMessagesQuery.isPending,
    messageReadMutation,
    selectedConversation,
  ])

  if (profileQuery.isPending) {
    return (
      <main className="min-h-svh bg-[#F4F7FB] p-5">
        <div className="mx-auto max-w-7xl space-y-5">
          <Skeleton className="h-20 rounded-2xl" />
          <Skeleton className="h-56 rounded-2xl" />
          <Skeleton className="h-72 rounded-2xl" />
        </div>
      </main>
    )
  }

  if (profileQuery.error || !profile) {
    return (
      <main className="flex min-h-svh items-center justify-center bg-[#F4F7FB] px-4 py-8">
        <div className="w-full max-w-xl rounded-3xl border border-white bg-white p-5 shadow-xl sm:p-8">
          <BrandMark />
          <div className="mt-8">
            <ErrorState
              title="Partner account unavailable"
              description="This account could not load a partner profile. Sign in with the email address that received your partner invitation, or contact your Bomach representative."
              error={profileQuery.error}
              action={
                <Button
                  onClick={() => void performSignOut()}
                  leadingIcon={<LogOut className="size-4" />}
                >
                  Return to partner sign in
                </Button>
              }
            />
          </div>
        </div>
      </main>
    )
  }

  const contentTab = routeSearch.tab === 'profile' ? 'home' : routeSearch.tab
  const activeTab = tabs.find((tab) => tab.id === contentTab) ?? tabs[0]
  const selectedTab = profileDialogOpen ? 'profile' : contentTab
  const jobs = jobsQuery.data ?? []
  const leads = leadsQuery.data ?? []
  const totalUnread = unreadNotifications + unreadMessages

  return (
    <div className="desktop:flex bg-background text-text-primary min-h-svh">
      <aside
        className={`desktop:sticky desktop:top-0 desktop:flex desktop:h-svh desktop:shrink-0 border-border-subtle bg-surface hidden flex-col border-r transition-[width] duration-200 ease-in-out motion-reduce:transition-none ${sidebarIsCollapsed ? 'desktop:w-[72px]' : 'desktop:w-[300px]'}`}
        onMouseEnter={() => {
          if (sidebarCollapsed && window.matchMedia?.('(min-width: 1100px)').matches) {
            setSidebarHoverExpanded(true)
          }
        }}
        onMouseLeave={() => {
          if (sidebarCollapsed) setSidebarHoverExpanded(false)
        }}
        onBlurCapture={(event) => {
          if (
            !(event.relatedTarget instanceof Node) ||
            !event.currentTarget.contains(event.relatedTarget)
          ) {
            setSidebarHoverExpanded(false)
          }
        }}
      >
        <div
          className={`border-border-subtle flex shrink-0 border-b ${sidebarIsCollapsed ? 'h-20 flex-col justify-center gap-1 px-1' : 'h-20 items-center justify-between px-4'}`}
        >
          <BrandMark compact={sidebarIsCollapsed} />
          <Button
            variant="ghost"
            size="icon"
            aria-label={
              sidebarHoverExpanded
                ? 'Keep sidebar expanded'
                : sidebarIsCollapsed
                  ? 'Expand sidebar'
                  : 'Collapse sidebar'
            }
            title={
              sidebarHoverExpanded
                ? 'Keep sidebar expanded'
                : sidebarIsCollapsed
                  ? 'Expand sidebar'
                  : 'Collapse sidebar'
            }
            className={sidebarIsCollapsed ? 'size-8' : undefined}
            onClick={() => {
              if (sidebarHoverExpanded) {
                setSidebarCollapsed(false)
                setSidebarHoverExpanded(false)
                return
              }
              setSidebarCollapsed((isCollapsed) => !isCollapsed)
            }}
          >
            <ShellIcon name={sidebarIsCollapsed ? 'expand' : 'collapse'} className="size-5" />
          </Button>
        </div>
        <PartnerNavigation
          selectedTab={selectedTab}
          unreadMessages={unreadMessages}
          unreadNotifications={unreadNotifications}
          collapsed={sidebarIsCollapsed}
          onSelect={selectTab}
        />
        <div
          className={`border-border-subtle flex shrink-0 border-t ${sidebarIsCollapsed ? 'flex-col items-center gap-1 p-2.5' : 'items-center gap-2 p-3'}`}
        >
          <button
            type="button"
            onClick={() => setProfileOpen(true)}
            aria-label={`Open profile for ${profile.name || 'Partner account'}`}
            aria-haspopup="dialog"
            aria-expanded={profileDialogOpen}
            title={sidebarIsCollapsed ? profile.name || 'Partner account' : undefined}
            className={`focus-visible:shadow-focus-ring rounded-control flex min-h-11 items-center transition-colors focus-visible:outline-none ${sidebarIsCollapsed ? 'size-10 justify-center' : 'bg-surface-muted/40 hover:bg-surface-muted border-border-subtle min-w-0 flex-1 gap-2 border p-2 text-left'}`}
          >
            <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-full">
              <CircleUserRound className="size-5" aria-hidden="true" />
            </span>
            {!sidebarIsCollapsed ? (
              <span className="min-w-0 flex-1">
                <span className="text-label block truncate font-semibold">
                  {profile.name || 'Partner account'}
                </span>
                <span className="text-caption text-text-secondary block truncate">
                  {roleLabels[profile.partner_role]}
                </span>
              </span>
            ) : null}
          </button>
          <Button
            variant="ghost"
            size={sidebarIsCollapsed ? 'icon' : 'sm'}
            aria-label="Sign out"
            title={sidebarIsCollapsed ? 'Sign out' : undefined}
            className={sidebarIsCollapsed ? undefined : 'shrink-0'}
            leadingIcon={<ShellIcon name="logout" className="size-4" />}
            onClick={() => setSignOutOpen(true)}
          >
            {!sidebarIsCollapsed ? 'Sign out' : null}
          </Button>
        </div>
      </aside>

      <div className="min-w-0 flex-1">
        <header
          aria-label="Partner portal header"
          className="desktop:hidden border-border-subtle bg-surface phone:px-4 sticky top-0 z-30 flex h-16 items-center gap-2 border-b px-3 shadow-sm"
        >
          <Button
            ref={menuButtonRef}
            variant="ghost"
            size="icon"
            aria-label="Open navigation menu"
            aria-expanded={drawerOpen}
            aria-controls={drawerOpen ? 'partner-navigation-drawer' : undefined}
            onClick={() => setDrawerOpen(true)}
            className="-ml-1"
          >
            <Menu className="size-5" aria-hidden="true" />
          </Button>
          <img
            src="/bomach-logo.png"
            alt="Bomach OS"
            className="h-9 w-[5.75rem] shrink-0 object-contain object-left"
          />
          <div className="ml-auto flex items-center gap-1">
            <Button
              variant="ghost"
              size="icon"
              aria-label={`${unreadNotifications ? `${unreadNotifications} unread ` : ''}Open updates`}
              onClick={() => selectTab('notifications')}
              className="relative"
            >
              <Bell className="size-[18px]" aria-hidden="true" />
              {unreadNotifications > 0 ? (
                <span className="bg-danger absolute top-1 right-1 size-2 rounded-full" />
              ) : null}
            </Button>
            <Button
              variant="ghost"
              size="icon"
              aria-label="Open partner profile"
              onClick={() => setProfileOpen(true)}
            >
              <CircleUserRound className="size-[18px]" aria-hidden="true" />
            </Button>
          </div>
        </header>

        <main className="phone:px-5 tablet:px-6 tablet:py-7 wide:px-8 mx-auto w-full max-w-[1440px] space-y-5 px-4 py-5">
          {profileIncomplete && onboardingDismissed ? (
            <div className="border-warning/30 bg-warning/5 rounded-control flex min-h-11 items-center justify-between gap-2 border px-3 py-2">
              <p className="text-caption text-text-secondary flex min-w-0 items-center gap-2">
                <CircleAlert
                  className="text-warning-foreground size-4 shrink-0"
                  aria-hidden="true"
                />
                <span className="truncate">
                  <span className="text-text-primary font-semibold">Profile incomplete</span>
                  <span className="phone:inline hidden"> · Add your name and phone number.</span>
                </span>
              </p>
              <Button size="sm" variant="outline" onClick={() => setProfileOpen(true)}>
                Finish setup
              </Button>
            </div>
          ) : null}

          <section className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#061A3A] via-[#0B2A55] to-[#173D70] p-5 text-white shadow-lg shadow-[#061A3A]/10 sm:p-7">
            <div
              aria-hidden="true"
              className="pointer-events-none absolute -top-20 -right-12 size-64 rounded-full border-[36px] border-white/[0.06]"
            />
            <div className="relative flex flex-wrap items-end justify-between gap-4">
              <div className="min-w-0">
                <p className="text-[10px] font-extrabold tracking-[0.2em] text-[#F0B8B8]">
                  {activeTab.label.toUpperCase()} · {roleLabels[profile.partner_role].toUpperCase()}
                </p>
                <h1 className="mt-2 max-w-3xl text-2xl font-semibold tracking-tight break-words sm:text-3xl">
                  {activeTab.id === 'home'
                    ? `Welcome${profile.name ? `, ${profile.name.split(' ')[0]}` : ''}`
                    : activeTab.label}
                </h1>
                <p className="mt-2 max-w-2xl text-sm leading-6 text-white/75">
                  {activeTab.id === 'home'
                    ? roleWelcome(profile.partner_role)
                    : `Your ${activeTab.label.toLowerCase()} for the Bomach partner network.`}
                </p>
              </div>
              <div className="flex flex-wrap gap-2">
                <StatusChip
                  label={profile.status.replaceAll('_', ' ')}
                  tone={statusTone(profile.status)}
                />
                <StatusChip
                  label={`KYC ${profile.kyc_status.replaceAll('_', ' ')}`}
                  tone={profile.kyc_status === 'approved' ? 'success' : 'neutral'}
                />
              </div>
            </div>
          </section>

          {routeSearch.tab === 'home' ? (
            <div className="space-y-5">
              <section
                className="wide:grid-cols-4 grid gap-3 sm:grid-cols-2"
                aria-label="Partner overview"
              >
                {isRealtor ? (
                  <>
                    <Metric
                      label="Referred leads"
                      value={leadsQuery.isPending ? '—' : String(leads.length)}
                      icon={Handshake}
                    />
                    <Metric
                      label="Approved catalogue"
                      value={
                        catalogueQuery.isPending
                          ? '—'
                          : String(
                              (catalogueQuery.data?.estates.length ?? 0) +
                                (catalogueQuery.data?.properties.length ?? 0) +
                                (catalogueQuery.data?.brokerage_listings.length ?? 0),
                            )
                      }
                      icon={Building2}
                    />
                    <Metric
                      label="Commission items"
                      value={
                        earningsQuery.isPending ? '—' : String(earningsQuery.data?.length ?? 0)
                      }
                      icon={BriefcaseBusiness}
                    />
                    <Metric label="Unread updates" value={String(totalUnread)} icon={Bell} />
                  </>
                ) : (
                  <>
                    <Metric
                      label="Assigned jobs"
                      value={jobsQuery.isPending ? '—' : String(jobs.length)}
                      icon={BriefcaseBusiness}
                    />
                    <Metric
                      label="In progress"
                      value={
                        jobsQuery.isPending
                          ? '—'
                          : String(
                              jobs.filter((job) =>
                                ['in_progress', 'assigned', 'submitted'].includes(job.status),
                              ).length,
                            )
                      }
                      icon={ClipboardList}
                    />
                    <Metric
                      label="Due dates set"
                      value={
                        jobsQuery.isPending
                          ? '—'
                          : String(jobs.filter((job) => Boolean(job.due_date)).length)
                      }
                      icon={Building2}
                    />
                    <Metric label="Unread updates" value={String(totalUnread)} icon={Bell} />
                  </>
                )}
              </section>
              <Card className="overflow-hidden p-0">
                <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b px-4 py-4 sm:px-5">
                  <div>
                    <h2 className="text-text-primary text-lg font-semibold">
                      {isRealtor ? 'Recent referred leads' : 'Recent assigned work'}
                    </h2>
                    <p className="text-caption text-text-secondary mt-1">
                      Recent activity and items shared with your account.
                    </p>
                  </div>
                  <Button variant="outline" size="sm" onClick={() => selectTab('work')}>
                    View work
                    <ChevronRight className="size-4" />
                  </Button>
                </div>
                {isRealtor ? (
                  <LeadList
                    items={leads.slice(0, 4)}
                    pending={leadsQuery.isPending}
                    error={leadsQuery.error}
                  />
                ) : (
                  <JobList
                    items={jobs.slice(0, 4)}
                    pending={jobsQuery.isPending}
                    error={jobsQuery.error}
                  />
                )}
              </Card>
              {isRealtor ? (
                <CataloguePreview
                  catalogue={catalogueQuery.data}
                  pending={catalogueQuery.isPending}
                  error={catalogueQuery.error}
                  compact
                />
              ) : null}
            </div>
          ) : null}

          {routeSearch.tab === 'work' ? (
            isRealtor ? (
              <div className="space-y-5">
                <Card className="overflow-hidden p-0">
                  <SectionHeading
                    title="Referred leads"
                    description="Leads connected to your partner account."
                    count={leads.length}
                  />
                  <LeadList items={leads} pending={leadsQuery.isPending} error={leadsQuery.error} />
                </Card>
                <CataloguePreview
                  catalogue={catalogueQuery.data}
                  pending={catalogueQuery.isPending}
                  error={catalogueQuery.error}
                />
              </div>
            ) : (
              <Card className="overflow-hidden p-0">
                <SectionHeading
                  title="Assigned professional work"
                  description="Work items shared with your partner account."
                  count={jobs.length}
                />
                <JobList items={jobs} pending={jobsQuery.isPending} error={jobsQuery.error} />
              </Card>
            )
          ) : null}

          {routeSearch.tab === 'messages' ? (
            <Card className="overflow-hidden p-0">
              <SectionHeading
                title="Messages"
                description="Choose a Bomach contact. Each conversation is private to you and that staff member."
                count={messagesQuery.data?.conversations.length ?? 0}
              />
              {messagesQuery.isPending ? (
                <LoadingRows />
              ) : messagesQuery.error ? (
                <SectionErrorState
                  error={messagesQuery.error}
                  onRetry={() => void messagesQuery.refetch()}
                />
              ) : messagesQuery.data ? (
                <div className="desktop:grid-cols-[minmax(14rem,0.65fr)_minmax(0,1.5fr)] grid min-w-0 gap-0">
                  <aside className="border-border-subtle desktop:border-r desktop:border-b-0 min-w-0 border-b p-3 sm:p-4">
                    <h2 className="text-label text-text-primary px-2 font-semibold">
                      Contact threads
                    </h2>
                    <div className="mt-2 space-y-1">
                      {messagesQuery.data.contacts.map((contact) => {
                        const conversation = messagesQuery.data?.conversations.find(
                          (item) =>
                            item.kind === 'direct' && item.staff_user_id === contact.staff_user_id,
                        )
                        const selected = conversation?.id === selectedConversationId
                        return (
                          <button
                            key={contact.staff_user_id}
                            type="button"
                            aria-pressed={selected}
                            onClick={() => {
                              if (conversation) setActiveConversationId(conversation.id)
                              else startConversationMutation.mutate(contact.staff_user_id)
                            }}
                            className={`focus-visible:shadow-focus-ring flex min-h-14 w-full min-w-0 items-center gap-3 rounded-xl px-3 py-2 text-left ${selected ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
                          >
                            <span className="bg-surface flex size-9 shrink-0 items-center justify-center rounded-lg">
                              <UserRound className="size-4" />
                            </span>
                            <span className="min-w-0 flex-1">
                              <span className="block truncate text-sm font-semibold">
                                {contact.name}
                              </span>
                              <span className="text-caption block truncate">
                                {contact.source === 'inviter'
                                  ? 'Bomach contact'
                                  : contact.is_primary
                                    ? 'Primary contact'
                                    : contact.designation || 'Partner contact'}
                              </span>
                            </span>
                            {contact.is_primary ? (
                              <StatusChip label="Primary" tone="info" dense />
                            ) : null}
                          </button>
                        )
                      })}
                      {messagesQuery.data.support_available ? (
                        <button
                          type="button"
                          aria-pressed={selectedConversation?.kind === 'unassigned'}
                          onClick={() => {
                            const existing = messagesQuery.data?.conversations.find(
                              (item) => item.kind === 'unassigned' && item.status === 'queued',
                            )
                            if (existing) setActiveConversationId(existing.id)
                            else startConversationMutation.mutate()
                          }}
                          className={`focus-visible:shadow-focus-ring flex min-h-14 w-full items-center gap-3 rounded-xl px-3 py-2 text-left ${selectedConversation?.kind === 'unassigned' ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
                        >
                          <span className="bg-surface flex size-9 items-center justify-center rounded-lg">
                            <MessageSquareText className="size-4" />
                          </span>
                          <span>
                            <span className="block text-sm font-semibold">Bomach Support</span>
                            <span className="text-caption block">Shared support queue</span>
                          </span>
                        </button>
                      ) : null}
                    </div>
                    {messagesQuery.data.conversations.some(
                      (item) => item.kind === 'legacy' || item.status === 'read_only',
                    ) ? (
                      <div className="border-border-subtle mt-4 border-t pt-3">
                        <p className="text-caption text-text-muted px-2">Previous conversations</p>
                        {messagesQuery.data.conversations
                          .filter((item) => item.kind === 'legacy' || item.status === 'read_only')
                          .map((conversation) => (
                            <button
                              key={conversation.id}
                              type="button"
                              onClick={() => setActiveConversationId(conversation.id)}
                              className={`mt-1 flex min-h-11 w-full items-center gap-2 rounded-xl px-3 text-left text-sm ${selectedConversationId === conversation.id ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
                            >
                              <Clock3 className="size-4 shrink-0" />
                              <span className="min-w-0 truncate">
                                {conversation.kind === 'legacy'
                                  ? 'Earlier shared history'
                                  : conversation.staff_name}
                              </span>
                            </button>
                          ))}
                      </div>
                    ) : null}
                  </aside>

                  <section className="flex min-h-[30rem] min-w-0 flex-col">
                    {selectedConversation ? (
                      <>
                        <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b p-4">
                          <div className="min-w-0">
                            <h2 className="text-label text-text-primary font-semibold break-words">
                              {selectedConversation.kind === 'legacy'
                                ? 'Earlier shared history'
                                : selectedConversation.kind === 'unassigned'
                                  ? 'Bomach Support'
                                  : selectedConversation.staff_name}
                            </h2>
                            <p className="text-caption text-text-secondary mt-1">
                              {selectedConversation.kind === 'legacy' ||
                              selectedConversation.status === 'read_only'
                                ? 'This conversation is read only.'
                                : selectedConversation.kind === 'unassigned'
                                  ? 'A support contact will claim this conversation.'
                                  : 'Private partner conversation.'}
                            </p>
                          </div>
                          {selectedConversation.status === 'read_only' ||
                          selectedConversation.kind === 'legacy' ? (
                            <StatusChip label="Read only" tone="neutral" dense />
                          ) : null}
                        </div>
                        <div className="bg-background min-h-0 flex-1 space-y-3 overflow-y-auto p-4">
                          {conversationMessagesQuery.isPending ? <LoadingRows /> : null}
                          {conversationMessagesQuery.error ? (
                            <SectionErrorState
                              error={conversationMessagesQuery.error}
                              onRetry={() => void conversationMessagesQuery.refetch()}
                            />
                          ) : null}
                          {conversationMessagesQuery.data?.length
                            ? [...conversationMessagesQuery.data].reverse().map((item) => (
                                <article
                                  key={item.id}
                                  className={`max-w-[92%] rounded-2xl border p-3 sm:p-4 ${item.is_from_partner ? 'border-primary/15 bg-primary-subtle/50 ml-auto' : 'border-border-subtle bg-surface'}`}
                                >
                                  <div className="flex flex-wrap items-center justify-between gap-2">
                                    <div className="flex flex-wrap items-center gap-2">
                                      <h3 className="text-body-sm text-text-primary font-semibold">
                                        {item.subject || 'Message'}
                                      </h3>
                                      <StatusChip
                                        dense
                                        label={
                                          item.is_from_partner
                                            ? 'You'
                                            : item.sender_name || selectedConversation.staff_name
                                        }
                                        tone={item.is_from_partner ? 'neutral' : 'info'}
                                      />
                                    </div>
                                    <span className="text-caption text-text-muted">
                                      {formatDate(item.created_at)}
                                    </span>
                                  </div>
                                  <p className="text-body-sm text-text-secondary mt-3 leading-6 break-words whitespace-pre-wrap">
                                    {item.body}
                                  </p>
                                  {item.attachments?.length ? (
                                    <ul className="mt-3 space-y-1">
                                      {item.attachments.map((file) => (
                                        <li key={file.id}>
                                          <a
                                            className="text-caption text-primary underline"
                                            href={file.download_url}
                                          >
                                            {file.name}
                                          </a>
                                        </li>
                                      ))}
                                    </ul>
                                  ) : null}
                                </article>
                              ))
                            : null}
                          {!conversationMessagesQuery.isPending &&
                          !conversationMessagesQuery.error &&
                          !conversationMessagesQuery.data?.length ? (
                            <EmptyState
                              title="No messages yet"
                              description="Start the conversation with this contact."
                              icon={<MessageSquareText className="size-5" />}
                            />
                          ) : null}
                        </div>
                        {selectedConversation.can_reply ? (
                          <form
                            className="border-border-subtle space-y-4 border-t p-4"
                            onSubmit={sendMessage}
                          >
                            {selectedConversation.kind === 'unassigned' ? (
                              <Alert tone="info">
                                Your message will be visible to the authorized Bomach support team
                                until a contact claims this conversation.
                              </Alert>
                            ) : null}
                            <FormControl id="partner-message-subject" label="Subject" required>
                              <TextInput
                                value={subject}
                                onChange={(event) => setSubject(event.currentTarget.value)}
                                maxLength={255}
                                required
                              />
                            </FormControl>
                            <FormControl id="partner-message-body" label="Message" required>
                              <TextArea
                                rows={4}
                                value={message}
                                onChange={(event) => setMessage(event.currentTarget.value)}
                                required
                              />
                            </FormControl>
                            {messageError ? (
                              <Alert tone="danger" role="alert">
                                {messageError}
                              </Alert>
                            ) : null}
                            <div className="flex justify-end">
                              <Button
                                type="submit"
                                isLoading={sendMessageMutation.isPending}
                                leadingIcon={<Mail className="size-4" />}
                              >
                                Send message
                              </Button>
                            </div>
                          </form>
                        ) : null}
                      </>
                    ) : (
                      <div className="flex flex-1 flex-col items-center justify-center gap-4 p-6 text-center">
                        {messagesQuery.data.contacts.length === 0 &&
                        !messagesQuery.data.support_available ? (
                          <Alert tone="warning">
                            Messaging is temporarily unavailable. Contact access has not been
                            configured for your Bomach branch.
                          </Alert>
                        ) : (
                          <EmptyState
                            title="Choose a contact"
                            description="Select one of your assigned Bomach contacts to open a private conversation."
                            icon={<MessageSquareText className="size-6" />}
                          />
                        )}
                        {startConversationMutation.error ? (
                          <Alert tone="danger" role="alert">
                            {
                              presentError(startConversationMutation.error, 'background-action')
                                .message
                            }
                          </Alert>
                        ) : null}
                      </div>
                    )}
                  </section>
                </div>
              ) : null}
            </Card>
          ) : null}

          {routeSearch.tab === 'notifications' ? (
            <Card className="overflow-hidden p-0">
              <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b px-4 py-4 sm:px-5">
                <div>
                  <h2 className="text-text-primary text-lg font-semibold">Updates</h2>
                  <p className="text-caption text-text-secondary mt-1">
                    Private notifications for your partner account.
                  </p>
                </div>
                {unreadNotifications > 0 ? (
                  <Button
                    variant="outline"
                    size="sm"
                    isLoading={notificationMutation.isPending}
                    onClick={() => notificationMutation.mutate('all')}
                  >
                    Mark all read
                  </Button>
                ) : null}
              </div>
              {notificationsQuery.isPending ? (
                <LoadingRows />
              ) : notificationsQuery.error ? (
                <SectionErrorState
                  error={notificationsQuery.error}
                  onRetry={() => void notificationsQuery.refetch()}
                />
              ) : notificationsQuery.data?.length ? (
                <div className="divide-border-subtle divide-y">
                  {notificationsQuery.data.map((item) => (
                    <article
                      key={item.id}
                      className={`flex min-w-0 gap-3 p-4 sm:px-5 ${item.is_read ? 'bg-surface' : 'bg-[#F3F7FD]'}`}
                    >
                      <span
                        className={`mt-0.5 flex size-9 shrink-0 items-center justify-center rounded-xl ${item.is_read ? 'bg-surface-muted text-text-secondary' : 'bg-[#E2ECFA] text-[#0B3974]'}`}
                      >
                        <Bell className="size-4" aria-hidden="true" />
                      </span>
                      <div className="min-w-0 flex-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <h3 className="text-text-primary font-semibold break-words">
                            {item.title}
                          </h3>
                          {!item.is_read ? <StatusChip label="New" tone="info" dense /> : null}
                        </div>
                        <p className="text-body-sm text-text-secondary mt-1 leading-6 break-words">
                          {item.message}
                        </p>
                        <p className="text-caption text-text-muted mt-2">
                          {formatDate(item.created_at)}
                        </p>
                      </div>
                      {!item.is_read ? (
                        <Button
                          variant="ghost"
                          size="icon"
                          aria-label={`Mark ${item.title} as read`}
                          onClick={() => notificationMutation.mutate(item.id)}
                        >
                          <Check className="size-4" />
                        </Button>
                      ) : null}
                    </article>
                  ))}
                </div>
              ) : (
                <EmptyState
                  title="You’re all caught up"
                  description="New partner activity and important updates will appear here."
                  icon={<Bell className="size-6" />}
                />
              )}
            </Card>
          ) : null}
        </main>
      </div>

      {drawerOpen ? (
        <div className="desktop:hidden fixed inset-0 z-50">
          <button
            type="button"
            aria-label="Close navigation menu"
            className="absolute inset-0 size-full cursor-default bg-neutral-900/45"
            onClick={() => setDrawerOpen(false)}
          />
          <div
            ref={drawerRef}
            id="partner-navigation-drawer"
            role="dialog"
            aria-modal="true"
            aria-label="Partner navigation menu"
            className="bg-surface shadow-elevation-lg relative flex h-dvh w-[min(300px,calc(100vw-2.5rem))] max-w-full flex-col"
            onKeyDown={handleDrawerKeyDown}
          >
            <div className="border-border-subtle flex items-center justify-between gap-3 border-b px-4 py-3">
              <BrandMark />
              <Button
                data-drawer-close
                variant="ghost"
                size="icon"
                aria-label="Close navigation menu"
                onClick={() => setDrawerOpen(false)}
              >
                <X className="size-5" aria-hidden="true" />
              </Button>
            </div>
            <PartnerNavigation
              selectedTab={selectedTab}
              unreadMessages={unreadMessages}
              unreadNotifications={unreadNotifications}
              collapsed={false}
              onSelect={selectTab}
            />
            <div className="border-border-subtle mt-auto border-t p-4">
              <button
                type="button"
                onClick={() => selectTab('profile')}
                className="rounded-control hover:bg-surface-muted flex w-full items-center gap-3 p-2 text-left"
              >
                <span className="bg-primary-subtle text-primary flex size-10 items-center justify-center rounded-full">
                  <CircleUserRound className="size-5" aria-hidden="true" />
                </span>
                <span className="min-w-0">
                  <span className="text-label block truncate font-semibold">
                    {profile.name || 'Partner account'}
                  </span>
                  <span className="text-caption text-text-secondary block">
                    {roleLabels[profile.partner_role]}
                  </span>
                </span>
              </button>
              <Button
                variant="ghost"
                className="mt-2 w-full justify-start"
                leadingIcon={<LogOut className="size-4" />}
                onClick={() => {
                  setDrawerOpen(false)
                  setSignOutOpen(true)
                }}
              >
                Sign out
              </Button>
            </div>
          </div>
        </div>
      ) : null}

      <Dialog
        open={profileDialogOpen}
        onOpenChange={handleProfileOpenChange}
        title={profileIncomplete ? 'Complete your profile' : 'Your profile'}
        description={
          profileIncomplete
            ? 'Add your name and phone number to finish setup.'
            : 'Review your contact details and account status.'
        }
        size="md"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => handleProfileOpenChange(false)}
              disabled={profileMutation.isPending}
            >
              {profileIncomplete ? 'Not now' : 'Close'}
            </Button>
            <Button
              type="submit"
              form="partner-profile-form"
              isLoading={profileMutation.isPending}
              leadingIcon={<Check className="size-4" />}
            >
              {profileIncomplete ? 'Finish setup' : 'Save changes'}
            </Button>
          </>
        }
      >
        <form
          id="partner-profile-form"
          className="space-y-4"
          onSubmit={saveProfile}
          key={`${profile.id}-${profile.profile_completed}`}
        >
          <div className="bg-surface-muted/50 rounded-control border-border-subtle flex flex-wrap items-center justify-between gap-3 border p-3">
            <div className="flex min-w-0 items-center gap-3">
              <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-full">
                <CircleUserRound className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-label truncate font-semibold">
                  {profile.name || 'Partner account'}
                </p>
                <p className="text-caption text-text-secondary truncate">{profile.email}</p>
              </div>
            </div>
            <StatusChip
              label={profileIncomplete ? 'Setup needed' : 'Active'}
              tone={profileIncomplete ? 'warning' : 'success'}
              dense
            />
          </div>

          <div className="tablet:grid-cols-2 grid gap-4">
            <FormControl id="partner-profile-name" label="Full name" required>
              <TextInput
                name="name"
                autoComplete="name"
                defaultValue={profile.name}
                minLength={2}
                required
              />
            </FormControl>
            <FormControl id="partner-profile-phone" label="Phone number" required>
              <TextInput
                name="phone"
                autoComplete="tel"
                type="tel"
                defaultValue={profile.phone}
                placeholder="Include country code if available"
                required
              />
            </FormControl>
            <FormControl id="partner-profile-email" label="Email address">
              <TextInput value={profile.email} readOnly disabled className="bg-surface-muted" />
            </FormControl>
            <FormControl id="partner-profile-address" label="Address (optional)">
              <TextInput
                name="address"
                autoComplete="street-address"
                defaultValue={profile.address}
                placeholder="Street, city, state"
              />
            </FormControl>
          </div>

          {profileMutation.error ? (
            <Alert tone="danger" role="alert">
              {presentError(profileMutation.error, 'form-submit').message}
            </Alert>
          ) : null}

          <div className="tablet:grid-cols-2 border-border-subtle grid gap-3 border-t pt-4">
            <div className="bg-surface-muted/50 rounded-control flex min-w-0 items-start gap-3 p-3">
              <Building2 className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
              <div className="min-w-0">
                <p className="text-caption text-text-muted">Branch access</p>
                <p className="text-body-sm mt-0.5 font-medium break-words">
                  {profile.branches.length
                    ? profile.branches.map((branch) => branch.branch_name).join(', ')
                    : 'Not assigned'}
                </p>
              </div>
            </div>
            <div className="bg-surface-muted/50 rounded-control flex min-w-0 items-start gap-3 p-3">
              <ShieldCheck className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
              <div className="min-w-0">
                <p className="text-caption text-text-muted">Verification</p>
                <p className="text-body-sm mt-0.5 font-medium capitalize">
                  {profile.kyc_status.replaceAll('_', ' ')}
                </p>
              </div>
            </div>
          </div>
          <p className="text-caption text-text-secondary">
            Partner role: <span className="font-semibold">{roleLabels[profile.partner_role]}</span>
          </p>
        </form>
      </Dialog>

      <Dialog
        open={signOutOpen}
        onOpenChange={setSignOutOpen}
        title="Sign out?"
        description="You can sign in again with your partner account."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setSignOutOpen(false)} disabled={signingOut}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={signingOut}
              leadingIcon={<LogOut className="size-4" />}
              onClick={() => void performSignOut()}
            >
              Sign out
            </Button>
          </>
        }
      >
        <div className="bg-surface-muted rounded-control flex items-center gap-3 p-3">
          <CircleUserRound className="text-primary size-5 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-caption text-text-secondary">Signed in as</p>
            <p className="text-body-sm truncate font-semibold">{profile.email}</p>
          </div>
        </div>
      </Dialog>
    </div>
  )
}

function SectionHeading({
  title,
  description,
  count,
}: {
  title: string
  description: string
  count: number
}) {
  return (
    <header className="border-border-subtle flex flex-wrap items-start justify-between gap-3 border-b px-4 py-4 sm:px-5">
      <div className="min-w-0">
        <h2 className="text-text-primary text-lg font-semibold">{title}</h2>
        <p className="text-caption text-text-secondary mt-1">{description}</p>
      </div>
      <StatusChip label={`${count} ${count === 1 ? 'item' : 'items'}`} tone="neutral" dense />
    </header>
  )
}

function LoadingRows() {
  return (
    <div className="space-y-3 p-4 sm:p-5">
      <Skeleton className="h-20" />
      <Skeleton className="h-20" />
      <Skeleton className="h-20" />
    </div>
  )
}

function LeadList({
  items,
  pending,
  error,
}: {
  items: PartnerLeadPreview[]
  pending: boolean
  error: unknown
}) {
  if (pending) return <LoadingRows />
  if (error)
    return <SectionErrorState error={error} description="Your lead list could not be loaded." />
  if (items.length === 0)
    return (
      <EmptyState
        title="No lead activity yet"
        description="Leads referred through your partner account will be listed here."
        icon={<Handshake className="size-6" />}
      />
    )
  return (
    <div className="divide-border-subtle divide-y">
      {items.map((item) => (
        <article
          key={item.id}
          className="flex min-w-0 flex-wrap items-center justify-between gap-3 px-4 py-4 sm:px-5"
        >
          <div className="min-w-0">
            <h3 className="text-text-primary font-semibold break-words">{item.full_name}</h3>
            <p className="text-caption text-text-secondary mt-1 flex flex-wrap items-center gap-x-3 gap-y-1">
              <span>{item.branch_name || 'Branch not specified'}</span>
              <span>Received {formatDate(item.created_at)}</span>
            </p>
            {item.next_action ? (
              <p className="text-caption mt-2 text-[#52627A]">Next: {item.next_action}</p>
            ) : null}
          </div>
          <StatusChip
            label={item.status_display || item.status.replaceAll('_', ' ')}
            tone={statusTone(item.status)}
            dense
          />
        </article>
      ))}
    </div>
  )
}

function JobList({
  items,
  pending,
  error,
}: {
  items: Awaited<ReturnType<typeof partnerPortalApi.jobs>>
  pending: boolean
  error: unknown
}) {
  if (pending) return <LoadingRows />
  if (error)
    return <SectionErrorState error={error} description="Your assigned work could not be loaded." />
  if (items.length === 0)
    return (
      <EmptyState
        title="No assigned work yet"
        description="When Bomach assigns professional work to your account, it will appear here."
        icon={<BriefcaseBusiness className="size-6" />}
      />
    )
  return (
    <div className="divide-border-subtle divide-y">
      {items.map((item) => (
        <article key={item.id} className="min-w-0 p-4 sm:p-5">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div className="min-w-0">
              <h3 className="text-text-primary font-semibold break-words">
                {item.title || item.code}
              </h3>
              <p className="text-caption text-text-secondary mt-1">
                {item.code} · {item.workflow_type.replaceAll('_', ' ')}
              </p>
            </div>
            <StatusChip
              label={item.status.replaceAll('_', ' ')}
              tone={statusTone(item.status)}
              dense
            />
          </div>
          <p className="text-body-sm text-text-secondary mt-3 leading-6 break-words whitespace-pre-wrap">
            {item.scope || 'No work summary provided.'}
          </p>
          <div className="text-caption text-text-secondary mt-3 flex flex-wrap gap-x-5 gap-y-2">
            <span>Due {formatDate(item.due_date)}</span>
            <span>Fee {formatMoney(item.approved_fee)}</span>
            {item.report_status ? (
              <span>Report {item.report_status.replaceAll('_', ' ')}</span>
            ) : null}
          </div>
          {item.deliverables.length ? (
            <div className="mt-4 flex flex-wrap gap-2">
              {item.deliverables.slice(0, 4).map((deliverable) => (
                <StatusChip
                  key={deliverable.id}
                  label={deliverable.title}
                  tone={statusTone(deliverable.status)}
                  dense
                />
              ))}
            </div>
          ) : null}
        </article>
      ))}
    </div>
  )
}

function CataloguePreview({
  catalogue,
  pending,
  error,
  compact = false,
}: {
  catalogue: Awaited<ReturnType<typeof partnerPortalApi.catalogue>> | undefined
  pending: boolean
  error: unknown
  compact?: boolean
}) {
  if (pending)
    return (
      <Card>
        <Skeleton className="h-28" />
      </Card>
    )
  if (error)
    return (
      <SectionErrorState
        title="Property catalogue unavailable"
        description="Approved property information could not be loaded."
        error={error}
      />
    )
  const items = [
    ...(catalogue?.estates ?? []).map((item) => ({
      id: `estate-${item.id}`,
      title: item.name,
      detail: [item.city_town, item.state].filter(Boolean).join(', '),
      kind: 'Estate',
    })),
    ...(catalogue?.properties ?? []).map((item) => ({
      id: `property-${item.id}`,
      title: item.name,
      detail: item.estate_name || 'Bomach property',
      kind: 'Property',
    })),
    ...(catalogue?.brokerage_listings ?? []).map((item) => ({
      id: `listing-${item.id}`,
      title: item.title,
      detail: item.location,
      kind: 'Listing',
    })),
  ]
  const visible = compact ? items.slice(0, 3) : items
  return (
    <Card className="overflow-hidden p-0">
      <SectionHeading
        title="Approved property catalogue"
        description="Approved properties available to share with clients."
        count={items.length}
      />
      {visible.length ? (
        <div className="bg-border-subtle wide:grid-cols-3 grid gap-px sm:grid-cols-2">
          {visible.map((item) => (
            <article key={item.id} className="bg-surface min-w-0 p-4">
              <StatusChip label={item.kind} tone="info" dense />
              <h3 className="text-text-primary mt-2 font-semibold break-words">{item.title}</h3>
              <p className="text-caption text-text-secondary mt-1 flex items-start gap-1.5">
                <MapPin className="mt-0.5 size-3.5 shrink-0" />
                {item.detail || 'Location not listed'}
              </p>
            </article>
          ))}
        </div>
      ) : (
        <EmptyState
          title="No approved listings yet"
          description="Approved Bomach estates and properties will appear here when available."
          icon={<Building2 className="size-6" />}
        />
      )}
    </Card>
  )
}
