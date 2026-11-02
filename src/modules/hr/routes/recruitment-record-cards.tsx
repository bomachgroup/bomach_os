import { BriefcaseBusiness, ClipboardList, CircleUserRound, Pencil, Trash2 } from 'lucide-react'
import type { ReactNode } from 'react'

import { ApplicantRowActions } from '@/modules/hr/routes/applicant-row-actions'
import { Button } from '@/shared/ui/button'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import type {
  Applicant,
  ApplicantStatus,
  JobPostingListItem,
  JobPostingStatus,
} from '../recruitment.api'
import { RecruitmentRowActions, type RecruitmentMenuAction } from './recruitment-row-actions'

export function RecruitmentFact({
  label,
  value,
  fallback = 'Not provided',
  valueClassName = '',
}: {
  label: string
  value: ReactNode
  fallback?: string
  valueClassName?: string
}) {
  const isEmpty = value == null || value === ''
  return (
    <div className="min-w-0">
      <dt className="text-overline text-text-muted">{label}</dt>
      <dd
        className={`text-body-sm text-text-primary mt-1 font-medium break-words ${valueClassName}`}
      >
        {isEmpty ? fallback : value}
      </dd>
    </div>
  )
}

function readableStatus(status: string) {
  return status
    .split(/[\s_-]+/)
    .filter(Boolean)
    .map((part) => part[0].toUpperCase() + part.slice(1))
    .join(' ')
}

export function JobPostingCard({
  posting,
  branchName,
  departmentName,
  jobTypeLabel,
  dateLabel,
  statusTone,
  statusOptions,
  canView,
  canUpdate,
  canDelete,
  editLoading,
  editDisabled,
  statusSaving,
  onView,
  onEdit,
  onStatusChange,
  onDelete,
}: {
  posting: JobPostingListItem
  branchName: string
  departmentName: string
  jobTypeLabel: string
  dateLabel: (value: string | null | undefined) => string
  statusTone: (status: string) => StatusTone
  statusOptions: DropdownSelectOption[]
  canView: boolean
  canUpdate: boolean
  canDelete: boolean
  editLoading: boolean
  editDisabled: boolean
  statusSaving: boolean
  onView: () => void
  onEdit: () => void
  onStatusChange: (status: JobPostingStatus) => void
  onDelete: () => void
}) {
  const menuActions: RecruitmentMenuAction[] = [
    ...(canUpdate && canView
      ? [
          {
            id: 'edit',
            label: editLoading ? 'Loading job opening…' : 'Edit job opening',
            icon: Pencil,
            onSelect: onEdit,
            disabled: editLoading || editDisabled,
            className: 'tablet:hidden',
          },
        ]
      : []),
    ...(canUpdate
      ? statusOptions
          .filter((option) => option.value !== posting.status)
          .map((option) => ({
            id: `status-${option.value}`,
            label: `Set status to ${option.label}`,
            icon: ClipboardList,
            onSelect: () => onStatusChange(option.value as JobPostingStatus),
            disabled: statusSaving,
          }))
      : []),
    ...(canDelete
      ? [
          {
            id: 'delete',
            label: 'Delete job opening',
            icon: Trash2,
            onSelect: onDelete,
            danger: true,
          },
        ]
      : []),
  ]

  return (
    <article className="border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-sm rounded-control shadow-elevation-sm min-w-0 overflow-hidden border transition-colors">
      <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <BriefcaseBusiness className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <div className="min-w-0 flex-1 space-y-1">
              <h2 className="text-label text-text-primary font-semibold break-words">
                {posting.title}
              </h2>
              <p className="text-caption text-text-secondary break-words">{jobTypeLabel}</p>
            </div>
            <div className="flex shrink-0 flex-wrap items-center gap-2">
              <StatusChip
                label={readableStatus(posting.status)}
                tone={statusTone(posting.status)}
                dense
              />
            </div>
          </div>
        </div>
      </header>

      <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
        <RecruitmentFact label="Branch" value={branchName} />
        <RecruitmentFact label="Department" value={departmentName} />
        <RecruitmentFact
          label="Applicants"
          value={`${posting.applicantsCount} ${posting.applicantsCount === 1 ? 'applicant' : 'applicants'}`}
        />
        <RecruitmentFact label="Last updated" value={dateLabel(posting.updatedAt)} />
      </dl>

      <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
        <p className="text-overline text-text-muted min-w-0 break-all">
          Job opening ID · #{posting.id}
        </p>
        <div className="phone:justify-end flex min-w-0 flex-wrap items-center justify-end gap-2">
          {canView ? (
            <Button variant="outline" size="sm" onClick={onView}>
              Details
            </Button>
          ) : null}
          {canUpdate && canView ? (
            <Button
              variant="outline"
              size="sm"
              className="tablet:inline-flex hidden"
              onClick={onEdit}
              isLoading={editLoading}
              disabled={editDisabled}
            >
              Edit
            </Button>
          ) : null}
          <RecruitmentRowActions recordLabel={posting.title} actions={menuActions} />
        </div>
      </footer>
    </article>
  )
}

export function ApplicantCard({
  applicant,
  dateLabel,
  statusTone,
  canView,
  canUpdate,
  canChangeStatus,
  canDelete,
  editLoading,
  editDisabled,
  onView,
  onEdit,
  onStatusChange,
  onDelete,
}: {
  applicant: Applicant
  dateLabel: (value: string | null | undefined) => string
  statusTone: (status: string) => StatusTone
  canView: boolean
  canUpdate: boolean
  canChangeStatus: boolean
  canDelete: boolean
  editLoading: boolean
  editDisabled: boolean
  onView: () => void
  onEdit: () => void
  onStatusChange: (status: ApplicantStatus) => void
  onDelete: () => void
}) {
  const applicantName = `${applicant.firstName} ${applicant.lastName}`
  const experience =
    applicant.yearsOfExperience == null ? 'Not provided' : `${applicant.yearsOfExperience} years`

  return (
    <article className="border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-sm rounded-control shadow-elevation-sm min-w-0 overflow-hidden border transition-colors">
      <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <CircleUserRound className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <div className="min-w-0 flex-1 space-y-1">
              <h2 className="text-label text-text-primary font-semibold break-words">
                {applicantName}
              </h2>
              <p className="text-caption text-text-secondary break-words">
                {applicant.jobPosting.title}
              </p>
            </div>
            <StatusChip
              label={readableStatus(applicant.status)}
              tone={statusTone(applicant.status)}
              dense
              className="shrink-0"
            />
          </div>
        </div>
      </header>

      <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
        <RecruitmentFact label="Email" value={applicant.email} valueClassName="break-all" />
        <RecruitmentFact label="Phone" value={applicant.phone} />
        <RecruitmentFact label="Current role" value={applicant.currentJobTitle} />
        <RecruitmentFact label="Experience" value={experience} />
      </dl>

      <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
        <p className="text-overline text-text-muted flex min-w-0 flex-wrap items-center gap-x-1.5 gap-y-1 break-all">
          <span>Candidate ID · #{applicant.id}</span>
          <span aria-hidden="true">·</span>
          <span>Applied {dateLabel(applicant.createdAt)}</span>
        </p>
        <div className="phone:justify-end flex min-w-0 flex-wrap items-center justify-end gap-2">
          {canView ? (
            <Button variant="outline" size="sm" onClick={onView}>
              Profile
            </Button>
          ) : null}
          {canChangeStatus ? (
            <DropdownSelect
              aria-label={`Change ${applicantName} stage`}
              value={applicant.status}
              options={[
                { value: 'applied', label: 'Applied' },
                { value: 'shortlisted', label: 'Shortlisted' },
                { value: 'interviewed', label: 'Interviewed' },
                { value: 'offered', label: 'Offered' },
                { value: 'hired', label: 'Hired' },
                { value: 'rejected', label: 'Rejected' },
              ]}
              menuMinWidth={176}
              className="w-28 shrink-0"
              onChange={(value) => onStatusChange(value as ApplicantStatus)}
            />
          ) : null}
          <ApplicantRowActions
            applicantName={applicantName}
            canEdit={canUpdate && canView}
            canDelete={canDelete}
            editLoading={editLoading}
            editDisabled={editDisabled}
            onEdit={onEdit}
            onDelete={onDelete}
          />
        </div>
      </footer>
    </article>
  )
}
