import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Banknote,
  BriefcaseBusiness,
  Building2,
  CalendarDays,
  CalendarClock,
  Check,
  ChevronLeft,
  ChevronRight,
  CircleUserRound,
  ClipboardList,
  ExternalLink,
  FilePlus2,
  FileText,
  MapPin,
  Search,
  Users,
  X,
} from 'lucide-react'
import { useState, type FormEvent, type ReactNode } from 'react'

import { branchesApi } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import { hrOverviewQueryKey } from '@/modules/hr/hr-dashboard.api'
import { employeesApi, employeesQueryKeys, type EmployeeDto } from '@/modules/hr/employees.api'
import { authSessionQueryOptions, hasPermission, type PermissionSet } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import {
  recruitmentApi,
  type Applicant,
  type ApplicantInput,
  type ApplicantStatus,
  type InterviewInput,
  type OfferLetterInput,
  type JobPosting,
  type JobPostingInput,
  type JobPostingListItem,
  type JobPostingStatus,
} from '../recruitment.api'
import {
  applicantListQueryOptions,
  applicantQueryOptions,
  jobPostingListQueryOptions,
  jobPostingQueryOptions,
  jobPostingSummaryQueryOptions,
  recruitmentQueryKeys,
} from '../recruitment.queries'
import { postingDepartmentOptions } from '../recruitment-department-options'
import { hasRecruitmentFilters, type RecruitmentSearch } from '../recruitment.search'
import { ApplicantFormDialog } from './applicant-form-dialog'
import { ApplicantWorkflowFormDialog } from './applicant-workflow-form-dialog'
import { JobPostingFormDialog } from './job-posting-form-dialog'
import { ApplicantCard, JobPostingCard, RecruitmentFact } from './recruitment-record-cards'
import { formatRecruitmentMoney } from './recruitment-presentation'

const JOB_TYPES: Record<string, string> = {
  full_time: 'Full-time',
  part_time: 'Part-time',
  contract: 'Contract',
  internship: 'Internship',
  temporary: 'Temporary',
}
const APPLICANT_STATUSES: Array<{ value: ApplicantStatus; label: string }> = [
  { value: 'applied', label: 'Applied' },
  { value: 'shortlisted', label: 'Shortlisted' },
  { value: 'interviewed', label: 'Interviewed' },
  { value: 'offered', label: 'Offered' },
  { value: 'hired', label: 'Hired' },
  { value: 'rejected', label: 'Rejected' },
]
const POSTING_STATUSES: DropdownSelectOption[] = [
  { value: 'draft', label: 'Draft' },
  { value: 'pending', label: 'Pending' },
  { value: 'active', label: 'Active' },
  { value: 'closed', label: 'Closed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const PAGE_SIZES = [10, 20, 50] as const

function dateLabel(value: string | null | undefined) {
  if (!value) return 'No deadline'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(date)
}

function dateTimeLabel(value: string | null | undefined) {
  if (!value) return 'Not scheduled'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(date)
}

function statusTone(status: string): StatusTone {
  if (status === 'active' || status === 'hired') return 'success'
  if (status === 'pending' || status === 'shortlisted' || status === 'interviewed') return 'info'
  if (status === 'rejected' || status === 'cancelled') return 'danger'
  if (status === 'offered') return 'primary'
  return 'neutral'
}

function employeeName(employee: EmployeeDto) {
  return [employee.first_name, employee.middle_name, employee.last_name].filter(Boolean).join(' ')
}

function interviewerLabel(employeeId: number, employees: EmployeeDto[] | undefined) {
  const employee = employees?.find((item) => item.id === employeeId)
  return employee
    ? `${employeeName(employee)} · ${employee.employee_id}`
    : `Employee #${employeeId}`
}

function Metric({
  icon,
  label,
  value,
  accent,
  className = '',
}: {
  icon: ReactNode
  label: string
  value: number
  accent: string
  className?: string
}) {
  return (
    <Card className={`flex min-w-0 items-center gap-3 p-3.5 ${className}`}>
      <span
        className={`bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center ${accent}`}
      >
        {icon}
      </span>
      <span className="min-w-0">
        <span className="text-h3 text-text-primary block font-semibold tabular-nums">{value}</span>
        <span className="text-caption text-text-secondary block truncate">{label}</span>
      </span>
    </Card>
  )
}

function PostingDetailFact({
  icon,
  label,
  value,
}: {
  icon: ReactNode
  label: string
  value: string
}) {
  return (
    <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3">
      <dt className="text-caption text-text-secondary flex items-center gap-1.5">
        <span aria-hidden="true" className="text-primary">
          {icon}
        </span>
        {label}
      </dt>
      <dd className="text-body-sm text-text-primary mt-1.5 font-semibold break-words">{value}</dd>
    </div>
  )
}

export function PostingDetails({
  posting,
  branches,
  departments,
  onClose,
}: {
  posting: JobPosting | null
  branches: Array<{ value: string; label: string }>
  departments: Array<{ value: string; label: string }>
  onClose: () => void
}) {
  const department = posting?.departmentId
    ? (departments.find((item) => item.value === String(posting.departmentId))?.label ??
      `Department #${posting.departmentId}`)
    : 'Not assigned'
  const branch = posting
    ? (branches.find((item) => item.value === String(posting.branchId))?.label ??
      `Branch #${posting.branchId}`)
    : ''
  const minSalary = posting?.salaryMin?.trim() ? formatRecruitmentMoney(posting.salaryMin) : null
  const maxSalary = posting?.salaryMax?.trim() ? formatRecruitmentMoney(posting.salaryMax) : null
  const salaryRange =
    minSalary && maxSalary
      ? `${minSalary} – ${maxSalary}`
      : minSalary
        ? `From ${minSalary}`
        : maxSalary
          ? `Up to ${maxSalary}`
          : 'Not specified'
  const roleSections = posting
    ? [
        { label: 'Position summary', value: posting.description },
        { label: 'Responsibilities', value: posting.responsibilities },
        { label: 'Requirements', value: posting.requirements },
      ].filter((section) => section.value.trim())
    : []

  return (
    <Dialog
      open={Boolean(posting)}
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
      title={posting?.title ?? 'Job posting'}
      description="Position overview, compensation and hiring timeline."
      size="lg"
      fitContent
      compactOnMobile
      bodyClassName="space-y-4"
      footer={
        <Button variant="outline" onClick={onClose}>
          Close
        </Button>
      }
    >
      {posting ? (
        <div className="space-y-4">
          <div className="from-primary-subtle/65 via-primary-subtle/25 to-surface border-border-subtle rounded-surface tablet:grid-cols-3 grid grid-cols-1 items-center gap-3 border bg-gradient-to-r p-3">
            <div className="flex min-w-0 items-center gap-2">
              <span className="bg-surface text-primary rounded-control flex size-9 shrink-0 items-center justify-center shadow-sm">
                <BriefcaseBusiness className="size-4.5" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-text-secondary mb-1">Posting status</p>
                <StatusChip
                  dense
                  label={
                    POSTING_STATUSES.find((option) => option.value === posting.status)?.label ??
                    posting.status.replaceAll('_', ' ')
                  }
                  tone={statusTone(posting.status)}
                />
              </div>
            </div>
            <div className="min-w-0">
              <p className="text-overline text-text-secondary mb-1">Employment type</p>
              <StatusChip
                dense
                label={JOB_TYPES[posting.jobType] ?? posting.jobType.replaceAll('_', ' ')}
                tone="neutral"
              />
            </div>
            <div className="flex min-w-0 items-center gap-2">
              <span className="bg-surface text-primary rounded-control flex size-9 shrink-0 items-center justify-center shadow-sm">
                <Users className="size-4" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-text-secondary mb-1">Candidate pipeline</p>
                <p className="text-body-sm text-text-primary font-semibold">
                  {posting.applicantsCount}{' '}
                  {posting.applicantsCount === 1 ? 'applicant' : 'applicants'}
                </p>
              </div>
            </div>
          </div>
          <section aria-labelledby="job-posting-facts-heading">
            <h3
              id="job-posting-facts-heading"
              className="text-label text-text-primary flex items-center gap-2 font-semibold"
            >
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <ClipboardList className="size-4" />
              </span>
              Position overview
            </h3>
            <dl className="tablet:grid-cols-3 phone:grid-cols-2 mt-2.5 grid grid-cols-1 gap-2.5">
              <PostingDetailFact
                icon={<Building2 className="size-3.5" />}
                label="Department"
                value={department}
              />
              <PostingDetailFact
                icon={<MapPin className="size-3.5" />}
                label="Branch"
                value={branch}
              />
              <PostingDetailFact
                icon={<Banknote className="size-3.5" />}
                label="Salary range"
                value={salaryRange}
              />
              <PostingDetailFact
                icon={<BriefcaseBusiness className="size-3.5" />}
                label="Open positions"
                value={
                  posting.vacancyCount > 0
                    ? `${posting.vacancyCount} ${posting.vacancyCount === 1 ? 'position' : 'positions'}`
                    : 'Not specified'
                }
              />
              <PostingDetailFact
                icon={<CalendarDays className="size-3.5" />}
                label="Application deadline"
                value={dateLabel(posting.deadline)}
              />
              <PostingDetailFact
                icon={<CalendarClock className="size-3.5" />}
                label="Created"
                value={dateLabel(posting.createdAt)}
              />
            </dl>
          </section>
          <section className="border-border-subtle rounded-control border p-3.5">
            <h3 className="text-label text-text-primary flex items-center gap-2 font-semibold">
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <FileText className="size-4" />
              </span>
              Role details
            </h3>
            {roleSections.length ? (
              <div className="mt-3 space-y-3">
                {roleSections.map((section, index) => (
                  <div
                    key={section.label}
                    className={index ? 'border-border-subtle border-t pt-3' : ''}
                  >
                    <h4 className="text-caption text-text-primary font-semibold">
                      {section.label}
                    </h4>
                    <p className="text-body-sm text-text-secondary mt-1 break-words whitespace-pre-wrap">
                      {section.value}
                    </p>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-body-sm text-text-secondary mt-2">
                No role details have been added.
              </p>
            )}
          </section>
        </div>
      ) : null}
    </Dialog>
  )
}

function ApplicantDetails({
  applicant,
  onClose,
  onStatusChange,
  canUpdate,
  saving,
  userId,
  employeeId,
  permissions,
  onWorkflowSaved,
}: {
  applicant: Applicant | null
  onClose: () => void
  onStatusChange: (status: ApplicantStatus) => void
  canUpdate: boolean
  saving: boolean
  userId: number
  employeeId: string
  permissions: PermissionSet
  onWorkflowSaved: () => Promise<void>
}) {
  const [tab, setTab] = useState<'profile' | 'interviews' | 'offers'>('profile')
  const [interviewFormOpen, setInterviewFormOpen] = useState(false)
  const [offerFormOpen, setOfferFormOpen] = useState(false)
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const canListInterviews = hasPermission(permissions, 'interviews', 'list')
  const canCreateInterview = hasPermission(permissions, 'interviews', 'create')
  const canListOffers = hasPermission(permissions, 'offer_letters', 'list')
  const canCreateOffer = hasPermission(permissions, 'offer_letters', 'create')
  const canListEmployees = hasPermission(permissions, 'employees', 'list')
  const interviewerParams = {
    limit: 500,
    offset: 0,
    search: '',
    view: 'active' as const,
    branchId: 'all',
    departmentId: 'all',
  }
  const interviewersQuery = useQuery({
    queryKey: employeesQueryKeys.list(userId, employeeId, interviewerParams),
    queryFn: ({ signal }) => employeesApi.list(interviewerParams, signal),
    enabled: canListEmployees && (interviewFormOpen || (tab === 'interviews' && canListInterviews)),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const interviewsQuery = useQuery({
    queryKey: ['hr', 'recruitment', userId, employeeId, 'interviews', applicant?.id ?? 0],
    queryFn: ({ signal }) => recruitmentApi.interviews(applicant!.id, signal),
    enabled: Boolean(applicant && tab === 'interviews' && canListInterviews),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const offersQuery = useQuery({
    queryKey: ['hr', 'recruitment', userId, employeeId, 'offers', applicant?.id ?? 0],
    queryFn: ({ signal }) => recruitmentApi.offerLetters(applicant!.id, signal),
    enabled: Boolean(applicant && tab === 'offers' && canListOffers),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const interviewMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: InterviewInput }) =>
      recruitmentApi.scheduleInterview(id, input),
  })
  const offerMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: OfferLetterInput }) =>
      recruitmentApi.createOfferLetter(id, input),
  })

  async function saveInterview(input: InterviewInput | OfferLetterInput) {
    if (!applicant || !('interviewer_id' in input)) return
    await interviewMutation.mutateAsync({ id: applicant.id, input })
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: ['hr', 'recruitment', userId, employeeId, 'interviews', applicant.id],
      }),
      onWorkflowSaved(),
    ])
    setInterviewFormOpen(false)
    showToast({
      title: 'Interview scheduled',
      description: 'The candidate’s pipeline and interview details were updated.',
      tone: 'success',
    })
  }
  async function saveOffer(input: InterviewInput | OfferLetterInput) {
    if (!applicant || !('annual_salary' in input)) return
    await offerMutation.mutateAsync({ id: applicant.id, input })
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: ['hr', 'recruitment', userId, employeeId, 'offers', applicant.id],
      }),
      onWorkflowSaved(),
    ])
    setOfferFormOpen(false)
    showToast({
      title: 'Offer letter created',
      description: 'The letter was sent and the candidate moved to Offered.',
      tone: 'success',
    })
  }

  const availableTabs = [
    { value: 'profile' as const, label: 'Profile', icon: CircleUserRound },
    ...(canListInterviews || canCreateInterview
      ? [{ value: 'interviews' as const, label: 'Interviews', icon: CalendarClock }]
      : []),
    ...(canListOffers || canCreateOffer
      ? [{ value: 'offers' as const, label: 'Offer letters', icon: FileText }]
      : []),
  ]

  return (
    <>
      <Dialog
        open={Boolean(applicant)}
        onOpenChange={(open) => {
          if (!open) onClose()
        }}
        title="Candidate profile"
        description="Review candidate details, interviews, and offers."
        size="lg"
        footer={
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
        }
      >
        {applicant ? (
          <div className="space-y-5">
            <section className="from-primary-subtle/70 via-surface-muted to-surface border-border-subtle rounded-surface tablet:p-5 grid gap-4 border bg-gradient-to-br p-4">
              <div className="flex min-w-0 items-start gap-3">
                <span className="bg-surface text-primary border-border-subtle shadow-elevation-sm flex size-12 shrink-0 items-center justify-center rounded-2xl border">
                  <CircleUserRound className="size-6" />
                </span>
                <div className="min-w-0 flex-1">
                  <p className="text-overline text-primary mb-1">Candidate #{applicant.id}</p>
                  <div className="flex min-w-0 flex-wrap items-center gap-2">
                    <h3 className="text-h3 text-text-primary min-w-0 font-semibold break-words">
                      {applicant.firstName} {applicant.lastName}
                    </h3>
                    <StatusChip
                      label={applicant.status}
                      tone={statusTone(applicant.status)}
                      dense
                    />
                  </div>
                  <p className="text-body-sm text-text-secondary mt-1 break-words">
                    {applicant.jobPosting.title}
                  </p>
                </div>
              </div>
              <dl className="border-border-subtle phone:grid-cols-2 grid min-w-0 gap-x-5 gap-y-3 border-t pt-3">
                <RecruitmentFact label="Email" value={applicant.email} valueClassName="break-all" />
                <RecruitmentFact label="Phone" value={applicant.phone} />
                <RecruitmentFact label="Applied" value={dateLabel(applicant.createdAt)} />
              </dl>
            </section>
            <nav
              aria-label="Candidate details"
              className="bg-surface-muted rounded-control phone:grid-cols-3 grid grid-cols-2 gap-1 p-1"
            >
              {availableTabs.map(({ value, label, icon: Icon }) => (
                <button
                  key={value}
                  type="button"
                  aria-pressed={tab === value}
                  onClick={() => setTab(value)}
                  className={`focus-visible:shadow-focus-ring rounded-control text-caption flex min-h-10 min-w-0 items-center justify-center gap-2 px-2 font-semibold focus-visible:outline-none ${tab === value ? 'bg-surface text-text-primary shadow-elevation-sm' : 'text-text-secondary hover:text-text-primary'}`}
                >
                  <Icon className="size-4 shrink-0" />
                  <span className="truncate">{label}</span>
                </button>
              ))}
            </nav>
            {tab === 'profile' ? (
              <div className="space-y-5">
                <section className="space-y-3">
                  <div className="phone:flex-row phone:items-end flex flex-col justify-between gap-3">
                    <div>
                      <h3 className="text-label text-text-primary font-semibold">
                        Candidate overview
                      </h3>
                      <p className="text-caption text-text-secondary mt-1">
                        Professional background and application details.
                      </p>
                    </div>
                    {canUpdate ? (
                      <div className="phone:w-64 w-full shrink-0">
                        <FormControl id="candidate-detail-status" label="Pipeline status">
                          <DropdownSelect
                            value={applicant.status}
                            options={APPLICANT_STATUSES}
                            disabled={saving}
                            onChange={(value) => onStatusChange(value as ApplicantStatus)}
                          />
                        </FormControl>
                      </div>
                    ) : null}
                  </div>
                  <dl className="bg-surface-muted border-border-subtle rounded-control phone:grid-cols-2 grid gap-x-5 gap-y-4 border p-4">
                    <RecruitmentFact label="Current role" value={applicant.currentJobTitle} />
                    <RecruitmentFact
                      label="Experience"
                      value={
                        applicant.yearsOfExperience == null
                          ? null
                          : `${applicant.yearsOfExperience} years`
                      }
                    />
                    <RecruitmentFact
                      label="Education"
                      value={
                        [applicant.highestEducation, applicant.institutionName]
                          .filter(Boolean)
                          .join(' · ') || null
                      }
                    />
                    <RecruitmentFact
                      label="Expected salary"
                      value={formatRecruitmentMoney(applicant.expectedSalary)}
                    />
                    <RecruitmentFact
                      label="Source"
                      value={applicant.source}
                      fallback="Not recorded"
                    />
                    <RecruitmentFact label="Address" value={applicant.address} />
                  </dl>
                </section>
                {applicant.resume ? (
                  <a
                    href={applicant.resume}
                    target="_blank"
                    rel="noreferrer"
                    className="text-primary text-body-sm inline-flex items-center gap-2 font-medium underline underline-offset-4"
                  >
                    Open resume <ExternalLink className="size-4" />
                  </a>
                ) : (
                  <p className="text-caption text-text-muted">No resume link provided.</p>
                )}
                {applicant.coverLetter ? (
                  <section>
                    <h3 className="text-label text-text-primary font-semibold">Cover letter</h3>
                    <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
                      {applicant.coverLetter}
                    </p>
                  </section>
                ) : null}
                {applicant.notes ? (
                  <section>
                    <h3 className="text-label text-text-primary font-semibold">Internal notes</h3>
                    <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
                      {applicant.notes}
                    </p>
                  </section>
                ) : null}
              </div>
            ) : null}
            {tab === 'interviews' ? (
              <section className="space-y-4">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div>
                    <h3 className="text-label text-text-primary font-semibold">
                      Interview schedule
                    </h3>
                    <p className="text-caption text-text-secondary mt-1">
                      Appointments and recorded feedback for this candidate.
                    </p>
                  </div>
                  {canCreateInterview ? (
                    <Button
                      size="sm"
                      leadingIcon={<CalendarClock className="size-4" />}
                      onClick={() => setInterviewFormOpen(true)}
                    >
                      Schedule interview
                    </Button>
                  ) : null}
                </div>
                {!canListInterviews ? (
                  <Alert tone="info" title="Interview history is restricted">
                    You may schedule interviews, but your account cannot list previous records.
                  </Alert>
                ) : interviewsQuery.isPending ? (
                  <Card className="space-y-3" aria-busy="true">
                    {Array.from({ length: 2 }, (_, index) => (
                      <Skeleton key={index} variant="row" />
                    ))}
                  </Card>
                ) : interviewsQuery.isError ? (
                  <Alert tone="warning" title="Interview history unavailable">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <span>{presentError(interviewsQuery.error, 'page-load').message}</span>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => void interviewsQuery.refetch()}
                      >
                        Retry
                      </Button>
                    </div>
                  </Alert>
                ) : interviewsQuery.data?.items.length ? (
                  <div className="space-y-3">
                    {interviewsQuery.data.items.map((interview) => (
                      <article
                        key={interview.id}
                        className="border-border-subtle bg-surface rounded-control min-w-0 overflow-hidden border"
                      >
                        <header className="phone:p-4 flex min-w-0 items-start gap-3 p-3">
                          <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                            <CalendarClock className="size-4" aria-hidden="true" />
                          </span>
                          <div className="flex min-w-0 flex-1 flex-wrap items-start justify-between gap-2">
                            <div className="min-w-0">
                              <h4 className="text-body-sm text-text-primary font-semibold">
                                Interview · {dateLabel(interview.scheduledAt)}
                              </h4>
                              <p className="text-caption text-text-secondary mt-1 break-words">
                                {interviewerLabel(
                                  interview.interviewerId,
                                  interviewersQuery.data?.items,
                                )}
                              </p>
                            </div>
                            <StatusChip
                              label={interview.status.replaceAll('_', ' ')}
                              tone={statusTone(interview.status)}
                              dense
                            />
                          </div>
                        </header>
                        <dl className="border-border-subtle phone:grid-cols-2 grid min-w-0 gap-x-4 gap-y-3 border-t px-4 py-3">
                          <RecruitmentFact
                            label="Scheduled for"
                            value={dateTimeLabel(interview.scheduledAt)}
                          />
                          <RecruitmentFact
                            label="Meeting link"
                            value={
                              interview.meetingLink ? (
                                <a
                                  href={interview.meetingLink}
                                  target="_blank"
                                  rel="noreferrer"
                                  className="text-primary inline-flex items-center gap-1 underline underline-offset-4"
                                >
                                  Open meeting link <ExternalLink className="size-3.5" />
                                </a>
                              ) : null
                            }
                          />
                        </dl>
                        {interview.feedback ? (
                          <div className="border-border-subtle border-t px-4 py-3">
                            <p className="text-overline text-text-muted">Feedback</p>
                            <p className="text-body-sm text-text-secondary mt-1 break-words whitespace-pre-wrap">
                              {interview.feedback}
                            </p>
                          </div>
                        ) : null}
                        <footer className="border-border-subtle text-overline text-text-muted border-t px-4 py-2.5">
                          Interview ID · #{interview.id}
                        </footer>
                      </article>
                    ))}
                  </div>
                ) : (
                  <EmptyState
                    icon={<CalendarClock className="size-5" />}
                    title="No interviews scheduled"
                    description="Schedule an interview to keep this candidate moving forward."
                    action={
                      canCreateInterview ? (
                        <Button size="sm" onClick={() => setInterviewFormOpen(true)}>
                          Schedule interview
                        </Button>
                      ) : undefined
                    }
                  />
                )}
              </section>
            ) : null}
            {tab === 'offers' ? (
              <section className="space-y-4">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div>
                    <h3 className="text-label text-text-primary font-semibold">Offer letters</h3>
                    <p className="text-caption text-text-secondary mt-1">
                      Offers issued to this candidate.
                    </p>
                  </div>
                  {canCreateOffer ? (
                    <Button
                      size="sm"
                      leadingIcon={<FileText className="size-4" />}
                      onClick={() => setOfferFormOpen(true)}
                    >
                      Create offer letter
                    </Button>
                  ) : null}
                </div>
                {!canListOffers ? (
                  <Alert tone="info" title="Offer history is restricted">
                    You may create an offer, but your account cannot list previous letters.
                  </Alert>
                ) : offersQuery.isPending ? (
                  <Card className="space-y-3" aria-busy="true">
                    {Array.from({ length: 2 }, (_, index) => (
                      <Skeleton key={index} variant="row" />
                    ))}
                  </Card>
                ) : offersQuery.isError ? (
                  <Alert tone="warning" title="Offer history unavailable">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <span>{presentError(offersQuery.error, 'page-load').message}</span>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => void offersQuery.refetch()}
                      >
                        Retry
                      </Button>
                    </div>
                  </Alert>
                ) : offersQuery.data?.items.length ? (
                  <div className="space-y-3">
                    {offersQuery.data.items.map((offer) => (
                      <article
                        key={offer.id}
                        className="border-border-subtle bg-surface rounded-control min-w-0 overflow-hidden border"
                      >
                        <header className="phone:p-4 flex min-w-0 items-start gap-3 p-3">
                          <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                            <FileText className="size-4" aria-hidden="true" />
                          </span>
                          <div className="flex min-w-0 flex-1 flex-wrap items-start justify-between gap-2">
                            <div className="min-w-0">
                              <h4 className="text-body-sm text-text-primary font-semibold break-words capitalize">
                                {offer.template.replaceAll('_', ' ')}
                              </h4>
                              <p className="text-caption text-text-secondary mt-1">
                                Offer prepared for {applicant.firstName} {applicant.lastName}
                              </p>
                            </div>
                            <StatusChip
                              label={offer.status}
                              tone={statusTone(offer.status)}
                              dense
                            />
                          </div>
                        </header>
                        <dl className="border-border-subtle phone:grid-cols-2 grid min-w-0 gap-x-4 gap-y-3 border-t px-4 py-3">
                          <RecruitmentFact
                            label="Annual salary"
                            value={formatRecruitmentMoney(offer.annualSalary)}
                          />
                          <RecruitmentFact label="Start date" value={dateLabel(offer.startDate)} />
                        </dl>
                        <footer className="border-border-subtle text-overline text-text-muted border-t px-4 py-2.5">
                          Offer ID · #{offer.id}
                        </footer>
                      </article>
                    ))}
                  </div>
                ) : (
                  <EmptyState
                    icon={<FileText className="size-5" />}
                    title="No offer letters yet"
                    description="Create an offer letter once the candidate is ready to move forward."
                    action={
                      canCreateOffer ? (
                        <Button size="sm" onClick={() => setOfferFormOpen(true)}>
                          Create offer letter
                        </Button>
                      ) : undefined
                    }
                  />
                )}
              </section>
            ) : null}
          </div>
        ) : null}
      </Dialog>
      {interviewFormOpen ? (
        <ApplicantWorkflowFormDialog
          mode="interview"
          open
          onOpenChange={setInterviewFormOpen}
          saving={interviewMutation.isPending}
          onSave={saveInterview}
          interviewers={interviewersQuery.data?.items ?? []}
          interviewersLoading={interviewersQuery.isPending}
          interviewersError={
            interviewersQuery.isError
              ? presentError(interviewersQuery.error, 'page-load').message
              : undefined
          }
          canListInterviewers={canListEmployees}
          onRetryInterviewers={() => void interviewersQuery.refetch()}
        />
      ) : null}
      {offerFormOpen ? (
        <ApplicantWorkflowFormDialog
          mode="offer"
          open
          onOpenChange={setOfferFormOpen}
          saving={offerMutation.isPending}
          onSave={saveOffer}
        />
      ) : null}
    </>
  )
}

export function RecruitmentPage() {
  const search = useSearch({ from: '/_protected/hr/job-post' }) as RecruitmentSearch
  const navigate = useNavigate({ from: '/_protected/hr/job-post' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canListJobs = hasPermission(permissions, 'job_postings', 'list')
  const canListApplicants = hasPermission(permissions, 'applicants', 'list')
  const canCreateJob = hasPermission(permissions, 'job_postings', 'create')
  const canUpdateJob = hasPermission(permissions, 'job_postings', 'update')
  const canDeleteJob = hasPermission(permissions, 'job_postings', 'delete')
  const canCreateApplicant = hasPermission(permissions, 'applicants', 'create')
  const canCreateApplicantWithPosting = canCreateApplicant && canListJobs
  const canUpdateApplicant = hasPermission(permissions, 'applicants', 'update')
  const canChangeApplicantStatus = hasPermission(permissions, 'applicants', 'update_status')
  const canDeleteApplicant = hasPermission(permissions, 'applicants', 'delete')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search
  const [postingFormOpen, setPostingFormOpen] = useState(false)
  const [applicantFormOpen, setApplicantFormOpen] = useState(false)
  const [editingPosting, setEditingPosting] = useState<JobPosting | null>(null)
  const [editingApplicant, setEditingApplicant] = useState<Applicant | null>(null)
  const [viewingPostingId, setViewingPostingId] = useState<number | null>(null)
  const [viewingApplicantId, setViewingApplicantId] = useState<number | null>(null)
  const [loadingEditId, setLoadingEditId] = useState<string | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<{
    kind: 'posting' | 'applicant'
    id: number
    label: string
  } | null>(null)
  function updateSearch(updates: Partial<RecruitmentSearch>) {
    void navigate({
      to: '/hr/job-post',
      search: (previous: RecruitmentSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }
  function commitSearch(event?: FormEvent) {
    event?.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  function setSearchDraft(value: string) {
    setSearchDraftState({ routeValue: search.search, value })
  }

  const postingParams = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: search.tab === 'jobs' ? search.search : '',
    status: search.status,
    jobType: search.jobType,
    branchId: search.branchId,
    departmentId: search.departmentId,
  }
  const applicantParams = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: search.tab === 'pipeline' ? search.search : '',
    status: search.candidateStatus,
    jobPostingId: search.jobPostingId,
  }
  const postingsQuery = useQuery({
    ...jobPostingListQueryOptions(userId, employeeId, postingParams),
    enabled: Boolean(session && canListJobs && search.tab === 'jobs'),
    placeholderData: keepPreviousData,
  })
  const applicantsQuery = useQuery({
    ...applicantListQueryOptions(userId, employeeId, applicantParams),
    enabled: Boolean(session && canListApplicants && search.tab === 'pipeline'),
    placeholderData: keepPreviousData,
  })
  const summaryQuery = useQuery({
    ...jobPostingSummaryQueryOptions(userId, employeeId),
    enabled: Boolean(session && canListJobs),
  })
  const postingDetailQuery = useQuery({
    ...jobPostingQueryOptions(userId, employeeId, viewingPostingId ?? 0),
    enabled: Boolean(viewingPostingId && hasPermission(permissions, 'job_postings', 'view')),
  })
  const applicantDetailQuery = useQuery({
    ...applicantQueryOptions(userId, employeeId, viewingApplicantId ?? 0),
    enabled: Boolean(viewingApplicantId && hasPermission(permissions, 'applicants', 'view')),
  })
  const postingChoicesQuery = useQuery({
    ...jobPostingListQueryOptions(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: 'all',
      jobType: 'all',
      branchId: 'all',
      departmentId: 'all',
    }),
    enabled: Boolean(
      canListJobs && (applicantFormOpen || (search.tab === 'pipeline' && canListApplicants)),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const branchesQuery = useQuery({
    queryKey: ['hr', 'recruitment', userId, employeeId, 'branch-choices'],
    queryFn: ({ signal }) =>
      branchesApi.list(
        {
          limit: 100,
          offset: 0,
          search: '',
          operationalStatus: 'all',
          branchRole: 'all',
          recordState: 'active',
        },
        signal,
      ),
    enabled: Boolean(
      (search.tab === 'jobs' && canListJobs) || (postingFormOpen && (canCreateJob || canUpdateJob)),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const departmentsQuery = useQuery({
    queryKey: ['hr', 'recruitment', userId, employeeId, 'posting-departments'],
    queryFn: async ({ signal }) => {
      const [departments, choices] = await Promise.all([
        companyOrganizationApi.departments({ limit: 100, offset: 0, search: '' }, signal),
        companyOrganizationApi.departmentChoices(signal),
      ])
      return {
        ...departments,
        items: postingDepartmentOptions(departments.items, choices.items),
      }
    },
    enabled: Boolean(
      (search.tab === 'jobs' && canListJobs) || (postingFormOpen && (canCreateJob || canUpdateJob)),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  async function invalidateRecruitment() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: recruitmentQueryKeys.scoped(userId, employeeId) }),
      queryClient.invalidateQueries({ queryKey: hrOverviewQueryKey(userId, employeeId) }),
    ])
  }
  const postingCreateMutation = useMutation({ mutationFn: recruitmentApi.createJobPosting })
  const postingUpdateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: JobPostingInput }) =>
      recruitmentApi.updateJobPosting(id, input),
  })
  const postingStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: JobPostingStatus }) =>
      recruitmentApi.updateJobPostingStatus(id, status),
  })
  const postingDeleteMutation = useMutation({ mutationFn: recruitmentApi.deleteJobPosting })
  const applicantCreateMutation = useMutation({ mutationFn: recruitmentApi.createApplicant })
  const applicantUpdateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: ApplicantInput }) =>
      recruitmentApi.updateApplicant(id, input),
  })
  const applicantStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: ApplicantStatus }) =>
      recruitmentApi.updateApplicantStatus(id, status),
  })
  const applicantDeleteMutation = useMutation({ mutationFn: recruitmentApi.deleteApplicant })

  async function savePosting(input: JobPostingInput) {
    if (editingPosting) await postingUpdateMutation.mutateAsync({ id: editingPosting.id, input })
    else await postingCreateMutation.mutateAsync(input)
    await invalidateRecruitment()
    showToast({
      title: editingPosting ? 'Posting updated' : 'Posting created',
      description: 'Recruitment records are up to date.',
      tone: 'success',
    })
    setPostingFormOpen(false)
    setEditingPosting(null)
  }
  async function saveApplicant(input: ApplicantInput) {
    if (editingApplicant)
      await applicantUpdateMutation.mutateAsync({ id: editingApplicant.id, input })
    else await applicantCreateMutation.mutateAsync(input)
    await invalidateRecruitment()
    showToast({
      title: editingApplicant ? 'Candidate updated' : 'Candidate added',
      description: 'The candidate record was saved.',
      tone: 'success',
    })
    setApplicantFormOpen(false)
    setEditingApplicant(null)
  }
  async function beginPostingEdit(id: number) {
    setLoadingEditId(`posting:${id}`)
    try {
      const posting = await queryClient.fetchQuery(jobPostingQueryOptions(userId, employeeId, id))
      setEditingPosting(posting)
      setPostingFormOpen(true)
    } catch (error) {
      showToast({
        title: 'Posting could not be opened for editing',
        description: presentError(error, 'page-load').message,
        tone: 'danger',
      })
    } finally {
      setLoadingEditId(null)
    }
  }
  async function beginApplicantEdit(id: number) {
    setLoadingEditId(`applicant:${id}`)
    try {
      const applicant = await queryClient.fetchQuery(applicantQueryOptions(userId, employeeId, id))
      setEditingApplicant(applicant)
      setApplicantFormOpen(true)
    } catch (error) {
      showToast({
        title: 'Candidate could not be opened for editing',
        description: presentError(error, 'page-load').message,
        tone: 'danger',
      })
    } finally {
      setLoadingEditId(null)
    }
  }
  async function updatePostingStatus(id: number, status: JobPostingStatus) {
    try {
      await postingStatusMutation.mutateAsync({ id, status })
      await invalidateRecruitment()
      showToast({
        title: 'Posting status updated',
        description: `The posting is now ${status}.`,
        tone: 'success',
      })
    } catch (error) {
      showToast({
        title: 'Status could not be updated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      })
    }
  }
  async function updateApplicantStatus(id: number, status: ApplicantStatus) {
    try {
      await applicantStatusMutation.mutateAsync({ id, status })
      await invalidateRecruitment()
      showToast({
        title: 'Candidate stage updated',
        description: `Moved to ${status}.`,
        tone: 'success',
      })
    } catch (error) {
      showToast({
        title: 'Stage could not be updated',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      })
    }
  }
  async function confirmDelete() {
    if (!deleteTarget) return
    try {
      if (deleteTarget.kind === 'posting') await postingDeleteMutation.mutateAsync(deleteTarget.id)
      else await applicantDeleteMutation.mutateAsync(deleteTarget.id)
      await invalidateRecruitment()
      showToast({
        title: deleteTarget.kind === 'posting' ? 'Posting deleted' : 'Candidate deleted',
        description: 'The record was removed.',
        tone: 'success',
      })
      setDeleteTarget(null)
      if (viewingPostingId === deleteTarget.id) setViewingPostingId(null)
      if (viewingApplicantId === deleteTarget.id) setViewingApplicantId(null)
    } catch (error) {
      showToast({
        title: 'Record could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      })
    }
  }

  const currentAllowed = search.tab === 'jobs' ? canListJobs : canListApplicants
  const rows =
    search.tab === 'jobs' ? (postingsQuery.data?.items ?? []) : (applicantsQuery.data?.items ?? [])
  const total =
    search.tab === 'jobs' ? (postingsQuery.data?.count ?? 0) : (applicantsQuery.data?.count ?? 0)
  const hasNoMatches = hasRecruitmentFilters(search) || total > 0
  const query = search.tab === 'jobs' ? postingsQuery : applicantsQuery
  const pageCount = Math.max(1, Math.ceil(total / search.pageSize))
  const postingChoices = (postingChoicesQuery.data?.items ?? []) as JobPostingListItem[]
  const departmentOptions = departmentsQuery.data?.items ?? []
  const branchOptions =
    branchesQuery.data?.items.map((branch) => ({
      value: String(branch.id),
      label: branch.branch_name,
    })) ?? []
  const displayedPosting =
    viewingPostingId && postingDetailQuery.data?.id === viewingPostingId
      ? postingDetailQuery.data
      : null
  const displayedApplicant =
    viewingApplicantId && applicantDetailQuery.data?.id === viewingApplicantId
      ? applicantDetailQuery.data
      : null

  if (sessionQuery.isPending)
    return (
      <PageLayout title="Recruitment" subtitle="Manage job openings and candidate progression.">
        <Card className="space-y-4" aria-busy="true">
          {Array.from({ length: 4 }, (_, i) => (
            <Skeleton key={i} variant="row" />
          ))}
        </Card>
      </PageLayout>
    )
  if (sessionQuery.isError || !session)
    return (
      <PageLayout title="Recruitment">
        <Card>
          <ErrorState
            title="Recruitment access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )

  return (
    <PageLayout
      title="Recruitment"
      subtitle="Manage open roles and move candidates through the hiring pipeline."
      leading={<BriefcaseBusiness className="size-[18px]" aria-hidden="true" />}
      actionsInline
      actions={
        search.tab === 'jobs' ? (
          canCreateJob ? (
            <Button
              size="sm"
              aria-label="New job posting"
              leadingIcon={<FilePlus2 className="size-4" />}
              onClick={() => {
                setEditingPosting(null)
                setPostingFormOpen(true)
              }}
            >
              <span className="max-[479px]:hidden">New job posting</span>
              <span className="hidden min-[361px]:max-[479px]:inline">New</span>
            </Button>
          ) : undefined
        ) : canCreateApplicantWithPosting ? (
          <Button
            size="sm"
            aria-label="Add candidate"
            leadingIcon={<Users className="size-4" />}
            onClick={() => {
              setEditingApplicant(null)
              setApplicantFormOpen(true)
            }}
          >
            <span className="max-[479px]:hidden">Add candidate</span>
            <span className="hidden min-[361px]:max-[479px]:inline">New</span>
          </Button>
        ) : undefined
      }
      contentClassName="space-y-5"
    >
      <nav
        aria-label="Recruitment sections"
        className="bg-surface border-border-subtle shadow-elevation-sm rounded-control grid grid-cols-2 gap-1 border p-1"
      >
        {[
          { value: 'jobs', label: 'Job openings', icon: BriefcaseBusiness },
          { value: 'pipeline', label: 'Candidate pipeline', icon: Users },
        ].map(({ value, label, icon: Icon }) => (
          <button
            key={value}
            type="button"
            aria-current={search.tab === value ? 'page' : undefined}
            onClick={() =>
              updateSearch({ tab: value as RecruitmentSearch['tab'], page: 1, search: '' })
            }
            className={`focus-visible:shadow-focus-ring rounded-control text-body-sm flex min-h-11 min-w-0 items-center justify-center gap-2 px-2 font-semibold focus-visible:outline-none ${search.tab === value ? 'bg-primary text-on-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface-muted'}`}
          >
            <Icon className="size-4 shrink-0" />
            <span className="truncate">{label}</span>
          </button>
        ))}
      </nav>

      {!currentAllowed ? (
        <Card>
          <ErrorState
            title="You do not have access to this view"
            description={
              search.tab === 'jobs'
                ? 'Your account cannot list job postings.'
                : 'Your account cannot list applicants.'
            }
          />
        </Card>
      ) : (
        <>
          {search.tab === 'pipeline' && canCreateApplicant && !canListJobs ? (
            <Alert tone="info" title="Job-opening access required to add candidates">
              Each applicant must be linked to a job opening. You can review the pipeline, but your
              account cannot load the job choices needed to create a candidate record.
            </Alert>
          ) : null}
          {search.tab === 'jobs' && canListJobs ? (
            <section
              aria-label="Job posting summary"
              className="tablet:grid-cols-3 desktop:grid-cols-5 grid grid-cols-2 gap-2.5"
            >
              {summaryQuery.isPending ? (
                Array.from({ length: 5 }, (_, i) => (
                  <Skeleton
                    key={i}
                    className={`h-[4.6rem] ${i === 4 ? 'tablet:col-span-1 col-span-2' : ''}`}
                  />
                ))
              ) : summaryQuery.isError ? (
                <Card className="col-span-full">
                  <Alert tone="warning" title="Posting summary unavailable">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <span>
                        The job register can still be used; summary counts could not be loaded.
                      </span>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => void summaryQuery.refetch()}
                      >
                        Retry
                      </Button>
                    </div>
                  </Alert>
                </Card>
              ) : summaryQuery.data ? (
                <>
                  <Metric
                    icon={<ClipboardList className="size-5" />}
                    label="All postings"
                    value={summaryQuery.data.total}
                    accent=""
                  />
                  <Metric
                    icon={<Check className="size-5" />}
                    label="Active"
                    value={summaryQuery.data.active}
                    accent="text-success-foreground"
                  />
                  <Metric
                    icon={<CalendarDays className="size-5" />}
                    label="Pending"
                    value={summaryQuery.data.pending}
                    accent="text-info-foreground"
                  />
                  <Metric
                    icon={<X className="size-5" />}
                    label="Closed"
                    value={summaryQuery.data.closed}
                    accent="text-text-muted"
                  />
                  <Metric
                    icon={<FilePlus2 className="size-5" />}
                    label="Drafts"
                    value={summaryQuery.data.draft}
                    accent="text-warning-foreground"
                    className="tablet:col-span-1 col-span-2"
                  />
                </>
              ) : null}
            </section>
          ) : null}

          <Card className="tablet:p-5 space-y-4 p-4">
            <div className="flex flex-wrap items-end justify-between gap-2">
              <div>
                <p className="text-overline text-primary font-semibold">People operations</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">
                  {search.tab === 'jobs' ? 'Job register' : 'Candidate pipeline'}
                </h2>
                <p className="text-body-sm text-text-secondary mt-1">
                  {search.tab === 'jobs'
                    ? 'Published, pending, and draft hiring requests.'
                    : 'Review applications and update their current stage.'}
                </p>
              </div>
              <p className="text-caption text-text-secondary" aria-live="polite">
                {query.isPending && !query.data
                  ? 'Loading records'
                  : `${total} ${total === 1 ? 'record' : 'records'}`}
              </p>
            </div>
            <form
              onSubmit={commitSearch}
              className="grid grid-cols-[minmax(0,1fr)_auto] items-end gap-3"
            >
              <FormControl
                id="recruitment-search"
                label={search.tab === 'jobs' ? 'Search job openings' : 'Search candidates'}
                className="min-w-0"
              >
                <span className="relative block">
                  <Search className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2" />
                  <TextInput
                    type="search"
                    maxLength={200}
                    value={searchDraft}
                    onChange={(event) => setSearchDraft(event.currentTarget.value)}
                    placeholder={
                      search.tab === 'jobs'
                        ? 'Role title or description'
                        : 'Candidate name, email, or phone'
                    }
                    className="pl-10"
                  />
                </span>
              </FormControl>
              <div className="grid grid-cols-1 gap-2 min-[400px]:flex min-[400px]:items-end">
                <Button
                  type="submit"
                  aria-label="Search"
                  size="icon"
                  leadingIcon={<Search className="size-4" />}
                  className="phone:h-11 phone:w-auto phone:px-4 shrink-0"
                >
                  <span className="phone:inline hidden">Search</span>
                </Button>
                {searchDraft ||
                search.status !== 'all' ||
                search.jobType !== 'all' ||
                search.candidateStatus !== 'all' ||
                search.branchId !== 'all' ||
                search.departmentId !== 'all' ||
                search.jobPostingId !== 'all' ? (
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-11 shrink-0"
                    onClick={() => {
                      setSearchDraft('')
                      updateSearch({
                        search: '',
                        status: 'all',
                        jobType: 'all',
                        candidateStatus: 'all',
                        branchId: 'all',
                        departmentId: 'all',
                        jobPostingId: 'all',
                        page: 1,
                      })
                    }}
                  >
                    Clear
                  </Button>
                ) : null}
              </div>
            </form>
            {search.tab === 'jobs' ? (
              <div className="desktop:grid-cols-4 grid gap-3 min-[400px]:grid-cols-2">
                <FormControl id="posting-status-filter" label="Status">
                  <DropdownSelect
                    value={search.status}
                    options={[{ value: 'all', label: 'All statuses' }, ...POSTING_STATUSES]}
                    onChange={(value) =>
                      updateSearch({ status: value as RecruitmentSearch['status'], page: 1 })
                    }
                  />
                </FormControl>
                <FormControl id="posting-type-filter" label="Employment type">
                  <DropdownSelect
                    value={search.jobType}
                    options={[
                      { value: 'all', label: 'All types' },
                      ...Object.entries(JOB_TYPES).map(([value, label]) => ({ value, label })),
                    ]}
                    onChange={(value) =>
                      updateSearch({ jobType: value as RecruitmentSearch['jobType'], page: 1 })
                    }
                  />
                </FormControl>
                <FormControl id="posting-branch-filter" label="Branch">
                  <DropdownSelect
                    value={search.branchId}
                    options={[{ value: 'all', label: 'All branches' }, ...branchOptions]}
                    onChange={(value) => updateSearch({ branchId: value, page: 1 })}
                  />
                </FormControl>
                <FormControl id="posting-department-filter" label="Department">
                  <DropdownSelect
                    value={search.departmentId}
                    options={[{ value: 'all', label: 'All departments' }, ...departmentOptions]}
                    onChange={(value) => updateSearch({ departmentId: value, page: 1 })}
                  />
                </FormControl>
              </div>
            ) : (
              <div className="grid gap-3 min-[400px]:grid-cols-2">
                <FormControl id="candidate-status-filter" label="Pipeline stage">
                  <DropdownSelect
                    value={search.candidateStatus}
                    options={[{ value: 'all', label: 'All stages' }, ...APPLICANT_STATUSES]}
                    onChange={(value) =>
                      updateSearch({
                        candidateStatus: value as RecruitmentSearch['candidateStatus'],
                        page: 1,
                      })
                    }
                  />
                </FormControl>
                <FormControl id="candidate-posting-filter" label="Job opening">
                  <DropdownSelect
                    value={search.jobPostingId}
                    options={[
                      { value: 'all', label: 'All openings' },
                      ...(postingChoicesQuery.data?.items ?? []).map((posting) => ({
                        value: String(posting.id),
                        label: posting.title,
                      })),
                    ]}
                    onChange={(value) => updateSearch({ jobPostingId: value, page: 1 })}
                  />
                </FormControl>
              </div>
            )}
          </Card>

          {query.isError && query.data ? (
            <Alert tone="warning" title="Showing saved results">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>
                  The last refresh failed. The previously loaded records remain available.
                </span>
                <Button size="sm" variant="outline" onClick={() => void query.refetch()}>
                  Retry refresh
                </Button>
              </div>
            </Alert>
          ) : null}
          {query.isPending ? (
            <Card className="space-y-3" aria-busy="true" aria-label="Loading recruitment records">
              {Array.from({ length: 4 }, (_, i) => (
                <Skeleton key={i} variant="row" />
              ))}
            </Card>
          ) : query.isError && !query.data ? (
            <Card>
              <ErrorState
                title="Recruitment records could not load"
                description="Try reloading this register."
                error={query.error}
                action={
                  <Button variant="outline" onClick={() => void query.refetch()}>
                    Try again
                  </Button>
                }
              />
            </Card>
          ) : rows.length === 0 ? (
            <Card>
              <EmptyState
                icon={
                  search.tab === 'jobs' ? (
                    <BriefcaseBusiness className="size-6" />
                  ) : (
                    <Users className="size-6" />
                  )
                }
                title={
                  hasNoMatches
                    ? 'No records match these filters'
                    : search.tab === 'jobs'
                      ? 'No job openings yet'
                      : 'No candidates yet'
                }
                description={
                  hasNoMatches
                    ? 'Try adjusting or clearing your search and filters.'
                    : search.tab === 'jobs'
                      ? 'Create a posting to start a hiring process.'
                      : 'Candidates will appear here when applications are recorded.'
                }
                action={
                  !hasNoMatches && search.tab === 'jobs' && canCreateJob ? (
                    <Button
                      leadingIcon={<FilePlus2 className="size-4" />}
                      onClick={() => {
                        setEditingPosting(null)
                        setPostingFormOpen(true)
                      }}
                    >
                      Create job posting
                    </Button>
                  ) : !hasNoMatches &&
                    search.tab === 'pipeline' &&
                    canCreateApplicantWithPosting ? (
                    <Button
                      onClick={() => {
                        setEditingApplicant(null)
                        setApplicantFormOpen(true)
                      }}
                    >
                      Add candidate
                    </Button>
                  ) : undefined
                }
              />
            </Card>
          ) : (
            <div className="space-y-3">
              {search.tab === 'jobs'
                ? (postingsQuery.data?.items ?? []).map((posting) => (
                    <JobPostingCard
                      key={posting.id}
                      posting={posting}
                      branchName={
                        branchOptions.find((item) => item.value === String(posting.branchId))
                          ?.label ?? `Branch #${posting.branchId}`
                      }
                      departmentName={
                        posting.departmentId
                          ? (departmentOptions.find(
                              (item) => item.value === String(posting.departmentId),
                            )?.label ?? `Department #${posting.departmentId}`)
                          : 'Not assigned'
                      }
                      jobTypeLabel={JOB_TYPES[posting.jobType] ?? posting.jobType}
                      dateLabel={dateLabel}
                      statusTone={statusTone}
                      statusOptions={POSTING_STATUSES}
                      canView={hasPermission(permissions, 'job_postings', 'view')}
                      canUpdate={canUpdateJob}
                      canDelete={canDeleteJob}
                      editLoading={loadingEditId === `posting:${posting.id}`}
                      editDisabled={loadingEditId !== null}
                      statusSaving={postingStatusMutation.isPending}
                      onView={() => setViewingPostingId(posting.id)}
                      onEdit={() => void beginPostingEdit(posting.id)}
                      onStatusChange={(status) => void updatePostingStatus(posting.id, status)}
                      onDelete={() =>
                        setDeleteTarget({
                          kind: 'posting',
                          id: posting.id,
                          label: posting.title,
                        })
                      }
                    />
                  ))
                : (applicantsQuery.data?.items ?? []).map((applicant) => (
                    <ApplicantCard
                      key={applicant.id}
                      applicant={applicant}
                      dateLabel={dateLabel}
                      statusTone={statusTone}
                      canView={hasPermission(permissions, 'applicants', 'view')}
                      canUpdate={canUpdateApplicant}
                      canChangeStatus={canChangeApplicantStatus}
                      canDelete={canDeleteApplicant}
                      editLoading={loadingEditId === `applicant:${applicant.id}`}
                      editDisabled={loadingEditId !== null}
                      onView={() => setViewingApplicantId(applicant.id)}
                      onEdit={() => void beginApplicantEdit(applicant.id)}
                      onStatusChange={(status) => void updateApplicantStatus(applicant.id, status)}
                      onDelete={() =>
                        setDeleteTarget({
                          kind: 'applicant',
                          id: applicant.id,
                          label: `${applicant.firstName} ${applicant.lastName}`,
                        })
                      }
                    />
                  ))}
              <Card className="overflow-hidden p-0">
                <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
                  <p className="text-caption text-text-secondary" aria-live="polite">
                    {total === 0
                      ? '0'
                      : `${(search.page - 1) * search.pageSize + 1}–${Math.min(search.page * search.pageSize, total)}`}{' '}
                    of {total}
                  </p>
                  <div className="flex items-center gap-2">
                    <DropdownSelect
                      aria-label="Records per page"
                      value={String(search.pageSize)}
                      options={PAGE_SIZES.map((size) => ({
                        value: String(size),
                        label: `${size} per page`,
                      }))}
                      onChange={(value) =>
                        updateSearch({
                          pageSize: Number(value) as RecruitmentSearch['pageSize'],
                          page: 1,
                        })
                      }
                    />
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={search.page <= 1}
                      onClick={() => updateSearch({ page: search.page - 1 })}
                    >
                      <ChevronLeft className="size-4" />
                      <span className="tablet:inline hidden">Previous</span>
                    </Button>
                    <span className="text-caption text-text-secondary tabular-nums">
                      {search.page}/{pageCount}
                    </span>
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={search.page >= pageCount}
                      onClick={() => updateSearch({ page: search.page + 1 })}
                    >
                      <span className="tablet:inline hidden">Next</span>
                      <ChevronRight className="size-4" />
                    </Button>
                  </div>
                </div>
              </Card>
            </div>
          )}
        </>
      )}

      {postingFormOpen ? (
        <JobPostingFormDialog
          open
          onOpenChange={setPostingFormOpen}
          posting={editingPosting}
          branches={branchesQuery.data?.items ?? []}
          departments={departmentsQuery.data?.items ?? []}
          branchChoicesError={branchesQuery.isError}
          departmentChoicesError={departmentsQuery.isError}
          onRetryBranches={() => void branchesQuery.refetch()}
          onRetryDepartments={() => void departmentsQuery.refetch()}
          onSave={savePosting}
          saving={postingCreateMutation.isPending || postingUpdateMutation.isPending}
        />
      ) : null}
      {applicantFormOpen ? (
        <ApplicantFormDialog
          open
          onOpenChange={setApplicantFormOpen}
          applicant={editingApplicant}
          postings={postingChoices}
          postingsLoading={postingChoicesQuery.isPending}
          postingsError={postingChoicesQuery.isError}
          onRetryPostings={() => void postingChoicesQuery.refetch()}
          saving={applicantCreateMutation.isPending || applicantUpdateMutation.isPending}
          onSave={saveApplicant}
        />
      ) : null}
      <PostingDetails
        posting={displayedPosting}
        branches={branchOptions}
        departments={departmentOptions}
        onClose={() => setViewingPostingId(null)}
      />
      {viewingPostingId && postingDetailQuery.isPending && !displayedPosting ? (
        <Dialog
          open
          onOpenChange={(open) => {
            if (!open) setViewingPostingId(null)
          }}
          title="Loading job posting"
          description="Retrieving the full role record."
          size="sm"
        >
          <div className="space-y-3" aria-busy="true">
            <Skeleton variant="row" />
            <Skeleton variant="row" />
          </div>
        </Dialog>
      ) : null}
      {viewingPostingId && postingDetailQuery.isError && !displayedPosting ? (
        <Dialog
          open
          onOpenChange={(open) => {
            if (!open) setViewingPostingId(null)
          }}
          title="Posting details unavailable"
          description="This posting could not be loaded."
          footer={
            <Button variant="outline" onClick={() => void postingDetailQuery.refetch()}>
              Retry
            </Button>
          }
        >
          <Alert tone="danger" title="Unable to open posting">
            {presentError(postingDetailQuery.error, 'page-load').message}
          </Alert>
        </Dialog>
      ) : null}
      <ApplicantDetails
        key={viewingApplicantId ?? 'closed'}
        applicant={displayedApplicant}
        onClose={() => {
          setViewingApplicantId(null)
        }}
        onStatusChange={(status) => {
          if (viewingApplicantId) void updateApplicantStatus(viewingApplicantId, status)
        }}
        canUpdate={canChangeApplicantStatus}
        saving={applicantStatusMutation.isPending}
        userId={userId}
        employeeId={employeeId}
        permissions={permissions}
        onWorkflowSaved={invalidateRecruitment}
      />
      {viewingApplicantId && applicantDetailQuery.isPending && !displayedApplicant ? (
        <Dialog
          open
          onOpenChange={(open) => {
            if (!open) setViewingApplicantId(null)
          }}
          title="Loading candidate profile"
          description="Retrieving the full candidate record."
          size="sm"
        >
          <div className="space-y-3" aria-busy="true">
            <Skeleton variant="row" />
            <Skeleton variant="row" />
          </div>
        </Dialog>
      ) : null}
      {viewingApplicantId && applicantDetailQuery.isError && !displayedApplicant ? (
        <Dialog
          open
          onOpenChange={(open) => {
            if (!open) setViewingApplicantId(null)
          }}
          title="Candidate profile unavailable"
          description="This candidate could not be loaded."
          footer={
            <Button variant="outline" onClick={() => void applicantDetailQuery.refetch()}>
              Retry
            </Button>
          }
        >
          <Alert tone="danger" title="Unable to open profile">
            {presentError(applicantDetailQuery.error, 'page-load').message}
          </Alert>
        </Dialog>
      ) : null}
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null)
        }}
        title={`Delete ${deleteTarget?.kind === 'posting' ? 'job posting' : 'candidate'}?`}
        description="This action cannot be undone."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={postingDeleteMutation.isPending || applicantDeleteMutation.isPending}
              onClick={() => void confirmDelete()}
            >
              Delete
            </Button>
          </>
        }
      >
        <p className="text-body-sm text-text-secondary">
          Delete <strong className="text-text-primary">{deleteTarget?.label}</strong>?{' '}
          {deleteTarget?.kind === 'posting'
            ? 'The API may refuse deletion while applicants are attached.'
            : 'This permanently removes the applicant record.'}
        </p>
      </Dialog>
    </PageLayout>
  )
}
