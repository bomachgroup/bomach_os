import type { ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

export interface PageHeaderProps {
  title: string
  subtitle?: string
  eyebrow?: string
  leading?: ReactNode
  breadcrumbs?: ReactNode
  actions?: ReactNode
  /** Optional page controls (for example, tabs or filters) shown on their own row. */
  toolbar?: ReactNode
  className?: string
}

export function PageHeader({
  title,
  subtitle,
  eyebrow,
  leading,
  breadcrumbs,
  actions,
  toolbar,
  className,
}: PageHeaderProps) {
  return (
    <header className={cn('min-w-0 space-y-4', className)}>
      <div className="tablet:flex-row tablet:items-end tablet:justify-between tablet:gap-8 flex flex-col gap-4">
        <div className="flex min-w-0 items-start gap-3">
          {leading ? <div className="shrink-0">{leading}</div> : null}
          <div className="min-w-0">
            {breadcrumbs ? <div className="mb-2">{breadcrumbs}</div> : null}
            {eyebrow && !breadcrumbs ? (
              <p className="text-overline text-primary mb-1">{eyebrow}</p>
            ) : null}
            <h1 className="text-h1 text-text-primary tablet:text-display-md desktop:text-display-lg font-semibold tracking-tight">
              {title}
            </h1>
            {subtitle ? (
              <p className="text-body-sm text-text-secondary desktop:text-body-md mt-1 max-w-3xl">
                {subtitle}
              </p>
            ) : null}
          </div>
        </div>
        {actions ? (
          <div className="tablet:max-w-[50%] tablet:justify-end flex shrink-0 flex-wrap items-center gap-2">
            {actions}
          </div>
        ) : null}
      </div>
      {toolbar ? <div className="border-border-subtle border-t pt-4">{toolbar}</div> : null}
    </header>
  )
}
