import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowUpRight,
  Building2,
  CalendarClock,
  Globe2,
  Mail,
  MapPin,
  Pencil,
  Phone,
  UserRound,
} from 'lucide-react'
import { useState, type ReactNode } from 'react'

import {
  branchQueryKeys,
  branchesApi,
  type BranchBusinessHoursDto,
  type BranchDto,
  type BranchUpdateInput,
  type BranchWriteInput,
} from '@/modules/company/branches.api'
import { companyOverviewQueryKey } from '@/modules/company/company-dashboard.api'
import { BranchFormDialog } from '@/modules/company/routes/branch-form-dialog'
import { BranchGeofenceDialog } from '@/modules/company/routes/branch-geofence-dialog'
import { BranchHoursDialog } from '@/modules/company/routes/branch-hours-dialog'
import { attendanceQueryKeys } from '@/modules/attendance/attendance.queries'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type { BranchDirectorySearch } from '../branches.search'

function operationalTone(status: string): StatusTone {
  if (status === 'active') return 'success'
  if (status === 'under_maintenance' || status === 'temporarily_closed') return 'warning'
  if (status === 'permanently_closed') return 'danger'
  return 'neutral'
}

function ValueRow({
  label,
  value,
  icon,
  href,
}: {
  label: string
  value: string | null | undefined
  icon: ReactNode
  href?: string
}) {
  return (
    <div className="border-border-subtle flex min-w-0 items-start gap-3 border-b py-3 first:pt-0 last:border-b-0 last:pb-0">
      <span className="text-text-muted mt-0.5 shrink-0">{icon}</span>
      <div className="min-w-0 flex-1">
        <p className="text-caption text-text-secondary">{label}</p>
        {value ? (
          href ? (
            <a
              href={href}
              className="text-body-sm text-text-primary hover:text-primary mt-0.5 inline-flex max-w-full items-center gap-1 font-medium break-all underline-offset-4 hover:underline"
            >
              {value} <ArrowUpRight className="size-3.5 shrink-0" aria-hidden="true" />
            </a>
          ) : (
            <p className="text-body-sm text-text-primary mt-0.5 font-medium break-words">{value}</p>
          )
        ) : (
          <p className="text-body-sm text-text-muted mt-0.5">Not provided</p>
        )}
      </div>
    </div>
  )
}

function displayHours(hours: BranchBusinessHoursDto[], dayIndex: number) {
  const day = hours.find((item) => item.day_of_week === dayIndex)
  if (!day) return 'Not set'
  if (!day.is_open) return 'Closed'
  return `${day.open_time?.slice(0, 5) ?? '—'} – ${day.close_time?.slice(0, 5) ?? '—'}`
}

export function BranchDetailPage() {
  const params = useParams({ from: '/_protected/company/branch/$branchId' })
  const search = useSearch({
    from: '/_protected/company/branch/$branchId',
  }) as BranchDirectorySearch
  const navigate = useNavigate({ from: '/_protected/company/branch/$branchId' })
  const branchId = Number(params.branchId)
  const validBranchId = Number.isSafeInteger(branchId) && branchId > 0
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canEdit = hasPermission(permissions, 'branches', 'update')
  const canEditHours = hasPermission(permissions, 'branches', 'set_business_hours')
  const [editOpen, setEditOpen] = useState(false)
  const [hoursEditOpen, setHoursEditOpen] = useState(false)
  const [geofenceEditOpen, setGeofenceEditOpen] = useState(false)

  const branchQuery = useQuery({
    queryKey: branchQueryKeys.detail(userId, employeeId, validBranchId ? branchId : 0),
    queryFn: ({ signal }) => branchesApi.detail(branchId, signal),
    enabled: Boolean(session && validBranchId),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const hoursQuery = useQuery({
    queryKey: branchQueryKeys.hours(userId, employeeId, validBranchId ? branchId : 0),
    queryFn: ({ signal }) => branchesApi.businessHours(branchId, signal),
    enabled: Boolean(session && validBranchId),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const saveMutation = useMutation({
    mutationFn: (input: BranchWriteInput | BranchUpdateInput) =>
      branchesApi.update(branchId, input),
    onSuccess: async (saved) => {
      queryClient.setQueryData(branchQueryKeys.detail(userId, employeeId, saved.id), saved)
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: branchQueryKeys.lists(userId, employeeId) }),
        queryClient.invalidateQueries({
          queryKey: branchQueryKeys.hours(userId, employeeId, saved.id),
        }),
        queryClient.invalidateQueries({ queryKey: companyOverviewQueryKey(userId, employeeId) }),
        ...(branchChangedAttendanceBoundary(branchQuery.data, saved)
          ? [queryClient.invalidateQueries({ queryKey: attendanceQueryKeys.branches(userId) })]
          : []),
      ])
      setEditOpen(false)
      showToast({
        title: 'Branch updated',
        description: `${saved.branch_name} is up to date.`,
        tone: 'success',
      })
    },
  })

  const hoursMutation = useMutation({
    mutationFn: (input: Parameters<typeof branchesApi.updateBusinessHours>[1]) =>
      branchesApi.updateBusinessHours(branchId, input),
    onSuccess: async (saved) => {
      queryClient.setQueryData(branchQueryKeys.hours(userId, employeeId, branchId), saved)
      await queryClient.invalidateQueries({
        queryKey: branchQueryKeys.detail(userId, employeeId, branchId),
      })
      setHoursEditOpen(false)
      showToast({
        title: 'Business hours saved',
        description: 'The weekly schedule is up to date.',
        tone: 'success',
      })
    },
  })

  const geofenceMutation = useMutation({
    mutationFn: (input: BranchUpdateInput) => branchesApi.update(branchId, input),
    onSuccess: async (saved) => {
      queryClient.setQueryData(branchQueryKeys.detail(userId, employeeId, saved.id), saved)
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: branchQueryKeys.lists(userId, employeeId) }),
        queryClient.invalidateQueries({ queryKey: attendanceQueryKeys.branches(userId) }),
      ])
      showToast({
        title: 'Geofence updated',
        description: 'The attendance boundary is up to date.',
        tone: 'success',
      })
    },
  })

  const branch = branchQuery.data
  const hours = hoursQuery.data ?? []
  const backLink = (
    <Link to="/company/branch" search={search} className={pageBackLinkClassName}>
      <PageBackLinkContent>Branch directory</PageBackLinkContent>
    </Link>
  )

  if (!validBranchId) {
    return (
      <PageLayout title="Branch not found" backLink={backLink}>
        <EmptyState
          title="Branch not found"
          description="The branch link is invalid or the branch no longer exists."
          action={
            <Button
              variant="outline"
              onClick={() => void navigate({ to: '/company/branch', search })}
            >
              Back to branches
            </Button>
          }
        />
      </PageLayout>
    )
  }

  if (branchQuery.isPending && !branch) {
    return (
      <PageLayout title="Branch details" backLink={backLink}>
        <div className="space-y-4">
          <Skeleton className="h-28" />
          <Skeleton className="h-64" />
          <Skeleton className="h-48" />
        </div>
      </PageLayout>
    )
  }

  if (!branch && branchQuery.error) {
    const notFound = branchQuery.error instanceof ApiError && branchQuery.error.status === 404
    return (
      <PageLayout title={notFound ? 'Branch not found' : 'Branch details'} backLink={backLink}>
        {notFound ? (
          <EmptyState
            title="Branch not found"
            description="This branch may have been removed or is outside your assigned branch scope."
            action={
              <Button
                variant="outline"
                onClick={() => void navigate({ to: '/company/branch', search })}
              >
                Back to branches
              </Button>
            }
          />
        ) : (
          <ErrorState
            title="Branch details could not load"
            error={branchQuery.error}
            action={
              <Button variant="outline" onClick={() => void branchQuery.refetch()}>
                Retry branch details
              </Button>
            }
          />
        )}
      </PageLayout>
    )
  }

  if (!branch) return null

  return (
    <PageLayout
      title={branch.branch_name}
      subtitle={`${branch.branch_role_display} · ${[branch.city, branch.state, branch.country].filter(Boolean).join(', ')}`}
      backLink={backLink}
      actions={
        <>
          {canEditHours && !canEdit ? (
            <Button
              variant="outline"
              onClick={() => setHoursEditOpen(true)}
              disabled={!hoursQuery.data}
              leadingIcon={<CalendarClock className="size-4" aria-hidden="true" />}
            >
              Edit hours
            </Button>
          ) : null}
          {canEdit ? (
            <Button
              onClick={() => setEditOpen(true)}
              leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
            >
              Edit branch
            </Button>
          ) : null}
        </>
      }
    >
      <div className="space-y-5">
        {branchQuery.error && branchQuery.data ? (
          <Alert tone="warning" title="Showing saved branch details" role="status">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>
                Branch details could not refresh. Your saved information is still available.
              </span>
              <Button variant="ghost" size="sm" onClick={() => void branchQuery.refetch()}>
                Retry
              </Button>
            </div>
          </Alert>
        ) : null}

        <Card className="overflow-hidden p-0">
          <div className="from-primary-subtle/70 via-surface to-surface phone:flex-row phone:items-center phone:p-5 flex min-w-0 flex-col gap-4 bg-gradient-to-r p-4">
            <span className="bg-surface text-primary border-primary/10 rounded-surface shadow-elevation-sm phone:size-14 flex size-12 shrink-0 items-center justify-center border">
              <Building2 className="size-7" aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <div className="flex flex-wrap items-center gap-2">
                <span className="text-body-sm text-text-primary font-semibold">
                  {branch.branch_id}
                </span>
                <span className="text-text-muted" aria-hidden="true">
                  ·
                </span>
                <span className="text-body-sm text-text-secondary">
                  {branch.branch_role_display}
                </span>
                <StatusChip
                  label={branch.operational_status_display}
                  tone={operationalTone(branch.operational_status)}
                />
              </div>
              <div className="mt-3 flex flex-wrap gap-2">
                <StatusChip
                  label={branch.is_active ? 'Active record' : 'Inactive record'}
                  tone={branch.is_active ? 'info' : 'neutral'}
                  dense
                />
                <StatusChip
                  label={branch.is_operational ? 'Operational' : 'Not operational'}
                  tone={branch.is_operational ? 'success' : 'warning'}
                  dense
                />
              </div>
            </div>
          </div>
          <div className="border-border-subtle phone:grid-cols-3 phone:p-5 grid gap-3 border-t p-4">
            <div>
              <p className="text-caption text-text-secondary">Manager</p>
              <p className="text-body-sm text-text-primary mt-1 font-medium">
                {branch.manager_name || 'No manager assigned'}
              </p>
            </div>
            <div>
              <p className="text-caption text-text-secondary">Default currency</p>
              <p className="text-body-sm text-text-primary mt-1 font-medium">
                {branch.default_currency || 'Not set'}
              </p>
            </div>
            <div>
              <p className="text-caption text-text-secondary">Language</p>
              <p className="text-body-sm text-text-primary mt-1 font-medium">
                {branch.language_preference || 'Not set'}
              </p>
            </div>
          </div>
        </Card>

        <div className="desktop:grid-cols-2 grid min-w-0 gap-4">
          <Card className="phone:p-5 min-w-0 p-4">
            <div className="mb-4 flex items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                <MapPin className="size-5" aria-hidden="true" />
              </span>
              <div>
                <h2 className="text-label font-semibold">Location and contact</h2>
                <p className="text-caption text-text-secondary mt-0.5">
                  Where to find and reach this branch.
                </p>
              </div>
            </div>
            <div className="space-y-3">
              <ValueRow
                label="Office address"
                value={branch.full_address}
                icon={<MapPin className="size-4" />}
              />
              <ValueRow
                label="Contact email"
                value={branch.contact_email}
                href={`mailto:${branch.contact_email}`}
                icon={<Mail className="size-4" />}
              />
              <ValueRow
                label="Contact phone"
                value={branch.contact_phone}
                href={`tel:${branch.contact_phone}`}
                icon={<Phone className="size-4" />}
              />
              <ValueRow
                label="Manager"
                value={branch.manager_name}
                icon={<UserRound className="size-4" />}
              />
              <ValueRow
                label="Country code"
                value={branch.country_code}
                icon={<Globe2 className="size-4" />}
              />
            </div>
          </Card>

          <Card className="phone:p-5 min-w-0 p-4">
            <div className="mb-4 flex items-start justify-between gap-3">
              <div className="flex min-w-0 items-start gap-3">
                <span className="bg-info-subtle text-info-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
                  <MapPin className="size-5" aria-hidden="true" />
                </span>
                <div>
                  <h2 className="text-label font-semibold">Attendance geofence</h2>
                  <p className="text-caption text-text-secondary mt-0.5">
                    The GPS boundary used for attendance verification.
                  </p>
                </div>
              </div>
              {canEdit ? (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setGeofenceEditOpen(true)}
                  leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                  className="shrink-0"
                >
                  Update
                </Button>
              ) : null}
            </div>
            {branch.latitude == null || branch.longitude == null ? (
              <div className="border-border-subtle bg-surface-muted/50 rounded-control flex min-w-0 items-start gap-3 border p-4">
                <span className="bg-surface text-text-secondary rounded-control flex size-9 shrink-0 items-center justify-center">
                  <MapPin className="size-4" aria-hidden="true" />
                </span>
                <div className="min-w-0">
                  <p className="text-body-sm font-semibold">GPS point not set</p>
                  <p className="text-caption text-text-secondary mt-1">
                    Attendance at this branch does not have a saved location boundary.
                  </p>
                </div>
              </div>
            ) : (
              <div className="phone:grid-cols-2 grid gap-3">
                <div className="bg-surface-muted rounded-control p-3">
                  <p className="text-caption text-text-secondary">Latitude</p>
                  <p className="text-body-sm mt-1 font-semibold tabular-nums">
                    {branch.latitude.toFixed(6)}
                  </p>
                </div>
                <div className="bg-surface-muted rounded-control p-3">
                  <p className="text-caption text-text-secondary">Longitude</p>
                  <p className="text-body-sm mt-1 font-semibold tabular-nums">
                    {branch.longitude.toFixed(6)}
                  </p>
                </div>
                <div className="bg-surface-muted rounded-control phone:col-span-2 p-3">
                  <p className="text-caption text-text-secondary">Attendance radius</p>
                  <p className="text-body-sm mt-1 font-semibold">
                    {branch.attendance_radius_meters} metres
                  </p>
                </div>
              </div>
            )}
          </Card>
        </div>

        <Card className="phone:p-5 min-w-0 p-4">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-3">
            <div className="flex items-start gap-3">
              <span className="bg-info-subtle text-info-foreground rounded-control flex size-10 shrink-0 items-center justify-center">
                <CalendarClock className="size-5" aria-hidden="true" />
              </span>
              <div>
                <h2 className="text-label font-semibold">Business hours</h2>
                <p className="text-caption text-text-secondary mt-0.5">
                  Local branch time · unset days are not treated as closed.
                </p>
              </div>
            </div>
            {canEditHours ? (
              <Button
                variant="outline"
                size="sm"
                disabled={!hoursQuery.data}
                onClick={() => setHoursEditOpen(true)}
                leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
              >
                Edit hours
              </Button>
            ) : null}
          </div>
          {hoursQuery.isPending && !hoursQuery.data ? (
            <div className="phone:grid-cols-2 desktop:grid-cols-3 mt-4 grid gap-2">
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
              <Skeleton className="h-14" />
            </div>
          ) : hoursQuery.error && !hoursQuery.data ? (
            <SectionErrorState
              className="mt-4"
              title="Business hours could not load"
              error={hoursQuery.error}
              onRetry={() => void hoursQuery.refetch()}
            />
          ) : hoursQuery.error && hoursQuery.data ? (
            <Alert
              className="mt-4"
              tone="warning"
              title="Showing saved business hours"
              role="status"
            >
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>The weekly schedule could not refresh.</span>
                <Button variant="ghost" size="sm" onClick={() => void hoursQuery.refetch()}>
                  Retry
                </Button>
              </div>
            </Alert>
          ) : hours.length === 0 ? (
            <p className="text-body-sm text-text-secondary bg-surface-muted rounded-control mt-4 px-4 py-3">
              No business-hours schedule has been configured for this branch.
            </p>
          ) : (
            <div className="phone:grid-cols-2 desktop:grid-cols-3 mt-4 grid gap-2">
              {Array.from({ length: 7 }, (_, dayIndex) => {
                const day = hours.find((item) => item.day_of_week === dayIndex)
                const label =
                  day?.day_name ??
                  ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][
                    dayIndex
                  ]
                const value = displayHours(hours, dayIndex)
                return (
                  <div
                    key={dayIndex}
                    className="border-border-subtle bg-surface-muted/40 rounded-control flex min-w-0 items-center justify-between gap-3 border p-3"
                  >
                    <span className="text-body-sm font-medium">{label}</span>
                    <span
                      className={`text-caption text-right ${day?.is_open ? 'text-text-primary font-semibold tabular-nums' : 'text-text-secondary'}`}
                    >
                      {value}
                    </span>
                  </div>
                )
              })}
            </div>
          )}
        </Card>

        <Card className="phone:p-5 p-4">
          <div className="mb-3 flex items-center gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <Building2 className="size-5" aria-hidden="true" />
            </span>
            <div>
              <h2 className="text-label font-semibold">Notes</h2>
              <p className="text-caption text-text-secondary mt-0.5">Internal branch context.</p>
            </div>
          </div>
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {branch.notes?.trim() || 'No notes have been added.'}
          </p>
        </Card>
      </div>

      {canEdit ? (
        <BranchFormDialog
          open={editOpen}
          onOpenChange={setEditOpen}
          branch={branch}
          userId={userId}
          employeeId={employeeId}
          canEditHours={canEditHours}
          onSave={async (input) => {
            await saveMutation.mutateAsync(input)
          }}
        />
      ) : null}
      {canEdit ? (
        <BranchGeofenceDialog
          open={geofenceEditOpen}
          branch={branch}
          onOpenChange={setGeofenceEditOpen}
          onSave={async (input) => {
            await geofenceMutation.mutateAsync(input)
          }}
        />
      ) : null}
      {canEditHours && hoursQuery.data ? (
        <BranchHoursDialog
          open={hoursEditOpen}
          branch={branch}
          hours={hoursQuery.data}
          onOpenChange={setHoursEditOpen}
          onSave={async (input) => {
            await hoursMutation.mutateAsync(input)
          }}
        />
      ) : null}
    </PageLayout>
  )
}

function branchChangedAttendanceBoundary(before: BranchDto | undefined, after: BranchDto) {
  return (
    !before ||
    before.is_active !== after.is_active ||
    before.operational_status !== after.operational_status ||
    before.latitude !== after.latitude ||
    before.longitude !== after.longitude ||
    before.attendance_radius_meters !== after.attendance_radius_meters
  )
}
