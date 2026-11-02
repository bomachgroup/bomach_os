import { useState } from 'react'
import { ChevronDown, Copy, Sparkles } from 'lucide-react'

import { WEEKDAYS, type DayScheduleDraft } from '@/modules/company/branch-hours'
import { Button } from '@/shared/ui/button'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { FormControl } from '@/shared/ui/form-control'
import { TimePickerField } from '@/shared/ui/time-picker-field'

function TargetDayButtons({
  sourceIndex,
  targetIndexes,
  onToggle,
}: {
  sourceIndex: number
  targetIndexes: number[]
  onToggle: (index: number) => void
}) {
  return (
    <div className="flex flex-wrap gap-1.5" role="group" aria-label="Days to copy the schedule to">
      {WEEKDAYS.map((day, index) => {
        const isSource = index === sourceIndex
        const isSelected = targetIndexes.includes(index)
        return (
          <button
            key={day}
            type="button"
            aria-label={isSource ? `${day}, source day` : day}
            aria-pressed={isSelected}
            disabled={isSource}
            onClick={() => onToggle(index)}
            className={`focus-visible:shadow-focus-ring rounded-pill text-overline inline-flex min-h-9 min-w-9 items-center justify-center border px-2.5 font-semibold transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-45 ${isSelected ? 'border-primary bg-primary text-text-on-primary' : 'border-border-subtle bg-surface text-text-secondary hover:border-primary/40 hover:text-text-primary'}`}
          >
            <span aria-hidden="true">{day.slice(0, 3)}</span>
          </button>
        )
      })}
    </div>
  )
}

export function BranchHoursEditor({
  days,
  onChange,
  idPrefix,
}: {
  days: DayScheduleDraft[]
  onChange: (days: DayScheduleDraft[]) => void
  idPrefix: string
}) {
  const [sourceIndex, setSourceIndex] = useState(0)
  const [targetIndexes, setTargetIndexes] = useState<number[]>([])
  const [copyMessage, setCopyMessage] = useState<string | null>(null)

  function updateDay(index: number, patch: Partial<DayScheduleDraft>) {
    onChange(days.map((day, dayIndex) => (dayIndex === index ? { ...day, ...patch } : day)))
    setCopyMessage(null)
  }

  function toggleTarget(index: number) {
    setCopyMessage(null)
    setTargetIndexes((current) =>
      current.includes(index) ? current.filter((target) => target !== index) : [...current, index],
    )
  }

  function copySchedule(requestedTargets: number[], scope: 'selected' | 'all') {
    const source = days[sourceIndex]
    if (!source) return

    const targets = [...new Set(requestedTargets)].filter(
      (index) =>
        Number.isInteger(index) && index >= 0 && index < days.length && index !== sourceIndex,
    )
    if (!targets.length) {
      setCopyMessage('Choose at least one other day to update.')
      return
    }

    const targetSet = new Set(targets)
    onChange(days.map((day, index) => (targetSet.has(index) ? { ...source } : day)))
    setTargetIndexes([])
    setCopyMessage(
      scope === 'all'
        ? `Applied ${WEEKDAYS[sourceIndex]}’s schedule to all ${targets.length} other days.`
        : `Applied ${WEEKDAYS[sourceIndex]}’s schedule to ${targets.map((index) => WEEKDAYS[index]).join(', ')}.`,
    )
  }

  const sourceDay = days[sourceIndex]
  const modeLabel =
    sourceDay?.mode === 'open'
      ? `Open · ${sourceDay.openTime || 'time not set'}–${sourceDay.closeTime || 'time not set'}`
      : sourceDay?.mode === 'closed'
        ? 'Closed all day'
        : 'Not set'

  return (
    <div className="space-y-3">
      <section
        aria-label="Copy weekly schedule"
        className="border-border-subtle bg-primary-subtle/30 rounded-control phone:p-4 space-y-3 border p-3"
      >
        <div className="flex items-start gap-3">
          <span className="bg-surface text-primary rounded-control flex size-9 shrink-0 items-center justify-center border border-white/70 shadow-sm">
            <Copy className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <h4 className="text-body-sm font-semibold">Copy a day’s schedule</h4>
            <p className="text-caption text-text-secondary mt-0.5 max-w-2xl">
              Choose a source day, then apply its open hours, closed state, or unset state to other
              days.
            </p>
          </div>
        </div>

        <div className="tablet:grid-cols-[minmax(10rem,0.8fr)_minmax(0,1.2fr)] grid min-w-0 gap-3">
          <FormControl id={`${idPrefix}-copy-source`} label="Copy from">
            <DropdownSelect
              id={`${idPrefix}-copy-source`}
              aria-label="Copy schedule from day"
              value={String(sourceIndex)}
              options={WEEKDAYS.map((day, index) => ({ value: String(index), label: day }))}
              onChange={(value) => {
                setSourceIndex(Number(value))
                setTargetIndexes([])
                setCopyMessage(null)
              }}
            />
          </FormControl>

          <div className="min-w-0">
            <p className="text-control-label text-text-secondary mb-1.5 font-bold">Apply to</p>

            <div className="tablet:block hidden">
              <TargetDayButtons
                sourceIndex={sourceIndex}
                targetIndexes={targetIndexes}
                onToggle={toggleTarget}
              />
            </div>

            <details className="tablet:hidden border-border-subtle bg-surface rounded-control border">
              <summary className="text-control-value marker:text-text-muted focus-visible:ring-primary flex min-h-10 cursor-pointer list-inside items-center justify-between gap-3 px-3 py-2 font-medium focus-visible:ring-2 focus-visible:outline-none">
                <span>
                  {targetIndexes.length
                    ? `${targetIndexes.length} ${targetIndexes.length === 1 ? 'day' : 'days'} selected`
                    : 'Choose days to update'}
                </span>
                <ChevronDown className="text-text-muted size-4 shrink-0" aria-hidden="true" />
              </summary>
              <div className="border-border-subtle space-y-2 border-t p-3">
                <p className="text-caption text-text-secondary">
                  Select one or more days. The source day is unavailable.
                </p>
                <TargetDayButtons
                  sourceIndex={sourceIndex}
                  targetIndexes={targetIndexes}
                  onToggle={toggleTarget}
                />
              </div>
            </details>

            <p className="text-overline text-text-secondary mt-2" aria-live="polite">
              Copying from {WEEKDAYS[sourceIndex]} · {modeLabel}
            </p>
          </div>
        </div>

        <div className="tablet:flex-row tablet:items-center tablet:justify-between border-border-subtle flex flex-col gap-3 border-t pt-3">
          <p className="text-caption text-text-secondary min-h-5" role="status" aria-live="polite">
            {copyMessage ??
              (targetIndexes.length
                ? `${targetIndexes.length} ${targetIndexes.length === 1 ? 'day' : 'days'} selected`
                : 'Select days to apply a copy, or apply to every other day.')}
          </p>
          <div className="phone:grid-cols-2 tablet:flex tablet:w-auto grid w-full gap-2">
            <Button
              type="button"
              variant="primary"
              size="md"
              className="tablet:w-auto w-full"
              disabled={targetIndexes.length === 0}
              onClick={() => copySchedule(targetIndexes, 'selected')}
            >
              Apply to selected
            </Button>
            <Button
              type="button"
              variant="outline"
              size="md"
              className="tablet:w-auto w-full"
              leadingIcon={<Sparkles className="size-4" aria-hidden="true" />}
              onClick={() =>
                copySchedule(
                  WEEKDAYS.map((_, index) => index).filter((index) => index !== sourceIndex),
                  'all',
                )
              }
            >
              Apply to all days
            </Button>
          </div>
        </div>
      </section>

      <div className="space-y-2">
        {days.map((day, index) => (
          <div
            key={WEEKDAYS[index]}
            className="border-border-subtle bg-surface-muted/35 rounded-control phone:grid-cols-2 tablet:grid-cols-[minmax(7rem,0.7fr)_minmax(9rem,0.8fr)_1fr_1fr] tablet:items-center grid min-w-0 gap-2 border p-3"
          >
            <span className="text-body-sm self-center font-semibold">{WEEKDAYS[index]}</span>
            <DropdownSelect
              aria-label={`${WEEKDAYS[index]} schedule`}
              value={day.mode}
              options={[
                { value: 'unset', label: 'Not set' },
                { value: 'closed', label: 'Closed' },
                { value: 'open', label: 'Open' },
              ]}
              onChange={(mode) => updateDay(index, { mode: mode as DayScheduleDraft['mode'] })}
            />
            {day.mode === 'open' ? (
              <FormControl id={`${idPrefix}-open-${index}`} label="Opens">
                <TimePickerField
                  value={day.openTime}
                  onValueChange={(value) => updateDay(index, { openTime: value })}
                />
              </FormControl>
            ) : (
              <span className="text-caption text-text-muted phone:col-span-2 tablet:col-span-2 self-center">
                {day.mode === 'closed' ? 'Closed all day' : 'No saved schedule'}
              </span>
            )}
            {day.mode === 'open' ? (
              <FormControl id={`${idPrefix}-close-${index}`} label="Closes">
                <TimePickerField
                  value={day.closeTime}
                  onValueChange={(value) => updateDay(index, { closeTime: value })}
                />
              </FormControl>
            ) : null}
          </div>
        ))}
      </div>
    </div>
  )
}
