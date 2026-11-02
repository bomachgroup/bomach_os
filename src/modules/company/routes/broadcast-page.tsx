import {
  useCallback,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type FormEvent,
  type ReactNode,
} from 'react'
import { createPortal } from 'react-dom'
import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Bell,
  CalendarDays,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Clock3,
  MapPin,
  Megaphone,
  Plus,
  Search,
  Send,
  Trash2,
  UserRound,
  UsersRound,
} from 'lucide-react'

import {
  broadcastApi,
  broadcastQueryKeys,
  type AnnouncementDto,
  type AnnouncementInput,
  type EventDto,
  type EventInput,
} from '@/modules/company/broadcast.api'
import { branchesApi } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { TimePickerField } from '@/shared/ui/time-picker-field'

import type { BroadcastSearch } from '../broadcast.search'

const PAGE_SIZE = 10
const ANNOUNCEMENT_FORM_ID = 'broadcast-announcement-form'
const EVENT_FORM_ID = 'broadcast-event-form'
const tabs = [
  { value: 'announcements', label: 'Announcements', icon: Megaphone, resource: 'announcements' },
  { value: 'events', label: 'Events', icon: CalendarDays, resource: 'events' },
] as const

type BroadcastTab = (typeof tabs)[number]['value']

function formatDate(value: string | null | undefined, withTime = false) {
  if (!value) return 'Not scheduled'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    ...(withTime ? { hour: 'numeric', minute: '2-digit' } : {}),
  }).format(parsed)
}

function toLocalInput(value: string | null) {
  if (!value) return ''
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return ''
  const local = new Date(parsed.getTime() - parsed.getTimezoneOffset() * 60_000)
  return local.toISOString().slice(0, 16)
}

function localDateParts(value: string | null) {
  const local = toLocalInput(value)
  return local ? { date: local.slice(0, 10), time: local.slice(11, 16) } : { date: '', time: '' }
}

function localDateTimeToIso(date: string, time: string) {
  if (!date || !time) return null
  const parsed = new Date(`${date}T${time}`)
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString()
}

function localDateValue(date: Date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function formatEventRange(start: string, end: string) {
  const startDate = new Date(start)
  const endDate = new Date(end)
  if (Number.isNaN(startDate.getTime()) || Number.isNaN(endDate.getTime())) {
    return `${formatDate(start, true)} – ${formatDate(end, true)}`
  }

  const date = new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
  const time = new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' })
  if (localDateValue(startDate) === localDateValue(endDate)) {
    return `${date.format(startDate)} · ${time.format(startDate)}–${time.format(endDate)}`
  }
  return `${formatDate(start, true)} – ${formatDate(end, true)}`
}

function announcementAudience(item: AnnouncementDto) {
  const branches = item.targets_all_branches
    ? 'All branches'
    : item.branches.length === 1
      ? item.branches[0].branch_name
      : item.branches.length
        ? `${item.branches.length} branches`
        : 'Branch scope not recorded'
  const departments = item.targets_all_departments
    ? 'All departments'
    : item.departments.length === 1
      ? item.departments[0].name
      : item.departments.length
        ? `${item.departments.length} departments`
        : 'Department scope not recorded'
  return `${branches} · ${departments}`
}

function announcementAudienceDetails(item: AnnouncementDto) {
  const branches = item.targets_all_branches
    ? 'All branches'
    : item.branches.map(({ branch_name }) => branch_name).join(', ') || 'Branch scope not recorded'
  const departments = item.targets_all_departments
    ? 'All departments'
    : item.departments.map(({ name }) => name).join(', ') || 'Department scope not recorded'
  return `${branches} · ${departments}`
}

function eventAudienceSummary(audience: string[]) {
  if (!audience.length) return 'No audience selected'
  if (audience.length === 1) return audience[0]
  return `${audience.length} groups selected`
}

function eventStart(event: EventDto) {
  return event.event_time_from_iso || event.event_time_from
}

function eventCanBeEdited(event: EventDto) {
  const startsAt = new Date(eventStart(event)).getTime()
  return Number.isFinite(startsAt) && startsAt > Date.now()
}

function actionTone(isActive: boolean): 'success' | 'neutral' {
  return isActive ? 'success' : 'neutral'
}

function TargetPicker({
  title,
  options,
  selected,
  onChange,
  all,
  onAllChange,
  optionsState,
  onRetry,
  savedSelection,
}: {
  title: string
  options: { id: number; label: string }[]
  selected: number[]
  onChange: (value: number[]) => void
  all: boolean
  onAllChange: (value: boolean) => void
  optionsState: 'ready' | 'loading' | 'error' | 'unavailable'
  onRetry?: () => void
  savedSelection: string[]
}) {
  const canSelect = optionsState === 'ready' && options.length > 0
  const audienceId = title.toLowerCase()

  return (
    <fieldset
      data-audience={audienceId}
      className="border-border-subtle bg-surface-muted/60 rounded-control min-w-0 border p-3"
    >
      <legend className="text-label text-text-primary px-1 font-semibold">{title}</legend>
      <label className="text-body-sm text-text-primary flex min-h-10 cursor-pointer items-center gap-2">
        <input
          type="checkbox"
          checked={all}
          disabled={!canSelect}
          onChange={(event) => {
            onAllChange(event.target.checked)
            if (event.target.checked) onChange([])
          }}
        />
        All {title.toLowerCase()}
      </label>
      {!all && optionsState === 'ready' && options.length ? (
        <div className="border-border-subtle mt-2 grid max-h-36 gap-1 overflow-y-auto border-t pt-2">
          {options.map((option) => (
            <label
              key={option.id}
              className="text-caption text-text-secondary flex min-h-9 cursor-pointer items-center gap-2"
            >
              <input
                type="checkbox"
                data-audience-option
                checked={selected.includes(option.id)}
                onChange={(event) =>
                  onChange(
                    event.target.checked
                      ? [...selected, option.id]
                      : selected.filter((id) => id !== option.id),
                  )
                }
              />
              <span className="truncate">{option.label}</span>
            </label>
          ))}
        </div>
      ) : optionsState === 'loading' ? (
        <p role="status" className="text-caption text-text-secondary mt-1">
          Loading {title.toLowerCase()}…
        </p>
      ) : optionsState === 'error' ? (
        <div className="mt-1 flex flex-wrap items-center justify-between gap-2">
          <p role="alert" className="text-caption text-danger">
            Could not load {title.toLowerCase()}. Retry before changing this audience.
          </p>
          {onRetry ? (
            <Button type="button" variant="ghost" size="sm" onClick={onRetry}>
              Retry
            </Button>
          ) : null}
        </div>
      ) : optionsState === 'unavailable' ? (
        <p className="text-caption text-text-secondary mt-1">
          Your role cannot edit {title.toLowerCase()} targeting.{' '}
          {!all && savedSelection.length
            ? `The existing audience is preserved: ${savedSelection.join(', ')}.`
            : `This announcement will include all ${title.toLowerCase()}.`}
        </p>
      ) : !options.length ? (
        <p className="text-caption text-text-secondary mt-1">
          No {title.toLowerCase()} are available to target. All {title.toLowerCase()} will be
          included.
        </p>
      ) : null}
    </fieldset>
  )
}

const eventAudienceOptions = [
  { key: 'branches', label: 'All branches' },
  { key: 'departments', label: 'All departments' },
  { key: 'associates', label: 'All associates' },
  { key: 'investors', label: 'All investors' },
  { key: 'partners', label: 'All partners' },
] as const

type EventAudienceKey = (typeof eventAudienceOptions)[number]['key']

function RequiredTimeField({
  id,
  label,
  value,
  disabled,
  onChange,
}: {
  id: string
  label: string
  value: string
  disabled: boolean
  onChange: (value: string) => void
}) {
  return (
    <div className="space-y-1.5">
      <label htmlFor={id} className="text-control-label text-text-secondary block font-bold">
        {label}
        <span aria-hidden="true" className="text-danger ml-1">
          *
        </span>
      </label>
      <TimePickerField
        id={id}
        value={value}
        disabled={disabled}
        required
        aria-required="true"
        onValueChange={onChange}
      />
    </div>
  )
}

function EventAudiencePicker({
  id,
  value,
  onChange,
  'aria-describedby': describedBy,
  'aria-invalid': invalid,
  'aria-required': required,
}: {
  id?: string
  value: EventAudienceKey[]
  onChange: (value: EventAudienceKey[]) => void
  'aria-describedby'?: string
  'aria-invalid'?: boolean | 'true' | 'false'
  'aria-required'?: boolean | 'true' | 'false'
}) {
  const generatedId = useId()
  const controlId = id ?? `event-audience-${generatedId}`
  const menuId = `${controlId}-menu`
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const [open, setOpen] = useState(false)
  const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null)
  const [position, setPosition] = useState<{
    position: 'absolute' | 'fixed'
    top: number
    left: number
    width: number
  } | null>(null)
  const selectedLabels = eventAudienceOptions
    .filter(({ key }) => value.includes(key))
    .map(({ label }) => label)

  const closeMenu = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPortalContainer(null)
    setPosition(null)
    if (restoreFocus) window.requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  useEffect(() => {
    if (!open) return
    const trigger = triggerRef.current
    const menu = menuRef.current
    if (!trigger || !menu) return

    const updatePosition = () => {
      const anchor = trigger.getBoundingClientRect()
      const dialog = trigger.closest('dialog[open]')
      const dialogRect = dialog?.getBoundingClientRect()
      const dialogElement = dialog && dialogRect ? dialog : null
      const bounds =
        dialogElement && dialogRect
          ? {
              top: dialogRect.top + Math.max(dialogElement.clientTop, 1),
              right: dialogRect.right - Math.max(dialogElement.clientLeft, 1),
              bottom: dialogRect.bottom - Math.max(dialogElement.clientTop, 1),
              left: dialogRect.left + Math.max(dialogElement.clientLeft, 1),
            }
          : { top: 8, right: window.innerWidth - 8, bottom: window.innerHeight - 8, left: 8 }
      const width = Math.min(anchor.width, bounds.right - bounds.left)
      const left = Math.min(Math.max(anchor.left, bounds.left), bounds.right - width)
      const menuHeight = Math.min(menu.scrollHeight, 280)
      const below = bounds.bottom - anchor.bottom - 8
      const above = anchor.top - bounds.top - 8
      const top =
        below >= menuHeight || below >= above ? anchor.bottom + 4 : anchor.top - menuHeight - 4
      setPosition({
        position: dialogElement && dialogRect ? 'absolute' : 'fixed',
        top:
          dialogElement && dialogRect
            ? top - dialogRect.top - Math.max(dialogElement.clientTop, 1)
            : top,
        left:
          dialogElement && dialogRect
            ? left - dialogRect.left - Math.max(dialogElement.clientLeft, 1)
            : left,
        width,
      })
    }
    const handleOutside = (event: PointerEvent) => {
      const target = event.target
      if (target instanceof Node && !trigger.contains(target) && !menu.contains(target)) closeMenu()
    }

    updatePosition()
    const focusFrame = window.requestAnimationFrame(() => {
      menu.querySelector<HTMLInputElement>('input[type="checkbox"]')?.focus()
    })
    window.addEventListener('resize', updatePosition)
    window.addEventListener('scroll', updatePosition, true)
    document.addEventListener('pointerdown', handleOutside)
    return () => {
      window.cancelAnimationFrame(focusFrame)
      window.removeEventListener('resize', updatePosition)
      window.removeEventListener('scroll', updatePosition, true)
      document.removeEventListener('pointerdown', handleOutside)
    }
  }, [closeMenu, open, portalContainer])

  function toggleMenu() {
    if (open) {
      closeMenu()
      return
    }
    setPortalContainer(triggerRef.current?.closest('dialog[open]') ?? document.body)
    setOpen(true)
  }

  const menu =
    open && portalContainer
      ? createPortal(
          <div
            ref={menuRef}
            id={menuId}
            role="dialog"
            aria-label="Notify audience"
            className="bg-surface border-border-subtle shadow-elevation-lg rounded-control fixed z-[200] max-h-[min(17.5rem,calc(100dvh-1rem))] overflow-y-auto border p-2"
            style={{
              position: position?.position ?? 'fixed',
              top: position?.top ?? 0,
              left: position?.left ?? 0,
              width: position?.width,
              visibility: position ? 'visible' : 'hidden',
            }}
            onKeyDown={(event) => {
              if (event.key === 'Escape') {
                event.preventDefault()
                event.stopPropagation()
                closeMenu(true)
              }
            }}
          >
            <fieldset className="space-y-1">
              <legend className="text-caption text-text-secondary px-2 py-1">
                Select one or more audiences
              </legend>
              {eventAudienceOptions.map(({ key, label }) => (
                <label
                  key={key}
                  className="text-body-sm hover:bg-surface-muted rounded-control flex min-h-10 cursor-pointer items-center gap-3 px-2"
                >
                  <input
                    type="checkbox"
                    checked={value.includes(key)}
                    onChange={(event) =>
                      onChange(
                        event.target.checked
                          ? [...value, key]
                          : value.filter((selected) => selected !== key),
                      )
                    }
                  />
                  {label}
                </label>
              ))}
            </fieldset>
          </div>,
          portalContainer,
        )
      : null

  return (
    <div>
      <button
        ref={triggerRef}
        id={controlId}
        type="button"
        aria-haspopup="dialog"
        aria-expanded={open}
        aria-controls={open ? menuId : undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid}
        aria-required={required}
        aria-label={`Notify audience${selectedLabels.length ? `: ${selectedLabels.join(', ')}` : ''}`}
        onClick={toggleMenu}
        className="text-body-sm border-border-subtle bg-surface text-text-primary focus-visible:shadow-focus-ring hover:border-border-strong aria-[invalid=true]:border-danger rounded-control flex min-h-11 w-full items-center justify-between gap-3 border px-3 text-left focus-visible:outline-none"
      >
        <span className="flex min-w-0 items-center gap-2">
          <span className={selectedLabels.length ? 'truncate' : 'text-text-muted truncate'}>
            {selectedLabels.length
              ? `${selectedLabels.length} ${selectedLabels.length === 1 ? 'group' : 'groups'} selected`
              : 'Select audiences'}
          </span>
          {selectedLabels.length ? (
            <span className="bg-primary-subtle text-primary rounded-pill text-overline flex size-5 shrink-0 items-center justify-center font-semibold">
              {selectedLabels.length}
            </span>
          ) : null}
        </span>
        <ChevronDown className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
      </button>
      <div className="mt-2 flex flex-wrap gap-1.5" aria-live="polite">
        {selectedLabels.length ? (
          selectedLabels.map((label) => (
            <span
              key={label}
              className="bg-primary-subtle text-primary rounded-pill text-overline max-w-full truncate px-2 py-0.5 font-medium"
              title={label}
            >
              {label}
            </span>
          ))
        ) : (
          <span className="text-caption text-text-secondary">No audiences selected</span>
        )}
      </div>
      {menu}
    </div>
  )
}

function AnnouncementForm({
  formId,
  value,
  choices,
  branches,
  departments,
  branchOptionsState,
  departmentOptionsState,
  onRetryBranches,
  onRetryDepartments,
  onSubmit,
}: {
  formId: string
  value?: AnnouncementDto
  choices?: {
    announcement_types: { value: string; label: string }[]
    priorities: { value: string; label: string }[]
  }
  branches: { id: number; label: string }[]
  departments: { id: number; label: string }[]
  branchOptionsState: 'ready' | 'loading' | 'error' | 'unavailable'
  departmentOptionsState: 'ready' | 'loading' | 'error' | 'unavailable'
  onRetryBranches?: () => void
  onRetryDepartments?: () => void
  onSubmit: (input: AnnouncementInput) => void
}) {
  const [title, setTitle] = useState(value?.title ?? '')
  const [content, setContent] = useState(value?.content ?? '')
  const [type, setType] = useState(
    value?.announcement_type ?? choices?.announcement_types[0]?.value ?? 'general',
  )
  const [priority, setPriority] = useState(
    value?.priority ??
      choices?.priorities.find((choice) => choice.value === 'normal')?.value ??
      choices?.priorities[0]?.value ??
      'normal',
  )
  const initialPublish = localDateParts(value?.publish_at ?? null)
  const initialExpiry = localDateParts(value?.expires_at ?? null)
  const [publishDate, setPublishDate] = useState(initialPublish.date)
  const [publishTime, setPublishTime] = useState(initialPublish.time)
  const [publishImmediately, setPublishImmediately] = useState(!value?.publish_at)
  const [expiresDate, setExpiresDate] = useState(initialExpiry.date)
  const [expiresTime, setExpiresTime] = useState(initialExpiry.time)
  const [allBranches, setAllBranches] = useState(value?.targets_all_branches ?? true)
  const [branchIds, setBranchIds] = useState(value?.branches.map(({ id }) => id) ?? [])
  const [allDepartments, setAllDepartments] = useState(value?.targets_all_departments ?? true)
  const [departmentIds, setDepartmentIds] = useState(value?.departments.map(({ id }) => id) ?? [])
  const [fieldError, setFieldError] = useState<string | null>(null)

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const publishAt = publishImmediately
      ? null
      : localDateTimeToIso(publishDate, publishTime || '00:00')
    const expiresAt = localDateTimeToIso(expiresDate, expiresTime || '00:00')
    if (!title.trim() || !content.trim()) {
      setFieldError('Enter an announcement title and message before publishing.')
      document
        .getElementById(!title.trim() ? 'announcement-title' : 'announcement-content')
        ?.focus()
      return
    }
    if (!publishImmediately && !publishDate) {
      setFieldError('Choose a publish date or switch on Publish immediately.')
      document.getElementById('announcement-publish-date')?.focus()
      return
    }
    if (expiresAt && publishAt && new Date(expiresAt) <= new Date(publishAt)) {
      setFieldError('The expiry date and time must be later than the publication date and time.')
      document.getElementById('announcement-expires-date')?.focus()
      return
    }
    if (
      (!allBranches && branches.length > 0 && branchIds.length === 0) ||
      (!allDepartments && departments.length > 0 && departmentIds.length === 0)
    ) {
      const missingBranches = !allBranches && branches.length > 0 && branchIds.length === 0
      setFieldError(
        missingBranches
          ? 'Select at least one branch or choose All branches.'
          : 'Select at least one department or choose All departments.',
      )
      document
        .querySelector<HTMLInputElement>(
          `fieldset[data-audience="${missingBranches ? 'branches' : 'departments'}"] input[data-audience-option]:not(:checked)`,
        )
        ?.focus()
      return
    }
    setFieldError(null)
    onSubmit({
      title: title.trim(),
      content: content.trim(),
      announcement_type: type,
      priority,
      branch_ids: allBranches ? [] : branchIds,
      department_ids: allDepartments ? [] : departmentIds,
      is_active: value?.is_active ?? true,
      publish_at: publishAt,
      expires_at: expiresAt,
    })
  }

  return (
    <form id={formId} onSubmit={submit} className="space-y-4">
      {fieldError ? (
        <Alert role="alert" tone="danger" title="Review the announcement">
          {fieldError}
        </Alert>
      ) : null}
      <FormSection aria-labelledby="announcement-content-heading" className="space-y-4">
        <div>
          <h3
            id="announcement-content-heading"
            className="text-label text-text-primary font-semibold"
          >
            Announcement details
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Give the update a clear title and message.
          </p>
        </div>
        <FormControl id="announcement-title" label="Announcement title" required>
          <TextInput
            id="announcement-title"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            required
            maxLength={200}
          />
        </FormControl>
        <FormControl
          id="announcement-content"
          label="Message"
          required
          description="Use clear, concise language for the intended audience."
        >
          <TextArea
            id="announcement-content"
            value={content}
            onChange={(event) => setContent(event.target.value)}
            required
            rows={5}
          />
        </FormControl>
      </FormSection>
      <FormSection aria-labelledby="announcement-classification-heading" className="space-y-4">
        <div>
          <h3
            id="announcement-classification-heading"
            className="text-label text-text-primary font-semibold"
          >
            Classification
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Choose how this announcement is categorized.
          </p>
        </div>
        <div className="phone:grid-cols-2 grid gap-4">
          <FormControl id="announcement-type" label="Announcement type" required>
            <DropdownSelect
              id="announcement-type"
              value={type}
              options={(choices?.announcement_types ?? []).map((item) => ({ ...item }))}
              onChange={setType}
            />
          </FormControl>
          <FormControl id="announcement-priority" label="Priority" required>
            <DropdownSelect
              id="announcement-priority"
              value={priority}
              options={(choices?.priorities ?? []).map((item) => ({ ...item }))}
              onChange={setPriority}
            />
          </FormControl>
        </div>
      </FormSection>
      <FormSection aria-labelledby="announcement-schedule-heading" className="space-y-4">
        <div>
          <h3
            id="announcement-schedule-heading"
            className="text-label text-text-primary font-semibold"
          >
            Schedule
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Choose when the message becomes visible and, optionally, when it expires.
          </p>
        </div>
        <div className="space-y-4">
          <label className="text-body-sm text-text-primary flex w-fit cursor-pointer items-center gap-2.5">
            <input
              type="checkbox"
              role="switch"
              checked={publishImmediately}
              onChange={(event) => setPublishImmediately(event.currentTarget.checked)}
              className="accent-primary size-4"
            />
            <span className="font-medium">Publish immediately</span>
          </label>
          <div className="phone:grid-cols-2 grid gap-4">
            <div className="space-y-3">
              <FormControl id="announcement-publish-date" label="Publish date">
                <DatePickerField
                  id="announcement-publish-date"
                  value={publishDate}
                  disabled={publishImmediately}
                  clearable
                  placeholder="Choose a date"
                  onValueChange={(next) => {
                    setPublishDate(next)
                    if (!next) setPublishTime('')
                    else if (!publishTime) setPublishTime('09:00')
                  }}
                />
              </FormControl>
              <FormControl id="announcement-publish-time" label="Publish time">
                <TimePickerField
                  id="announcement-publish-time"
                  value={publishTime}
                  disabled={!publishDate || publishImmediately}
                  clearable
                  onValueChange={setPublishTime}
                />
              </FormControl>
            </div>
            <div className="space-y-3">
              <FormControl id="announcement-expires-date" label="Expiry date">
                <DatePickerField
                  id="announcement-expires-date"
                  value={expiresDate}
                  min={publishDate || undefined}
                  clearable
                  placeholder="Choose a date"
                  onValueChange={(next) => {
                    setExpiresDate(next)
                    if (!next) setExpiresTime('')
                    else if (!expiresTime) setExpiresTime('09:00')
                  }}
                />
              </FormControl>
              <FormControl id="announcement-expires-time" label="Expiry time">
                <TimePickerField
                  id="announcement-expires-time"
                  value={expiresTime}
                  disabled={!expiresDate}
                  clearable
                  onValueChange={setExpiresTime}
                />
              </FormControl>
            </div>
          </div>
        </div>
      </FormSection>
      <FormSection aria-labelledby="announcement-audience-heading" className="space-y-3">
        <div>
          <h3
            id="announcement-audience-heading"
            className="text-label text-text-primary font-semibold"
          >
            Audience
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Limit the announcement to selected branches or departments, or include everyone.
          </p>
        </div>
        <div className="phone:grid-cols-2 grid gap-3">
          <TargetPicker
            title="Branches"
            options={branches}
            selected={branchIds}
            onChange={setBranchIds}
            all={allBranches}
            onAllChange={setAllBranches}
            optionsState={branchOptionsState}
            onRetry={onRetryBranches}
            savedSelection={value?.branches.map(({ branch_name }) => branch_name) ?? []}
          />
          <TargetPicker
            title="Departments"
            options={departments}
            selected={departmentIds}
            onChange={setDepartmentIds}
            all={allDepartments}
            onAllChange={setAllDepartments}
            optionsState={departmentOptionsState}
            onRetry={onRetryDepartments}
            savedSelection={value?.departments.map(({ name }) => name) ?? []}
          />
        </div>
      </FormSection>
    </form>
  )
}

function EventForm({
  formId,
  value,
  choices,
  saveError,
  onSubmit,
}: {
  formId: string
  value?: EventDto
  choices?: { event_types: { value: string; label: string }[] }
  saveError?: string | null
  onSubmit: (input: EventInput) => void
}) {
  const initialStart = localDateParts(value ? eventStart(value) : null)
  const initialEnd = localDateParts(value ? value.event_time_to_iso || value.event_time_to : null)
  const [title, setTitle] = useState(value?.title ?? '')
  const [eventType, setEventType] = useState(
    value?.event_type ?? choices?.event_types[0]?.value ?? '',
  )
  const [startDate, setStartDate] = useState(initialStart.date)
  const [startTime, setStartTime] = useState(initialStart.time)
  const [endDate, setEndDate] = useState(initialEnd.date)
  const [endTime, setEndTime] = useState(initialEnd.time)
  const [location, setLocation] = useState(value?.meeting_location ?? '')
  const [reminder, setReminder] = useState(() => {
    const match = value?.reminder_offset.match(/^(\d+)\s+minutes?/i)
    return match?.[1] ?? ''
  })
  const [recurrence, setRecurrence] = useState(() => {
    const raw = value?.recurrence ?? ''
    if (/FREQ=DAILY/i.test(raw)) return 'daily'
    if (/FREQ=WEEKLY/i.test(raw)) return 'weekly'
    return 'none'
  })
  const [audience, setAudience] = useState({
    branches: value?.target_all_branches ?? true,
    departments: value?.target_all_departments ?? true,
    associates: value?.target_associates ?? false,
    investors: value?.target_investors ?? false,
    partners: value?.target_partners ?? false,
  })
  const [error, setError] = useState<{ section: 'details' | 'schedule'; message: string } | null>(
    null,
  )
  const saveErrorRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!saveError || !saveErrorRef.current) return
    saveErrorRef.current.scrollIntoView?.({ block: 'nearest' })
    saveErrorRef.current.focus()
  }, [saveError])

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const start = localDateTimeToIso(startDate, startTime)
    const end = localDateTimeToIso(endDate, endTime)
    if (!title.trim()) {
      setError({ section: 'details', message: 'Enter an event title before saving.' })
      document.getElementById('event-title')?.focus()
      return
    }
    if (!start || !end) {
      setError({
        section: 'schedule',
        message: 'Choose a valid start and end time. The end must be later than the start.',
      })
      document.getElementById(!start ? 'event-start-date' : 'event-end-date')?.focus()
      return
    }
    if (new Date(start) < new Date()) {
      setError({
        section: 'schedule',
        message: 'The event start must be in the future. Choose a later local date and time.',
      })
      document.getElementById('event-start-date')?.focus()
      return
    }
    if (new Date(end) <= new Date(start)) {
      setError({
        section: 'schedule',
        message: 'The event end date and time must be later than its start.',
      })
      document.getElementById('event-end-date')?.focus()
      return
    }
    setError(null)
    onSubmit({
      title: title.trim(),
      event_type: eventType,
      event_time_from: start,
      event_time_to: end,
      meeting_location: location.trim() || null,
      target_all_branches: audience.branches,
      target_all_departments: audience.departments,
      target_associates: audience.associates,
      target_investors: audience.investors,
      target_partners: audience.partners,
      reminder_offset: reminder ? Number(reminder) : null,
      recurrence:
        recurrence === 'none' ? null : `RRULE:FREQ=${recurrence.toUpperCase()};INTERVAL=1`,
    })
  }

  return (
    <form id={formId} noValidate onSubmit={submit} className="space-y-4">
      <FormSection aria-labelledby="event-information-heading" className="space-y-4">
        <div>
          <h3 id="event-information-heading" className="text-label text-text-primary font-semibold">
            Event details
          </h3>
          <p className="text-caption text-text-secondary mt-1">Set the event name and category.</p>
        </div>
        {error?.section === 'details' ? (
          <Alert role="alert" tone="danger" title="Review event details">
            {error.message}
          </Alert>
        ) : null}
        <FormControl id="event-title" label="Event title" required>
          <TextInput
            id="event-title"
            value={title}
            onChange={(event) => {
              setTitle(event.target.value)
              if (error?.section === 'details') setError(null)
            }}
            required
            maxLength={200}
          />
        </FormControl>
        <FormControl id="event-type" label="Event type" required>
          <DropdownSelect
            id="event-type"
            value={eventType}
            options={(choices?.event_types ?? []).map((item) => ({ ...item }))}
            onChange={setEventType}
          />
        </FormControl>
      </FormSection>
      <FormSection aria-labelledby="event-schedule-heading" className="space-y-4">
        <div>
          <h3 id="event-schedule-heading" className="text-label text-text-primary font-semibold">
            Schedule and location
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Dates use the global calendar; times are entered in your local timezone.
          </p>
        </div>
        {error?.section === 'schedule' ? (
          <Alert role="alert" tone="danger" title="Review the event schedule">
            {error.message}
          </Alert>
        ) : null}
        <div className="phone:grid-cols-2 grid gap-4">
          <div className="space-y-3">
            <FormControl id="event-start-date" label="Start date" required>
              <DatePickerField
                id="event-start-date"
                value={startDate}
                min={localDateValue(new Date())}
                required
                placeholder="Choose a date"
                onValueChange={(next) => {
                  setStartDate(next)
                  if (!next) setStartTime('')
                  else if (!startTime) setStartTime('09:00')
                  if (error?.section === 'schedule') setError(null)
                }}
              />
            </FormControl>
            <RequiredTimeField
              id="event-start-time"
              label="Start time"
              value={startTime}
              disabled={!startDate}
              onChange={(next) => {
                setStartTime(next)
                if (error?.section === 'schedule') setError(null)
              }}
            />
          </div>
          <div className="space-y-3">
            <FormControl id="event-end-date" label="End date" required>
              <DatePickerField
                id="event-end-date"
                value={endDate}
                min={startDate || localDateValue(new Date())}
                required
                placeholder="Choose a date"
                onValueChange={(next) => {
                  setEndDate(next)
                  if (!next) setEndTime('')
                  else if (!endTime) setEndTime('10:00')
                  if (error?.section === 'schedule') setError(null)
                }}
              />
            </FormControl>
            <RequiredTimeField
              id="event-end-time"
              label="End time"
              value={endTime}
              disabled={!endDate}
              onChange={(next) => {
                setEndTime(next)
                if (error?.section === 'schedule') setError(null)
              }}
            />
          </div>
        </div>
        <FormControl id="event-location" label="Location">
          <TextInput
            id="event-location"
            value={location}
            onChange={(event) => setLocation(event.target.value)}
            maxLength={500}
            placeholder="Office, venue or meeting link"
          />
        </FormControl>
      </FormSection>
      <FormSection aria-labelledby="event-settings-heading" className="space-y-4">
        <div>
          <h3 id="event-settings-heading" className="text-label text-text-primary font-semibold">
            Event settings
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Choose a reminder and optional repeat schedule.
          </p>
        </div>
        <div className="phone:grid-cols-2 grid gap-4">
          <FormControl id="event-reminder" label="Reminder">
            <DropdownSelect
              id="event-reminder"
              value={reminder}
              options={[
                { value: '', label: 'No reminder' },
                { value: '15', label: '15 minutes before' },
                { value: '60', label: '1 hour before' },
                { value: '1440', label: '1 day before' },
              ]}
              onChange={setReminder}
            />
          </FormControl>
          <FormControl id="event-recurrence" label="Repeats">
            <DropdownSelect
              id="event-recurrence"
              value={recurrence}
              options={[
                { value: 'none', label: 'Does not repeat' },
                { value: 'daily', label: 'Daily' },
                { value: 'weekly', label: 'Weekly' },
              ]}
              onChange={setRecurrence}
            />
          </FormControl>
        </div>
      </FormSection>
      <FormSection aria-labelledby="event-audience-heading" className="space-y-3">
        <div>
          <h3 id="event-audience-heading" className="text-label text-text-primary font-semibold">
            Audience
          </h3>
          <p className="text-caption text-text-secondary mt-1">
            Choose one or more groups to notify about this event.
          </p>
        </div>
        <FormControl id="event-audience" label="Notify audience">
          <EventAudiencePicker
            value={eventAudienceOptions.filter(({ key }) => audience[key]).map(({ key }) => key)}
            onChange={(selected) =>
              setAudience({
                branches: selected.includes('branches'),
                departments: selected.includes('departments'),
                associates: selected.includes('associates'),
                investors: selected.includes('investors'),
                partners: selected.includes('partners'),
              })
            }
          />
        </FormControl>
      </FormSection>
      {saveError ? (
        <div ref={saveErrorRef} tabIndex={-1}>
          <Alert role="alert" tone="danger" title="Event could not be saved">
            {saveError}
          </Alert>
        </div>
      ) : null}
    </form>
  )
}

function Pagination({
  page,
  count,
  onPage,
}: {
  page: number
  count: number
  onPage: (page: number) => void
}) {
  const pages = Math.max(1, Math.ceil(count / PAGE_SIZE))
  return (
    <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary">
        {count
          ? `${(page - 1) * PAGE_SIZE + 1}–${Math.min(page * PAGE_SIZE, count)} of ${count}`
          : '0 records'}
      </p>
      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          aria-label="Previous page"
          disabled={page <= 1}
          onClick={() => onPage(page - 1)}
          leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
        >
          Previous
        </Button>
        <span className="text-caption text-text-secondary min-w-16 text-center">
          {page} / {pages}
        </span>
        <Button
          variant="outline"
          size="sm"
          aria-label="Next page"
          disabled={page >= pages}
          onClick={() => onPage(page + 1)}
        >
          Next <ChevronRight className="size-4" aria-hidden="true" />
        </Button>
      </div>
    </div>
  )
}

export function BroadcastPage() {
  const search = useSearch({ from: '/_protected/company/broadcast' }) as BroadcastSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const allowedTabs = tabs.filter(({ resource }) => hasPermission(permissions, resource, 'list'))
  const canListBranches = hasPermission(permissions, 'branches', 'list')
  const canListDepartments = hasPermission(permissions, 'departments', 'list')
  const currentTab: BroadcastTab =
    allowedTabs.find(({ value }) => value === search.tab)?.value ??
    allowedTabs[0]?.value ??
    'announcements'
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search
  const [announcementForm, setAnnouncementForm] = useState<AnnouncementDto | 'new' | null>(null)
  const [eventForm, setEventForm] = useState<EventDto | 'new' | null>(null)
  const [detailAnnouncement, setDetailAnnouncement] = useState<AnnouncementDto | null>(null)
  const [detailEvent, setDetailEvent] = useState<EventDto | null>(null)
  const [confirmDeactivate, setConfirmDeactivate] = useState<AnnouncementDto | null>(null)
  const [confirmDeleteEvent, setConfirmDeleteEvent] = useState<EventDto | null>(null)

  const listParams = useMemo(
    () => ({ limit: PAGE_SIZE, offset: (search.page - 1) * PAGE_SIZE, search: search.search }),
    [search.page, search.search],
  )
  const announcementsQuery = useQuery({
    queryKey: broadcastQueryKeys.announcementList(userId, employeeId, listParams),
    queryFn: ({ signal }) => broadcastApi.announcements(listParams, signal),
    enabled: Boolean(
      session &&
      currentTab === 'announcements' &&
      hasPermission(permissions, 'announcements', 'list'),
    ),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const eventsQuery = useQuery({
    queryKey: broadcastQueryKeys.eventList(userId, employeeId, listParams),
    queryFn: ({ signal }) => broadcastApi.events(listParams, signal),
    enabled: Boolean(
      session && currentTab === 'events' && hasPermission(permissions, 'events', 'list'),
    ),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const announcementChoices = useQuery({
    queryKey: broadcastQueryKeys.announcementChoices(userId, employeeId),
    queryFn: ({ signal }) => broadcastApi.announcementChoices(signal),
    enabled: Boolean(
      session &&
      announcementForm &&
      (hasPermission(permissions, 'announcements', 'create') ||
        hasPermission(permissions, 'announcements', 'update')),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const eventChoices = useQuery({
    queryKey: broadcastQueryKeys.eventChoices(userId, employeeId),
    queryFn: ({ signal }) => broadcastApi.eventChoices(signal),
    enabled: Boolean(
      session &&
      eventForm &&
      (hasPermission(permissions, 'events', 'create') ||
        hasPermission(permissions, 'events', 'update')),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const branchChoices = useQuery({
    queryKey: ['company', 'broadcast', userId, employeeId, 'branch-options'],
    queryFn: ({ signal }) =>
      branchesApi.list(
        {
          limit: 100,
          offset: 0,
          search: '',
          operationalStatus: 'all',
          branchRole: 'all',
          recordState: 'all',
        },
        signal,
      ),
    enabled: Boolean(session && announcementForm && canListBranches),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const departmentOptions = useQuery({
    queryKey: ['company', 'broadcast', userId, employeeId, 'department-options'],
    queryFn: ({ signal }) =>
      companyOrganizationApi.departments({ limit: 100, offset: 0, search: '' }, signal),
    enabled: Boolean(session && announcementForm && canListDepartments),
    staleTime: DATA_FRESHNESS_MS.reference,
  })

  useEffect(() => {
    if (allowedTabs.length && !allowedTabs.some(({ value }) => value === search.tab)) {
      void navigate({
        to: '/company/broadcast',
        search: { ...search, tab: allowedTabs[0].value, page: 1 },
        replace: true,
        resetScroll: false,
      })
    }
  }, [allowedTabs, navigate, search])

  const updateSearch = useCallback(
    (updates: Partial<BroadcastSearch>, replace = false) => {
      void navigate({
        to: '/company/broadcast',
        search: (previous: BroadcastSearch) => ({ ...previous, ...updates }),
        replace,
        resetScroll: false,
      })
    },
    [navigate],
  )
  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  const invalidateAnnouncements = async () =>
    queryClient.invalidateQueries({
      queryKey: broadcastQueryKeys.announcements(userId, employeeId),
    })
  const invalidateEvents = async () =>
    queryClient.invalidateQueries({ queryKey: broadcastQueryKeys.events(userId, employeeId) })
  const saveAnnouncement = useMutation({
    mutationFn: (input: AnnouncementInput) =>
      announcementForm && announcementForm !== 'new'
        ? broadcastApi.updateAnnouncement(announcementForm.id, input)
        : broadcastApi.createAnnouncement(input),
    onSuccess: async () => {
      await invalidateAnnouncements()
      setAnnouncementForm(null)
      showToast({
        title:
          announcementForm && announcementForm !== 'new'
            ? 'Announcement updated'
            : 'Announcement published',
        description: 'The broadcast register has been refreshed.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Announcement could not be saved',
        description: presentError(error, 'form-submit').message,
        tone: 'danger',
      }),
  })
  const deactivateAnnouncement = useMutation({
    mutationFn: (id: number) => broadcastApi.deactivateAnnouncement(id),
    onSuccess: async () => {
      await invalidateAnnouncements()
      setConfirmDeactivate(null)
      showToast({
        title: 'Announcement deactivated',
        description: 'It is no longer active.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Announcement could not be deactivated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const saveEvent = useMutation({
    mutationFn: (input: EventInput) =>
      eventForm && eventForm !== 'new'
        ? broadcastApi.updateEvent(eventForm.id, input)
        : broadcastApi.createEvent(input),
    onSuccess: async () => {
      await invalidateEvents()
      setEventForm(null)
      showToast({
        title: eventForm && eventForm !== 'new' ? 'Event updated' : 'Event created',
        description: 'The event register has been refreshed.',
        tone: 'success',
      })
    },
  })
  function openEventForm(value: EventDto | 'new') {
    saveEvent.reset()
    setEventForm(value)
  }
  function closeEventForm() {
    saveEvent.reset()
    setEventForm(null)
  }
  const deleteEvent = useMutation({
    mutationFn: (id: number) => broadcastApi.deleteEvent(id),
    onSuccess: async () => {
      await invalidateEvents()
      setConfirmDeleteEvent(null)
      showToast({
        title: 'Event deleted',
        description: 'The event is no longer in the register.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Event could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const announcements = announcementsQuery.data?.items ?? []
  const events = eventsQuery.data?.items ?? []
  const canCreateAnnouncement = hasPermission(permissions, 'announcements', 'create')
  const canUpdateAnnouncement = hasPermission(permissions, 'announcements', 'update')
  const canDeactivateAnnouncement = hasPermission(permissions, 'announcements', 'delete')
  const canCreateEvent = hasPermission(permissions, 'events', 'create')
  const canUpdateEvent = hasPermission(permissions, 'events', 'update')
  const canDeleteEvent = hasPermission(permissions, 'events', 'delete')
  const canOpenNotifications = hasPermission(permissions, 'notifications', 'list')

  const activeListCount =
    currentTab === 'announcements' ? announcementsQuery.data?.count : eventsQuery.data?.count
  useEffect(() => {
    if (activeListCount === undefined) return
    const lastPage = Math.max(1, Math.ceil(activeListCount / PAGE_SIZE))
    if (search.page > lastPage) updateSearch({ page: lastPage }, true)
  }, [activeListCount, currentTab, search.page, updateSearch])

  const headerAction =
    currentTab === 'announcements' && canCreateAnnouncement ? (
      <Button
        onClick={() => setAnnouncementForm('new')}
        aria-label="New announcement"
        leadingIcon={<Plus className="size-4" aria-hidden="true" />}
      >
        <span className="phone:hidden max-[361px]:hidden">New</span>
        <span className="phone:inline hidden">New announcement</span>
      </Button>
    ) : currentTab === 'events' && canCreateEvent ? (
      <Button
        onClick={() => openEventForm('new')}
        aria-label="New event"
        leadingIcon={<Plus className="size-4" aria-hidden="true" />}
      >
        <span className="phone:hidden max-[361px]:hidden">New</span>
        <span className="phone:inline hidden">New event</span>
      </Button>
    ) : null

  if (!allowedTabs.length) {
    return (
      <PageLayout title="Broadcast" subtitle="Company announcements and events.">
        <EmptyState
          title="Broadcast access is not available"
          description="Your account does not have permission to view announcements or events."
          icon={<Megaphone className="size-6" aria-hidden="true" />}
          action={
            canOpenNotifications ? (
              <Button onClick={() => void navigate({ to: '/notifications' })}>
                Open notification center
              </Button>
            ) : undefined
          }
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Broadcast"
      subtitle="Coordinate company announcements and events."
      actions={headerAction}
      actionsInline
    >
      <div className="space-y-5">
        <Card className="tablet:p-3 p-2">
          <div className="tablet:flex-row tablet:items-center flex flex-col gap-2">
            <div
              className="phone:grid-cols-2 tablet:max-w-xl grid flex-1 gap-1"
              role="tablist"
              aria-label="Broadcast sections"
            >
              {allowedTabs.map(({ value, label, icon: Icon }) => (
                <button
                  key={value}
                  type="button"
                  role="tab"
                  aria-selected={currentTab === value}
                  onClick={() => updateSearch({ tab: value, page: 1 })}
                  className={`rounded-control focus-visible:shadow-focus-ring text-label flex min-h-11 items-center justify-center gap-2 px-3 font-semibold transition-colors focus-visible:outline-none ${currentTab === value ? 'bg-primary text-text-on-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface-muted hover:text-text-primary'}`}
                >
                  <Icon className="size-4" aria-hidden="true" />
                  {label}
                </button>
              ))}
            </div>
            {canOpenNotifications ? (
              <Button
                variant="ghost"
                size="sm"
                className="tablet:self-auto self-end"
                onClick={() => void navigate({ to: '/notifications' })}
                leadingIcon={<Bell className="size-4" aria-hidden="true" />}
              >
                Open notification center
              </Button>
            ) : null}
          </div>
          <form
            onSubmit={submitSearch}
            className="border-border-subtle phone:grid-cols-[minmax(0,1fr)_auto] phone:items-end mt-3 grid gap-3 border-t pt-3"
          >
            <FormControl
              id="broadcast-search"
              className="min-w-0"
              label={currentTab === 'announcements' ? 'Search announcements' : 'Search events'}
            >
              <TextInput
                id="broadcast-search"
                value={searchDraft}
                onChange={(event) =>
                  setSearchDraftState({ routeValue: search.search, value: event.target.value })
                }
                placeholder={
                  currentTab === 'announcements' ? 'Title, content or reference' : 'Event title'
                }
              />
            </FormControl>
            <Button
              type="submit"
              className="phone:w-auto w-full"
              leadingIcon={<Search className="size-4" aria-hidden="true" />}
            >
              Search
            </Button>
          </form>
        </Card>

        {currentTab === 'announcements' ? (
          <Card className="overflow-hidden p-0">
            <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-b px-4 py-4">
              <div>
                <p className="text-overline text-primary">Company communication</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Announcements</h2>
                <p className="text-caption text-text-secondary mt-1">
                  Scheduled and active broadcasts
                </p>
              </div>
              <span className="bg-primary-subtle text-primary rounded-pill text-caption px-3 py-1.5 font-semibold">
                {announcementsQuery.data?.count ?? 0} records
              </span>
            </div>
            {announcementsQuery.isPending ? (
              <div className="space-y-3 p-4">
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
              </div>
            ) : announcementsQuery.isError && !announcementsQuery.data ? (
              <ErrorState
                title="Announcements could not be loaded"
                error={announcementsQuery.error}
                action={
                  <Button variant="outline" onClick={() => void announcementsQuery.refetch()}>
                    Try again
                  </Button>
                }
              />
            ) : announcements.length === 0 ? (
              <EmptyState
                title="No announcements found"
                description={
                  search.search
                    ? 'Try another search or clear the current query.'
                    : 'Published and scheduled announcements will appear here.'
                }
                icon={<Megaphone className="size-6" aria-hidden="true" />}
                action={
                  canCreateAnnouncement ? (
                    <Button
                      onClick={() => setAnnouncementForm('new')}
                      leadingIcon={<Plus className="size-4" aria-hidden="true" />}
                    >
                      Create announcement
                    </Button>
                  ) : undefined
                }
              />
            ) : (
              <div className="tablet:p-4 space-y-3 p-3">
                {announcements.map((item) => (
                  <article
                    key={item.id}
                    className="group border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-md rounded-surface shadow-elevation-sm tablet:p-5 flex min-w-0 flex-col gap-4 border p-4 transition-[border-color,box-shadow] duration-150"
                  >
                    <div className="flex min-w-0 flex-1 gap-3">
                      <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                        <Megaphone className="size-[18px]" aria-hidden="true" />
                      </span>
                      <div className="min-w-0 flex-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <h3 className="text-body-md text-text-primary leading-snug font-semibold break-words">
                            {item.title}
                          </h3>
                          <StatusChip
                            label={item.is_active ? 'Active' : 'Inactive'}
                            tone={actionTone(item.is_active)}
                            dense
                          />
                          <StatusChip
                            label={item.priority_display}
                            tone={item.priority === 'high' ? 'warning' : 'neutral'}
                            dense
                          />
                        </div>
                        <p className="text-caption text-text-secondary mt-1">
                          {item.announcement_type_display}
                          <span aria-hidden="true"> · </span>
                          <span className="font-mono">{item.announcement_id}</span>
                        </p>
                        <p className="border-border-subtle text-body-sm text-text-secondary mt-3 line-clamp-2 border-l-2 pl-3">
                          {item.content}
                        </p>
                        <div className="text-caption text-text-secondary phone:grid-cols-2 mt-3 grid min-w-0 gap-x-4 gap-y-2">
                          <time
                            dateTime={item.publish_at ?? item.created_at}
                            className="inline-flex min-w-0 items-center gap-1.5"
                          >
                            <Clock3 className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="break-words">
                              {item.publish_at
                                ? `Publishes ${formatDate(item.publish_at, true)}`
                                : `Published ${formatDate(item.created_at, true)}`}
                            </span>
                          </time>
                          <span
                            className="inline-flex min-w-0 items-center gap-1.5"
                            title={announcementAudienceDetails(item)}
                            aria-label={`Audience: ${announcementAudience(item)}. ${announcementAudienceDetails(item)}`}
                          >
                            <UsersRound className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="line-clamp-2 min-w-0 break-words">
                              {announcementAudience(item)}
                            </span>
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="border-border-subtle flex shrink-0 flex-wrap justify-end gap-2 border-t pt-3">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setDetailAnnouncement(item)}
                      >
                        View
                      </Button>
                      {canUpdateAnnouncement ? (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setAnnouncementForm(item)}
                        >
                          Edit
                        </Button>
                      ) : null}
                      {item.is_active && canDeactivateAnnouncement ? (
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-danger hover:text-danger"
                          onClick={() => setConfirmDeactivate(item)}
                          leadingIcon={<Trash2 className="size-4" aria-hidden="true" />}
                        >
                          Deactivate
                        </Button>
                      ) : null}
                    </div>
                  </article>
                ))}
              </div>
            )}
            {announcementsQuery.isError && announcementsQuery.data ? (
              <div className="p-4 pt-0">
                <SectionErrorState
                  error={announcementsQuery.error}
                  description="Showing the last loaded announcements."
                  onRetry={() => void announcementsQuery.refetch()}
                />
              </div>
            ) : null}
            {!announcementsQuery.isPending && announcementsQuery.data ? (
              <Pagination
                page={search.page}
                count={announcementsQuery.data?.count ?? 0}
                onPage={(page) => updateSearch({ page })}
              />
            ) : null}
          </Card>
        ) : null}

        {currentTab === 'events' ? (
          <Card className="overflow-hidden p-0">
            <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-b px-4 py-4">
              <div>
                <p className="text-overline text-primary">Company calendar</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Events</h2>
                <p className="text-caption text-text-secondary mt-1">Scheduled company events</p>
              </div>
              <span className="bg-primary-subtle text-primary rounded-pill text-caption px-3 py-1.5 font-semibold">
                {eventsQuery.data?.count ?? 0} events
              </span>
            </div>
            {eventsQuery.isPending ? (
              <div className="space-y-3 p-4">
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
                <Skeleton className="h-24" />
              </div>
            ) : eventsQuery.isError && !eventsQuery.data ? (
              <ErrorState
                title="Events could not be loaded"
                error={eventsQuery.error}
                action={
                  <Button variant="outline" onClick={() => void eventsQuery.refetch()}>
                    Try again
                  </Button>
                }
              />
            ) : events.length === 0 ? (
              <EmptyState
                title="No events found"
                description={
                  search.search
                    ? 'Try another search or clear the current query.'
                    : 'Company events will appear here when they are scheduled.'
                }
                icon={<CalendarDays className="size-6" aria-hidden="true" />}
                action={
                  canCreateEvent ? (
                    <Button
                      onClick={() => openEventForm('new')}
                      leadingIcon={<Plus className="size-4" aria-hidden="true" />}
                    >
                      Create event
                    </Button>
                  ) : undefined
                }
              />
            ) : (
              <div className="tablet:p-4 space-y-3 p-3">
                {events.map((item) => (
                  <article
                    key={item.id}
                    className="group border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-md rounded-surface shadow-elevation-sm tablet:p-5 flex min-w-0 flex-col gap-4 border p-4 motion-safe:transition-[border-color,box-shadow] motion-safe:duration-150"
                  >
                    <div className="flex min-w-0 flex-1 gap-3">
                      <time
                        dateTime={eventStart(item)}
                        aria-label={formatDate(eventStart(item))}
                        className="bg-primary-subtle text-primary rounded-control flex size-14 shrink-0 flex-col items-center justify-center self-start"
                      >
                        <span className="text-overline">
                          {new Intl.DateTimeFormat(undefined, { month: 'short' }).format(
                            new Date(eventStart(item)),
                          )}
                        </span>
                        <span className="text-h3 font-semibold">
                          {new Intl.DateTimeFormat(undefined, { day: '2-digit' }).format(
                            new Date(eventStart(item)),
                          )}
                        </span>
                      </time>
                      <div className="min-w-0 flex-1">
                        <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
                          <h3 className="text-body-md text-text-primary leading-snug font-semibold break-words">
                            {item.title}
                          </h3>
                          <StatusChip
                            label={item.status}
                            tone={item.status === 'Active' ? 'success' : 'neutral'}
                            dense
                          />
                        </div>
                        <p className="text-caption text-text-secondary mt-1">
                          {item.event_type_display}
                        </p>
                        <div className="text-caption text-text-secondary phone:grid-cols-2 mt-3 grid min-w-0 gap-x-4 gap-y-2">
                          <span className="phone:col-span-2 inline-flex min-w-0 items-center gap-1.5">
                            <CalendarDays className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="break-words">
                              {formatEventRange(
                                eventStart(item),
                                item.event_time_to_iso || item.event_time_to,
                              )}
                            </span>
                          </span>
                          <span className="inline-flex min-w-0 items-center gap-1.5">
                            <MapPin className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="truncate" title={item.meeting_location || undefined}>
                              {item.meeting_location || 'Location to be confirmed'}
                            </span>
                          </span>
                          <span className="inline-flex min-w-0 items-center gap-1.5">
                            <UsersRound className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="break-words" title={item.target_audience.join(', ')}>
                              {eventAudienceSummary(item.target_audience)}
                            </span>
                          </span>
                          <span className="inline-flex min-w-0 items-center gap-1.5">
                            <UserRound className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="break-words">Hosted by {item.organizer_name}</span>
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="border-border-subtle flex shrink-0 flex-wrap justify-end gap-2 border-t pt-3">
                      <Button variant="outline" size="sm" onClick={() => setDetailEvent(item)}>
                        Details
                      </Button>
                      {canUpdateEvent && item.organizer_id === userId && eventCanBeEdited(item) ? (
                        <Button variant="outline" size="sm" onClick={() => openEventForm(item)}>
                          Edit
                        </Button>
                      ) : null}
                      {canUpdateEvent && item.organizer_id === userId && !eventCanBeEdited(item) ? (
                        <span className="text-caption text-text-muted mr-auto self-center">
                          Editing closes when an event starts.
                        </span>
                      ) : null}
                      {canDeleteEvent && item.organizer_id === userId ? (
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-danger hover:text-danger"
                          onClick={() => setConfirmDeleteEvent(item)}
                          leadingIcon={<Trash2 className="size-4" aria-hidden="true" />}
                        >
                          Delete
                        </Button>
                      ) : null}
                    </div>
                  </article>
                ))}
              </div>
            )}
            {eventsQuery.isError && eventsQuery.data ? (
              <div className="p-4 pt-0">
                <SectionErrorState
                  error={eventsQuery.error}
                  description="Showing the last loaded events."
                  onRetry={() => void eventsQuery.refetch()}
                />
              </div>
            ) : null}
            {!eventsQuery.isPending && eventsQuery.data ? (
              <Pagination
                page={search.page}
                count={eventsQuery.data?.count ?? 0}
                onPage={(page) => updateSearch({ page })}
              />
            ) : null}
          </Card>
        ) : null}
      </div>

      <Dialog
        open={Boolean(announcementForm)}
        onOpenChange={(open) => !open && setAnnouncementForm(null)}
        title={announcementForm === 'new' ? 'Create announcement' : 'Edit announcement'}
        description="Write a clear company update and choose its audience."
        size="lg"
        closeOnBackdrop={!saveAnnouncement.isPending}
        dismissDisabled={saveAnnouncement.isPending}
        footer={
          announcementForm ? (
            announcementChoices.isPending || announcementChoices.isError ? (
              <Button
                variant="outline"
                disabled={saveAnnouncement.isPending}
                onClick={() => setAnnouncementForm(null)}
              >
                Close
              </Button>
            ) : (
              <>
                <Button
                  variant="outline"
                  disabled={saveAnnouncement.isPending}
                  onClick={() => setAnnouncementForm(null)}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  form={ANNOUNCEMENT_FORM_ID}
                  isLoading={saveAnnouncement.isPending}
                  leadingIcon={<Send className="size-4" aria-hidden="true" />}
                >
                  {announcementForm !== 'new' ? 'Save changes' : 'Publish announcement'}
                </Button>
              </>
            )
          ) : null
        }
      >
        {announcementForm ? (
          announcementChoices.isError ? (
            <SectionErrorState
              error={announcementChoices.error}
              onRetry={() => void announcementChoices.refetch()}
            />
          ) : announcementChoices.isPending ? (
            <Skeleton className="h-64" />
          ) : (
            <AnnouncementForm
              formId={ANNOUNCEMENT_FORM_ID}
              key={announcementForm === 'new' ? 'new' : announcementForm.id}
              value={announcementForm === 'new' ? undefined : announcementForm}
              choices={announcementChoices.data}
              branches={(branchChoices.data?.items ?? []).map(({ id, branch_name }) => ({
                id,
                label: branch_name,
              }))}
              departments={(departmentOptions.data?.items ?? []).map(({ id, name }) => ({
                id,
                label: name,
              }))}
              branchOptionsState={
                !canListBranches
                  ? 'unavailable'
                  : branchChoices.isError
                    ? 'error'
                    : branchChoices.isPending
                      ? 'loading'
                      : 'ready'
              }
              departmentOptionsState={
                !canListDepartments
                  ? 'unavailable'
                  : departmentOptions.isError
                    ? 'error'
                    : departmentOptions.isPending
                      ? 'loading'
                      : 'ready'
              }
              onRetryBranches={() => void branchChoices.refetch()}
              onRetryDepartments={() => void departmentOptions.refetch()}
              onSubmit={(input) => saveAnnouncement.mutate(input)}
            />
          )
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(eventForm)}
        onOpenChange={(open) => !open && closeEventForm()}
        title={eventForm === 'new' ? 'Create event' : 'Edit event'}
        description="Schedule a company event and select who should be notified."
        size="lg"
        closeOnBackdrop={!saveEvent.isPending}
        dismissDisabled={saveEvent.isPending}
        footer={
          eventForm ? (
            eventChoices.isPending || eventChoices.isError ? (
              <Button variant="outline" disabled={saveEvent.isPending} onClick={closeEventForm}>
                Close
              </Button>
            ) : (
              <>
                <Button variant="outline" disabled={saveEvent.isPending} onClick={closeEventForm}>
                  Cancel
                </Button>
                <Button
                  type="submit"
                  form={EVENT_FORM_ID}
                  isLoading={saveEvent.isPending}
                  leadingIcon={<CalendarDays className="size-4" aria-hidden="true" />}
                >
                  {eventForm !== 'new' ? 'Save event' : 'Create event'}
                </Button>
              </>
            )
          ) : null
        }
      >
        {eventForm ? (
          eventChoices.isError ? (
            <SectionErrorState
              error={eventChoices.error}
              onRetry={() => void eventChoices.refetch()}
            />
          ) : eventChoices.isPending ? (
            <Skeleton className="h-64" />
          ) : (
            <EventForm
              formId={EVENT_FORM_ID}
              key={eventForm === 'new' ? 'new' : eventForm.id}
              value={eventForm === 'new' ? undefined : eventForm}
              choices={eventChoices.data}
              saveError={
                saveEvent.isError ? presentError(saveEvent.error, 'form-submit').message : null
              }
              onSubmit={(input) => saveEvent.mutate(input)}
            />
          )
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(detailAnnouncement)}
        onOpenChange={(open) => !open && setDetailAnnouncement(null)}
        title={detailAnnouncement?.title ?? 'Announcement'}
        description={detailAnnouncement?.announcement_id}
        size="md"
        fitContent
        compactOnMobile
        footer={
          <Button variant="outline" onClick={() => setDetailAnnouncement(null)}>
            Close
          </Button>
        }
      >
        {detailAnnouncement ? (
          <div className="space-y-4">
            <section className="border-border-subtle bg-surface-muted/60 rounded-surface border p-4">
              <div className="flex flex-wrap gap-2">
                <StatusChip
                  label={detailAnnouncement.is_active ? 'Active' : 'Inactive'}
                  tone={actionTone(detailAnnouncement.is_active)}
                />
                <StatusChip label={detailAnnouncement.priority_display} tone="primary" />
              </div>
              <div className="border-border-subtle mt-4 border-t pt-4">
                <h3 className="text-overline text-text-secondary">Message</h3>
                <p className="text-body-sm text-text-primary mt-2 break-words whitespace-pre-wrap">
                  {detailAnnouncement.content}
                </p>
              </div>
            </section>
            <section className="space-y-2">
              <h3 className="text-label text-text-primary font-semibold">Publication</h3>
              <dl className="phone:grid-cols-2 grid gap-2">
                <Detail label="Type" value={detailAnnouncement.announcement_type_display} />
                <Detail label="Created by" value={detailAnnouncement.created_by_name || 'System'} />
                <Detail
                  label="Publishes"
                  value={
                    detailAnnouncement.publish_at
                      ? formatDate(detailAnnouncement.publish_at, true)
                      : 'Published immediately'
                  }
                />
                <Detail
                  label="Expires"
                  value={
                    detailAnnouncement.expires_at
                      ? formatDate(detailAnnouncement.expires_at, true)
                      : 'No expiry set'
                  }
                />
              </dl>
            </section>
            <section aria-labelledby="announcement-details-audience-heading" className="space-y-3">
              <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-b pb-3">
                <div className="flex min-w-0 items-center gap-3">
                  <span className="bg-primary-subtle text-primary rounded-control inline-flex size-10 shrink-0 items-center justify-center">
                    <UsersRound size={18} aria-hidden="true" />
                  </span>
                  <div className="min-w-0">
                    <h3
                      id="announcement-details-audience-heading"
                      className="text-label text-text-primary font-semibold"
                    >
                      Audience
                    </h3>
                    <p className="text-caption text-text-secondary mt-0.5">
                      Visibility follows the selected branch and department scope.
                    </p>
                  </div>
                </div>
                <StatusChip
                  label={
                    detailAnnouncement.targets_all_branches &&
                    detailAnnouncement.targets_all_departments
                      ? 'Company-wide'
                      : 'Targeted audience'
                  }
                  tone={
                    detailAnnouncement.targets_all_branches &&
                    detailAnnouncement.targets_all_departments
                      ? 'info'
                      : 'primary'
                  }
                  dense
                />
              </div>
              <div className="tablet:grid-cols-2 grid gap-3">
                <AnnouncementAudienceCard
                  label="Branches"
                  icon={<MapPin size={17} aria-hidden="true" />}
                  all={detailAnnouncement.targets_all_branches}
                  allLabel="All branches"
                  allMessage="This announcement is visible across all branches."
                  selectedLabel={(count) =>
                    `${count} ${count === 1 ? 'branch' : 'branches'} selected`
                  }
                  names={detailAnnouncement.branches.map(({ branch_name }) => branch_name)}
                  emptyLabel="Branch scope was not recorded."
                  listLabel="Selected branches"
                />
                <AnnouncementAudienceCard
                  label="Departments"
                  icon={<UsersRound size={17} aria-hidden="true" />}
                  all={detailAnnouncement.targets_all_departments}
                  allLabel="All departments"
                  allMessage="This announcement is visible across all departments."
                  selectedLabel={(count) =>
                    `${count} ${count === 1 ? 'department' : 'departments'} selected`
                  }
                  names={detailAnnouncement.departments.map(({ name }) => name)}
                  emptyLabel="Department scope was not recorded."
                  listLabel="Selected departments"
                />
              </div>
            </section>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(detailEvent)}
        onOpenChange={(open) => !open && setDetailEvent(null)}
        title={detailEvent?.title ?? 'Event'}
        description={detailEvent?.event_id}
        size="md"
        fitContent
        compactOnMobile
        footer={
          <Button variant="outline" onClick={() => setDetailEvent(null)}>
            Close
          </Button>
        }
      >
        {detailEvent ? (
          <div className="space-y-4">
            <section className="border-border-subtle bg-surface-muted/60 rounded-surface border p-4">
              <div className="flex flex-wrap gap-2">
                <StatusChip
                  label={detailEvent.status}
                  tone={detailEvent.status === 'Active' ? 'success' : 'neutral'}
                />
                <StatusChip label={detailEvent.event_type_display} tone="primary" />
              </div>
              <div className="phone:grid-cols-2 mt-4 grid gap-2">
                <Detail label="Starts" value={formatDate(eventStart(detailEvent), true)} />
                <Detail
                  label="Ends"
                  value={formatDate(
                    detailEvent.event_time_to_iso || detailEvent.event_time_to,
                    true,
                  )}
                />
              </div>
            </section>
            <section className="space-y-2">
              <h3 className="text-label text-text-primary font-semibold">Event details</h3>
              <dl className="phone:grid-cols-2 grid gap-2">
                <Detail label="Location" value={detailEvent.meeting_location || 'Not specified'} />
                <Detail label="Reminder" value={detailEvent.reminder_offset || 'No reminder'} />
                <Detail label="Repeats" value={detailEvent.recurrence || 'No recurrence'} />
                <Detail label="Organizer" value={detailEvent.organizer_name || 'Not specified'} />
              </dl>
            </section>
            <section className="space-y-2">
              <h3 className="text-label text-text-primary font-semibold">Audience</h3>
              {detailEvent.target_audience.length ? (
                <div className="flex flex-wrap gap-2">
                  {detailEvent.target_audience.map((audience) => (
                    <StatusChip key={audience} label={audience} tone="neutral" />
                  ))}
                </div>
              ) : (
                <p className="text-body-sm text-text-secondary">No audience selected</p>
              )}
            </section>
          </div>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(confirmDeactivate)}
        onOpenChange={(open) => !open && setConfirmDeactivate(null)}
        title="Deactivate announcement"
        description="This removes the announcement from active broadcasts. It does not permanently delete the record."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmDeactivate(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deactivateAnnouncement.isPending}
              onClick={() =>
                confirmDeactivate && deactivateAnnouncement.mutate(confirmDeactivate.id)
              }
            >
              Deactivate
            </Button>
          </>
        }
      >
        {confirmDeactivate ? (
          <p className="text-body-sm text-text-secondary">
            Deactivate <strong className="text-text-primary">{confirmDeactivate.title}</strong>?
          </p>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(confirmDeleteEvent)}
        onOpenChange={(open) => !open && setConfirmDeleteEvent(null)}
        title="Delete event"
        description="This permanently removes the event from the event register."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setConfirmDeleteEvent(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deleteEvent.isPending}
              onClick={() => confirmDeleteEvent && deleteEvent.mutate(confirmDeleteEvent.id)}
            >
              Delete event
            </Button>
          </>
        }
      >
        {confirmDeleteEvent ? (
          <p className="text-body-sm text-text-secondary">
            Delete <strong className="text-text-primary">{confirmDeleteEvent.title}</strong>?
          </p>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}

function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div className="border-border-subtle bg-surface rounded-control min-w-0 border p-3">
      <dt className="text-overline text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">{value}</dd>
    </div>
  )
}

function AnnouncementAudienceCard({
  label,
  icon,
  all,
  allLabel,
  allMessage,
  selectedLabel,
  names,
  emptyLabel,
  listLabel,
}: {
  label: string
  icon: ReactNode
  all: boolean
  allLabel: string
  allMessage: string
  selectedLabel: (count: number) => string
  names: string[]
  emptyLabel: string
  listLabel: string
}) {
  return (
    <div className="border-border-subtle bg-surface rounded-control shadow-elevation-sm min-w-0 border p-4">
      <div className="flex min-w-0 items-start justify-between gap-3">
        <div className="flex min-w-0 items-center gap-3">
          <span className="bg-surface-muted text-text-secondary rounded-control inline-flex size-9 shrink-0 items-center justify-center">
            {icon}
          </span>
          <div className="min-w-0">
            <h4 className="text-label text-text-primary font-semibold">{label}</h4>
            <p className="text-caption text-text-secondary mt-0.5">
              {all ? allLabel : selectedLabel(names.length)}
            </p>
          </div>
        </div>
      </div>
      {all ? (
        <p className="border-border-subtle bg-surface-muted/60 text-body-sm text-text-secondary rounded-control mt-4 border px-3 py-2.5">
          {allMessage}
        </p>
      ) : names.length ? (
        <ul aria-label={listLabel} className="mt-4 flex flex-wrap gap-2">
          {names.map((name, index) => (
            <li
              key={`${name}-${index}`}
              className="border-border-subtle bg-surface-muted/60 text-caption text-text-primary rounded-control max-w-full border px-2.5 py-1.5 font-medium break-words"
            >
              {name}
            </li>
          ))}
        </ul>
      ) : (
        <p className="border-border-subtle bg-surface-muted/60 text-body-sm text-text-secondary rounded-control mt-4 border px-3 py-2.5">
          {emptyLabel}
        </p>
      )}
    </div>
  )
}
