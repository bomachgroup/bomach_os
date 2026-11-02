import { useEffect, useMemo, useState, type FormEvent } from 'react'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  ChevronLeft,
  ChevronRight,
  Clock3,
  FilterX,
  ListFilter,
  Search,
  ShieldCheck,
  UserRound,
} from 'lucide-react'

import { auditLogApi, auditLogQueryKeys, type AuditLogDto } from '@/modules/company/audit-log.api'
import {
  AUDIT_LOG_STATUSES,
  AUDIT_LOG_TYPES,
  auditLogDateRangeError,
  type AuditLogSearch,
} from '@/modules/company/audit-log.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

const PAGE_SIZE = 10

const typeLabels: Record<(typeof AUDIT_LOG_TYPES)[number], string> = {
  login: 'Login',
  login_failed: 'Login failed',
  logout: 'Logout',
  forgot_password: 'Forgot password',
  reset_password: 'Reset password',
  two_factor_sent: '2FA code sent',
  two_factor_verified: '2FA verified',
  two_factor_failed: '2FA failed',
  webauthn_registered: 'Device registered',
  webauthn_approved: 'Device approved',
  webauthn_rejected: 'Device rejected',
  webauthn_verified: 'Device verified',
  webauthn_failed: 'Device verification failed',
  add_employee: 'Add employee',
  update_employee: 'Update employee',
  update_profile: 'Update profile',
  add_client: 'Add client',
  add_lead: 'Add lead',
  finance_action: 'Finance action',
  non_working_day_change: 'Non-working day change',
  leave_request_change: 'Leave request change',
}

const statusLabels: Record<(typeof AUDIT_LOG_STATUSES)[number], string> = {
  success: 'Success',
  info: 'Info',
  warning: 'Warning',
  error: 'Error',
}

const typeOptions: DropdownSelectOption[] = [
  { value: '', label: 'All audit types' },
  ...AUDIT_LOG_TYPES.map((value) => ({ value, label: typeLabels[value] })),
]

const statusOptions: DropdownSelectOption[] = [
  { value: '', label: 'All statuses' },
  ...AUDIT_LOG_STATUSES.map((value) => ({ value, label: statusLabels[value] })),
]

function typeTone(type: string): StatusTone {
  if (type === 'login' || type === 'two_factor_verified' || type === 'webauthn_verified')
    return 'primary'
  if (type.startsWith('add_')) return 'success'
  if (type.startsWith('update_') || type === 'non_working_day_change') return 'warning'
  if (type.endsWith('_failed') || type === 'webauthn_rejected') return 'danger'
  return 'neutral'
}

function statusTone(status: string): StatusTone {
  if (status === 'success') return 'success'
  if (status === 'error') return 'danger'
  if (status === 'warning') return 'warning'
  return 'neutral'
}

function formatDate(value: string) {
  const date = new Date(value)
  if (!Number.isFinite(date.getTime())) return value || 'Date unavailable'
  return new Intl.DateTimeFormat(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(date)
}

function actorName(log: AuditLogDto) {
  return log.user?.full_name?.trim() || log.user?.email || 'System or unknown user'
}

function actorEmail(log: AuditLogDto) {
  const email = log.user?.email?.trim()
  return email && email !== actorName(log) ? email : null
}

function AuditTypeChip({ log }: { log: AuditLogDto }) {
  return (
    <StatusChip
      label={
        log.audit_type_display ||
        typeLabels[log.audit_type as keyof typeof typeLabels] ||
        log.audit_type
      }
      tone={typeTone(log.audit_type)}
      dense
    />
  )
}

function AuditStatusChip({ log }: { log: AuditLogDto }) {
  return (
    <StatusChip
      label={
        log.audit_status_display ||
        statusLabels[log.audit_status as keyof typeof statusLabels] ||
        log.audit_status
      }
      tone={statusTone(log.audit_status)}
      dense
    />
  )
}

function AuditLogMobileCard({ log }: { log: AuditLogDto }) {
  return (
    <article className="group hover:bg-surface-muted/50 tablet:px-5 min-w-0 px-4 py-4 transition-colors">
      <div className="grid min-w-0 grid-cols-[2.25rem_minmax(0,1fr)] gap-x-3">
        <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
          <ShieldCheck className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0">
          <div className="flex min-w-0 flex-wrap items-center justify-between gap-x-3 gap-y-1.5">
            <div className="flex min-w-0 flex-wrap items-center gap-1.5">
              <AuditTypeChip log={log} />
              <AuditStatusChip log={log} />
            </div>
            <time
              dateTime={log.created_at}
              className="text-caption text-text-secondary inline-flex items-center gap-1.5"
            >
              <Clock3 className="size-3.5 shrink-0" aria-hidden="true" />
              {formatDate(log.created_at)}
            </time>
          </div>

          <h3 className="text-label text-text-primary mt-2 leading-relaxed font-semibold break-words">
            {log.activity || 'Activity description unavailable'}
          </h3>

          <div className="text-caption text-text-secondary mt-2.5 flex flex-wrap items-center gap-x-3 gap-y-1.5">
            <span className="inline-flex min-w-0 items-center gap-1.5">
              <UserRound className="size-3.5 shrink-0" aria-hidden="true" />
              <span className="break-words">{actorName(log)}</span>
            </span>
            <span className="inline-flex min-w-0 items-center gap-1.5">
              <span className="text-text-secondary">IP</span>
              <span className="max-w-full font-mono break-all">{log.ip_address || '—'}</span>
            </span>
          </div>
        </div>
      </div>
    </article>
  )
}

function AuditLogTable({ items }: { items: AuditLogDto[] }) {
  return (
    <div className="hidden overflow-x-auto min-[1200px]:block">
      <table className="text-body-sm w-full min-w-[760px] border-collapse text-left">
        <thead className="bg-surface-muted text-caption text-text-secondary">
          <tr>
            <th scope="col" className="px-4 py-3 font-semibold">
              User
            </th>
            <th scope="col" className="px-4 py-3 font-semibold">
              Activity
            </th>
            <th scope="col" className="px-4 py-3 font-semibold">
              Type
            </th>
            <th scope="col" className="px-4 py-3 font-semibold">
              Status
            </th>
            <th scope="col" className="px-4 py-3 font-semibold">
              IP address
            </th>
            <th scope="col" className="px-4 py-3 font-semibold">
              Date &amp; time
            </th>
          </tr>
        </thead>
        <tbody className="divide-border-subtle divide-y">
          {items.map((log) => (
            <tr key={log.id} className="hover:bg-surface-muted/50 align-top transition-colors">
              <td className="max-w-52 px-4 py-4">
                <p className="text-text-primary font-semibold break-words">{actorName(log)}</p>
                {actorEmail(log) ? (
                  <p className="text-caption text-text-secondary mt-0.5 break-all">
                    {actorEmail(log)}
                  </p>
                ) : null}
              </td>
              <td className="text-text-primary max-w-80 px-4 py-4 break-words">
                {log.activity || 'Activity description unavailable'}
              </td>
              <td className="px-4 py-4">
                <AuditTypeChip log={log} />
              </td>
              <td className="px-4 py-4">
                <AuditStatusChip log={log} />
              </td>
              <td className="text-caption text-text-secondary px-4 py-4 font-mono whitespace-nowrap">
                {log.ip_address || '—'}
              </td>
              <td className="text-caption text-text-secondary px-4 py-4 whitespace-nowrap">
                <time dateTime={log.created_at}>{formatDate(log.created_at)}</time>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export function AuditLogPage() {
  const search = useSearch({ from: '/_protected/company/audit-log' }) as AuditLogSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canRead = hasPermission(permissions, 'audit_logs', 'list')
  const routeDraft = useMemo<AuditLogSearch>(
    () => ({
      search: search.search,
      userId: search.userId,
      auditType: search.auditType,
      auditStatus: search.auditStatus,
      startDate: search.startDate,
      endDate: search.endDate,
      page: search.page,
    }),
    [
      search.search,
      search.userId,
      search.auditType,
      search.auditStatus,
      search.startDate,
      search.endDate,
      search.page,
    ],
  )
  const routeKey = JSON.stringify(routeDraft)
  const [draftState, setDraftState] = useState({ routeKey, value: routeDraft })
  const draft = draftState.routeKey === routeKey ? draftState.value : routeDraft
  const setDraft = (updater: (current: AuditLogSearch) => AuditLogSearch) => {
    setDraftState((current) => ({
      routeKey,
      value: updater(current.routeKey === routeKey ? current.value : routeDraft),
    }))
  }

  const params = useMemo(
    () => ({
      search: routeDraft.search,
      userId: routeDraft.userId,
      auditType: routeDraft.auditType,
      auditStatus: routeDraft.auditStatus,
      startDate: routeDraft.startDate,
      endDate: routeDraft.endDate,
      limit: PAGE_SIZE,
      offset: (routeDraft.page - 1) * PAGE_SIZE,
    }),
    [routeDraft],
  )
  const listQuery = useQuery({
    queryKey: auditLogQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => auditLogApi.list(params, signal),
    enabled: Boolean(session && canRead),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })

  const updateSearch = (updates: Partial<AuditLogSearch>, replace = false) =>
    void navigate({
      to: '/company/audit-log',
      search: (previous: AuditLogSearch) => ({ ...previous, ...updates }),
      replace,
      resetScroll: false,
    })

  const dateRangeError = auditLogDateRangeError(draft.startDate, draft.endDate)
  const updateDateDraft = (field: 'startDate' | 'endDate', value: string) =>
    setDraft((current) => ({ ...current, [field]: value }))
  const submitFilters = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (dateRangeError) return
    updateSearch({ ...draft, search: draft.search.trim(), userId: draft.userId.trim(), page: 1 })
  }
  const clearFilters = () => {
    const cleared: AuditLogSearch = {
      search: '',
      userId: '',
      auditType: '',
      auditStatus: '',
      startDate: '',
      endDate: '',
      page: 1,
    }
    setDraft(() => cleared)
    updateSearch(cleared)
  }

  const items = listQuery.data?.items ?? []
  const count = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(count / PAGE_SIZE))

  useEffect(() => {
    if (!listQuery.data || listQuery.isPlaceholderData) return
    if (search.page > pageCount) {
      void navigate({
        to: '/company/audit-log',
        search: (previous: AuditLogSearch) => ({ ...previous, page: pageCount }),
        replace: true,
        resetScroll: false,
      })
    }
  }, [listQuery.data, listQuery.isPlaceholderData, navigate, pageCount, search.page])

  if (session && !canRead) {
    return (
      <PageLayout title="Audit Log" subtitle="Review system activity in your authorized scope.">
        <ErrorState
          title="You can’t view the Audit Log"
          description="Your role does not have permission to list audit logs."
        />
      </PageLayout>
    )
  }

  const refresh = () => void listQuery.refetch()

  return (
    <PageLayout
      title="Audit Log"
      subtitle="Track recorded system activity and security events."
      backLink={
        <Link to="/company/overview" className={pageBackLinkClassName}>
          <PageBackLinkContent>Company overview</PageBackLinkContent>
        </Link>
      }
    >
      <div className="space-y-4">
        <section className="border-border-subtle bg-surface shadow-elevation-sm rounded-surface relative isolate overflow-hidden border">
          <div aria-hidden="true" className="bg-primary absolute inset-y-0 left-0 w-1" />
          <div className="from-primary-subtle/40 via-surface to-surface tablet:flex-row tablet:items-center tablet:justify-between tablet:p-5 flex flex-col gap-4 bg-gradient-to-br p-4">
            <div className="flex min-w-0 items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                <ShieldCheck className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-primary font-semibold">
                  Governance &amp; oversight
                </p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Activity register</h2>
                <p className="text-body-sm text-text-secondary mt-1 max-w-2xl">
                  A clear, searchable record of system actions and security events.
                </p>
              </div>
            </div>
            <div className="border-border-subtle bg-surface tablet:min-w-36 rounded-control shadow-elevation-sm flex items-center gap-3 border px-4 py-2.5">
              <span className="text-h2 text-text-primary tabular-nums">
                {listQuery.data ? count.toLocaleString() : '—'}
              </span>
              <span className="text-caption text-text-secondary leading-tight">
                events
                <br />
                recorded
              </span>
            </div>
          </div>
        </section>

        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex min-w-0 items-start gap-3">
            <span className="bg-surface-muted text-text-secondary rounded-control flex size-9 shrink-0 items-center justify-center">
              <ListFilter className="size-4" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h2 className="text-label text-text-primary font-semibold">Filter activity</h2>
              <p className="text-caption text-text-secondary mt-0.5">
                Narrow the register by keyword, user, event type, status, or date.
              </p>
            </div>
          </div>

          <form onSubmit={submitFilters} className="space-y-4">
            <div className="phone:grid-cols-2 desktop:grid-cols-3 grid min-w-0 grid-cols-1 gap-3">
              <FormControl id="audit-search" label="Search activity">
                <TextInput
                  value={draft.search}
                  onChange={(event) => {
                    const value = event.currentTarget.value
                    setDraft((current) => ({ ...current, search: value }))
                  }}
                  placeholder="Activity, user name, or email"
                  autoComplete="off"
                />
              </FormControl>
              <FormControl id="audit-user-id" label="User ID">
                <TextInput
                  type="number"
                  min="1"
                  step="1"
                  inputMode="numeric"
                  value={draft.userId}
                  onChange={(event) => {
                    const value = event.currentTarget.value
                    setDraft((current) => ({ ...current, userId: value }))
                  }}
                  placeholder="Any user"
                />
              </FormControl>
              <FormControl id="audit-type" label="Audit type">
                <DropdownSelect
                  value={draft.auditType}
                  options={typeOptions}
                  onChange={(value) =>
                    setDraft((current) => ({
                      ...current,
                      auditType: value as AuditLogSearch['auditType'],
                    }))
                  }
                  aria-label="Filter by audit type"
                />
              </FormControl>
              <FormControl id="audit-status" label="Audit status">
                <DropdownSelect
                  value={draft.auditStatus}
                  options={statusOptions}
                  onChange={(value) =>
                    setDraft((current) => ({
                      ...current,
                      auditStatus: value as AuditLogSearch['auditStatus'],
                    }))
                  }
                  aria-label="Filter by audit status"
                />
              </FormControl>
              <FormControl id="audit-start-date" label="From date">
                <DatePickerField
                  value={draft.startDate}
                  max={draft.endDate || undefined}
                  clearable
                  onValueChange={(value) => updateDateDraft('startDate', value)}
                />
              </FormControl>
              <FormControl id="audit-end-date" label="To date" error={dateRangeError ?? undefined}>
                <DatePickerField
                  value={draft.endDate}
                  min={draft.startDate || undefined}
                  aria-invalid={Boolean(dateRangeError)}
                  clearable
                  onValueChange={(value) => updateDateDraft('endDate', value)}
                />
              </FormControl>
            </div>
            <div className="phone:flex-row phone:justify-end flex flex-col-reverse gap-2">
              <Button
                type="button"
                variant="ghost"
                onClick={clearFilters}
                leadingIcon={<FilterX className="size-4" aria-hidden="true" />}
              >
                Clear filters
              </Button>
              <Button
                type="submit"
                disabled={Boolean(dateRangeError)}
                leadingIcon={<Search className="size-4" aria-hidden="true" />}
              >
                Apply filters
              </Button>
            </div>
          </form>
        </Card>

        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" role="status" title="Showing saved audit events">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <span>
                The latest refresh did not complete:{' '}
                {presentError(listQuery.error, 'section-load').message}
              </span>
              <Button size="sm" variant="outline" onClick={refresh}>
                Retry
              </Button>
            </div>
          </Alert>
        ) : null}

        {listQuery.isPending ? (
          <div className="space-y-3" aria-label="Loading audit events" role="status">
            {[0, 1, 2].map((item) => (
              <Skeleton key={item} variant="card" className="h-28" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <ErrorState
              title="Audit events are unavailable"
              description="We couldn’t load the audit register. Try again."
              error={listQuery.error}
              action={<Button onClick={refresh}>Try again</Button>}
            />
          </Card>
        ) : items.length ? (
          <Card className="overflow-hidden p-0" aria-busy={listQuery.isFetching || undefined}>
            <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-b px-4 py-3.5">
              <div>
                <h2 className="text-label text-text-primary font-semibold">Recorded activity</h2>
                <p className="text-caption text-text-secondary mt-0.5">
                  {items.length} {items.length === 1 ? 'event' : 'events'} on this page
                </p>
              </div>
              <span className="bg-primary-subtle text-primary rounded-pill text-caption inline-flex items-center gap-1.5 px-3 py-1 font-semibold tabular-nums">
                <ShieldCheck className="size-3.5" aria-hidden="true" />
                {count.toLocaleString()} total
              </span>
              {listQuery.isPlaceholderData ? (
                <span role="status" className="text-caption text-text-secondary">
                  Updating results…
                </span>
              ) : null}
            </div>
            <AuditLogTable items={items} />
            <div className="divide-border-subtle divide-y min-[1200px]:hidden">
              {items.map((log) => (
                <AuditLogMobileCard key={log.id} log={log} />
              ))}
            </div>
          </Card>
        ) : (
          <Card>
            <EmptyState
              icon={<ListFilter className="size-6" aria-hidden="true" />}
              title={
                search.search ||
                search.auditType ||
                search.auditStatus ||
                search.userId ||
                search.startDate ||
                search.endDate
                  ? 'No matching audit events'
                  : 'No audit events recorded'
              }
              description={
                search.search ||
                search.auditType ||
                search.auditStatus ||
                search.userId ||
                search.startDate ||
                search.endDate
                  ? 'Adjust or clear the filters to see more activity.'
                  : 'System activity will appear here when events are recorded.'
              }
            />
          </Card>
        )}

        {count > 0 ? (
          <div className="border-border-subtle text-body-sm text-text-secondary rounded-control bg-surface shadow-elevation-sm tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-3 border px-4 py-3">
            <p>
              Showing {(search.page - 1) * PAGE_SIZE + 1}–{Math.min(search.page * PAGE_SIZE, count)}{' '}
              of {count.toLocaleString()} events
            </p>
            <nav
              aria-label="Audit log pages"
              className="phone:justify-end flex items-center justify-between gap-2"
            >
              <Button
                variant="outline"
                size="sm"
                disabled={search.page <= 1 || listQuery.isFetching || listQuery.isPlaceholderData}
                onClick={() => updateSearch({ page: search.page - 1 })}
                leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
              >
                Previous
              </Button>
              <span className="px-1 whitespace-nowrap">
                Page {search.page} of {pageCount}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={
                  search.page >= pageCount || listQuery.isFetching || listQuery.isPlaceholderData
                }
                onClick={() => updateSearch({ page: search.page + 1 })}
              >
                Next <ChevronRight className="size-4" aria-hidden="true" />
              </Button>
            </nav>
          </div>
        ) : null}
      </div>
    </PageLayout>
  )
}
