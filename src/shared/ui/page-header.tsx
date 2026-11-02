import type { ReactNode } from 'react'
import {
  Bell,
  BriefcaseBusiness,
  Building2,
  CalendarDays,
  ClipboardCheck,
  FileText,
  LayoutDashboard,
  ListChecks,
  MapPin,
  Network,
  ScanFace,
  ShieldCheck,
  Target,
  UserRound,
} from 'lucide-react'

import { cn } from '@/shared/lib/cn'

export interface PageHeaderProps {
  title: string
  /** Legacy route copy accepted for compatibility; page headings stay title-only. */
  subtitle?: string
  leading?: ReactNode
  /** A safe, canonical parent link for nested routes. */
  backLink?: ReactNode
  actions?: ReactNode
  /** Optional page controls (for example, tabs or filters) shown on their own row. */
  toolbar?: ReactNode
  /** Keeps one compact page action or status summary alongside the title on narrow screens. */
  actionsInline?: boolean
  className?: string
}

function getPageIcon(title: string): ReactNode {
  const normalizedTitle = title.toLocaleLowerCase()

  if (
    normalizedTitle.includes('department') ||
    normalizedTitle.includes('unit') ||
    normalizedTitle.includes('org chart')
  )
    return <Network className="size-[18px]" />
  if (normalizedTitle.includes('branch') || normalizedTitle.includes('company'))
    return <Building2 className="size-[18px]" />
  if (normalizedTitle.includes('notification')) return <Bell className="size-[18px]" />
  if (normalizedTitle.includes('approval')) return <ClipboardCheck className="size-[18px]" />
  if (normalizedTitle.includes('profile')) return <UserRound className="size-[18px]" />
  if (normalizedTitle.includes('role')) return <ShieldCheck className="size-[18px]" />
  if (normalizedTitle.includes('task')) return <ListChecks className="size-[18px]" />
  if (normalizedTitle.includes('report')) return <FileText className="size-[18px]" />
  if (normalizedTitle.includes('target')) return <Target className="size-[18px]" />
  if (
    normalizedTitle.includes('attendance') ||
    normalizedTitle.includes('leave') ||
    normalizedTitle.includes('request')
  )
    return <CalendarDays className="size-[18px]" />
  if (normalizedTitle.includes('location')) return <MapPin className="size-[18px]" />
  if (normalizedTitle.includes('face')) return <ScanFace className="size-[18px]" />
  if (normalizedTitle.includes('hr')) return <BriefcaseBusiness className="size-[18px]" />
  return <LayoutDashboard className="size-[18px]" />
}

export function PageHeader({
  title,
  leading,
  backLink,
  actions,
  toolbar,
  actionsInline = false,
  className,
}: PageHeaderProps) {
  const rowClassName = actionsInline
    ? 'flex min-w-0 items-center justify-between gap-2'
    : 'tablet:flex-row tablet:items-center tablet:justify-between tablet:gap-4 flex min-w-0 flex-col gap-3'

  return (
    <header className={cn('min-w-0 space-y-3', className)}>
      {backLink ? (
        <div className={rowClassName}>
          <div className={cn('flex min-w-0 items-center gap-3', actionsInline && 'flex-1')}>
            <div className="shrink-0">{backLink}</div>
            <h1
              className={cn(
                'text-h1 text-text-primary min-w-0 font-semibold tracking-tight',
                actionsInline
                  ? 'min-w-0 flex-1 truncate text-[clamp(1.125rem,3vw,2rem)] leading-tight'
                  : 'break-words',
              )}
            >
              {title}
            </h1>
          </div>
          {actions ? (
            <div
              className={cn(
                'tablet:w-auto tablet:max-w-[55%] tablet:shrink-0 tablet:justify-end flex w-full flex-wrap items-center justify-end gap-2',
                actionsInline && 'w-auto max-w-none shrink-0 flex-nowrap',
              )}
            >
              {actions}
            </div>
          ) : null}
        </div>
      ) : (
        <div className={rowClassName}>
          <div className={cn('flex min-w-0 items-center gap-3', actionsInline && 'flex-1')}>
            <span
              aria-hidden="true"
              className="bg-primary-subtle text-primary border-primary/10 rounded-control flex size-10 shrink-0 items-center justify-center border"
            >
              {leading ?? getPageIcon(title)}
            </span>
            <h1
              className={cn(
                'text-h1 text-text-primary min-w-0 font-semibold tracking-tight',
                actionsInline
                  ? 'min-w-0 flex-1 truncate text-[clamp(1.125rem,3vw,2rem)] leading-tight'
                  : 'break-words',
              )}
            >
              {title}
            </h1>
          </div>
          {actions ? (
            <div
              className={cn(
                'tablet:w-auto tablet:max-w-[55%] tablet:shrink-0 tablet:justify-end flex w-full flex-wrap items-center justify-end gap-2',
                actionsInline && 'w-auto max-w-none shrink-0 flex-nowrap',
              )}
            >
              {actions}
            </div>
          ) : null}
        </div>
      )}
      {toolbar ? <div className="border-border-subtle border-t pt-3">{toolbar}</div> : null}
    </header>
  )
}
