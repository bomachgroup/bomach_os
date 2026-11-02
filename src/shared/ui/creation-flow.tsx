import type { ReactNode } from 'react'
import { Check } from 'lucide-react'

import { cn } from '@/shared/lib/cn'

export type CreationFlowStep = {
  id: string
  label: string
  title?: string
  detail?: string
  compactLabel?: string
}

type CreationFlowStepperProps = {
  steps: readonly CreationFlowStep[]
  currentStep: number
  maxSelectableStep: number
  onStepSelect: (index: number) => void
  ariaLabel: string
  variant: 'horizontal' | 'responsive'
  eyebrow?: string
  headerAction?: ReactNode
  headerActionClassName?: string
  hideDetailBelow480?: boolean
  className?: string
}

function stepStateLabel(index: number, currentStep: number, maxSelectableStep: number) {
  if (index === currentStep) return 'current step'
  if (index <= maxSelectableStep) return index < currentStep ? 'completed' : 'available'
  return 'not reached'
}

export function CreationFlowStepper({
  steps,
  currentStep,
  maxSelectableStep,
  onStepSelect,
  ariaLabel,
  variant,
  eyebrow,
  headerAction,
  headerActionClassName,
  hideDetailBelow480 = false,
  className,
}: CreationFlowStepperProps) {
  const active = steps[currentStep]
  const isHorizontal = variant === 'horizontal'

  if (isHorizontal) {
    return (
      <section
        aria-label={ariaLabel}
        className={cn(
          'bg-surface-muted/35 border-border-subtle rounded-surface phone:p-4 space-y-3 border p-3',
          className,
        )}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            {eyebrow ? <p className="text-overline text-primary font-semibold">{eyebrow}</p> : null}
            <h2 className="text-label mt-1 font-semibold">{active?.title ?? active?.label}</h2>
            {active?.detail ? (
              <p
                className={cn(
                  'text-caption text-text-secondary mt-0.5',
                  hideDetailBelow480 && 'max-[479px]:hidden',
                )}
              >
                {active.detail}
              </p>
            ) : null}
          </div>
          <span className="bg-surface text-overline text-text-secondary rounded-pill border-border-subtle shrink-0 border px-2.5 py-1.5 font-semibold">
            {currentStep + 1} of {steps.length}
          </span>
        </div>
        <div
          className="bg-border-subtle rounded-pill h-1.5 overflow-hidden"
          role="progressbar"
          aria-label={`${ariaLabel} progress`}
          aria-valuemin={1}
          aria-valuemax={steps.length}
          aria-valuenow={currentStep + 1}
          aria-valuetext={`Step ${currentStep + 1} of ${steps.length}: ${active?.label ?? ''}`}
        >
          <div
            className="bg-primary rounded-pill h-full transition-[width] duration-300"
            style={{ width: `${((currentStep + 1) / steps.length) * 100}%` }}
          />
        </div>
        <ol
          className="grid min-w-0 gap-1"
          style={{ gridTemplateColumns: `repeat(${steps.length}, minmax(0, 1fr))` }}
          aria-label={`${ariaLabel} steps`}
        >
          {steps.map((step, index) => {
            const isCurrent = index === currentStep
            const isComplete = index < currentStep
            const state = stepStateLabel(index, currentStep, maxSelectableStep)
            return (
              <li key={step.id} className="min-w-0">
                <button
                  type="button"
                  aria-current={isCurrent ? 'step' : undefined}
                  aria-label={`${step.label}, step ${index + 1} of ${steps.length}, ${state}`}
                  disabled={index > maxSelectableStep}
                  onClick={() => onStepSelect(index)}
                  className={cn(
                    'focus-visible:shadow-focus-ring rounded-control flex min-h-14 w-full min-w-0 flex-col items-center justify-center gap-1 border px-0.5 py-1.5 text-center transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-45',
                    isCurrent
                      ? 'border-primary/25 bg-primary-subtle/60 text-primary shadow-sm'
                      : isComplete
                        ? 'border-success/20 bg-success-subtle/50 text-success-foreground hover:bg-success-subtle'
                        : 'border-border-subtle bg-surface text-text-muted',
                  )}
                >
                  <span
                    className={cn(
                      'rounded-pill flex size-5 shrink-0 items-center justify-center border text-[10px] font-bold',
                      isCurrent
                        ? 'border-primary bg-primary text-text-on-primary'
                        : isComplete
                          ? 'border-success/30 bg-success-subtle text-success-foreground'
                          : 'border-border-subtle bg-surface text-text-muted',
                    )}
                  >
                    {isComplete ? <Check className="size-3" aria-hidden="true" /> : index + 1}
                  </span>
                  <span className="text-overline max-w-full min-w-0 leading-tight font-medium whitespace-nowrap">
                    <span className="phone:hidden">{step.compactLabel ?? step.label}</span>
                    <span className="phone:inline hidden">{step.label}</span>
                  </span>
                </button>
              </li>
            )
          })}
        </ol>
      </section>
    )
  }

  return (
    <section
      aria-label={ariaLabel}
      className={cn(
        'bg-surface border-border-subtle rounded-control shadow-elevation-sm desktop:sticky desktop:top-24 desktop:p-4 tablet:p-5 min-w-0 border p-4',
        className,
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-overline text-primary">
            {eyebrow ?? `Step ${currentStep + 1} of ${steps.length}`}
          </p>
          <h2 className="text-h3 text-text-primary mt-1 font-semibold">
            {active?.title ?? active?.label}
          </h2>
        </div>
        {headerAction ? (
          <div className={cn('shrink-0', headerActionClassName)}>{headerAction}</div>
        ) : null}
      </div>
      <ol
        aria-label={`${ariaLabel} progress`}
        className="desktop:hidden mt-4 grid gap-1.5"
        style={{ gridTemplateColumns: `repeat(${steps.length}, minmax(0, 1fr))` }}
      >
        {steps.map((step, index) => (
          <li key={step.id}>
            <button
              type="button"
              aria-current={currentStep === index ? 'step' : undefined}
              aria-label={`${step.label}, step ${index + 1} of ${steps.length}, ${stepStateLabel(index, currentStep, maxSelectableStep)}`}
              disabled={index > maxSelectableStep}
              onClick={() => onStepSelect(index)}
              className="focus-visible:shadow-focus-ring rounded-control flex min-h-8 w-full items-center focus-visible:outline-none disabled:cursor-not-allowed"
            >
              <span
                aria-hidden="true"
                className={cn(
                  'rounded-pill block h-1.5 w-full',
                  index <= maxSelectableStep ? 'bg-primary' : 'bg-border-subtle',
                )}
              />
            </button>
          </li>
        ))}
      </ol>
      <ol aria-label={`${ariaLabel} steps`} className="desktop:grid desktop:gap-1 mt-4 hidden">
        {steps.map((step, index) => {
          const isCurrent = index === currentStep
          const isComplete = index < currentStep
          return (
            <li
              key={step.id}
              aria-current={isCurrent ? 'step' : undefined}
              className="before:bg-border-subtle relative pb-1 before:absolute before:top-9 before:bottom-0 before:left-4 before:w-px last:pb-0 last:before:hidden"
            >
              <button
                type="button"
                aria-label={`${step.label}, step ${index + 1} of ${steps.length}, ${stepStateLabel(index, currentStep, maxSelectableStep)}`}
                disabled={index > maxSelectableStep}
                onClick={() => onStepSelect(index)}
                className={cn(
                  'focus-visible:shadow-focus-ring rounded-control relative flex min-h-12 w-full gap-3 p-2.5 text-left transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-55',
                  isCurrent
                    ? 'bg-primary-subtle/70'
                    : index <= maxSelectableStep && 'hover:bg-surface-muted',
                )}
              >
                <span
                  className={cn(
                    'text-caption relative z-10 mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-full font-semibold',
                    isComplete
                      ? 'bg-success-subtle text-success-foreground'
                      : isCurrent
                        ? 'bg-primary text-text-on-primary'
                        : 'border-border-subtle bg-surface text-text-muted border',
                  )}
                >
                  {isComplete ? <Check className="size-4" aria-hidden="true" /> : index + 1}
                </span>
                <span className="min-w-0 py-0.5">
                  <span
                    className={cn(
                      'text-body-sm block font-semibold',
                      isCurrent ? 'text-primary' : 'text-text-primary',
                    )}
                  >
                    {step.label}
                  </span>
                </span>
              </button>
            </li>
          )
        })}
      </ol>
    </section>
  )
}

type CreationFlowActionsProps = {
  leading?: ReactNode
  children: ReactNode
  className?: string
}

export function CreationFlowActions({ leading, children, className }: CreationFlowActionsProps) {
  return (
    <div className={cn('flex w-full flex-wrap items-center justify-between gap-3', className)}>
      {leading ? <div className="mr-auto flex flex-wrap items-center gap-2">{leading}</div> : null}
      <div className="flex flex-wrap items-center justify-end gap-2">{children}</div>
    </div>
  )
}
