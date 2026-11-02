import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Banknote,
  Building2,
  CalendarDays,
  CalendarClock,
  ChevronLeft,
  ChevronRight,
  Clock3,
  DollarSign,
  ExternalLink,
  FileText,
  GraduationCap,
  Pencil,
  Search,
  Trash2,
  Users,
} from 'lucide-react'
import { useEffect, useRef, useState, type FormEvent, type ReactNode, type RefObject } from 'react'

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
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import {
  trainingProgramsApi,
  type TrainingProgram,
  type TrainingProgramListItem,
} from '../training-programs.api'
import {
  trainingProgramDetailOptions,
  trainingProgramListOptions,
  trainingProgramsQueryKeys,
} from '../training-programs.queries'
import type { TrainingProgramsSearch } from '../training-programs.search'
import { TrainingProgramFormDialog } from './training-program-form-dialog'

const PAGE_SIZES = [10, 20, 50] as const
const STATUS_OPTIONS = [
  { value: 'all', label: 'All statuses' },
  { value: 'pending', label: 'Planned' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const AUDIENCE_OPTIONS = [
  { value: 'all', label: 'All audiences' },
  { value: 'all_employees', label: 'All employees' },
  { value: 'management', label: 'Management' },
  { value: 'new_hires', label: 'New hires' },
  { value: 'department_specific', label: 'Department specific' },
  { value: 'leadership_team', label: 'Leadership team' },
  { value: 'technical_staff', label: 'Technical staff' },
  { value: 'sales_team', label: 'Sales team' },
  { value: 'customer_service', label: 'Customer service' },
]
const AUDIENCE_LABELS = Object.fromEntries(
  AUDIENCE_OPTIONS.map(({ value, label }) => [value, label]),
)

function statusLabel(value: string) {
  return (
    STATUS_OPTIONS.find((option) => option.value === value)?.label ?? value.replaceAll('_', ' ')
  )
}

function statusTone(status: string): StatusTone {
  if (status === 'completed') return 'success'
  if (status === 'in_progress') return 'info'
  if (status === 'pending') return 'primary'
  if (status === 'cancelled') return 'neutral'
  return 'warning'
}

function dateLabel(value: string | null | undefined) {
  if (!value) return 'Not scheduled'
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function currency(value: string | number) {
  const amount = Number(value)
  return Number.isFinite(amount)
    ? `₦${new Intl.NumberFormat('en-NG', { maximumFractionDigits: 2 }).format(amount)}`
    : String(value)
}

function ProgramDetailFact({
  icon,
  label,
  value,
}: {
  icon: ReactNode
  label: string
  value: string
}) {
  return (
    <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3">
      <dt className="text-caption text-text-secondary flex items-center gap-1.5">
        <span aria-hidden="true" className="text-primary">
          {icon}
        </span>
        {label}
      </dt>
      <dd className="text-body-sm text-text-primary mt-1.5 font-semibold break-words">{value}</dd>
    </div>
  )
}

export function ProgramDetails({
  program,
  loading,
  error,
  canEdit,
  canDelete,
  onClose,
  onRetry,
  onEdit,
  returnFocusRef,
  onDelete,
}: {
  program: TrainingProgram | null
  loading: boolean
  error: unknown
  canEdit: boolean
  canDelete: boolean
  onClose: () => void
  onRetry: () => void
  onEdit: (opener: HTMLElement) => void
  returnFocusRef?: RefObject<HTMLElement | null>
  onDelete: () => void
}) {
  return (
    <Dialog
      open={Boolean(program) || loading || Boolean(error)}
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
      title={
        loading
          ? 'Loading training program'
          : error
            ? 'Program details'
            : (program?.program_name ?? 'Program details')
      }
      description="Program schedule, audience and provider information."
      size="lg"
      fitContent
      compactOnMobile
      returnFocusRef={returnFocusRef}
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
          {program && !loading && !error && canEdit ? (
            <Button variant="outline" onClick={(event) => onEdit(event.currentTarget)}>
              Edit program
            </Button>
          ) : null}
          {program && !loading && !error && canDelete ? (
            <Button variant="danger" onClick={onDelete}>
              Delete
            </Button>
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
          title="Program details could not load"
          description="Try loading the program again."
          error={error}
          action={
            <Button variant="outline" onClick={onRetry}>
              Try again
            </Button>
          }
        />
      ) : null}
      {program && !loading && !error ? (
        <div className="space-y-4">
          <div className="from-primary-subtle/65 via-primary-subtle/25 to-surface border-border-subtle rounded-surface phone:grid-cols-2 grid grid-cols-1 items-center gap-3 border bg-gradient-to-r p-3">
            <div className="flex min-w-0 items-center gap-2">
              <span className="bg-surface text-primary rounded-control flex size-9 shrink-0 items-center justify-center shadow-sm">
                <GraduationCap className="size-4.5" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-text-secondary mb-1">Program status</p>
                <StatusChip
                  dense
                  label={statusLabel(program.status)}
                  tone={statusTone(program.status)}
                />
              </div>
            </div>
            <div className="min-w-0">
              <p className="text-overline text-text-secondary mb-1">Audience</p>
              <StatusChip
                dense
                label={AUDIENCE_LABELS[program.target_audience] ?? program.target_audience}
                tone="neutral"
                icon={<Users className="size-3.5" />}
              />
            </div>
          </div>
          <section aria-labelledby="training-program-facts-heading">
            <h3
              id="training-program-facts-heading"
              className="text-label text-text-primary flex items-center gap-2 font-semibold"
            >
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <CalendarClock className="size-4" />
              </span>
              Schedule and investment
            </h3>
            <dl className="tablet:grid-cols-3 mt-2.5 grid grid-cols-2 gap-2.5">
              <ProgramDetailFact
                icon={<Building2 className="size-3.5" />}
                label="Provider"
                value={program.provider?.trim() || 'Not specified'}
              />
              <ProgramDetailFact
                icon={<Clock3 className="size-3.5" />}
                label="Duration"
                value={`${program.duration_days} ${program.duration_days === 1 ? 'day' : 'days'}`}
              />
              <ProgramDetailFact
                icon={<CalendarDays className="size-3.5" />}
                label="Start date"
                value={dateLabel(program.start_date)}
              />
              <ProgramDetailFact
                icon={<CalendarDays className="size-3.5" />}
                label="End date"
                value={dateLabel(program.end_date)}
              />
              <ProgramDetailFact
                icon={<Banknote className="size-3.5" />}
                label="Program cost"
                value={currency(program.cost)}
              />
              <ProgramDetailFact
                icon={<CalendarClock className="size-3.5" />}
                label="Created"
                value={dateLabel(program.created_at)}
              />
            </dl>
          </section>
          <section className="border-border-subtle rounded-control border p-3.5">
            <h3 className="text-label text-text-primary flex items-center gap-2 font-semibold">
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <FileText className="size-4" />
              </span>
              Program overview
            </h3>
            <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
              {program.description?.trim() || 'No description has been added.'}
            </p>
          </section>
        </div>
      ) : null}
    </Dialog>
  )
}

export function TrainingProgramsPage() {
  const search = useSearch({ from: '/_protected/hr/training-program' }) as TrainingProgramsSearch
  const navigate = useNavigate({ from: '/_protected/hr/training-program' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'training_programs', 'list')
  const canView = hasPermission(permissions, 'training_programs', 'view')
  const canCreate = hasPermission(permissions, 'training_programs', 'create')
  const canUpdate = hasPermission(permissions, 'training_programs', 'update')
  const canDelete = hasPermission(permissions, 'training_programs', 'delete')
  const [draftState, setDraftState] = useState({ routeValue: search.search, value: search.search })
  const searchDraft = draftState.routeValue === search.search ? draftState.value : search.search
  const [editorOpen, setEditorOpen] = useState(false)
  const [editorInstance, setEditorInstance] = useState(0)
  const [editingProgram, setEditingProgram] = useState<TrainingProgram | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<TrainingProgram | null>(null)
  const editorReturnFocusRef = useRef<HTMLElement | null>(null)
  const detailsReturnFocusRef = useRef<HTMLElement | null>(null)

  function openEditor(program: TrainingProgram | null, opener: HTMLElement | null) {
    editorReturnFocusRef.current = opener
    setEditingProgram(program)
    setEditorInstance((instance) => instance + 1)
    setEditorOpen(true)
  }

  function updateSearch(updates: Partial<TrainingProgramsSearch>) {
    void navigate({
      to: '/hr/training-program',
      search: (previous: TrainingProgramsSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }
  function commitSearch(event: FormEvent) {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  const params = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: search.search,
    status: search.status,
    audience: search.audience,
  }
  const listQuery = useQuery({
    ...trainingProgramListOptions(userId, employeeId, params),
    enabled: Boolean(session && canList),
    placeholderData: keepPreviousData,
  })
  const selectedId = search.program_id ?? 0
  const detailQuery = useQuery({
    ...trainingProgramDetailOptions(userId, employeeId, selectedId),
    enabled: Boolean(selectedId && canView),
  })
  const createMutation = useMutation({ mutationFn: trainingProgramsApi.create })
  const updateMutation = useMutation({
    mutationFn: ({
      id,
      input,
    }: {
      id: number
      input: Parameters<typeof trainingProgramsApi.update>[1]
    }) => trainingProgramsApi.update(id, input),
  })
  const deleteMutation = useMutation({ mutationFn: trainingProgramsApi.delete })
  const saving = createMutation.isPending || updateMutation.isPending

  async function invalidate() {
    await queryClient.invalidateQueries({
      queryKey: trainingProgramsQueryKeys.scoped(userId, employeeId),
    })
  }
  async function saveProgram(input: Parameters<typeof trainingProgramsApi.create>[0]) {
    if (editingProgram) {
      await updateMutation.mutateAsync({ id: editingProgram.id, input })
      showToast({
        title: 'Training program updated',
        description: 'Your changes have been saved.',
        tone: 'success',
      })
    } else {
      const created = await createMutation.mutateAsync(input)
      updateSearch({ program_id: canView ? created.id : undefined, page: 1 })
      showToast({
        title: 'Training program created',
        description: 'The program is now in the register.',
        tone: 'success',
      })
    }
    await invalidate()
    setEditorOpen(false)
  }
  async function removeProgram() {
    if (!deleteTarget) return
    try {
      await deleteMutation.mutateAsync(deleteTarget.id)
      await invalidate()
      if (search.program_id === deleteTarget.id) updateSearch({ program_id: undefined })
      showToast({
        title: 'Training program deleted',
        description: 'The program was removed.',
        tone: 'success',
      })
      setDeleteTarget(null)
    } catch (error) {
      showToast({
        title: 'Program could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      })
    }
  }

  const items = listQuery.data?.items ?? []
  const total = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(total / search.pageSize))
  useEffect(() => {
    if (!listQuery.data || search.page <= pageCount) return
    void navigate({
      to: '/hr/training-program',
      search: (previous: TrainingProgramsSearch) => ({ ...previous, page: pageCount }),
      resetScroll: false,
    })
  }, [listQuery.data, navigate, pageCount, search.page])
  const filtersActive = Boolean(
    search.search || search.status !== 'all' || search.audience !== 'all',
  )
  const currentProgram = detailQuery.data
  const canOpenSelected = Boolean(selectedId && canView)

  if (sessionQuery.isPending)
    return (
      <PageLayout title="Training programs" subtitle="Plan and track employee learning.">
        <Card className="space-y-3" aria-busy="true">
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} variant="row" />
          ))}
        </Card>
      </PageLayout>
    )
  if (sessionQuery.isError || !session)
    return (
      <PageLayout title="Training programs">
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
      title="Training programs"
      subtitle="Plan learning programs and follow their schedule, audience and investment."
      leading={<GraduationCap className="size-[18px]" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            title="Create training program"
            aria-label="Create training program"
            leadingIcon={<GraduationCap className="size-4" />}
            onClick={(event) => openEditor(null, event.currentTarget)}
          >
            <span className="hidden min-[480px]:inline">New program</span>
            <span className="hidden min-[361px]:inline min-[480px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-2">
            <div>
              <p className="text-overline text-primary font-semibold">Learning & development</p>
              <h2 className="text-h3 mt-1 font-semibold">Program register</h2>
            </div>
            <p className="text-caption text-text-secondary" aria-live="polite">
              {listQuery.isPending && !listQuery.data
                ? 'Loading programs'
                : `${total} ${total === 1 ? 'program' : 'programs'}`}
            </p>
          </div>
          <form
            onSubmit={commitSearch}
            className="grid grid-cols-[minmax(0,1fr)_auto] items-end gap-3"
          >
            <FormControl id="training-search" label="Search programs" className="min-w-0">
              <span className="relative block">
                <Search className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2" />
                <TextInput
                  className="pl-10"
                  type="search"
                  maxLength={200}
                  placeholder="Program name or provider"
                  value={searchDraft}
                  onChange={(event) =>
                    setDraftState({ routeValue: search.search, value: event.currentTarget.value })
                  }
                />
              </span>
            </FormControl>
            <Button
              type="submit"
              aria-label="Apply search"
              size="icon"
              className="phone:h-11 phone:w-auto phone:px-4 shrink-0"
              leadingIcon={<Search className="size-4" />}
            >
              <span className="phone:inline hidden">Apply search</span>
            </Button>
          </form>
          <div className="phone:grid-cols-2 grid gap-3">
            <FormControl id="training-status-filter" label="Program status">
              <DropdownSelect
                value={search.status}
                options={STATUS_OPTIONS}
                onChange={(value) =>
                  updateSearch({ status: value as TrainingProgramsSearch['status'], page: 1 })
                }
              />
            </FormControl>
            <FormControl id="training-audience-filter" label="Audience">
              <DropdownSelect
                value={search.audience}
                options={AUDIENCE_OPTIONS}
                searchable
                onChange={(value) =>
                  updateSearch({ audience: value as TrainingProgramsSearch['audience'], page: 1 })
                }
              />
            </FormControl>
          </div>
          {filtersActive ? (
            <div className="flex justify-end">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setDraftState({ routeValue: '', value: '' })
                  updateSearch({
                    search: '',
                    status: 'all',
                    audience: 'all',
                    page: 1,
                  })
                }}
              >
                Clear filters
              </Button>
            </div>
          ) : null}
        </Card>

        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" title="Showing saved programs">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>The latest refresh failed. Previously loaded programs remain available.</span>
              <Button size="sm" variant="outline" onClick={() => void listQuery.refetch()}>
                Retry refresh
              </Button>
            </div>
          </Alert>
        ) : null}
        {listQuery.isPending && !listQuery.data ? (
          <Card className="space-y-3" aria-busy="true" aria-label="Loading training programs">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} variant="row" />
            ))}
          </Card>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <ErrorState
              title="Training programs could not load"
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
              icon={<GraduationCap className="size-6" />}
              title={filtersActive ? 'No programs match these filters' : 'No training programs yet'}
              description={
                filtersActive
                  ? 'Change or clear the filters to see other programs.'
                  : 'Create a program to start tracking employee learning.'
              }
              action={
                filtersActive ? (
                  <Button
                    variant="outline"
                    onClick={() =>
                      updateSearch({
                        search: '',
                        status: 'all',
                        audience: 'all',
                        page: 1,
                      })
                    }
                  >
                    Clear filters
                  </Button>
                ) : canCreate ? (
                  <Button
                    leadingIcon={<GraduationCap className="size-4" />}
                    onClick={(event) => openEditor(null, event.currentTarget)}
                  >
                    Create program
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <div className="desktop:grid-cols-2 grid min-w-0 gap-3">
            {items.map((program: TrainingProgramListItem) => (
              <Card key={program.id} className="min-w-0 p-0">
                <article className="desktop:p-5 grid min-w-0 gap-4 p-4">
                  <div className="flex min-w-0 items-start gap-3">
                    <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                      <GraduationCap className="size-5" />
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="flex min-w-0 items-start justify-between gap-3">
                        <h3 className="text-label text-text-primary min-w-0 flex-1 font-semibold break-words">
                          {program.program_name}
                        </h3>
                        <StatusChip
                          dense
                          label={statusLabel(program.status)}
                          tone={statusTone(program.status)}
                          className="shrink-0"
                        />
                      </div>
                      <div className="text-body-sm text-text-secondary mt-1 flex flex-wrap items-center gap-x-2 gap-y-1">
                        {program.provider ? <span>{program.provider}</span> : null}
                        {program.provider ? <span aria-hidden="true">·</span> : null}
                        <span>
                          {AUDIENCE_LABELS[program.target_audience] ?? program.target_audience}
                        </span>
                      </div>
                      <div className="text-caption text-text-muted mt-2 flex flex-wrap gap-x-4 gap-y-1">
                        <span className="inline-flex items-center gap-1.5">
                          <CalendarDays className="size-3.5" />
                          {dateLabel(program.start_date)} – {dateLabel(program.end_date)}
                        </span>
                        <span className="inline-flex items-center gap-1.5">
                          <Clock3 className="size-3.5" />
                          {program.duration_days} {program.duration_days === 1 ? 'day' : 'days'}
                        </span>
                        <span className="inline-flex items-center gap-1.5">
                          <DollarSign className="size-3.5" />
                          {currency(program.cost)}
                        </span>
                      </div>
                    </div>
                  </div>
                  <div className="border-border-subtle flex flex-wrap justify-end gap-2 border-t pt-3">
                    {canView ? (
                      <Button
                        size="sm"
                        variant="outline"
                        aria-label={`View ${program.program_name}`}
                        onClick={(event) => {
                          detailsReturnFocusRef.current = event.currentTarget
                          updateSearch({ program_id: program.id })
                        }}
                        leadingIcon={<ExternalLink className="size-4" />}
                      >
                        View
                      </Button>
                    ) : null}
                    {canView && canUpdate ? (
                      <Button
                        size="sm"
                        variant="outline"
                        aria-label={`Edit ${program.program_name}`}
                        leadingIcon={<Pencil className="size-4" />}
                        onClick={(event) => {
                          const opener = event.currentTarget
                          void queryClient
                            .ensureQueryData(
                              trainingProgramDetailOptions(userId, employeeId, program.id),
                            )
                            .then((record) => {
                              openEditor(record, opener)
                            })
                            .catch((error) =>
                              showToast({
                                title: 'Program could not load for editing',
                                description: presentError(error, 'background-action').message,
                                tone: 'danger',
                              }),
                            )
                        }}
                      >
                        Edit
                      </Button>
                    ) : null}
                    {canDelete ? (
                      <Button
                        size="sm"
                        variant="danger"
                        aria-label={`Delete ${program.program_name}`}
                        leadingIcon={<Trash2 className="size-4" />}
                        onClick={() => {
                          void queryClient
                            .ensureQueryData(
                              trainingProgramDetailOptions(userId, employeeId, program.id),
                            )
                            .then(setDeleteTarget)
                            .catch((error) =>
                              showToast({
                                title: 'Program could not load',
                                description: presentError(error, 'background-action').message,
                                tone: 'danger',
                              }),
                            )
                        }}
                      >
                        Delete
                      </Button>
                    ) : null}
                  </div>
                </article>
              </Card>
            ))}
          </div>
        )}
        {items.length > 0 ? (
          <Card className="flex flex-wrap items-center justify-between gap-3 p-3">
            <p className="text-caption text-text-secondary" aria-live="polite">
              {total
                ? `${(search.page - 1) * search.pageSize + 1}–${Math.min(search.page * search.pageSize, total)} of ${total}`
                : '0 programs'}
            </p>
            <div className="flex items-center gap-2">
              <DropdownSelect
                aria-label="Programs per page"
                value={String(search.pageSize)}
                options={PAGE_SIZES.map((size) => ({
                  value: String(size),
                  label: `${size} per page`,
                }))}
                onChange={(value) =>
                  updateSearch({
                    pageSize: Number(value) as TrainingProgramsSearch['pageSize'],
                    page: 1,
                  })
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

      <TrainingProgramFormDialog
        key={editorInstance}
        open={editorOpen}
        onOpenChange={(open) => {
          setEditorOpen(open)
        }}
        program={editingProgram}
        saving={saving}
        onSave={saveProgram}
        returnFocusRef={editorReturnFocusRef}
      />
      <ProgramDetails
        program={canOpenSelected ? (currentProgram ?? null) : null}
        loading={canOpenSelected && (detailQuery.isPending || detailQuery.isFetching)}
        error={canOpenSelected ? detailQuery.error : undefined}
        canEdit={canUpdate}
        canDelete={canDelete}
        onClose={() => updateSearch({ program_id: undefined })}
        onRetry={() => void detailQuery.refetch()}
        onEdit={(opener) => {
          if (currentProgram) {
            openEditor(currentProgram, detailsReturnFocusRef.current ?? opener)
            updateSearch({ program_id: undefined })
          }
        }}
        returnFocusRef={detailsReturnFocusRef}
        onDelete={() => {
          if (currentProgram) setDeleteTarget(currentProgram)
        }}
      />
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteTarget(null)
        }}
        title="Delete training program"
        description="This will permanently remove the program from the register."
        size="sm"
        fitContent
        compactOnMobile
        bodyClassName="space-y-3"
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
              onClick={() => void removeProgram()}
            >
              Delete program
            </Button>
          </>
        }
      >
        {deleteTarget ? (
          <div className="space-y-3">
            <p className="text-body-sm">
              Delete <strong>{deleteTarget.program_name}</strong>?
            </p>
            {deleteMutation.isError ? (
              <Alert tone="danger" title="Program not deleted">
                {presentError(deleteMutation.error, 'background-action').message}
              </Alert>
            ) : null}
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}
