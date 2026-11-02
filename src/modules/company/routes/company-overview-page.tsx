import { useQuery } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { ArrowUpRight, Building2, ClipboardCheck, GitBranch, PackageSearch } from 'lucide-react'

import {
  DashboardEmptyMessage,
  DashboardListRow,
  DashboardMetricStrip,
  DashboardPanel,
  DashboardPanelCard,
  type DashboardMetric,
} from '@/modules/dashboard/dashboard-components'
import {
  companyDashboardApi,
  companyIdentityQueryKeys,
  companyOverviewQueryKey,
} from '@/modules/company/company-dashboard.api'
import { CompanyLogoImage } from '@/modules/company/components/company-logo-image'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'

function formatShortDate(value: string) {
  return new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' }).format(
    new Date(value),
  )
}

export function CompanyOverviewPage() {
  const { data: session } = useQuery(authSessionQueryOptions())
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const summary = useQuery({
    queryKey: companyOverviewQueryKey(userId, employeeId),
    queryFn: ({ signal }) => companyDashboardApi.overview(signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const data = summary.data
  const permissions = session?.permissions ?? {}
  const canViewCompanyIdentity = hasPermission(permissions, 'company_settings', 'view')
  const companyProfile = useQuery({
    queryKey: companyIdentityQueryKeys.profile(userId),
    queryFn: ({ signal }) => companyDashboardApi.profile(signal),
    enabled: Boolean(session && canViewCompanyIdentity),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const companyBranding = useQuery({
    queryKey: companyIdentityQueryKeys.branding(userId),
    queryFn: ({ signal }) => companyDashboardApi.branding(signal),
    enabled: Boolean(session && canViewCompanyIdentity),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const metrics: DashboardMetric[] = []

  if (hasPermission(permissions, 'branches', 'list') && data?.total_branches != null) {
    metrics.push({
      label: 'Branches',
      value: data.total_branches,
      detail:
        data.operational_branches == null || data.non_operational_branches == null
          ? data.inactive_branches_30_days == null
            ? 'Operating footprint'
            : `${data.inactive_branches_30_days} recently inactive`
          : `${data.operational_branches} operational · ${data.non_operational_branches} non-operational`,
      icon: <GitBranch className="size-4" aria-hidden="true" />,
      tone: 'primary',
    })
  }
  if (
    (hasPermission(permissions, 'departments', 'list') ||
      hasPermission(permissions, 'department_units', 'list')) &&
    data?.departments_count != null
  ) {
    metrics.push({
      label: 'Departments',
      value: data.departments_count,
      detail:
        data.units_count == null
          ? 'Organization structure'
          : `${data.units_count} units across the organization`,
      icon: <Building2 className="size-4" aria-hidden="true" />,
      tone: 'info',
    })
  }
  if (hasPermission(permissions, 'approval_requests', 'list') && data?.pending_approvals != null) {
    metrics.push({
      label: 'Pending approvals',
      value: data.pending_approvals,
      detail:
        data.overdue_approvals == null ? 'Governance queue' : `${data.overdue_approvals} overdue`,
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
      tone: data.overdue_approvals ? 'danger' : data.pending_approvals ? 'warning' : 'success',
    })
  }
  if (hasPermission(permissions, 'assets', 'list') && data?.asset_count != null) {
    metrics.push({
      label: 'Tracked assets',
      value: data.asset_count,
      detail:
        data.assets_added_30_days == null
          ? 'Company inventory'
          : `${data.assets_added_30_days} added in 30 days`,
      icon: <PackageSearch className="size-4" aria-hidden="true" />,
      tone: 'success',
    })
  }

  const links: { label: string; to: string; icon: ReactNode }[] = []
  if (hasPermission(permissions, 'branches', 'list')) {
    links.push({
      label: 'Branches',
      to: '/company/branch',
      icon: <GitBranch className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'departments', 'list')) {
    links.push({
      label: 'Departments & units',
      to: '/company/department',
      icon: <Building2 className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'approval_flows', 'list')) {
    links.push({
      label: 'Approval workflows',
      to: '/company/approval-workflow',
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'approval_requests', 'list')) {
    links.push({
      label: 'Approval requests',
      to: '/company/approval-requests',
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'assets', 'list')) {
    links.push({
      label: 'Assets',
      to: '/company/assets',
      icon: <PackageSearch className="size-4" aria-hidden="true" />,
    })
  }

  return (
    <PageLayout
      title="Company Overview"
      subtitle="A focused view of organization structure, governance, and company assets."
    >
      <div className="space-y-7">
        {canViewCompanyIdentity ? (
          <Card className="phone:p-5 tablet:flex-row tablet:items-center tablet:gap-5 tablet:p-6 flex min-w-0 flex-col gap-4 p-4">
            <CompanyLogoImage
              src={companyBranding.data?.company_logo}
              alt=""
              className="border-border-subtle bg-surface-muted rounded-control tablet:size-20 size-16 shrink-0 border object-contain p-2"
              fallback={
                <span
                  className="bg-primary-subtle text-primary rounded-control tablet:size-20 flex size-16 shrink-0 items-center justify-center"
                  aria-hidden="true"
                >
                  <Building2 className="size-8" />
                </span>
              }
            />
            <div className="min-w-0 flex-1">
              {companyProfile.isPending ? (
                <Skeleton className="h-7 w-56 max-w-full" />
              ) : companyProfile.data ? (
                <>
                  <p className="text-overline text-text-secondary font-semibold">Company</p>
                  <h2 className="text-h2 text-text-primary mt-1 font-semibold break-words">
                    {companyProfile.data.company_name}
                  </h2>
                  {companyBranding.data?.company_slogan ? (
                    <p className="text-body-sm text-text-secondary mt-1.5">
                      {companyBranding.data.company_slogan}
                    </p>
                  ) : null}
                </>
              ) : companyProfile.isError ? (
                <div className="flex flex-wrap items-center gap-3">
                  <p className="text-body-sm text-text-secondary">
                    Company identity is temporarily unavailable.
                  </p>
                  <Button size="sm" variant="ghost" onClick={() => void companyProfile.refetch()}>
                    Retry
                  </Button>
                </div>
              ) : (
                <p className="text-body-sm text-text-secondary">
                  Company identity has not been set up.
                </p>
              )}
              {companyProfile.isError && companyProfile.data ? (
                <button
                  type="button"
                  onClick={() => void companyProfile.refetch()}
                  className="text-caption text-text-muted hover:text-primary focus-visible:shadow-focus-ring mt-1 rounded-xs underline underline-offset-2 focus-visible:outline-none"
                >
                  Identity refresh failed · Retry
                </button>
              ) : null}
              {companyBranding.isError ? (
                <button
                  type="button"
                  onClick={() => void companyBranding.refetch()}
                  className="text-caption text-text-muted hover:text-primary focus-visible:shadow-focus-ring mt-1 rounded-xs underline underline-offset-2 focus-visible:outline-none"
                >
                  Branding is unavailable · Retry
                </button>
              ) : null}
            </div>
          </Card>
        ) : null}

        <DashboardMetricStrip
          metrics={metrics}
          loading={summary.isPending}
          error={summary.isError && !data}
          onRetry={() => void summary.refetch()}
          emptyMessage="No company summary values are available for your permissions and branch scope."
        />

        <div className="wide:grid-cols-[minmax(0,1.15fr)_minmax(19rem,0.85fr)] grid min-w-0 gap-6">
          {hasPermission(permissions, 'approval_requests', 'list') ? (
            <DashboardPanel
              title="Approval queue"
              description="The oldest pending requests in your authorized organization scope."
              icon={<ClipboardCheck className="size-5" aria-hidden="true" />}
              action={
                <div className="flex flex-wrap items-center gap-1">
                  <Link
                    to="/company/approval-requests"
                    search={{ status: 'pending', search: '', page: 1 }}
                    className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                  >
                    Review approvals <ArrowUpRight className="size-4" aria-hidden="true" />
                  </Link>
                  {hasPermission(permissions, 'approval_flows', 'list') ? (
                    <Link
                      to="/company/approval-workflow"
                      className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                    >
                      Workflows <ArrowUpRight className="size-4" aria-hidden="true" />
                    </Link>
                  ) : null}
                </div>
              }
            >
              <DashboardPanelCard className="phone:p-5 p-4">
                {summary.isPending ? (
                  <div className="space-y-4" aria-label="Loading approvals" role="status">
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                  </div>
                ) : summary.isError && !data ? (
                  <p className="text-body-sm text-text-secondary">Approval preview unavailable.</p>
                ) : data?.approval_queue?.length ? (
                  <ul className="divide-border-subtle divide-y">
                    {data.approval_queue.slice(0, 5).map((item) => (
                      <DashboardListRow
                        key={item.id}
                        icon={<ClipboardCheck className="size-4" aria-hidden="true" />}
                        tone="warning"
                        title={item.title}
                        description={`${item.action_type}${item.requester_name ? ` · ${item.requester_name}` : ''}`}
                        trailing={
                          <span className="text-right">
                            <time dateTime={item.created_at} className="block">
                              {formatShortDate(item.created_at)}
                            </time>
                            <span className="text-overline text-text-muted block">
                              {waitingDuration(item.created_at)}
                            </span>
                          </span>
                        }
                      />
                    ))}
                  </ul>
                ) : (
                  <DashboardEmptyMessage
                    title="No pending requests"
                    description="New governance approvals will appear here when they need review."
                  />
                )}
              </DashboardPanelCard>
            </DashboardPanel>
          ) : null}

          <DashboardPanel
            title="Organization structure"
            description="Move directly to the company records available to you."
            icon={<Building2 className="size-5" aria-hidden="true" />}
          >
            <DashboardPanelCard className="phone:p-3 p-2">
              {links.length ? (
                <ul className="divide-border-subtle divide-y">
                  {links.map((item) => (
                    <DashboardListRow
                      key={item.to}
                      icon={item.icon}
                      title={item.label}
                      trailing={<ArrowUpRight className="size-4" aria-hidden="true" />}
                      href={item.to}
                    />
                  ))}
                </ul>
              ) : (
                <DashboardEmptyMessage
                  title="No company sections available"
                  description="Your assigned permissions will appear here when company access is available."
                />
              )}
            </DashboardPanelCard>
          </DashboardPanel>
        </div>
      </div>
    </PageLayout>
  )
}

function waitingDuration(value: string) {
  const createdAt = new Date(value).getTime()
  if (!Number.isFinite(createdAt)) return 'Age unavailable'
  const elapsedHours = Math.floor(Math.max(0, Date.now() - createdAt) / 3_600_000)
  if (elapsedHours < 1) return 'Just received'
  if (elapsedHours < 24) return `${elapsedHours}h waiting`
  const days = Math.floor(elapsedHours / 24)
  return `${days} ${days === 1 ? 'day' : 'days'} waiting`
}
