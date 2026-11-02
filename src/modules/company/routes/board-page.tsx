import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  Archive,
  ArrowUpRight,
  CalendarDays,
  Check,
  ChevronLeft,
  ChevronRight,
  FileText,
  Handshake,
  Pencil,
  Plus,
  Search,
  UserRound,
  UsersRound,
  X,
} from 'lucide-react'
import { useCallback, useEffect, useMemo, useState, type FormEvent } from 'react'

import {
  governanceApi,
  governanceQueryKeys,
  type AssociateDto,
  type BoardMeetingDto,
  type BoardResolutionDto,
  type FieldChoice,
  type GovernanceListParams,
  type PartnerDto,
  type ShareholderDto,
} from '@/modules/company/governance.api'
import {
  AttachmentPicker,
  ProfileImagePicker,
} from '@/modules/company/components/governance-file-picker'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { TimePickerField } from '@/shared/ui/time-picker-field'

import type { BoardSearch } from '../governance.search'

const PAGE_SIZE = 10
const ASSOCIATE_TYPES = [
  'surveyor-associate',
  'lawyer-associate',
  'architect-associate',
  'engineer-associate',
] as const

const SECTION_META = {
  meetings: { label: 'Meetings', resource: 'meetings', icon: CalendarDays },
  resolutions: { label: 'Resolutions', resource: 'board_resolutions', icon: FileText },
  investors: { label: 'Investors', resource: 'shareholders', icon: UsersRound },
  associates: { label: 'Associates', resource: 'employees', icon: UserRound },
  partners: { label: 'Partners', resource: 'partners', icon: Handshake },
} as const

type Section = keyof typeof SECTION_META
type BoardRecord = BoardMeetingDto | BoardResolutionDto | ShareholderDto | AssociateDto | PartnerDto
type EditorState = { section: Section; record: BoardRecord | null } | null

const shareholderTitles: FieldChoice[] = [
  { value: 'founder', label: 'Founder' },
  { value: 'co_founder', label: 'Co Founder' },
  { value: 'chairman', label: 'Chairman' },
  { value: 'vice_chairman', label: 'Vice Chairman' },
  { value: 'executive_director', label: 'Executive Director' },
  { value: 'non_executive_director', label: 'Non-Executive Director' },
  { value: 'board_member', label: 'Board Member' },
]

function localDateInputValue() {
  const now = new Date()
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
}

function dateLabel(value: string) {
  const date = new Date(`${value.slice(0, 10)}T12:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }).format(date)
}

function toneFor(value: string): StatusTone {
  if (['approved', 'completed', 'active'].includes(value)) return 'success'
  if (['pending', 'scheduled', 'ongoing'].includes(value)) return 'warning'
  if (['cancelled', 'archived', 'inactive'].includes(value)) return 'neutral'
  if (['postponed', 'draft'].includes(value)) return 'info'
  return 'neutral'
}

function RecordFact({
  label,
  value,
}: {
  label: string
  value: string | number | null | undefined
}) {
  return (
    <div className="min-w-0">
      <dt className="text-overline text-text-muted">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
        {value == null || value === '' ? 'Not provided' : value}
      </dd>
    </div>
  )
}

function ExistingAttachment({ url, onRemove }: { url: string; onRemove: () => void }) {
  if (!url) return null

  return (
    <div className="border-border-subtle bg-surface rounded-control flex min-w-0 flex-wrap items-center justify-between gap-2 border px-3 py-2">
      <div className="min-w-0">
        <p className="text-caption text-text-muted">Current attachment</p>
        <a
          className="text-body-sm text-primary mt-0.5 block break-all underline-offset-2 hover:underline"
          href={url}
          rel="noreferrer"
          target="_blank"
        >
          View saved file
        </a>
      </div>
      <Button type="button" variant="ghost" size="sm" onClick={onRemove}>
        Remove attachment
      </Button>
    </div>
  )
}

function useDebouncedSearch(search: string, commit: (value: string) => void) {
  const [value, setValue] = useState(search)
  useEffect(() => {
    const next = value.trim()
    if (next === search) return
    const timer = window.setTimeout(() => commit(next), 250)
    return () => window.clearTimeout(timer)
  }, [commit, search, value])
  return [value, setValue] as const
}

function BoardSearchControl({
  search,
  onCommit,
}: {
  search: string
  onCommit: (value: string) => void
}) {
  const [value, setValue] = useDebouncedSearch(search, onCommit)
  return (
    <FormControl id="board-search" label="Search this section">
      <div className="relative">
        <Search
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="board-search"
          type="search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Search by name, title, reference, or type"
          className="pl-10"
        />
      </div>
    </FormControl>
  )
}

function initialDraft(
  section: Section,
  record: BoardRecord | null,
): Record<string, string | boolean | number | number[]> {
  const today = localDateInputValue()
  if (section === 'meetings') {
    const value = record as BoardMeetingDto | null
    return {
      title: value?.title ?? '',
      agenda: value?.agenda ?? '',
      meeting_date: value?.meeting_date ?? today,
      meeting_time: value?.meeting_time?.slice(0, 5) ?? '09:00',
      duration_minutes: value?.duration_minutes ?? 60,
      status: value?.status ?? 'scheduled',
      location_type: value?.location_type ?? 'physical',
      location: value?.location ?? '',
      notes: value?.notes ?? '',
      file_url: value?.file_url ?? '',
      attendee_ids: value?.attendees?.map((item) => item.user_id) ?? [],
    }
  }
  if (section === 'resolutions') {
    const value = record as BoardResolutionDto | null
    return {
      title: value?.title ?? '',
      description: value?.description ?? '',
      resolution_type: value?.resolution_type ?? 'governance',
      resolution_date: value?.resolution_date ?? today,
      status: value?.status === 'draft' ? 'draft' : 'pending',
      attachment_url: value?.attachment_url ?? '',
      notes: value?.notes ?? '',
    }
  }
  if (section === 'investors') {
    const value = record as ShareholderDto | null
    return {
      first_name: value?.first_name ?? '',
      last_name: value?.last_name ?? '',
      email: value?.email ?? '',
      phone_number: value?.phone_number ?? '',
      title: value?.title ?? 'board_member',
      share_percentage: value?.share_percentage ?? 0,
      share_count: value?.share_count ?? '',
      is_board_member: value?.is_board_member ?? false,
      is_active: value?.is_active ?? true,
      notes: value?.notes ?? '',
    }
  }
  if (section === 'partners') {
    const value = record as PartnerDto | null
    return {
      name: value?.name ?? '',
      code: value?.code ?? '',
      email: value?.email ?? '',
      phone: value?.phone ?? '',
      address: value?.address ?? '',
      category: value?.category ?? 'other',
      status: value?.status ?? 'inactive',
      kyc_status: value?.kyc_status ?? 'pending',
      commission_rate: value?.commission_rate ?? 0,
      notes: value?.notes ?? '',
    }
  }
  return {}
}

function BoardRecordEditor({
  section,
  record,
  userId,
  employeeId,
  permissions,
  saving,
  onClose,
  onSave,
}: {
  section: Section
  record: BoardRecord | null
  userId: number
  employeeId: string
  permissions: Record<string, string[]>
  saving: boolean
  onClose: () => void
  onSave: (
    section: Section,
    recordId: number | null,
    payload: Record<string, unknown>,
  ) => Promise<void>
}) {
  const [draft, setDraft] = useState(() => initialDraft(section, record))
  const [error, setError] = useState('')
  const [attachmentFile, setAttachmentFile] = useState<File | null>(null)
  const [clearAttachment, setClearAttachment] = useState(false)
  const [uploadedAttachment, setUploadedAttachment] = useState<{ file: File; url: string } | null>(
    null,
  )
  const [profileImageFile, setProfileImageFile] = useState<File | null>(null)
  const [uploadedProfileImage, setUploadedProfileImage] = useState<{
    file: File
    url: string
  } | null>(null)
  const [clearProfileImage, setClearProfileImage] = useState(false)
  const [uploading, setUploading] = useState(false)
  const canListEmployees = hasPermission(permissions, 'employees', 'list')
  const meetingChoices = useQuery({
    queryKey: governanceQueryKeys.choices(userId, employeeId, 'meeting-fields'),
    queryFn: ({ signal }) => governanceApi.meetingChoices(signal),
    enabled: section === 'meetings',
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const resolutionChoices = useQuery({
    queryKey: governanceQueryKeys.choices(userId, employeeId, 'resolution-fields'),
    queryFn: ({ signal }) => governanceApi.resolutionChoices(signal),
    enabled: section === 'resolutions',
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const partnerChoices = useQuery({
    queryKey: governanceQueryKeys.choices(userId, employeeId, 'partner-fields'),
    queryFn: ({ signal }) => governanceApi.partnerChoices(signal),
    enabled: section === 'partners',
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const attendeeChoices = useQuery({
    queryKey: governanceQueryKeys.choices(userId, employeeId, 'meeting-attendees'),
    queryFn: ({ signal }) => governanceApi.meetingAttendeeChoices(signal),
    enabled: section === 'meetings' && canListEmployees,
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const update = (key: string, value: string | boolean | number[]) =>
    setDraft((previous) => ({ ...previous, [key]: value }))

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    const payload: Record<string, unknown> = { ...draft }
    try {
      if (section === 'meetings' || section === 'resolutions') {
        if (attachmentFile) {
          const cachedUpload =
            uploadedAttachment?.file === attachmentFile ? uploadedAttachment : null
          let url = cachedUpload?.url
          if (!url) {
            setUploading(true)
            url = (await governanceApi.uploadFile(attachmentFile)).url
            setUploadedAttachment({ file: attachmentFile, url })
          }
          payload[section === 'meetings' ? 'file_url' : 'attachment_url'] = url
        } else if (clearAttachment) {
          payload[section === 'meetings' ? 'file_url' : 'attachment_url'] =
            section === 'resolutions' ? '' : null
        }
        if (section === 'meetings') {
          payload.duration_minutes = Number(draft.duration_minutes)
          if (!canListEmployees) delete payload.attendee_ids
        } else if (!payload.attachment_url) {
          // Optional URLFields are blank strings in the database, not nulls.
          payload.attachment_url = ''
        }
      } else if (section === 'investors') {
        payload.share_percentage = Number(draft.share_percentage)
        payload.share_count = draft.share_count === '' ? null : Number(draft.share_count)
        if (profileImageFile) {
          const cachedUpload =
            uploadedProfileImage?.file === profileImageFile ? uploadedProfileImage : null
          let url = cachedUpload?.url
          if (!url) {
            setUploading(true)
            url = (await governanceApi.uploadFile(profileImageFile)).url
            setUploadedProfileImage({ file: profileImageFile, url })
          }
          payload.profile_picture = url
        } else if (clearProfileImage) {
          payload.profile_picture = null
        }
        if (record) delete payload.email
        if (!record) {
          payload.password = null
          payload.gender = 'male'
          payload.marital_status = 'single'
          payload.address = ''
        }
      } else if (section === 'partners') {
        payload.commission_rate = Number(draft.commission_rate)
      }
      await onSave(section, record?.id ?? null, payload)
      onClose()
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    } finally {
      setUploading(false)
    }
  }

  const title = record
    ? `Edit ${SECTION_META[section].label.slice(0, -1).toLowerCase()}`
    : `New ${SECTION_META[section].label.slice(0, -1).toLowerCase()}`
  const meetingStatusOptions = (meetingChoices.data?.statuses ?? []).map((choice) => ({
    ...choice,
  }))
  const locationOptions = (meetingChoices.data?.location_types ?? []).map((choice) => ({
    ...choice,
  }))
  const resolutionTypeOptions = (
    resolutionChoices.data?.types ??
    resolutionChoices.data?.resolution_types ??
    []
  ).map((choice) => ({ ...choice }))
  const partnerCategoryOptions = (partnerChoices.data?.category ?? []).map((choice) => ({
    ...choice,
  }))
  const partnerStatusOptions = (partnerChoices.data?.status ?? []).map((choice) => ({ ...choice }))
  const kycOptions = (partnerChoices.data?.kyc_status ?? []).map((choice) => ({ ...choice }))
  const attendeeOptions = attendeeChoices.data?.items ?? []
  const pickedAttendees = Array.isArray(draft.attendee_ids) ? draft.attendee_ids : []

  return (
    <Dialog
      open
      onOpenChange={(open) => !open && onClose()}
      title={title}
      description="Complete the fields supported by this record. Changes are saved to the matching governance record."
      size="lg"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="board-record-form" isLoading={saving || uploading}>
            {record ? 'Save changes' : 'Create record'}
          </Button>
        </>
      }
    >
      <form id="board-record-form" onSubmit={(event) => void submit(event)} className="space-y-4">
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Record details</h3>
            <p className="text-caption text-text-secondary mt-1">
              Enter the information for this governance record.
            </p>
          </div>
          {section === 'meetings' ? (
            <div className="phone:grid-cols-2 grid gap-4">
              <FormControl
                id="meeting-title"
                label="Meeting title"
                required
                className="phone:col-span-2"
              >
                <TextInput
                  id="meeting-title"
                  required
                  maxLength={255}
                  value={String(draft.title ?? '')}
                  onChange={(e) => update('title', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="meeting-date" label="Date" required>
                <DatePickerField
                  required
                  value={String(draft.meeting_date ?? '')}
                  onValueChange={(value) => update('meeting_date', value)}
                />
              </FormControl>
              <FormControl id="meeting-time" label="Time" required>
                <TimePickerField
                  id="meeting-time"
                  required
                  value={String(draft.meeting_time ?? '')}
                  onValueChange={(value) => update('meeting_time', value)}
                />
              </FormControl>
              <FormControl id="meeting-duration" label="Duration in minutes" required>
                <TextInput
                  id="meeting-duration"
                  type="number"
                  min={1}
                  required
                  value={String(draft.duration_minutes ?? '')}
                  onChange={(e) => update('duration_minutes', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="meeting-status" label="Status">
                <DropdownSelect
                  id="meeting-status"
                  value={String(draft.status ?? 'scheduled')}
                  options={
                    meetingStatusOptions.length
                      ? meetingStatusOptions
                      : [
                          { value: 'scheduled', label: 'Scheduled' },
                          { value: 'ongoing', label: 'Ongoing' },
                          { value: 'completed', label: 'Completed' },
                          { value: 'postponed', label: 'Postponed' },
                          { value: 'cancelled', label: 'Cancelled' },
                        ]
                  }
                  onChange={(value) => update('status', value)}
                />
              </FormControl>
              <FormControl id="meeting-location-type" label="Location type">
                <DropdownSelect
                  id="meeting-location-type"
                  value={String(draft.location_type ?? 'physical')}
                  options={
                    locationOptions.length
                      ? locationOptions
                      : [
                          { value: 'physical', label: 'Physical' },
                          { value: 'virtual', label: 'Virtual' },
                          { value: 'hybrid', label: 'Hybrid' },
                        ]
                  }
                  onChange={(value) => update('location_type', value)}
                />
              </FormControl>
              <FormControl id="meeting-location" label="Location or link">
                <TextInput
                  id="meeting-location"
                  value={String(draft.location ?? '')}
                  onChange={(e) => update('location', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="meeting-agenda" label="Agenda" required className="phone:col-span-2">
                <TextArea
                  id="meeting-agenda"
                  required
                  rows={3}
                  value={String(draft.agenda ?? '')}
                  onChange={(e) => update('agenda', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="meeting-notes" label="Notes" className="phone:col-span-2">
                <TextArea
                  id="meeting-notes"
                  rows={2}
                  value={String(draft.notes ?? '')}
                  onChange={(e) => update('notes', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl
                id="meeting-document-file"
                label="Upload image or PDF"
                className="phone:col-span-2"
              >
                <div className="space-y-2">
                  {!attachmentFile && !clearAttachment ? (
                    <ExistingAttachment
                      url={String(draft.file_url ?? '')}
                      onRemove={() => {
                        setClearAttachment(true)
                        update('file_url', '')
                      }}
                    />
                  ) : null}
                  <AttachmentPicker
                    id="meeting-document-file-picker"
                    files={attachmentFile ? [attachmentFile] : []}
                    onChange={(files) => {
                      setAttachmentFile(files[0] ?? null)
                      setUploadedAttachment(null)
                    }}
                  />
                </div>
              </FormControl>
              {canListEmployees ? (
                <fieldset className="phone:col-span-2 min-w-0 space-y-2">
                  <legend className="text-control-label text-text-secondary font-bold">
                    Attendees
                  </legend>
                  {attendeeChoices.isError ? (
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <Alert className="flex-1" tone="warning">
                        Attendee choices could not be loaded. Existing selections are preserved.
                      </Alert>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => void attendeeChoices.refetch()}
                      >
                        Retry
                      </Button>
                    </div>
                  ) : null}
                  <div className="border-border-subtle bg-surface-muted rounded-control max-h-40 overflow-y-auto border p-2">
                    {attendeeChoices.isPending ? (
                      <p className="text-caption text-text-muted p-2">Loading active employees…</p>
                    ) : attendeeOptions.length ? (
                      attendeeOptions.map((person) => {
                        const name =
                          `${person.first_name} ${person.last_name}`.trim() || person.email
                        const checked = pickedAttendees.includes(person.user_id)
                        return (
                          <label
                            key={person.user_id}
                            className="hover:bg-surface rounded-control text-caption flex cursor-pointer items-center gap-2 px-2 py-1.5"
                          >
                            <input
                              type="checkbox"
                              checked={checked}
                              onChange={(event) =>
                                update(
                                  'attendee_ids',
                                  event.currentTarget.checked
                                    ? [...pickedAttendees, person.user_id]
                                    : pickedAttendees.filter((id) => id !== person.user_id),
                                )
                              }
                            />{' '}
                            <span className="min-w-0 truncate">{name}</span>
                            <span className="text-text-muted ml-auto truncate">
                              {person.employee_id}
                            </span>
                          </label>
                        )
                      })
                    ) : (
                      <p className="text-caption text-text-muted p-2">
                        No active employees available.
                      </p>
                    )}
                  </div>
                </fieldset>
              ) : null}
            </div>
          ) : null}
          {section === 'resolutions' ? (
            <div className="phone:grid-cols-2 grid gap-4">
              <FormControl
                id="resolution-title"
                label="Title"
                required
                className="phone:col-span-2"
              >
                <TextInput
                  id="resolution-title"
                  required
                  maxLength={255}
                  value={String(draft.title ?? '')}
                  onChange={(e) => update('title', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="resolution-type" label="Type" required>
                <DropdownSelect
                  id="resolution-type"
                  value={String(draft.resolution_type ?? 'governance')}
                  options={
                    resolutionTypeOptions.length
                      ? resolutionTypeOptions
                      : [
                          { value: 'financial', label: 'Financial' },
                          { value: 'operational', label: 'Operational' },
                          { value: 'strategic', label: 'Strategic' },
                          { value: 'legal', label: 'Legal & Compliance' },
                          { value: 'hr', label: 'Human Resources' },
                          { value: 'investment', label: 'Investment' },
                          { value: 'governance', label: 'Governance' },
                          { value: 'other', label: 'Other' },
                        ]
                  }
                  onChange={(value) => update('resolution_type', value)}
                />
              </FormControl>
              <FormControl id="resolution-date" label="Resolution date" required>
                <DatePickerField
                  required
                  value={String(draft.resolution_date ?? '')}
                  onValueChange={(value) => update('resolution_date', value)}
                />
              </FormControl>
              <FormControl id="resolution-status" label="Workflow status">
                <DropdownSelect
                  id="resolution-status"
                  value={String(draft.status ?? 'pending')}
                  options={[
                    { value: 'draft', label: 'Draft' },
                    { value: 'pending', label: 'Pending review' },
                  ]}
                  onChange={(value) => update('status', value)}
                />
              </FormControl>
              <FormControl id="resolution-document-file" label="Upload image or PDF">
                <div className="space-y-2">
                  {!attachmentFile && !clearAttachment ? (
                    <ExistingAttachment
                      url={String(draft.attachment_url ?? '')}
                      onRemove={() => {
                        setClearAttachment(true)
                        update('attachment_url', '')
                      }}
                    />
                  ) : null}
                  <AttachmentPicker
                    id="resolution-document-file-picker"
                    files={attachmentFile ? [attachmentFile] : []}
                    onChange={(files) => {
                      setAttachmentFile(files[0] ?? null)
                      setUploadedAttachment(null)
                    }}
                  />
                </div>
              </FormControl>
              <FormControl
                id="resolution-description"
                label="Description"
                required
                className="phone:col-span-2"
              >
                <TextArea
                  id="resolution-description"
                  required
                  rows={4}
                  value={String(draft.description ?? '')}
                  onChange={(e) => update('description', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="resolution-notes" label="Notes" className="phone:col-span-2">
                <TextArea
                  id="resolution-notes"
                  rows={2}
                  value={String(draft.notes ?? '')}
                  onChange={(e) => update('notes', e.currentTarget.value)}
                />
              </FormControl>
            </div>
          ) : null}
          {section === 'investors' ? (
            <div className="space-y-4">
              {!record ? (
                <Alert tone="info">
                  Creating a shareholder also creates a user account and sends a welcome email after
                  the save commits.
                </Alert>
              ) : null}
              <FormSection className="space-y-3">
                <div>
                  <h3 className="text-label font-semibold">Profile photo</h3>
                  <p className="text-caption text-text-secondary mt-0.5">
                    Choose a clear image for the shareholder profile.
                  </p>
                </div>
                <ProfileImagePicker
                  id="shareholder-profile-photo"
                  currentUrl={(record as ShareholderDto | null)?.profile_picture}
                  initials={`${String(draft.first_name ?? '')
                    .trim()
                    .slice(0, 1)}${String(draft.last_name ?? '')
                    .trim()
                    .slice(0, 1)}`}
                  file={profileImageFile}
                  onChange={(file) => {
                    setProfileImageFile(file)
                    setUploadedProfileImage(null)
                    if (file) setClearProfileImage(false)
                  }}
                  onClear={() => setClearProfileImage(true)}
                  disabled={saving || uploading}
                />
              </FormSection>
              <div className="tablet:grid-cols-2 grid gap-4">
                <FormControl id="shareholder-first-name" label="First name" required>
                  <TextInput
                    id="shareholder-first-name"
                    required
                    value={String(draft.first_name ?? '')}
                    onChange={(e) => update('first_name', e.currentTarget.value)}
                  />
                </FormControl>
                <FormControl id="shareholder-last-name" label="Last name" required>
                  <TextInput
                    id="shareholder-last-name"
                    required
                    value={String(draft.last_name ?? '')}
                    onChange={(e) => update('last_name', e.currentTarget.value)}
                  />
                </FormControl>
                <FormControl id="shareholder-email" label="Email" required>
                  <TextInput
                    id="shareholder-email"
                    type="email"
                    required
                    disabled={Boolean(record)}
                    value={String(draft.email ?? '')}
                    onChange={(e) => update('email', e.currentTarget.value)}
                  />
                </FormControl>
                <FormControl id="shareholder-phone" label="Phone">
                  <TextInput
                    id="shareholder-phone"
                    type="tel"
                    value={String(draft.phone_number ?? '')}
                    onChange={(e) => update('phone_number', e.currentTarget.value)}
                  />
                </FormControl>
                <FormControl id="shareholder-title" label="Board title" required>
                  <DropdownSelect
                    id="shareholder-title"
                    value={String(draft.title ?? 'board_member')}
                    options={shareholderTitles.map((choice) => ({ ...choice }))}
                    onChange={(value) => update('title', value)}
                  />
                </FormControl>
                <FormControl id="shareholder-shares" label="Share percentage" required>
                  <TextInput
                    id="shareholder-shares"
                    type="number"
                    min="0"
                    max="100"
                    step="0.01"
                    required
                    value={String(draft.share_percentage ?? 0)}
                    onChange={(e) => update('share_percentage', e.currentTarget.value)}
                  />
                </FormControl>
                <FormControl id="shareholder-count" label="Share count">
                  <TextInput
                    id="shareholder-count"
                    type="number"
                    min="0"
                    value={String(draft.share_count ?? '')}
                    onChange={(e) => update('share_count', e.currentTarget.value)}
                  />
                </FormControl>
                <div className="flex flex-wrap gap-4 self-end pb-2">
                  <label className="text-caption text-text-secondary inline-flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={Boolean(draft.is_board_member)}
                      onChange={(e) => update('is_board_member', e.currentTarget.checked)}
                    />{' '}
                    Board member
                  </label>
                  <label className="text-caption text-text-secondary inline-flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={Boolean(draft.is_active)}
                      onChange={(e) => update('is_active', e.currentTarget.checked)}
                    />{' '}
                    Active
                  </label>
                </div>
                <FormControl id="shareholder-notes" label="Notes" className="tablet:col-span-2">
                  <TextArea
                    id="shareholder-notes"
                    rows={3}
                    value={String(draft.notes ?? '')}
                    onChange={(e) => update('notes', e.currentTarget.value)}
                  />
                </FormControl>
              </div>
            </div>
          ) : null}
          {section === 'partners' ? (
            <div className="phone:grid-cols-2 grid gap-4">
              <FormControl
                id="partner-name"
                label="Partner name"
                required
                className="phone:col-span-2"
              >
                <TextInput
                  id="partner-name"
                  required
                  value={String(draft.name ?? '')}
                  onChange={(e) => update('name', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-code" label="Partner code">
                <TextInput
                  id="partner-code"
                  value={String(draft.code ?? '')}
                  onChange={(e) => update('code', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-category" label="Category">
                <DropdownSelect
                  id="partner-category"
                  value={String(draft.category ?? 'other')}
                  options={
                    partnerCategoryOptions.length
                      ? partnerCategoryOptions
                      : [{ value: 'other', label: 'Other' }]
                  }
                  onChange={(value) => update('category', value)}
                />
              </FormControl>
              <FormControl id="partner-status" label="Status">
                <DropdownSelect
                  id="partner-status"
                  value={String(draft.status ?? 'inactive')}
                  options={
                    partnerStatusOptions.length
                      ? partnerStatusOptions
                      : [
                          { value: 'active', label: 'Active' },
                          { value: 'inactive', label: 'Inactive' },
                          { value: 'pending', label: 'Pending' },
                          { value: 'suspended', label: 'Suspended' },
                        ]
                  }
                  onChange={(value) => update('status', value)}
                />
              </FormControl>
              <FormControl id="partner-kyc" label="KYC status">
                <DropdownSelect
                  id="partner-kyc"
                  value={String(draft.kyc_status ?? 'pending')}
                  options={
                    kycOptions.length
                      ? kycOptions
                      : [
                          { value: 'pending', label: 'Pending' },
                          { value: 'submitted', label: 'Submitted' },
                          { value: 'verified', label: 'Verified' },
                          { value: 'rejected', label: 'Rejected' },
                        ]
                  }
                  onChange={(value) => update('kyc_status', value)}
                />
              </FormControl>
              <FormControl id="partner-email" label="Email">
                <TextInput
                  id="partner-email"
                  type="email"
                  value={String(draft.email ?? '')}
                  onChange={(e) => update('email', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-phone" label="Phone">
                <TextInput
                  id="partner-phone"
                  type="tel"
                  value={String(draft.phone ?? '')}
                  onChange={(e) => update('phone', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-rate" label="Commission rate (%)">
                <TextInput
                  id="partner-rate"
                  type="number"
                  min="0"
                  max="100"
                  step="0.01"
                  value={String(draft.commission_rate ?? 0)}
                  onChange={(e) => update('commission_rate', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-address" label="Address" className="tablet:col-span-2">
                <TextArea
                  id="partner-address"
                  rows={2}
                  value={String(draft.address ?? '')}
                  onChange={(e) => update('address', e.currentTarget.value)}
                />
              </FormControl>
              <FormControl id="partner-notes" label="Notes" className="tablet:col-span-2">
                <TextArea
                  id="partner-notes"
                  rows={2}
                  value={String(draft.notes ?? '')}
                  onChange={(e) => update('notes', e.currentTarget.value)}
                />
              </FormControl>
            </div>
          ) : null}
          {section === 'associates' ? (
            <Alert tone="info">
              Associate records are managed in Employees. This view is read-only.
            </Alert>
          ) : null}
        </FormSection>
      </form>
    </Dialog>
  )
}

function RecordCard({
  section,
  record,
  search,
  permissions,
  onEdit,
  onPrimary,
  onDelete,
}: {
  section: Section
  record: BoardRecord
  search: BoardSearch
  permissions: Record<string, string[]>
  onEdit: () => void
  onPrimary: () => void
  onDelete: () => void
}) {
  const meta = SECTION_META[section]
  const lockedResolution =
    section === 'resolutions' &&
    ['approved', 'archived'].includes((record as BoardResolutionDto).status)
  const canUpdate =
    section !== 'associates' &&
    !lockedResolution &&
    hasPermission(permissions, meta.resource, 'update')
  const canDelete = hasPermission(permissions, meta.resource, 'delete')
  const canView = hasPermission(permissions, meta.resource, 'view')
  let title: string
  let subtitle: string
  let status: string
  let identifier: string
  let summary: string | null = null
  let facts: { label: string; value: string | number | null | undefined }[]
  let primaryLabel = ''
  let primaryAllowed = false

  if (section === 'meetings') {
    const item = record as BoardMeetingDto
    title = item.title
    subtitle = item.organizer_name ? `Organised by ${item.organizer_name}` : 'Board meeting'
    status = item.status_display || item.status
    identifier = item.meeting_id
    facts = [
      { label: 'Date', value: dateLabel(item.meeting_date) },
      {
        label: 'Time',
        value: `${item.meeting_time?.slice(0, 5) || 'Not set'} · ${item.duration_display || `${item.duration_minutes} min`}`,
      },
      {
        label: 'Location',
        value: [item.location_type_display, item.location].filter(Boolean).join(' · '),
      },
      {
        label: 'Attendees',
        value: `${item.attendee_count} ${item.attendee_count === 1 ? 'person' : 'people'}`,
      },
    ]
    summary = item.agenda || null
    primaryLabel = 'Cancel meeting'
    primaryAllowed = item.status !== 'cancelled' && canDelete
  } else if (section === 'resolutions') {
    const item = record as BoardResolutionDto
    title = item.title
    subtitle = item.resolution_type_display || 'Board resolution'
    status = item.status_display || item.status
    identifier = item.resolution_id
    facts = [
      { label: 'Resolution date', value: dateLabel(item.resolution_date) },
      { label: 'Prepared by', value: item.created_by_name },
      { label: 'Approved by', value: item.approved_by_name },
    ]
    summary = item.description || null
    primaryLabel = 'Approve'
    primaryAllowed =
      item.status === 'pending' && hasPermission(permissions, 'board_resolutions', 'approve')
  } else if (section === 'investors') {
    const item = record as ShareholderDto
    title = `${item.first_name} ${item.last_name}`.trim()
    subtitle = item.title_display || 'Shareholder'
    status = item.is_active ? 'Active' : 'Inactive'
    identifier = item.shareholder_id
    facts = [
      { label: 'Ownership', value: `${item.share_percentage}%` },
      { label: 'Shares', value: item.share_count?.toLocaleString() },
      { label: 'Board role', value: item.is_board_member ? 'Board member' : 'Shareholder' },
      { label: 'Email', value: item.email },
    ]
  } else if (section === 'associates') {
    const item = record as AssociateDto
    title = `${item.first_name} ${item.last_name}`.trim()
    subtitle = item.designation || 'Associate'
    status = item.employment_status || (item.is_active ? 'Active' : 'Inactive')
    identifier = item.employee_id
    facts = [
      { label: 'Employment type', value: item.employment_type },
      { label: 'Department', value: item.department_name },
      { label: 'Branch', value: item.branch_name },
      { label: 'Email', value: item.email },
    ]
  } else {
    const item = record as PartnerDto
    title = item.name
    subtitle = item.category_display || 'Board partner'
    status = item.status_display
    identifier = item.code || `#${item.id}`
    facts = [
      { label: 'KYC status', value: item.kyc_status_display },
      { label: 'Agreements', value: item.agreement_count },
      { label: 'Commission', value: `${item.commission_rate}%` },
      { label: 'Email', value: item.email },
    ]
    primaryLabel = 'Delete'
    primaryAllowed = canDelete
  }

  const recordId = section === 'associates' ? (record as AssociateDto).user_id : record.id
  const shortCancelLabel = section === 'meetings' && primaryLabel === 'Cancel meeting'
  return (
    <article className="border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-sm rounded-control shadow-elevation-sm min-w-0 overflow-hidden border transition-colors">
      <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center overflow-hidden">
          {section === 'investors' && (record as ShareholderDto).profile_picture ? (
            <img
              className="size-full object-cover"
              src={(record as ShareholderDto).profile_picture ?? ''}
              alt=""
            />
          ) : (
            <meta.icon className="size-5" aria-hidden="true" />
          )}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <div className="min-w-0 flex-1">
              <h2 className="text-label text-text-primary font-semibold break-words">
                {title || 'Untitled record'}
              </h2>
              <p className="text-caption text-text-secondary mt-0.5 break-words">{subtitle}</p>
            </div>
            {status ? (
              <StatusChip
                label={status}
                tone={toneFor(status.toLowerCase())}
                dense
                className="shrink-0"
              />
            ) : null}
          </div>
        </div>
      </header>

      <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
        {facts.map((fact) => (
          <RecordFact key={fact.label} label={fact.label} value={fact.value} />
        ))}
      </dl>

      {summary ? (
        <div className="border-border-subtle phone:px-5 border-t px-4 py-3">
          <p className="text-overline text-text-muted">
            {section === 'meetings' ? 'Agenda' : section === 'resolutions' ? 'Summary' : 'Notes'}
          </p>
          <p className="text-body-sm text-text-secondary mt-1 line-clamp-2 break-words">
            {summary}
          </p>
        </div>
      ) : null}

      <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
        <p className="text-overline text-text-muted min-w-0 break-all">Record ID · {identifier}</p>
        <div className="phone:justify-end flex min-w-0 flex-wrap items-center gap-2">
          {canView ? (
            <Link
              to="/company/board/$section/$recordId"
              params={{ section, recordId: String(recordId) }}
              search={search}
              className="text-caption text-primary border-primary/20 bg-primary-subtle/45 hover:bg-primary-subtle focus-visible:shadow-focus-ring rounded-control inline-flex min-h-9 items-center justify-center gap-2 border px-3 font-semibold transition-colors focus-visible:outline-none"
            >
              Details <ArrowUpRight className="size-3.5" aria-hidden="true" />
            </Link>
          ) : null}
          {canUpdate ? (
            <Button
              variant="outline"
              size="sm"
              onClick={onEdit}
              leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
            >
              Edit
            </Button>
          ) : null}
          {primaryAllowed ? (
            <Button
              variant={section === 'partners' ? 'danger' : 'outline'}
              size="sm"
              onClick={onPrimary}
              aria-label={shortCancelLabel ? 'Cancel meeting' : undefined}
              leadingIcon={
                section === 'resolutions' ? (
                  <Check className="size-3.5" aria-hidden="true" />
                ) : (
                  <X className="size-3.5" aria-hidden="true" />
                )
              }
            >
              {shortCancelLabel ? (
                <>
                  <span className="tablet:hidden">Cancel</span>
                  <span className="tablet:inline hidden">Cancel meeting</span>
                </>
              ) : (
                primaryLabel
              )}
            </Button>
          ) : null}
          {section === 'resolutions' &&
          canDelete &&
          (record as BoardResolutionDto).status !== 'archived' ? (
            <Button
              variant="ghost"
              size="sm"
              onClick={onDelete}
              leadingIcon={<Archive className="size-3.5" aria-hidden="true" />}
            >
              Archive
            </Button>
          ) : null}
        </div>
      </footer>
    </article>
  )
}

function ConfirmationDialog({
  title,
  description,
  confirmLabel,
  danger = false,
  onCancel,
  onConfirm,
  pending,
}: {
  title: string
  description: string
  confirmLabel: string
  danger?: boolean
  onCancel: () => void
  onConfirm: () => void
  pending: boolean
}) {
  return (
    <Dialog
      open
      onOpenChange={(open) => !open && onCancel()}
      title={title}
      description={description}
      size="sm"
      fitContent
      compactOnMobile
      footer={
        <>
          <Button variant="outline" onClick={onCancel}>
            Keep record
          </Button>
          <Button variant={danger ? 'danger' : 'primary'} onClick={onConfirm} isLoading={pending}>
            {confirmLabel}
          </Button>
        </>
      }
    >
      <Alert tone={danger ? 'warning' : 'info'}>{description}</Alert>
    </Dialog>
  )
}

export function BoardPage() {
  const search = useSearch({ from: '/_protected/company/board' }) as BoardSearch
  const navigate = useNavigate({ from: '/company/board' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const [editor, setEditor] = useState<EditorState>(null)
  const [confirmation, setConfirmation] = useState<{
    section: Section
    record: BoardRecord
    action: 'primary' | 'archive'
  } | null>(null)
  const section = search.tab as Section
  const sectionPermission = SECTION_META[section].resource
  const canListSection = hasPermission(permissions, sectionPermission, 'list')
  const canCreate = canListSection && hasPermission(permissions, sectionPermission, 'create')
  const params = useMemo<GovernanceListParams>(
    () => ({ limit: PAGE_SIZE, offset: (search.page - 1) * PAGE_SIZE, search: search.search }),
    [search.page, search.search],
  )
  const listQuery = useQuery({
    queryKey: governanceQueryKeys.list(userId, employeeId, section, {
      ...params,
      ...(section === 'associates' ? { types: ASSOCIATE_TYPES } : {}),
    }),
    queryFn: async ({ signal }) => {
      if (section === 'meetings') return governanceApi.meetings(params, signal)
      if (section === 'resolutions') return governanceApi.resolutions(params, signal)
      if (section === 'investors') return governanceApi.shareholders(params, signal)
      if (section === 'partners') return governanceApi.partners(params, signal)
      const pages = await Promise.all(
        ASSOCIATE_TYPES.map((employmentType) =>
          governanceApi.associates({ ...params, limit: 100, offset: 0, employmentType }, signal),
        ),
      )
      const associates = pages
        .flatMap((page) => page.items)
        .sort((left, right) =>
          `${left.first_name} ${left.last_name}`.localeCompare(
            `${right.first_name} ${right.last_name}`,
          ),
        )
      return {
        count: pages.reduce((sum, page) => sum + page.count, 0),
        items: associates.slice((search.page - 1) * PAGE_SIZE, search.page * PAGE_SIZE),
      }
    },
    enabled: Boolean(session && canListSection),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: (previousData, previousQuery) =>
      previousQuery?.queryKey[4] === section ? previousData : undefined,
  })

  const saveMutation = useMutation({
    mutationFn: async ({
      section: target,
      id,
      payload,
    }: {
      section: Section
      id: number | null
      payload: Record<string, unknown>
    }) => {
      if (target === 'meetings')
        return id ? governanceApi.updateMeeting(id, payload) : governanceApi.createMeeting(payload)
      if (target === 'resolutions')
        return id
          ? governanceApi.updateResolution(id, payload)
          : governanceApi.createResolution(payload)
      if (target === 'investors')
        return id
          ? governanceApi.updateShareholder(id, payload)
          : governanceApi.createShareholder(payload)
      if (target === 'partners')
        return id ? governanceApi.updatePartner(id, payload) : governanceApi.createPartner(payload)
      throw new Error('Associate records are read-only from the Board page.')
    },
    onSuccess: async (_result, variables) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.lists(userId, employeeId, variables.section),
        }),
        ...(variables.id !== null
          ? [
              queryClient.invalidateQueries({
                queryKey: governanceQueryKeys.detail(
                  userId,
                  employeeId,
                  variables.section,
                  variables.id,
                ),
              }),
            ]
          : []),
      ])
      setEditor(null)
      showToast({
        title: editor?.record ? 'Record updated' : 'Record created',
        description: 'The Board record is up to date.',
        tone: 'success',
      })
    },
  })

  const resolutionActionMutation = useMutation<
    unknown,
    Error,
    { id: number; action: 'approve' | 'archive' }
  >({
    mutationFn: ({ id, action }) =>
      action === 'approve'
        ? governanceApi.approveResolution(id)
        : governanceApi.archiveResolution(id),
    onSuccess: async (_result, variables) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.lists(userId, employeeId, 'resolutions'),
        }),
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.detail(userId, employeeId, 'resolutions', variables.id),
        }),
      ])
      setConfirmation(null)
      showToast({
        title: variables.action === 'approve' ? 'Resolution approved' : 'Resolution archived',
        description: 'The resolution record is up to date.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Resolution could not be updated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const meetingCancelMutation = useMutation({
    mutationFn: (id: number) => governanceApi.cancelMeeting(id),
    onSuccess: async (_result, id) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.lists(userId, employeeId, 'meetings'),
        }),
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.detail(userId, employeeId, 'meetings', id),
        }),
      ])
      setConfirmation(null)
      showToast({
        title: 'Meeting cancelled',
        description: 'The meeting status has been updated.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Meeting could not be cancelled',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const partnerDeleteMutation = useMutation({
    mutationFn: (id: number) => governanceApi.deletePartner(id),
    onSuccess: async (_result, id) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.lists(userId, employeeId, 'partners'),
        }),
        queryClient.invalidateQueries({
          queryKey: governanceQueryKeys.detail(userId, employeeId, 'partners', id),
        }),
      ])
      setConfirmation(null)
      showToast({
        title: 'Partner removed',
        description: 'The partner and related agreements were deleted.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Partner could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })

  const updateSearch = useCallback(
    (value: string) => {
      void navigate({
        search: (previous: BoardSearch) => ({ ...previous, search: value, page: 1 }),
      })
    },
    [navigate],
  )
  const updateTab = (value: Section) =>
    void navigate({ search: (previous: BoardSearch) => ({ ...previous, tab: value, page: 1 }) })
  const firstAvailableSection = (Object.keys(SECTION_META) as Section[]).find((item) =>
    hasPermission(permissions, SECTION_META[item].resource, 'list'),
  )
  useEffect(() => {
    if (!session || canListSection || !firstAvailableSection) return
    void navigate({
      search: (previous: BoardSearch) => ({ ...previous, tab: firstAvailableSection, page: 1 }),
    })
  }, [canListSection, firstAvailableSection, navigate, session])
  const records = (listQuery.data?.items ?? []) as BoardRecord[]
  const total = listQuery.data?.count ?? 0
  const EmptyIcon = SECTION_META[section].icon
  const visibleSections = (Object.keys(SECTION_META) as Section[]).filter((item) =>
    hasPermission(permissions, SECTION_META[item].resource, 'list'),
  )
  const sectionNavigationColumns =
    {
      1: 'grid-cols-1 phone:grid-cols-1 tablet:grid-cols-1',
      2: 'grid-cols-2 phone:grid-cols-2 tablet:grid-cols-2',
      3: 'grid-cols-2 phone:grid-cols-3 tablet:grid-cols-3',
      4: 'grid-cols-2 phone:grid-cols-2 tablet:grid-cols-4',
      5: 'grid-cols-2 phone:grid-cols-3 tablet:grid-cols-5',
    }[visibleSections.length as 1 | 2 | 3 | 4 | 5] ?? 'grid-cols-1'
  const centerLastSectionOnCompactPhone =
    visibleSections.length > 1 && visibleSections.length % 2 === 1

  const saveRecord = async (
    target: Section,
    id: number | null,
    payload: Record<string, unknown>,
  ) => {
    await saveMutation.mutateAsync({ section: target, id, payload })
  }

  return (
    <PageLayout
      title="Board"
      subtitle="Manage Board meetings, resolutions, investors, associates, and partners."
    >
      <div className="space-y-5">
        <Card className="space-y-3 p-3">
          <nav
            aria-label="Board sections"
            className={`bg-surface-muted rounded-control grid w-full min-w-0 gap-1 p-1 ${sectionNavigationColumns}`}
          >
            {visibleSections.map((item) => {
              const MetaIcon = SECTION_META[item].icon
              const centerLastItem =
                centerLastSectionOnCompactPhone && item === visibleSections.at(-1)
              return (
                <button
                  key={item}
                  type="button"
                  aria-pressed={section === item}
                  onClick={() => updateTab(item)}
                  className={`rounded-control text-caption phone:px-3 flex min-h-10 min-w-0 items-center justify-center gap-2 px-2 font-semibold whitespace-nowrap transition-colors ${centerLastItem ? 'phone:col-span-1 phone:w-full phone:justify-self-stretch col-span-2 w-1/2 justify-self-center' : 'w-full'} ${section === item ? 'bg-primary text-text-on-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface/75'}`}
                >
                  <MetaIcon className="size-4" aria-hidden="true" />
                  {SECTION_META[item].label}
                </button>
              )
            })}
          </nav>
        </Card>

        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <h2 className="text-h2 font-semibold">{SECTION_META[section].label}</h2>
            </div>
            {canCreate && section !== 'associates' ? (
              <Button
                className="shrink-0"
                size="sm"
                onClick={() => setEditor({ section, record: null })}
                leadingIcon={<Plus className="size-4" aria-hidden="true" />}
              >
                New
              </Button>
            ) : null}
          </div>
          <BoardSearchControl key={search.search} search={search.search} onCommit={updateSearch} />
        </Card>

        {listQuery.isPending && !listQuery.data ? (
          <Card className="space-y-3 p-4">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} className="h-24" />
            ))}
          </Card>
        ) : null}
        {listQuery.isError && !listQuery.data ? (
          <SectionErrorState
            error={listQuery.error}
            title={`${SECTION_META[section].label} could not be loaded`}
            onRetry={() => void listQuery.refetch()}
          />
        ) : null}
        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" role="status">
            Saved records are shown, but the latest update could not be loaded.
          </Alert>
        ) : null}
        {listQuery.data && records.length === 0 ? (
          <Card>
            <EmptyState
              icon={<EmptyIcon className="size-5" aria-hidden="true" />}
              title={`No ${SECTION_META[section].label.toLowerCase()} found`}
              description={
                search.search
                  ? 'Try another search or clear the search field.'
                  : 'Records added to this section will appear here.'
              }
              action={
                canCreate && section !== 'associates' ? (
                  <Button
                    onClick={() => setEditor({ section, record: null })}
                    leadingIcon={<Plus className="size-4" aria-hidden="true" />}
                  >
                    Create first record
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : null}
        {records.length ? (
          <div className="space-y-3">
            {records.map((record) => (
              <RecordCard
                key={`${section}-${record.id}`}
                section={section}
                record={record}
                search={search}
                permissions={permissions}
                onEdit={() => setEditor({ section, record })}
                onPrimary={() => setConfirmation({ section, record, action: 'primary' })}
                onDelete={() => setConfirmation({ section, record, action: 'archive' })}
              />
            ))}
          </div>
        ) : null}
        {listQuery.data && total > PAGE_SIZE ? (
          <Card className="phone:flex-row phone:items-center phone:justify-between flex flex-col gap-3 p-3">
            <p className="text-caption text-text-secondary">
              Page {search.page} of {Math.max(1, Math.ceil(total / PAGE_SIZE))}
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={search.page <= 1}
                onClick={() =>
                  void navigate({
                    search: (previous: BoardSearch) => ({
                      ...previous,
                      page: Math.max(1, search.page - 1),
                    }),
                  })
                }
                leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={search.page >= Math.ceil(total / PAGE_SIZE)}
                onClick={() =>
                  void navigate({
                    search: (previous: BoardSearch) => ({ ...previous, page: search.page + 1 }),
                  })
                }
              >
                Next
                <ChevronRight className="size-4" aria-hidden="true" />
              </Button>
            </div>
          </Card>
        ) : null}

        {editor ? (
          <BoardRecordEditor
            section={editor.section}
            record={editor.record}
            userId={userId}
            employeeId={employeeId}
            permissions={permissions}
            saving={saveMutation.isPending}
            onClose={() => setEditor(null)}
            onSave={saveRecord}
          />
        ) : null}
        {confirmation ? (
          <ConfirmationDialog
            title={
              confirmation.action === 'archive'
                ? 'Archive resolution?'
                : confirmation.section === 'meetings'
                  ? 'Cancel this meeting?'
                  : confirmation.section === 'partners'
                    ? 'Delete this partner?'
                    : 'Approve this resolution?'
            }
            description={
              confirmation.action === 'archive'
                ? 'This moves the resolution to the archived state.'
                : confirmation.section === 'meetings'
                  ? 'The meeting record will remain available with cancelled status.'
                  : confirmation.section === 'partners'
                    ? 'This permanently removes the partner and its agreements.'
                    : 'This marks the resolution as approved in the Board register.'
            }
            confirmLabel={
              confirmation.action === 'archive'
                ? 'Archive resolution'
                : confirmation.section === 'meetings'
                  ? 'Cancel meeting'
                  : confirmation.section === 'partners'
                    ? 'Delete'
                    : 'Approve resolution'
            }
            danger={confirmation.action === 'primary' && confirmation.section === 'partners'}
            pending={
              resolutionActionMutation.isPending ||
              meetingCancelMutation.isPending ||
              partnerDeleteMutation.isPending
            }
            onCancel={() => setConfirmation(null)}
            onConfirm={() => {
              if (confirmation.section === 'meetings')
                meetingCancelMutation.mutate((confirmation.record as BoardMeetingDto).id)
              else if (confirmation.section === 'partners')
                partnerDeleteMutation.mutate((confirmation.record as PartnerDto).id)
              else if (confirmation.section === 'resolutions')
                resolutionActionMutation.mutate({
                  id: (confirmation.record as BoardResolutionDto).id,
                  action: confirmation.action === 'archive' ? 'archive' : 'approve',
                })
            }}
          />
        ) : null}
      </div>
    </PageLayout>
  )
}
