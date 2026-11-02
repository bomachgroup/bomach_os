import type { ReactNode } from 'react'
import {
  CalendarDays,
  Check,
  CheckCircle2,
  Download,
  FileText,
  Image as ImageIcon,
  MapPin,
  Music2,
  Pencil,
  Video,
  X,
} from 'lucide-react'

import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

export type ReportEvidenceItem = {
  id: string
  name: string
  detail: string
  href?: string
  mediaType?: string
  status?: 'ready' | 'uploading' | 'attached'
}

function lines(value: string | null | undefined): string[] {
  return (value ?? '')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
}

function formatReportDate(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function formatCompactReportDate(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function SummaryValue({
  icon,
  label,
  value,
  className,
}: {
  icon: ReactNode
  label: string
  value: ReactNode
  className?: string
}) {
  return (
    <div
      className={`rounded-control border-border-subtle bg-surface-muted/70 tablet:p-4 min-w-0 border p-3 ${className ?? ''}`}
    >
      <div className="flex items-center gap-2">
        <span className="text-primary bg-primary-subtle rounded-control flex size-8 shrink-0 items-center justify-center">
          {icon}
        </span>
        <dt className="text-caption text-text-secondary">{label}</dt>
      </div>
      <dd className="text-body-sm text-text-primary mt-2 font-semibold break-words">{value}</dd>
    </div>
  )
}

export function ReportOverviewSummary({
  day,
  hoursWorked,
  operationalBase,
  workTimeRange,
  status,
  onEdit,
}: {
  day: string
  hoursWorked: number
  operationalBase?: string | null
  workTimeRange?: string | null
  status?: { label: string; tone: StatusTone }
  onEdit?: () => void
}) {
  const metadata = [
    <SummaryValue
      key="date"
      icon={<CalendarDays className="size-4" aria-hidden="true" />}
      label="Report date"
      value={
        <>
          <span className="tablet:hidden">{formatCompactReportDate(day)}</span>
          <span className="tablet:inline hidden">{formatReportDate(day)}</span>
        </>
      }
    />,
    <SummaryValue
      key="hours"
      icon={<CheckCircle2 className="size-4" aria-hidden="true" />}
      label="Work hours"
      value={`${hoursWorked.toFixed(1)} hours${workTimeRange ? ` · ${workTimeRange}` : ''}`}
    />,
  ]
  if (operationalBase?.trim()) {
    metadata.push(
      <SummaryValue
        key="base"
        icon={<MapPin className="size-4" aria-hidden="true" />}
        label="Operational base"
        value={operationalBase.trim()}
        className="desktop:col-span-1 col-span-2"
      />,
    )
  }

  return (
    <Card className="tablet:p-5 space-y-4 p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex min-w-0 items-center gap-3">
          <span className="text-primary bg-primary-subtle rounded-surface flex size-10 shrink-0 items-center justify-center">
            <FileText className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <h2 className="text-h3 text-text-primary font-semibold">Report details</h2>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {status ? <StatusChip label={status.label} tone={status.tone} /> : null}
          {onEdit ? (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={onEdit}
              leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
            >
              Edit details
            </Button>
          ) : null}
        </div>
      </div>
      <dl
        className={`tablet:gap-3 grid grid-cols-2 gap-2.5 ${metadata.length === 3 ? 'desktop:grid-cols-3' : 'desktop:grid-cols-2'}`}
      >
        {metadata}
      </dl>
    </Card>
  )
}

function ContentSection({
  title,
  icon,
  onEdit,
  children,
}: {
  title: string
  icon: ReactNode
  onEdit?: () => void
  children: ReactNode
}) {
  return (
    <Card className="tablet:p-5 h-full space-y-4 p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex min-w-0 items-center gap-3">
          <span className="text-primary bg-primary-subtle rounded-control flex size-9 shrink-0 items-center justify-center">
            {icon}
          </span>
          <h3 className="text-label text-text-primary font-semibold">{title}</h3>
        </div>
        {onEdit ? (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={onEdit}
            leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
            aria-label={`Edit ${title.toLowerCase()}`}
          >
            Edit
          </Button>
        ) : null}
      </div>
      {children}
    </Card>
  )
}

function ContentList({ items }: { items: string[] }) {
  if (!items.length) return null
  return (
    <ul className="space-y-2">
      {items.map((item, index) => (
        <li
          key={`${index}-${item}`}
          className="rounded-control border-border-subtle bg-surface-muted/60 flex items-start gap-3 border px-3 py-2.5"
        >
          <span
            aria-hidden="true"
            className="bg-success-subtle text-success-foreground mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full"
          >
            <Check className="size-3" />
          </span>
          <span
            className="text-body-sm text-text-primary min-w-0 break-words whitespace-pre-wrap"
            style={{ overflowWrap: 'anywhere' }}
          >
            {item}
          </span>
        </li>
      ))}
    </ul>
  )
}

export function ReportContentSummary({
  workActivities,
  taskDetails,
  planNextDay,
  onEditActivities,
  onEditFollowUps,
}: {
  workActivities: string | null | undefined
  taskDetails: string | null | undefined
  planNextDay: string | null | undefined
  onEditActivities?: () => void
  onEditFollowUps?: () => void
}) {
  const activities = lines(workActivities)
  const challenges = lines(taskDetails)
  const nextSteps = lines(planNextDay)
  const hasFollowUps = challenges.length > 0 || nextSteps.length > 0

  return (
    <div
      className={`grid items-start gap-4 ${hasFollowUps ? 'desktop:grid-cols-2' : 'desktop:grid-cols-1'}`}
    >
      <ContentSection
        title="Work completed"
        icon={<CheckCircle2 className="size-4" aria-hidden="true" />}
        onEdit={onEditActivities}
      >
        <ContentList items={activities} />
      </ContentSection>
      {hasFollowUps ? (
        <ContentSection
          title="Challenges and next steps"
          icon={<CalendarDays className="size-4" aria-hidden="true" />}
          onEdit={onEditFollowUps}
        >
          <div className="space-y-4">
            {challenges.length ? (
              <section className="space-y-2">
                <h4 className="text-caption text-text-secondary font-semibold">Challenges</h4>
                <ContentList items={challenges} />
              </section>
            ) : null}
            {nextSteps.length ? (
              <section className="space-y-2">
                <h4 className="text-caption text-text-secondary font-semibold">Next workday</h4>
                <ContentList items={nextSteps} />
              </section>
            ) : null}
          </div>
        </ContentSection>
      ) : null}
    </div>
  )
}

function EvidenceIcon({ name, mediaType }: { name: string; mediaType?: string }) {
  const extension = name.toLowerCase().split('.').pop() ?? ''
  const type = (mediaType ?? '').toLowerCase()
  const className = 'size-4'
  if (type.startsWith('image/') || /^(png|jpe?g|gif|webp|avif|heic)$/.test(extension))
    return <ImageIcon className={className} aria-hidden="true" />
  if (type.startsWith('video/') || /^(mp4|mov|webm|m4v)$/.test(extension))
    return <Video className={className} aria-hidden="true" />
  if (type.startsWith('audio/') || /^(mp3|wav|m4a|aac|ogg)$/.test(extension))
    return <Music2 className={className} aria-hidden="true" />
  return <FileText className={className} aria-hidden="true" />
}

export function ReportEvidenceList({
  items,
  onRemove,
  previewImages = false,
}: {
  items: ReportEvidenceItem[]
  onRemove?: (id: string) => void
  previewImages?: boolean
}) {
  if (!items.length) return null

  return (
    <ul className="space-y-2">
      {items.map((item) => (
        <li
          key={item.id}
          className="rounded-control border-border-subtle bg-surface flex min-w-0 items-center gap-3 border p-3"
        >
          {previewImages && item.href && item.mediaType?.startsWith('image/') ? (
            <img
              src={item.href}
              alt=""
              loading="lazy"
              className="bg-surface-muted rounded-control size-12 shrink-0 object-cover"
            />
          ) : (
            <span className="text-primary bg-primary-subtle rounded-control flex size-10 shrink-0 items-center justify-center">
              <EvidenceIcon name={item.name} mediaType={item.mediaType} />
            </span>
          )}
          <div className="min-w-0 flex-1">
            {item.href ? (
              <a
                className="text-body-sm text-text-primary focus-visible:shadow-focus-ring block truncate font-semibold underline-offset-2 hover:underline focus-visible:outline-none"
                href={item.href}
                target="_blank"
                rel="noreferrer"
              >
                {item.name}
              </a>
            ) : (
              <p className="text-body-sm text-text-primary truncate font-semibold">{item.name}</p>
            )}
            <p className="text-caption text-text-secondary mt-0.5">
              {item.detail}
              {item.status
                ? ` · ${item.status === 'uploading' ? 'Uploading' : item.status === 'attached' ? 'Attached' : 'Ready to upload'}`
                : ''}
            </p>
          </div>
          {onRemove ? (
            <Button
              type="button"
              variant="ghost"
              size="icon"
              aria-label={`Remove ${item.name}`}
              onClick={() => onRemove(item.id)}
              className="text-text-secondary hover:text-danger size-9 shrink-0"
            >
              <X className="size-4" aria-hidden="true" />
            </Button>
          ) : item.href ? (
            <a
              className="text-primary focus-visible:shadow-focus-ring rounded-control hover:bg-surface-muted flex size-9 shrink-0 items-center justify-center focus-visible:outline-none"
              href={item.href}
              target="_blank"
              rel="noreferrer"
              aria-label={`Open ${item.name}`}
            >
              <Download className="size-4" aria-hidden="true" />
            </a>
          ) : null}
        </li>
      ))}
    </ul>
  )
}
