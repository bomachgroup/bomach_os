import { forwardRef, type InputHTMLAttributes, type ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'
import { TextInput } from '@/shared/ui/form-control'

type AuthTextInputProps = InputHTMLAttributes<HTMLInputElement> & {
  icon: 'email' | 'lock'
  trailing?: ReactNode
}

export const AuthTextInput = forwardRef<HTMLInputElement, AuthTextInputProps>(
  ({ icon, trailing, className, ...props }, ref) => (
    <div className="relative">
      <span
        className="text-text-muted pointer-events-none absolute inset-y-0 left-3 flex items-center"
        aria-hidden="true"
      >
        {icon === 'email' ? (
          <svg
            viewBox="0 0 24 24"
            className="size-[18px]"
            fill="none"
            stroke="currentColor"
            strokeWidth="1.7"
          >
            <path d="M4 6h16v12H4z" />
            <path d="m4 7 8 6 8-6" />
          </svg>
        ) : (
          <svg
            viewBox="0 0 24 24"
            className="size-[18px]"
            fill="none"
            stroke="currentColor"
            strokeWidth="1.7"
          >
            <rect x="4.5" y="10" width="15" height="11" rx="2" />
            <path d="M8 10V7a4 4 0 1 1 8 0v3" />
          </svg>
        )}
      </span>
      <TextInput {...props} ref={ref} className={cn('pl-10', trailing && 'pr-12', className)} />
      {trailing}
    </div>
  ),
)

AuthTextInput.displayName = 'AuthTextInput'
