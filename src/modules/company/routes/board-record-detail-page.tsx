import { useQuery } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowUpRight,
  CalendarDays,
  FileText,
  Handshake,
  UserRound,
  UsersRound,
} from 'lucide-react'
import type { ReactNode } from 'react'

import {
  governanceApi,
  governanceQueryKeys,
  type AssociateDetailDto,
  type BoardMeetingDto,
  type BoardResolutionDto,
  type PartnerDto,
  type ShareholderDto,
} from '@/modules/company/governance.api'
import { BOARD_SECTIONS, type BoardSection } from '@/modules/company/governance.search'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { BoardSearch } from '../governance.search'

type BoardRecordDetail =
  BoardMeetingDto | BoardResolutionDto | ShareholderDto | AssociateDetailDto | PartnerDto

const SECTION_META = {
  meetings: { label: 'Meeting', resource: 'meetings', icon: CalendarDays },
  resolutions: { label: 'Resolution', resource: 'board_resolutions', icon: FileText },
  investors: { label: 'Investor', resource: 'shareholders', icon: UsersRound },
  associates: { label: 'Associate', resource: 'employees', icon: UserRound },
  partners: { label: 'Partner', resource: 'partners', icon: Handshake },
} as const

function toneFor(value: string): StatusTone {
  const status = value.toLowerCase()
  if (['approved', 'completed', 'active'].includes(status)) return 'success'
  if (['pending', 'scheduled', 'ongoing'].includes(status)) return 'warning'
  if (['cancelled', 'archived', 'inactive'].includes(status)) return 'neutral'
  if (['postponed', 'draft', 'submitted'].includes(status)) return 'info'
  if (['rejected', 'expired'].includes(status)) return 'danger'
  return 'neutral'
}

function formatDate(value: string | null | undefined) {
  if (!value) return 'Not provided'
  const date = new Date(`${value.slice(0, 10)}T12:00:00`)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(date)
}

function DetailField({
  label,
  value,
  href,
}: {
  label: string
  value: string | number | null | undefined
  href?: string
}) {
  const content = value == null || value === '' ? 'Not provided' : String(value)
  return (
    <div className="border-border-subtle min-w-0 border-b py-3 first:pt-0 last:border-b-0 last:pb-0">
      <dt className="text-caption text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
        {href && content !== 'Not provided' ? (
          <a
            className="hover:text-primary underline-offset-2 hover:underline"
            href={href}
            rel="noreferrer"
          >
            {content}
          </a>
        ) : (
          content
        )}
      </dd>
    </div>
  )
}

function DetailSection({ title, children }: { title: string; children: ReactNode }) {
  return (
    <Card className="phone:p-5 min-w-0 p-4">
      <h2 className="text-label text-text-primary mb-4 font-semibold">{title}</h2>
      {children}
    </Card>
  )
}

function DetailGrid({ children }: { children: ReactNode }) {
  return <dl className="tablet:grid-cols-2 grid min-w-0 gap-x-8">{children}</dl>
}

function attachmentLink(url: string | null | undefined) {
  if (!url) return null
  try {
    const parsed = new URL(url, window.location.origin)
    if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') return null
    return parsed.href
  } catch {
    return null
  }
}

function AttachmentPanel({
  url,
  label,
  image = false,
}: {
  url: string | null | undefined
  label: string
  image?: boolean
}) {
  const href = attachmentLink(url)
  if (!href) {
    return (
      <div className="border-border-subtle bg-surface-muted/50 rounded-control flex min-h-20 items-center gap-3 border p-3">
        <span className="bg-surface text-text-muted rounded-control flex size-10 shrink-0 items-center justify-center">
          <FileText className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0">
          <p className="text-body-sm text-text-primary font-medium">
            No {label.toLowerCase()} attached
          </p>
          <p className="text-caption text-text-muted mt-0.5">An uploaded file will appear here.</p>
        </div>
      </div>
    )
  }

  const showImage = image || /\.(avif|gif|jpe?g|png|webp)(?:[?#]|$)/i.test(href)
  return (
    <div className="border-border-subtle bg-surface-muted/50 rounded-control min-w-0 overflow-hidden border">
      {showImage ? (
        <a href={href} target="_blank" rel="noreferrer" aria-label={`Open ${label}`}>
          <img
            className="bg-surface max-h-96 w-full object-contain"
            src={href}
            alt={label}
            loading="lazy"
            referrerPolicy="no-referrer"
          />
        </a>
      ) : null}
      <div className="flex min-w-0 flex-wrap items-center justify-between gap-3 p-3">
        <div className="flex min-w-0 items-center gap-3">
          <span className="bg-surface text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <FileText className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="text-body-sm text-text-primary font-medium">{label}</p>
            <p className="text-caption text-text-muted mt-0.5 break-all">Uploaded file</p>
          </div>
        </div>
        <a
          className="text-caption text-primary inline-flex min-h-9 items-center gap-2 font-semibold"
          href={href}
          target="_blank"
          rel="noreferrer"
        >
          Open file <ArrowUpRight className="size-3.5" aria-hidden="true" />
        </a>
      </div>
    </div>
  )
}

function recordTitle(section: BoardSection, record: BoardRecordDetail) {
  if (section === 'meetings' || section === 'resolutions') {
    return (record as BoardMeetingDto | BoardResolutionDto).title || 'Untitled record'
  }
  if (section === 'investors' || section === 'associates') {
    const person = record as ShareholderDto | AssociateDetailDto
    return `${person.first_name} ${person.last_name}`.trim() || 'Unnamed person'
  }
  return (record as PartnerDto).name || 'Unnamed partner'
}

function recordStatus(section: BoardSection, record: BoardRecordDetail) {
  if (section === 'investors' || section === 'associates') {
    return (record as ShareholderDto | AssociateDetailDto).is_active ? 'Active' : 'Inactive'
  }
  const statusRecord = record as BoardMeetingDto | BoardResolutionDto | PartnerDto
  return statusRecord.status_display || statusRecord.status
}

function recordIdentifier(section: BoardSection, record: BoardRecordDetail) {
  if (section === 'meetings') return (record as BoardMeetingDto).meeting_id
  if (section === 'resolutions') return (record as BoardResolutionDto).resolution_id
  if (section === 'investors') return (record as ShareholderDto).shareholder_id
  if (section === 'associates') return (record as AssociateDetailDto).employee_id
  const partner = record as PartnerDto
  return partner.code || `Partner ${partner.id}`
}

function loadRecord(section: BoardSection, id: number, signal: AbortSignal) {
  if (section === 'meetings') return governanceApi.meeting(id, signal)
  if (section === 'resolutions') return governanceApi.resolution(id, signal)
  if (section === 'investors') return governanceApi.shareholder(id, signal)
  if (section === 'associates') return governanceApi.associate(id, signal)
  return governanceApi.partner(id, signal)
}

export function BoardRecordDetailPage() {
  const params = useParams({ from: '/_protected/company/board/$section/$recordId' })
  const search = useSearch({
    from: '/_protected/company/board/$section/$recordId',
  }) as BoardSearch
  const navigate = useNavigate({ from: '/_protected/company/board/$section/$recordId' })
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const rawSection: string = params.section
  const section = BOARD_SECTIONS.includes(rawSection as BoardSection)
    ? (rawSection as BoardSection)
    : null
  const id = Number(params.recordId)
  const validId = Number.isSafeInteger(id) && id > 0
  const meta = SECTION_META[section ?? 'meetings']
  const canView = Boolean(meta && hasPermission(session?.permissions ?? {}, meta.resource, 'view'))
  const query = useQuery<BoardRecordDetail>({
    queryKey: governanceQueryKeys.detail(
      userId,
      employeeId,
      section ?? 'unknown',
      validId ? id : 0,
    ),
    queryFn: ({ signal }) => loadRecord(section as BoardSection, id, signal),
    enabled: Boolean(session && section && validId && canView),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const backLink = (
    <Link
      to="/company/board"
      search={{ ...search, tab: section ?? search.tab }}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>Board</PageBackLinkContent>
    </Link>
  )

  if (!section || !validId) {
    return (
      <PageLayout title="Board record not found" backLink={backLink}>
        <EmptyState
          title="This record link is invalid"
          description="Return to the Board register and open a record from its list."
          action={
            <Button
              variant="outline"
              onClick={() => void navigate({ to: '/company/board', search })}
            >
              Back to Board
            </Button>
          }
        />
      </PageLayout>
    )
  }

  if (!canView) {
    return (
      <PageLayout title={`${meta.label} details`} backLink={backLink}>
        <EmptyState
          title="You do not have access to these details"
          description="Your Board permissions do not include viewing this record."
        />
      </PageLayout>
    )
  }

  const record = query.data as BoardRecordDetail | undefined
  if (query.isPending && !record) {
    return (
      <PageLayout title={`${meta.label} details`} backLink={backLink}>
        <div className="space-y-4">
          <Skeleton className="h-28" />
          <Skeleton className="h-56" />
          <Skeleton className="h-40" />
        </div>
      </PageLayout>
    )
  }

  if (!record && query.error) {
    const notFound = query.error instanceof ApiError && query.error.status === 404
    return (
      <PageLayout
        title={notFound ? `${meta.label} not found` : `${meta.label} details`}
        backLink={backLink}
      >
        {notFound ? (
          <EmptyState
            title={`${meta.label} not found`}
            description="This record may have been removed or is outside your access scope."
            action={
              <Button
                variant="outline"
                onClick={() => void navigate({ to: '/company/board', search })}
              >
                Back to Board
              </Button>
            }
          />
        ) : (
          <ErrorState
            title={`${meta.label} details could not load`}
            description="Please check your connection and try loading these details again."
            action={
              <Button variant="outline" onClick={() => void query.refetch()}>
                Retry details
              </Button>
            }
          />
        )}
      </PageLayout>
    )
  }

  if (!record) return null

  const title = recordTitle(section, record)
  const status = recordStatus(section, record)
  const identifier = recordIdentifier(section, record)
  const MetaIcon = meta.icon
  const portrait =
    section === 'investors'
      ? (record as ShareholderDto).profile_picture
      : section === 'associates'
        ? (record as AssociateDetailDto).profile_picture
        : null

  return (
    <PageLayout
      title={title}
      backLink={backLink}
      actions={<StatusChip label={status} tone={toneFor(status)} />}
      actionsInline
    >
      <div className="space-y-5">
        {query.error ? (
          <Alert tone="warning" role="status">
            Saved details are shown, but the latest update could not be loaded.
          </Alert>
        ) : null}

        <Card className="overflow-hidden p-0">
          <div className="from-primary-subtle/70 via-surface to-surface phone:flex-row phone:items-center phone:p-5 flex min-w-0 flex-col gap-4 bg-gradient-to-r p-4">
            <span className="bg-surface text-primary border-primary/10 rounded-surface shadow-elevation-sm phone:size-14 flex size-12 shrink-0 items-center justify-center overflow-hidden border">
              {portrait ? (
                <img className="size-full object-cover" src={portrait} alt={`${title} portrait`} />
              ) : (
                <MetaIcon className="size-6" aria-hidden="true" />
              )}
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-caption text-primary font-semibold">{meta.label} profile</p>
              <p className="text-body-sm text-text-secondary mt-1 break-all">
                Record ID · {identifier}
              </p>
            </div>
            {section === 'investors' && (record as ShareholderDto).is_board_member ? (
              <StatusChip label="Board member" tone="info" dense />
            ) : null}
          </div>
        </Card>

        {section === 'meetings' ? <MeetingDetails record={record as BoardMeetingDto} /> : null}
        {section === 'resolutions' ? (
          <ResolutionDetails record={record as BoardResolutionDto} />
        ) : null}
        {section === 'investors' ? <InvestorDetails record={record as ShareholderDto} /> : null}
        {section === 'associates' ? (
          <AssociateDetails record={record as AssociateDetailDto} />
        ) : null}
        {section === 'partners' ? <PartnerDetails record={record as PartnerDto} /> : null}

        <div className="flex justify-start">
          <Button
            variant="outline"
            onClick={() =>
              void navigate({ to: '/company/board', search: { ...search, tab: section } })
            }
          >
            Back to {SECTION_META[section].label.toLowerCase()} list
          </Button>
        </div>
      </div>
    </PageLayout>
  )
}

function MeetingDetails({ record }: { record: BoardMeetingDto }) {
  return (
    <div className="desktop:grid-cols-2 phone:p-5 grid min-w-0 gap-4 p-4">
      <DetailSection title="Schedule and location">
        <DetailGrid>
          <DetailField label="Meeting date" value={formatDate(record.meeting_date)} />
          <DetailField label="Start time" value={record.meeting_time?.slice(0, 5)} />
          <DetailField
            label="Duration"
            value={record.duration_display || `${record.duration_minutes} minutes`}
          />
          <DetailField label="Location type" value={record.location_type_display} />
          <DetailField label="Location" value={record.location} />
          <DetailField label="Attendees" value={record.attendee_count} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Meeting ownership">
        <DetailGrid>
          <DetailField label="Organiser" value={record.organizer_name} />
          <DetailField label="Meeting reference" value={record.meeting_id} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Agenda">
        <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
          {record.agenda || 'No agenda has been added.'}
        </p>
      </DetailSection>
      <DetailSection title={`Attendees (${record.attendees?.length ?? 0})`}>
        {record.attendees?.length ? (
          <ul className="divide-border-subtle divide-y">
            {record.attendees.map((attendee) => (
              <li
                key={attendee.user_id}
                className="flex min-w-0 items-start gap-3 py-3 first:pt-0 last:pb-0"
              >
                <UsersRound className="text-text-muted mt-0.5 size-4 shrink-0" aria-hidden="true" />
                <div className="min-w-0">
                  <p className="text-body-sm text-text-primary font-medium">{attendee.full_name}</p>
                  <p className="text-caption text-text-secondary mt-0.5 break-all">
                    {attendee.email}
                  </p>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-body-sm text-text-muted">No attendees are listed.</p>
        )}
      </DetailSection>
      <DetailSection title="Meeting file">
        <AttachmentPanel url={record.file_url} label="Meeting file" />
      </DetailSection>
      {record.notes ? (
        <DetailSection title="Notes">
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {record.notes}
          </p>
        </DetailSection>
      ) : null}
    </div>
  )
}

function ResolutionDetails({ record }: { record: BoardResolutionDto }) {
  return (
    <div className="desktop:grid-cols-2 phone:p-5 grid min-w-0 gap-4 p-4">
      <DetailSection title="Resolution details">
        <DetailGrid>
          <DetailField label="Reference" value={record.resolution_id} />
          <DetailField label="Category" value={record.resolution_type_display} />
          <DetailField label="Resolution date" value={formatDate(record.resolution_date)} />
          <DetailField label="Status" value={record.status_display} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Approval history">
        <DetailGrid>
          <DetailField label="Prepared by" value={record.created_by_name} />
          <DetailField label="Approved by" value={record.approved_by_name} />
          <DetailField label="Approved on" value={formatDate(record.approved_at)} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Decision and rationale">
        <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
          {record.description || 'No decision description has been added.'}
        </p>
      </DetailSection>
      <DetailSection title="Supporting document">
        <AttachmentPanel url={record.attachment_url} label="Resolution attachment" />
      </DetailSection>
      {record.notes ? (
        <DetailSection title="Notes">
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {record.notes}
          </p>
        </DetailSection>
      ) : null}
    </div>
  )
}

function InvestorDetails({ record }: { record: ShareholderDto }) {
  return (
    <div className="desktop:grid-cols-2 phone:p-5 grid min-w-0 gap-4 p-4">
      <DetailSection title="Ownership">
        <DetailGrid>
          <DetailField label="Shareholder reference" value={record.shareholder_id} />
          <DetailField label="Position" value={record.title_display} />
          <DetailField label="Ownership" value={`${record.share_percentage}%`} />
          <DetailField label="Shares" value={record.share_count?.toLocaleString()} />
          <DetailField label="Board member" value={record.is_board_member ? 'Yes' : 'No'} />
          <DetailField label="Record status" value={record.is_active ? 'Active' : 'Inactive'} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Contact">
        <DetailGrid>
          <DetailField label="Email" value={record.email} href={`mailto:${record.email}`} />
          <DetailField
            label="Phone"
            value={record.phone_number}
            href={record.phone_number ? `tel:${record.phone_number}` : undefined}
          />
        </DetailGrid>
      </DetailSection>
      {record.notes ? (
        <DetailSection title="Notes">
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {record.notes}
          </p>
        </DetailSection>
      ) : null}
      <DetailSection title="Record history">
        <DetailGrid>
          <DetailField label="Added" value={formatDate(record.created_at)} />
          <DetailField label="Last updated" value={formatDate(record.updated_at)} />
        </DetailGrid>
      </DetailSection>
    </div>
  )
}

function AssociateDetails({ record }: { record: AssociateDetailDto }) {
  return (
    <div className="desktop:grid-cols-2 phone:p-5 grid min-w-0 gap-4 p-4">
      <DetailSection title="Employment">
        <DetailGrid>
          <DetailField label="Employee ID" value={record.employee_id} />
          <DetailField label="Designation" value={record.designation} />
          <DetailField label="Employment type" value={record.employment_type} />
          <DetailField label="Employment status" value={record.employment_status} />
          <DetailField label="Start date" value={formatDate(record.start_date)} />
          <DetailField label="Work schedule" value={record.work_schedule} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Team and location">
        <DetailGrid>
          <DetailField label="Department" value={record.department_name} />
          <DetailField
            label="Department units"
            value={record.department_units
              ?.map((unit) => unit.name)
              .filter(Boolean)
              .join(', ')}
          />
          <DetailField label="Branch" value={record.branch_name} />
          <DetailField label="Work location" value={record.location} />
          <DetailField
            label="City"
            value={[record.city, record.state, record.country].filter(Boolean).join(', ')}
          />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Work contact">
        <DetailGrid>
          <DetailField label="Work email" value={record.email} href={`mailto:${record.email}`} />
          <DetailField
            label="Phone"
            value={record.phone_number}
            href={record.phone_number ? `tel:${record.phone_number}` : undefined}
          />
          <DetailField label="Employee account" value={record.is_active ? 'Active' : 'Inactive'} />
        </DetailGrid>
      </DetailSection>
    </div>
  )
}

function PartnerDetails({ record }: { record: PartnerDto }) {
  return (
    <div className="desktop:grid-cols-2 phone:p-5 grid min-w-0 gap-4 p-4">
      <DetailSection title="Partner profile">
        <DetailGrid>
          <DetailField label="Partner code" value={record.code} />
          <DetailField label="Category" value={record.category_display} />
          <DetailField label="Status" value={record.status_display} />
          <DetailField label="KYC status" value={record.kyc_status_display} />
          <DetailField label="Commission rate" value={`${record.commission_rate}%`} />
          <DetailField label="Agreements" value={record.agreement_count} />
        </DetailGrid>
      </DetailSection>
      <DetailSection title="Contact and address">
        <DetailGrid>
          <DetailField label="Email" value={record.email} href={`mailto:${record.email}`} />
          <DetailField
            label="Phone"
            value={record.phone}
            href={record.phone ? `tel:${record.phone}` : undefined}
          />
          <div className="tablet:col-span-2">
            <DetailField label="Address" value={record.address} />
          </div>
        </DetailGrid>
      </DetailSection>
      {record.notes ? (
        <DetailSection title="Notes">
          <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
            {record.notes}
          </p>
        </DetailSection>
      ) : null}
      <DetailSection title="Record history">
        <DetailGrid>
          <DetailField label="Added" value={formatDate(record.created_at)} />
          <DetailField label="Last updated" value={formatDate(record.updated_at)} />
        </DetailGrid>
      </DetailSection>
    </div>
  )
}
