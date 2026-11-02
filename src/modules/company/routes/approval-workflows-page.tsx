import { useCallback, useEffect, useMemo, useRef, useState, type FormEvent } from 'react'
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowDown,
  ArrowUp,
  Check,
  ChevronLeft,
  ChevronRight,
  Clock3,
  FileCheck2,
  Plus,
  Search,
  UserRound,
  Workflow,
  X,
} from 'lucide-react'

import {
  approvalWorkflowsApi,
  approvalWorkflowsQueryKeys,
  type ApprovalWorkflowDto,
  type ApprovalWorkflowInput,
} from '@/modules/company/approval-workflows.api'
import {
  approvalRequestsApi,
  approvalRequestsQueryKeys,
  companyOverviewQueryKey,
  type ApprovalRequestDto,
  type ApprovalRequestStatus,
} from '@/modules/company/company-dashboard.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type { ApprovalWorkflowsSearch } from '../approval-workflows.search'

const PAGE_SIZE = 10
const statusOptions = [
  { value: 'all', label: 'All requests' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'cancelled', label: 'Cancelled' },
]

function formatDate(value: string) {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(date)
}

function requestTone(status: ApprovalRequestStatus): StatusTone {
  if (status === 'pending') return 'warning'
  if (status === 'approved') return 'success'
  if (status === 'rejected') return 'danger'
  return 'neutral'
}

function WorkflowForm({
  value,
  actionTypes,
  levels,
  pending,
  onCancel,
  onSubmit,
}: {
  value?: ApprovalWorkflowDto
  actionTypes: { value: string; label: string }[]
  levels: { value: string; label: string }[]
  pending: boolean
  onCancel: () => void
  onSubmit: (input: ApprovalWorkflowInput) => void
}) {
  const [name, setName] = useState(value?.name ?? '')
  const [description, setDescription] = useState(value?.description ?? '')
  const [actionType, setActionType] = useState(value?.action_type ?? actionTypes[0]?.value ?? '')
  const [steps, setSteps] = useState(
    () =>
      value?.steps.map(({ step_name, required_level }) => ({ step_name, required_level })) ?? [
        { step_name: '', required_level: levels[0]?.value ?? '' },
      ],
  )
  const [error, setError] = useState<string | null>(null)

  function updateStep(index: number, field: 'step_name' | 'required_level', next: string) {
    setSteps((current) =>
      current.map((step, stepIndex) => (stepIndex === index ? { ...step, [field]: next } : step)),
    )
  }
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!steps.length || steps.some((step) => !step.step_name.trim() || !step.required_level)) {
      setError('Add at least one complete approval step. Each step needs a name and level.')
      document.querySelector<HTMLInputElement>('[data-step-name="empty"]')?.focus()
      return
    }
    setError(null)
    onSubmit({
      name: name.trim(),
      description: description.trim(),
      action_type: actionType,
      steps: steps.map((step, index) => ({
        step_order: index + 1,
        step_name: step.step_name.trim(),
        required_level: step.required_level,
      })),
    })
  }

  return (
    <form onSubmit={submit} className="space-y-4">
      {error ? (
        <Alert role="alert" tone="danger" title="Complete the workflow steps">
          {error}
        </Alert>
      ) : null}
      <FormSection aria-labelledby="workflow-details-heading" className="space-y-4">
        <div>
          <h3 id="workflow-details-heading" className="text-label text-text-primary font-semibold">
            Workflow details
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Set the request type and give this approval route a clear name.
          </p>
        </div>
        <div className="phone:grid-cols-2 grid gap-4">
          <FormControl id="workflow-name" label="Workflow name" required>
            <TextInput
              id="workflow-name"
              value={name}
              onChange={(event) => setName(event.target.value)}
              required
              maxLength={200}
            />
          </FormControl>
          <FormControl id="workflow-action" label="Action type" required>
            <DropdownSelect
              id="workflow-action"
              value={actionType}
              options={actionTypes}
              onChange={setActionType}
            />
          </FormControl>
          <FormControl
            id="workflow-description"
            label="Description"
            description="Optional context for administrators managing this route."
            className="phone:col-span-2"
          >
            <TextArea
              id="workflow-description"
              value={description}
              onChange={(event) => setDescription(event.target.value)}
              rows={3}
            />
          </FormControl>
        </div>
      </FormSection>

      <FormSection aria-labelledby="workflow-steps-heading" className="space-y-3">
        <div className="flex flex-wrap items-end justify-between gap-2">
          <div>
            <h3 id="workflow-steps-heading" className="text-label text-text-primary font-semibold">
              Approval sequence
            </h3>
            <p className="text-caption text-text-secondary mt-1">
              Arrange steps in the order the request should pass through.
            </p>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() =>
              setSteps((current) => [
                ...current,
                { step_name: '', required_level: levels[0]?.value ?? '' },
              ])
            }
            leadingIcon={<Plus className="size-4" aria-hidden="true" />}
          >
            Add step
          </Button>
        </div>
        {steps.map((step, index) => (
          <div
            key={index}
            className="border-border-subtle bg-surface-muted/50 rounded-control phone:grid-cols-[auto_minmax(0,1fr)_minmax(0,0.8fr)_auto] phone:items-end grid gap-3 border p-3"
          >
            <span className="bg-primary-subtle text-primary rounded-pill text-caption flex size-8 items-center justify-center font-semibold">
              {String(index + 1).padStart(2, '0')}
            </span>
            <FormControl id={`workflow-step-${index}`} label="Step name" required>
              <TextInput
                data-step-name={step.step_name ? undefined : 'empty'}
                id={`workflow-step-${index}`}
                value={step.step_name}
                onChange={(event) => updateStep(index, 'step_name', event.target.value)}
                placeholder="e.g. Department review"
                maxLength={120}
                required
              />
            </FormControl>
            <FormControl id={`workflow-level-${index}`} label="Required level" required>
              <DropdownSelect
                id={`workflow-level-${index}`}
                value={step.required_level}
                options={levels}
                onChange={(next) => updateStep(index, 'required_level', next)}
              />
            </FormControl>
            <div className="phone:pb-0.5 flex justify-end gap-1">
              <Button
                variant="ghost"
                size="icon"
                aria-label={`Move step ${index + 1} up`}
                disabled={index === 0}
                onClick={() =>
                  setSteps((current) => {
                    const next = [...current]
                    ;[next[index - 1], next[index]] = [next[index], next[index - 1]]
                    return next
                  })
                }
              >
                <ArrowUp className="size-4" aria-hidden="true" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                aria-label={`Move step ${index + 1} down`}
                disabled={index === steps.length - 1}
                onClick={() =>
                  setSteps((current) => {
                    const next = [...current]
                    ;[next[index + 1], next[index]] = [next[index], next[index + 1]]
                    return next
                  })
                }
              >
                <ArrowDown className="size-4" aria-hidden="true" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                aria-label={`Remove step ${index + 1}`}
                disabled={steps.length === 1}
                onClick={() =>
                  setSteps((current) => current.filter((_, stepIndex) => stepIndex !== index))
                }
              >
                <X className="size-4" aria-hidden="true" />
              </Button>
            </div>
          </div>
        ))}
      </FormSection>
      <div className="border-border-subtle flex flex-wrap justify-end gap-2 border-t pt-4">
        <Button variant="outline" onClick={onCancel} disabled={pending}>
          Cancel
        </Button>
        <Button type="submit" isLoading={pending}>
          {value ? 'Save workflow' : 'Create workflow'}
        </Button>
      </div>
    </form>
  )
}

function Pagination({
  page,
  count,
  onPage,
}: {
  page: number
  count: number
  onPage: (page: number) => void
}) {
  const pages = Math.max(1, Math.ceil(count / PAGE_SIZE))
  return (
    <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary">
        {count
          ? `${(page - 1) * PAGE_SIZE + 1}–${Math.min(page * PAGE_SIZE, count)} of ${count}`
          : '0 records'}
      </p>
      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          aria-label="Previous page"
          disabled={page <= 1}
          onClick={() => onPage(page - 1)}
          leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
        >
          Previous
        </Button>
        <span className="text-caption text-text-secondary min-w-16 text-center">
          {page} / {pages}
        </span>
        <Button
          variant="outline"
          size="sm"
          aria-label="Next page"
          disabled={page >= pages}
          onClick={() => onPage(page + 1)}
        >
          Next <ChevronRight className="size-4" aria-hidden="true" />
        </Button>
      </div>
    </div>
  )
}

export function ApprovalWorkflowsPage() {
  const search = useSearch({
    from: '/_protected/company/approval-workflow',
  }) as ApprovalWorkflowsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canListFlows = hasPermission(permissions, 'approval_flows', 'list')
  const canListRequests = hasPermission(permissions, 'approval_requests', 'list')
  const canCreate = hasPermission(permissions, 'approval_flows', 'create')
  const canUpdate = hasPermission(permissions, 'approval_flows', 'update')
  const canDeactivate = hasPermission(permissions, 'approval_flows', 'delete')
  const canApprove = hasPermission(permissions, 'approval_requests', 'approve')
  const canReject = hasPermission(permissions, 'approval_requests', 'reject')
  const availableTabs = useMemo(
    () => [
      ...(canListFlows
        ? [{ value: 'workflows' as const, label: 'Workflows', icon: Workflow }]
        : []),
      ...(canListRequests
        ? [{ value: 'requests' as const, label: 'Approval requests', icon: FileCheck2 }]
        : []),
    ],
    [canListFlows, canListRequests],
  )
  const activeTab = availableTabs.some(({ value }) => value === search.tab)
    ? search.tab
    : (availableTabs[0]?.value ?? 'workflows')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search
  const [workflowEditor, setWorkflowEditor] = useState<ApprovalWorkflowDto | 'new' | null>(null)
  const [workflowDetail, setWorkflowDetail] = useState<ApprovalWorkflowDto | null>(null)
  const [deactivateTarget, setDeactivateTarget] = useState<ApprovalWorkflowDto | null>(null)
  const [requestDetail, setRequestDetail] = useState<ApprovalRequestDto | null>(null)
  const [rejectTarget, setRejectTarget] = useState<ApprovalRequestDto | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [rejectionError, setRejectionError] = useState<string | null>(null)
  const rejectionRef = useRef<HTMLTextAreaElement | null>(null)
  const params = useMemo(
    () => ({ limit: PAGE_SIZE, offset: (search.page - 1) * PAGE_SIZE, search: search.search }),
    [search.page, search.search],
  )
  const flowQuery = useQuery({
    queryKey: approvalWorkflowsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => approvalWorkflowsApi.list(params, signal),
    enabled: Boolean(session && activeTab === 'workflows' && canListFlows),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const requestParams = useMemo(
    () => ({
      status: search.status,
      search: search.search,
      limit: PAGE_SIZE,
      offset: (search.page - 1) * PAGE_SIZE,
    }),
    [search.page, search.search, search.status],
  )
  const requestsQuery = useQuery({
    queryKey: approvalRequestsQueryKeys.list(userId, employeeId, requestParams),
    queryFn: ({ signal }) => approvalRequestsApi.list(requestParams, signal),
    enabled: Boolean(session && activeTab === 'requests' && canListRequests),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const choicesQuery = useQuery({
    queryKey: approvalWorkflowsQueryKeys.choices(userId, employeeId),
    queryFn: ({ signal }) => approvalWorkflowsApi.choices(signal),
    enabled: Boolean(session && workflowEditor),
    staleTime: DATA_FRESHNESS_MS.reference,
  })

  useEffect(() => {
    if (availableTabs.length && !availableTabs.some(({ value }) => value === search.tab)) {
      void navigate({
        to: '/company/approval-workflow',
        search: { ...search, tab: availableTabs[0].value, page: 1 },
        replace: true,
        resetScroll: false,
      })
    }
  }, [availableTabs, navigate, search])

  const updateSearch = useCallback(
    (updates: Partial<ApprovalWorkflowsSearch>, replace = false) => {
      void navigate({
        to: '/company/approval-workflow',
        search: (previous: ApprovalWorkflowsSearch) => ({ ...previous, ...updates }),
        replace,
        resetScroll: false,
      })
    },
    [navigate],
  )
  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  const invalidateFlows = async () =>
    queryClient.invalidateQueries({
      queryKey: approvalWorkflowsQueryKeys.lists(userId, employeeId),
    })
  const invalidateRequestData = async () =>
    Promise.all([
      queryClient.invalidateQueries({
        queryKey: approvalRequestsQueryKeys.lists(userId, employeeId),
      }),
      queryClient.invalidateQueries({ queryKey: companyOverviewQueryKey(userId, employeeId) }),
    ])

  const saveWorkflow = useMutation({
    mutationFn: (input: ApprovalWorkflowInput) =>
      workflowEditor && workflowEditor !== 'new'
        ? approvalWorkflowsApi.update(workflowEditor.id, input)
        : approvalWorkflowsApi.create(input),
    onSuccess: async () => {
      await invalidateFlows()
      setWorkflowEditor(null)
      showToast({
        title: workflowEditor && workflowEditor !== 'new' ? 'Workflow updated' : 'Workflow created',
        description: 'The approval flow register has been refreshed.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Workflow could not be saved',
        description: presentError(error, 'form-submit').message,
        tone: 'danger',
      }),
  })
  const deactivateWorkflow = useMutation({
    mutationFn: (id: number) => approvalWorkflowsApi.deactivate(id),
    onSuccess: async () => {
      await invalidateFlows()
      setDeactivateTarget(null)
      showToast({
        title: 'Workflow deactivated',
        description: 'New requests can no longer use this workflow.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Workflow could not be deactivated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const activateWorkflow = useMutation({
    mutationFn: (id: number) => approvalWorkflowsApi.update(id, { is_active: true }),
    onSuccess: async () => {
      await invalidateFlows()
      showToast({
        title: 'Workflow activated',
        description: 'It is available for new requests.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Workflow could not be activated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const approveRequest = useMutation({
    mutationFn: (id: number) => approvalRequestsApi.approve(id),
    onSuccess: async (result) => {
      await invalidateRequestData()
      setRequestDetail(null)
      showToast({
        title: result.status === 'approved' ? 'Request approved' : 'Approval recorded',
        description:
          result.status === 'approved'
            ? 'All approval steps have been completed.'
            : `The request is now awaiting ${result.pending_step_name || `step ${result.current_step}`}.`,
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Approval could not be recorded',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const rejectRequest = useMutation({
    mutationFn: ({ id, comment }: { id: number; comment: string }) =>
      approvalRequestsApi.reject(id, comment),
    onSuccess: async () => {
      await invalidateRequestData()
      setRejectTarget(null)
      setRequestDetail(null)
      setRejectionReason('')
      setRejectionError(null)
      showToast({
        title: 'Request rejected',
        description: 'The decision and reason have been recorded.',
        tone: 'success',
      })
    },
    onError: (error) => {
      setRejectionError(presentError(error, 'form-submit').message)
      rejectionRef.current?.focus()
    },
  })

  const flows = flowQuery.data?.items ?? []
  const requests = requestsQuery.data?.items ?? []
  const activeListCount =
    activeTab === 'workflows' ? flowQuery.data?.count : requestsQuery.data?.count
  useEffect(() => {
    if (activeListCount === undefined) return
    const lastPage = Math.max(1, Math.ceil(activeListCount / PAGE_SIZE))
    if (search.page > lastPage) updateSearch({ page: lastPage }, true)
  }, [activeListCount, activeTab, search.page, updateSearch])
  const headerAction =
    activeTab === 'workflows' && canCreate ? (
      <Button
        onClick={() => setWorkflowEditor('new')}
        aria-label="New workflow"
        leadingIcon={<Plus className="size-4" aria-hidden="true" />}
      >
        <span className="phone:hidden max-[361px]:hidden">New</span>
        <span className="phone:inline hidden">New workflow</span>
      </Button>
    ) : null

  return (
    <PageLayout
      title="Approval workflows"
      subtitle="Define the approval routes used to review company requests."
      actions={headerAction}
      actionsInline
    >
      <div className="space-y-5">
        <Card className="p-2">
          <div
            className="phone:grid-cols-2 grid gap-1"
            role="tablist"
            aria-label="Approval workflow sections"
          >
            {availableTabs.map(({ value, label, icon: Icon }) => (
              <button
                key={value}
                type="button"
                role="tab"
                aria-selected={activeTab === value}
                onClick={() => updateSearch({ tab: value, page: 1 })}
                className={`rounded-control focus-visible:shadow-focus-ring text-label flex min-h-11 items-center justify-center gap-2 px-3 font-semibold transition-colors focus-visible:outline-none ${activeTab === value ? 'bg-primary text-text-on-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface-muted hover:text-text-primary'}`}
              >
                <Icon className="size-4" aria-hidden="true" />
                {label}
              </button>
            ))}
          </div>
        </Card>
        <Card className="tablet:p-5 p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-overline text-primary">Governance & oversight</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">
                {activeTab === 'workflows' ? 'Workflow register' : 'Request review'}
              </h2>
              <p className="text-caption text-text-secondary mt-1">
                {activeTab === 'workflows'
                  ? `${flowQuery.data?.count ?? 0} configured routes · each step is ordered`
                  : `${requestsQuery.data?.count ?? 0} requests in your review scope`}
              </p>
            </div>
            {activeTab === 'workflows' ? (
              <StatusChip label="Approval routing" tone="primary" dense />
            ) : null}
          </div>
          <form
            onSubmit={submitSearch}
            className="phone:grid-cols-[minmax(0,1fr)_auto] mt-4 grid gap-3"
          >
            {activeTab === 'requests' ? (
              <FormControl id="request-status" label="Request status">
                <DropdownSelect
                  id="request-status"
                  value={search.status}
                  options={statusOptions}
                  onChange={(status) =>
                    updateSearch({ status: status as ApprovalWorkflowsSearch['status'], page: 1 })
                  }
                />
              </FormControl>
            ) : null}
            <FormControl
              id="approval-search"
              className="min-w-0"
              label={activeTab === 'workflows' ? 'Search workflows' : 'Search requests'}
            >
              <TextInput
                id="approval-search"
                value={searchDraft}
                onChange={(event) =>
                  setSearchDraftState({ routeValue: search.search, value: event.target.value })
                }
                placeholder={
                  activeTab === 'workflows'
                    ? 'Workflow name or description'
                    : 'Title, reference or details'
                }
              />
            </FormControl>
            <div className="flex items-end">
              <Button
                type="submit"
                className="phone:w-auto w-full"
                leadingIcon={<Search className="size-4" aria-hidden="true" />}
              >
                Search
              </Button>
            </div>
          </form>
        </Card>

        {activeTab === 'workflows' ? (
          <Card className="overflow-hidden p-0">
            {flowQuery.isPending ? (
              <div className="space-y-3 p-4">
                <Skeleton className="h-28" />
                <Skeleton className="h-28" />
                <Skeleton className="h-28" />
              </div>
            ) : flowQuery.isError && !flowQuery.data ? (
              <ErrorState
                title="Approval workflows could not be loaded"
                error={flowQuery.error}
                action={
                  <Button variant="outline" onClick={() => void flowQuery.refetch()}>
                    Try again
                  </Button>
                }
              />
            ) : flows.length === 0 ? (
              <EmptyState
                title="No workflows found"
                description={
                  search.search
                    ? 'Try a different search term.'
                    : 'Create an approval route to define how company requests are reviewed.'
                }
                icon={<Workflow className="size-6" aria-hidden="true" />}
                action={
                  canCreate ? (
                    <Button
                      onClick={() => setWorkflowEditor('new')}
                      leadingIcon={<Plus className="size-4" aria-hidden="true" />}
                    >
                      Create workflow
                    </Button>
                  ) : undefined
                }
              />
            ) : (
              <div className="tablet:p-4 space-y-3 p-3">
                {flows.map((flow) => (
                  <article
                    key={flow.id}
                    className="group border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-md rounded-surface shadow-elevation-sm overflow-hidden border motion-safe:transition-[border-color,box-shadow] motion-safe:duration-150"
                  >
                    <div className="tablet:grid-cols-[minmax(0,1fr)_auto] tablet:p-5 grid gap-4 p-4">
                      <div className="min-w-0 space-y-3">
                        <div className="flex min-w-0 items-start gap-3">
                          <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
                            <Workflow className="size-[18px]" aria-hidden="true" />
                          </span>
                          <div className="min-w-0 flex-1">
                            <div className="flex min-w-0 flex-wrap items-center gap-2">
                              <h3 className="text-body-md text-text-primary leading-snug font-semibold break-words">
                                {flow.name}
                              </h3>
                              <StatusChip
                                label={flow.is_active ? 'Active' : 'Inactive'}
                                tone={flow.is_active ? 'success' : 'neutral'}
                                dense
                              />
                            </div>
                            <p className="text-caption text-text-secondary mt-1">
                              {flow.action_type_display} <span aria-hidden="true">·</span>{' '}
                              {flow.steps.length} {flow.steps.length === 1 ? 'step' : 'steps'}
                            </p>
                          </div>
                        </div>
                        <p className="border-border-subtle text-body-sm text-text-secondary border-l-2 pl-3">
                          {flow.description || 'No description has been added.'}
                        </p>
                        <div>
                          <p className="text-overline text-text-muted mb-2">Approval sequence</p>
                          {flow.steps.length ? (
                            <ol
                              aria-label={`Approval steps for ${flow.name}`}
                              className="phone:grid-cols-2 desktop:grid-cols-3 grid gap-2"
                            >
                              {flow.steps.map((step) => (
                                <li
                                  key={step.id}
                                  className="border-border-subtle bg-surface-muted/55 rounded-control flex min-w-0 items-start gap-2.5 border p-2.5"
                                >
                                  <span className="bg-primary-subtle text-primary rounded-pill text-caption flex size-7 shrink-0 items-center justify-center font-semibold">
                                    {String(step.step_order).padStart(2, '0')}
                                  </span>
                                  <span className="min-w-0">
                                    <span className="text-caption text-text-primary block font-semibold break-words">
                                      {step.step_name}
                                    </span>
                                    <span className="text-caption text-text-secondary mt-0.5 block">
                                      {step.required_level_display}
                                    </span>
                                  </span>
                                </li>
                              ))}
                            </ol>
                          ) : (
                            <p className="text-caption text-text-secondary">
                              No approval steps are configured.
                            </p>
                          )}
                        </div>
                        <p className="text-caption text-text-muted">
                          Updated {formatDate(flow.updated_at)}
                        </p>
                      </div>
                      <div className="border-border-subtle tablet:self-stretch tablet:border-t-0 tablet:border-l tablet:pl-4 tablet:pt-0 flex flex-wrap items-center gap-2 border-t pt-3">
                        <Button
                          variant="outline"
                          size="sm"
                          className="tablet:w-auto flex-1"
                          onClick={() => setWorkflowDetail(flow)}
                        >
                          Details
                        </Button>
                        {canUpdate ? (
                          <Button
                            variant="outline"
                            size="sm"
                            className="tablet:w-auto flex-1"
                            onClick={() => setWorkflowEditor(flow)}
                          >
                            Edit
                          </Button>
                        ) : null}
                        {flow.is_active && canDeactivate ? (
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-danger hover:text-danger tablet:w-auto w-full"
                            onClick={() => setDeactivateTarget(flow)}
                          >
                            Deactivate
                          </Button>
                        ) : null}
                        {!flow.is_active && canUpdate ? (
                          <Button
                            variant="outline"
                            size="sm"
                            className="tablet:w-auto flex-1"
                            isLoading={activateWorkflow.isPending}
                            onClick={() => activateWorkflow.mutate(flow.id)}
                          >
                            Activate
                          </Button>
                        ) : null}
                      </div>
                    </div>
                  </article>
                ))}
              </div>
            )}
            {flowQuery.isError && flowQuery.data ? (
              <div className="p-4 pt-0">
                <SectionErrorState
                  title="Workflows could not be refreshed"
                  description="Showing the last loaded workflows. Try again to check for updates."
                  onRetry={() => void flowQuery.refetch()}
                />
              </div>
            ) : null}
            {!flowQuery.isPending && flowQuery.data ? (
              <Pagination
                page={search.page}
                count={flowQuery.data?.count ?? 0}
                onPage={(page) => updateSearch({ page })}
              />
            ) : null}
          </Card>
        ) : null}

        {activeTab === 'requests' ? (
          <>
            <Card className="overflow-hidden p-0">
              {requestsQuery.isPending ? (
                <div className="space-y-3 p-4">
                  <Skeleton className="h-24" />
                  <Skeleton className="h-24" />
                  <Skeleton className="h-24" />
                </div>
              ) : requestsQuery.isError && !requestsQuery.data ? (
                <ErrorState
                  title="Approval requests could not be loaded"
                  error={requestsQuery.error}
                  action={
                    <Button variant="outline" onClick={() => void requestsQuery.refetch()}>
                      Try again
                    </Button>
                  }
                />
              ) : requests.length === 0 ? (
                <EmptyState
                  title="No approval requests found"
                  description={
                    search.search || search.status !== 'all'
                      ? 'Adjust the status or search filters.'
                      : 'Requests in your review scope will appear here.'
                  }
                  icon={<FileCheck2 className="size-6" aria-hidden="true" />}
                />
              ) : (
                <div className="divide-border-subtle divide-y">
                  {requests.map((request) => (
                    <article
                      key={request.id}
                      className="tablet:flex-row tablet:items-start tablet:justify-between tablet:px-5 flex min-w-0 flex-col gap-3 p-4"
                    >
                      <div className="flex min-w-0 gap-3">
                        <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                          <FileCheck2 className="size-[18px]" aria-hidden="true" />
                        </span>
                        <div className="min-w-0">
                          <div className="flex flex-wrap items-center gap-2">
                            <h3 className="text-label text-text-primary font-semibold">
                              {request.title}
                            </h3>
                            <StatusChip
                              label={request.status_display}
                              tone={requestTone(request.status)}
                              dense
                            />
                          </div>
                          <p className="text-caption text-text-secondary mt-1">
                            {request.flow_name} · {request.action_type_display} ·{' '}
                            {request.approval_request_id}
                          </p>
                          <p className="text-body-sm text-text-secondary mt-2 line-clamp-2">
                            {request.description || 'No additional details were provided.'}
                          </p>
                          <div className="text-caption text-text-secondary mt-2 flex flex-wrap gap-x-4 gap-y-1">
                            <span className="inline-flex items-center gap-1.5">
                              <UserRound className="size-3.5" aria-hidden="true" />
                              {request.created_by_name || 'Requester unavailable'}
                            </span>
                            <time
                              dateTime={request.created_at}
                              className="inline-flex items-center gap-1.5"
                            >
                              <Clock3 className="size-3.5" aria-hidden="true" />
                              {formatDate(request.created_at)}
                            </time>
                            {request.status === 'pending' ? (
                              <span>
                                Step {request.current_step} of {request.total_steps}:{' '}
                                {request.pending_step_name || 'Awaiting review'}
                              </span>
                            ) : null}
                          </div>
                        </div>
                      </div>
                      <Button
                        variant="outline"
                        size="sm"
                        className="tablet:w-auto w-full"
                        onClick={() => setRequestDetail(request)}
                      >
                        Review request
                      </Button>
                    </article>
                  ))}
                </div>
              )}
              {requestsQuery.isError && requestsQuery.data ? (
                <div className="p-4 pt-0">
                  <SectionErrorState
                    title="Requests could not be refreshed"
                    description="Showing the last loaded requests. Try again to check for updates."
                    onRetry={() => void requestsQuery.refetch()}
                  />
                </div>
              ) : null}
              {!requestsQuery.isPending && requestsQuery.data ? (
                <Pagination
                  page={search.page}
                  count={requestsQuery.data?.count ?? 0}
                  onPage={(page) => updateSearch({ page })}
                />
              ) : null}
            </Card>
          </>
        ) : null}
      </div>

      <Dialog
        open={Boolean(workflowEditor)}
        onOpenChange={(open) => !open && setWorkflowEditor(null)}
        title={workflowEditor === 'new' ? 'Create approval workflow' : 'Edit approval workflow'}
        description="Configure the ordered review steps for this type of request."
        size="lg"
        closeOnBackdrop={!saveWorkflow.isPending}
      >
        {workflowEditor ? (
          choicesQuery.isError ? (
            <SectionErrorState
              error={choicesQuery.error}
              onRetry={() => void choicesQuery.refetch()}
            />
          ) : choicesQuery.isPending ? (
            <Skeleton className="h-64" />
          ) : (
            <WorkflowForm
              key={workflowEditor === 'new' ? 'new' : workflowEditor.id}
              value={workflowEditor === 'new' ? undefined : workflowEditor}
              actionTypes={choicesQuery.data.action_types}
              levels={choicesQuery.data.required_levels}
              pending={saveWorkflow.isPending}
              onCancel={() => setWorkflowEditor(null)}
              onSubmit={(input) => saveWorkflow.mutate(input)}
            />
          )
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(workflowDetail)}
        onOpenChange={(open) => !open && setWorkflowDetail(null)}
        title={workflowDetail?.name ?? 'Workflow details'}
        description="Approval route and ordered steps"
        size="md"
        fitContent
        compactOnMobile
        footer={
          <Button variant="outline" onClick={() => setWorkflowDetail(null)}>
            Close
          </Button>
        }
      >
        {workflowDetail ? (
          <div className="space-y-5">
            <div className="from-primary-subtle/60 via-primary-subtle/20 border-border-subtle rounded-control flex flex-wrap items-center justify-between gap-3 border bg-gradient-to-r to-transparent p-4">
              <div>
                <p className="text-overline text-text-muted">Workflow status</p>
                <div className="mt-2 flex flex-wrap gap-2">
                  <StatusChip
                    label={workflowDetail.is_active ? 'Active' : 'Inactive'}
                    tone={workflowDetail.is_active ? 'success' : 'neutral'}
                  />
                  <StatusChip label={workflowDetail.action_type_display} tone="primary" />
                </div>
              </div>
              <div className="text-right">
                <p className="text-overline text-text-muted">Approval steps</p>
                <p className="text-h3 text-text-primary mt-1 font-semibold tabular-nums">
                  {String(workflowDetail.steps.length).padStart(2, '0')}
                </p>
              </div>
            </div>
            <section aria-labelledby="workflow-detail-description">
              <h3
                id="workflow-detail-description"
                className="text-label text-text-primary font-semibold"
              >
                Purpose and scope
              </h3>
              <p className="text-body-sm text-text-secondary mt-1.5">
                {workflowDetail.description || 'No description has been added.'}
              </p>
            </section>
            <section aria-labelledby="workflow-detail-steps">
              <div className="flex items-end justify-between gap-3">
                <div>
                  <h3
                    id="workflow-detail-steps"
                    className="text-label text-text-primary font-semibold"
                  >
                    Approval sequence
                  </h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Reviews are presented in this order.
                  </p>
                </div>
              </div>
              {workflowDetail.steps.length ? (
                <ol className="mt-3 space-y-2">
                  {workflowDetail.steps.map((step, index) => (
                    <li
                      key={step.id}
                      className="border-border-subtle bg-surface rounded-control relative flex items-start gap-3 border p-3"
                    >
                      <span className="bg-primary-subtle text-primary rounded-control text-caption flex size-9 shrink-0 items-center justify-center font-semibold tabular-nums">
                        {String(step.step_order).padStart(2, '0')}
                      </span>
                      <div className="min-w-0 flex-1 py-0.5">
                        <p className="text-label text-text-primary font-semibold break-words">
                          {step.step_name}
                        </p>
                        <p className="text-caption text-text-secondary mt-1">
                          Required level{' '}
                          <span className="text-text-primary font-medium">
                            {step.required_level_display}
                          </span>
                        </p>
                      </div>
                      {index < workflowDetail.steps.length - 1 ? (
                        <span className="text-caption text-text-muted phone:block hidden shrink-0 pt-2">
                          Then
                        </span>
                      ) : null}
                    </li>
                  ))}
                </ol>
              ) : (
                <p className="text-caption text-text-secondary border-border-subtle rounded-control mt-3 border border-dashed p-3">
                  No approval steps are configured.
                </p>
              )}
            </section>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(deactivateTarget)}
        onOpenChange={(open) => !open && setDeactivateTarget(null)}
        title="Deactivate workflow"
        description="Inactive workflows cannot be selected for new requests."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setDeactivateTarget(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deactivateWorkflow.isPending}
              onClick={() => deactivateTarget && deactivateWorkflow.mutate(deactivateTarget.id)}
            >
              Deactivate
            </Button>
          </>
        }
      >
        {deactivateTarget ? (
          <p className="text-body-sm text-text-secondary">
            Deactivate <strong className="text-text-primary">{deactivateTarget.name}</strong>?
            Existing requests are not cancelled.
          </p>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(requestDetail && !rejectTarget)}
        onOpenChange={(open) => !open && setRequestDetail(null)}
        title={requestDetail?.title ?? 'Review request'}
        description={requestDetail?.approval_request_id}
        size="lg"
        fitContent
        compactOnMobile
        footer={
          <div className="flex w-full flex-wrap items-center justify-between gap-2">
            <Button variant="outline" onClick={() => setRequestDetail(null)}>
              Close
            </Button>
            {requestDetail?.status === 'pending' ? (
              <div className="flex gap-2">
                {canReject ? (
                  <Button
                    variant="danger"
                    onClick={() => {
                      setRejectTarget(requestDetail)
                      setRejectionReason('')
                    }}
                  >
                    Reject
                  </Button>
                ) : null}
                {canApprove ? (
                  <Button
                    isLoading={approveRequest.isPending}
                    onClick={() => approveRequest.mutate(requestDetail.id)}
                    leadingIcon={<Check className="size-4" aria-hidden="true" />}
                  >
                    Approve
                  </Button>
                ) : null}
              </div>
            ) : null}
          </div>
        }
      >
        {requestDetail ? (
          <div className="space-y-4">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <StatusChip
                label={requestDetail.status_display}
                tone={requestTone(requestDetail.status)}
              />
              <span className="text-caption text-text-secondary">
                {requestDetail.flow_name} · {requestDetail.action_type_display}
              </span>
            </div>
            <div className="bg-surface-muted rounded-control phone:grid-cols-2 grid gap-3 p-4">
              <Detail
                label="Requested by"
                value={requestDetail.created_by_name || 'Requester unavailable'}
              />
              <Detail label="Submitted" value={formatDate(requestDetail.created_at)} />
              <Detail
                label="Progress"
                value={`${requestDetail.current_step} of ${requestDetail.total_steps}${requestDetail.pending_step_name ? ` · ${requestDetail.pending_step_name}` : ''}`}
              />
              {requestDetail.pending_step_required_level_display ? (
                <Detail
                  label="Configured level"
                  value={requestDetail.pending_step_required_level_display}
                />
              ) : null}
            </div>
            <section>
              <h3 className="text-label text-text-primary font-semibold">Request details</h3>
              <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
                {requestDetail.description || 'No additional details were provided.'}
              </p>
            </section>
            <section>
              <h3 className="text-label text-text-primary font-semibold">Decision history</h3>
              {requestDetail.decisions.length ? (
                <ol className="mt-3 space-y-2">
                  {requestDetail.decisions.map((decision) => (
                    <li
                      key={decision.id}
                      className="border-border-subtle rounded-control border p-3"
                    >
                      <div className="flex flex-wrap justify-between gap-2">
                        <p className="text-label text-text-primary font-semibold">
                          {decision.step_name} · {decision.decision_display}
                        </p>
                        <time
                          className="text-caption text-text-secondary"
                          dateTime={decision.created_at}
                        >
                          {formatDate(decision.created_at)}
                        </time>
                      </div>
                      <p className="text-caption text-text-secondary mt-1">
                        {decision.approver_name || 'System'}
                      </p>
                      {decision.comment ? (
                        <p className="text-body-sm text-text-secondary mt-2">{decision.comment}</p>
                      ) : null}
                    </li>
                  ))}
                </ol>
              ) : (
                <p className="text-caption text-text-secondary mt-2">
                  No decisions have been recorded yet.
                </p>
              )}
            </section>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(rejectTarget)}
        onOpenChange={(open) => {
          if (!open) {
            setRejectTarget(null)
            setRejectionError(null)
          }
        }}
        title="Reject request"
        description="Record a clear reason with the decision."
        size="md"
        compactOnMobile
        closeOnBackdrop={!rejectRequest.isPending}
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setRejectTarget(null)}
              disabled={rejectRequest.isPending}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={rejectRequest.isPending}
              onClick={() => {
                if (!rejectionReason.trim()) {
                  setRejectionError('Provide a reason for rejecting this request.')
                  rejectionRef.current?.focus()
                  return
                }
                if (rejectTarget)
                  rejectRequest.mutate({ id: rejectTarget.id, comment: rejectionReason.trim() })
              }}
            >
              Reject request
            </Button>
          </>
        }
      >
        <FormControl
          id="rejection-reason"
          label="Reason"
          required
          error={rejectionError ?? undefined}
        >
          <TextArea
            ref={rejectionRef}
            id="rejection-reason"
            value={rejectionReason}
            onChange={(event) => {
              setRejectionReason(event.target.value)
              setRejectionError(null)
            }}
            rows={5}
            maxLength={2000}
            aria-invalid={Boolean(rejectionError)}
          />
        </FormControl>
      </Dialog>
    </PageLayout>
  )
}

function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div className="min-w-0">
      <p className="text-overline text-text-secondary">{label}</p>
      <p className="text-body-sm text-text-primary mt-1 break-words">{value}</p>
    </div>
  )
}
