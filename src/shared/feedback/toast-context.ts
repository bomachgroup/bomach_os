import { createContext } from 'react'

import type { ToastOptions } from './toast-types'

export interface ToastContextValue {
  showToast: (options: ToastOptions) => void
  dismissToast: () => void
}

export const ToastContext = createContext<ToastContextValue | null>(null)
