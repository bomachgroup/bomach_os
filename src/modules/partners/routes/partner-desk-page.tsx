import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  BadgeCheck,
  ChevronLeft,
  ChevronRight,
  CircleAlert,
  Handshake,
  Mail,
  MessageSquareText,
  Plus,
  RefreshCw,
  Search,
  Send,
  UserRound,
  UsersRound,
  XCircle,
} from 'lucide-react'
import { useCallback, useEffect, useMemo, useState, type FormEvent } from 'react'

import {
  partnerAdminApi,
  partnerQueryKeys,
  type PartnerInvitationDto,
  type PartnerInvitationInput,
  type PartnerContactCandidate,
  type PartnerRole,
} from '@/modules/partners/partner.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type { PartnerDeskSearch } from '../partner.search'

const PAGE_SIZE = 10
const roleLabels: Record<PartnerRole, string> = {
  realtor: 'Realtor',
  surveyor: 'Surveyor',
  lawyer: 'Legal associate',
  consultant: 'Consultant',
}

function partnerTone(value: string): StatusTone {
  if (value === 'active' || value === 'accepted') return 'success'
  if (value === 'pending' || value === 'sent') return 'warning'
  if (value === 'suspended' || value === 'revoked' || value === 'expired') return 'danger'
  return 'neutral'
}

function deliveryLabel(item: PartnerInvitationDto) {
  if (item.delivery_status === 'failed') return 'Email failed'
  if (item.status === 'accepted' || item.setup_completed_at) return 'Account set up'
  if (item.status === 'expired') return 'Invitation expired'
  if (item.status === 'revoked') return 'Invitation revoked'
  if (item.delivery_status === 'sent') return 'Email sent'
  return 'Sending invitation'
}

function deliveryTone(item: PartnerInvitationDto): StatusTone {
  if (item.delivery_status === 'failed' || item.status === 'revoked' || item.status === 'expired')
    return 'danger'
  if (item.status === 'accepted' || item.setup_completed_at) return 'success'
  if (item.delivery_status === 'sent') return 'info'
  return 'warning'
}

function PartnerSearch({ value, onCommit }: { value: string; onCommit: (value: string) => void }) {
  const [draft, setDraft] = useState(value)
  useEffect(() => {
    const next = draft.trim()
    if (next === value) return
    const timer = window.setTimeout(() => onCommit(next), 250)
    return () => window.clearTimeout(timer)
  }, [draft, onCommit, value])

  return (
    <label className="relative block min-w-0 flex-1" htmlFor="partner-search">
      <span className="sr-only">Search partners and invitations</span>
      <Search
        className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
        aria-hidden="true"
      />
      <TextInput
        id="partner-search"
        type="search"
        value={draft}
        onChange={(event) => setDraft(event.currentTarget.value)}
        placeholder="Search name, email, or partner code"
        className="pl-10"
      />
    </label>
  )
}

function InvitePartnerDialog({
  open,
  onOpenChange,
  onInvite,
  sending,
  error,
  branches,
  viewerId,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  onInvite: (input: PartnerInvitationInput) => void
  sending: boolean
  error: string
  branches: Array<{ id: number; name: string; code: string }>
  viewerId?: number
}) {
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [role, setRole] = useState<PartnerRole>('realtor')
  const [branchId, setBranchId] = useState(() =>
    branches.length === 1 ? String(branches[0].id) : '',
  )
  const [territory, setTerritory] = useState('')
  const [commission, setCommission] = useState('')
  const [contactIds, setContactIds] = useState<number[]>([])
  const [primaryContactId, setPrimaryContactId] = useState<number | null>(null)
  const [fieldError, setFieldError] = useState('')
  const contactsQuery = useQuery({
    queryKey: [...partnerQueryKeys.all, 'invitation-contacts', viewerId, branchId],
    queryFn: ({ signal }) => partnerAdminApi.invitationContacts(Number(branchId), signal),
    enabled: open && Boolean(viewerId) && Boolean(branchId),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const branchOptions: DropdownSelectOption[] = useMemo(
    () =>
      branches.map((branch) => ({
        value: String(branch.id),
        label: branch.name,
        description: branch.code,
      })),
    [branches],
  )
  const roleOptions: DropdownSelectOption[] = Object.entries(roleLabels).map(([value, label]) => ({
    value,
    label,
  }))

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFieldError('')
    if (!email.trim()) {
      setFieldError('Enter the partner’s email address.')
      return
    }
    if (!branchId) {
      setFieldError('Choose the branch that will own this partner record.')
      return
    }
    if (
      commission &&
      (!Number.isFinite(Number(commission)) || Number(commission) < 0 || Number(commission) > 100)
    ) {
      setFieldError('Enter a commission rate between 0 and 100.')
      return
    }
    onInvite({
      email: email.trim(),
      ...(name.trim() ? { name: name.trim() } : {}),
      ...(phone.trim() ? { phone: phone.trim() } : {}),
      partner_role: role,
      branch_id: Number(branchId),
      contact_employee_ids: contactIds,
      primary_contact_employee_id: primaryContactId,
      ...(role === 'realtor' && commission ? { commission_rate: Number(commission) } : {}),
      ...(role === 'realtor' && territory.trim() ? { territory: territory.trim() } : {}),
    })
  }

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title="Invite a partner"
      description="Send secure account setup access to an external partner. They will complete their required profile after setting a password."
      size="lg"
      fitContent
      bodyClassName="bg-background"
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={sending}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="partner-invite-form"
            isLoading={sending}
            leadingIcon={<Send className="size-4" aria-hidden="true" />}
          >
            Send invitation
          </Button>
        </>
      }
    >
      <form id="partner-invite-form" className="space-y-5" onSubmit={submit}>
        <div className="phone:grid-cols-2 grid min-w-0 gap-4">
          <FormControl id="partner-invite-email" label="Email address" required>
            <TextInput
              type="email"
              autoComplete="email"
              value={email}
              onChange={(event) => setEmail(event.currentTarget.value)}
              required
            />
          </FormControl>
          <FormControl id="partner-invite-role" label="Partner role" required>
            <DropdownSelect
              value={role}
              options={roleOptions}
              onChange={(value) => setRole(value as PartnerRole)}
              required
            />
          </FormControl>
          <FormControl
            id="partner-invite-branch"
            label="Owning branch"
            required
            className="phone:col-span-2"
            description={
              branches.length === 0
                ? 'No active branch is available in your access scope. Ask an administrator to update your branch access.'
                : undefined
            }
          >
            <DropdownSelect
              value={branchId}
              options={branchOptions}
              onChange={(value) => {
                setBranchId(value)
                setContactIds([])
                setPrimaryContactId(null)
              }}
              placeholder="Select an authorized branch"
              searchable={branches.length > 6}
              disabled={branches.length === 0}
              required
            />
          </FormControl>
          <section
            aria-labelledby="partner-message-contacts-heading"
            className="phone:col-span-2 border-border-subtle bg-surface-muted/60 min-w-0 rounded-2xl border p-4 sm:p-5"
          >
            <div className="flex min-w-0 flex-wrap items-start justify-between gap-3">
              <div className="flex min-w-0 items-start gap-3">
                <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-xl">
                  <UsersRound className="size-5" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <h3
                    id="partner-message-contacts-heading"
                    className="text-label text-text-primary font-semibold"
                  >
                    Partner message contacts
                  </h3>
                  <p className="text-caption text-text-secondary mt-1 max-w-2xl">
                    Choose who will handle this partner’s private messages. Only active staff with
                    message and branch access appear here.
                  </p>
                </div>
              </div>
              {branchId && contactsQuery.isSuccess ? (
                <span className="text-caption text-text-secondary bg-surface shrink-0 rounded-full px-3 py-1">
                  {contactsQuery.data.items.length}{' '}
                  {contactsQuery.data.items.length === 1
                    ? 'eligible staff member'
                    : 'eligible staff'}
                </span>
              ) : null}
            </div>
            {!branchId ? (
              <div className="border-border-subtle bg-surface mt-4 rounded-xl border border-dashed p-4">
                <p className="text-body-sm text-text-secondary">
                  Select an owning branch to see staff who can access partner messages there.
                </p>
              </div>
            ) : contactsQuery.isPending ? (
              <div className="mt-4 space-y-2" aria-label="Loading eligible contacts">
                <Skeleton className="h-16" />
                <Skeleton className="h-16" />
              </div>
            ) : contactsQuery.error ? (
              <Alert className="mt-4" tone="danger" role="alert">
                Eligible staff could not be loaded. You can still send the invitation and update
                contacts later.
              </Alert>
            ) : (contactsQuery.data?.items.length ?? 0) > 0 ? (
              <div className="mt-4 space-y-2" role="group" aria-label="Eligible message contacts">
                {(contactsQuery.data?.items ?? []).map((contact: PartnerContactCandidate) => {
                  const selected = contactIds.includes(contact.employee_id)
                  return (
                    <div
                      key={contact.employee_id}
                      className={`flex min-w-0 flex-wrap items-center gap-3 rounded-xl border p-3 transition-colors sm:p-3.5 ${selected ? 'border-primary bg-primary-subtle/50' : 'border-border-subtle bg-surface'}`}
                    >
                      <label className="flex min-w-0 flex-1 cursor-pointer items-center gap-3">
                        <input
                          type="checkbox"
                          checked={selected}
                          onChange={(event) => {
                            const next = event.currentTarget.checked
                              ? [...contactIds, contact.employee_id]
                              : contactIds.filter((id) => id !== contact.employee_id)
                            setContactIds(next)
                            if (!next.includes(primaryContactId ?? -1)) {
                              setPrimaryContactId(next[0] ?? null)
                            }
                          }}
                          className="accent-primary size-4 shrink-0"
                          aria-label={`Assign ${contact.name} as a partner contact`}
                        />
                        <span className="bg-primary-subtle text-primary flex size-9 shrink-0 items-center justify-center rounded-lg">
                          <UserRound className="size-4" aria-hidden="true" />
                        </span>
                        <span className="min-w-0">
                          <span className="text-body-sm text-text-primary block font-semibold break-words">
                            {contact.name}
                          </span>
                          <span className="text-caption text-text-secondary mt-0.5 block break-all">
                            {contact.designation || contact.email}
                            {contact.designation ? ` · ${contact.email}` : ''}
                          </span>
                        </span>
                      </label>
                      {selected ? (
                        <label className="text-caption text-text-secondary ml-7 inline-flex shrink-0 items-center gap-2 sm:ml-0">
                          <input
                            type="radio"
                            name="primary-partner-contact"
                            checked={primaryContactId === contact.employee_id}
                            onChange={() => setPrimaryContactId(contact.employee_id)}
                            className="accent-primary size-4"
                            aria-label={`Set ${contact.name} as primary contact`}
                          />
                          Primary
                        </label>
                      ) : null}
                    </div>
                  )
                })}
              </div>
            ) : (
              <Alert className="mt-4" tone="info">
                No eligible staff have partner-message access for this branch. You can send the
                invitation without selecting a contact and assign staff later.
              </Alert>
            )}
          </section>
          <FormControl id="partner-invite-name" label="Name (optional)">
            <TextInput
              autoComplete="name"
              value={name}
              onChange={(event) => setName(event.currentTarget.value)}
              placeholder="Partner’s full name"
            />
          </FormControl>
          <FormControl id="partner-invite-phone" label="Phone (optional)">
            <TextInput
              autoComplete="tel"
              type="tel"
              value={phone}
              onChange={(event) => setPhone(event.currentTarget.value)}
              placeholder="Phone number"
            />
          </FormControl>
          {role === 'realtor' ? (
            <>
              <FormControl id="partner-invite-territory" label="Territory (optional)">
                <TextInput
                  value={territory}
                  onChange={(event) => setTerritory(event.currentTarget.value)}
                  placeholder="e.g. Enugu metropolis"
                />
              </FormControl>
              <FormControl id="partner-invite-commission" label="Commission rate (optional)">
                <TextInput
                  type="number"
                  min="0"
                  max="100"
                  step="0.01"
                  value={commission}
                  onChange={(event) => setCommission(event.currentTarget.value)}
                  placeholder="Set later if needed"
                />
              </FormControl>
            </>
          ) : null}
        </div>
        {fieldError ? (
          <Alert tone="danger" role="alert">
            {fieldError}
          </Alert>
        ) : null}
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
      </form>
    </Dialog>
  )
}

export function PartnerDeskPage() {
  const routeSearch = useSearch({ from: '/_protected/company/partners' }) as PartnerDeskSearch
  const navigate = useNavigate({ from: '/company/partners' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const permissions = sessionQuery.data?.permissions ?? {}
  const canList = hasPermission(permissions, 'partners', 'list')
  const canInvite = hasPermission(permissions, 'partners', 'invite')
  const canReceiveQueue =
    hasPermission(permissions, 'partner_messages', 'list') &&
    hasPermission(permissions, 'partner_messages', 'receive_unassigned')
  const [view, setView] = useState<'partners' | 'invitations' | 'queue'>('partners')
  const [inviteOpen, setInviteOpen] = useState(false)
  const [revokeTarget, setRevokeTarget] = useState<PartnerInvitationDto | null>(null)
  const [mutationError, setMutationError] = useState('')

  const commitSearch = useCallback(
    (search: string) => {
      void navigate({
        search: (previous: PartnerDeskSearch) => ({ ...previous, search, page: 1 }),
        replace: true,
      })
    },
    [navigate],
  )

  const listQuery = useQuery({
    queryKey: [...partnerQueryKeys.directory(routeSearch.search), routeSearch.page],
    queryFn: ({ signal }) =>
      partnerAdminApi.partners(
        {
          limit: PAGE_SIZE,
          offset: (routeSearch.page - 1) * PAGE_SIZE,
          search: routeSearch.search,
        },
        signal,
      ),
    enabled: canList && view === 'partners',
    placeholderData: keepPreviousData,
  })
  const invitationQuery = useQuery({
    queryKey: [...partnerQueryKeys.invitations(routeSearch.search), routeSearch.page],
    queryFn: ({ signal }) =>
      partnerAdminApi.invitations(
        {
          limit: PAGE_SIZE,
          offset: (routeSearch.page - 1) * PAGE_SIZE,
          search: routeSearch.search,
        },
        signal,
      ),
    enabled: canList && view === 'invitations',
    placeholderData: keepPreviousData,
  })
  const choicesQuery = useQuery({
    queryKey: [...partnerQueryKeys.all, 'invitation-choices'],
    queryFn: ({ signal }) => partnerAdminApi.invitationChoices(signal),
    enabled: canInvite,
    staleTime: 5 * 60 * 1000,
  })
  const queueQuery = useQuery({
    queryKey: partnerQueryKeys.unassignedConversations(sessionQuery.data?.user.id ?? 0),
    queryFn: ({ signal }) => partnerAdminApi.unassignedConversations(signal),
    enabled: canReceiveQueue && Boolean(sessionQuery.data?.user.id),
    staleTime: DATA_FRESHNESS_MS.live,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    refetchInterval: DATA_FRESHNESS_MS.live,
    refetchIntervalInBackground: false,
  })

  const invalidateLists = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: [...partnerQueryKeys.all, 'directory'] }),
      queryClient.invalidateQueries({ queryKey: [...partnerQueryKeys.all, 'invitations'] }),
    ])
  }

  const inviteMutation = useMutation({
    mutationFn: (input: PartnerInvitationInput) => partnerAdminApi.invite(input),
    onSuccess: async () => {
      await invalidateLists()
      setInviteOpen(false)
      setMutationError('')
      showToast({
        title: 'Invitation sent',
        description: 'The partner setup email has been queued.',
        tone: 'success',
      })
    },
    onError: (error) => setMutationError(presentError(error, 'form-submit').message),
  })
  const resendMutation = useMutation({
    mutationFn: (id: number) => partnerAdminApi.resend(id),
    onSuccess: async () => {
      await invalidateLists()
      showToast({
        title: 'Invitation resent',
        description: 'A fresh setup link has been sent.',
        tone: 'success',
      })
    },
  })
  const revokeMutation = useMutation({
    mutationFn: (id: number) => partnerAdminApi.revoke(id),
    onSuccess: async () => {
      await invalidateLists()
      setRevokeTarget(null)
      showToast({
        title: 'Invitation revoked',
        description: 'The setup link can no longer be used.',
        tone: 'success',
      })
    },
  })

  const pageCount = Math.max(
    1,
    Math.ceil(
      ((view === 'partners'
        ? listQuery.data?.count
        : view === 'invitations'
          ? invitationQuery.data?.count
          : 0) ?? 0) / PAGE_SIZE,
    ),
  )
  const pageError =
    view === 'queue'
      ? queueQuery.data === undefined
        ? queueQuery.error
        : null
      : canList
        ? view === 'partners'
          ? listQuery.error
          : invitationQuery.error
        : null

  function setPage(page: number) {
    void navigate({
      search: (previous: PartnerDeskSearch) => ({ ...previous, page }),
      replace: true,
    })
  }

  return (
    <>
      <PageLayout
        title="Partners"
        subtitle="Invite external professionals and track their account onboarding."
        actionsInline
        actions={
          canInvite ? (
            <Button
              disabled={
                choicesQuery.isPending ||
                choicesQuery.isError ||
                (choicesQuery.data?.branches.length ?? 0) === 0
              }
              onClick={() => {
                setMutationError('')
                setInviteOpen(true)
              }}
              aria-label="Invite partner"
              className="max-[479px]:min-h-9 max-[479px]:px-3"
              leadingIcon={<Plus className="size-4" aria-hidden="true" />}
            >
              <span className="max-[479px]:hidden">Invite partner</span>
              <span className="hidden max-[479px]:inline max-[361px]:hidden">Invite</span>
            </Button>
          ) : undefined
        }
      >
        <div className="space-y-5">
          <Card className="space-y-4 p-4 sm:p-5">
            <div className="tablet:flex-row tablet:items-center tablet:justify-between flex flex-col gap-3">
              <div
                className="bg-surface-muted flex min-w-0 gap-1 rounded-xl p-1"
                role="tablist"
                aria-label="Partner workspace lists"
              >
                <button
                  type="button"
                  role="tab"
                  aria-selected={view === 'partners'}
                  onClick={() => {
                    setView('partners')
                    setPage(1)
                  }}
                  className={`min-h-10 rounded-lg px-3 text-sm font-semibold transition-colors sm:px-4 ${view === 'partners' ? 'bg-surface text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
                >
                  Partner directory
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={view === 'invitations'}
                  onClick={() => {
                    setView('invitations')
                    setPage(1)
                  }}
                  className={`min-h-10 rounded-lg px-3 text-sm font-semibold transition-colors sm:px-4 ${view === 'invitations' ? 'bg-surface text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
                >
                  Invitation history
                </button>
                {(queueQuery.data?.length ?? 0) > 0 ? (
                  <button
                    type="button"
                    role="tab"
                    aria-selected={view === 'queue'}
                    onClick={() => setView('queue')}
                    className={`min-h-10 rounded-lg px-3 text-sm font-semibold transition-colors sm:px-4 ${view === 'queue' ? 'bg-surface text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
                  >
                    Unassigned messages
                  </button>
                ) : null}
              </div>
              {canList && view !== 'queue' ? (
                <div className="tablet:max-w-xl flex min-w-0 flex-1 gap-2">
                  <PartnerSearch
                    key={routeSearch.search}
                    value={routeSearch.search}
                    onCommit={commitSearch}
                  />
                  {routeSearch.search ? (
                    <Button
                      variant="ghost"
                      size="icon"
                      aria-label="Clear search"
                      onClick={() => commitSearch('')}
                    >
                      <XCircle className="size-4" />
                    </Button>
                  ) : null}
                </div>
              ) : null}
            </div>

            {canReceiveQueue && queueQuery.error && !queueQuery.data?.length ? (
              <SectionErrorState
                className="mt-4"
                title="Unassigned messages could not be checked"
                description="The queue tab will appear when messages are available. Retry to check the queue again."
                error={queueQuery.error}
                onRetry={() => void queueQuery.refetch()}
              />
            ) : null}

            {!canList && view !== 'queue' ? (
              <EmptyState
                title="Invitation access only"
                description="You can create new invitations, but your account does not have permission to view the partner directory or invitation history."
                icon={<Handshake className="size-6" />}
              />
            ) : pageError ? (
              <ErrorState
                title="Partner records could not load"
                description="Retry the request. Your search and current page will be preserved."
                error={pageError}
                action={
                  <Button
                    variant="outline"
                    onClick={() =>
                      void (view === 'partners'
                        ? listQuery.refetch()
                        : view === 'invitations'
                          ? invitationQuery.refetch()
                          : queueQuery.refetch())
                    }
                  >
                    Try again
                  </Button>
                }
              />
            ) : (
                view === 'partners'
                  ? listQuery.isPending
                  : view === 'invitations'
                    ? invitationQuery.isPending
                    : queueQuery.isPending
              ) ? (
              <div className="space-y-3" aria-label="Loading partner records">
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
              </div>
            ) : view === 'queue' ? (
              queueQuery.data?.length ? (
                <div className="space-y-3">
                  {queueQuery.error ? (
                    <SectionErrorState
                      title="Unassigned messages could not be refreshed"
                      description="Showing the last loaded conversations. Retry to check for updates."
                      error={queueQuery.error}
                      onRetry={() => void queueQuery.refetch()}
                    />
                  ) : null}
                  {queueQuery.data.map((conversation) => (
                    <article
                      key={conversation.id}
                      className="border-border-subtle bg-surface tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center grid min-w-0 gap-4 rounded-2xl border p-4 sm:p-5"
                    >
                      <div className="flex min-w-0 items-start gap-3">
                        <span className="bg-warning-subtle text-warning-foreground flex size-10 shrink-0 items-center justify-center rounded-xl">
                          <MessageSquareText className="size-5" aria-hidden="true" />
                        </span>
                        <div className="min-w-0">
                          <div className="flex flex-wrap items-center gap-2">
                            <h2 className="text-label text-text-primary font-semibold">
                              {conversation.partner_name ||
                                conversation.partner_code ||
                                'Partner message'}
                            </h2>
                            <StatusChip label="Needs a contact" tone="warning" dense />
                          </div>
                          <p className="text-caption text-text-secondary mt-1">
                            {conversation.partner_code || `Partner #${conversation.partner_id}`} ·{' '}
                            {conversation.last_message_at
                              ? new Date(conversation.last_message_at).toLocaleString()
                              : 'New conversation'}
                          </p>
                        </div>
                      </div>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          void navigate({
                            to: '/company/partners/$partnerId',
                            params: { partnerId: String(conversation.partner_id) },
                            search: { tab: 'messages', conversation: conversation.id },
                          })
                        }
                        leadingIcon={<MessageSquareText className="size-4" />}
                      >
                        Review and claim
                      </Button>
                    </article>
                  ))}
                </div>
              ) : (
                <EmptyState
                  title="Queue is clear"
                  description="Unassigned partner conversations will appear here."
                  icon={<MessageSquareText className="size-6" />}
                  action={
                    <Button variant="outline" onClick={() => setView('partners')}>
                      Return to partner directory
                    </Button>
                  }
                />
              )
            ) : view === 'partners' ? (
              (listQuery.data?.items.length ?? 0) === 0 ? (
                <EmptyState
                  title={routeSearch.search ? 'No matching partners' : 'No partners yet'}
                  description={
                    routeSearch.search
                      ? 'Try another name, email, or partner code.'
                      : 'Send an invitation to bring your first partner into the network.'
                  }
                  icon={<UserRound className="size-6" />}
                  action={
                    canInvite && !routeSearch.search ? (
                      <Button
                        onClick={() => setInviteOpen(true)}
                        leadingIcon={<Plus className="size-4" />}
                      >
                        Invite partner
                      </Button>
                    ) : undefined
                  }
                />
              ) : (
                <div className="space-y-3">
                  {listQuery.data?.items.map((partner) => (
                    <article
                      key={partner.id}
                      className="border-border-subtle bg-surface hover:border-primary/25 desktop:grid-cols-[minmax(0,1fr)_auto] desktop:items-center grid min-w-0 gap-4 rounded-2xl border p-4 transition-[border-color,box-shadow] hover:shadow-sm sm:p-5"
                    >
                      <div className="flex min-w-0 items-start gap-3 sm:gap-4">
                        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-2xl sm:size-12">
                          <UserRound className="size-5" aria-hidden="true" />
                        </span>
                        <div className="min-w-0 flex-1">
                          <div className="flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1">
                            <h2 className="text-label text-text-primary min-w-0 leading-snug font-semibold break-words">
                              {partner.name || 'Name to be confirmed'}
                            </h2>
                            <StatusChip
                              label={partner.status_display || partner.status}
                              tone={partnerTone(partner.status)}
                              dense
                            />
                          </div>
                          <p className="text-body-sm text-text-secondary mt-1 break-all">
                            {partner.email}
                          </p>
                          <div className="text-caption text-text-secondary mt-3 flex flex-wrap gap-x-2 gap-y-1.5 sm:gap-x-3">
                            <span>
                              {roleLabels[partner.partner_role] ??
                                partner.partner_role_display ??
                                'Partner'}
                            </span>
                            <span aria-hidden="true" className="text-border-strong">
                              ·
                            </span>
                            <span>{partner.primary_branch_name || 'Branch not assigned'}</span>
                            {partner.phone ? (
                              <>
                                <span aria-hidden="true" className="text-border-strong">
                                  ·
                                </span>
                                <span>{partner.phone}</span>
                              </>
                            ) : null}
                          </div>
                        </div>
                      </div>
                      <div className="border-border-subtle desktop:justify-end desktop:border-t-0 desktop:pt-0 flex min-w-0 flex-wrap items-center justify-between gap-3 border-t pt-3">
                        <div className="flex min-w-0 flex-wrap items-center gap-2">
                          <StatusChip
                            label={partner.has_login ? 'Workspace active' : 'Setup pending'}
                            tone={partner.has_login ? 'success' : 'warning'}
                            dense
                          />
                          {partner.code ? (
                            <span className="text-caption text-text-muted min-w-0 break-all">
                              {partner.code}
                            </span>
                          ) : null}
                        </div>
                        <Button
                          variant="outline"
                          size="sm"
                          className="shrink-0"
                          onClick={() =>
                            void navigate({
                              to: '/company/partners/$partnerId',
                              params: { partnerId: String(partner.id) },
                              search: { tab: 'contacts' },
                            })
                          }
                        >
                          Open
                        </Button>
                      </div>
                    </article>
                  ))}
                </div>
              )
            ) : (invitationQuery.data?.items.length ?? 0) === 0 ? (
              <EmptyState
                title={routeSearch.search ? 'No matching invitations' : 'No invitations yet'}
                description={
                  routeSearch.search
                    ? 'Try another name or email address.'
                    : 'New partner invitations and setup progress will appear here.'
                }
                icon={<Mail className="size-6" />}
              />
            ) : (
              <div className="space-y-3">
                {invitationQuery.data?.items.map((invitation) => (
                  <article
                    key={invitation.id}
                    className="border-border-subtle bg-surface tablet:grid-cols-[minmax(0,1fr)_auto] tablet:items-center grid min-w-0 gap-4 rounded-2xl border p-4 sm:p-5"
                  >
                    <div className="flex min-w-0 gap-3">
                      <span className="flex size-11 shrink-0 items-center justify-center rounded-2xl bg-[#FCECEC] text-[#A9222A]">
                        <Mail className="size-5" aria-hidden="true" />
                      </span>
                      <div className="min-w-0">
                        <div className="flex min-w-0 flex-wrap items-center gap-2">
                          <h2 className="text-label text-text-primary min-w-0 font-semibold break-words">
                            {invitation.partner_name || invitation.email}
                          </h2>
                          <StatusChip
                            label={deliveryLabel(invitation)}
                            tone={deliveryTone(invitation)}
                            dense
                          />
                        </div>
                        <p className="text-body-sm text-text-secondary mt-1 break-all">
                          {invitation.email}
                        </p>
                        <div className="text-caption text-text-secondary mt-2 flex flex-wrap gap-x-4 gap-y-1">
                          <span>
                            {(invitation.partner_role && roleLabels[invitation.partner_role]) ||
                              'Partner'}
                          </span>
                          <span>
                            Expires {new Date(invitation.expires_at).toLocaleDateString()}
                          </span>
                          {invitation.last_sent_at ? (
                            <span>
                              Last sent {new Date(invitation.last_sent_at).toLocaleDateString()}
                            </span>
                          ) : null}
                        </div>
                        {invitation.delivery_status === 'failed' && invitation.delivery_error ? (
                          <p className="text-caption text-danger mt-2">
                            {invitation.delivery_error}
                          </p>
                        ) : null}
                      </div>
                    </div>
                    {canInvite &&
                    !invitation.setup_completed_at &&
                    invitation.status !== 'accepted' ? (
                      <div className="tablet:justify-end flex flex-wrap gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          isLoading={
                            resendMutation.isPending && resendMutation.variables === invitation.id
                          }
                          onClick={() => resendMutation.mutate(invitation.id)}
                          leadingIcon={<RefreshCw className="size-3.5" />}
                        >
                          Resend
                        </Button>
                        {invitation.status !== 'revoked' ? (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => setRevokeTarget(invitation)}
                          >
                            Revoke
                          </Button>
                        ) : null}
                      </div>
                    ) : invitation.setup_completed_at ? (
                      <span className="text-caption text-success-foreground inline-flex items-center gap-1.5 font-semibold">
                        <BadgeCheck className="size-4" /> Completed
                      </span>
                    ) : null}
                  </article>
                ))}
              </div>
            )}

            {canList && view !== 'queue' && pageError === null && pageCount > 1 ? (
              <nav
                aria-label="Partner records pages"
                className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-4"
              >
                <p className="text-caption text-text-secondary">
                  Page {routeSearch.page} of {pageCount} ·{' '}
                  {view === 'partners' ? listQuery.data?.count : invitationQuery.data?.count}{' '}
                  records
                </p>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={routeSearch.page <= 1}
                    onClick={() => setPage(routeSearch.page - 1)}
                    leadingIcon={<ChevronLeft className="size-4" />}
                  >
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={routeSearch.page >= pageCount}
                    onClick={() => setPage(routeSearch.page + 1)}
                  >
                    Next
                    <ChevronRight className="size-4" />
                  </Button>
                </div>
              </nav>
            ) : null}
          </Card>

          {canInvite && choicesQuery.error ? (
            <SectionErrorState
              title="Invitation options unavailable"
              description="Branch and role options could not be loaded."
              error={choicesQuery.error}
              onRetry={() => void choicesQuery.refetch()}
            />
          ) : null}
          {canInvite && choicesQuery.data && choicesQuery.data.branches.length === 0 ? (
            <Alert tone="warning" title="Branch access is required">
              There are no active branches available in your access scope. Ask an administrator to
              update your branch access before inviting a partner.
            </Alert>
          ) : null}
          {mutationError ? (
            <Alert tone="danger" role="alert">
              {mutationError}
            </Alert>
          ) : null}
          {resendMutation.error ? (
            <Alert tone="danger" role="alert">
              {presentError(resendMutation.error, 'background-action').message}
            </Alert>
          ) : null}
          {revokeMutation.error ? (
            <Alert tone="danger" role="alert">
              {presentError(revokeMutation.error, 'background-action').message}
            </Alert>
          ) : null}
        </div>
      </PageLayout>

      {inviteOpen ? (
        <InvitePartnerDialog
          open={inviteOpen}
          onOpenChange={(open) => {
            setInviteOpen(open)
            if (!open) setMutationError('')
          }}
          onInvite={(input) => inviteMutation.mutate(input)}
          sending={inviteMutation.isPending}
          error={mutationError}
          branches={choicesQuery.data?.branches ?? []}
          viewerId={sessionQuery.data?.user.id}
        />
      ) : null}
      <Dialog
        open={Boolean(revokeTarget)}
        onOpenChange={(open) => !open && setRevokeTarget(null)}
        title="Revoke this invitation?"
        description="The one-time setup link will stop working. You can send a fresh invitation later."
        size="sm"
        fitContent
        footer={
          <>
            <Button variant="outline" onClick={() => setRevokeTarget(null)}>
              Keep invitation
            </Button>
            <Button
              variant="danger"
              isLoading={revokeMutation.isPending}
              onClick={() => revokeTarget && revokeMutation.mutate(revokeTarget.id)}
              leadingIcon={<CircleAlert className="size-4" />}
            >
              Revoke link
            </Button>
          </>
        }
      >
        <div className="space-y-3">
          <p className="text-body-sm text-text-secondary break-all">{revokeTarget?.email}</p>
          {revokeMutation.error ? (
            <Alert tone="danger" role="alert">
              {presentError(revokeMutation.error, 'background-action').message}
            </Alert>
          ) : null}
        </div>
      </Dialog>
    </>
  )
}
