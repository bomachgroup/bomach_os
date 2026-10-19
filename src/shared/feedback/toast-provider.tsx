import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
  type FocusEvent,
  type ReactNode,
} from 'react'

import { cn } from '@/shared/lib/cn'
import { Button } from '@/shared/ui/button'
import { FeedbackIcon, type FeedbackIconName } from '@/shared/ui/feedback-icon'

import { ToastContext } from './toast-context'
import type { ToastOptions, ToastTone } from './toast-types'

interface ToastItem extends Omit<ToastOptions, 'durationMs'> {
  durationMs: number | null
  id: number
}

const toneClasses: Record<ToastTone, string> = {
  success: 'border-success/25 bg-success-subtle text-text-primary',
  info: 'border-info/25 bg-info-subtle text-text-primary',
  warning: 'border-warning/25 bg-warning-subtle text-text-primary',
  danger: 'border-danger/25 bg-danger-subtle text-text-primary',
}

const toneIcons: Record<ToastTone, FeedbackIconName> = {
  success: 'success',
  info: 'info',
  warning: 'warning',
  danger: 'danger',
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toast, setToast] = useState<ToastItem | null>(null)
  const [paused, setPaused] = useState(false)
  const sequence = useRef(0)
  const remainingDuration = useRef<{ toastId: number; milliseconds: number | null } | null>(null)

  const showToast = useCallback((options: ToastOptions) => {
    sequence.current += 1
    setPaused(false)
    const durationMs =
      options.durationMs === undefined ? (options.action ? null : 5000) : options.durationMs
    remainingDuration.current = { toastId: sequence.current, milliseconds: durationMs }
    setToast({ ...options, durationMs, tone: options.tone ?? 'info', id: sequence.current })
  }, [])

  const dismissToast = useCallback(() => setToast(null), [])

  useEffect(() => {
    if (!toast || paused || toast.durationMs === null) return
    const trackedDuration = remainingDuration.current
    const durationMs =
      trackedDuration?.toastId === toast.id && trackedDuration.milliseconds !== null
        ? trackedDuration.milliseconds
        : toast.durationMs
    const startedAt = Date.now()
    const timeout = window.setTimeout(() => {
      setToast((current) => (current?.id === toast.id ? null : current))
    }, durationMs)
    return () => {
      window.clearTimeout(timeout)
      if (remainingDuration.current?.toastId === toast.id) {
        remainingDuration.current.milliseconds = Math.max(0, durationMs - (Date.now() - startedAt))
      }
    }
  }, [toast, paused])

  function handleBlur(event: FocusEvent<HTMLDivElement>) {
    const nextTarget = event.relatedTarget
    if (!(nextTarget instanceof Node) || !event.currentTarget.contains(nextTarget)) {
      setPaused(false)
    }
  }

  const value = useMemo(() => ({ showToast, dismissToast }), [showToast, dismissToast])
  const tone = toast?.tone ?? 'info'

  return (
    <ToastContext.Provider value={value}>
      {children}
      {toast ? (
        <div className="z-toast tablet:inset-x-auto tablet:right-6 tablet:w-[min(28rem,calc(100vw-3rem))] pointer-events-none fixed inset-x-4 bottom-4 flex justify-center">
          <div
            role={tone === 'danger' ? 'alert' : 'status'}
            aria-atomic="true"
            onMouseEnter={() => setPaused(true)}
            onMouseLeave={() => setPaused(false)}
            onFocusCapture={() => setPaused(true)}
            onBlurCapture={handleBlur}
            className={cn(
              'rounded-control shadow-elevation-md pointer-events-auto flex w-full items-start gap-3 border px-4 py-3',
              toneClasses[tone],
            )}
          >
            <FeedbackIcon
              name={toneIcons[tone]}
              className={cn(
                'mt-0.5 size-5 shrink-0',
                tone === 'success' && 'text-success',
                tone === 'info' && 'text-info',
                tone === 'warning' && 'text-warning',
                tone === 'danger' && 'text-danger',
              )}
            />
            <div className="min-w-0 flex-1">
              <p className="text-label font-semibold">{toast.title}</p>
              {toast.description ? (
                <p className="text-body-sm text-text-secondary mt-0.5">{toast.description}</p>
              ) : null}
              {toast.action ? (
                <button
                  type="button"
                  className="text-label text-primary focus-visible:shadow-focus-ring mt-2 font-semibold underline-offset-2 hover:underline focus-visible:outline-none"
                  onClick={() => {
                    try {
                      toast.action?.onClick()
                    } finally {
                      dismissToast()
                    }
                  }}
                >
                  {toast.action.label}
                </button>
              ) : null}
            </div>
            <Button
              type="button"
              variant="ghost"
              size="icon"
              className="-mt-2 -mr-2 size-9 shrink-0"
              aria-label="Dismiss notification"
              onClick={dismissToast}
            >
              <FeedbackIcon name="close" className="size-4" />
            </Button>
          </div>
        </div>
      ) : null}
    </ToastContext.Provider>
  )
}
