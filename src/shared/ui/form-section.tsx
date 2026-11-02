import type { HTMLAttributes } from 'react'

import { cn } from '@/shared/lib/cn'

/** Muted, bordered surface used to group fields inside create and edit forms. */
export function FormSection({ className, ...props }: HTMLAttributes<HTMLElement>) {
  return (
    <section
      {...props}
      className={cn(
        'bg-surface-muted border-border-subtle rounded-surface tablet:p-5 border p-4',
        className,
      )}
    />
  )
}
