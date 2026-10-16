import { forwardRef, type HTMLAttributes } from 'react'

import { cn } from '@/shared/lib/cn'

export type CardElevation = 'none' | 'sm' | 'md' | 'lg'

const elevationClasses: Record<CardElevation, string> = {
  none: '',
  sm: 'shadow-elevation-sm',
  md: 'shadow-elevation-md',
  lg: 'shadow-elevation-lg',
}

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  elevation?: CardElevation
}

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, elevation = 'sm', ...props }, ref) => (
    <div
      {...props}
      ref={ref}
      className={cn(
        'rounded-control border border-border-subtle bg-surface p-4',
        elevationClasses[elevation],
        className,
      )}
    />
  ),
)

Card.displayName = 'Card'
