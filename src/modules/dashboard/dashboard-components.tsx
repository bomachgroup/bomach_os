import type { CSSProperties, HTMLAttributes, ReactNode } from 'react'
import { Link } from '@tanstack/react-router'

import { cn } from '@/shared/lib/cn'
import { Card } from '@/shared/ui/card'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'

export interface DashboardMetric {
  label: string
  value: string | number
  detail?: string
  icon?: ReactNode
  tone?: DashboardTone
}

export type DashboardTone = 'primary' | 'info' | 'success' | 'warning' | 'danger' | 'neutral'

const dashboardToneClasses: Record<
  DashboardTone,
  { badge: string; icon: string; surface: string; ring: string }
> = {
  primary: {
    badge: 'border-primary/20 bg-primary-subtle text-primary',
    icon: 'bg-primary-subtle text-primary',
    surface: 'border-primary/20 bg-primary-subtle/45',
    ring: 'text-primary',
  },
  info: {
    badge: 'border-info/20 bg-info-subtle text-info-foreground',
    icon: 'bg-info-subtle text-info-foreground',
    surface: 'border-info/20 bg-info-subtle/45',
    ring: 'text-info',
  },
  success: {
    badge: 'border-success/20 bg-success-subtle text-success-foreground',
    icon: 'bg-success-subtle text-success-foreground',
    surface: 'border-success/20 bg-success-subtle/45',
    ring: 'text-success',
  },
  warning: {
    badge: 'border-warning/20 bg-warning-subtle text-warning-foreground',
    icon: 'bg-warning-subtle text-warning-foreground',
    surface: 'border-warning/20 bg-warning-subtle/40',
    ring: 'text-warning',
  },
  danger: {
    badge: 'border-danger/20 bg-danger-subtle text-danger-foreground',
    icon: 'bg-danger-subtle text-danger-foreground',
    surface: 'border-danger/20 bg-danger-subtle/40',
    ring: 'text-danger',
  },
  neutral: {
    badge: 'border-border-subtle bg-neutral-100 text-neutral-600',
    icon: 'bg-neutral-100 text-neutral-600',
    surface: 'border-border-subtle bg-surface',
    ring: 'text-neutral-500',
  },
}

export function DashboardPanel({
  title,
  description,
  action,
  icon,
  children,
  className,
}: {
  title: string
  description?: string
  action?: ReactNode
  icon?: ReactNode
  children: ReactNode
  className?: string
}) {
  const headingId = `dashboard-${title.toLowerCase().replaceAll(/[^a-z0-9]+/g, '-')}-heading`

  return (
    <section aria-labelledby={headingId} className={cn('min-w-0', className)}>
      <div className="mb-4 flex items-start justify-between gap-3">
        <div className="flex min-w-0 items-center gap-3">
          {icon ? (
            <span
              className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center"
              aria-hidden="true"
            >
              {icon}
            </span>
          ) : null}
          <div className="min-w-0">
            <h2 id={headingId} className="text-h3 text-text-primary font-semibold">
              {title}
            </h2>
            {description ? (
              <p className="text-body-sm text-text-secondary mt-1">{description}</p>
            ) : null}
          </div>
        </div>
        {action ? <div className="shrink-0">{action}</div> : null}
      </div>
      {children}
    </section>
  )
}

export function DashboardPanelCard({
  children,
  className,
  ...props
}: HTMLAttributes<HTMLDivElement>) {
  return (
    <Card
      {...props}
      className={cn('dashboard-enter phone:p-5 min-w-0 p-4', className)}
      elevation="sm"
    >
      {children}
    </Card>
  )
}

export function DashboardMetricStrip({
  metrics,
  loading = false,
  error = false,
  onRetry,
  emptyMessage = 'No summary data is available for your permissions and data scope.',
}: {
  metrics: DashboardMetric[]
  loading?: boolean
  error?: boolean
  onRetry?: () => void
  emptyMessage?: string
}) {
  if (error) {
    return (
      <SectionErrorState
        description="These summary figures could not be loaded. Other dashboard sections remain available."
        onRetry={onRetry ?? (() => undefined)}
      />
    )
  }

  if (loading) {
    return (
      <div className="phone:grid-cols-2 desktop:grid-cols-4 tablet:gap-4 grid grid-cols-1 gap-3">
        {Array.from({ length: 4 }, (_, index) => (
          <div
            key={index}
            className="rounded-surface border-border-subtle bg-surface space-y-3 border p-4"
            aria-hidden="true"
          >
            <Skeleton className="rounded-control h-9 w-9" />
            <Skeleton className="h-3 w-24" />
            <Skeleton className="h-8 w-16" />
          </div>
        ))}
      </div>
    )
  }

  if (!metrics.length) {
    return (
      <div className="bg-surface rounded-control border-border-subtle border px-4 py-5">
        <EmptyState
          title="No summary data available"
          description={emptyMessage}
          className="min-h-24"
        />
      </div>
    )
  }

  const gridClass =
    metrics.length === 1
      ? 'grid-cols-1'
      : metrics.length === 2
        ? 'phone:grid-cols-2 desktop:grid-cols-2'
        : metrics.length === 3
          ? 'phone:grid-cols-2 desktop:grid-cols-3'
          : 'phone:grid-cols-2 desktop:grid-cols-4'

  return (
    <dl className={cn('tablet:gap-4 grid min-w-0 gap-3', gridClass)}>
      {metrics.map((metric, index) => (
        <div
          key={metric.label}
          className={cn(
            'dashboard-enter rounded-surface shadow-elevation-sm tablet:p-5 min-w-0 border p-4',
            dashboardToneClasses[metric.tone ?? 'primary'].surface,
          )}
          style={{ animationDelay: `${Math.min(index * 45, 180)}ms` }}
        >
          <dt className="text-caption text-text-secondary flex min-w-0 items-center gap-2.5">
            {metric.icon ? (
              <span
                className={cn(
                  'rounded-control flex size-10 shrink-0 items-center justify-center',
                  dashboardToneClasses[metric.tone ?? 'primary'].icon,
                )}
              >
                {metric.icon}
              </span>
            ) : null}
            <span className="truncate">{metric.label}</span>
          </dt>
          <dd className="text-display-md text-text-primary mt-3 font-semibold tabular-nums">
            {metric.value}
          </dd>
          {metric.detail ? (
            <dd className="text-caption text-text-secondary mt-1 line-clamp-2 min-h-8">
              {metric.detail}
            </dd>
          ) : null}
        </div>
      ))}
    </dl>
  )
}

export function DashboardRingMetricCard({
  title,
  scoreLabel,
  score,
  tone = 'primary',
  detail,
}: {
  title: string
  scoreLabel: string
  score: number | null
  tone?: DashboardTone
  detail: string
}) {
  const boundedScore = score === null ? 0 : Math.min(100, Math.max(0, score))
  const circumference = 2 * Math.PI * 42
  const offset = circumference * (1 - boundedScore / 100)

  return (
    <article
      className={cn(
        'rounded-surface tablet:p-5 flex min-w-0 flex-col items-center border p-4 text-center',
        dashboardToneClasses[tone].surface,
      )}
    >
      <h3 className="text-body-md text-text-primary font-semibold">{title}</h3>
      <div
        className="desktop:size-32 relative mt-4 size-28 shrink-0"
        role="img"
        aria-label={`${scoreLabel}: ${score === null ? 'not available' : `${boundedScore}%`}`}
      >
        <svg viewBox="0 0 100 100" className="size-full -rotate-90" aria-hidden="true">
          <circle
            cx="50"
            cy="50"
            r="42"
            fill="none"
            className="stroke-neutral-200"
            strokeWidth="9"
          />
          <circle
            cx="50"
            cy="50"
            r="42"
            fill="none"
            className={cn('dashboard-ring-fill', dashboardToneClasses[tone].ring)}
            stroke="currentColor"
            strokeWidth="9"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
          />
        </svg>
        <span className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-h2 text-text-primary font-semibold tabular-nums">
            {score === null ? '—' : `${boundedScore}%`}
          </span>
          <span className="text-caption text-text-secondary">Score</span>
        </span>
      </div>
      <p className="text-caption text-text-secondary bg-surface/80 rounded-pill mt-3 max-w-full truncate px-3 py-1.5">
        {detail}
      </p>
    </article>
  )
}

export function DashboardScoreBreakdownCard({
  title,
  icon,
  tone = 'primary',
  score,
  stats,
}: {
  title: string
  icon: ReactNode
  tone?: DashboardTone
  score: number | null
  stats: { label: string; value: string | number; icon: ReactNode; tone?: DashboardTone }[]
}) {
  const boundedScore = score === null ? 0 : Math.min(100, Math.max(0, score))

  return (
    <article className="rounded-surface border-border-subtle bg-surface-muted/70 tablet:p-5 min-w-0 border p-4">
      <div className="flex min-w-0 items-center gap-3">
        <span
          className={cn(
            'rounded-control flex size-9 shrink-0 items-center justify-center',
            dashboardToneClasses[tone].icon,
          )}
          aria-hidden="true"
        >
          {icon}
        </span>
        <h3 className="text-body-md text-text-primary truncate font-semibold">{title}</h3>
      </div>
      <div className="mt-4">
        <div className="text-caption text-text-secondary flex items-center justify-between gap-3">
          <span>Score</span>
          <span className={cn('font-semibold tabular-nums', dashboardToneClasses[tone].ring)}>
            {score === null ? '—' : `${boundedScore}%`}
          </span>
        </div>
        <div
          className="mt-2 h-2 overflow-hidden rounded-full bg-neutral-200"
          role="progressbar"
          aria-label={`${title} score`}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={score === null ? undefined : boundedScore}
          aria-valuetext={score === null ? 'Not available' : `${boundedScore}%`}
        >
          <div
            className={cn(
              'dashboard-ring-fill h-full rounded-full',
              dashboardToneClasses[tone].ring,
            )}
            style={{ width: `${boundedScore}%`, backgroundColor: 'currentColor' }}
          />
        </div>
      </div>
      <dl className="divide-border-subtle mt-3 divide-y">
        {stats.map((stat) => (
          <div key={stat.label} className="flex min-w-0 items-center justify-between gap-3 py-2.5">
            <div className="flex min-w-0 items-center gap-2">
              <span
                className={cn(
                  'flex size-5 shrink-0 items-center justify-center',
                  dashboardToneClasses[stat.tone ?? tone].ring,
                )}
                aria-hidden="true"
              >
                {stat.icon}
              </span>
              <dt className="text-body-sm text-text-secondary truncate">{stat.label}</dt>
            </div>
            <dd className="text-body-sm text-text-primary shrink-0 font-semibold tabular-nums">
              {stat.value}
            </dd>
          </div>
        ))}
      </dl>
    </article>
  )
}

export function DashboardLoadingRows({ count = 3 }: { count?: number }) {
  return (
    <ul className="divide-border-subtle divide-y" aria-label="Loading dashboard items">
      {Array.from({ length: count }, (_, index) => (
        <li key={index} className="flex items-center gap-3 py-3 first:pt-0 last:pb-0">
          <Skeleton className="rounded-pill size-9 shrink-0" />
          <div className="min-w-0 flex-1 space-y-2">
            <Skeleton className="h-4 w-2/3" />
            <Skeleton className="h-3 w-1/2" />
          </div>
        </li>
      ))}
    </ul>
  )
}

export function DashboardListRow({
  icon,
  tone = 'primary',
  trailingTone,
  title,
  description,
  trailing,
  href,
  className,
  style,
}: {
  icon?: ReactNode
  tone?: DashboardTone
  trailingTone?: DashboardTone
  title: ReactNode
  description?: ReactNode
  trailing?: ReactNode
  href?: string
  className?: string
  style?: CSSProperties
}) {
  const content = (
    <>
      {icon ? (
        <span
          className={cn(
            'rounded-control flex size-9 shrink-0 items-center justify-center',
            dashboardToneClasses[tone].icon,
          )}
        >
          {icon}
        </span>
      ) : null}
      <span className="min-w-0 flex-1">
        <span className="text-body-sm text-text-primary block truncate font-medium">{title}</span>
        {description ? (
          <span className="text-caption text-text-secondary mt-0.5 block truncate">
            {description}
          </span>
        ) : null}
      </span>
      {trailing ? (
        <span
          className={cn(
            'text-caption shrink-0',
            trailingTone
              ? cn(
                  'rounded-pill border px-2.5 py-1 font-medium',
                  dashboardToneClasses[trailingTone].badge,
                )
              : 'text-text-secondary',
          )}
        >
          {trailing}
        </span>
      ) : null}
    </>
  )

  return (
    <li className={cn('min-w-0 py-3 first:pt-0 last:pb-0', className)} style={style}>
      {href ? (
        <Link
          to={href as never}
          className="focus-visible:shadow-focus-ring rounded-control hover:bg-primary-subtle/30 flex min-h-10 min-w-0 items-center gap-3 transition-colors outline-none focus-visible:outline-none"
        >
          {content}
        </Link>
      ) : (
        <div className="flex min-w-0 items-center gap-3">{content}</div>
      )}
    </li>
  )
}

export function DashboardEmptyMessage({
  title,
  description,
}: {
  title: string
  description: string
}) {
  return (
    <div className="bg-surface-muted/50 rounded-control px-4 py-5 text-center">
      <p className="text-body-sm text-text-primary font-medium">{title}</p>
      <p className="text-caption text-text-secondary mt-1">{description}</p>
    </div>
  )
}
