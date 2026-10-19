import type { ReactNode } from 'react'
import { cn } from '@/shared/lib/cn'

interface AuthPageFrameProps {
  children: ReactNode
  className?: string
  cardClassName?: string
  glass?: boolean
  dimBackground?: boolean
}

export function AuthPageFrame({
  children,
  className,
  cardClassName,
  glass = false,
  dimBackground = false,
}: AuthPageFrameProps) {
  return (
    <main
      className={cn(
        'flex min-h-svh items-center justify-center overflow-y-auto bg-cover bg-center px-4 py-6 sm:px-6',
        glass ? 'text-white' : 'text-text-primary',
        className,
      )}
      style={{
        backgroundImage: dimBackground
          ? "linear-gradient(rgba(15, 23, 42, 0.35), rgba(15, 23, 42, 0.35)), url('/login-bg.png')"
          : "url('/login-bg.png')",
      }}
    >
      <section
        className={cn(
          'shadow-elevation-md w-full max-w-[500px] rounded-[20px] border border-neutral-200/90 px-[30px] py-10',
          glass ? 'border-white/50 bg-slate-950/15' : 'bg-white',
          cardClassName,
        )}
      >
        {children}
      </section>
    </main>
  )
}

export function AuthLogo({ variant = 'compact' }: { variant?: 'compact' | 'tile' }) {
  return (
    <div
      className={cn(
        'mx-auto flex items-center justify-center',
        variant === 'tile' && 'h-[120px] w-[140px] rounded-[20px] bg-white p-2.5',
      )}
    >
      <img
        className={cn('w-auto object-contain', variant === 'tile' ? 'h-full' : 'h-16')}
        src="/bomach-logo.png"
        alt="Bomach"
      />
    </div>
  )
}

export function AuthFormAlert({
  message,
  className,
}: {
  message: string | null
  className?: string
}) {
  if (!message) return null
  return (
    <div
      role="alert"
      className={cn(
        'rounded-control border-danger/30 bg-danger/5 text-body-sm text-danger border px-4 py-3',
        className,
      )}
    >
      {message}
    </div>
  )
}

export function AuthFieldError({ message }: { message: unknown }) {
  const text = typeof message === 'string' ? message : null
  if (!text) return null
  return <span>{text}</span>
}
