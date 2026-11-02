import { useLayoutEffect, useMemo, useRef } from 'react'
import { Plus, Trash2 } from 'lucide-react'

import { Button } from '@/shared/ui/button'
import { TextArea } from '@/shared/ui/form-control'

const MAX_REPORT_ITEMS = 10

type ReportEntryListProps = {
  id: string
  label: string
  itemLabel: string
  description: string
  placeholder: string
  entries: string[]
  onChange: (entries: string[]) => void
  required?: boolean
  error?: string
}

export function ReportEntryList({
  id,
  label,
  itemLabel,
  description,
  placeholder,
  entries,
  onChange,
  required = false,
  error,
}: ReportEntryListProps) {
  const visibleEntries = useMemo(
    () => (entries.length > 0 ? entries : required ? [''] : []),
    [entries, required],
  )
  const textareaRefs = useRef<Array<HTMLTextAreaElement | null>>([])
  const descriptionId = `${id}-description`
  const errorId = error ? `${id}-error` : undefined
  const describedBy = [descriptionId, errorId].filter(Boolean).join(' ')

  useLayoutEffect(() => {
    textareaRefs.current.forEach((textarea) => {
      if (!textarea) return
      textarea.style.height = 'auto'
      textarea.style.height = `${textarea.scrollHeight}px`
    })
  }, [visibleEntries])

  function updateEntry(index: number, value: string) {
    const next = [...visibleEntries]
    next[index] = value
    onChange(next)
  }

  function addEntry() {
    if (visibleEntries.length >= MAX_REPORT_ITEMS) return
    onChange([...visibleEntries, ''])
  }

  function removeEntry(index: number) {
    if (visibleEntries.length <= 1) return
    onChange(visibleEntries.filter((_, entryIndex) => entryIndex !== index))
  }

  return (
    <fieldset
      className="space-y-3"
      aria-describedby={describedBy}
      aria-required={required || undefined}
    >
      <div className="flex flex-wrap items-start justify-between gap-x-4 gap-y-1">
        <legend className="text-label text-text-primary font-semibold">
          {label}
          {required ? (
            <span aria-hidden="true" className="text-danger ml-1">
              *
            </span>
          ) : null}
        </legend>
        <span className="text-caption text-text-muted">
          {visibleEntries.length} of {MAX_REPORT_ITEMS}
        </span>
      </div>
      <p id={descriptionId} className="text-body-sm text-text-secondary -mt-1">
        {description}
      </p>

      {visibleEntries.length ? (
        <div className="space-y-2.5">
          {visibleEntries.map((entry, index) => (
            <div
              key={`${id}-entry-${index}`}
              className="rounded-control border-border-subtle bg-surface tablet:p-3 focus-within:border-primary focus-within:shadow-elevation-sm grid grid-cols-[2.25rem_minmax(0,1fr)] items-start gap-2.5 border p-2.5 transition-colors"
            >
              <span
                aria-hidden="true"
                className="bg-primary-subtle text-primary text-caption mt-0.5 flex size-9 items-center justify-center rounded-full font-semibold"
              >
                {String(index + 1).padStart(2, '0')}
              </span>
              <div className="min-w-0">
                <div className="mb-1 flex min-h-8 items-center justify-between gap-2">
                  <span className="text-caption text-text-secondary font-medium">
                    {itemLabel} {index + 1}
                  </span>
                  {visibleEntries.length > 1 ? (
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon"
                      aria-label={`Remove ${itemLabel.toLowerCase()} ${index + 1}`}
                      onClick={() => removeEntry(index)}
                      className="text-text-secondary hover:text-danger size-8"
                    >
                      <Trash2 className="size-4" aria-hidden="true" />
                    </Button>
                  ) : null}
                </div>
                <TextArea
                  ref={(element) => {
                    textareaRefs.current[index] = element
                  }}
                  id={`${id}-${index}`}
                  rows={2}
                  value={entry}
                  onChange={(event) => {
                    const textarea = event.currentTarget
                    textarea.style.height = 'auto'
                    textarea.style.height = `${textarea.scrollHeight}px`
                    updateEntry(index, textarea.value)
                  }}
                  placeholder={placeholder}
                  aria-label={`${itemLabel} ${index + 1}`}
                  aria-describedby={describedBy || undefined}
                  aria-invalid={error ? 'true' : undefined}
                  className="tablet:min-h-24 min-h-20 resize-none"
                />
              </div>
            </div>
          ))}
        </div>
      ) : null}

      {error ? (
        <p id={errorId} className="text-body-sm text-danger" role="status">
          {error}
        </p>
      ) : null}

      {visibleEntries.length < MAX_REPORT_ITEMS ? (
        <Button
          type="button"
          variant="outline"
          size="sm"
          leadingIcon={<Plus className="size-4" aria-hidden="true" />}
          onClick={addEntry}
          className="tablet:w-auto w-full border-dashed"
        >
          Add {itemLabel.toLowerCase()}
        </Button>
      ) : null}
    </fieldset>
  )
}
