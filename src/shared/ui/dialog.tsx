import {
  useEffect,
  useId,
  useRef,
  type MouseEvent,
  type ReactNode,
  type SyntheticEvent,
} from 'react'

import { cn } from '@/shared/lib/cn'
import { Button } from '@/shared/ui/button'
import { FeedbackIcon } from '@/shared/ui/feedback-icon'

export type DialogSize = 'sm' | 'md' | 'lg' | 'xl'

const sizeClasses: Record<DialogSize, string> = {
  sm: 'tablet:max-w-[30rem]',
  md: 'tablet:max-w-[40rem]',
  lg: 'tablet:max-w-[50rem]',
  xl: 'tablet:max-w-[60rem]',
}

interface DialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  description?: string
  size?: DialogSize
  children: ReactNode
  footer?: ReactNode
  className?: string
  bodyClassName?: string
  closeLabel?: string
  closeOnBackdrop?: boolean
}

export function Dialog({
  open,
  onOpenChange,
  title,
  description,
  size = 'md',
  children,
  footer,
  className,
  bodyClassName,
  closeLabel = 'Close dialog',
  closeOnBackdrop = true,
}: DialogProps) {
  const dialogRef = useRef<HTMLDialogElement>(null)
  const titleId = useId()
  const descriptionId = useId()

  useEffect(() => {
    const dialog = dialogRef.current
    if (!dialog) return

    if (open && !dialog.open) {
      dialog.showModal()
      dialog.querySelector<HTMLElement>('[data-dialog-initial-focus]')?.focus()
    } else if (!open && dialog.open) {
      dialog.close()
    }

    return () => {
      if (dialog.open) dialog.close()
    }
  }, [open])

  function handleCancel(event: SyntheticEvent<HTMLDialogElement>) {
    event.preventDefault()
    onOpenChange(false)
  }

  function handleClose() {
    if (open) onOpenChange(false)
  }

  function handleBackdropClick(event: MouseEvent<HTMLDialogElement>) {
    if (closeOnBackdrop && event.target === event.currentTarget) {
      onOpenChange(false)
    }
  }

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby={titleId}
      aria-describedby={description ? descriptionId : undefined}
      onCancel={handleCancel}
      onClose={handleClose}
      onClick={handleBackdropClick}
      className={cn(
        'fixed inset-0 m-0 hidden h-dvh max-h-none w-screen max-w-none flex-col overflow-hidden bg-surface p-0 text-text-primary open:flex backdrop:bg-neutral-900/45 tablet:inset-auto tablet:m-auto tablet:h-auto tablet:max-h-[90dvh] tablet:w-[calc(100vw-2rem)] tablet:rounded-surface tablet:border tablet:border-border-subtle tablet:shadow-elevation-lg',
        sizeClasses[size],
        className,
      )}
    >
      <header className="flex shrink-0 items-start justify-between gap-4 border-b border-border-subtle px-5 py-4">
        <div className="min-w-0">
          <h2 id={titleId} tabIndex={-1} className="text-h3 font-semibold">
            {title}
          </h2>
          {description ? (
            <p id={descriptionId} className="mt-1 text-body-sm text-text-secondary">
              {description}
            </p>
          ) : null}
        </div>
        <Button
          type="button"
          variant="ghost"
          size="icon"
          aria-label={closeLabel}
          data-dialog-initial-focus
          onClick={() => onOpenChange(false)}
        >
          <FeedbackIcon name="close" className="size-4" />
        </Button>
      </header>
      <div className={cn('min-h-0 flex-1 overflow-y-auto p-5', bodyClassName)}>{children}</div>
      {footer ? (
        <footer className="flex shrink-0 flex-wrap items-center justify-end gap-2 border-t border-border-subtle px-5 py-4">
          {footer}
        </footer>
      ) : null}
    </dialog>
  )
}

