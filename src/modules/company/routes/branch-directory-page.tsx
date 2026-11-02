import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  Building2,
  ChevronLeft,
  ChevronRight,
  CircleAlert,
  GitBranch,
  MapPin,
  Plus,
  RefreshCw,
  Search,
  UsersRound,
} from 'lucide-react'
import { useCallback, useEffect, useMemo, useState } from 'react'

import {
  branchQueryKeys,
  branchesApi,
  type BranchDto,
  type BranchListParams,
  type BranchUpdateInput,
  type BranchWriteInput,
} from '@/modules/company/branches.api'
import {
  companyDashboardApi,
  companyOverviewQueryKey,
} from '@/modules/company/company-dashboard.api'
import { BranchFormDialog } from '@/modules/company/routes/branch-form-dialog'
import { BranchRowActions } from '@/modules/company/components/branch-row-actions'
import { attendanceQueryKeys } from '@/modules/attendance/attendance.queries'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type { BranchDirectorySearch } from '../branches.search'

const PAGE_SIZE = 10
const operationalOptions: DropdownSelectOption[] = [
  { value: 'all', label: 'All operating statuses' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'under_maintenance', label: 'Under maintenance' },
  { value: 'temporarily_closed', label: 'Temporarily closed' },
  { value: 'permanently_closed', label: 'Permanently closed' },
]
const branchTypeOptions: DropdownSelectOption[] = [
  { value: 'all', label: 'All branch types' },
  { value: 'branch', label: 'Branch' },
  { value: 'state_headquarters', label: 'State headquarters' },
  { value: 'interstate_regional_headquarters', label: 'Interstate regional headquarters' },
  { value: 'national_headquarters', label: 'National headquarters' },
]
const recordStateOptions: DropdownSelectOption[] = [
  { value: 'all', label: 'All records' },
  { value: 'active', label: 'Active records' },
  { value: 'inactive', label: 'Inactive records' },
]

function BranchSearchInput({
  search,
  onCommit,
}: {
  search: string
  onCommit: (value: string) => void
}) {
  const [value, setValue] = useState(search)

  useEffect(() => {
    const next = value.trim()
    if (next === search) return
    const timer = window.setTimeout(() => onCommit(next), 250)
    return () => window.clearTimeout(timer)
  }, [onCommit, search, value])

  return (
    <div className="wide:col-span-1 col-span-2 space-y-1.5">
      <label
        htmlFor="branch-search"
        className="text-control-label text-text-secondary block font-bold"
      >
        Search branches
      </label>
      <div className="relative">
        <Search
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="branch-search"
          type="search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Name, ID, type, manager, location"
          className="pl-10"
        />
      </div>
    </div>
  )
}

function operationalTone(status: string): StatusTone {
  if (status === 'active') return 'success'
  if (status === 'under_maintenance' || status === 'temporarily_closed') return 'warning'
  if (status === 'permanently_closed') return 'danger'
  return 'neutral'
}

function formatLocation(branch: BranchDto) {
  return [branch.city, branch.state, branch.country].filter(Boolean).join(', ')
}

function BranchStatus({ branch }: { branch: BranchDto }) {
  return (
    <div className="flex min-w-0 flex-wrap gap-1.5">
      <StatusChip
        label={branch.operational_status_display}
        tone={operationalTone(branch.operational_status)}
        dense
      />
      <StatusChip
        label={branch.is_active ? 'Active record' : 'Inactive record'}
        tone={branch.is_active ? 'info' : 'neutral'}
        dense
      />
    </div>
  )
}

function BranchTableRow({
  branch,
  search,
  canView,
  canEdit,
  onEdit,
}: {
  branch: BranchDto
  search: BranchDirectorySearch
  canView: boolean
  canEdit: boolean
  onEdit: () => void
}) {
  return (
    <tr className="border-border-subtle group hover:bg-surface-muted/30 border-t transition-colors first:border-t-0">
      <td className="py-4 pr-4 pl-4 align-middle">
        {canView ? (
          <Link
            to="/company/branch/$branchId"
            params={{ branchId: String(branch.id) }}
            search={search}
            className="text-body-sm text-text-primary hover:text-primary focus-visible:shadow-focus-ring rounded-control font-semibold underline-offset-4 hover:underline focus-visible:outline-none"
          >
            {branch.branch_name}
          </Link>
        ) : (
          <span className="text-body-sm text-text-primary font-semibold">{branch.branch_name}</span>
        )}
        <p className="text-caption text-text-secondary mt-1">{branch.branch_id}</p>
      </td>
      <td className="text-body-sm text-text-secondary py-4 pr-4 pl-4 align-middle">
        <span className="inline-flex items-start gap-1.5">
          <MapPin className="mt-0.5 size-3.5 shrink-0" aria-hidden="true" />
          <span>{formatLocation(branch) || 'Location not provided'}</span>
        </span>
      </td>
      <td className="text-body-sm text-text-secondary py-4 pr-4 pl-4 align-middle">
        <span className="block">{branch.branch_role_display}</span>
        <span className="text-caption mt-1 block">
          {branch.manager_name || 'No manager assigned'}
        </span>
      </td>
      <td className="py-4 pr-4 pl-4 align-middle">
        <BranchStatus branch={branch} />
      </td>
      {canView || canEdit ? (
        <td className="border-border-subtle w-28 border-l py-3 pr-4 pl-3 text-right align-middle">
          <BranchRowActions
            branch={branch}
            search={search}
            canView={canView}
            canEdit={canEdit}
            onEdit={onEdit}
          />
        </td>
      ) : null}
    </tr>
  )
}

function BranchMobileCard({
  branch,
  search,
  canView,
  canEdit,
  onEdit,
}: {
  branch: BranchDto
  search: BranchDirectorySearch
  canView: boolean
  canEdit: boolean
  onEdit: () => void
}) {
  return (
    <Card className="overflow-hidden p-0">
      <div className="from-primary-subtle/55 via-surface to-surface flex min-w-0 items-start gap-3 bg-gradient-to-r p-4">
        <span className="bg-surface text-primary border-primary/10 rounded-control flex size-11 shrink-0 items-center justify-center border">
          <Building2 className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <h2 className="text-label text-text-primary truncate font-semibold">
            {branch.branch_name}
          </h2>
          <div className="mt-1 flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1">
            <span className="text-caption text-text-secondary font-semibold">
              {branch.branch_id}
            </span>
            <span className="text-text-muted" aria-hidden="true">
              ·
            </span>
            <span className="text-caption text-text-secondary">{branch.branch_role_display}</span>
          </div>
        </div>
      </div>
      <div className="px-4 pb-3">
        <BranchStatus branch={branch} />
      </div>
      <div className="phone:grid-cols-2 phone:p-4 grid gap-2 p-3">
        <div className="bg-surface-muted/55 rounded-control flex min-w-0 items-start gap-2.5 p-3">
          <MapPin className="text-text-muted mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-overline text-text-muted">Location</p>
            <p className="text-caption text-text-primary mt-0.5 break-words">
              {formatLocation(branch) || 'Not provided'}
            </p>
          </div>
        </div>
        <div className="bg-surface-muted/55 rounded-control flex min-w-0 items-start gap-2.5 p-3">
          <UsersRound className="text-text-muted mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-overline text-text-muted">Branch manager</p>
            <p className="text-caption text-text-primary mt-0.5 break-words">
              {branch.manager_name || 'Not assigned'}
            </p>
          </div>
        </div>
      </div>
      {canView || canEdit ? (
        <div className="border-border-subtle flex justify-end border-t p-3">
          <BranchRowActions
            branch={branch}
            search={search}
            canView={canView}
            canEdit={canEdit}
            onEdit={onEdit}
          />
        </div>
      ) : null}
    </Card>
  )
}

function BranchHealthOverview({
  total,
  operational,
  nonOperational,
}: {
  total: number | null | undefined
  operational: number | null | undefined
  nonOperational: number | null | undefined
}) {
  return (
    <Card className="phone:p-5 tablet:grid-cols-[minmax(12rem,0.8fr)_minmax(0,1.7fr)] tablet:items-center grid min-w-0 gap-4 p-4">
      <div className="flex min-w-0 items-center gap-3">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <GitBranch className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0">
          <p className="text-overline text-text-secondary font-semibold">Branch health</p>
          <p className="text-h2 text-text-primary mt-0.5 font-semibold tabular-nums">
            {total ?? '—'}
          </p>
          <p className="text-caption text-text-muted">branches in your access scope</p>
        </div>
      </div>
      <div className="grid min-w-0 grid-cols-2 gap-2.5">
        <div className="bg-success-subtle/55 border-success/20 rounded-control phone:p-4 flex min-w-0 items-center gap-2.5 border p-3">
          <span className="bg-surface/80 text-success-foreground rounded-control flex size-9 shrink-0 items-center justify-center">
            <Building2 className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="text-caption text-text-secondary">Operational</p>
            <p className="text-h3 text-text-primary mt-0.5 font-semibold tabular-nums">
              {operational ?? '—'}
            </p>
          </div>
        </div>
        <div className="bg-warning-subtle/55 border-warning/20 rounded-control phone:p-4 flex min-w-0 items-center gap-2.5 border p-3">
          <span className="bg-surface/80 text-warning-foreground rounded-control flex size-9 shrink-0 items-center justify-center">
            <CircleAlert className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="text-caption text-text-secondary">Non-operational</p>
            <p className="text-h3 text-text-primary mt-0.5 font-semibold tabular-nums">
              {nonOperational ?? '—'}
            </p>
          </div>
        </div>
      </div>
    </Card>
  )
}

export function BranchDirectoryPage() {
  const search = useSearch({ from: '/_protected/company/branch' }) as BranchDirectorySearch
  const navigate = useNavigate({ from: '/_protected/company/branch' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canView = hasPermission(permissions, 'branches', 'view')
  const canCreate = hasPermission(permissions, 'branches', 'create')
  const canEdit = hasPermission(permissions, 'branches', 'update')
  const canEditHours = hasPermission(permissions, 'branches', 'set_business_hours')
  const [editingBranch, setEditingBranch] = useState<BranchDto | null>(null)
  const [createOpen, setCreateOpen] = useState(false)

  const commitSearch = useCallback(
    (value: string) => {
      void navigate({
        to: '/company/branch',
        search: (previous: BranchDirectorySearch) => ({ ...previous, search: value, page: 1 }),
        replace: true,
      })
    },
    [navigate],
  )

  const listParams: BranchListParams = useMemo(
    () => ({
      limit: PAGE_SIZE,
      offset: (search.page - 1) * PAGE_SIZE,
      search: search.search,
      operationalStatus: search.operationalStatus || 'all',
      branchRole: search.branchRole || 'all',
      recordState: search.recordState,
    }),
    [search.branchRole, search.operationalStatus, search.page, search.recordState, search.search],
  )
  const listQuery = useQuery({
    queryKey: branchQueryKeys.list(userId, employeeId, listParams),
    queryFn: ({ signal }) => branchesApi.list(listParams, signal),
    enabled: Boolean(session && hasPermission(permissions, 'branches', 'list')),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const overviewQuery = useQuery({
    queryKey: companyOverviewQueryKey(userId, employeeId),
    queryFn: ({ signal }) => companyDashboardApi.overview(signal),
    enabled: Boolean(session && hasPermission(permissions, 'branches', 'list')),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const saveMutation = useMutation({
    mutationFn: async ({
      branch,
      input,
    }: {
      branch: BranchDto | null
      input: BranchWriteInput | BranchUpdateInput
    }) =>
      branch ? branchesApi.update(branch.id, input) : branchesApi.create(input as BranchWriteInput),
    onSuccess: async (saved, variables) => {
      if (variables.branch) {
        queryClient.setQueryData(branchQueryKeys.detail(userId, employeeId, saved.id), saved)
      }
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: branchQueryKeys.lists(userId, employeeId) }),
        queryClient.invalidateQueries({ queryKey: companyOverviewQueryKey(userId, employeeId) }),
        ...(variables.branch
          ? [
              queryClient.invalidateQueries({
                queryKey: branchQueryKeys.detail(userId, employeeId, saved.id),
              }),
              queryClient.invalidateQueries({
                queryKey: branchQueryKeys.hours(userId, employeeId, saved.id),
              }),
            ]
          : []),
        ...(!variables.branch ||
        variables.branch.is_active !== saved.is_active ||
        variables.branch.operational_status !== saved.operational_status ||
        variables.branch.latitude !== saved.latitude ||
        variables.branch.longitude !== saved.longitude ||
        variables.branch.attendance_radius_meters !== saved.attendance_radius_meters
          ? [
              queryClient.invalidateQueries({
                queryKey: attendanceQueryKeys.branches(userId),
              }),
            ]
          : []),
      ])
      setEditingBranch(null)
      setCreateOpen(false)
      showToast({
        title: variables.branch ? 'Branch updated' : 'Branch created',
        description: `${saved.branch_name} is up to date.`,
        tone: 'success',
      })
    },
  })

  const result = listQuery.data
  const branches = result?.items ?? []
  const totalPages = Math.max(1, Math.ceil((result?.count ?? 0) / PAGE_SIZE))
  const hasActiveFilter =
    search.search.trim() !== '' ||
    search.operationalStatus !== 'all' ||
    search.branchRole !== 'all' ||
    search.recordState !== 'all'

  async function changeSearch(patch: Partial<BranchDirectorySearch>) {
    await navigate({
      to: '/company/branch',
      search: (previous: BranchDirectorySearch) => ({
        ...previous,
        ...patch,
        page: patch.page ?? 1,
      }),
      replace: patch.search !== undefined,
    })
  }

  function openCreate() {
    saveMutation.reset()
    setEditingBranch(null)
    setCreateOpen(true)
  }

  function openEdit(branch: BranchDto) {
    saveMutation.reset()
    setCreateOpen(false)
    setEditingBranch(branch)
  }

  const dialogOpen = createOpen || Boolean(editingBranch)

  return (
    <PageLayout
      title="Branches"
      subtitle="Manage branch identity, operating status, and attendance locations."
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="New branch"
            size="sm"
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
            onClick={openCreate}
            leadingIcon={<Plus className="size-4" aria-hidden="true" />}
          >
            <span className="max-[479px]:hidden">New branch</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <section aria-label="Branch overview" className="min-w-0">
          {overviewQuery.isPending && !overviewQuery.data ? (
            <Skeleton className="h-36" />
          ) : overviewQuery.error && !overviewQuery.data ? (
            <SectionErrorState
              title="Branch counts are unavailable"
              description="The branch directory remains available. Retry the company overview counts."
              error={overviewQuery.error}
              onRetry={() => void overviewQuery.refetch()}
            />
          ) : (
            <BranchHealthOverview
              total={overviewQuery.data?.total_branches}
              operational={overviewQuery.data?.operational_branches}
              nonOperational={overviewQuery.data?.non_operational_branches}
            />
          )}
        </section>

        {overviewQuery.error && overviewQuery.data ? (
          <Alert tone="warning" title="Showing saved branch counts" role="status">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>Counts could not refresh. The branch list is still available.</span>
              <Button variant="ghost" size="sm" onClick={() => void overviewQuery.refetch()}>
                Retry counts
              </Button>
            </div>
          </Alert>
        ) : null}

        <Card className="phone:p-5 space-y-4 p-4">
          <div className="tablet:flex-row tablet:items-end flex min-w-0 flex-col gap-3">
            <div className="min-w-0 flex-1">
              <h2 className="text-h3 text-text-primary font-semibold">Branch directory</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {result
                  ? `${result.count} ${result.count === 1 ? 'branch' : 'branches'} in this view`
                  : 'Search and review branches in your access scope.'}
              </p>
            </div>
            {listQuery.isFetching && result ? (
              <span
                className="text-caption text-text-muted inline-flex items-center gap-2"
                role="status"
              >
                <RefreshCw className="size-3.5 animate-spin" aria-hidden="true" /> Updating list
              </span>
            ) : null}
          </div>

          <div className="wide:grid-cols-[minmax(16rem,1.5fr)_repeat(3,minmax(10rem,1fr))] grid grid-cols-2 gap-3">
            <BranchSearchInput key={search.search} search={search.search} onCommit={commitSearch} />
            <FormControl id="branch-operating-filter" label="Operating status">
              <DropdownSelect
                id="branch-operating-filter"
                value={search.operationalStatus}
                options={operationalOptions}
                onChange={(operationalStatus) => void changeSearch({ operationalStatus })}
              />
            </FormControl>
            <FormControl id="branch-type-filter" label="Branch type">
              <DropdownSelect
                id="branch-type-filter"
                value={search.branchRole}
                options={branchTypeOptions}
                onChange={(branchRole) => void changeSearch({ branchRole })}
              />
            </FormControl>
            <FormControl id="branch-record-filter" label="Record state">
              <DropdownSelect
                id="branch-record-filter"
                value={search.recordState}
                options={recordStateOptions}
                onChange={(recordState) =>
                  void changeSearch({
                    recordState: recordState as BranchDirectorySearch['recordState'],
                  })
                }
              />
            </FormControl>
          </div>

          {listQuery.error && result ? (
            <Alert tone="warning" title="Showing saved branch data" role="status">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>{presentError(listQuery.error, 'background-action').message}</span>
                <Button variant="ghost" size="sm" onClick={() => void listQuery.refetch()}>
                  Retry
                </Button>
              </div>
            </Alert>
          ) : null}

          {listQuery.isPending && !result ? (
            <div className="space-y-3" aria-label="Loading branches">
              <Skeleton className="h-16" />
              <Skeleton className="h-16" />
              <Skeleton className="h-16" />
            </div>
          ) : listQuery.error && !result ? (
            <ErrorState
              title="Branches could not load"
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Retry branch list
                </Button>
              }
            />
          ) : !branches.length ? (
            <EmptyState
              title={hasActiveFilter ? 'No branches match these filters' : 'No branches yet'}
              description={
                hasActiveFilter
                  ? 'Adjust the search or filters to see more branches.'
                  : 'Create a branch to start managing its operating details and attendance location.'
              }
              icon={<Building2 className="size-6" aria-hidden="true" />}
              action={
                hasActiveFilter ? (
                  <Button
                    variant="outline"
                    onClick={() => {
                      void changeSearch({
                        search: '',
                        operationalStatus: 'all',
                        branchRole: 'all',
                        recordState: 'all',
                      })
                    }}
                  >
                    Clear filters
                  </Button>
                ) : canCreate ? (
                  <Button
                    onClick={openCreate}
                    leadingIcon={<Plus className="size-4" aria-hidden="true" />}
                  >
                    New branch
                  </Button>
                ) : undefined
              }
            />
          ) : (
            <>
              <div className="tablet:hidden space-y-3">
                {branches.map((branch) => (
                  <BranchMobileCard
                    key={branch.id}
                    branch={branch}
                    search={search}
                    canView={canView}
                    canEdit={canEdit}
                    onEdit={() => openEdit(branch)}
                  />
                ))}
              </div>
              <div className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm tablet:block hidden overflow-x-auto border">
                <table
                  aria-label="Branch directory results"
                  className="w-full min-w-[860px] border-collapse text-left"
                >
                  <thead className="bg-surface-muted/65">
                    <tr className="text-caption text-text-secondary">
                      <th className="py-3 pr-4 pl-4 font-semibold">Branch</th>
                      <th className="py-3 pr-4 pl-4 font-semibold">Location</th>
                      <th className="py-3 pr-4 pl-4 font-semibold">Type and manager</th>
                      <th className="py-3 pr-4 pl-4 font-semibold">Status</th>
                      {canView || canEdit ? (
                        <th className="border-border-subtle w-28 border-l py-3 pr-4 pl-3 text-right font-semibold">
                          More
                        </th>
                      ) : null}
                    </tr>
                  </thead>
                  <tbody>
                    {branches.map((branch) => (
                      <BranchTableRow
                        key={branch.id}
                        branch={branch}
                        search={search}
                        canView={canView}
                        canEdit={canEdit}
                        onEdit={() => openEdit(branch)}
                      />
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-4">
                <p className="text-caption text-text-secondary">
                  Showing {(search.page - 1) * PAGE_SIZE + 1}–
                  {Math.min(search.page * PAGE_SIZE, result?.count ?? 0)} of {result?.count ?? 0}
                </p>
                <div className="flex items-center gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={search.page <= 1}
                    onClick={() => void changeSearch({ page: search.page - 1 })}
                    leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
                  >
                    Previous
                  </Button>
                  <span className="text-caption text-text-secondary px-1 tabular-nums">
                    {search.page} / {totalPages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={search.page >= totalPages}
                    onClick={() => void changeSearch({ page: search.page + 1 })}
                  >
                    Next <ChevronRight className="size-4" aria-hidden="true" />
                  </Button>
                </div>
              </div>
            </>
          )}
        </Card>
      </div>

      <BranchFormDialog
        open={dialogOpen}
        onOpenChange={(open) => {
          if (!open) {
            setCreateOpen(false)
            setEditingBranch(null)
          }
        }}
        branch={editingBranch}
        userId={userId}
        employeeId={employeeId}
        canEditHours={canEditHours}
        onSave={async (input) => {
          await saveMutation.mutateAsync({ branch: editingBranch, input })
        }}
      />
    </PageLayout>
  )
}
