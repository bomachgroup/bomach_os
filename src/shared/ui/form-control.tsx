import {
  cloneElement,
  forwardRef,
  type InputHTMLAttributes,
  type ReactElement,
  type TextareaHTMLAttributes,
} from 'react'

import { cn } from '@/shared/lib/cn'
import { CONTROL_SIZE_CLASSES } from '@/shared/ui/control-sizing'

type DescribedControlProps = {
  id?: string
  'aria-describedby'?: string
  'aria-invalid'?: boolean | 'true' | 'false'
  'aria-errormessage'?: string
  'aria-required'?: boolean | 'true' | 'false'
  required?: boolean
}

interface FormControlProps {
  id: string
  label: string
  children: ReactElement<DescribedControlProps>
  description?: string
  error?: string
  required?: boolean
  className?: string
  labelClassName?: string
  requiredMarkClassName?: string
  errorClassName?: string
}

export function FormControl({
  id,
  label,
  children,
  description,
  error,
  required = false,
  className,
  labelClassName,
  requiredMarkClassName,
  errorClassName,
}: FormControlProps) {
  const descriptionId = description ? `${id}-description` : undefined
  const errorId = error ? `${id}-error` : undefined
  const isRequired = required || children.props.required
  const childDescription = children.props['aria-describedby']
  const describedBy = [childDescription, descriptionId, errorId].filter(Boolean).join(' ')

  const control = cloneElement(children, {
    id,
    'aria-describedby': describedBy || undefined,
    'aria-invalid': error ? 'true' : children.props['aria-invalid'],
    required: isRequired || undefined,
  })

  return (
    <div className={cn('space-y-1.5', className)}>
      <label
        htmlFor={id}
        className={cn('text-control-label text-text-secondary block font-bold', labelClassName)}
      >
        {label}
        {isRequired ? (
          <span aria-hidden="true" className={cn('text-danger ml-1', requiredMarkClassName)}>
            *
          </span>
        ) : null}
      </label>
      {control}
      {description ? (
        <p id={descriptionId} className="text-body-sm text-text-secondary">
          {description}
        </p>
      ) : null}
      {error ? (
        <p id={errorId} className={cn('text-body-sm text-danger', errorClassName)} role="status">
          {error}
        </p>
      ) : null}
    </div>
  )
}

const controlClasses = cn(
  CONTROL_SIZE_CLASSES,
  'w-full rounded-control border border-border-subtle bg-surface text-text-primary placeholder:text-text-muted transition-colors hover:border-border-strong focus-visible:border-primary focus-visible:outline-none focus-visible:shadow-focus-ring disabled:cursor-not-allowed disabled:bg-surface-muted disabled:opacity-60 aria-[invalid=true]:border-danger aria-[invalid=true]:focus-visible:border-danger aria-[invalid=true]:focus-visible:shadow-focus-ring-danger',
)

export const TextInput = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(
  ({ className, ...props }, ref) => (
    <input {...props} ref={ref} className={cn(controlClasses, className)} />
  ),
)

TextInput.displayName = 'TextInput'

export const TextArea = forwardRef<
  HTMLTextAreaElement,
  TextareaHTMLAttributes<HTMLTextAreaElement>
>(({ className, rows = 4, ...props }, ref) => (
  <textarea
    {...props}
    ref={ref}
    rows={rows}
    className={cn(controlClasses, 'min-h-24 resize-y', className)}
  />
))

TextArea.displayName = 'TextArea'
