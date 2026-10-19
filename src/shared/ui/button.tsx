import { forwardRef, type ButtonHTMLAttributes, type ReactNode } from 'react'

import { cn } from '@/shared/lib/cn'

export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger'
export type ButtonSize = 'sm' | 'md' | 'lg' | 'icon'

const variantClasses: Record<ButtonVariant, string> = {
  primary: 'bg-primary text-text-on-primary hover:bg-primary-hover active:bg-primary-pressed',
  secondary: 'bg-surface-muted text-text-primary hover:bg-neutral-200 active:bg-neutral-300',
  outline:
    'border border-border-strong bg-surface text-text-primary hover:bg-surface-muted active:bg-neutral-200',
  ghost: 'text-text-secondary hover:bg-surface-muted hover:text-text-primary active:bg-neutral-200',
  danger: 'bg-danger text-text-on-primary hover:bg-danger-hover active:bg-danger-foreground',
}

const sizeClasses: Record<ButtonSize, string> = {
  sm: 'min-h-9 px-3 text-caption',
  md: 'min-h-11 px-4 py-2 text-label',
  lg: 'min-h-12 px-5 py-2.5 text-label',
  icon: 'size-11 p-0',
}

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant
  size?: ButtonSize
  isLoading?: boolean
  leadingIcon?: ReactNode
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = 'primary',
      size = 'md',
      isLoading = false,
      leadingIcon,
      disabled,
      children,
      type = 'button',
      ...props
    },
    ref,
  ) => (
    <button
      {...props}
      ref={ref}
      type={type}
      disabled={disabled || isLoading}
      aria-busy={isLoading || undefined}
      className={cn(
        'rounded-control focus-visible:shadow-focus-ring inline-flex items-center justify-center gap-2 font-semibold whitespace-nowrap transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50',
        variantClasses[variant],
        sizeClasses[size],
        className,
      )}
    >
      {isLoading ? (
        <span
          aria-hidden="true"
          className="size-4 animate-spin rounded-full border-2 border-current border-r-transparent"
        />
      ) : (
        leadingIcon
      )}
      {children}
    </button>
  ),
)

Button.displayName = 'Button'
