import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { Award, CalendarDays, ChartNoAxesCombined, Medal, Trophy, UsersRound } from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Card } from '@/shared/ui/card'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'

import { leaderboardOptions } from '../recognition.queries'
import type { LeaderboardEntry } from '../recognition.api'
import type { LeaderboardSearch } from '../recognition.search'

const MONTH_OPTIONS = Array.from({ length: 12 }, (_, index) => ({
  value: String(index + 1),
  label: new Intl.DateTimeFormat(undefined, { month: 'long' }).format(new Date(2024, index, 1)),
}))

function makeYearOptions(): { value: string; label: string }[] {
  const year = new Date().getFullYear()
  return Array.from({ length: 6 }, (_, index) => ({
    value: String(year - index),
    label: String(year - index),
  }))
}

function formatPeriod(month: number, year: number): string {
  return new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(
    new Date(year, month - 1, 1),
  )
}

function rankLabel(rank: number): string {
  if (rank === 1) return '1st'
  if (rank === 2) return '2nd'
  if (rank === 3) return '3rd'
  return `${rank}th`
}

function Score({ value }: { value: number }) {
  return (
    <div className="min-w-24">
      <div className="flex items-center justify-between gap-3">
        <span className="text-label text-text-primary font-semibold tabular-nums">
          {value.toFixed(1)}%
        </span>
        <span className="text-overline text-text-muted">score</span>
      </div>
      <ProgressBar
        value={value}
        label={`Score ${value.toFixed(1)} percent`}
        className="mt-1.5 h-1.5"
      />
    </div>
  )
}

function LeaderCard({ entry, featured = false }: { entry: LeaderboardEntry; featured?: boolean }) {
  const Icon = entry.rank === 1 ? Trophy : Medal
  return (
    <article
      className={`border-border-subtle shadow-elevation-sm rounded-surface flex min-w-0 flex-col border p-4 ${
        featured ? 'from-primary-subtle/80 to-surface bg-gradient-to-br' : 'bg-surface'
      }`}
    >
      <div className="flex items-start gap-3">
        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
          <Icon className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 items-start justify-between gap-2">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">
                {rankLabel(entry.rank)} place
              </p>
              <h3 className="text-body-lg text-text-primary mt-1 font-semibold break-words">
                {entry.employeeName?.trim() || `Employee #${entry.employeeId}`}
              </h3>
            </div>
            <span className="bg-surface text-primary text-caption shrink-0 rounded-full px-2.5 py-1 font-semibold tabular-nums">
              {entry.score.toFixed(1)}%
            </span>
          </div>
          <p className="text-caption text-text-secondary mt-1 truncate">
            {entry.branch?.trim() || 'Branch details unavailable'}
          </p>
          <div className="mt-3">
            <ProgressBar
              value={entry.score}
              label={`${entry.score.toFixed(1)} percent`}
              className="h-1.5"
            />
          </div>
        </div>
      </div>
    </article>
  )
}

function useLeaderboardData() {
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const search = useSearch({ from: '/_protected/hr/performance-leaderboard' }) as LeaderboardSearch
  const canList = hasPermission(session?.permissions ?? {}, 'monthly_scorecards', 'list')
  const query = useQuery({
    ...leaderboardOptions(
      session?.user.id ?? 0,
      session?.employee.employee_id ?? '',
      search.month,
      search.year,
    ),
    enabled: Boolean(session && canList),
    placeholderData: keepPreviousData,
  })
  return { sessionQuery, session, canList, search, query, data: query.data }
}

export function PerformanceLeaderboardPage() {
  const { sessionQuery, session, canList, search, query, data } = useLeaderboardData()
  const navigate = useNavigate()
  const updateSearch = (updates: Partial<LeaderboardSearch>) =>
    void navigate({
      to: '/hr/performance-leaderboard',
      search: (previous: LeaderboardSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })

  if (sessionQuery.isError) {
    return (
      <PageLayout title="Performance leaderboard">
        <ErrorState
          title="Your HR access could not be loaded"
          description="Retry loading your account and leaderboard access."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }
  if (session && !canList) {
    return (
      <PageLayout title="Performance leaderboard">
        <ErrorState
          title="You can’t view the leaderboard"
          description="Your account does not have permission to view monthly scorecards."
        />
      </PageLayout>
    )
  }

  const entries = data?.entries ?? []
  const topThree = entries.filter((entry) => entry.rank <= 3).sort((a, b) => a.rank - b.rank)
  const remaining = entries.filter((entry) => entry.rank > 3).sort((a, b) => a.rank - b.rank)

  return (
    <PageLayout
      title="Performance leaderboard"
      subtitle="Monthly scorecard rankings across the branches available to your role."
      leading={<ChartNoAxesCombined className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Monthly scorecards</p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">Leaderboard</h2>
              <p className="text-caption text-text-secondary mt-1">
                Choose a period to view its available rankings.
              </p>
            </div>
            <span className="bg-primary-subtle text-primary text-caption inline-flex items-center gap-2 rounded-full px-3 py-1.5 font-semibold">
              <CalendarDays className="size-4" aria-hidden="true" />
              {formatPeriod(search.month, search.year)}
            </span>
          </div>
          <div className="grid max-w-2xl gap-3 min-[400px]:grid-cols-2">
            <FormControl id="leaderboard-month" label="Month" className="min-w-0">
              <DropdownSelect
                value={String(search.month)}
                options={MONTH_OPTIONS}
                onChange={(value) => updateSearch({ month: Number(value) })}
                aria-label="Select leaderboard month"
              />
            </FormControl>
            <FormControl id="leaderboard-year" label="Year" className="min-w-0">
              <DropdownSelect
                value={String(search.year)}
                options={makeYearOptions()}
                onChange={(value) => updateSearch({ year: Number(value) })}
                aria-label="Select leaderboard year"
              />
            </FormControl>
          </div>
        </Card>

        {query.isPending ? (
          <div className="tablet:grid-cols-3 grid gap-3" aria-label="Loading leaderboard">
            {[0, 1, 2].map((item) => (
              <Skeleton key={item} className="h-32 w-full" />
            ))}
          </div>
        ) : query.isError && !data ? (
          <Card>
            <SectionErrorState
              title="Leaderboard could not be loaded"
              description="Your selected period is unchanged. Retry to load its scorecards."
              onRetry={() => void query.refetch()}
            />
          </Card>
        ) : (
          <>
            {query.isError ? (
              <SectionErrorState
                title="Showing saved leaderboard results"
                description="The latest refresh failed. Retry to check for updated rankings."
                onRetry={() => void query.refetch()}
              />
            ) : null}
            {entries.length > 0 ? (
              <Card className="tablet:p-5 space-y-4 p-4">
                <div>
                  <p className="text-overline text-primary font-semibold">Performance summary</p>
                  <h2 className="text-h3 text-text-primary mt-1 font-semibold">
                    Period at a glance
                  </h2>
                  <p className="text-caption text-text-secondary mt-1">
                    Scorecard performance for {formatPeriod(search.month, search.year)}.
                  </p>
                </div>
                <div className="phone:grid-cols-3 grid gap-3">
                  <SummaryMetric
                    label="Average score"
                    value={`${data?.averageScore.toFixed(1) ?? '0.0'}%`}
                    icon={<ChartNoAxesCombined className="size-4" aria-hidden="true" />}
                  />
                  <SummaryMetric
                    label="Ranked scorecards"
                    value={String(data?.totalParticipants ?? entries.length)}
                    icon={<UsersRound className="size-4" aria-hidden="true" />}
                  />
                  <SummaryMetric
                    label="Period"
                    value={formatPeriod(search.month, search.year)}
                    icon={<CalendarDays className="size-4" aria-hidden="true" />}
                  />
                </div>
              </Card>
            ) : null}
            <Card className="tablet:p-5 space-y-4 p-4">
              <div className="flex flex-wrap items-end justify-between gap-3">
                <div>
                  <p className="text-overline text-primary font-semibold">Results</p>
                  <h2 className="text-h3 text-text-primary mt-1 font-semibold">Top performers</h2>
                  <p className="text-caption text-text-secondary mt-1">
                    Ranked scorecards for {formatPeriod(search.month, search.year)}.
                  </p>
                </div>
                <span className="text-caption text-text-secondary tabular-nums">
                  {entries.length} {entries.length === 1 ? 'scorecard' : 'scorecards'}
                </span>
              </div>
              {entries.length === 0 ? (
                <EmptyState
                  icon={<Award className="size-6" aria-hidden="true" />}
                  title="No scorecards for this period"
                  description="Monthly rankings appear here after scorecards have been generated."
                />
              ) : (
                <>
                  <div className="tablet:grid-cols-3 grid gap-3">
                    {topThree.map((entry) => (
                      <LeaderCard
                        key={entry.employeeId}
                        entry={entry}
                        featured={entry.rank === 1}
                      />
                    ))}
                  </div>
                  {remaining.length > 0 ? (
                    <section aria-labelledby="leaderboard-remaining-title" className="space-y-3">
                      <div className="flex items-center gap-2">
                        <Medal className="text-primary size-4" aria-hidden="true" />
                        <h3
                          id="leaderboard-remaining-title"
                          className="text-label text-text-primary font-semibold"
                        >
                          Other ranked scorecards
                        </h3>
                      </div>
                      <div className="space-y-2">
                        {remaining.map((entry) => (
                          <article
                            key={entry.employeeId}
                            className="border-border-subtle bg-surface rounded-control flex min-w-0 flex-wrap items-center gap-3 border p-3"
                          >
                            <span className="bg-surface-muted text-text-secondary text-label flex size-9 shrink-0 items-center justify-center rounded-lg font-semibold tabular-nums">
                              {entry.rank}
                            </span>
                            <div className="min-w-0 flex-1">
                              <h4 className="text-label text-text-primary font-semibold break-words">
                                {entry.employeeName?.trim() || `Employee #${entry.employeeId}`}
                              </h4>
                              <p className="text-caption text-text-secondary truncate">
                                {entry.branch?.trim() || 'Branch details unavailable'}
                              </p>
                            </div>
                            <Score value={entry.score} />
                          </article>
                        ))}
                      </div>
                    </section>
                  ) : null}
                  <p className="text-caption text-text-muted border-border-subtle border-t pt-3">
                    The current API returns up to 10 ranked scorecards for each month. Employee
                    names and branch labels are shown when available.
                  </p>
                </>
              )}
            </Card>
          </>
        )}
      </div>
    </PageLayout>
  )
}

function SummaryMetric({ label, value, icon }: { label: string; value: string; icon: ReactNode }) {
  return (
    <div className="bg-surface-muted rounded-control flex min-w-0 items-center gap-3 p-3.5">
      <span className="bg-primary-subtle text-primary flex size-9 shrink-0 items-center justify-center rounded-lg">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-caption text-text-secondary leading-snug break-words">{label}</p>
        <p className="text-body-lg text-text-primary mt-0.5 font-semibold break-words tabular-nums">
          {value}
        </p>
      </div>
    </div>
  )
}
