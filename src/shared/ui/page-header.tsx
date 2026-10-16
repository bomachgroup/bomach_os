import type { ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

interface PageHeaderProps {
  title: string
  subtitle?: string
  leading?: ReactNode
  breadcrumbs?: ReactNode
  actions?: ReactNode
  className?: string
}

export function PageHeader({
  title,
  subtitle,
  leading,
  breadcrumbs,
  actions,
  className,
}: PageHeaderProps) {
  return (
    <header
      className={cn(
        'flex flex-col gap-4 tablet:flex-row tablet:items-center tablet:justify-between',
        className,
      )}
    >
      <div className="flex min-w-0 items-start gap-3">
        {leading ? <div className="shrink-0">{leading}</div> : null}
        <div className="min-w-0">
          {breadcrumbs ? <div className="mb-2">{breadcrumbs}</div> : null}
          <h1 className="text-h2 font-semibold tracking-tight text-text-primary tablet:text-display-md">
            {title}
          </h1>
          {subtitle ? (
            <p className="mt-1 text-body-sm text-text-secondary">{subtitle}</p>
          ) : null}
        </div>
      </div>
      {actions ? (
        <div className="flex shrink-0 flex-wrap items-center gap-2 tablet:justify-end">
          {actions}
        </div>
      ) : null}
    </header>
  )
}
