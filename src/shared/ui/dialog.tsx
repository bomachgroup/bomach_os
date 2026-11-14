import {
  useCallback,
  useEffect,
  useId,
  useLayoutEffect,
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
  fitContent?: boolean
  compactOnMobile?: boolean
  dismissDisabled?: boolean
  children: ReactNode
  footer?: ReactNode
  className?: string
  bodyClassName?: string
  closeLabel?: string
  closeOnBackdrop?: boolean
  initialFocusRef?: RefObject<HTMLElement | null>
  returnFocusRef?: RefObject<HTMLElement | null>
}

export function Dialog({
  open,
  onOpenChange,
  title,
  description,
  size = 'md',
  fitContent = false,
  compactOnMobile = false,
  dismissDisabled = false,
  children,
  footer,
  className,
  bodyClassName,
  closeLabel = 'Close dialog',
  closeOnBackdrop = true,
  initialFocusRef,
  returnFocusRef: externalReturnFocusRef,
}: DialogProps) {
  const dialogRef = useRef<HTMLDialogElement>(null)
  const cleanupCloseEventsRef = useRef(0)
  const returnFocusRef = useRef<HTMLElement | null>(null)
  const dialogWasOpenRef = useRef(false)
  const openStateRef = useRef(open)
  const titleRef = useRef<HTMLHeadingElement>(null)
  const titleId = useId()
  const descriptionId = useId()

  useLayoutEffect(() => {
    openStateRef.current = open
  }, [open])

  const restoreFocus = useCallback(() => {
    dialogWasOpenRef.current = false
    const returnFocusTarget = returnFocusRef.current ?? externalReturnFocusRef?.current
    returnFocusRef.current = null
    if (returnFocusTarget?.isConnected) {
      window.setTimeout(() => {
        const anotherDialogIsOpen = Array.from(document.querySelectorAll('dialog[open]')).some(
          (openDialog) => openDialog !== dialogRef.current,
        )
        if (returnFocusTarget.isConnected && !anotherDialogIsOpen) returnFocusTarget.focus()
      }, 0)
    }
  }, [externalReturnFocusRef])

  useEffect(() => {
    const dialog = dialogRef.current
    if (!dialog) return

    if (open && !dialog.open) {
      if (!dialogWasOpenRef.current) {
        returnFocusRef.current =
          externalReturnFocusRef?.current ??
          (document.activeElement instanceof HTMLElement ? document.activeElement : null)
      }
      dialogWasOpenRef.current = true
      dialog.showModal()
      const initialFocusTarget = initialFocusRef?.current ?? titleRef.current
      initialFocusTarget?.focus()
    } else if (!open && dialog.open) {
      dialog.close()
    }

    return () => {
      if (dialog.open) {
        // Strict Mode replays effects in development. Closing the native dialog
        // during that replay must not make its close event clear the parent's
        // still-open state.
        cleanupCloseEventsRef.current += 1
        dialog.close()
        if (!openStateRef.current) restoreFocus()
      }
    }
  }, [externalReturnFocusRef, initialFocusRef, open, restoreFocus])

  function handleCancel(event: SyntheticEvent<HTMLDialogElement>) {
    if (event.target !== event.currentTarget) return
    event.preventDefault()
    if (!dismissDisabled) onOpenChange(false)
  }

  function handleClose(event: SyntheticEvent<HTMLDialogElement>) {
    // Nested dialogs (such as password confirmation inside the profile dialog)
    // must not cause their parent dialog to close as well.
    if (event.target !== event.currentTarget) return
    if (cleanupCloseEventsRef.current > 0) {
      cleanupCloseEventsRef.current -= 1
      return
    }
    restoreFocus()
    if (open) onOpenChange(false)
  }

  function handleBackdropClick(event: MouseEvent<HTMLDialogElement>) {
    if (closeOnBackdrop && !dismissDisabled && event.target === event.currentTarget) {
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
        'bg-surface text-text-primary tablet:inset-4 tablet:top-1/2 tablet:bottom-auto tablet:mx-auto tablet:my-0 tablet:h-auto tablet:max-h-[90dvh] tablet:w-auto tablet:-translate-y-1/2 tablet:rounded-surface tablet:border tablet:border-border-subtle tablet:shadow-elevation-lg rounded-surface border-border-subtle shadow-elevation-lg fixed inset-3 m-0 hidden h-auto max-h-none w-auto max-w-none flex-col overflow-hidden border p-0 backdrop:bg-neutral-900/45 open:flex',
        sizeClasses[size],
        compactOnMobile &&
          'rounded-surface border-border-subtle shadow-elevation-lg top-1/2 bottom-auto mx-auto my-0 h-auto max-h-[calc(100dvh-2rem)] w-auto max-w-[30rem] -translate-y-1/2 border',
        fitContent &&
          cn(
            'tablet:top-1/2 tablet:bottom-auto tablet:my-0 tablet:h-auto tablet:max-h-[90dvh] tablet:-translate-y-1/2 top-1/2 bottom-auto my-0 h-auto -translate-y-1/2',
            !compactOnMobile && 'max-h-[calc(100dvh-1.5rem)]',
          ),
        className,
      )}
    >
      <header className="border-border-subtle from-primary-subtle/75 via-primary-subtle/25 to-surface tablet:px-5 tablet:py-3.5 relative flex shrink-0 items-start justify-between gap-3 border-b bg-gradient-to-br px-[calc(1rem+env(safe-area-inset-left))] pt-[calc(0.75rem+env(safe-area-inset-top))] pr-[calc(1rem+env(safe-area-inset-right))] pb-3">
        <span
          aria-hidden="true"
          className="from-primary via-primary/35 pointer-events-none absolute inset-x-0 top-0 h-[3px] bg-gradient-to-r to-transparent"
        />
        <div className="min-w-0 flex-1">
          <h2
            ref={titleRef}
            id={titleId}
            tabIndex={-1}
            className="text-h2 leading-snug font-semibold tracking-tight break-words focus:outline-none"
          >
            {title}
          </h2>
          {description ? (
            <p id={descriptionId} className="text-caption text-text-secondary mt-0.5 leading-snug">
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
          disabled={dismissDisabled}
          className="border-border-subtle bg-surface/80 text-text-secondary hover:border-border-strong hover:bg-surface hover:text-text-primary rounded-control shrink-0 border shadow-none"
        >
          <FeedbackIcon name="close" className="size-[18px]" />
        </Button>
      </header>
      <div
        className={cn(
          'tablet:px-5 tablet:pl-5 tablet:pr-5 min-h-0 flex-1 overflow-y-auto py-5 pr-[calc(1.25rem+env(safe-area-inset-right))] pl-[calc(1.25rem+env(safe-area-inset-left))]',
          fitContent && 'flex-auto',
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
