import { Link } from '@tanstack/react-router'

import { cn } from '@/shared/lib/cn'

import { PageBackLinkContent, pageBackLinkClassName } from './page-back-link'

export interface BreadcrumbItem {
  label: string
  to: string
}

export function Breadcrumbs({ items }: { items: BreadcrumbItem[] }) {
  if (items.length === 0) return null

  const backItem = items.at(-1)

  return (
    <nav aria-label="Breadcrumb" className="min-w-0">
      <ol className="phone:flex text-caption text-text-secondary hidden min-w-0 flex-wrap items-center gap-x-2 gap-y-1">
        {items.map((item, index) => (
          <li key={`${item.to}-${item.label}`} className="inline-flex min-w-0 items-center gap-2">
            {index > 0 ? (
              <span aria-hidden="true" className="text-text-subtle">
                /
              </span>
            ) : null}
            <Link
              to={item.to as never}
              className="focus-visible:shadow-focus-ring rounded-control hover:text-primary max-w-full truncate underline-offset-4 transition-colors hover:underline focus-visible:outline-none"
            >
              {item.label}
            </Link>
          </li>
        ))}
      </ol>
      {backItem ? (
        <Link to={backItem.to as never} className={cn('phone:hidden', pageBackLinkClassName)}>
          <PageBackLinkContent>{backItem.label}</PageBackLinkContent>
        </Link>
      ) : null}
    </nav>
  )
}
