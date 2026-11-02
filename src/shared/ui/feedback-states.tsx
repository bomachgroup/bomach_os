import type { ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { presentError, type ErrorPresentationContext } from '@/shared/errors'
import { FeedbackIcon, type FeedbackIconName } from '@/shared/ui/feedback-icon'

interface StateContentProps {
  title: string
  description?: string
  icon?: ReactNode
  action?: ReactNode
  announcement?: 'polite' | 'assertive'
  className?: string
}

function CenteredState({
  title,
  description,
  icon,
  action,
  announcement,
  className,
}: StateContentProps) {
  return (
    <div
      className={cn(
        'flex min-h-52 flex-col items-center justify-center px-5 py-8 text-center',
        className,
      )}
    >
      {icon ? (
        <div className="rounded-surface bg-surface-muted text-text-secondary mb-4 flex size-12 items-center justify-center">
          {icon}
        </div>
      ) : null}
      <div aria-live={announcement} aria-atomic={announcement ? 'true' : undefined}>
        <h2 className="text-h3 text-text-primary font-semibold">{title}</h2>
        {description ? (
          <p className="text-body-sm text-text-secondary mt-2 max-w-lg">{description}</p>
        ) : null}
      </div>
      {action ? <div className="mt-5">{action}</div> : null}
    </div>
  )
}

export function EmptyState(props: StateContentProps) {
  return <CenteredState announcement="polite" {...props} />
}

export function ErrorState({
  title,
  description,
  action,
  className,
  error,
  errorContext = 'page-load',
}: StateContentProps & {
  error?: unknown
  errorContext?: ErrorPresentationContext
}) {
  const presentation = error != null ? presentError(error, errorContext) : undefined
  return (
    <CenteredState
      title={presentation?.title ?? title}
      description={presentation?.message ?? description}
      action={action}
      announcement="assertive"
      className={className}
      icon={<FeedbackIcon name="danger" className="text-danger size-6" />}
    />
  )
}

export interface SectionErrorStateProps {
  title?: string
  description?: string
  onRetry?: () => void
  className?: string
  error?: unknown
  errorContext?: ErrorPresentationContext
}

export function SectionErrorState({
  title = 'This section could not load',
  description,
  onRetry,
  className,
  error,
  errorContext = 'section-load',
}: SectionErrorStateProps) {
  const presentation = error != null ? presentError(error, errorContext) : undefined
  return (
    <Alert
      tone="danger"
      role="status"
      title={presentation?.title ?? title}
      className={cn('flex flex-wrap items-center justify-between gap-3', className)}
    >
      <span>{presentation?.message ?? description}</span>
      {onRetry ? (
        <Button variant="outline" size="sm" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </Alert>
  )
}

export function SummaryUnavailable({
  description = 'Figures are temporarily unavailable.',
  onRetry,
  className,
}: {
  description?: string
  onRetry?: () => void
  className?: string
}) {
  return (
    <div
      role="status"
      className={cn(
        'rounded-surface shadow-elevation-sm border-border-subtle bg-surface min-w-0 border p-4',
        className,
      )}
    >
      <div className="flex min-w-0 flex-wrap items-center justify-between gap-3">
        <div className="min-w-0">
          <p className="text-caption text-text-secondary">Summary</p>
          <p className="text-label text-text-primary mt-1 font-semibold">Unavailable</p>
          <p className="text-caption text-text-secondary mt-0.5">{description}</p>
        </div>
        {onRetry ? (
          <Button variant="ghost" size="sm" onClick={onRetry} className="shrink-0">
            Retry
          </Button>
        ) : null}
      </div>
    </div>
  )
}

export interface SuccessStateProps extends StateContentProps {
  reference?: string
  nextSteps?: ReactNode
}

export function SuccessState({
  title,
  description,
  action,
  reference,
  nextSteps,
  className,
}: SuccessStateProps) {
  return (
    <CenteredState
      title={title}
      description={description}
      action={
        reference || nextSteps || action ? (
          <>
            {reference ? (
              <p className="text-body-sm text-text-secondary mb-3">
                Reference: <span className="text-text-primary font-semibold">{reference}</span>
              </p>
            ) : null}
            {nextSteps ? (
              <div className="text-body-sm text-text-secondary mb-4">{nextSteps}</div>
            ) : null}
            {action}
          </>
        ) : undefined
      }
      announcement="polite"
      className={className}
      icon={<FeedbackIcon name="success" className="text-success size-6" />}
    />
  )
}

export type SkeletonVariant = 'text' | 'title' | 'avatar' | 'card' | 'row'

const skeletonClasses: Record<SkeletonVariant, string> = {
  text: 'h-4 w-full rounded-xs',
  title: 'h-6 w-2/3 rounded-xs',
  avatar: 'size-11 rounded-pill',
  card: 'h-32 w-full rounded-control',
  row: 'h-12 w-full rounded-sm',
}

export function Skeleton({
  variant = 'text',
  className,
}: {
  variant?: SkeletonVariant
  className?: string
}) {
  return (
    <div
      aria-hidden="true"
      className={cn('animate-pulse bg-neutral-100', skeletonClasses[variant], className)}
    />
  )
}

export function PageSkeleton({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div
      aria-label="Loading page"
      aria-busy="true"
      role="status"
      className={cn('space-y-6', className)}
    >
      {children}
    </div>
  )
}

export function LoadingLabel({ children = 'Loading' }: { children?: string }) {
  return (
    <span role="status" className="text-body-sm text-text-secondary inline-flex items-center gap-2">
      <span
        aria-hidden="true"
        className="rounded-pill border-primary size-4 animate-spin border-2 border-r-transparent"
      />
      {children}
    </span>
  )
}

export type StateToneIcon = FeedbackIconName
