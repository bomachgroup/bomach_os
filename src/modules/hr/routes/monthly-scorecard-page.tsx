import { useQuery } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { CalendarDays, ChartNoAxesCombined, Flag, Medal, Target } from 'lucide-react'
import type { ReactNode } from 'react'

import type { EmployeeScorecardDto } from '@/modules/hr/employees.api'
import { performanceScorecardOptions } from '@/modules/hr/performance-analytics.queries'
import { type ScorecardSearch } from '@/modules/hr/performance-analytics.search'
import { ApiError } from '@/shared/api/api-error'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip } from '@/shared/ui/status-chip'

const MONTHS = Array.from({ length: 12 }, (_, index) => ({
  value: String(index + 1),
  label: new Intl.DateTimeFormat(undefined, { month: 'long' }).format(new Date(2024, index, 1)),
}))

function years(): { value: string; label: string }[] {
  const currentYear = new Date().getFullYear()
  return Array.from({ length: 5 }, (_, index) => {
    const year = currentYear - 2 + index
    return { value: String(year), label: String(year) }
  })
}

function formatPeriod(month: number, year: number): string {
  return new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(
    new Date(year, month - 1, 1),
  )
}

function scoreValue(value: number | string): number {
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : 0
}

function MetricRow({ label, value }: { label: string; value: number | string }) {
  const score = scoreValue(value)
  const boundedScore = Math.max(0, Math.min(100, score))
  return (
    <div className="min-w-0 py-3 first:pt-0 last:pb-0">
      <div className="flex min-w-0 items-center justify-between gap-3">
        <h3 className="text-label text-text-primary min-w-0 truncate font-semibold">{label}</h3>
        <span className="text-caption text-text-secondary shrink-0 font-semibold tabular-nums">
          {score.toFixed(1)}%
        </span>
      </div>
      <ProgressBar
        value={boundedScore}
        label={`${label}: ${score.toFixed(1)} percent`}
        className="mt-2 h-2"
      />
    </div>
  )
}

function ScorecardSummary({ scorecard }: { scorecard: EmployeeScorecardDto }) {
  const overall = scoreValue(scorecard.overall_score)
  const targetScore = scoreValue(scorecard.target_score)
  const targetAchievement = scoreValue(scorecard.target_achievement)
  const employeeName = scorecard.employee_name?.trim() || 'Employee scorecard'
  const metrics = [
    ['Attendance', scorecard.attendance_score],
    ['Task delivery', scorecard.task_delivery_score],
    ['Report accuracy', scorecard.report_accuracy_score],
    ['Brand contribution', scorecard.brand_contribution_score],
    ['Training progress', scorecard.training_progress_score],
  ] as const

  return (
    <div className="space-y-4">
      <Card className="tablet:p-5 overflow-hidden p-4">
        <div className="tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-5">
          <div className="flex min-w-0 items-center gap-3">
            <span className="bg-primary-subtle text-primary flex size-12 shrink-0 items-center justify-center rounded-2xl">
              <ChartNoAxesCombined className="size-6" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <h2 className="text-h3 text-text-primary truncate font-semibold">{employeeName}</h2>
              <p className="text-caption text-text-secondary mt-1 truncate">
                {scorecard.employee_level?.trim() || 'Monthly performance summary'}
              </p>
            </div>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <StatusChip
              label={scorecard.is_auto_generated ? 'System generated' : 'HR adjusted'}
              tone={scorecard.is_auto_generated ? 'info' : 'neutral'}
            />
            <StatusChip label={formatPeriod(scorecard.month, scorecard.year)} tone="primary" />
          </div>
        </div>
      </Card>

      <section aria-label="Scorecard summary" className="tablet:grid-cols-4 grid gap-3">
        <Card className="from-primary to-primary-hover text-text-on-primary flex min-h-32 flex-col justify-center bg-gradient-to-br p-5">
          <p className="text-caption text-text-on-primary/80 font-medium">Overall score</p>
          <p className="mt-1 text-4xl font-semibold tabular-nums">{overall.toFixed(1)}%</p>
          <ProgressBar
            value={Math.max(0, Math.min(100, overall))}
            label={`Overall score ${overall.toFixed(1)} percent`}
            className="mt-3 h-1.5 bg-white/25 [&>span]:bg-white"
          />
        </Card>
        <SummaryCard
          icon={<Target className="size-5" aria-hidden="true" />}
          label="Target achievement"
          value={`${targetAchievement.toFixed(1)}%`}
          detail={targetAchievement >= 100 ? 'Target exceeded' : 'Of target reached'}
        />
        <SummaryCard
          icon={<Medal className="size-5" aria-hidden="true" />}
          label="Ranking"
          value={scorecard.ranking == null ? '—' : `#${scorecard.ranking}`}
          detail="For this period"
        />
        <SummaryCard
          icon={<Flag className="size-5" aria-hidden="true" />}
          label="Target score"
          value={`${targetScore.toFixed(1)}%`}
          detail="Expected performance"
        />
      </section>

      <Card className="tablet:p-5 space-y-4 p-4">
        <div>
          <h2 className="text-h3 text-text-primary font-semibold">Performance breakdown</h2>
          <p className="text-caption text-text-secondary mt-1">
            The five measures contributing to this month’s scorecard.
          </p>
        </div>
        <div className="divide-border-subtle divide-y">
          {metrics.map(([label, value]) => (
            <MetricRow key={label} label={label} value={value} />
          ))}
        </div>
      </Card>

      {scorecard.notes.trim() ? (
        <Card className="tablet:p-5 p-4">
          <h2 className="text-label text-text-primary font-semibold">HR notes</h2>
          <p className="text-body-sm text-text-secondary mt-2 leading-relaxed whitespace-pre-wrap">
            {scorecard.notes}
          </p>
        </Card>
      ) : null}
    </div>
  )
}

function SummaryCard({
  icon,
  label,
  value,
  detail,
}: {
  icon: ReactNode
  label: string
  value: string
  detail: string
}) {
  return (
    <Card className="min-w-0 p-4">
      <div className="flex items-center gap-2">
        <span className="text-primary" aria-hidden="true">
          {icon}
        </span>
        <p className="text-caption text-text-secondary truncate">{label}</p>
      </div>
      <p className="text-h2 text-text-primary mt-3 font-semibold tabular-nums">{value}</p>
      <p className="text-overline text-text-muted mt-1">{detail}</p>
    </Card>
  )
}

export function MonthlyScorecardPage() {
  const search = useSearch({ from: '/_protected/hr/monthly-scorecard' }) as ScorecardSearch
  const navigate = useNavigate()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const canView =
    hasPermission(permissions, 'monthly_scorecards', 'view') ||
    hasPermission(permissions, 'monthly_scorecards', 'view_own')
  const employeeRecordId = session?.employee.id
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const scorecardQuery = useQuery({
    ...performanceScorecardOptions(
      userId,
      employeeKey,
      employeeRecordId ?? 0,
      search.month,
      search.year,
    ),
    enabled: Boolean(session && canView && employeeRecordId),
  })

  const updateSearch = (updates: Partial<ScorecardSearch>) =>
    void navigate({
      to: '/hr/monthly-scorecard',
      search: (previous: ScorecardSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Monthly Scorecard">
        <ErrorState
          title="Your HR session could not be loaded"
          description="Retry loading your employee profile and scorecard access."
          error={sessionQuery.error}
          action={<Button onClick={() => void sessionQuery.refetch()}>Try again</Button>}
        />
      </PageLayout>
    )
  }

  if (session && !canView) {
    return (
      <PageLayout title="Monthly Scorecard">
        <ErrorState
          title="You can’t view this scorecard"
          description="Your role does not have permission to view monthly scorecards."
        />
      </PageLayout>
    )
  }

  if (session && !employeeRecordId) {
    return (
      <PageLayout title="Monthly Scorecard">
        <ErrorState
          title="Employee record unavailable"
          description="Your profile does not include an employee record, so a scorecard cannot be loaded."
        />
      </PageLayout>
    )
  }

  const noScorecard =
    scorecardQuery.error instanceof ApiError && scorecardQuery.error.status === 404

  return (
    <PageLayout
      title="Monthly Scorecard"
      subtitle="A measured view of your performance for the selected period."
      leading={<ChartNoAxesCombined className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="tablet:flex-row tablet:items-end tablet:justify-between flex flex-col gap-4 p-4">
          <div className="min-w-0">
            <p className="text-overline text-primary font-semibold">Review period</p>
            <h2 className="text-h3 text-text-primary mt-1 font-semibold">
              {formatPeriod(search.month, search.year)}
            </h2>
            <p className="text-caption text-text-secondary mt-1">
              Select a month to view the scorecard currently recorded for your employee profile.
            </p>
          </div>
          <div className="phone:grid-cols-2 tablet:max-w-md grid w-full gap-3">
            <FormControl id="scorecard-month" label="Month" className="min-w-0">
              <DropdownSelect
                value={String(search.month)}
                options={MONTHS}
                onChange={(value) => updateSearch({ month: Number(value) })}
                aria-label="Select scorecard month"
              />
            </FormControl>
            <FormControl id="scorecard-year" label="Year" className="min-w-0">
              <DropdownSelect
                value={String(search.year)}
                options={years()}
                onChange={(value) => updateSearch({ year: Number(value) })}
                aria-label="Select scorecard year"
              />
            </FormControl>
          </div>
        </Card>

        {scorecardQuery.isPending ? (
          <div className="space-y-3" aria-label="Loading monthly scorecard">
            <Skeleton className="h-20 w-full" />
            <div className="tablet:grid-cols-4 grid gap-3">
              {[0, 1, 2, 3].map((item) => (
                <Skeleton key={item} className="h-32 w-full" />
              ))}
            </div>
            <Skeleton className="h-72 w-full" />
          </div>
        ) : noScorecard ? (
          <Card>
            <EmptyState
              icon={<CalendarDays className="size-6" aria-hidden="true" />}
              title="No scorecard for this period"
              description="A scorecard has not been recorded for this month. It will appear here once it is available."
            />
          </Card>
        ) : scorecardQuery.isError && !scorecardQuery.data ? (
          <Card>
            <SectionErrorState
              title="Scorecard could not be loaded"
              description="Your selected period is unchanged. Retry to check the scorecard service."
              onRetry={() => void scorecardQuery.refetch()}
              error={scorecardQuery.error}
            />
          </Card>
        ) : scorecardQuery.data ? (
          <>
            {scorecardQuery.isError ? (
              <SectionErrorState
                title="Showing saved scorecard data"
                description="The latest refresh failed; these values may be out of date."
                onRetry={() => void scorecardQuery.refetch()}
                error={scorecardQuery.error}
              />
            ) : null}
            <ScorecardSummary scorecard={scorecardQuery.data} />
          </>
        ) : null}
      </div>
    </PageLayout>
  )
}
