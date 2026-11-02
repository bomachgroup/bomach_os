import { forwardRef, type HTMLAttributes, type ReactNode } from 'react'

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

export const Alert = forwardRef<HTMLDivElement, AlertProps>(
  ({ className, tone = 'info', title, children, role, ...props }, ref) => (
    <div
      {...props}
      ref={ref}
      role={role}
      className={cn('rounded-control text-body-sm border px-4 py-3', toneClasses[tone], className)}
    >
      {title ? <p className="text-label mb-1 font-semibold">{title}</p> : null}
      {children ? <div className="text-text-secondary">{children}</div> : null}
    </div>
  ),
)

Alert.displayName = 'Alert'
