import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Banknote,
  Briefcase,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Clock3,
  ExternalLink,
  FileText,
  Search,
  UserRound,
} from 'lucide-react'
import { useCallback, useEffect, useState, type FormEvent, type ReactNode } from 'react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

import { loansApi, type LoanListItem, type LoanRequest } from '../loans.api'
import { formatLoanCurrency, formatLoanDate, loanStatusTone } from '../loans.presentation'
import {
  loanDetailOptions,
  loansListOptions,
  loansQueryKeys,
  loanEmployeeChoicesOptions,
} from '../loans.queries'
import type { LoansSearch } from '../loans.search'
import type { MyLoansSearch } from '../my-loans.search'
import { LoanFormDialog } from './loan-form-dialog'
import { LoanRequestCard } from './loan-request-card'

const PAGE_SIZES = [10, 20, 50] as const
const STATUS_OPTIONS = [
  { value: 'all', label: 'All statuses' },
  { value: 'pending', label: 'Pending review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
]
const VIEW_OPTIONS = [
  { value: 'all', label: 'All requests', compactLabel: 'All' },
  { value: 'pending', label: 'Pending approvals', compactLabel: 'Pending' },
  { value: 'history', label: 'Decision history', compactLabel: 'History' },
]

type LoansRouteSearch = Omit<LoansSearch, 'search' | 'view'> & {
  search?: string
  view?: LoansSearch['view']
}

type LoansSearchUpdate = Partial<LoansSearch>

export function LoansPage() {
  const search = useSearch({ from: '/_protected/hr/loans' }) as LoansSearch
  const navigate = useNavigate()
  const onSearchChange = useCallback(
    (updates: LoansSearchUpdate) =>
      void navigate({
        to: '/hr/loans',
        search: (previous: LoansSearch) => ({ ...previous, ...updates }),
        resetScroll: false,
      }),
    [navigate],
  )
  return <LoansPageContent personal={false} search={search} onSearchChange={onSearchChange} />
}

export function MyLoansPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-loans' }) as MyLoansSearch
  const navigate = useNavigate()
  const onSearchChange = useCallback(
    (updates: LoansSearchUpdate) =>
      void navigate({
        to: '/dashboard/my-loans',
        search: (previous: MyLoansSearch) => ({
          ...previous,
          ...(Object.hasOwn(updates, 'status') ? { status: updates.status } : {}),
          ...(Object.hasOwn(updates, 'request_id') ? { request_id: updates.request_id } : {}),
          ...(Object.hasOwn(updates, 'page') ? { page: updates.page } : {}),
          ...(Object.hasOwn(updates, 'pageSize') ? { pageSize: updates.pageSize } : {}),
        }),
        resetScroll: false,
      }),
    [navigate],
  )
  return <LoansPageContent personal search={search} onSearchChange={onSearchChange} />
}

function normalizedStatus(value: string) {
  return value.toLocaleLowerCase()
}

function LoanDetailFact({ icon, label, value }: { icon: ReactNode; label: string; value: string }) {
  return (
    <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3">
      <dt className="text-caption text-text-secondary flex items-center gap-1.5">
        <span className="text-primary" aria-hidden="true">
          {icon}
        </span>
        {label}
      </dt>
      <dd className="text-body-sm text-text-primary mt-1.5 font-semibold break-words">{value}</dd>
    </div>
  )
}

function LoanDetails({
  loan,
  loading,
  error,
  onClose,
  onRetry,
  canApprove,
  canReject,
  canEdit,
  personal,
  currentUserId,
  onEdit,
  onDecision,
}: {
  loan: LoanRequest | null
  loading: boolean
  error: unknown
  onClose: () => void
  onRetry: () => void
  canApprove: boolean
  canReject: boolean
  canEdit: boolean
  personal: boolean
  currentUserId: number
  onEdit: () => void
  onDecision: (status: 'approved' | 'rejected') => void
}) {
  const status = loan ? normalizedStatus(loan.status) : ''
  const isOwn = loan?.employee_user_id === currentUserId
  const pendingReview = status === 'pending' && !isOwn
  return (
    <Dialog
      open={Boolean(loan) || loading || Boolean(error)}
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
      title={loan ? `Loan request #${loan.id}` : 'Loan request details'}
      description={
        loan
          ? `${personal ? 'Your request' : loan.employee_name} · Submitted ${formatLoanDate(loan.created_at)}`
          : 'Request terms and review details.'
      }
      size="lg"
      fitContent
      compactOnMobile
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
          {loan && canEdit && isOwn && status === 'pending' ? (
            <Button variant="outline" onClick={onEdit}>
              Edit request
            </Button>
          ) : null}
          {loan && pendingReview && canReject ? (
            <Button variant="danger" onClick={() => onDecision('rejected')}>
              Reject
            </Button>
          ) : null}
          {loan && pendingReview && canApprove ? (
            <Button onClick={() => onDecision('approved')}>Approve</Button>
          ) : null}
        </>
      }
    >
      {loading ? (
        <div className="space-y-3" aria-busy="true">
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} variant="row" />
          ))}
        </div>
      ) : null}
      {error ? (
        <ErrorState
          title="Loan request could not load"
          description="Try loading this request again. It may have been removed or your access may have changed."
          error={error}
          action={
            <Button variant="outline" onClick={onRetry}>
              Try again
            </Button>
          }
        />
      ) : null}
      {loan ? (
        <div className="space-y-5">
          <div className="from-primary-subtle/65 via-primary-subtle/25 to-surface border-border-subtle rounded-surface flex min-w-0 flex-wrap items-center justify-between gap-3 border bg-gradient-to-r p-3.5">
            <div className="flex min-w-0 items-center gap-3">
              <span className="bg-surface text-primary rounded-control flex size-10 shrink-0 items-center justify-center shadow-sm">
                <UserRound className="size-5" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-text-secondary mb-1">
                  {personal ? 'Your request' : 'Applicant'}
                </p>
                <p className="text-body-sm text-text-primary font-semibold break-words">
                  {loan.employee_name}
                </p>
              </div>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <StatusChip dense label={status.replaceAll('_', ' ')} tone={loanStatusTone(status)} />
              {isOwn ? <StatusChip dense label="Your request" tone="neutral" /> : null}
            </div>
          </div>
          <section aria-labelledby="loan-details-heading">
            <h3 id="loan-details-heading" className="text-label text-text-primary font-semibold">
              Request details
            </h3>
            <dl className="phone:grid-cols-2 tablet:grid-cols-3 mt-2.5 grid grid-cols-1 gap-2.5">
              <LoanDetailFact
                icon={<Banknote className="size-3.5" />}
                label="Requested amount"
                value={formatLoanCurrency(loan.loan_amount)}
              />
              <LoanDetailFact
                icon={<CalendarDays className="size-3.5" />}
                label="Planned repayment"
                value={formatLoanDate(loan.repayment_date)}
              />
              <LoanDetailFact
                icon={<Briefcase className="size-3.5" />}
                label="Role"
                value={loan.job_title && loan.job_title !== 'N/A' ? loan.job_title : 'Not provided'}
              />
              <LoanDetailFact
                icon={<UserRound className="size-3.5" />}
                label="Emergency contact"
                value={loan.emergency_contact_name}
              />
              <LoanDetailFact
                icon={<ExternalLink className="size-3.5" />}
                label="Contact phone"
                value={loan.emergency_contact_phone}
              />
              <LoanDetailFact
                icon={<Clock3 className="size-3.5" />}
                label="Last updated"
                value={formatLoanDate(loan.updated_at)}
              />
            </dl>
          </section>
          <section className="border-border-subtle rounded-control border p-3.5">
            <h3 className="text-label text-text-primary flex items-center gap-2 font-semibold">
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <FileText className="size-4" aria-hidden="true" />
              </span>
              Reason for request
            </h3>
            <p className="text-body-sm text-text-secondary mt-2 break-words whitespace-pre-wrap">
              {loan.reason}
            </p>
          </section>
          {loan.attachment ? (
            <a
              href={loan.attachment}
              target="_blank"
              rel="noreferrer"
              className="text-primary text-body-sm inline-flex items-center gap-2 underline"
            >
              <FileText className="size-4" />
              Open supporting document
              <ExternalLink className="size-3.5" />
            </a>
          ) : (
            <p className="text-caption text-text-muted">No supporting document attached.</p>
          )}
          {isOwn && status === 'pending' && (canApprove || canReject) ? (
            <Alert tone="info" title="Awaiting independent review">
              You cannot approve or reject your own request.
            </Alert>
          ) : null}
        </div>
      ) : null}
    </Dialog>
  )
}

function LoansPageContent({
  personal,
  search,
  onSearchChange,
}: {
  personal: boolean
  search: LoansRouteSearch | MyLoansSearch
  onSearchChange: (updates: LoansSearchUpdate) => void
}) {
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = personal
    ? hasPermission(permissions, 'loans', 'list_own') &&
      !hasPermission(permissions, 'loans', 'list')
    : hasPermission(permissions, 'loans', 'list')
  const canView =
    hasPermission(permissions, 'loans', 'view') || hasPermission(permissions, 'loans', 'view_own')
  const canCreate = hasPermission(permissions, 'loans', 'create')
  const canUpdate =
    hasPermission(permissions, 'loans', 'update') ||
    hasPermission(permissions, 'loans', 'update_own')
  const canApprove = hasPermission(permissions, 'loans', 'approve')
  const canReject = hasPermission(permissions, 'loans', 'reject')
  const canChooseEmployee = !personal && hasPermission(permissions, 'employees', 'list')
  const hrSearch = search as LoansSearch
  const searchValue = personal ? '' : hrSearch.search
  const [draftState, setDraftState] = useState({ routeValue: searchValue, value: searchValue })
  const searchDraft = draftState.routeValue === searchValue ? draftState.value : searchValue
  const [formOpen, setFormOpen] = useState(false)
  const [editingLoan, setEditingLoan] = useState<LoanRequest | null>(null)
  const [decision, setDecision] = useState<{
    loan: LoanListItem
    status: 'approved' | 'rejected'
  } | null>(null)
  const selectedId = search.request_id ?? 0

  function updateSearch(updates: LoansSearchUpdate) {
    onSearchChange(updates)
  }
  function commitSearch(event: FormEvent) {
    event.preventDefault()
    updateSearch({ search: personal ? undefined : searchDraft.trim(), page: 1 })
  }
  const view = personal ? 'all' : ((search as LoansSearch).view ?? 'all')
  const effectiveStatus =
    view === 'pending' ? 'pending' : view === 'history' ? 'history' : search.status
  const params = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: personal ? '' : hrSearch.search,
    status: effectiveStatus,
  }
  const listQuery = useQuery({
    ...loansListOptions(userId, employeeId, params),
    enabled: Boolean(session && canList),
    placeholderData: keepPreviousData,
  })
  const detailQuery = useQuery({
    ...loanDetailOptions(userId, employeeId, selectedId),
    enabled: Boolean(selectedId && canView),
  })
  const employeeChoicesQuery = useQuery({
    ...loanEmployeeChoicesOptions(userId, employeeId),
    enabled: Boolean(session && canChooseEmployee && formOpen && !editingLoan),
  })
  const createMutation = useMutation({ mutationFn: loansApi.create })
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: Parameters<typeof loansApi.update>[1] }) =>
      loansApi.update(id, input),
  })
  const approveMutation = useMutation({ mutationFn: loansApi.approve })
  const rejectMutation = useMutation({ mutationFn: loansApi.reject })
  const saving = createMutation.isPending || updateMutation.isPending
  const deciding = approveMutation.isPending || rejectMutation.isPending

  async function invalidate() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: loansQueryKeys.lists(userId, employeeId) }),
      queryClient.invalidateQueries({
        queryKey: [...loansQueryKeys.scoped(userId, employeeId), 'detail'],
      }),
    ])
  }
  function openDecision(loan: LoanListItem, status: 'approved' | 'rejected') {
    approveMutation.reset()
    rejectMutation.reset()
    setDecision({ loan, status })
  }
  async function saveLoan(
    input: Parameters<typeof loansApi.create>[0] | Parameters<typeof loansApi.update>[1],
  ) {
    if (editingLoan) {
      await updateMutation.mutateAsync({ id: editingLoan.id, input })
      showToast({
        title: 'Loan request updated',
        description: 'Your changes were saved.',
        tone: 'success',
      })
    } else {
      const created = await createMutation.mutateAsync(
        input as Parameters<typeof loansApi.create>[0],
      )
      if (canView) updateSearch({ request_id: created.id, page: 1 })
      showToast({
        title: 'Loan request submitted',
        description: 'The request is now awaiting review.',
        tone: 'success',
      })
    }
    await invalidate()
    setFormOpen(false)
    setEditingLoan(null)
  }
  async function submitDecision() {
    if (!decision) return
    try {
      if (decision.status === 'approved') await approveMutation.mutateAsync(decision.loan.id)
      else await rejectMutation.mutateAsync(decision.loan.id)
      await invalidate()
      showToast({
        title: decision.status === 'approved' ? 'Loan approved' : 'Loan rejected',
        description: 'The review decision has been recorded.',
        tone: 'success',
      })
      approveMutation.reset()
      rejectMutation.reset()
      setDecision(null)
    } catch {
      // The open confirmation dialog presents this failure beside the decision.
    }
  }

  const items = listQuery.data?.items ?? []
  const total = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(total / search.pageSize))
  useEffect(() => {
    if (!listQuery.data || search.page <= pageCount) return
    onSearchChange({ page: pageCount })
  }, [listQuery.data, onSearchChange, pageCount, search.page])
  const filtersActive = Boolean((!personal && searchValue) || search.status !== 'all')
  const currentLoan = detailQuery.data
  const employeeName =
    [session?.employee.first_name, session?.employee.last_name].filter(Boolean).join(' ') ||
    session?.user.username ||
    'Current employee'
  const canOpenSelected = Boolean(selectedId && canView)
  const isOwn = (loan: { employee_user_id: number }) => loan.employee_user_id === userId

  if (sessionQuery.isPending)
    return (
      <PageLayout
        title={personal ? 'My Loans' : 'Loans'}
        subtitle={
          personal
            ? 'Submit a request and keep track of its review status.'
            : 'Review employee loan requests and track decisions.'
        }
      >
        <Card className="space-y-3" aria-busy="true">
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} variant="row" />
          ))}
        </Card>
      </PageLayout>
    )
  if (sessionQuery.isError || !session)
    return (
      <PageLayout title={personal ? 'My Loans' : 'Loans'}>
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )

  return (
    <PageLayout
      title={personal ? 'My Loans' : 'Loans'}
      subtitle={
        personal
          ? 'Submit a request and keep track of its review status.'
          : 'Review employee loan requests and track decisions.'
      }
      leading={<Banknote className="size-[18px]" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            title="Create loan request"
            aria-label="Create loan request"
            leadingIcon={<Banknote className="size-4" />}
            onClick={() => {
              setEditingLoan(null)
              setFormOpen(true)
            }}
          >
            <span className="hidden min-[480px]:inline">New request</span>
            <span className="hidden min-[361px]:inline min-[480px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-2">
            <div>
              <p className="text-overline text-primary font-semibold">
                {personal ? 'My Work' : 'Employee finance'}
              </p>
              <h2 className="text-h3 mt-1 font-semibold">
                {personal ? 'My loan requests' : 'Loan register'}
              </h2>
            </div>
            <p className="text-caption text-text-secondary" aria-live="polite">
              {listQuery.isPending && !listQuery.data
                ? 'Loading requests'
                : `${total} ${total === 1 ? 'request' : 'requests'}`}
            </p>
          </div>
          {!personal ? (
            <div
              className="bg-surface-muted rounded-control grid grid-cols-3 gap-1 p-1"
              role="tablist"
              aria-label="Loan request views"
            >
              {VIEW_OPTIONS.map((option) => (
                <button
                  key={option.value}
                  type="button"
                  role="tab"
                  aria-selected={view === option.value}
                  onClick={() =>
                    updateSearch({
                      view: option.value as LoansSearch['view'],
                      status: 'all',
                      page: 1,
                    })
                  }
                  className={`rounded-control text-caption min-h-10 px-2 font-semibold transition-colors ${view === option.value ? 'bg-surface text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}`}
                >
                  <span className="tablet:hidden">{option.compactLabel}</span>
                  <span className="tablet:inline hidden">{option.label}</span>
                </button>
              ))}
            </div>
          ) : null}
          {!personal ? (
            <form
              onSubmit={commitSearch}
              className="phone:grid-cols-[minmax(0,1fr)_auto] phone:items-end grid gap-3"
            >
              <FormControl id="loan-search" label="Search requests">
                <span className="relative block">
                  <Search className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2" />
                  <TextInput
                    className="pl-10"
                    type="search"
                    maxLength={200}
                    placeholder="Employee or reason"
                    value={searchDraft}
                    onChange={(event) =>
                      setDraftState({ routeValue: searchValue, value: event.currentTarget.value })
                    }
                  />
                </span>
              </FormControl>
              <Button
                type="submit"
                className="phone:w-auto w-full"
                aria-label="Apply search"
                leadingIcon={<Search className="size-4" />}
              >
                <span className="phone:hidden tablet:inline">Apply search</span>
              </Button>
            </form>
          ) : null}
          <div className="phone:flex-row phone:items-end phone:justify-between flex flex-col gap-3">
            <FormControl
              id="loan-status-filter"
              label="Status"
              className="phone:max-w-[22rem] phone:flex-1 min-w-0"
            >
              <DropdownSelect
                value={search.status}
                options={STATUS_OPTIONS}
                disabled={view !== 'all'}
                onChange={(value) =>
                  updateSearch({ status: value as LoansSearch['status'], page: 1 })
                }
              />
            </FormControl>
            {filtersActive ? (
              <Button
                variant="ghost"
                size="sm"
                className="self-end"
                onClick={() => {
                  setDraftState({ routeValue: '', value: '' })
                  updateSearch({ search: personal ? undefined : '', status: 'all', page: 1 })
                }}
              >
                Clear filters
              </Button>
            ) : null}
          </div>
        </Card>
        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" title="Showing saved requests">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>The latest refresh failed. Previously loaded requests remain available.</span>
              <Button size="sm" variant="outline" onClick={() => void listQuery.refetch()}>
                Retry refresh
              </Button>
            </div>
          </Alert>
        ) : null}
        {listQuery.isPending && !listQuery.data ? (
          <Card className="space-y-3" aria-busy="true" aria-label="Loading loan requests">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} variant="row" />
            ))}
          </Card>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <ErrorState
              title="Loan requests could not load"
              description="Try loading the register again."
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          </Card>
        ) : items.length === 0 ? (
          <Card>
            <EmptyState
              icon={<Banknote className="size-6" />}
              title={
                filtersActive
                  ? 'No requests match these filters'
                  : view === 'pending'
                    ? 'No requests awaiting approval'
                    : view === 'history'
                      ? 'No decisions recorded yet'
                      : personal
                        ? 'No loan requests yet'
                        : 'No loan requests yet'
              }
              description={
                filtersActive
                  ? 'Change or clear the filters to see other requests.'
                  : personal
                    ? 'Your loan requests will appear here once submitted.'
                    : 'Requests within your access scope will appear here.'
              }
              action={
                filtersActive ? (
                  <Button
                    variant="outline"
                    onClick={() =>
                      updateSearch({ search: personal ? undefined : '', status: 'all', page: 1 })
                    }
                  >
                    Clear filters
                  </Button>
                ) : canCreate ? (
                  <Button
                    onClick={() => {
                      setEditingLoan(null)
                      setFormOpen(true)
                    }}
                  >
                    Create request
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <div className="desktop:grid-cols-2 grid min-w-0 gap-3">
            {items.map((loan) => (
              <LoanRequestCard
                key={loan.id}
                loan={loan}
                personal={personal}
                isOwn={isOwn(loan)}
                canView={canView}
                canUpdate={canUpdate}
                canApprove={canApprove}
                canReject={canReject}
                onView={() => updateSearch({ request_id: loan.id })}
                onEdit={() => {
                  void queryClient
                    .ensureQueryData(loanDetailOptions(userId, employeeId, loan.id))
                    .then((record) => {
                      setEditingLoan(record)
                      setFormOpen(true)
                    })
                    .catch((error) =>
                      showToast({
                        title: 'Request could not load for editing',
                        description: presentError(error, 'background-action').message,
                        tone: 'danger',
                      }),
                    )
                }}
                onDecision={openDecision}
              />
            ))}
          </div>
        )}
        {items.length > 0 ? (
          <Card className="flex flex-wrap items-center justify-between gap-3 p-3">
            <p className="text-caption text-text-secondary" aria-live="polite">
              {total
                ? `${(search.page - 1) * search.pageSize + 1}–${Math.min(search.page * search.pageSize, total)} of ${total}`
                : '0 requests'}
            </p>
            <div className="flex min-w-0 flex-wrap items-center justify-end gap-2">
              <DropdownSelect
                aria-label="Requests per page"
                value={String(search.pageSize)}
                options={PAGE_SIZES.map((size) => ({
                  value: String(size),
                  label: `${size} per page`,
                }))}
                onChange={(value) =>
                  updateSearch({ pageSize: Number(value) as LoansSearch['pageSize'], page: 1 })
                }
              />
              <Button
                size="sm"
                variant="outline"
                aria-label="Previous page"
                disabled={search.page <= 1}
                onClick={() => updateSearch({ page: search.page - 1 })}
              >
                <ChevronLeft className="size-4" />
                <span className="tablet:inline hidden">Previous</span>
              </Button>
              <span className="text-caption text-text-secondary tabular-nums">
                {search.page}/{pageCount}
              </span>
              <Button
                size="sm"
                variant="outline"
                aria-label="Next page"
                disabled={search.page >= pageCount}
                onClick={() => updateSearch({ page: search.page + 1 })}
              >
                <span className="tablet:inline hidden">Next</span>
                <ChevronRight className="size-4" />
              </Button>
            </div>
          </Card>
        ) : null}
      </div>
      {formOpen ? (
        <LoanFormDialog
          key={editingLoan?.id ?? 'new'}
          open={formOpen}
          onOpenChange={(open) => {
            setFormOpen(open)
            if (!open) setEditingLoan(null)
          }}
          loan={editingLoan}
          currentUserId={userId}
          currentEmployeeName={employeeName}
          employees={employeeChoicesQuery.data?.items ?? []}
          canChooseEmployee={canChooseEmployee}
          employeeChoicesLoading={employeeChoicesQuery.isPending}
          employeeChoicesError={employeeChoicesQuery.error}
          onRetryEmployees={() => void employeeChoicesQuery.refetch()}
          saving={saving}
          onUploadAttachment={async (file) => (await loansApi.uploadAttachment(file)).url}
          canSubmit={
            !canChooseEmployee ||
            Boolean(editingLoan) ||
            (!employeeChoicesQuery.isPending &&
              !employeeChoicesQuery.isError &&
              Boolean(employeeChoicesQuery.data?.items.length))
          }
          onSave={saveLoan}
        />
      ) : null}
      <LoanDetails
        loan={canOpenSelected ? (currentLoan ?? null) : null}
        loading={canOpenSelected && detailQuery.isPending}
        error={canOpenSelected ? detailQuery.error : undefined}
        onClose={() => updateSearch({ request_id: undefined })}
        onRetry={() => void detailQuery.refetch()}
        canApprove={canApprove}
        canReject={canReject}
        canEdit={canUpdate}
        personal={personal}
        currentUserId={userId}
        onEdit={() => {
          if (currentLoan) {
            setEditingLoan(currentLoan)
            setFormOpen(true)
            updateSearch({ request_id: undefined })
          }
        }}
        onDecision={(status) => {
          if (currentLoan) openDecision(currentLoan, status)
        }}
      />
      <Dialog
        open={Boolean(decision)}
        onOpenChange={(open) => {
          if (!open && !deciding) {
            setDecision(null)
            approveMutation.reset()
            rejectMutation.reset()
          }
        }}
        title={decision?.status === 'approved' ? 'Approve loan request?' : 'Reject loan request?'}
        description="This decision will update the request status."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deciding}
        footer={
          <>
            <Button
              variant="outline"
              disabled={deciding}
              onClick={() => {
                setDecision(null)
                approveMutation.reset()
                rejectMutation.reset()
              }}
            >
              Cancel
            </Button>
            <Button
              variant={decision?.status === 'rejected' ? 'danger' : 'primary'}
              isLoading={deciding}
              onClick={() => void submitDecision()}
            >
              {decision?.status === 'approved' ? 'Approve request' : 'Reject request'}
            </Button>
          </>
        }
      >
        {decision ? (
          <div className="space-y-3">
            <div className="bg-surface-muted border-border-subtle rounded-control border p-3.5">
              <p className="text-caption text-text-secondary">Request from</p>
              <p className="text-body-sm mt-1 font-semibold">{decision.loan.employee_name}</p>
              <p className="text-body-sm text-text-secondary mt-1">
                {formatLoanCurrency(decision.loan.loan_amount)} · Request #{decision.loan.id}
              </p>
            </div>
            <p className="text-body-sm text-text-secondary">
              {decision.status === 'approved'
                ? 'Approving will record this request as approved.'
                : 'Rejecting will record this request as rejected.'}
            </p>
            {approveMutation.isError || rejectMutation.isError ? (
              <Alert tone="danger" title="Decision not saved">
                {
                  presentError(approveMutation.error ?? rejectMutation.error, 'background-action')
                    .message
                }
              </Alert>
            ) : null}
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}
