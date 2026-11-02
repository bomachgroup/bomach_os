import {
  useCallback,
  useEffect,
  useId,
  useRef,
  useState,
  type KeyboardEvent as ReactKeyboardEvent,
} from 'react'
import { createPortal } from 'react-dom'
import { CalendarDays, ChevronLeft, ChevronRight } from 'lucide-react'

import { cn } from '@/shared/lib/cn'
import { CONTROL_SIZE_CLASSES } from '@/shared/ui/control-sizing'

import { Button } from './button'
import { DropdownSelect, type DropdownSelectOption } from './dropdown-select'

type DatePickerFieldProps = {
  value: string
  onValueChange: (value: string) => void
  id?: string
  disabled?: boolean
  required?: boolean
  min?: string
  max?: string
  clearable?: boolean
  placeholder?: string
  'aria-describedby'?: string
  'aria-invalid'?: boolean | 'true' | 'false'
}

const fieldClassName = cn(
  CONTROL_SIZE_CLASSES,
  'w-full rounded-control border border-border-subtle bg-surface text-left text-text-primary transition-colors hover:border-border-strong focus-visible:border-primary focus-visible:outline-none focus-visible:shadow-focus-ring disabled:cursor-not-allowed disabled:bg-surface-muted disabled:opacity-60 aria-[invalid=true]:border-danger aria-[invalid=true]:focus-visible:border-danger aria-[invalid=true]:focus-visible:shadow-focus-ring-danger',
)
const weekdayNames = Array.from({ length: 7 }, (_, index) =>
  new Intl.DateTimeFormat(undefined, { weekday: 'short' }).format(new Date(2024, 0, index + 7)),
)
const monthOptions: DropdownSelectOption[] = Array.from({ length: 12 }, (_, index) => ({
  value: String(index),
  label: new Intl.DateTimeFormat(undefined, { month: 'long' }).format(new Date(2024, index, 1)),
}))

type PopoverPosition = {
  position: 'fixed' | 'absolute'
  top: number
  left: number
  width: number
  maxHeight: number
  ready: boolean
}

function parseDate(value: string): Date | null {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null
  const [year, month, day] = value.split('-').map(Number)
  const date = new Date(year, month - 1, day)
  return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day
    ? date
    : null
}

function dateValue(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function startOfMonth(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), 1)
}

function sameMonth(left: Date, right: Date): boolean {
  return left.getFullYear() === right.getFullYear() && left.getMonth() === right.getMonth()
}

function monthLabel(date: Date): string {
  return new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(date)
}

function displayDate(value: string, placeholder: string): string {
  const date = parseDate(value)
  return date
    ? new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(date)
    : placeholder
}

function moveDate(date: Date, amount: number): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + amount)
}

function isInRange(value: string, min?: string, max?: string): boolean {
  return (!min || !parseDate(min) || value >= min) && (!max || !parseDate(max) || value <= max)
}

function clampDay(year: number, month: number, day: number): Date {
  const lastDay = new Date(year, month + 1, 0).getDate()
  return new Date(year, month, Math.min(day, lastDay))
}

function placePopover(
  anchor: Pick<DOMRect, 'left' | 'top' | 'bottom'>,
  panel: Pick<DOMRect, 'width' | 'height'>,
  dialog?: HTMLDialogElement | null,
) {
  const margin = 8
  if (dialog) {
    const dialogRect = dialog.getBoundingClientRect()
    const border = Math.max(dialog.clientLeft, 1)
    const topBorder = Math.max(dialog.clientTop, 1)
    const headerBottom = dialog.querySelector('header')?.getBoundingClientRect().bottom
    const footerTop = dialog.querySelector('footer')?.getBoundingClientRect().top
    const boundsTop = Math.max(dialogRect.top + topBorder + margin, headerBottom ?? dialogRect.top)
    const boundsBottom = Math.min(
      dialogRect.bottom - topBorder - margin,
      footerTop ?? dialogRect.bottom,
    )
    const boundsLeft = dialogRect.left + border + margin
    const boundsRight = dialogRect.right - border - margin
    const width = Math.max(1, Math.min(panel.width, boundsRight - boundsLeft))
    const spaceBelow = Math.max(0, boundsBottom - anchor.bottom - margin)
    const spaceAbove = Math.max(0, anchor.top - boundsTop - margin)
    const height = Math.min(panel.height, Math.max(0, boundsBottom - boundsTop))
    const viewportTop =
      panel.height <= spaceBelow
        ? anchor.bottom + margin
        : panel.height <= spaceAbove
          ? anchor.top - panel.height - margin
          : Math.max(boundsTop, Math.min(anchor.bottom + margin, boundsBottom - height))
    const viewportLeft = Math.max(boundsLeft, Math.min(anchor.left, boundsRight - width))
    return {
      position: 'absolute' as const,
      top: viewportTop - dialogRect.top - topBorder,
      left: viewportLeft - dialogRect.left - border,
      width,
      maxHeight: Math.max(120, height),
    }
  }
  const left = Math.max(margin, Math.min(anchor.left, window.innerWidth - panel.width - margin))
  const spaceBelow = window.innerHeight - anchor.bottom - margin
  const spaceAbove = anchor.top - margin
  const below = anchor.bottom + margin
  const top =
    panel.height <= spaceBelow
      ? below
      : panel.height <= spaceAbove
        ? anchor.top - panel.height - margin
        : Math.max(margin, Math.min(below, window.innerHeight - panel.height - margin))
  return {
    position: 'fixed' as const,
    top,
    left,
    width: panel.width,
    maxHeight: Math.max(120, window.innerHeight - 16),
  }
}

function CalendarGrid({
  month,
  focusedDate,
  selectedDate,
  min,
  max,
  onFocusDate,
  onChoose,
}: {
  month: Date
  focusedDate: Date
  selectedDate: string
  min?: string
  max?: string
  onFocusDate: (date: Date) => void
  onChoose: (date: Date) => void
}) {
  const firstVisible = new Date(month.getFullYear(), month.getMonth(), 1 - month.getDay())
  const days = Array.from({ length: 42 }, (_, index) => moveDate(firstVisible, index))

  function handleDayKeyDown(event: ReactKeyboardEvent<HTMLButtonElement>, date: Date) {
    let next: Date | null = null
    if (event.key === 'ArrowLeft') next = moveDate(date, -1)
    if (event.key === 'ArrowRight') next = moveDate(date, 1)
    if (event.key === 'ArrowUp') next = moveDate(date, -7)
    if (event.key === 'ArrowDown') next = moveDate(date, 7)
    if (event.key === 'Home') next = moveDate(date, -date.getDay())
    if (event.key === 'End') next = moveDate(date, 6 - date.getDay())
    if (event.key === 'PageUp') {
      const monthOffset = event.shiftKey ? -12 : -1
      next = clampDay(date.getFullYear(), date.getMonth() + monthOffset, date.getDate())
    }
    if (event.key === 'PageDown') {
      const monthOffset = event.shiftKey ? 12 : 1
      next = clampDay(date.getFullYear(), date.getMonth() + monthOffset, date.getDate())
    }
    if (!next) return
    event.preventDefault()
    const nextValue = dateValue(next)
    if (!isInRange(nextValue, min, max)) return
    onFocusDate(next)
    event.currentTarget
      .closest('[role="grid"]')
      ?.querySelector<HTMLButtonElement>(`[data-date="${nextValue}"]`)
      ?.focus()
  }

  return (
    <div role="grid" aria-label={monthLabel(month)} className="tablet:mt-4 mt-3">
      <div role="row" className="grid grid-cols-7">
        {weekdayNames.map((name) => (
          <div
            key={name}
            role="columnheader"
            aria-label={name}
            className="text-caption text-text-muted tablet:py-2 py-1 text-center font-medium"
          >
            {name.slice(0, 2)}
          </div>
        ))}
      </div>
      {Array.from({ length: 6 }, (_, rowIndex) => (
        <div role="row" key={rowIndex} className="grid grid-cols-7">
          {days.slice(rowIndex * 7, rowIndex * 7 + 7).map((date) => {
            const value = dateValue(date)
            const today = value === dateValue(new Date())
            const selected = value === selectedDate
            const outsideMonth = !sameMonth(date, month)
            const disabled = !isInRange(value, min, max)
            return (
              <div role="gridcell" key={value} aria-selected={selected}>
                <button
                  type="button"
                  data-date={value}
                  tabIndex={value === dateValue(focusedDate) && !disabled ? 0 : -1}
                  aria-label={new Intl.DateTimeFormat(undefined, {
                    weekday: 'long',
                    day: 'numeric',
                    month: 'long',
                    year: 'numeric',
                  }).format(date)}
                  aria-pressed={selected}
                  aria-current={today ? 'date' : undefined}
                  disabled={disabled}
                  onFocus={() => onFocusDate(date)}
                  onKeyDown={(event) => handleDayKeyDown(event, date)}
                  onClick={() => onChoose(date)}
                  className={cn(
                    'focus-visible:shadow-focus-ring text-body-sm tablet:size-9 mx-auto flex size-8 items-center justify-center rounded-full transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-30',
                    selected
                      ? 'bg-primary text-text-on-primary font-semibold'
                      : today
                        ? 'border-primary text-primary border font-semibold'
                        : 'text-text-primary hover:bg-primary-subtle',
                    outsideMonth && !selected && 'text-text-muted',
                  )}
                >
                  {date.getDate()}
                </button>
              </div>
            )
          })}
        </div>
      ))}
    </div>
  )
}

export function DatePickerField({
  value,
  onValueChange,
  id,
  disabled = false,
  required = false,
  min,
  max,
  clearable = false,
  placeholder = 'Choose a date',
  'aria-describedby': describedBy,
  'aria-invalid': invalid,
}: DatePickerFieldProps) {
  const generatedId = useId()
  const triggerId = id ?? `date-picker-${generatedId}`
  const calendarId = `${triggerId}-calendar`
  const triggerRef = useRef<HTMLButtonElement>(null)
  const popoverRef = useRef<HTMLDivElement>(null)
  const dialogSizeRef = useRef<{
    dialog: HTMLDialogElement
    minHeight: string
    maxHeight: string
  } | null>(null)
  const [open, setOpen] = useState(false)
  const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null)
  const selected = parseDate(value)
  const today = new Date()
  const [month, setMonth] = useState(() => startOfMonth(selected ?? today))
  const [focusedDate, setFocusedDate] = useState(() => selected ?? today)
  const [position, setPosition] = useState<PopoverPosition>({
    position: 'fixed' as const,
    top: 0,
    left: 8,
    width: 320,
    maxHeight: 0,
    ready: false,
  })
  const yearRange = [
    Math.min(today.getFullYear() - 10, selected?.getFullYear() ?? today.getFullYear()),
    Math.max(today.getFullYear() + 10, selected?.getFullYear() ?? today.getFullYear()),
  ] as const
  const years = Array.from(
    { length: yearRange[1] - yearRange[0] + 1 },
    (_, index) => yearRange[0] + index,
  )

  const closePicker = useCallback(() => {
    setOpen(false)
    setPortalContainer(null)
    setPosition((current) => ({ ...current, ready: false }))
    if (dialogSizeRef.current) {
      const { dialog, minHeight, maxHeight } = dialogSizeRef.current
      dialog.style.minHeight = minHeight
      dialog.style.maxHeight = maxHeight
      dialogSizeRef.current = null
    }
    window.requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  function openPicker() {
    const initialDate = selected ?? new Date()
    const dialog = triggerRef.current?.closest<HTMLDialogElement>('dialog[open]')
    if (dialog) {
      dialogSizeRef.current = {
        dialog,
        minHeight: dialog.style.minHeight,
        maxHeight: dialog.style.maxHeight,
      }
      dialog.style.minHeight = 'min(90dvh, 44rem)'
      dialog.style.maxHeight = '90dvh'
    }
    setPortalContainer(dialog ?? document.body)
    setPosition((current) => ({ ...current, ready: false }))
    setMonth(startOfMonth(initialDate))
    setFocusedDate(initialDate)
    setOpen(true)
  }

  function commitDate(date: Date) {
    const nextValue = dateValue(date)
    if (!isInRange(nextValue, min, max)) return
    onValueChange(nextValue)
    closePicker()
  }

  function shiftMonth(amount: number) {
    const nextMonth = new Date(month.getFullYear(), month.getMonth() + amount, 1)
    setMonth(nextMonth)
    setFocusedDate((current) =>
      clampDay(nextMonth.getFullYear(), nextMonth.getMonth(), current.getDate()),
    )
  }

  function changeMonth(monthNumber: number) {
    const nextMonth = new Date(month.getFullYear(), monthNumber, 1)
    setMonth(nextMonth)
    setFocusedDate((current) =>
      clampDay(nextMonth.getFullYear(), nextMonth.getMonth(), current.getDate()),
    )
  }

  function changeYear(year: number) {
    const nextMonth = new Date(year, month.getMonth(), 1)
    setMonth(nextMonth)
    setFocusedDate((current) => clampDay(year, nextMonth.getMonth(), current.getDate()))
  }

  useEffect(() => {
    if (!open) return
    function positionPopover() {
      const anchor = triggerRef.current?.getBoundingClientRect()
      const panel = popoverRef.current
      if (!anchor || !panel) return
      const bounds = panel.getBoundingClientRect()
      const dialog =
        portalContainer?.tagName === 'DIALOG' ? (portalContainer as HTMLDialogElement) : null
      setPosition({ ...placePopover(anchor, bounds, dialog), ready: true })
    }
    function handleOutside(event: PointerEvent) {
      const target = event.target
      if (
        target instanceof Node &&
        !triggerRef.current?.contains(target) &&
        !popoverRef.current?.contains(target)
      ) {
        if (target instanceof Element && target.closest('[data-dropdown-menu]')) return
        closePicker()
      }
    }
    positionPopover()
    window.addEventListener('resize', positionPopover)
    window.addEventListener('scroll', positionPopover, true)
    document.addEventListener('pointerdown', handleOutside)
    return () => {
      window.removeEventListener('resize', positionPopover)
      window.removeEventListener('scroll', positionPopover, true)
      document.removeEventListener('pointerdown', handleOutside)
    }
  }, [closePicker, open, portalContainer])

  useEffect(() => {
    if (!open) return
    const frame = window.requestAnimationFrame(() => {
      popoverRef.current
        ?.querySelector<HTMLButtonElement>(`[data-date="${dateValue(focusedDate)}"]`)
        ?.focus()
      const anchor = triggerRef.current?.getBoundingClientRect()
      const panel = popoverRef.current?.getBoundingClientRect()
      if (anchor && panel) {
        const dialog =
          portalContainer?.tagName === 'DIALOG' ? (portalContainer as HTMLDialogElement) : null
        setPosition({ ...placePopover(anchor, panel, dialog), ready: true })
      }
    })
    return () => window.cancelAnimationFrame(frame)
  }, [focusedDate, month, open, portalContainer])

  const calendar = (
    <div className="min-w-0">
      <div className="flex items-center gap-2">
        <button
          type="button"
          aria-label="Previous month"
          onClick={() => shiftMonth(-1)}
          className="focus-visible:shadow-focus-ring rounded-control hover:bg-surface-muted phone:size-10 flex size-8 shrink-0 items-center justify-center focus-visible:outline-none"
        >
          <ChevronLeft className="size-4" aria-hidden="true" />
        </button>
        <DropdownSelect
          aria-label="Month"
          value={String(month.getMonth())}
          options={monthOptions}
          onChange={(value) => changeMonth(Number(value))}
          searchable={false}
          menuMinWidth={160}
          className="min-w-0 flex-1"
        />
        <DropdownSelect
          aria-label="Year"
          value={String(month.getFullYear())}
          options={years.map((year) => ({ value: String(year), label: String(year) }))}
          onChange={(value) => changeYear(Number(value))}
          menuMinWidth={160}
          className="phone:w-24 w-16 shrink-0"
        />
        <button
          type="button"
          aria-label="Next month"
          onClick={() => shiftMonth(1)}
          className="focus-visible:shadow-focus-ring rounded-control hover:bg-surface-muted phone:size-10 flex size-8 shrink-0 items-center justify-center focus-visible:outline-none"
        >
          <ChevronRight className="size-4" aria-hidden="true" />
        </button>
      </div>
      <CalendarGrid
        month={month}
        focusedDate={focusedDate}
        selectedDate={value}
        min={min}
        max={max}
        onFocusDate={(date) => {
          setFocusedDate(date)
          if (!sameMonth(date, month)) setMonth(startOfMonth(date))
        }}
        onChoose={commitDate}
      />
      <div className="border-border-subtle tablet:mt-3 tablet:pt-3 mt-2 flex items-center justify-between gap-2 border-t pt-2">
        <div className="flex gap-1">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              const now = new Date()
              if (isInRange(dateValue(now), min, max)) commitDate(now)
            }}
            disabled={!isInRange(dateValue(new Date()), min, max)}
          >
            Today
          </Button>
          {clearable ? (
            <Button
              variant="ghost"
              size="sm"
              disabled={!value}
              onClick={() => {
                onValueChange('')
                closePicker()
              }}
            >
              Clear
            </Button>
          ) : null}
        </div>
      </div>
    </div>
  )

  return (
    <>
      <button
        ref={triggerRef}
        id={triggerId}
        type="button"
        disabled={disabled}
        aria-haspopup="dialog"
        aria-expanded={open}
        aria-controls={open ? calendarId : undefined}
        aria-required={required || undefined}
        aria-invalid={invalid}
        aria-describedby={describedBy}
        onClick={open ? closePicker : openPicker}
        className={cn(fieldClassName, 'flex items-center justify-between gap-3')}
      >
        <span
          className={cn('min-w-0 truncate', !value && 'text-text-muted')}
          title={displayDate(value, placeholder)}
        >
          {displayDate(value, placeholder)}
        </span>
        <CalendarDays className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
      </button>
      {open && portalContainer
        ? createPortal(
            <div
              ref={popoverRef}
              id={calendarId}
              role="dialog"
              aria-label="Choose a date"
              className="bg-surface border-border-subtle shadow-elevation-lg rounded-surface tablet:p-4 z-[100] w-[min(22rem,calc(100vw-1rem))] max-w-[calc(100vw-1rem)] border p-3"
              style={{
                position: position.position,
                top: position.top,
                left: position.left,
                width: `${position.width}px`,
                maxHeight: `${position.maxHeight || Math.max(120, window.innerHeight - 16)}px`,
                overflowY: 'auto',
                visibility: position.ready ? 'visible' : 'hidden',
              }}
              onKeyDown={(event) => {
                if (event.key === 'Escape') {
                  event.preventDefault()
                  closePicker()
                }
              }}
            >
              {calendar}
            </div>,
            portalContainer,
          )
        : null}
    </>
  )
}
