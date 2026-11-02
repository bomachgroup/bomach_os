import type { ReactNode } from 'react'
import { ArrowLeft } from 'lucide-react'

export const pageBackLinkClassName =
  'focus-visible:shadow-focus-ring border-border-subtle bg-surface text-text-secondary hover:border-border-strong hover:bg-surface-muted hover:text-primary active:bg-neutral-200 rounded-control inline-flex size-10 shrink-0 items-center justify-center border p-0 transition-colors focus-visible:outline-none'

export function PageBackLinkContent({ children }: { children: ReactNode }) {
  return (
    <>
      <ArrowLeft aria-hidden="true" className="size-4" />
      <span className="sr-only">Back to {children}</span>
    </>
  )
}
