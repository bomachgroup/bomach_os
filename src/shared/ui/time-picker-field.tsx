import { useEffect, useId, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { Check, Clock3 } from 'lucide-react'

import { cn } from '@/shared/lib/cn'
import { CONTROL_SIZE_CLASSES } from '@/shared/ui/control-sizing'

import { Button } from './button'
import { DropdownSelect } from './dropdown-select'

type TimePickerFieldProps = {
  value: string
  onValueChange: (value: string) => void
  id?: string
  disabled?: boolean
  required?: boolean
  clearable?: boolean
  placeholder?: string
  'aria-describedby'?: string
  'aria-invalid'?: boolean | 'true' | 'false'
  'aria-required'?: boolean | 'true' | 'false'
}

const fieldClassName = cn(
  CONTROL_SIZE_CLASSES,
  'w-full rounded-control border border-border-subtle bg-surface text-left text-text-primary transition-colors hover:border-border-strong focus-visible:border-primary focus-visible:outline-none focus-visible:shadow-focus-ring disabled:cursor-not-allowed disabled:bg-surface-muted disabled:opacity-60 aria-[invalid=true]:border-danger aria-[invalid=true]:focus-visible:border-danger aria-[invalid=true]:focus-visible:shadow-focus-ring-danger',
)
const hourOptions = Array.from({ length: 12 }, (_, index) => {
  const hour = String(index + 1).padStart(2, '0')
  return { value: String(index + 1), label: hour }
})
const minuteOptions = Array.from({ length: 60 }, (_, minute) => {
  const value = String(minute).padStart(2, '0')
  return { value, label: value }
})
const periodOptions = [
  { value: 'AM', label: 'AM' },
  { value: 'PM', label: 'PM' },
]

function parseTime(value: string) {
  const match = /^(\d{2}):(\d{2})(?::\d{2})?$/.exec(value)
  if (!match) return null
  const hour = Number(match[1])
  const minute = Number(match[2])
  return hour < 24 && minute < 60 ? { hour, minute } : null
}

function to24Hour(hour: string, minute: string, period: string) {
  const hourNumber = Number(hour) % 12
  const normalizedHour = hourNumber + (period === 'PM' ? 12 : 0)
  return `${String(normalizedHour).padStart(2, '0')}:${minute}`
}

function displayTime(value: string, placeholder: string) {
  const time = parseTime(value)
  if (!time) return placeholder
  const date = new Date(2000, 0, 1, time.hour, time.minute)
  return new Intl.DateTimeFormat(undefined, { hour: '2-digit', minute: '2-digit' }).format(date)
}

function placePopover(anchor: DOMRect, panel: DOMRect, dialog: HTMLDialogElement | null) {
  const margin = 8
  const dialogRect = dialog?.getBoundingClientRect()
  const border = dialog ? Math.max(dialog.clientLeft, 1) : 0
  const topBorder = dialog ? Math.max(dialog.clientTop, 1) : 0
  const bounds = dialogRect
    ? {
        top: dialogRect.top + topBorder,
        right: dialogRect.right - border,
        bottom: dialogRect.bottom - topBorder,
        left: dialogRect.left + border,
      }
    : { top: 0, right: window.innerWidth, bottom: window.innerHeight, left: 0 }
  const left = Math.max(
    bounds.left + margin,
    Math.min(anchor.left, bounds.right - panel.width - margin),
  )
  const spaceBelow = bounds.bottom - anchor.bottom - margin
  const spaceAbove = anchor.top - bounds.top - margin
  const top =
    panel.height <= spaceBelow
      ? anchor.bottom + margin
      : panel.height <= spaceAbove
        ? anchor.top - panel.height - margin
        : Math.max(
            bounds.top + margin,
            Math.min(anchor.bottom + margin, bounds.bottom - panel.height - margin),
          )
  return {
    position: dialogRect ? ('absolute' as const) : ('fixed' as const),
    top: dialogRect ? top - dialogRect.top - topBorder : top,
    left: dialogRect ? left - dialogRect.left - border : left,
  }
}

export function TimePickerField({
  value,
  onValueChange,
  id,
  disabled = false,
  required = false,
  clearable = false,
  placeholder = 'Choose a time',
  'aria-describedby': describedBy,
  'aria-invalid': invalid,
  'aria-required': ariaRequired,
}: TimePickerFieldProps) {
  const generatedId = useId()
  const triggerId = id ?? `time-picker-${generatedId}`
  const pickerId = `${triggerId}-picker`
  const triggerRef = useRef<HTMLButtonElement>(null)
  const pickerRef = useRef<HTMLDivElement>(null)
  const [open, setOpen] = useState(false)
  const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null)
  const [position, setPosition] = useState({
    position: 'fixed' as 'fixed' | 'absolute',
    top: 0,
    left: 8,
  })
  const parsed = parseTime(value)
  const initialHour = parsed ? String(parsed.hour % 12 || 12) : '9'
  const initialMinute = parsed ? String(parsed.minute).padStart(2, '0') : '00'
  const initialPeriod = parsed && parsed.hour >= 12 ? 'PM' : 'AM'
  const [hour, setHour] = useState(initialHour)
  const [minute, setMinute] = useState(initialMinute)
  const [period, setPeriod] = useState(initialPeriod)

  function closePicker(restoreFocus = false) {
    setOpen(false)
    setPortalContainer(null)
    if (restoreFocus) window.requestAnimationFrame(() => triggerRef.current?.focus())
  }

  function openPicker() {
    if (disabled) return
    const time = parseTime(value)
    setHour(String(time ? time.hour % 12 || 12 : 9))
    setMinute(String(time ? time.minute : 0).padStart(2, '0'))
    setPeriod(time && time.hour >= 12 ? 'PM' : 'AM')
    setPortalContainer(triggerRef.current?.closest('dialog[open]') ?? document.body)
    setOpen(true)
  }

  function commitTime() {
    onValueChange(to24Hour(hour, minute, period))
    closePicker(true)
  }

  useEffect(() => {
    if (!open) return
    const updatePosition = () => {
      const anchor = triggerRef.current?.getBoundingClientRect()
      const panel = pickerRef.current?.getBoundingClientRect()
      const dialog = triggerRef.current?.closest<HTMLDialogElement>('dialog[open]') ?? null
      if (anchor && panel) setPosition(placePopover(anchor, panel, dialog))
    }
    const handleOutside = (event: PointerEvent) => {
      const target = event.target
      if (
        target instanceof Node &&
        !triggerRef.current?.contains(target) &&
        !pickerRef.current?.contains(target)
      ) {
        if (target instanceof Element && target.closest('[data-dropdown-menu]')) return
        closePicker()
      }
    }
    updatePosition()
    const frame = window.requestAnimationFrame(updatePosition)
    const focusFrame = window.requestAnimationFrame(() =>
      pickerRef.current?.querySelector<HTMLButtonElement>('button')?.focus(),
    )
    window.addEventListener('resize', updatePosition)
    window.addEventListener('scroll', updatePosition, true)
    document.addEventListener('pointerdown', handleOutside)
    return () => {
      window.cancelAnimationFrame(frame)
      window.cancelAnimationFrame(focusFrame)
      window.removeEventListener('resize', updatePosition)
      window.removeEventListener('scroll', updatePosition, true)
      document.removeEventListener('pointerdown', handleOutside)
    }
  }, [open])

  return (
    <>
      <button
        ref={triggerRef}
        id={triggerId}
        type="button"
        disabled={disabled}
        aria-haspopup="dialog"
        aria-expanded={open}
        aria-controls={open ? pickerId : undefined}
        aria-required={required || ariaRequired || undefined}
        aria-invalid={invalid}
        aria-describedby={describedBy}
        onClick={open ? () => closePicker(true) : openPicker}
        className={cn(fieldClassName, 'flex items-center justify-between gap-3')}
      >
        <span className={value ? '' : 'text-text-muted'}>{displayTime(value, placeholder)}</span>
        <Clock3 className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
      </button>
      {open && portalContainer
        ? createPortal(
            <div
              ref={pickerRef}
              id={pickerId}
              role="dialog"
              aria-label="Choose a time"
              className="bg-surface border-border-subtle shadow-elevation-lg rounded-surface fixed z-[100] w-[min(22rem,calc(100vw-1rem))] border p-3"
              style={{
                position: position.position,
                top: position.top,
                left: position.left,
                visibility: position.top ? 'visible' : 'hidden',
              }}
              onKeyDown={(event) => {
                if (event.key === 'Escape') {
                  event.preventDefault()
                  closePicker(true)
                }
              }}
            >
              <div className="grid grid-cols-[minmax(0,1fr)_minmax(0,1fr)_5rem] items-end gap-2">
                <DropdownSelect
                  aria-label="Hour"
                  value={hour}
                  options={hourOptions}
                  onChange={setHour}
                  searchable={false}
                  menuMinWidth={72}
                />
                <DropdownSelect
                  aria-label="Minute"
                  value={minute}
                  options={minuteOptions}
                  onChange={setMinute}
                  searchable={false}
                  menuMinWidth={76}
                />
                <DropdownSelect
                  aria-label="AM or PM"
                  value={period}
                  options={periodOptions}
                  onChange={setPeriod}
                  searchable={false}
                  menuMinWidth={72}
                />
              </div>
              <div className="border-border-subtle mt-3 flex items-center justify-between gap-2 border-t pt-3">
                <div className="flex gap-1">
                  {clearable ? (
                    <Button
                      variant="ghost"
                      size="sm"
                      disabled={!value}
                      onClick={() => {
                        onValueChange('')
                        closePicker(true)
                      }}
                    >
                      Clear
                    </Button>
                  ) : null}
                  <Button variant="ghost" size="sm" onClick={() => closePicker(true)}>
                    Cancel
                  </Button>
                </div>
                <Button
                  size="sm"
                  leadingIcon={<Check className="size-4" aria-hidden="true" />}
                  onClick={commitTime}
                >
                  Set time
                </Button>
              </div>
            </div>,
            portalContainer,
          )
        : null}
    </>
  )
}
