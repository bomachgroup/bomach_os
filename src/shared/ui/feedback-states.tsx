import type { ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { FeedbackIcon, type FeedbackIconName } from '@/shared/ui/feedback-icon'

interface StateContentProps {
  title: string
  description?: string
  icon?: ReactNode
  action?: ReactNode
  className?: string
}

function CenteredState({
  title,
  description,
  icon,
  action,
  className,
}: StateContentProps) {
  return (
    <div className={cn('flex min-h-52 flex-col items-center justify-center px-5 py-8 text-center', className)}>
      {icon ? (
        <div className="mb-4 flex size-12 items-center justify-center rounded-surface bg-surface-muted text-text-secondary">
          {icon}
        </div>
      ) : null}
      <h2 className="text-h3 font-semibold text-text-primary">{title}</h2>
      {description ? (
        <p className="mt-2 max-w-lg text-body-sm text-text-secondary">{description}</p>
      ) : null}
      {action ? <div className="mt-5">{action}</div> : null}
    </div>
  )
}

export function EmptyState(props: StateContentProps) {
  return <CenteredState {...props} />
}

export function ErrorState({
  title,
  description,
  action,
  className,
}: StateContentProps) {
  return (
    <CenteredState
      title={title}
      description={description}
      action={action}
      className={className}
      icon={<FeedbackIcon name="danger" className="size-6 text-danger" />}
    />
  )
}

export interface SectionErrorStateProps {
  title?: string
  description: string
  onRetry?: () => void
  className?: string
}

export function SectionErrorState({
  title = 'This section could not load',
  description,
  onRetry,
  className,
}: SectionErrorStateProps) {
  return (
    <Alert tone="danger" title={title} className={cn('flex flex-wrap items-center justify-between gap-3', className)}>
      <span>{description}</span>
      {onRetry ? (
        <Button variant="outline" size="sm" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </Alert>
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
        <>
          {reference ? (
            <p className="mb-3 text-body-sm text-text-secondary">
              Reference: <span className="font-semibold text-text-primary">{reference}</span>
            </p>
          ) : null}
          {nextSteps ? <div className="mb-4 text-body-sm text-text-secondary">{nextSteps}</div> : null}
          {action}
        </>
      }
      className={className}
      icon={<FeedbackIcon name="success" className="size-6 text-success" />}
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

export function PageSkeleton({ className }: { className?: string }) {
  return (
    <div aria-label="Loading page" role="status" className={cn('space-y-6', className)}>
      <Skeleton variant="title" className="w-1/3" />
      <Skeleton variant="text" className="w-1/2" />
      <div className="grid gap-4 tablet:grid-cols-2 desktop:grid-cols-3">
        <Skeleton variant="card" />
        <Skeleton variant="card" />
        <Skeleton variant="card" />
      </div>
    </div>
  )
}

export function LoadingLabel({ children = 'Loading' }: { children?: string }) {
  return (
    <span role="status" className="inline-flex items-center gap-2 text-body-sm text-text-secondary">
      <span aria-hidden="true" className="size-4 animate-spin rounded-pill border-2 border-primary border-r-transparent" />
      {children}
    </span>
  )
}

export type StateToneIcon = FeedbackIconName
