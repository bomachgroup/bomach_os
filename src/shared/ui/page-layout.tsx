import type { ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

import { PageHeader, type PageHeaderProps } from './page-header'

interface PageLayoutProps extends Omit<PageHeaderProps, 'className'> {
  children: ReactNode
  className?: string
  contentClassName?: string
}

/** Shared compact page title band and aligned, padded page body. */
export function PageLayout({
  title,
  subtitle,
  leading,
  backLink,
  actions,
  actionsInline,
  toolbar,
  children,
  className,
  contentClassName,
}: PageLayoutProps) {
  return (
    <div className={cn('min-w-0', className)}>
      <div className="bg-surface border-border-subtle desktop:sticky desktop:top-0 desktop:z-20 border-b">
        <div className="tablet:px-6 wide:px-8 mx-auto w-full max-w-[1440px] px-4 py-3">
          <PageHeader
            title={title}
            subtitle={subtitle}
            leading={leading}
            backLink={backLink}
            actions={actions}
            actionsInline={actionsInline}
            toolbar={toolbar}
          />
        </div>
      </div>
      <div
        className={cn(
          'phone:px-5 tablet:px-6 tablet:py-6 wide:px-8 wide:py-8 mx-auto w-full max-w-[1440px] px-4 py-5',
          contentClassName,
        )}
      >
        {children}
      </div>
    </div>
  )
}
