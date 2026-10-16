import {
  createContext,
  useCallback,
  useContext,
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

export type ToastTone = 'success' | 'info' | 'warning' | 'danger'

export interface ToastOptions {
  title: string
  description?: string
  tone?: ToastTone
  durationMs?: number
  action?: { label: string; onClick: () => void }
}

interface ToastItem extends ToastOptions {
  id: number
}

interface ToastContextValue {
  showToast: (options: ToastOptions) => void
  dismissToast: () => void
}

const ToastContext = createContext<ToastContextValue | null>(null)

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

  const showToast = useCallback((options: ToastOptions) => {
    sequence.current += 1
    setPaused(false)
    setToast({ ...options, tone: options.tone ?? 'info', id: sequence.current })
  }, [])

  const dismissToast = useCallback(() => setToast(null), [])

  useEffect(() => {
    if (!toast || paused) return
    const timeout = window.setTimeout(() => {
      setToast((current) => (current?.id === toast.id ? null : current))
    }, toast.durationMs ?? 3000)
    return () => window.clearTimeout(timeout)
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
        <div className="pointer-events-none fixed inset-x-4 bottom-4 z-toast flex justify-center tablet:inset-x-auto tablet:right-6 tablet:w-[min(28rem,calc(100vw-3rem))]">
          <div
            role={tone === 'danger' ? 'alert' : 'status'}
            aria-live={tone === 'danger' ? 'assertive' : 'polite'}
            aria-atomic="true"
            onMouseEnter={() => setPaused(true)}
            onMouseLeave={() => setPaused(false)}
            onFocusCapture={() => setPaused(true)}
            onBlurCapture={handleBlur}
            className={cn(
              'pointer-events-auto flex w-full items-start gap-3 rounded-control border px-4 py-3 shadow-elevation-md',
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
                <p className="mt-0.5 text-body-sm text-text-secondary">{toast.description}</p>
              ) : null}
              {toast.action ? (
                <button
                  type="button"
                  className="mt-2 text-label font-semibold text-primary underline-offset-2 hover:underline focus-visible:outline-none focus-visible:shadow-focus-ring"
                  onClick={() => {
                    toast.action?.onClick()
                    dismissToast()
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
              className="-mr-2 -mt-2 size-9 shrink-0"
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

export function useToast() {
  const context = useContext(ToastContext)
  if (!context) throw new Error('useToast must be used within ToastProvider')
  return context
}
