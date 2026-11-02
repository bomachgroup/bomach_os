import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  ChartNoAxesCombined,
  ChevronLeft,
  ChevronRight,
  MessageSquareText,
  Search,
  Star,
  UserRound,
} from 'lucide-react'
import { useState, type FormEvent } from 'react'

import {
  performanceReviewsApi,
  type PerformanceReview,
  type PerformanceReviewInput,
} from '@/modules/hr/performance-reviews.api'
import {
  performanceReviewsListOptions,
  performanceReviewsQueryKeys,
} from '@/modules/hr/performance-reviews.queries'
import type { PerformanceReviewsSearch } from '@/modules/hr/performance-reviews.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'

const PAGE_SIZE_OPTIONS = [10, 20, 50].map((size) => ({
  value: String(size),
  label: `${size} per page`,
}))
const RATING_FILTER_OPTIONS = [
  { value: 'all', label: 'All ratings' },
  ...[1, 2, 3, 4, 5].map((rating) => ({ value: String(rating), label: `${rating} of 5 stars` })),
]
const RATING_OPTIONS = [
  { value: '', label: 'Choose a rating' },
  ...[1, 2, 3, 4, 5].map((rating) => ({ value: String(rating), label: `${rating} of 5 stars` })),
]

type ReviewDraft = {
  employeeId: string
  reviewerId: string
  reviewDate: string
  reviewPeriod: string
  rating: string
  strengths: string
  areasForImprovement: string
  feedback: string
  employeeComment: string
}
type ReviewDraftErrors = Partial<Record<keyof ReviewDraft, string>>

function todayValue(): string {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

function emptyDraft(reviewerId = ''): ReviewDraft {
  const now = new Date()
  const quarter = Math.floor(now.getMonth() / 3) + 1
  return {
    employeeId: '',
    reviewerId,
    reviewDate: todayValue(),
    reviewPeriod: `Q${quarter} ${now.getFullYear()}`,
    rating: '',
    strengths: '',
    areasForImprovement: '',
    feedback: '',
    employeeComment: '',
  }
}

function draftFromReview(review: PerformanceReview): ReviewDraft {
  return {
    employeeId: String(review.employeeId),
    reviewerId: String(review.reviewerId),
    reviewDate: review.reviewDate,
    reviewPeriod: review.reviewPeriod,
    rating: String(review.overallRating),
    strengths: review.strengths,
    areasForImprovement: review.areasForImprovement,
    feedback: review.feedback ?? '',
    employeeComment: review.employeeComment ?? '',
  }
}

function buildInput(draft: ReviewDraft): PerformanceReviewInput {
  return {
    employee_id: Number(draft.employeeId),
    reviewer_id: Number(draft.reviewerId),
    review_date: draft.reviewDate,
    review_period: draft.reviewPeriod.trim(),
    overall_rating: Number(draft.rating),
    strengths: draft.strengths.trim(),
    areas_for_improvement: draft.areasForImprovement.trim(),
    feedback: draft.feedback.trim() || null,
    employee_comment: draft.employeeComment.trim() || null,
  }
}

function validateDraft(draft: ReviewDraft, isEditing: boolean): ReviewDraftErrors {
  const errors: ReviewDraftErrors = {}
  const employeeId = Number(draft.employeeId)
  const reviewerId = Number(draft.reviewerId)
  const rating = Number(draft.rating)
  if (!isEditing && (!Number.isInteger(employeeId) || employeeId <= 0)) {
    errors.employeeId = 'Enter a valid employee record ID.'
  }
  if (!isEditing && (!Number.isInteger(reviewerId) || reviewerId <= 0)) {
    errors.reviewerId = 'Enter a valid reviewer record ID.'
  }
  if (!isEditing && employeeId > 0 && reviewerId > 0 && employeeId === reviewerId) {
    errors.reviewerId = 'Choose a reviewer different from the employee.'
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(draft.reviewDate)) {
    errors.reviewDate = 'Choose the review date.'
  }
  if (!draft.reviewPeriod.trim()) errors.reviewPeriod = 'Enter the review period.'
  if (draft.reviewPeriod.trim().length > 50) errors.reviewPeriod = 'Use 50 characters or fewer.'
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    errors.rating = 'Choose a rating from 1 to 5.'
  }
  return errors
}

function formatDate(value: string): string {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function ReviewRating({ rating }: { rating: number }) {
  return (
    <span className="inline-flex items-center gap-1" aria-label={`${rating} of 5 stars`}>
      {Array.from({ length: 5 }, (_, index) => (
        <Star
          key={index}
          className={
            index < rating ? 'fill-warning text-warning size-4' : 'text-border-strong size-4'
          }
          aria-hidden="true"
        />
      ))}
      <span className="text-caption text-text-secondary ml-1 tabular-nums">{rating}/5</span>
    </span>
  )
}

function ReviewCard({
  review,
  onOpen,
  canView,
}: {
  review: PerformanceReview
  onOpen: () => void
  canView: boolean
}) {
  return (
    <article className="border-border-subtle bg-surface shadow-elevation-sm rounded-surface tablet:p-5 min-w-0 border p-4">
      <div className="flex min-w-0 items-start gap-3">
        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
          <UserRound className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <div className="min-w-0">
              <h3 className="text-label text-text-primary truncate font-semibold">
                {review.employeeName}
              </h3>
              <p className="text-caption text-text-secondary mt-0.5 truncate">
                Employee record #{review.employeeId} · Reviewer {review.reviewerName}
              </p>
            </div>
            <ReviewRating rating={review.overallRating} />
          </div>
          <div className="text-caption text-text-secondary mt-3 flex flex-wrap items-center gap-x-4 gap-y-1.5">
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
              {formatDate(review.reviewDate)}
            </span>
            <span className="bg-surface-muted text-text-secondary rounded-full px-2.5 py-1 font-medium">
              {review.reviewPeriod}
            </span>
          </div>
          {review.feedback?.trim() ? (
            <p className="text-body-sm text-text-secondary mt-3 line-clamp-2 leading-relaxed">
              {review.feedback}
            </p>
          ) : null}
          {canView ? (
            <div className="mt-3 flex justify-end">
              <Button variant="outline" size="sm" onClick={onOpen}>
                View review
                <ChevronRight className="size-4" aria-hidden="true" />
              </Button>
            </div>
          ) : null}
        </div>
      </div>
    </article>
  )
}

export function PerformanceReviewsPage() {
  const search = useSearch({
    from: '/_protected/hr/performance-review',
  }) as PerformanceReviewsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'performance_reviews', 'list')
  const canView = hasPermission(permissions, 'performance_reviews', 'view')
  const canCreate = hasPermission(permissions, 'performance_reviews', 'create')
  const canUpdate = hasPermission(permissions, 'performance_reviews', 'update')
  const canDelete = hasPermission(permissions, 'performance_reviews', 'delete')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const [selectedReview, setSelectedReview] = useState<PerformanceReview | null>(null)
  const [editingReview, setEditingReview] = useState<PerformanceReview | null>(null)
  const [formDraft, setFormDraft] = useState<ReviewDraft | null>(null)
  const [formErrors, setFormErrors] = useState<ReviewDraftErrors>({})
  const [formError, setFormError] = useState('')
  const [deleteReview, setDeleteReview] = useState<PerformanceReview | null>(null)
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search

  const params = {
    search: search.search,
    rating: search.rating === 'all' ? 'all' : Number(search.rating),
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
  } as const
  const listQuery = useQuery({
    ...performanceReviewsListOptions(userId, employeeKey, params),
    enabled: Boolean(session && canList),
    placeholderData: keepPreviousData,
  })
  const saveMutation = useMutation({
    mutationFn: ({ id, input }: { id: number | null; input: PerformanceReviewInput }) =>
      id === null
        ? performanceReviewsApi.create(input)
        : performanceReviewsApi.update(id, {
            review_date: input.review_date,
            review_period: input.review_period,
            overall_rating: input.overall_rating,
            strengths: input.strengths,
            areas_for_improvement: input.areas_for_improvement,
            feedback: input.feedback,
            employee_comment: input.employee_comment,
          }),
    onSuccess: async (review, variables) => {
      await queryClient.invalidateQueries({
        queryKey: performanceReviewsQueryKeys.lists(userId, employeeKey),
      })
      setFormDraft(null)
      setEditingReview(null)
      setFormErrors({})
      setFormError('')
      showToast({
        title: variables.id === null ? 'Performance review created' : 'Performance review updated',
        description: `${review.employeeName}’s ${review.reviewPeriod} review was saved.`,
        tone: 'success',
      })
    },
    onError: (error) => setFormError(presentError(error, 'form-submit').message),
  })
  const deleteMutation = useMutation({
    mutationFn: (review: PerformanceReview) => performanceReviewsApi.remove(review.id),
    onSuccess: async (_, review) => {
      await queryClient.invalidateQueries({
        queryKey: performanceReviewsQueryKeys.lists(userId, employeeKey),
      })
      setDeleteReview(null)
      setSelectedReview(null)
      showToast({
        title: 'Performance review deleted',
        description: `${review.employeeName}’s ${review.reviewPeriod} review was removed.`,
        tone: 'success',
      })
    },
  })

  const updateSearch = (updates: Partial<PerformanceReviewsSearch>) =>
    void navigate({
      to: '/hr/performance-review',
      search: (previous: PerformanceReviewsSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  const submitSearch = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  const openCreate = () => {
    setEditingReview(null)
    saveMutation.reset()
    setFormError('')
    setFormErrors({})
    setFormDraft(emptyDraft(session?.employee.id ? String(session.employee.id) : ''))
  }
  const openEdit = (review: PerformanceReview) => {
    setSelectedReview(null)
    setEditingReview(review)
    saveMutation.reset()
    setFormError('')
    setFormErrors({})
    setFormDraft(draftFromReview(review))
  }
  const submitReview = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!formDraft) return
    const errors = validateDraft(formDraft, editingReview !== null)
    setFormErrors(errors)
    setFormError('')
    if (Object.keys(errors).length) {
      requestAnimationFrame(() =>
        document.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus(),
      )
      return
    }
    saveMutation.mutate({ id: editingReview?.id ?? null, input: buildInput(formDraft) })
  }
  const updateDraft = <K extends keyof ReviewDraft>(key: K, value: ReviewDraft[K]) => {
    setFormDraft((current) => (current ? { ...current, [key]: value } : current))
    setFormErrors((current) => ({ ...current, [key]: undefined }))
    setFormError('')
    if (saveMutation.isError) saveMutation.reset()
  }

  const reviews = listQuery.data?.items ?? []
  const count = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(count / search.pageSize))
  const editing = editingReview !== null

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Performance reviews">
        <ErrorState
          title="Your HR session could not be loaded"
          description="Retry loading your account and review permissions."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  if (session && !canList) {
    return (
      <PageLayout title="Performance reviews">
        <ErrorState
          title="You can’t view performance reviews"
          description="Your account does not have permission to list employee reviews."
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Performance reviews"
      subtitle="Record employee evaluations and review the history of feedback."
      leading={<ChartNoAxesCombined className="size-5" aria-hidden="true" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            aria-label="New review"
            onClick={openCreate}
            leadingIcon={<Star className="size-4" aria-hidden="true" />}
            className="max-[360px]:size-9 max-[360px]:px-0"
          >
            <span className="max-[479px]:hidden">New review</span>
            <span className="hidden min-[361px]:inline min-[480px]:hidden">New</span>
          </Button>
        ) : undefined
      }
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Review history</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Performance register</h2>
            </div>
            <span className="bg-primary-subtle text-primary text-caption rounded-full px-3 py-1.5 font-semibold tabular-nums">
              {count} {count === 1 ? 'review' : 'reviews'}
            </span>
          </div>
          <form
            onSubmit={submitSearch}
            className="grid min-w-0 gap-3 min-[400px]:grid-cols-[minmax(0,1fr)_auto] min-[400px]:items-end"
          >
            <div className="min-w-0 space-y-1.5">
              <label
                htmlFor="performance-review-search"
                className="text-control-label text-text-secondary block font-bold"
              >
                Search reviews
              </label>
              <span className="relative block">
                <Search
                  className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
                  aria-hidden="true"
                />
                <TextInput
                  id="performance-review-search"
                  className="pl-10"
                  type="search"
                  aria-label="Search reviews"
                  maxLength={200}
                  value={searchDraft}
                  onChange={(event) =>
                    setSearchDraftState({
                      routeValue: search.search,
                      value: event.currentTarget.value,
                    })
                  }
                  placeholder="Employee, reviewer, or review period"
                />
              </span>
            </div>
            <Button
              type="submit"
              aria-label="Search"
              leadingIcon={<Search className="size-4" aria-hidden="true" />}
              className="w-full min-[400px]:w-auto"
            >
              <span className="tablet:inline min-[400px]:hidden">Search</span>
            </Button>
          </form>
          <div className="phone:flex-row phone:items-end phone:justify-between flex flex-col gap-3">
            <FormControl
              id="performance-review-rating-filter"
              label="Rating"
              className="phone:max-w-[22rem] phone:flex-1 min-w-0"
            >
              <DropdownSelect
                value={search.rating}
                options={RATING_FILTER_OPTIONS}
                onChange={(rating) =>
                  updateSearch({ rating: rating as PerformanceReviewsSearch['rating'], page: 1 })
                }
                aria-label="Filter reviews by rating"
              />
            </FormControl>
            {search.search || search.rating !== 'all' ? (
              <Button
                variant="outline"
                size="sm"
                className="self-end"
                onClick={() => {
                  setSearchDraftState({ routeValue: '', value: '' })
                  updateSearch({ search: '', rating: 'all', page: 1 })
                }}
              >
                Clear filters
              </Button>
            ) : null}
          </div>
        </Card>

        {listQuery.isPending ? (
          <div className="desktop:grid-cols-2 grid gap-3" aria-label="Loading performance reviews">
            {[0, 1, 2, 3].map((item) => (
              <Skeleton key={item} className="h-40 w-full" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <SectionErrorState
              title="Performance reviews could not be loaded"
              description="Retry the request. Your filters will stay in place."
              onRetry={() => void listQuery.refetch()}
            />
          </Card>
        ) : reviews.length === 0 ? (
          <Card>
            <EmptyState
              title={
                search.search || search.rating !== 'all'
                  ? 'No reviews match these filters'
                  : 'No performance reviews yet'
              }
              description={
                search.search || search.rating !== 'all'
                  ? 'Clear the search or choose another rating to see more reviews.'
                  : 'Completed employee evaluations will appear here.'
              }
              icon={<ChartNoAxesCombined className="size-6" aria-hidden="true" />}
              action={
                search.search || search.rating !== 'all' ? (
                  <Button
                    variant="outline"
                    onClick={() => updateSearch({ search: '', rating: 'all', page: 1 })}
                  >
                    Clear filters
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <section aria-label="Performance review records" className="space-y-3">
            {listQuery.isError ? (
              <SectionErrorState
                title="Showing saved reviews"
                description="The latest refresh failed. Retry to update this register."
                onRetry={() => void listQuery.refetch()}
              />
            ) : null}
            <div className="desktop:grid-cols-2 grid min-w-0 gap-3">
              {reviews.map((review) => (
                <ReviewCard
                  key={review.id}
                  review={review}
                  canView={canView}
                  onOpen={() => setSelectedReview(review)}
                />
              ))}
            </div>
            <Card className="flex flex-wrap items-center justify-between gap-3">
              <p className="text-caption text-text-secondary tabular-nums">
                Showing {(search.page - 1) * search.pageSize + 1}–
                {Math.min(search.page * search.pageSize, count)} of {count}
              </p>
              <div className="flex flex-wrap items-center gap-2">
                <DropdownSelect
                  value={String(search.pageSize)}
                  options={PAGE_SIZE_OPTIONS}
                  onChange={(value) =>
                    updateSearch({
                      pageSize: Number(value) as PerformanceReviewsSearch['pageSize'],
                      page: 1,
                    })
                  }
                  aria-label="Reviews per page"
                  className="min-w-36"
                />
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1}
                  onClick={() => updateSearch({ page: search.page - 1 })}
                >
                  <ChevronLeft className="size-4" aria-hidden="true" /> Previous
                </Button>
                <span className="text-caption text-text-secondary tabular-nums" aria-live="polite">
                  {search.page} / {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount}
                  onClick={() => updateSearch({ page: search.page + 1 })}
                >
                  Next <ChevronRight className="size-4" aria-hidden="true" />
                </Button>
              </div>
            </Card>
          </section>
        )}
      </div>

      <Dialog
        open={selectedReview !== null && canView}
        onOpenChange={(open) => {
          if (!open) setSelectedReview(null)
        }}
        title="Performance review"
        description={
          selectedReview
            ? `${selectedReview.employeeName} · ${selectedReview.reviewPeriod}`
            : undefined
        }
        size="lg"
        compactOnMobile
        footer={
          selectedReview ? (
            <div className="flex flex-wrap justify-end gap-2">
              <Button variant="outline" onClick={() => setSelectedReview(null)}>
                Close
              </Button>
              {canDelete ? (
                <Button
                  variant="danger"
                  onClick={() => {
                    setDeleteReview(selectedReview)
                    setSelectedReview(null)
                  }}
                >
                  Delete
                </Button>
              ) : null}
              {canUpdate ? (
                <Button onClick={() => openEdit(selectedReview)}>Edit review</Button>
              ) : null}
            </div>
          ) : undefined
        }
      >
        {selectedReview ? <ReviewDetails review={selectedReview} /> : null}
      </Dialog>

      {formDraft ? (
        <ReviewFormDialog
          draft={formDraft}
          errors={formErrors}
          error={formError}
          busy={saveMutation.isPending}
          isEditing={editing}
          onChange={updateDraft}
          onSubmit={submitReview}
          onClose={() => {
            if (!saveMutation.isPending) setFormDraft(null)
          }}
        />
      ) : null}

      <Dialog
        open={deleteReview !== null}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteReview(null)
        }}
        title="Delete performance review"
        description="This removes the review record and cannot be undone."
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          deleteReview ? (
            <div className="flex flex-wrap justify-end gap-2">
              <Button
                variant="outline"
                disabled={deleteMutation.isPending}
                onClick={() => setDeleteReview(null)}
              >
                Cancel
              </Button>
              <Button
                variant="danger"
                isLoading={deleteMutation.isPending}
                onClick={() => deleteMutation.mutate(deleteReview)}
              >
                Delete review
              </Button>
            </div>
          ) : undefined
        }
      >
        {deleteReview ? (
          <div className="space-y-3">
            {deleteMutation.isError ? (
              <Alert tone="danger" title="Review was not deleted">
                {presentError(deleteMutation.error, 'form-submit').message}
              </Alert>
            ) : null}
            <p className="text-body-sm text-text-primary">
              Delete {deleteReview.employeeName}’s {deleteReview.reviewPeriod} performance review?
            </p>
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}

function ReviewDetails({ review }: { review: PerformanceReview }) {
  return (
    <div className="space-y-4">
      <section className="border-border-subtle bg-surface shadow-elevation-sm rounded-control min-w-0 border p-4">
        <div className="phone:flex-row phone:items-center phone:justify-between flex min-w-0 flex-col gap-3">
          <div className="flex min-w-0 items-center gap-3">
            <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-xl">
              <UserRound className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <p className="text-caption text-text-secondary font-medium">Employee</p>
              <p className="text-label text-text-primary mt-0.5 font-semibold break-words">
                {review.employeeName}
              </p>
              <p className="text-caption text-text-secondary mt-0.5">Record #{review.employeeId}</p>
            </div>
          </div>
          <div className="bg-primary-subtle rounded-control phone:shrink-0 px-3 py-2">
            <p className="text-caption text-text-secondary mb-1 font-medium">Overall rating</p>
            <ReviewRating rating={review.overallRating} />
          </div>
        </div>
        <div className="border-border-subtle phone:grid-cols-2 mt-4 grid grid-cols-1 gap-x-4 gap-y-3 border-t pt-3">
          <DetailValue label="Reviewer" value={`${review.reviewerName} · #${review.reviewerId}`} />
          <DetailValue label="Review period" value={review.reviewPeriod} />
          <DetailValue label="Review date" value={formatDate(review.reviewDate)} />
        </div>
      </section>
      <div className="phone:grid-cols-2 grid grid-cols-1 gap-3">
        <ReviewText title="Strengths" value={review.strengths} />
        <ReviewText title="Areas for improvement" value={review.areasForImprovement} />
        <ReviewText title="Feedback" value={review.feedback} />
        <ReviewText title="Employee comment" value={review.employeeComment} />
      </div>
    </div>
  )
}

function DetailValue({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-caption text-text-secondary font-medium">{label}</p>
      <p className="text-body-sm text-text-primary mt-0.5 break-words">{value}</p>
    </div>
  )
}

function ReviewText({ title, value }: { title: string; value: string | null }) {
  return (
    <section className="border-border-subtle bg-surface rounded-control min-w-0 border p-3.5">
      <div className="flex items-center gap-2">
        <MessageSquareText className="text-primary size-4" aria-hidden="true" />
        <h3 className="text-label text-text-primary font-semibold">{title}</h3>
      </div>
      <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
        {value?.trim() || 'Not provided'}
      </p>
    </section>
  )
}

function ReviewFormDialog({
  draft,
  errors,
  error,
  busy,
  isEditing,
  onChange,
  onSubmit,
  onClose,
}: {
  draft: ReviewDraft
  errors: ReviewDraftErrors
  error: string
  busy: boolean
  isEditing: boolean
  onChange: <K extends keyof ReviewDraft>(key: K, value: ReviewDraft[K]) => void
  onSubmit: (event: FormEvent<HTMLFormElement>) => void
  onClose: () => void
}) {
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
      title={isEditing ? 'Edit performance review' : 'New performance review'}
      description={
        isEditing
          ? 'Update the rating and evaluation notes.'
          : 'Capture the rating, strengths, and feedback for an employee.'
      }
      size="lg"
      compactOnMobile
      dismissDisabled={busy}
      footer={
        <div className="flex flex-wrap justify-end gap-2">
          <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="performance-review-form" isLoading={busy}>
            {isEditing ? 'Save changes' : 'Create review'}
          </Button>
        </div>
      }
    >
      <form id="performance-review-form" className="space-y-4" onSubmit={onSubmit} noValidate>
        {error ? (
          <Alert tone="danger" title="Review was not saved">
            {error}
          </Alert>
        ) : null}
        <section className="bg-surface-muted border-border-subtle rounded-control tablet:p-5 space-y-4 border p-4">
          <div>
            <h3 className="text-label text-text-primary font-semibold">Review details</h3>
            <p className="text-caption text-text-secondary mt-1">
              Employee and reviewer IDs refer to employee records.
            </p>
          </div>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <FormControl
              id="review-employee-id"
              label="Employee record ID"
              required
              error={errors.employeeId}
            >
              <TextInput
                type="number"
                min={1}
                step={1}
                value={draft.employeeId}
                disabled={isEditing}
                onChange={(event) => onChange('employeeId', event.currentTarget.value)}
              />
            </FormControl>
            <FormControl
              id="review-reviewer-id"
              label="Reviewer record ID"
              required
              error={errors.reviewerId}
            >
              <TextInput
                type="number"
                min={1}
                step={1}
                value={draft.reviewerId}
                disabled={isEditing}
                onChange={(event) => onChange('reviewerId', event.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="review-date" label="Review date" required error={errors.reviewDate}>
              <DatePickerField
                value={draft.reviewDate}
                onValueChange={(value) => onChange('reviewDate', value)}
                max={todayValue()}
                aria-invalid={errors.reviewDate ? 'true' : undefined}
              />
            </FormControl>
            <FormControl
              id="review-period"
              label="Review period"
              required
              error={errors.reviewPeriod}
            >
              <TextInput
                value={draft.reviewPeriod}
                maxLength={50}
                placeholder="e.g. Q4 2026"
                onChange={(event) => onChange('reviewPeriod', event.currentTarget.value)}
              />
            </FormControl>
            <FormControl
              id="review-rating"
              label="Overall rating"
              required
              error={errors.rating}
              className="sm:col-span-2"
            >
              <DropdownSelect
                value={draft.rating}
                options={RATING_OPTIONS}
                onChange={(value) => onChange('rating', value)}
                aria-label="Overall rating"
                aria-invalid={errors.rating ? 'true' : undefined}
              />
            </FormControl>
          </div>
        </section>
        <section className="bg-surface-muted border-border-subtle rounded-control tablet:p-5 space-y-4 border p-4">
          <div>
            <h3 className="text-label text-text-primary font-semibold">Evaluation notes</h3>
            <p className="text-caption text-text-secondary mt-1">
              Add concise, specific feedback. All notes are optional.
            </p>
          </div>
          <FormControl id="review-strengths" label="Strengths">
            <TextArea
              rows={3}
              value={draft.strengths}
              onChange={(event) => onChange('strengths', event.currentTarget.value)}
            />
          </FormControl>
          <FormControl id="review-improvement" label="Areas for improvement">
            <TextArea
              rows={3}
              value={draft.areasForImprovement}
              onChange={(event) => onChange('areasForImprovement', event.currentTarget.value)}
            />
          </FormControl>
          <FormControl id="review-feedback" label="Feedback">
            <TextArea
              rows={3}
              value={draft.feedback}
              onChange={(event) => onChange('feedback', event.currentTarget.value)}
            />
          </FormControl>
          <FormControl id="review-employee-comment" label="Employee comment">
            <TextArea
              rows={3}
              value={draft.employeeComment}
              onChange={(event) => onChange('employeeComment', event.currentTarget.value)}
            />
          </FormControl>
        </section>
      </form>
    </Dialog>
  )
}
