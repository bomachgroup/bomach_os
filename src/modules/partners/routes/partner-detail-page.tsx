import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowLeft,
  ChevronRight,
  Clock3,
  Mail,
  MessageSquareText,
  ShieldCheck,
  UserRound,
  UsersRound,
} from 'lucide-react'
import { useEffect, useMemo, useState, type FormEvent } from 'react'

import {
  PartnerMessageComposer,
  PartnerMessageTimeline,
} from '@/modules/partners/components/partner-message-ui'
import {
  partnerAdminApi,
  partnerQueryKeys,
  type PartnerContactDto,
  type PartnerConversationDto,
  type PartnerMessageDto,
} from '@/modules/partners/partner.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type { PartnerDetailSearch } from '../partner.search'

function displayDate(value: string | null | undefined) {
  if (!value) return 'No messages yet'
  const date = new Date(value)
  if (Number.isNaN(date.valueOf())) return 'No messages yet'
  return date.toLocaleString('en-NG', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

function conversationLabel(conversation: PartnerConversationDto) {
  if (conversation.kind === 'legacy') return 'Earlier shared history'
  if (conversation.kind === 'unassigned') return 'Unassigned support queue'
  return conversation.staff_name
}

function conversationAccess(
  conversation: PartnerConversationDto,
  viewerId: number,
): { label: string; tone: StatusTone } {
  const isOwnThread = conversation.kind === 'direct' && conversation.staff_user_id === viewerId
  if (conversation.kind === 'unassigned') {
    return conversation.can_claim
      ? { label: 'Queue · claim to reply', tone: 'warning' as const }
      : { label: 'Queue · view-only', tone: 'neutral' as const }
  }
  if (conversation.status === 'read_only') {
    return {
      label: isOwnThread ? 'Previous contact · read-only' : 'Oversight · read-only',
      tone: 'neutral' as const,
    }
  }
  if (isOwnThread) {
    return conversation.can_reply
      ? { label: 'Assigned to you', tone: 'success' as const }
      : { label: 'Assigned · replies unavailable', tone: 'warning' as const }
  }
  return { label: 'Oversight · view-only', tone: 'info' as const }
}

function conversationAccessDescription(conversation: PartnerConversationDto, viewerId: number) {
  const isOwnThread = conversation.kind === 'direct' && conversation.staff_user_id === viewerId
  if (conversation.kind === 'unassigned') {
    return conversation.can_claim
      ? 'Shared with authorized support handlers until someone claims it.'
      : 'Visible to authorized support handlers; you cannot claim or reply.'
  }
  if (conversation.status === 'read_only') {
    return isOwnThread
      ? 'Your contact assignment ended. This history is retained and cannot receive replies.'
      : 'Historical thread available to you through message oversight; replies are disabled.'
  }
  if (isOwnThread && conversation.can_reply) {
    return 'Private to you and the partner. Authorized oversight staff can review it.'
  }
  if (isOwnThread) {
    return 'This thread is assigned to you, but your current permissions do not allow replies.'
  }
  return 'Oversight view only. The assigned contact and partner can reply.'
}

function partnerStatusTone(status: string) {
  if (status === 'active') return 'success'
  if (status === 'pending') return 'warning'
  if (status === 'suspended' || status === 'inactive') return 'danger'
  return 'neutral'
}

function ContactEditor({
  open,
  contacts,
  eligibleStaff,
  busy,
  error,
  onOpenChange,
  onSave,
}: {
  open: boolean
  contacts: PartnerContactDto[]
  eligibleStaff: Array<{
    employee_id: number
    staff_user_id: number
    name: string
    email: string
    designation: string
  }>
  busy: boolean
  error: unknown
  onOpenChange: (open: boolean) => void
  onSave: (employeeIds: number[], primaryId: number | null) => void
}) {
  const initialEmployeeIds = contacts.map((contact) => contact.employee_id)
  const [employeeIds, setEmployeeIds] = useState<number[]>(initialEmployeeIds)
  const [primaryId, setPrimaryId] = useState<number | null>(
    contacts.find((contact) => contact.is_primary)?.employee_id ?? initialEmployeeIds[0] ?? null,
  )

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    onSave(employeeIds, employeeIds.length ? primaryId : null)
  }

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title="Manage partner contacts"
      description="Contacts receive private partner messages. Removed contacts keep read-only access to their existing thread."
      size="lg"
      fitContent
      bodyClassName="bg-background"
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={busy}>
            Cancel
          </Button>
          <Button type="submit" form="partner-contact-form" isLoading={busy}>
            Save contacts
          </Button>
        </>
      }
    >
      <form id="partner-contact-form" className="space-y-4" onSubmit={submit}>
        {eligibleStaff.length ? (
          <div className="space-y-2">
            {eligibleStaff.map((staff) => {
              const checked = employeeIds.includes(staff.employee_id)
              return (
                <div
                  key={staff.employee_id}
                  className="border-border-subtle bg-surface rounded-control flex min-w-0 flex-wrap items-center gap-3 border p-3"
                >
                  <label className="flex min-w-0 flex-1 items-center gap-3">
                    <input
                      type="checkbox"
                      checked={checked}
                      className="accent-primary size-4 shrink-0"
                      aria-label={`Assign ${staff.name} as a partner contact`}
                      onChange={(event) => {
                        const next = event.currentTarget.checked
                          ? [...employeeIds, staff.employee_id]
                          : employeeIds.filter((id) => id !== staff.employee_id)
                        setEmployeeIds(next)
                        if (!next.includes(primaryId ?? -1)) setPrimaryId(next[0] ?? null)
                      }}
                    />
                    <span className="min-w-0">
                      <span className="text-body-sm text-text-primary block font-semibold break-words">
                        {staff.name}
                      </span>
                      <span className="text-caption text-text-secondary block break-all">
                        {staff.designation || staff.email}
                      </span>
                    </span>
                  </label>
                  {checked ? (
                    <label className="text-caption text-text-secondary phone:ml-0 ml-7 inline-flex items-center gap-2">
                      <input
                        type="radio"
                        name="primary-partner-contact-edit"
                        checked={primaryId === staff.employee_id}
                        className="accent-primary size-4"
                        aria-label={`Set ${staff.name} as primary contact`}
                        onChange={() => setPrimaryId(staff.employee_id)}
                      />
                      Primary
                    </label>
                  ) : null}
                </div>
              )
            })}
          </div>
        ) : (
          <Alert tone="warning">
            No active staff with partner messaging access are available in this partner’s branch.
            Assign the inviter as fallback or update a staff role before adding a contact.
          </Alert>
        )}
        {!employeeIds.length ? (
          <Alert tone="info">
            No contacts selected. The original inviter will receive new messages when eligible;
            otherwise the partner is routed to the authorized support queue.
          </Alert>
        ) : null}
        {error ? (
          <Alert tone="danger" role="alert">
            {presentError(error, 'form-submit').message}
          </Alert>
        ) : null}
      </form>
    </Dialog>
  )
}

export function PartnerDetailPage() {
  const { partnerId: partnerIdValue } = useParams({
    from: '/_protected/company/partners/$partnerId',
  })
  const partnerId = Number(partnerIdValue)
  const routeSearch = useSearch({
    from: '/_protected/company/partners/$partnerId',
  }) as PartnerDetailSearch
  const navigate = useNavigate({ from: '/company/partners/$partnerId' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const permissions = sessionQuery.data?.permissions ?? {}
  const canViewPartner = hasPermission(permissions, 'partners', 'view')
  const canListMessages = hasPermission(permissions, 'partner_messages', 'list')
  const canEditContacts = canViewPartner && hasPermission(permissions, 'partners', 'update')
  const canCreateMessages = hasPermission(permissions, 'partner_messages', 'create')
  const canMarkMessagesRead = hasPermission(permissions, 'partner_messages', 'mark_read')
  const canViewAllMessages = hasPermission(permissions, 'partner_messages', 'view_all')
  const [contactEditorOpen, setContactEditorOpen] = useState(false)

  const partnerQuery = useQuery({
    queryKey: [...partnerQueryKeys.all, 'partner', partnerId],
    queryFn: ({ signal }) => partnerAdminApi.partner(partnerId, signal),
    enabled: canViewPartner,
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const contactsQuery = useQuery({
    queryKey: [...partnerQueryKeys.all, 'contacts', partnerId],
    queryFn: ({ signal }) => partnerAdminApi.contacts(partnerId, signal),
    enabled: canViewPartner,
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const conversationsQuery = useQuery({
    queryKey: [...partnerQueryKeys.all, 'conversations', partnerId],
    queryFn: ({ signal }) => partnerAdminApi.conversations(partnerId, signal),
    enabled: canListMessages,
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const conversations = (conversationsQuery.data ?? []).filter(
    (conversation) => conversation.kind !== 'legacy',
  )
  const selectedConversation = conversations.find(
    (conversation) => conversation.id === routeSearch.conversation,
  )
  const messagesQuery = useQuery({
    queryKey: partnerQueryKeys.conversationMessages(selectedConversation?.id ?? null),
    queryFn: ({ signal }) =>
      partnerAdminApi.staffConversationMessages(partnerId, selectedConversation!.id, signal),
    enabled: Boolean(selectedConversation),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  useEffect(() => {
    if (!routeSearch.conversation || !conversationsQuery.data) return
    const requestedConversation = conversationsQuery.data.find(
      (conversation) => conversation.id === routeSearch.conversation,
    )
    if (requestedConversation?.kind !== 'legacy') return
    void navigate({
      search: (previous: PartnerDetailSearch) => ({ ...previous, conversation: undefined }),
      replace: true,
    })
  }, [conversationsQuery.data, navigate, routeSearch.conversation])

  const invalidatePartnerMessages = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: [...partnerQueryKeys.all, 'contacts', partnerId] }),
      queryClient.invalidateQueries({
        queryKey: [...partnerQueryKeys.all, 'conversations', partnerId],
      }),
      queryClient.invalidateQueries({
        queryKey: partnerQueryKeys.conversationMessages(selectedConversation?.id ?? null),
      }),
    ])
  }
  const contactMutation = useMutation({
    mutationFn: (input: { employee_ids: number[]; primary_employee_id: number | null }) =>
      partnerAdminApi.updateContacts(partnerId, input),
    onSuccess: async () => {
      await invalidatePartnerMessages()
      setContactEditorOpen(false)
      showToast({ title: 'Partner contacts updated', tone: 'success' })
    },
  })
  const startConversationMutation = useMutation({
    mutationFn: () => partnerAdminApi.startStaffConversation(partnerId),
    onSuccess: async (conversation) => {
      await invalidatePartnerMessages()
      void navigate({
        search: (previous: PartnerDetailSearch) => ({
          ...previous,
          tab: 'messages',
          conversation: conversation.id,
        }),
      })
    },
  })
  const claimMutation = useMutation({
    mutationFn: (conversationId: number) =>
      partnerAdminApi.claimConversation(partnerId, conversationId),
    onSuccess: async (conversation) => {
      await invalidatePartnerMessages()
      await queryClient.invalidateQueries({
        queryKey: partnerQueryKeys.unassignedConversations(sessionQuery.data?.user.id ?? 0),
      })
      void navigate({
        search: (previous: PartnerDetailSearch) => ({
          ...previous,
          tab: 'messages',
          conversation: conversation.id,
        }),
      })
      showToast({ title: 'Conversation assigned to you', tone: 'success' })
    },
  })
  const replyMutation = useMutation({
    mutationFn: (input: { conversationId: number; body: string; files: File[] }) =>
      partnerAdminApi.sendStaffConversationMessage(partnerId, input.conversationId, {
        body: input.body,
        files: input.files,
      }),
    onSuccess: async (message, input) => {
      const queryKey = partnerQueryKeys.conversationMessages(input.conversationId)
      queryClient.setQueryData<PartnerMessageDto[]>(queryKey, (messages = []) =>
        messages.some((item) => item.id === message.id)
          ? messages
          : [...messages, { ...message, conversation_id: input.conversationId }],
      )
      await invalidatePartnerMessages()
    },
  })
  const markReadMutation = useMutation({
    mutationFn: (conversationId: number) =>
      partnerAdminApi.markStaffConversationRead(partnerId, conversationId),
    onSuccess: () => void invalidatePartnerMessages(),
  })

  useEffect(() => {
    if (!selectedConversation || messagesQuery.isPending || !messagesQuery.data?.length) return
    if (
      !canMarkMessagesRead ||
      selectedConversation.kind !== 'direct' ||
      selectedConversation.staff_user_id !== sessionQuery.data?.user.id
    ) {
      return
    }
    if (
      messagesQuery.data.some((message) => message.is_from_partner && !message.is_read) &&
      markReadMutation.variables !== selectedConversation.id
    ) {
      markReadMutation.mutate(selectedConversation.id)
    }
  }, [
    canMarkMessagesRead,
    markReadMutation,
    messagesQuery.data,
    messagesQuery.isPending,
    selectedConversation,
    sessionQuery.data?.user.id,
  ])

  const effectiveContacts = contactsQuery.data?.effective_contacts ?? []
  const currentContact = useMemo(
    () => contactsQuery.data?.effective_contacts.find((contact) => contact.is_primary),
    [contactsQuery.data?.effective_contacts],
  )
  const canStartOwnConversation =
    canCreateMessages &&
    effectiveContacts.some((contact) => contact.staff_user_id === sessionQuery.data?.user.id)
  const ownConversation = conversations.find(
    (conversation) =>
      conversation.kind === 'direct' && conversation.staff_user_id === sessionQuery.data?.user.id,
  )

  function selectConversation(conversation: PartnerConversationDto) {
    void navigate({
      search: (previous: PartnerDetailSearch) => ({
        ...previous,
        tab: 'messages',
        conversation: conversation.id,
      }),
    })
  }

  if (canViewPartner && partnerQuery.isPending) {
    return (
      <PageLayout title="Partner">
        <div className="space-y-4">
          <Skeleton className="h-28" />
          <Skeleton className="h-72" />
        </div>
      </PageLayout>
    )
  }
  if (canViewPartner && (partnerQuery.error || !partnerQuery.data)) {
    return (
      <PageLayout
        title="Partner"
        backLink={
          <Button
            variant="outline"
            onClick={() =>
              void navigate({ to: '/company/partners', search: { search: '', page: 1 } })
            }
          >
            Back to partners
          </Button>
        }
      >
        <ErrorState
          title="Partner record unavailable"
          description="The partner record could not be loaded. Your access scope is preserved."
          error={partnerQuery.error}
          action={
            <Button variant="outline" onClick={() => void partnerQuery.refetch()}>
              Try again
            </Button>
          }
        />
      </PageLayout>
    )
  }

  const partner = canViewPartner ? partnerQuery.data : undefined
  const activeTab = canViewPartner ? routeSearch.tab : 'messages'
  const currentContacts = contactsQuery.data?.contacts ?? []
  const noConversations = conversations.length === 0
  const canBrowsePartners =
    hasPermission(permissions, 'partners', 'list') ||
    hasPermission(permissions, 'partners', 'invite')

  return (
    <>
      <PageLayout
        title={partner?.name || selectedConversation?.partner_name || 'Partner conversation'}
        backLink={
          <button
            type="button"
            onClick={() =>
              void (canBrowsePartners
                ? navigate({ to: '/company/partners', search: { search: '', page: 1 } })
                : navigate({ to: '/notifications', search: { filter: 'all' } }))
            }
            aria-label={canBrowsePartners ? 'Back to partners' : 'Back to notifications'}
            className="border-border-subtle bg-surface hover:bg-surface-muted rounded-control flex size-10 items-center justify-center border"
          >
            <ArrowLeft className="size-4" aria-hidden="true" />
          </button>
        }
        actionsInline
        actions={
          canEditContacts ? (
            <Button
              variant="outline"
              className="max-[479px]:size-10 max-[479px]:px-0"
              aria-label="Manage partner contacts"
              disabled={!contactsQuery.data}
              isLoading={contactsQuery.isPending}
              leadingIcon={<UsersRound className="size-4" aria-hidden="true" />}
              onClick={() => setContactEditorOpen(true)}
            >
              <span className="max-[479px]:hidden">Manage contacts</span>
            </Button>
          ) : undefined
        }
      >
        <div className="space-y-5">
          {partner ? (
            <Card className="flex min-w-0 flex-wrap items-center justify-between gap-4 p-4 sm:p-5">
              <div className="flex min-w-0 items-center gap-3">
                <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-2xl">
                  <UserRound className="size-5" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <p className="text-body-sm text-text-primary font-semibold">{partner.email}</p>
                    <StatusChip
                      label={partner.status_display || partner.status}
                      tone={partnerStatusTone(partner.status)}
                      dense
                    />
                  </div>
                  <p className="text-caption text-text-secondary mt-1">
                    {partner.code || 'Partner'} ·{' '}
                    {partner.partner_role_display || partner.partner_role}
                    {' · '}
                    {partner.primary_branch_name || 'No branch'}
                  </p>
                </div>
              </div>
              <div className="text-caption text-text-secondary flex items-center gap-2">
                <ShieldCheck className="text-primary size-4" aria-hidden="true" />
                {currentContact?.source === 'inviter'
                  ? `Original inviter: ${currentContact.name}`
                  : currentContact
                    ? `Primary contact: ${currentContact.name}`
                    : conversations.some((item) => item.kind === 'unassigned')
                      ? 'Authorized support queue'
                      : 'No eligible contact'}
              </div>
            </Card>
          ) : (
            <Card className="flex min-w-0 flex-wrap items-center gap-3 p-4 sm:p-5">
              <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-2xl">
                <MessageSquareText className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-body-sm text-text-primary font-semibold">
                  {selectedConversation?.partner_name || 'Partner conversation'}
                </p>
                <p className="text-caption text-text-secondary mt-1">
                  {selectedConversation?.partner_code || 'Private messages only'}
                </p>
              </div>
            </Card>
          )}

          {canViewPartner ? (
            <div
              className="bg-surface-muted flex w-fit max-w-full gap-1 overflow-x-auto rounded-xl p-1"
              role="tablist"
              aria-label="Partner details"
            >
              {(['contacts', 'messages'] as const).map((tab) => (
                <button
                  key={tab}
                  type="button"
                  role="tab"
                  aria-selected={activeTab === tab}
                  onClick={() =>
                    void navigate({
                      search: (previous: PartnerDetailSearch) => ({ ...previous, tab }),
                    })
                  }
                  className={`min-h-10 shrink-0 rounded-lg px-4 text-sm font-semibold ${activeTab === tab ? 'bg-surface text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
                >
                  {tab === 'contacts' ? 'Contacts' : 'Messages'}
                </button>
              ))}
            </div>
          ) : null}

          {activeTab === 'contacts' ? (
            <Card className="space-y-4 p-4 sm:p-5">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <h2 className="text-h2 text-text-primary font-semibold">Partner contacts</h2>
                  <p className="text-caption text-text-secondary mt-1">
                    Each contact has a separate, private message thread with this partner.
                  </p>
                </div>
                {canEditContacts ? (
                  <Button
                    variant="outline"
                    disabled={!contactsQuery.data}
                    isLoading={contactsQuery.isPending}
                    onClick={() => setContactEditorOpen(true)}
                    leadingIcon={<UsersRound className="size-4" />}
                  >
                    Edit contacts
                  </Button>
                ) : null}
              </div>
              {contactsQuery.isPending ? (
                <div className="space-y-3">
                  <Skeleton className="h-24" />
                  <Skeleton className="h-24" />
                </div>
              ) : contactsQuery.error ? (
                <SectionErrorState
                  error={contactsQuery.error}
                  onRetry={() => void contactsQuery.refetch()}
                />
              ) : currentContacts.length ? (
                <div className="space-y-3">
                  {currentContacts.map((contact) => {
                    const thread = conversations.find(
                      (item) =>
                        item.staff_user_id === contact.staff_user_id && item.kind === 'direct',
                    )
                    const isCurrentContact = sessionQuery.data?.user.id === contact.staff_user_id
                    return (
                      <article
                        key={contact.employee_id}
                        className="border-border-subtle bg-background rounded-control phone:grid-cols-[minmax(0,1fr)_auto] phone:items-center grid min-w-0 gap-4 border p-4"
                      >
                        <div className="flex min-w-0 items-start gap-3">
                          <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-xl">
                            <UserRound className="size-5" />
                          </span>
                          <div className="min-w-0">
                            <div className="flex flex-wrap items-center gap-2">
                              <h3 className="text-body-sm text-text-primary font-semibold">
                                {contact.name}
                              </h3>
                              {contact.is_primary ? (
                                <StatusChip label="Primary" tone="info" dense />
                              ) : null}
                            </div>
                            <p className="text-caption text-text-secondary mt-1 break-all">
                              {contact.email}
                            </p>
                            <p className="text-caption text-text-muted mt-1">
                              {contact.designation || 'Bomach staff'}
                            </p>
                          </div>
                        </div>
                        {!thread && (!canCreateMessages || !isCurrentContact) ? (
                          <p className="text-caption text-text-secondary">
                            The assigned staff member starts this private thread.
                          </p>
                        ) : (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => {
                              if (thread) selectConversation(thread)
                              else startConversationMutation.mutate()
                            }}
                            isLoading={startConversationMutation.isPending}
                            leadingIcon={<MessageSquareText className="size-4" />}
                          >
                            {thread ? 'Open thread' : 'Start your thread'}
                          </Button>
                        )}
                      </article>
                    )
                  })}
                </div>
              ) : effectiveContacts.length ? (
                <Alert tone="info">
                  {effectiveContacts[0].name} is the original inviter and will receive new messages
                  until you assign partner contacts.
                </Alert>
              ) : (
                <Alert tone="warning">
                  No contact is currently eligible for this branch. New partner messages use the
                  authorized support queue when a handler is available.
                </Alert>
              )}
              {(contactsQuery.data?.history.length ?? 0) ? (
                <div className="border-border-subtle border-t pt-4">
                  <h3 className="text-label text-text-primary font-semibold">Previous contacts</h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Removed staff retain read-only access to their existing conversations.
                  </p>
                  <ul className="mt-3 space-y-2">
                    {contactsQuery.data?.history.map((contact) => (
                      <li
                        key={`${contact.employee_id}-${contact.removed_at}`}
                        className="text-body-sm text-text-secondary flex flex-wrap justify-between gap-2"
                      >
                        <span>
                          {contact.name} · {contact.email}
                        </span>
                        <span>Removed {displayDate(contact.removed_at)}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              ) : null}
              {startConversationMutation.error ? (
                <Alert tone="danger" role="alert">
                  {presentError(startConversationMutation.error, 'background-action').message}
                </Alert>
              ) : null}
            </Card>
          ) : !canListMessages ? (
            <Alert tone="warning">
              Your account can view this partner record but does not have permission to view message
              threads.
            </Alert>
          ) : (
            <div className="desktop:grid-cols-[minmax(15rem,0.7fr)_minmax(0,1.5fr)] grid min-w-0 gap-4">
              <Card className="min-w-0 overflow-hidden p-0">
                <div className="border-border-subtle border-b p-4">
                  <h2 className="text-label text-text-primary font-semibold">Message threads</h2>
                  <p className="text-caption text-text-secondary mt-1">
                    {canViewAllMessages
                      ? 'Review staff conversations for this partner.'
                      : canStartOwnConversation
                        ? 'Your assigned private conversation with this partner.'
                        : 'Private conversations are limited to assigned contacts.'}
                  </p>
                  {canViewAllMessages ? (
                    <div
                      className="border-info/20 bg-info-subtle/60 mt-3 flex min-w-0 items-start gap-2 rounded-xl border p-3"
                      role="note"
                      aria-label="Message oversight access"
                    >
                      <ShieldCheck
                        className="text-info-foreground mt-0.5 size-4 shrink-0"
                        aria-hidden="true"
                      />
                      <p className="text-caption text-info-foreground min-w-0">
                        <span className="font-semibold">Message oversight.</span> You can review all
                        staff threads for this partner. Replies are limited to conversations
                        assigned to you.
                      </p>
                    </div>
                  ) : null}
                  {canStartOwnConversation && !ownConversation && conversations.length > 0 ? (
                    <div className="mt-3">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => startConversationMutation.mutate()}
                        isLoading={startConversationMutation.isPending}
                        leadingIcon={<MessageSquareText className="size-4" />}
                      >
                        Start your private thread
                      </Button>
                    </div>
                  ) : null}
                  {startConversationMutation.error ? (
                    <Alert className="mt-3" tone="danger" role="alert">
                      {presentError(startConversationMutation.error, 'background-action').message}
                    </Alert>
                  ) : null}
                </div>
                <div className="max-h-[65dvh] space-y-1 overflow-y-auto p-2">
                  {conversationsQuery.isPending ? (
                    <div className="space-y-2 p-2">
                      <Skeleton className="h-14" />
                      <Skeleton className="h-14" />
                    </div>
                  ) : null}
                  {conversationsQuery.error ? (
                    <SectionErrorState
                      error={conversationsQuery.error}
                      onRetry={() => void conversationsQuery.refetch()}
                    />
                  ) : null}
                  {!conversationsQuery.isPending && !conversationsQuery.error && noConversations ? (
                    <EmptyState
                      title="No message threads yet"
                      description={
                        canStartOwnConversation
                          ? 'Start your assigned private thread to message this partner.'
                          : canEditContacts
                            ? 'Assign eligible message contacts. Each contact gets a separate private thread.'
                            : canViewAllMessages
                              ? 'There are no threads to review yet. Oversight access does not assign or start a contact thread.'
                              : 'Ask a partner administrator to assign you as a message contact before starting a thread.'
                      }
                      icon={<MessageSquareText className="size-5" />}
                      action={
                        canStartOwnConversation ? (
                          <Button
                            onClick={() => startConversationMutation.mutate()}
                            isLoading={startConversationMutation.isPending}
                            leadingIcon={<MessageSquareText className="size-4" />}
                          >
                            Start your private thread
                          </Button>
                        ) : !canStartOwnConversation && canEditContacts ? (
                          <Button
                            variant="outline"
                            onClick={() => setContactEditorOpen(true)}
                            disabled={!contactsQuery.data}
                            isLoading={contactsQuery.isPending}
                            leadingIcon={<UsersRound className="size-4" />}
                          >
                            Manage contacts
                          </Button>
                        ) : undefined
                      }
                    />
                  ) : null}
                  {conversations.map((conversation) => (
                    <button
                      key={conversation.id}
                      type="button"
                      aria-pressed={routeSearch.conversation === conversation.id}
                      onClick={() => selectConversation(conversation)}
                      className={`focus-visible:shadow-focus-ring flex min-h-14 w-full min-w-0 items-center gap-3 rounded-xl px-3 py-2 text-left ${routeSearch.conversation === conversation.id ? 'bg-primary-subtle text-primary' : 'text-text-secondary hover:bg-surface-muted'}`}
                    >
                      <span className="bg-surface flex size-9 shrink-0 items-center justify-center rounded-lg">
                        <MessageSquareText className="size-4" />
                      </span>
                      <span className="min-w-0 flex-1">
                        <span className="flex min-w-0 flex-wrap items-center gap-2">
                          <span className="text-body-sm text-text-primary min-w-0 truncate font-semibold">
                            {conversationLabel(conversation)}
                          </span>
                          <StatusChip
                            {...conversationAccess(conversation, sessionQuery.data?.user.id ?? -1)}
                            dense
                          />
                        </span>
                        <span className="text-caption text-text-muted mt-1 block truncate">
                          {conversation.kind === 'unassigned'
                            ? conversation.can_claim
                              ? 'Waiting for an authorized staff contact to claim'
                              : 'Support queue · view permission only'
                            : conversation.status === 'read_only'
                              ? 'History retained · replies disabled'
                              : `Last activity · ${displayDate(conversation.last_message_at)}`}
                        </span>
                      </span>
                      <ChevronRight
                        className="text-text-muted size-4 shrink-0"
                        aria-hidden="true"
                      />
                    </button>
                  ))}
                </div>
              </Card>

              <Card className="flex min-h-[28rem] min-w-0 flex-col overflow-hidden p-0">
                {selectedConversation ? (
                  <>
                    <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b p-4 sm:p-5">
                      <div className="min-w-0">
                        <h2 className="text-label text-text-primary font-semibold break-words">
                          {conversationLabel(selectedConversation)}
                        </h2>
                        <p className="text-caption text-text-secondary mt-1">
                          {conversationAccessDescription(
                            selectedConversation,
                            sessionQuery.data?.user.id ?? -1,
                          )}
                        </p>
                      </div>
                      {selectedConversation.can_claim ? (
                        <Button
                          size="sm"
                          onClick={() => claimMutation.mutate(selectedConversation.id)}
                          isLoading={claimMutation.isPending}
                        >
                          Claim conversation
                        </Button>
                      ) : (
                        <StatusChip
                          {...conversationAccess(
                            selectedConversation,
                            sessionQuery.data?.user.id ?? -1,
                          )}
                          dense
                        />
                      )}
                    </div>
                    {claimMutation.error ? (
                      <Alert className="m-4" tone="danger" role="alert">
                        {presentError(claimMutation.error, 'background-action').message}
                      </Alert>
                    ) : null}
                    <div className="bg-background min-h-0 flex-1 space-y-3 overflow-y-auto p-4 sm:p-5">
                      {messagesQuery.isPending ? (
                        <div className="space-y-3">
                          <Skeleton className="h-20" />
                          <Skeleton className="h-20" />
                        </div>
                      ) : null}
                      {messagesQuery.error ? (
                        <SectionErrorState
                          error={messagesQuery.error}
                          onRetry={() => void messagesQuery.refetch()}
                        />
                      ) : null}
                      {messagesQuery.data?.length ? (
                        <PartnerMessageTimeline
                          messages={messagesQuery.data}
                          isOwnMessage={(message) => !message.is_from_partner}
                          counterpartName={
                            partner?.name || selectedConversation.partner_name || 'Partner'
                          }
                          formatDate={displayDate}
                        />
                      ) : null}
                      {!messagesQuery.isPending &&
                      !messagesQuery.error &&
                      !messagesQuery.data?.length ? (
                        <EmptyState
                          title="No messages in this thread"
                          description="Messages from this partner contact will appear here."
                          icon={<Mail className="size-5" />}
                        />
                      ) : null}
                    </div>
                    {selectedConversation.can_reply ? (
                      <PartnerMessageComposer
                        key={selectedConversation.id}
                        sending={replyMutation.isPending}
                        error={
                          replyMutation.error
                            ? presentError(replyMutation.error, 'form-submit').message
                            : undefined
                        }
                        onSend={async (messageBody, files) => {
                          await replyMutation.mutateAsync({
                            conversationId: selectedConversation.id,
                            body: messageBody,
                            files,
                          })
                        }}
                        placeholder="Message this partner…"
                      />
                    ) : null}
                  </>
                ) : (
                  <EmptyState
                    title="Choose a conversation"
                    description={
                      conversations.length
                        ? 'Select a private staff thread to review its messages.'
                        : canStartOwnConversation
                          ? 'Start your private conversation with this partner.'
                          : canEditContacts
                            ? 'Assign staff contacts to open private conversations with this partner.'
                            : 'Only an assigned staff contact can start a private conversation.'
                    }
                    icon={<Clock3 className="size-6" />}
                  />
                )}
              </Card>
            </div>
          )}
        </div>
      </PageLayout>

      {contactEditorOpen ? (
        <ContactEditor
          open
          contacts={currentContacts}
          eligibleStaff={contactsQuery.data?.eligible_staff ?? []}
          busy={contactMutation.isPending}
          error={contactMutation.error}
          onOpenChange={setContactEditorOpen}
          onSave={(employeeIds, primaryId) =>
            contactMutation.mutate({ employee_ids: employeeIds, primary_employee_id: primaryId })
          }
        />
      ) : null}
    </>
  )
}
