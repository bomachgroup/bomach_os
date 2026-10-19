import type { HTMLAttributes, ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

export type StatusTone = 'success' | 'warning' | 'danger' | 'info' | 'primary' | 'neutral'

const toneClasses: Record<StatusTone, string> = {
  success: 'border-success/20 bg-success-subtle text-success-foreground',
  warning: 'border-warning/20 bg-warning-subtle text-warning-foreground',
  danger: 'border-danger/20 bg-danger-subtle text-danger-foreground',
  info: 'border-info/20 bg-info-subtle text-info-foreground',
  primary: 'border-primary/20 bg-primary-subtle text-primary',
  neutral: 'border-border-subtle bg-surface-muted text-text-secondary',
}

export interface StatusChipProps extends HTMLAttributes<HTMLSpanElement> {
  label: string
  tone?: StatusTone
  dense?: boolean
  icon?: ReactNode
}

/** The feature chooses a tone; this presentation component does not interpret status strings. */
export function StatusChip({
  label,
  tone = 'neutral',
  dense = false,
  icon,
  className,
  ...props
}: StatusChipProps) {
  return (
    <span
      {...props}
      className={cn(
        'rounded-pill inline-flex max-w-full items-center gap-1.5 border font-medium',
        dense ? 'text-overline px-2 py-0.5' : 'text-caption px-2.5 py-1',
        toneClasses[tone],
        className,
      )}
    >
      {icon ? (
        <span className="inline-flex shrink-0" aria-hidden="true">
          {icon}
        </span>
      ) : null}
      <span className="truncate">{label}</span>
    </span>
  )
}
