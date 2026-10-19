import { useQuery } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import {
  ArrowUpRight,
  Award,
  BriefcaseBusiness,
  CalendarDays,
  ClipboardCheck,
  FileText,
  GraduationCap,
  Users,
} from 'lucide-react'

import {
  DashboardEmptyMessage,
  DashboardListRow,
  DashboardMetricStrip,
  DashboardPanel,
  DashboardPanelCard,
  type DashboardMetric,
} from '@/modules/dashboard/dashboard-components'
import { hrDashboardApi, hrOverviewQueryKey } from '@/modules/hr/hr-dashboard.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { PageLayout } from '@/shared/ui/page-layout'

function formatDateRange(start: string, end: string) {
  const date = new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' })
  const startLabel = date.format(new Date(`${start}T00:00:00`))
  const endLabel = date.format(new Date(`${end}T00:00:00`))
  return start === end ? startLabel : `${startLabel} – ${endLabel}`
}

export function HRDashboardPage() {
  const { data: session } = useQuery(authSessionQueryOptions())
  const summary = useQuery({
    queryKey: hrOverviewQueryKey,
    queryFn: ({ signal }) => hrDashboardApi.overview(signal),
    staleTime: 30_000,
  })
  const data = summary.data
  const permissions = session?.permissions ?? {}
  const metrics: DashboardMetric[] = []

  if (hasPermission(permissions, 'employees', 'list') && data?.total_employees != null) {
    metrics.push({
      label: 'Active employees',
      value: data.total_employees,
      icon: <Users className="size-4" aria-hidden="true" />,
      tone: 'primary',
    })
  }
  if (hasPermission(permissions, 'employees', 'list') && data?.new_hires_mtd != null) {
    metrics.push({
      label: 'New hires this month',
      value: data.new_hires_mtd,
      icon: <Users className="size-4" aria-hidden="true" />,
      tone: 'success',
    })
  }
  if (hasPermission(permissions, 'job_postings', 'list') && data?.open_roles != null) {
    metrics.push({
      label: 'Open roles',
      value: data.open_roles,
      icon: <BriefcaseBusiness className="size-4" aria-hidden="true" />,
      tone: 'warning',
    })
  }
  if (hasPermission(permissions, 'leave_requests', 'list') && data?.pending_leaves != null) {
    metrics.push({
      label: 'Pending leave requests',
      value: data.pending_leaves,
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
      tone: 'warning',
    })
  }

  const quickLinks = [
    {
      label: 'Employees',
      to: '/hr/employees',
      resource: 'employees',
      action: 'list',
      icon: <Users />,
    },
    {
      label: 'Attendance',
      to: '/hr/attendance',
      resource: 'attendance',
      action: 'list',
      alternative: 'list_own',
      icon: <CalendarDays />,
    },
    {
      label: 'Recruitment',
      to: '/hr/job-post',
      resource: 'job_postings',
      action: 'list',
      icon: <BriefcaseBusiness />,
    },
    {
      label: 'Leave requests',
      to: '/hr/leave-request',
      resource: 'leave_requests',
      action: 'list',
      icon: <FileText />,
    },
    {
      label: 'Work calendar',
      to: '/hr/attendance-calendar',
      resource: 'attendance_calendar',
      action: 'list',
      icon: <CalendarDays />,
    },
    {
      label: 'Training',
      to: '/hr/training-program',
      resource: 'training_programs',
      action: 'list',
      icon: <GraduationCap />,
    },
    {
      label: 'Performance',
      to: '/hr/performance-review',
      resource: 'performance_reviews',
      action: 'list',
      icon: <Award />,
    },
  ].filter(
    (item) =>
      hasPermission(permissions, item.resource, item.action) ||
      ('alternative' in item &&
        item.alternative !== undefined &&
        hasPermission(permissions, item.resource, item.alternative)),
  )

  const canViewHeadcount = hasPermission(permissions, 'employees', 'list')
  const headcount = canViewHeadcount ? (data?.headcount_by_department ?? null) : null
  const visibleHeadcount = headcount
    ? [...headcount].sort((a, b) => b.count - a.count).slice(0, 5)
    : null
  const largestDepartment = Math.max(1, ...(visibleHeadcount?.map((item) => item.count) ?? []))

  return (
    <PageLayout
      title="HR Dashboard"
      subtitle="Workforce capacity, hiring, and people requests within your authorized scope."
    >
      <div className="space-y-7">
        <DashboardMetricStrip
          metrics={metrics}
          loading={summary.isPending}
          error={summary.isError}
          onRetry={() => void summary.refetch()}
          emptyMessage="No HR summary values are available for your permissions and branch scope."
        />

        {quickLinks.length ? (
          <nav aria-label="HR dashboard shortcuts" className="flex flex-wrap gap-2">
            {quickLinks.map((item) => (
              <Link
                key={item.to}
                to={item.to as never}
                className="bg-surface border-border-subtle text-body-sm text-text-secondary focus-visible:shadow-focus-ring hover:border-primary/40 hover:text-primary rounded-pill inline-flex min-h-10 items-center gap-2 border px-3 transition-colors focus-visible:outline-none"
              >
                <span className="text-primary [&>svg]:size-4" aria-hidden="true">
                  {item.icon}
                </span>
                {item.label}
                <ArrowUpRight className="size-3.5" aria-hidden="true" />
              </Link>
            ))}
          </nav>
        ) : null}

        <div className="tablet:grid-cols-2 grid min-w-0 gap-6">
          {canViewHeadcount ? (
            <DashboardPanel
              title="Headcount by department"
              description="Active employees across the branches available to your role."
              icon={<Users className="size-5" aria-hidden="true" />}
            >
              <DashboardPanelCard>
                {summary.isPending ? (
                  <div
                    className="space-y-5"
                    aria-label="Loading department headcount"
                    role="status"
                  >
                    <div className="rounded-pill h-3 animate-pulse bg-neutral-100" />
                    <div className="rounded-pill h-3 animate-pulse bg-neutral-100" />
                    <div className="rounded-pill h-3 animate-pulse bg-neutral-100" />
                  </div>
                ) : summary.isError ? (
                  <p className="text-body-sm text-text-secondary">
                    Department data is unavailable.
                  </p>
                ) : visibleHeadcount?.length ? (
                  <>
                    <ul className="space-y-4">
                      {visibleHeadcount.map((item, index) => (
                        <li
                          key={item.department}
                          className="dashboard-enter grid min-w-0 grid-cols-[minmax(5.5rem,8rem)_minmax(2rem,1fr)_2rem] items-center gap-3"
                          style={{ animationDelay: `${index * 45}ms` }}
                        >
                          <span className="text-body-sm text-text-primary truncate">
                            {item.department}
                          </span>
                          <span
                            className="bg-surface-muted rounded-pill h-2.5 overflow-hidden"
                            role="img"
                            aria-label={`${item.department}: ${item.count} employees`}
                          >
                            <span
                              className="dashboard-progress-fill bg-primary rounded-pill block h-full"
                              style={{
                                width: `${Math.max(5, (item.count / largestDepartment) * 100)}%`,
                              }}
                            />
                          </span>
                          <span className="text-body-sm text-text-primary text-right font-semibold tabular-nums">
                            {item.count}
                          </span>
                        </li>
                      ))}
                    </ul>
                    {headcount && headcount.length > 5 ? (
                      <p className="text-caption text-text-muted mt-4">
                        Showing the five largest departments.
                      </p>
                    ) : null}
                  </>
                ) : (
                  <DashboardEmptyMessage
                    title="No department assignments"
                    description="Headcount will appear when active employees are assigned to departments."
                  />
                )}
              </DashboardPanelCard>
            </DashboardPanel>
          ) : null}

          {hasPermission(permissions, 'leave_requests', 'list') ? (
            <DashboardPanel
              title="Requests awaiting review"
              description="Leave, absence, and late-arrival requests in your review scope."
              icon={<ClipboardCheck className="size-5" aria-hidden="true" />}
              action={
                <Link
                  to="/hr/leave-request"
                  className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                >
                  Review requests <ArrowUpRight className="size-4" aria-hidden="true" />
                </Link>
              }
            >
              <DashboardPanelCard className="phone:p-5 p-4">
                {summary.isPending ? (
                  <div className="space-y-4" aria-label="Loading review requests" role="status">
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                    <div className="rounded-control h-10 animate-pulse bg-neutral-100" />
                  </div>
                ) : summary.isError ? (
                  <p className="text-body-sm text-text-secondary">
                    Review requests are unavailable.
                  </p>
                ) : data?.review_queue?.length ? (
                  <ul className="divide-border-subtle divide-y">
                    {data.review_queue.slice(0, 5).map((item) => (
                      <DashboardListRow
                        key={item.id}
                        icon={<ClipboardCheck className="size-4" aria-hidden="true" />}
                        tone="warning"
                        title={item.employee_name}
                        description={`${item.request_label} · ${formatDateRange(item.start_date, item.end_date)}`}
                        trailing="Pending"
                        trailingTone="warning"
                      />
                    ))}
                  </ul>
                ) : (
                  <DashboardEmptyMessage
                    title="No requests waiting"
                    description="Requests needing HR review will appear here."
                  />
                )}
              </DashboardPanelCard>
            </DashboardPanel>
          ) : null}
        </div>
      </div>
    </PageLayout>
  )
}
