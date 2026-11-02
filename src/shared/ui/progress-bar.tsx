import { cn } from '@/shared/lib/cn'

interface ProgressBarProps {
  value: number | null
  label: string
  valueText?: string
  className?: string
  trackClassName?: string
  fillClassName?: string
}

/** Compact, accessible progress indicator shared by target and dashboard summaries. */
export function ProgressBar({
  value,
  label,
  valueText,
  className,
  trackClassName,
  fillClassName,
}: ProgressBarProps) {
  const boundedValue =
    value !== null && Number.isFinite(value) ? Math.min(100, Math.max(0, value)) : 0

  return (
    <div
      className={cn(
        'bg-surface-muted rounded-pill h-1.5 overflow-hidden',
        className,
        trackClassName,
      )}
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={value === null ? undefined : boundedValue}
      aria-valuetext={
        valueText ?? (value === null ? 'Not available' : `${Math.round(boundedValue)}%`)
      }
    >
      <div
        className={cn(
          'bg-primary rounded-pill h-full motion-safe:transition-[width] motion-safe:duration-300',
          fillClassName,
        )}
        style={{ width: `${boundedValue}%` }}
      />
    </div>
  )
}
