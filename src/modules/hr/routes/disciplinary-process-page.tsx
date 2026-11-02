import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  AlertTriangle,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  Search,
  ShieldAlert,
  Trash2,
  UserRound,
} from 'lucide-react'
import { useState, type FormEvent } from 'react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import {
  recognitionApi,
  type DisciplinaryCase,
  type DisciplinaryCaseInput,
} from '../recognition.api'
import {
  disciplinaryDetailOptions,
  disciplinaryListOptions,
  employeeChoicesOptions,
  recognitionQueryKeys,
} from '../recognition.queries'
import { matchesRecognitionText, type RecognitionSearch } from '../recognition.search'
import { DisciplinaryCaseFormDialog } from './disciplinary-case-form-dialog'

const ACTIONS: DropdownSelectOption[] = [
  { value: 'all', label: 'All actions' },
  { value: 'verbal_warning', label: 'Verbal warning' },
  { value: 'written_warning', label: 'Written warning' },
  { value: 'final_warning', label: 'Final warning' },
  { value: 'suspension', label: 'Suspension' },
  { value: 'termination', label: 'Termination' },
  { value: 'demotion', label: 'Demotion' },
]

const CATEGORIES: DropdownSelectOption[] = [
  { value: 'all', label: 'All categories' },
  { value: 'attendance_issues', label: 'Attendance issues' },
  { value: 'misconduct', label: 'Misconduct' },
  { value: 'poor_performance', label: 'Poor performance' },
  { value: 'insubordination', label: 'Insubordination' },
  { value: 'dishonesty', label: 'Dishonesty' },
  { value: 'safety_violation', label: 'Safety violation' },
  { value: 'confidentiality_breach', label: 'Confidentiality breach' },
  { value: 'harassment_discrimination', label: 'Harassment / discrimination' },
  { value: 'other', label: 'Other' },
]

const PAGE_SIZES: DropdownSelectOption[] = [10, 20, 50].map((size) => ({
  value: String(size),
  label: `${size} per page`,
}))

function label(value: string): string {
  return value.replace(/[_-]+/g, ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function dateLabel(value: string): string {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return 'Date unavailable'
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function actionTone(action: string): StatusTone {
  if (action === 'termination') return 'danger'
  if (action === 'suspension' || action === 'final_warning') return 'warning'
  if (action === 'verbal_warning') return 'info'
  return 'primary'
}

function matchesCase(kase: DisciplinaryCase, employeeName: string, search: string): boolean {
  return matchesRecognitionText(
    [
      kase.violationTitle,
      kase.violationDescription,
      kase.violationCategory,
      kase.actionType,
      employeeName,
      String(kase.employeeId),
    ],
    search,
  )
}

export function DisciplinaryProcessPage() {
  const search = useSearch({ from: '/_protected/hr/disciplinary-process' }) as RecognitionSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'disciplinary_cases', 'list')
  const canListOwn = hasPermission(permissions, 'disciplinary_cases', 'list_own')
  const canView = hasPermission(permissions, 'disciplinary_cases', 'view')
  const canCreate = hasPermission(permissions, 'disciplinary_cases', 'create')
  const canUpdate = hasPermission(permissions, 'disciplinary_cases', 'update')
  const canDelete = hasPermission(permissions, 'disciplinary_cases', 'delete')
  const mayList = canList || canListOwn
  const listQuery = useQuery({
    ...disciplinaryListOptions(userId, employeeKey, {
      actionType: search.action,
      violationCategory: search.category,
    }),
    enabled: Boolean(session && mayList),
  })
  const employeeQuery = useQuery({
    ...employeeChoicesOptions(userId, employeeKey),
    enabled: Boolean(session && mayList && (canCreate || canUpdate)),
  })
  const detailQuery = useQuery({
    ...disciplinaryDetailOptions(userId, employeeKey, search.case_id ?? 0),
    enabled: Boolean(session && canView && search.case_id),
  })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const [draftState, setDraftState] = useState({ routeValue: search.search, value: search.search })
  const [formCase, setFormCase] = useState<DisciplinaryCase | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<DisciplinaryCase | null>(null)
  const draft = draftState.routeValue === search.search ? draftState.value : search.search
  const updateSearch = (updates: Partial<RecognitionSearch>) =>
    void navigate({
      to: '/hr/disciplinary-process',
      search: (previous: RecognitionSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })

  const createMutation = useMutation({
    mutationFn: (input: DisciplinaryCaseInput) => recognitionApi.disciplinary.create(input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.disciplinary })
      showToast({ tone: 'success', title: 'Disciplinary case created' })
    },
  })
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: DisciplinaryCaseInput }) =>
      recognitionApi.disciplinary.update(id, input),
    onSuccess: async (kase) => {
      queryClient.setQueryData(
        recognitionQueryKeys.disciplinaryDetail(userId, employeeKey, kase.id),
        kase,
      )
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.disciplinary })
      showToast({ tone: 'success', title: 'Disciplinary case updated' })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (id: number) => recognitionApi.disciplinary.remove(id),
    onSuccess: async (_result, id) => {
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.disciplinary })
      queryClient.removeQueries({
        queryKey: recognitionQueryKeys.disciplinaryDetail(userId, employeeKey, id),
      })
      showToast({ tone: 'success', title: 'Disciplinary case deleted' })
      setDeleteTarget(null)
      if (search.case_id === id) updateSearch({ case_id: undefined })
    },
  })

  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    updateSearch({ search: draft.trim(), page: 1 })
  }
  function openForm(kase: DisciplinaryCase | null) {
    setFormCase(kase)
    setFormOpen(true)
  }
  async function saveCase(input: DisciplinaryCaseInput) {
    if (formCase) await updateMutation.mutateAsync({ id: formCase.id, input })
    else await createMutation.mutateAsync(input)
    setFormOpen(false)
    setFormCase(null)
  }

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Disciplinary process">
        <ErrorState
          title="Your HR access could not be loaded"
          description="Retry loading your account and case access."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }
  if (session && !mayList) {
    return (
      <PageLayout title="Disciplinary process">
        <ErrorState
          title="You can’t view disciplinary cases"
          description="Your account does not have permission to read case records."
        />
      </PageLayout>
    )
  }

  const allCases = listQuery.data?.items ?? []
  const choices = employeeQuery.data ?? []
  const employeeNames = new Map(
    choices.map((employee) => [employee.id, employee.fullName || employee.employeeCode]),
  )
  const filtered = allCases.filter((kase) =>
    matchesCase(kase, employeeNames.get(kase.employeeId) ?? '', search.search),
  )
  const pages = Math.max(1, Math.ceil(filtered.length / search.pageSize))
  const page = Math.min(search.page, pages)
  const visible = filtered.slice((page - 1) * search.pageSize, page * search.pageSize)
  const activeFilters =
    search.search.length > 0 || search.action !== 'all' || search.category !== 'all'

  return (
    <PageLayout
      title="Disciplinary process"
      subtitle="Manage documented employee conduct and action records."
      leading={<ShieldAlert className="size-5" aria-hidden="true" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            aria-label="New case"
            leadingIcon={<AlertTriangle className="size-4" aria-hidden="true" />}
            onClick={() => openForm(null)}
            className="max-[360px]:size-9 max-[360px]:px-0"
          >
            <span className="hidden min-[480px]:inline">New case</span>
            <span className="hidden min-[361px]:inline min-[480px]:hidden">New</span>
          </Button>
        ) : undefined
      }
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Employee relations</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Case register</h2>
              <p className="text-caption text-text-secondary mt-1">
                Records visible within your assigned access scope.
              </p>
            </div>
            <span
              role="status"
              aria-live="polite"
              className="bg-primary-subtle text-primary text-caption rounded-full px-3 py-1.5 font-semibold tabular-nums"
            >
              {listQuery.data?.count ?? 0} {listQuery.data?.count === 1 ? 'case' : 'cases'}
            </span>
          </div>
          <form
            onSubmit={submitSearch}
            className="desktop:grid-cols-[minmax(0,1fr)_13rem_13rem_auto] grid min-w-0 gap-3 min-[400px]:grid-cols-4 min-[400px]:items-end"
          >
            <FormControl
              id="disciplinary-search"
              label="Search cases"
              className="desktop:col-span-1 min-w-0 min-[400px]:col-span-3"
            >
              <TextInput
                value={draft}
                onChange={(event) =>
                  setDraftState({ routeValue: search.search, value: event.currentTarget.value })
                }
                placeholder="Employee, action, category, or title"
              />
            </FormControl>
            <FormControl
              id="disciplinary-action-filter"
              label="Action type"
              className="desktop:col-span-1 desktop:col-start-2 desktop:row-start-1 min-w-0 min-[400px]:col-span-2 min-[400px]:col-start-1 min-[400px]:row-start-2"
            >
              <DropdownSelect
                value={search.action}
                options={ACTIONS}
                onChange={(action) => updateSearch({ action, page: 1 })}
                aria-label="Filter disciplinary cases by action"
              />
            </FormControl>
            <FormControl
              id="disciplinary-category-filter"
              label="Violation category"
              className="desktop:col-span-1 desktop:col-start-3 desktop:row-start-1 min-w-0 min-[400px]:col-span-2 min-[400px]:col-start-3 min-[400px]:row-start-2"
            >
              <DropdownSelect
                value={search.category}
                options={CATEGORIES}
                onChange={(category) => updateSearch({ category, page: 1 })}
                aria-label="Filter disciplinary cases by violation category"
              />
            </FormControl>
            <Button
              type="submit"
              leadingIcon={<Search className="size-4" aria-hidden="true" />}
              className="desktop:col-start-4 desktop:row-start-1 w-full min-[400px]:col-start-4 min-[400px]:row-start-1 min-[400px]:w-auto"
            >
              Search
            </Button>
          </form>
          {activeFilters ? (
            <div className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t pt-3">
              <p className="text-caption text-text-muted">Filters apply to the case register.</p>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setDraftState({ routeValue: '', value: '' })
                  updateSearch({ search: '', action: 'all', category: 'all', page: 1 })
                }}
              >
                Clear filters
              </Button>
            </div>
          ) : null}
        </Card>

        {listQuery.isPending ? (
          <div className="desktop:grid-cols-2 grid gap-3" aria-label="Loading disciplinary cases">
            {[0, 1, 2, 3].map((item) => (
              <Skeleton key={item} className="h-44 w-full" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <SectionErrorState
              title="Disciplinary cases could not be loaded"
              description="Retry to load the records in your current access scope."
              onRetry={() => void listQuery.refetch()}
            />
          </Card>
        ) : (
          <Card className="tablet:p-5 space-y-4 p-4">
            {listQuery.isError ? (
              <SectionErrorState
                title="Showing saved case records"
                description="The latest refresh failed. Retry to load current case data."
                onRetry={() => void listQuery.refetch()}
              />
            ) : null}
            <div className="flex flex-wrap items-end justify-between gap-3">
              <div>
                <p className="text-overline text-primary font-semibold">Records</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Disciplinary cases</h2>
              </div>
              <p className="text-caption text-text-secondary tabular-nums">
                {filtered.length} {filtered.length === 1 ? 'match' : 'matches'}
              </p>
            </div>
            {visible.length ? (
              <div
                className="desktop:grid-cols-2 grid min-w-0 gap-3"
                aria-label="Disciplinary case records"
              >
                {visible.map((kase) => (
                  <CaseCard
                    key={kase.id}
                    kase={kase}
                    employeeName={
                      employeeNames.get(kase.employeeId) ?? `Employee #${kase.employeeId}`
                    }
                    canView={canView}
                    canUpdate={canUpdate}
                    canDelete={canDelete}
                    onView={() => updateSearch({ case_id: kase.id })}
                    onEdit={() => openForm(kase)}
                    onDelete={() => setDeleteTarget(kase)}
                  />
                ))}
              </div>
            ) : (
              <EmptyState
                icon={<ClipboardList className="size-6" aria-hidden="true" />}
                title={
                  allCases.length
                    ? 'No cases match these filters'
                    : 'No disciplinary cases recorded'
                }
                description={
                  allCases.length
                    ? 'Change the search or clear filters to see more records.'
                    : 'Disciplinary records will appear here when they are created.'
                }
                action={
                  activeFilters ? (
                    <Button
                      variant="outline"
                      onClick={() => {
                        setDraftState({ routeValue: '', value: '' })
                        updateSearch({ search: '', action: 'all', category: 'all', page: 1 })
                      }}
                    >
                      Clear filters
                    </Button>
                  ) : undefined
                }
              />
            )}
            {filtered.length > 0 ? (
              <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-3">
                <p className="text-caption text-text-secondary tabular-nums">
                  Showing {(page - 1) * search.pageSize + 1}–
                  {Math.min(page * search.pageSize, filtered.length)} of {filtered.length}
                </p>
                <div className="flex flex-wrap items-center gap-2">
                  <DropdownSelect
                    value={String(search.pageSize)}
                    options={PAGE_SIZES}
                    onChange={(value) =>
                      updateSearch({
                        pageSize: Number(value) as RecognitionSearch['pageSize'],
                        page: 1,
                      })
                    }
                    aria-label="Cases per page"
                    className="min-w-36"
                  />
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={page <= 1}
                    onClick={() => updateSearch({ page: page - 1 })}
                  >
                    <ChevronLeft className="size-4" aria-hidden="true" /> Previous
                  </Button>
                  <span
                    className="text-caption text-text-secondary tabular-nums"
                    aria-live="polite"
                  >
                    {page} / {pages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={page >= pages}
                    onClick={() => updateSearch({ page: page + 1 })}
                  >
                    Next <ChevronRight className="size-4" aria-hidden="true" />
                  </Button>
                </div>
              </div>
            ) : null}
          </Card>
        )}
      </div>

      <Dialog
        open={Boolean(search.case_id)}
        onOpenChange={(open) => {
          if (!open) updateSearch({ case_id: undefined })
        }}
        title={detailQuery.data?.violationTitle ?? 'Disciplinary case'}
        description="Case details and recorded action"
        size="lg"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => updateSearch({ case_id: undefined })}>
              Close
            </Button>
            {detailQuery.data && canDelete ? (
              <Button variant="danger" onClick={() => setDeleteTarget(detailQuery.data!)}>
                <Trash2 className="size-4" aria-hidden="true" /> Delete
              </Button>
            ) : null}
            {detailQuery.data && canUpdate ? (
              <Button
                onClick={() => {
                  openForm(detailQuery.data!)
                  updateSearch({ case_id: undefined })
                }}
              >
                Edit case
              </Button>
            ) : null}
          </>
        }
      >
        {detailQuery.isPending ? (
          <Skeleton className="h-52 w-full" aria-label="Loading case details" />
        ) : null}
        {detailQuery.isError ? (
          <SectionErrorState
            title="Case details could not be loaded"
            description="The record may have been removed or is outside your current access scope."
            onRetry={() => void detailQuery.refetch()}
          />
        ) : null}
        {detailQuery.data ? (
          <CaseDetails
            kase={detailQuery.data}
            employeeName={
              employeeNames.get(detailQuery.data.employeeId) ??
              `Employee #${detailQuery.data.employeeId}`
            }
          />
        ) : null}
      </Dialog>
      <DisciplinaryCaseFormDialog
        key={formOpen ? (formCase?.id ?? 'new-case-open') : 'case-closed'}
        open={formOpen}
        kase={formCase}
        employeeChoices={choices}
        employeeChoicesAvailable={!employeeQuery.isError}
        saving={createMutation.isPending || updateMutation.isPending}
        onOpenChange={(open) => {
          setFormOpen(open)
          if (!open) setFormCase(null)
        }}
        onSave={saveCase}
      />
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteTarget(null)
        }}
        title="Delete disciplinary case?"
        description="The case record will be permanently removed."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          <>
            <Button
              variant="outline"
              disabled={deleteMutation.isPending}
              onClick={() => setDeleteTarget(null)}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deleteMutation.isPending}
              onClick={() => {
                if (deleteTarget) deleteMutation.mutate(deleteTarget.id)
              }}
            >
              Delete case
            </Button>
          </>
        }
      >
        <p className="text-body-sm text-text-secondary">
          Delete <strong className="text-text-primary">{deleteTarget?.violationTitle}</strong> for{' '}
          {deleteTarget
            ? (employeeNames.get(deleteTarget.employeeId) ?? `Employee #${deleteTarget.employeeId}`)
            : ''}
          ?
        </p>
        {deleteMutation.isError ? (
          <Alert tone="danger" title="Case not deleted" role="alert" className="mt-3">
            {deleteMutation.error instanceof Error ? deleteMutation.error.message : 'Try again.'}
          </Alert>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}

function CaseCard({
  kase,
  employeeName,
  canView,
  canUpdate,
  canDelete,
  onView,
  onEdit,
  onDelete,
}: {
  kase: DisciplinaryCase
  employeeName: string
  canView: boolean
  canUpdate: boolean
  canDelete: boolean
  onView: () => void
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <article className="border-border-subtle bg-surface shadow-elevation-sm rounded-surface flex min-w-0 flex-col overflow-hidden border">
      <div className="flex min-w-0 flex-1 items-start gap-3 p-4">
        <span className="bg-warning-subtle text-warning-foreground flex size-11 shrink-0 items-center justify-center rounded-xl">
          <AlertTriangle className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <h3 className="text-body-lg text-text-primary min-w-0 flex-1 font-semibold break-words max-[479px]:basis-full">
              {kase.violationTitle}
            </h3>
            <div className="max-[479px]:ml-auto">
              <StatusChip label={label(kase.actionType)} tone={actionTone(kase.actionType)} dense />
            </div>
          </div>
          <p className="text-caption text-text-secondary mt-1 flex items-center gap-1.5">
            <UserRound className="size-4 shrink-0" aria-hidden="true" />
            {employeeName}
          </p>
          <div className="text-caption text-text-secondary mt-2 flex flex-wrap items-center gap-x-4 gap-y-1.5">
            <span>{label(kase.violationCategory)}</span>
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
              {dateLabel(kase.dateOfViolation)}
            </span>
          </div>
          <p className="text-body-sm text-text-secondary mt-3 line-clamp-2 break-words">
            {kase.violationDescription}
          </p>
        </div>
      </div>
      {canView || canUpdate || canDelete ? (
        <footer className="border-border-subtle flex flex-wrap items-center justify-end gap-2 border-t px-4 py-3">
          {canView ? (
            <Button variant="ghost" size="sm" onClick={onView}>
              View details <ChevronRight className="size-4" aria-hidden="true" />
            </Button>
          ) : null}
          {canUpdate ? (
            <Button variant="outline" size="sm" onClick={onEdit}>
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button variant="danger" size="sm" onClick={onDelete}>
              <Trash2 className="size-4" aria-hidden="true" /> Delete
            </Button>
          ) : null}
        </footer>
      ) : null}
    </article>
  )
}

function CaseDetails({ kase, employeeName }: { kase: DisciplinaryCase; employeeName: string }) {
  return (
    <div className="space-y-4">
      <div className="bg-surface-muted rounded-control phone:grid-cols-2 grid gap-4 p-4">
        <DetailItem label="Employee" value={employeeName} />
        <DetailItem label="Action" value={label(kase.actionType)} />
        <DetailItem label="Category" value={label(kase.violationCategory)} />
        <DetailItem label="Date of violation" value={dateLabel(kase.dateOfViolation)} />
        <DetailItem label="Action date" value={dateLabel(kase.actionDate)} />
        <DetailItem
          label="Days since violation"
          value={kase.daysSinceViolation == null ? 'Unavailable' : String(kase.daysSinceViolation)}
        />
        {kase.severancePaymentDue ? (
          <DetailItem
            label="Severance amount"
            value={
              kase.severanceAmount == null
                ? 'Amount not provided'
                : `₦${Number(kase.severanceAmount).toLocaleString('en-NG', { minimumFractionDigits: 2 })}`
            }
          />
        ) : null}
      </div>
      <DetailText label="Violation description" value={kase.violationDescription} />
      <DetailText
        label="Investigation details"
        value={kase.investigationDetails || 'No investigation details provided.'}
      />
    </div>
  )
}

function DetailItem({ label: title, value }: { label: string; value: string }) {
  return (
    <div className="min-w-0">
      <p className="text-caption text-text-secondary">{title}</p>
      <p className="text-body-sm text-text-primary mt-1 font-medium break-words">{value}</p>
    </div>
  )
}

function DetailText({ label: title, value }: { label: string; value: string }) {
  return (
    <section className="border-border-subtle rounded-control border p-4">
      <h3 className="text-label text-text-primary font-semibold">{title}</h3>
      <p className="text-body-sm text-text-secondary mt-2 break-words whitespace-pre-wrap">
        {value}
      </p>
    </section>
  )
}
