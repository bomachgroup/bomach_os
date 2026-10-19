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
  companyOverviewQueryKey,
} from '@/modules/company/company-dashboard.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { PageLayout } from '@/shared/ui/page-layout'

function formatShortDate(value: string) {
  return new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' }).format(
    new Date(value),
  )
}

export function CompanyOverviewPage() {
  const { data: session } = useQuery(authSessionQueryOptions())
  const summary = useQuery({
    queryKey: companyOverviewQueryKey,
    queryFn: ({ signal }) => companyDashboardApi.overview(signal),
    staleTime: 30_000,
  })
  const data = summary.data
  const permissions = session?.permissions ?? {}
  const metrics: DashboardMetric[] = []

  if (hasPermission(permissions, 'branches', 'list') && data?.total_branches != null) {
    metrics.push({
      label: 'Branches',
      value: data.total_branches,
      detail:
        data.inactive_branches_30_days == null
          ? 'Operating footprint'
          : `${data.inactive_branches_30_days} recently inactive`,
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
        <DashboardMetricStrip
          metrics={metrics}
          loading={summary.isPending}
          error={summary.isError}
          onRetry={() => void summary.refetch()}
          emptyMessage="No company summary values are available for your permissions and branch scope."
        />

        <div className="wide:grid-cols-[minmax(0,1.15fr)_minmax(19rem,0.85fr)] grid min-w-0 gap-6">
          {hasPermission(permissions, 'approval_requests', 'list') ? (
            <DashboardPanel
              title="Approval queue"
              description="The latest requests in your authorized organization scope."
              icon={<ClipboardCheck className="size-5" aria-hidden="true" />}
              action={
                hasPermission(permissions, 'approval_flows', 'list') ? (
                  <Link
                    to="/company/approval-workflow"
                    className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                  >
                    Workflows <ArrowUpRight className="size-4" aria-hidden="true" />
                  </Link>
                ) : null
              }
            >
              <DashboardPanelCard className="phone:p-5 p-4">
                {summary.isPending ? (
                  <div className="space-y-4" aria-label="Loading approvals" role="status">
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                  </div>
                ) : summary.isError ? (
                  <p className="text-body-sm text-text-secondary">
                    Approval previews are unavailable while the summary retries.
                  </p>
                ) : data?.approval_queue?.length ? (
                  <ul className="divide-border-subtle divide-y">
                    {data.approval_queue.slice(0, 5).map((item) => (
                      <DashboardListRow
                        key={item.id}
                        icon={<ClipboardCheck className="size-4" aria-hidden="true" />}
                        tone="warning"
                        title={item.title}
                        description={`${item.action_type}${item.requester_name ? ` · ${item.requester_name}` : ''}`}
                        trailing={formatShortDate(item.created_at)}
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
