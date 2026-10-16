import type { HTMLAttributes, ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

export type AlertTone = 'info' | 'success' | 'warning' | 'danger'

const toneClasses: Record<AlertTone, string> = {
  info: 'border-info/25 bg-info-subtle text-text-primary',
  success: 'border-success/25 bg-success-subtle text-text-primary',
  warning: 'border-warning/25 bg-warning-subtle text-text-primary',
  danger: 'border-danger/25 bg-danger-subtle text-text-primary',
}

interface AlertProps extends HTMLAttributes<HTMLDivElement> {
  tone?: AlertTone
  title?: string
  children?: ReactNode
}

export function Alert({
  className,
  tone = 'info',
  title,
  children,
  ...props
}: AlertProps) {
  return (
    <div
      {...props}
      role={tone === 'danger' ? 'alert' : 'status'}
      className={cn('rounded-control border px-4 py-3 text-body-sm', toneClasses[tone], className)}
    >
      {title ? <p className="mb-1 text-label font-semibold">{title}</p> : null}
      {children ? <div className="text-text-secondary">{children}</div> : null}
    </div>
  )
}
