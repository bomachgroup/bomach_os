import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Award as AwardIcon,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Medal,
  Search,
  Sparkles,
  Trash2,
  Trophy,
} from 'lucide-react'
import { useEffect, useRef, useState, type FormEvent, type ReactNode } from 'react'

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

import { recognitionApi, type Award, type AwardInput } from '../recognition.api'
import { awardDetailOptions, awardsListOptions, recognitionQueryKeys } from '../recognition.queries'
import { matchesRecognitionText, type RecognitionSearch } from '../recognition.search'
import { AwardFormDialog } from './award-form-dialog'

const PAGE_SIZES: DropdownSelectOption[] = [10, 20, 50].map((size) => ({
  value: String(size),
  label: `${size} per page`,
}))

const MONTHS = Array.from({ length: 12 }, (_, index) => ({
  value: String(index + 1),
  label: new Intl.DateTimeFormat(undefined, { month: 'long' }).format(new Date(2024, index, 1)),
}))

function awardCategoryLabel(value: string): string {
  return value
    .replace(/[_-]+/g, ' ')
    .trim()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function awardLevelLabel(value: string): string {
  return value === 'inter-state-region' ? 'Inter-state region' : awardCategoryLabel(value)
}

function awardTone(category: string): StatusTone {
  if (category.includes('excellence') || category.includes('dependable')) return 'success'
  if (category.includes('branch')) return 'info'
  if (category.includes('regional')) return 'warning'
  return 'primary'
}

function formatAwardDate(value: string, options: Intl.DateTimeFormatOptions = {}) {
  const date = new Date(`${value.slice(0, 10)}T00:00:00`)
  if (!Number.isFinite(date.getTime())) return 'Date unavailable'
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    ...options,
  }).format(date)
}

function yearOptions(): DropdownSelectOption[] {
  const year = new Date().getFullYear()
  return [
    { value: 'all', label: 'All years' },
    ...Array.from({ length: 6 }, (_, index) => ({
      value: String(year - index),
      label: String(year - index),
    })),
  ]
}

function Metric({ label, value, icon }: { label: string; value: string; icon: ReactNode }) {
  return (
    <div className="bg-surface-muted rounded-control flex min-w-0 items-center gap-3 p-3.5">
      <span className="bg-primary-subtle text-primary flex size-9 shrink-0 items-center justify-center rounded-lg">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-caption text-text-secondary leading-snug break-words">{label}</p>
        <p className="text-body-lg text-text-primary mt-0.5 font-semibold tabular-nums">{value}</p>
      </div>
    </div>
  )
}

function AwardCard({
  award,
  canView,
  canUpdate,
  canDelete,
  onView,
  onEdit,
  onDelete,
}: {
  award: Award
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
        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
          <Trophy className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <h3 className="text-body-lg text-text-primary min-w-0 flex-1 font-semibold break-words">
              {award.title}
            </h3>
            <StatusChip
              label={awardCategoryLabel(award.category)}
              tone={awardTone(award.category)}
              dense
            />
          </div>
          <div className="text-body-sm text-text-secondary mt-2 flex flex-wrap items-center gap-x-4 gap-y-1.5">
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
              {formatAwardDate(award.dateAwarded)}
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Medal className="size-4 shrink-0" aria-hidden="true" />
              {awardLevelLabel(award.rankLevel)} level
            </span>
          </div>
          {award.description ? (
            <p className="text-body-sm text-text-secondary mt-3 line-clamp-2 break-words">
              {award.description}
            </p>
          ) : null}
        </div>
      </div>
      {(canView || canUpdate || canDelete) && (
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
      )}
    </article>
  )
}

export function AwardsRecognitionPage() {
  const search = useSearch({ from: '/_protected/hr/awards-recognition' }) as RecognitionSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'awards', 'list')
  const canView = hasPermission(permissions, 'awards', 'view')
  const canCreate = hasPermission(permissions, 'awards', 'create')
  const canUpdate = hasPermission(permissions, 'awards', 'update')
  const canDelete = hasPermission(permissions, 'awards', 'delete')
  const selectedYear = search.year === 'all' ? null : Number(search.year)
  const listQuery = useQuery({
    ...awardsListOptions(userId, employeeKey, selectedYear),
    enabled: Boolean(session && canList),
  })
  const detailQuery = useQuery({
    ...awardDetailOptions(userId, employeeKey, search.award_id ?? 0),
    enabled: Boolean(session && canView && search.award_id),
  })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const [formAward, setFormAward] = useState<Award | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<Award | null>(null)
  const searchRef = useRef<HTMLButtonElement>(null)
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search

  const updateSearch = (updates: Partial<RecognitionSearch>) =>
    void navigate({
      to: '/hr/awards-recognition',
      search: (previous: RecognitionSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })

  const createMutation = useMutation({
    mutationFn: (input: AwardInput) => recognitionApi.awards.create(input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.awards })
      showToast({ tone: 'success', title: 'Award created' })
    },
  })
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: AwardInput }) =>
      recognitionApi.awards.update(id, input),
    onSuccess: async (award) => {
      queryClient.setQueryData(recognitionQueryKeys.award(userId, employeeKey, award.id), award)
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.awards })
      showToast({ tone: 'success', title: 'Award updated' })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (id: number) => recognitionApi.awards.remove(id),
    onSuccess: async (_result, id) => {
      await queryClient.invalidateQueries({ queryKey: recognitionQueryKeys.awards })
      queryClient.removeQueries({ queryKey: recognitionQueryKeys.award(userId, employeeKey, id) })
      showToast({ tone: 'success', title: 'Award deleted' })
      setDeleteTarget(null)
      if (search.award_id === id) updateSearch({ award_id: undefined })
    },
  })

  useEffect(() => {
    if (!listQuery.data || listQuery.isFetching) return
    const filtered = filterAwards(listQuery.data.items, search.search, search.month)
    const pages = Math.max(1, Math.ceil(filtered.length / search.pageSize))
    if (search.page > pages) updateSearch({ page: pages })
    // updateSearch is stable for this render and should run only when URL page/results change.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    listQuery.data,
    listQuery.isFetching,
    search.month,
    search.page,
    search.pageSize,
    search.search,
  ])

  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }

  function openForm(award: Award | null) {
    setFormAward(award)
    setFormOpen(true)
  }

  async function saveAward(input: AwardInput) {
    if (formAward) await updateMutation.mutateAsync({ id: formAward.id, input })
    else await createMutation.mutateAsync(input)
    setFormOpen(false)
    setFormAward(null)
  }

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Awards & recognition">
        <ErrorState
          title="Awards access could not be loaded"
          description="Retry loading your HR access."
        />
      </PageLayout>
    )
  }
  if (session && !canList) {
    return (
      <PageLayout title="Awards & recognition">
        <ErrorState
          title="You can’t view awards"
          description="Your account does not have permission to read award records."
        />
      </PageLayout>
    )
  }

  const awards = listQuery.data?.items ?? []
  const filteredAwards = filterAwards(awards, search.search, search.month)
  const sortedAwards = [...filteredAwards].sort((a, b) =>
    b.dateAwarded.localeCompare(a.dateAwarded),
  )
  const currentYearCount = awards.filter((award) =>
    award.dateAwarded.startsWith(String(new Date().getFullYear())),
  ).length
  const categoryCount = new Set(awards.map((award) => award.category)).size
  const pageCount = Math.max(1, Math.ceil(sortedAwards.length / search.pageSize))
  const page = Math.min(search.page, pageCount)
  const pageAwards = sortedAwards.slice((page - 1) * search.pageSize, page * search.pageSize)
  const recentAwards = awards
    .filter((award) => award.dateAwarded.startsWith(String(new Date().getFullYear())))
    .sort((a, b) => b.dateAwarded.localeCompare(a.dateAwarded))
    .slice(0, 3)
  const yearOptionsList = yearOptions()
  const monthOptions: DropdownSelectOption[] = [{ value: 'all', label: 'All months' }, ...MONTHS]
  const hasFilters = search.search.length > 0 || search.month !== 'all' || search.year !== 'all'

  return (
    <PageLayout
      title="Awards & recognition"
      subtitle="Celebrate employee achievements across the organisation."
      leading={<AwardIcon className="size-5" aria-hidden="true" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            aria-label="New award"
            onClick={() => openForm(null)}
            leadingIcon={<Sparkles className="size-4" aria-hidden="true" />}
            className="max-[360px]:size-9 max-[360px]:px-0"
          >
            <span className="max-[479px]:hidden">New award</span>
            <span className="hidden min-[361px]:inline min-[480px]:hidden">New</span>
          </Button>
        ) : undefined
      }
    >
      <div className="space-y-5">
        {listQuery.isPending && session ? (
          <Card className="tablet:p-5 space-y-4 p-4">
            <div>
              <p className="text-overline text-primary font-semibold">Recognition overview</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Awards at a glance</h2>
            </div>
            <div className="phone:grid-cols-3 grid gap-3">
              {[0, 1, 2].map((item) => (
                <Skeleton key={item} className="h-[4.6rem] w-full" />
              ))}
            </div>
          </Card>
        ) : null}
        {listQuery.data ? (
          <Card className="tablet:p-5 space-y-4 p-4">
            <div className="flex flex-wrap items-end justify-between gap-3">
              <div className="min-w-0">
                <p className="text-overline text-primary font-semibold">Recognition overview</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Awards at a glance</h2>
                <p className="text-caption text-text-secondary mt-1">
                  Yearly activity, category breadth, and awards in the current view.
                </p>
              </div>
              <span className="text-caption text-text-secondary tabular-nums">
                {listQuery.data.count} total {listQuery.data.count === 1 ? 'award' : 'awards'}
              </span>
            </div>
            <div className="phone:grid-cols-3 grid gap-3">
              <Metric
                label="Awards this year"
                value={String(currentYearCount)}
                icon={<CalendarDays className="size-4" aria-hidden="true" />}
              />
              <Metric
                label="Categories represented"
                value={String(categoryCount)}
                icon={<Medal className="size-4" aria-hidden="true" />}
              />
              <Metric
                label="Awards in view"
                value={String(filteredAwards.length)}
                icon={<Sparkles className="size-4" aria-hidden="true" />}
              />
            </div>
          </Card>
        ) : null}
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Recognition</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Award register</h2>
              <p className="text-caption text-text-secondary mt-1">
                Review recognition history and award levels.
              </p>
            </div>
            <span
              role="status"
              aria-live="polite"
              className="bg-primary-subtle text-primary text-caption rounded-full px-3 py-1.5 font-semibold tabular-nums"
            >
              {listQuery.data?.count ?? 0} {listQuery.data?.count === 1 ? 'award' : 'awards'}
            </span>
          </div>
          <form
            onSubmit={submitSearch}
            className="desktop:grid-cols-[minmax(0,1fr)_12rem_12rem_auto] grid min-w-0 gap-3"
          >
            <div className="desktop:contents grid min-w-0 gap-3 min-[400px]:grid-cols-[minmax(0,1fr)_auto] min-[400px]:items-end">
              <FormControl
                id="awards-search"
                label="Search awards"
                className="desktop:col-start-1 desktop:row-start-1 min-w-0"
              >
                <TextInput
                  value={searchDraft}
                  onChange={(event) =>
                    setSearchDraftState({
                      routeValue: search.search,
                      value: event.currentTarget.value,
                    })
                  }
                  placeholder="Award title, category, or level"
                />
              </FormControl>
              <Button
                ref={searchRef}
                type="submit"
                variant="primary"
                className="desktop:col-start-4 desktop:row-start-1 w-full min-[400px]:w-auto"
                leadingIcon={<Search className="size-4" aria-hidden="true" />}
              >
                Search
              </Button>
            </div>
            <div className="desktop:contents grid min-w-0 gap-3 min-[360px]:grid-cols-2">
              <FormControl
                id="awards-year"
                label="Award year"
                className="desktop:col-start-2 desktop:row-start-1 min-w-0"
              >
                <DropdownSelect
                  value={search.year}
                  options={yearOptionsList}
                  onChange={(year) => updateSearch({ year, page: 1 })}
                  aria-label="Filter awards by year"
                />
              </FormControl>
              <FormControl
                id="awards-month"
                label="Award month"
                className="desktop:col-start-3 desktop:row-start-1 min-w-0"
              >
                <DropdownSelect
                  value={search.month}
                  options={monthOptions}
                  onChange={(month) => updateSearch({ month, page: 1 })}
                  aria-label="Filter awards by month"
                />
              </FormControl>
            </div>
          </form>
          {hasFilters ? (
            <div className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t pt-3">
              <p className="text-caption text-text-muted">Filters apply to the award history.</p>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSearchDraftState({ routeValue: '', value: '' })
                  updateSearch({ search: '', year: 'all', month: 'all', page: 1 })
                }}
              >
                Clear filters
              </Button>
            </div>
          ) : null}
        </Card>

        {listQuery.isPending ? (
          <div className="desktop:grid-cols-2 grid gap-3" aria-label="Loading award records">
            {[0, 1, 2].map((item) => (
              <Skeleton key={item} className="h-48 w-full" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <SectionErrorState
              title="Award records could not be loaded"
              description="Retry loading the register. Your selected filters will stay in place."
              onRetry={() => void listQuery.refetch()}
            />
          </Card>
        ) : (
          <>
            {listQuery.isError ? (
              <SectionErrorState
                title="Showing saved award records"
                description="The latest update failed. Retry to refresh this history."
                onRetry={() => void listQuery.refetch()}
              />
            ) : null}
            {recentAwards.length > 0 &&
            search.year !== 'all' &&
            Number(search.year) === new Date().getFullYear() ? (
              <Card className="tablet:p-5 space-y-4 p-4">
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="text-overline text-primary font-semibold">This year</p>
                    <h2 className="text-h3 text-text-primary mt-1 font-semibold">Recent awards</h2>
                  </div>
                  <span className="text-caption text-text-secondary">
                    {recentAwards.length} latest
                  </span>
                </div>
                <div className="tablet:grid-cols-3 grid gap-3">
                  {recentAwards.map((award) => (
                    <div
                      key={award.id}
                      className="bg-primary text-text-on-primary rounded-control min-w-0 p-4"
                    >
                      <span className="flex size-9 items-center justify-center rounded-full bg-white/15">
                        <Trophy className="size-4" aria-hidden="true" />
                      </span>
                      <h3 className="text-body-sm mt-3 font-semibold break-words">{award.title}</h3>
                      <p className="text-caption mt-1 text-white/85">
                        {awardCategoryLabel(award.category)}
                      </p>
                      <p className="text-overline mt-3 text-white/75">
                        {formatAwardDate(award.dateAwarded, { month: 'short', year: 'numeric' })}
                      </p>
                    </div>
                  ))}
                </div>
              </Card>
            ) : null}
            <Card className="tablet:p-5 space-y-4 p-4">
              <div className="flex flex-wrap items-end justify-between gap-3">
                <div>
                  <p className="text-overline text-primary font-semibold">Recognition history</p>
                  <h2 className="text-h3 text-text-primary mt-1 font-semibold">All awards</h2>
                </div>
                <span className="text-caption text-text-secondary tabular-nums">
                  {filteredAwards.length} {filteredAwards.length === 1 ? 'record' : 'records'}
                </span>
              </div>
              {pageAwards.length ? (
                <div className="desktop:grid-cols-2 grid min-w-0 gap-3" aria-label="Award records">
                  {pageAwards.map((award) => (
                    <AwardCard
                      key={award.id}
                      award={award}
                      canView={canView}
                      canUpdate={canUpdate}
                      canDelete={canDelete}
                      onView={() => updateSearch({ award_id: award.id })}
                      onEdit={() => openForm(award)}
                      onDelete={() => setDeleteTarget(award)}
                    />
                  ))}
                </div>
              ) : (
                <EmptyState
                  icon={<Trophy className="size-6" aria-hidden="true" />}
                  title={awards.length ? 'No awards match these filters' : 'No awards recorded yet'}
                  description={
                    awards.length
                      ? 'Try another search or clear the selected year and month.'
                      : 'Award records will appear here once they have been created.'
                  }
                  action={
                    awards.length && hasFilters ? (
                      <Button
                        variant="outline"
                        onClick={() =>
                          updateSearch({ search: '', year: 'all', month: 'all', page: 1 })
                        }
                      >
                        Clear filters
                      </Button>
                    ) : null
                  }
                />
              )}
              {sortedAwards.length > 0 ? (
                <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-3">
                  <p className="text-caption text-text-secondary tabular-nums">
                    Showing {(page - 1) * search.pageSize + 1}–
                    {Math.min(page * search.pageSize, sortedAwards.length)} of {sortedAwards.length}
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
                      aria-label="Awards per page"
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
                      {page} / {pageCount}
                    </span>
                    <Button
                      variant="outline"
                      size="sm"
                      disabled={page >= pageCount}
                      onClick={() => updateSearch({ page: page + 1 })}
                    >
                      Next <ChevronRight className="size-4" aria-hidden="true" />
                    </Button>
                  </div>
                </div>
              ) : null}
            </Card>
          </>
        )}
      </div>

      <Dialog
        open={Boolean(search.award_id && canView)}
        onOpenChange={(open) => {
          if (!open) updateSearch({ award_id: undefined })
        }}
        title={detailQuery.data?.title ?? 'Award details'}
        description="Recognition record details"
        size="md"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => updateSearch({ award_id: undefined })}>
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
                  updateSearch({ award_id: undefined })
                }}
              >
                Edit award
              </Button>
            ) : null}
          </>
        }
      >
        {detailQuery.isPending ? (
          <Skeleton className="h-48 w-full" aria-label="Loading award details" />
        ) : null}
        {detailQuery.isError ? (
          <SectionErrorState
            title="Award details could not be loaded"
            description="The record may have been removed or your access may have changed."
            onRetry={() => void detailQuery.refetch()}
          />
        ) : null}
        {detailQuery.data ? (
          <div className="space-y-4">
            <div className="bg-surface-muted rounded-control flex flex-wrap items-center gap-2 p-4">
              <StatusChip
                label={awardCategoryLabel(detailQuery.data.category)}
                tone={awardTone(detailQuery.data.category)}
              />
              <StatusChip
                label={`${awardLevelLabel(detailQuery.data.rankLevel)} level`}
                tone="neutral"
              />
              <StatusChip
                label={formatAwardDate(detailQuery.data.dateAwarded)}
                tone="neutral"
                icon={<CalendarDays className="size-3.5" />}
              />
            </div>
            <section className="border-border-subtle rounded-control border p-4">
              <h3 className="text-label text-text-primary font-semibold">Recognition note</h3>
              <p className="text-body-sm text-text-secondary mt-2 break-words whitespace-pre-wrap">
                {detailQuery.data.description || 'No recognition note was provided.'}
              </p>
            </section>
          </div>
        ) : null}
      </Dialog>
      <AwardFormDialog
        key={formOpen ? (formAward?.id ?? 'new-award-open') : 'award-closed'}
        open={formOpen}
        award={formAward}
        saving={createMutation.isPending || updateMutation.isPending}
        onOpenChange={(open) => {
          setFormOpen(open)
          if (!open) setFormAward(null)
        }}
        onSave={saveAward}
      />
      <Dialog
        open={deleteTarget !== null}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteTarget(null)
        }}
        title="Delete award?"
        description="This action cannot be undone."
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
              Delete award
            </Button>
          </>
        }
      >
        <p className="text-body-sm text-text-secondary">
          Delete <strong className="text-text-primary">{deleteTarget?.title}</strong> from the award
          register?
        </p>
        {deleteMutation.isError ? (
          <Alert tone="danger" title="Award not deleted" role="alert" className="mt-3">
            {String(
              deleteMutation.error instanceof Error ? deleteMutation.error.message : 'Try again.',
            )}
          </Alert>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}

function filterAwards(awards: Award[], search: string, month: string): Award[] {
  return awards.filter((award) => {
    if (month !== 'all' && Number(award.dateAwarded.slice(5, 7)) !== Number(month)) return false
    return matchesRecognitionText(
      [award.title, award.category, award.rankLevel, award.description],
      search,
    )
  })
}
