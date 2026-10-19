export type ToastTone = 'success' | 'info' | 'warning' | 'danger'

export interface ToastOptions {
  title: string
  description?: string
  tone?: ToastTone
  /** `null` keeps the toast visible until the user dismisses it or uses its action. */
  durationMs?: number | null
  action?: { label: string; onClick: () => void }
}
