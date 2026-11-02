import { useState, type FormEvent } from 'react'
import { presentError } from '@/shared/errors'
import { Dialog } from '@/shared/ui/dialog'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import type {
  Applicant,
  ApplicantInput,
  ApplicantStatus,
  JobPostingListItem,
} from '../recruitment.api'

const statusOptions = [
  { value: 'applied', label: 'Applied' },
  { value: 'shortlisted', label: 'Shortlisted' },
  { value: 'interviewed', label: 'Interviewed' },
  { value: 'offered', label: 'Offered' },
  { value: 'hired', label: 'Hired' },
  { value: 'rejected', label: 'Rejected' },
]
const educationOptions = [
  { value: '', label: 'Not provided' },
  { value: 'high_school', label: 'High school' },
  { value: 'associate', label: 'Associate degree' },
  { value: 'bachelor', label: "Bachelor's degree" },
  { value: 'master', label: "Master's degree" },
  { value: 'doctorate', label: 'Doctorate' },
  { value: 'other', label: 'Other' },
]
const sourceOptions = [
  { value: '', label: 'Not provided' },
  { value: 'linkedin', label: 'LinkedIn' },
  { value: 'indeed', label: 'Indeed' },
  { value: 'company_website', label: 'Company website' },
  { value: 'referral', label: 'Referral' },
  { value: 'other', label: 'Other' },
]

function isValidAmount(value: string, maxIntegerDigits: number) {
  return new RegExp(`^\\d{1,${maxIntegerDigits}}(?:\\.\\d{1,2})?$`).test(value.trim())
}

type Draft = {
  firstName: string
  lastName: string
  email: string
  phone: string
  jobPostingId: string
  status: ApplicantStatus
  resume: string
  coverLetter: string
  notes: string
  address: string
  currentJobTitle: string
  yearsOfExperience: string
  highestEducation: string
  institutionName: string
  source: string
  expectedSalary: string
}

function draftFromApplicant(applicant: Applicant | null): Draft {
  return {
    firstName: applicant?.firstName ?? '',
    lastName: applicant?.lastName ?? '',
    email: applicant?.email ?? '',
    phone: applicant?.phone ?? '',
    jobPostingId: applicant ? String(applicant.jobPosting.id) : '',
    status: (applicant?.status as ApplicantStatus) ?? 'applied',
    resume: applicant?.resume ?? '',
    coverLetter: applicant?.coverLetter ?? '',
    notes: applicant?.notes ?? '',
    address: applicant?.address ?? '',
    currentJobTitle: applicant?.currentJobTitle ?? '',
    yearsOfExperience:
      applicant?.yearsOfExperience == null ? '' : String(applicant.yearsOfExperience),
    highestEducation: applicant?.highestEducation ?? '',
    institutionName: applicant?.institutionName ?? '',
    source: applicant?.source ?? '',
    expectedSalary: applicant?.expectedSalary ?? '',
  }
}

export function ApplicantFormDialog({
  open,
  onOpenChange,
  applicant,
  postings,
  postingsLoading,
  postingsError,
  onRetryPostings,
  saving,
  onSave,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  applicant: Applicant | null
  postings: JobPostingListItem[]
  postingsLoading: boolean
  postingsError: boolean
  onRetryPostings: () => void
  saving: boolean
  onSave: (input: ApplicantInput) => Promise<void>
}) {
  const [draft, setDraft] = useState(() => draftFromApplicant(applicant))
  const [error, setError] = useState('')
  const [fieldError, setFieldError] = useState<Record<string, string>>({})

  function patch(key: keyof Draft, value: string) {
    setDraft((current) => ({ ...current, [key]: value }))
    setFieldError((current) => ({ ...current, [key]: '' }))
    setError('')
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const errors: Record<string, string> = {}
    if (!draft.firstName.trim()) errors.firstName = 'Enter the candidate’s first name.'
    else if (draft.firstName.trim().length > 100) errors.firstName = 'Use 100 characters or fewer.'
    if (!draft.lastName.trim()) errors.lastName = 'Enter the candidate’s last name.'
    else if (draft.lastName.trim().length > 100) errors.lastName = 'Use 100 characters or fewer.'
    if (draft.email.trim().length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(draft.email.trim()))
      errors.email = 'Enter a valid email address.'
    if (!draft.phone.trim()) errors.phone = 'Enter a phone number.'
    else if (draft.phone.trim().length > 20) errors.phone = 'Use 20 characters or fewer.'
    if (!/^[1-9]\d*$/.test(draft.jobPostingId)) errors.jobPostingId = 'Choose a job posting.'
    const years = draft.yearsOfExperience.trim() ? Number(draft.yearsOfExperience) : null
    if (years !== null && (!Number.isSafeInteger(years) || years < 0 || years > 2_147_483_647))
      errors.yearsOfExperience = 'Enter a whole number of years.'
    const salary = draft.expectedSalary.trim() ? Number(draft.expectedSalary) : null
    if (
      salary !== null &&
      (!Number.isFinite(salary) || salary < 0 || !isValidAmount(draft.expectedSalary, 8))
    )
      errors.expectedSalary = 'Enter a valid non-negative amount.'
    if (draft.currentJobTitle.trim().length > 100)
      errors.currentJobTitle = 'Use 100 characters or fewer.'
    if (draft.institutionName.trim().length > 255)
      errors.institutionName = 'Use 255 characters or fewer.'
    if (draft.address.trim().length > 255) errors.address = 'Use 255 characters or fewer.'
    if (draft.resume.trim().length > 200) errors.resume = 'Use 200 characters or fewer.'
    if (draft.resume.trim()) {
      try {
        const resumeUrl = new URL(draft.resume.trim())
        if (!['https:', 'http:'].includes(resumeUrl.protocol)) throw new Error()
      } catch {
        errors.resume = 'Enter a valid http or https resume link.'
      }
    }
    setFieldError(errors)
    if (Object.keys(errors).length) return
    try {
      await onSave({
        first_name: draft.firstName.trim(),
        last_name: draft.lastName.trim(),
        email: draft.email.trim(),
        phone: draft.phone.trim(),
        job_posting_id: Number(draft.jobPostingId),
        status: draft.status,
        resume: draft.resume.trim() || null,
        cover_letter: draft.coverLetter.trim() || null,
        notes: draft.notes.trim() || null,
        address: draft.address.trim() || null,
        current_job_title: draft.currentJobTitle.trim() || null,
        years_of_experience: years,
        highest_education: draft.highestEducation.trim() || null,
        institution_name: draft.institutionName.trim() || null,
        source: draft.source.trim() || null,
        expected_salary: salary,
      })
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    }
  }

  const postingOptions = postings.map((posting) => ({
    value: String(posting.id),
    label: posting.title,
  }))
  if (
    applicant &&
    !postingOptions.some((option) => option.value === String(applicant.jobPosting.id))
  ) {
    postingOptions.unshift({
      value: String(applicant.jobPosting.id),
      label: applicant.jobPosting.title,
    })
  }
  const textField = (
    key: keyof Draft,
    id: string,
    label: string,
    options: { maxLength?: number; type?: string } = {},
  ) => (
    <FormControl id={id} label={label} error={fieldError[key]}>
      <TextInput
        type={options.type}
        maxLength={options.maxLength}
        value={draft[key]}
        onChange={(event) => patch(key, event.currentTarget.value)}
      />
    </FormControl>
  )

  const educationChoices =
    applicant?.highestEducation &&
    !educationOptions.some((option) => option.value === applicant.highestEducation)
      ? [
          ...educationOptions,
          { value: applicant.highestEducation, label: applicant.highestEducation },
        ]
      : educationOptions
  const sourceChoices =
    applicant?.source && !sourceOptions.some((option) => option.value === applicant.source)
      ? [...sourceOptions, { value: applicant.source, label: applicant.source }]
      : sourceOptions

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={applicant ? 'Edit candidate' : 'Add candidate'}
      description="Capture applicant information that can be stored in the recruitment record."
      size="lg"
      dismissDisabled={saving}
      footer={
        <>
          <Button variant="outline" disabled={saving} onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="applicant-form"
            isLoading={saving}
            disabled={!applicant && (postingsLoading || postingsError || postings.length === 0)}
          >
            {applicant ? 'Save changes' : 'Add candidate'}
          </Button>
        </>
      }
    >
      <form
        id="applicant-form"
        onSubmit={(event) => void submit(event)}
        noValidate
        className="space-y-4"
      >
        {error ? (
          <Alert tone="danger" title="Candidate not saved" role="alert">
            {error}
          </Alert>
        ) : null}
        {!applicant && postingsError ? (
          <Alert tone="warning" title="Job openings unavailable">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>
                Candidate records must reference a job opening. Reload the choices before saving.
              </span>
              <Button size="sm" variant="outline" onClick={onRetryPostings}>
                Retry choices
              </Button>
            </div>
          </Alert>
        ) : null}
        {!applicant && postingsLoading ? (
          <Alert tone="info" title="Loading job openings">
            Candidate records must be linked to a job opening. The choices are loading now.
          </Alert>
        ) : null}
        {!applicant && !postingsLoading && !postingsError && postings.length === 0 ? (
          <Alert tone="info" title="Create a job opening first">
            The backend requires each applicant to be attached to an existing job posting.
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <h3 className="text-label font-semibold">Candidate and role</h3>
          <div className="phone:grid-cols-2 grid gap-4">
            {textField('firstName', 'candidate-first-name', 'First name', { maxLength: 100 })}
            {textField('lastName', 'candidate-last-name', 'Last name', { maxLength: 100 })}
            {textField('email', 'candidate-email', 'Email', { maxLength: 254, type: 'email' })}
            {textField('phone', 'candidate-phone', 'Phone', { maxLength: 20, type: 'tel' })}
          </div>
          <FormControl
            id="candidate-posting"
            label="Job posting"
            required
            error={fieldError.jobPostingId}
          >
            <DropdownSelect
              value={draft.jobPostingId}
              options={postingOptions}
              placeholder="Choose a posting"
              disabled={!applicant && (postingsLoading || postingsError || postings.length === 0)}
              onChange={(value) => patch('jobPostingId', value)}
            />
          </FormControl>
          <FormControl id="candidate-status" label="Pipeline status" required>
            <DropdownSelect
              value={draft.status}
              options={statusOptions}
              onChange={(value) => patch('status', value as ApplicantStatus)}
            />
          </FormControl>
        </FormSection>
        <FormSection className="space-y-4">
          <h3 className="text-label font-semibold">Experience and source</h3>
          <div className="phone:grid-cols-2 grid gap-4">
            {textField('currentJobTitle', 'candidate-current-title', 'Current role', {
              maxLength: 100,
            })}
            <FormControl
              id="candidate-years"
              label="Years of experience"
              error={fieldError.yearsOfExperience}
            >
              <TextInput
                type="number"
                min="0"
                max="2147483647"
                step="1"
                value={draft.yearsOfExperience}
                onChange={(event) => patch('yearsOfExperience', event.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="candidate-education" label="Highest education">
              <DropdownSelect
                value={draft.highestEducation}
                options={educationChoices}
                onChange={(value) => patch('highestEducation', value)}
              />
            </FormControl>
            {textField('institutionName', 'candidate-institution', 'Institution', {
              maxLength: 255,
            })}
            <FormControl id="candidate-source" label="Application source">
              <DropdownSelect
                value={draft.source}
                options={sourceChoices}
                onChange={(value) => patch('source', value)}
              />
            </FormControl>
            <FormControl
              id="candidate-expected-salary"
              label="Expected salary (₦)"
              error={fieldError.expectedSalary}
            >
              <TextInput
                type="number"
                min="0"
                max="99999999.99"
                step="0.01"
                value={draft.expectedSalary}
                onChange={(event) => patch('expectedSalary', event.currentTarget.value)}
              />
            </FormControl>
          </div>
          {textField('address', 'candidate-address', 'Address', { maxLength: 255 })}
          <FormControl id="candidate-resume" label="Resume URL" error={fieldError.resume}>
            <TextInput
              type="url"
              maxLength={200}
              value={draft.resume}
              onChange={(event) => patch('resume', event.currentTarget.value)}
              placeholder="https://example.com/resume"
            />
          </FormControl>
          <p className="text-caption text-text-muted">
            Add a secure link to the candidate’s resume. File uploads are not available here.
          </p>
        </FormSection>
        <FormSection className="space-y-4">
          <FormControl id="candidate-cover-letter" label="Cover letter">
            <TextArea
              rows={3}
              value={draft.coverLetter}
              onChange={(event) => patch('coverLetter', event.currentTarget.value)}
            />
          </FormControl>
          <FormControl id="candidate-notes" label="Internal notes">
            <TextArea
              rows={3}
              value={draft.notes}
              onChange={(event) => patch('notes', event.currentTarget.value)}
            />
          </FormControl>
        </FormSection>
      </form>
    </Dialog>
  )
}
