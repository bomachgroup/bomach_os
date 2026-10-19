import {
  useEffect,
  useId,
  useRef,
  type MouseEvent,
  type RefObject,
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
  initialFocusRef?: RefObject<HTMLElement | null>
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
  initialFocusRef,
}: DialogProps) {
  const dialogRef = useRef<HTMLDialogElement>(null)
  const titleRef = useRef<HTMLHeadingElement>(null)
  const titleId = useId()
  const descriptionId = useId()

  useEffect(() => {
    const dialog = dialogRef.current
    if (!dialog) return

    if (open && !dialog.open) {
      dialog.showModal()
      const initialFocusTarget = initialFocusRef?.current ?? titleRef.current
      initialFocusTarget?.focus()
    } else if (!open && dialog.open) {
      dialog.close()
    }

    return () => {
      if (dialog.open) dialog.close()
    }
  }, [initialFocusRef, open])

  function handleCancel(event: SyntheticEvent<HTMLDialogElement>) {
    if (event.target !== event.currentTarget) return
    event.preventDefault()
    onOpenChange(false)
  }

  function handleClose(event: SyntheticEvent<HTMLDialogElement>) {
    // Nested dialogs (such as password confirmation inside the profile dialog)
    // must not cause their parent dialog to close as well.
    if (event.target !== event.currentTarget) return
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
        'bg-surface text-text-primary tablet:h-auto tablet:max-h-[90dvh] tablet:w-[calc(100vw-2rem)] tablet:rounded-surface tablet:border tablet:border-border-subtle tablet:shadow-elevation-lg fixed inset-0 m-auto hidden h-dvh max-h-none w-screen max-w-none flex-col overflow-hidden p-0 backdrop:bg-neutral-900/45 open:flex',
        sizeClasses[size],
        className,
      )}
    >
      <header className="border-border-subtle tablet:px-5 tablet:pl-5 tablet:pr-5 tablet:pt-4 flex shrink-0 items-start justify-between gap-4 border-b px-[calc(1.25rem+env(safe-area-inset-left))] pt-[calc(1rem+env(safe-area-inset-top))] pr-[calc(1.25rem+env(safe-area-inset-right))] pb-4">
        <div className="min-w-0">
          <h2 ref={titleRef} id={titleId} tabIndex={-1} className="text-h3 font-semibold">
            {title}
          </h2>
          {description ? (
            <p id={descriptionId} className="text-body-sm text-text-secondary mt-1">
              {description}
            </p>
          ) : null}
        </div>
        <Button
          type="button"
          variant="ghost"
          size="icon"
          aria-label={closeLabel}
          onClick={() => onOpenChange(false)}
        >
          <FeedbackIcon name="close" className="size-4" />
        </Button>
      </header>
      <div
        className={cn(
          'tablet:px-5 tablet:pl-5 tablet:pr-5 min-h-0 flex-1 overflow-y-auto py-5 pr-[calc(1.25rem+env(safe-area-inset-right))] pl-[calc(1.25rem+env(safe-area-inset-left))]',
          bodyClassName,
        )}
      >
        {children}
      </div>
      {footer ? (
        <footer className="border-border-subtle tablet:px-5 tablet:pl-5 tablet:pr-5 tablet:pb-4 flex shrink-0 flex-wrap items-center justify-end gap-2 border-t px-[calc(1.25rem+env(safe-area-inset-left))] pt-4 pr-[calc(1.25rem+env(safe-area-inset-right))] pb-[calc(1rem+env(safe-area-inset-bottom))]">
          {footer}
        </footer>
      ) : null}
    </dialog>
  )
}
