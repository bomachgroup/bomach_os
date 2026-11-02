import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  Archive,
  ChevronLeft,
  ChevronRight,
  ImagePlus,
  Plus,
  Search,
  UserRound,
  UsersRound,
} from 'lucide-react'
import { useCallback, useEffect, useRef, useState, type FormEvent } from 'react'

import { branchesApi } from '@/modules/company/branches.api'
import { companyOrganizationApi } from '@/modules/company/company-organization.api'
import { rolesApi } from '@/modules/company/roles.api'
import {
  employeesApi,
  employeesQueryKeys,
  type EmployeeDto,
  type EmployeeWriteInput,
} from '@/modules/hr/employees.api'
import { validateEmployeesSearch, type EmployeesSearch } from '@/modules/hr/employees.search'
import {
  asDraft,
  buildAllowances,
  STANDARD_ALLOWANCE_FIELDS,
  validateAllowanceDraft,
  type EmployeeDraft,
} from '@/modules/hr/routes/employee-form-model'
import {
  EmployeeActionDialog,
  type EmployeeActionIntent,
  type EmployeeActionSubmission,
} from '@/modules/hr/routes/employee-action-dialog'
import { EmployeeRowActions } from '@/modules/hr/routes/employee-row-actions'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { useToast } from '@/shared/feedback/use-toast'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

const PROFILE_IMAGE_MAX_BYTES = 15 * 1024 * 1024
const STEPS = ['Identity', 'Contact', 'Employment', 'Compensation', 'Review'] as const
const EMPLOYMENT_TYPES = [
  'full-time',
  'part-time',
  'intern',
  'contract',
  'freelance',
  'surveyor-associate',
  'lawyer-associate',
  'architect-associate',
  'engineer-associate',
] as const
type Draft = EmployeeDraft

function maskIdentifier(value: string | undefined) {
  const normalized = value?.trim()
  if (!normalized) return 'Not provided'
  return `•••• ${normalized.slice(-4)}`
}

function EmployeeReviewGroup({
  title,
  step,
  children,
  onEdit,
}: {
  title: string
  step: number
  children: React.ReactNode
  onEdit: (step: number) => void
}) {
  return (
    <section
      className="border-border-subtle bg-surface rounded-control min-w-0 border p-3.5 sm:p-4"
      aria-labelledby={`employee-review-${step}-title`}
    >
      <div className="mb-3 flex items-center justify-between gap-3">
        <h3
          id={`employee-review-${step}-title`}
          className="text-label text-text-primary font-semibold"
        >
          {title}
        </h3>
        <Button variant="ghost" size="sm" onClick={() => onEdit(step)}>
          Edit
        </Button>
      </div>
      <dl className="grid min-w-0 gap-x-4 gap-y-3 sm:grid-cols-2">{children}</dl>
    </section>
  )
}

function EmployeeReviewValue({ label, value }: { label: string; value: unknown }) {
  const renderedValue =
    value === null || value === undefined || value === '' ? 'Not provided' : String(value)
  return (
    <div className="min-w-0">
      <dt className="text-caption text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-0.5 break-words">{renderedValue}</dd>
    </div>
  )
}

function EmployeeStatusTabs({
  view,
  onChange,
}: {
  view: EmployeesSearch['view']
  onChange: (view: EmployeesSearch['view']) => void
}) {
  const tabs = [
    {
      id: 'active' as const,
      label: 'Active employees',
      supporting: 'Current workforce',
      Icon: UsersRound,
    },
    {
      id: 'past' as const,
      label: 'Past employees',
      supporting: 'Former and inactive',
      Icon: Archive,
    },
  ]

  return (
    <div className="border-border-subtle bg-surface-muted rounded-surface border p-1.5">
      <div className="grid grid-cols-2 gap-1.5" role="tablist" aria-label="Employee status views">
        {tabs.map(({ id, label, supporting, Icon }, index) => (
          <button
            key={id}
            type="button"
            id={`employee-view-tab-${id}`}
            role="tab"
            aria-selected={view === id}
            aria-controls="employee-results"
            tabIndex={view === id ? 0 : -1}
            onClick={() => onChange(id)}
            onKeyDown={(event) => {
              let nextIndex: number | null = null
              if (event.key === 'ArrowRight' || event.key === 'ArrowDown')
                nextIndex = (index + 1) % tabs.length
              if (event.key === 'ArrowLeft' || event.key === 'ArrowUp')
                nextIndex = (index + tabs.length - 1) % tabs.length
              if (event.key === 'Home') nextIndex = 0
              if (event.key === 'End') nextIndex = tabs.length - 1
              if (nextIndex === null) return
              event.preventDefault()
              onChange(tabs[nextIndex].id)
              event.currentTarget.parentElement
                ?.querySelectorAll<HTMLButtonElement>('[role="tab"]')
                [nextIndex]?.focus()
            }}
            className={`rounded-control focus-visible:shadow-focus-ring flex min-h-14 min-w-0 items-center gap-2.5 px-2.5 py-2 text-left transition-colors focus-visible:outline-none sm:gap-3 sm:px-3 ${view === id ? 'bg-surface text-text-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface/70'}`}
          >
            <span
              className={`rounded-control flex size-8 shrink-0 items-center justify-center ${view === id ? 'bg-primary-subtle text-primary' : 'bg-surface text-text-muted'}`}
            >
              <Icon className="size-4" aria-hidden="true" />
            </span>
            <span className="min-w-0">
              <span className="text-caption sm:text-label block truncate font-semibold">
                {label}
              </span>
              <span className="text-caption text-text-muted hidden truncate sm:block">
                {supporting}
              </span>
            </span>
          </button>
        ))}
      </div>
    </div>
  )
}

function EmployeeSearchInput({
  search,
  onCommit,
}: {
  search: string
  onCommit: (value: string) => void
}) {
  const [value, setValue] = useState(search)
  useEffect(() => {
    const normalized = value.trim()
    if (normalized === search) return
    const timer = window.setTimeout(() => onCommit(normalized), 250)
    return () => window.clearTimeout(timer)
  }, [onCommit, search, value])

  return (
    <FormControl id="employee-search" label="Search employees">
      <span className="relative block">
        <Search
          className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          type="search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Name, email, employee ID"
          maxLength={200}
          className="pl-10"
        />
      </span>
    </FormControl>
  )
}

function numberOrNull(value: string) {
  if (!value.trim()) return null
  const number = Number(value)
  return Number.isFinite(number) ? number : null
}

function formatNairaAmount(value: string | undefined) {
  const amount = Number(value)
  if (!value?.trim() || !Number.isFinite(amount)) return ''
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency: 'NGN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

export function EmployeeEditor({
  open,
  employee,
  onClose,
  onSave,
  isSaving,
  error,
}: {
  open: boolean
  employee: EmployeeDto | null
  onClose: () => void
  onSave: (input: EmployeeWriteInput, profileImage: File | null) => void
  isSaving: boolean
  error?: unknown
}) {
  const [step, setStep] = useState(0)
  const [draft, setDraft] = useState<Draft>(() => asDraft(employee))
  const [unitIds, setUnitIds] = useState<number[]>(
    () => employee?.department_units.map((unit) => unit.id) ?? [],
  )
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [profileImage, setProfileImage] = useState<File | null>(null)
  const [profileImageError, setProfileImageError] = useState('')
  const [profileImageUrl, setProfileImageUrl] = useState<string | null>(
    () => employee?.profile_picture ?? null,
  )
  const profileImageObjectUrl = useRef<string | null>(null)
  useEffect(
    () => () => {
      if (profileImageObjectUrl.current) URL.revokeObjectURL(profileImageObjectUrl.current)
    },
    [],
  )

  const session = useQuery(authSessionQueryOptions()).data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const selectedDepartmentId = Number(draft.department_id)
  const selectedDepartmentIdOrNull =
    Number.isSafeInteger(selectedDepartmentId) && selectedDepartmentId > 0
      ? selectedDepartmentId
      : null
  const branchesQuery = useQuery({
    queryKey: ['hr', 'employee-form', 'branches', userId, employeeId],
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
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const departmentsQuery = useQuery({
    queryKey: ['hr', 'employee-form', 'departments', userId, employeeId],
    queryFn: ({ signal }) =>
      companyOrganizationApi.departments({ limit: 100, offset: 0, search: '' }, signal),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const rolesQuery = useQuery({
    queryKey: ['hr', 'employee-form', 'roles', userId, employeeId],
    queryFn: ({ signal }) => rolesApi.list({ limit: 100, offset: 0, search: '' }, signal),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const managersQuery = useQuery({
    queryKey: employeesQueryKeys.list(userId, employeeId, {
      limit: 500,
      offset: 0,
      search: '',
      view: 'active',
      branchId: 'all',
      departmentId: 'all',
    }),
    queryFn: ({ signal }) =>
      employeesApi.list(
        { limit: 500, offset: 0, search: '', view: 'active', branchId: 'all', departmentId: 'all' },
        signal,
      ),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.standard,
  })
  const unitsQuery = useQuery({
    queryKey: ['hr', 'employee-form', 'units', userId, employeeId, selectedDepartmentIdOrNull],
    queryFn: ({ signal }) =>
      companyOrganizationApi.units(
        { limit: 100, offset: 0, search: '', departmentId: selectedDepartmentIdOrNull },
        signal,
      ),
    enabled: open && selectedDepartmentIdOrNull !== null,
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const patch = (key: string, value: string) => {
    setDraft((current) => ({ ...current, [key]: value }))
    setFieldErrors((current) => ({ ...current, [key]: '' }))
    if (key === 'department_id') setUnitIds([])
  }
  const numericFields: Array<{
    key: string
    label: string
    minimum: number
    integer: boolean
    step: number
  }> = [
    { key: 'branch_id', label: 'Branch', minimum: 1, integer: true, step: 2 },
    { key: 'department_id', label: 'Department', minimum: 1, integer: true, step: 2 },
    { key: 'role_id', label: 'Role', minimum: 1, integer: true, step: 2 },
    { key: 'reporting_to_id', label: 'Manager', minimum: 1, integer: true, step: 2 },
    { key: 'probation_period', label: 'Probation period', minimum: 0, integer: true, step: 2 },
    { key: 'gross_salary', label: 'Gross salary', minimum: 0, integer: false, step: 3 },
    {
      key: 'employer_contribution',
      label: 'Employer contribution',
      minimum: 0,
      integer: false,
      step: 3,
    },
    {
      key: 'hmo_dependents_covered',
      label: 'Covered dependants',
      minimum: 0,
      integer: true,
      step: 3,
    },
  ]
  const validateSteps = (steps: number[]) => {
    const nextErrors: Record<string, string> = {}
    if (steps.includes(0)) {
      if (!draft.first_name?.trim()) nextErrors.first_name = 'Enter the employee’s first name.'
      if (!draft.last_name?.trim()) nextErrors.last_name = 'Enter the employee’s last name.'
      if (!employee && !draft.email?.trim()) nextErrors.email = 'Enter the employee’s work email.'
      else if (!employee && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(draft.email ?? '')) {
        nextErrors.email = 'Enter a valid work email address.'
      }
    }
    if (
      steps.includes(1) &&
      draft.personal_email?.trim() &&
      !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(draft.personal_email)
    ) {
      nextErrors.personal_email = 'Enter a valid personal email address.'
    }
    if (steps.includes(2) && !draft.designation?.trim()) {
      nextErrors.designation = 'Enter the employee’s job title.'
    }
    const invalidNumber = numericFields.find(({ key, minimum, integer, step: fieldStep }) => {
      const raw = draft[key]?.trim() ?? ''
      if (!steps.includes(fieldStep) || !raw) return false
      const value = Number(raw)
      return !Number.isFinite(value) || value < minimum || (integer && !Number.isInteger(value))
    })
    if (invalidNumber) {
      nextErrors[invalidNumber.key] =
        `${invalidNumber.label} must be ${invalidNumber.integer ? 'a whole number' : 'a number'} greater than or equal to ${invalidNumber.minimum}.`
    }
    if (steps.includes(3)) {
      Object.assign(nextErrors, validateAllowanceDraft(draft))
    }
    return nextErrors
  }
  const continueStep = () => {
    const nextErrors = validateSteps([step])
    setFieldErrors(nextErrors)
    if (Object.values(nextErrors).some(Boolean)) return
    setStep((current) => current + 1)
  }
  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (step < STEPS.length - 1) {
      continueStep()
      return
    }
    const nextErrors = validateSteps([0, 1, 2, 3])
    if (Object.keys(nextErrors).length) {
      setFieldErrors(nextErrors)
      const firstInvalidField = Object.keys(nextErrors)[0]
      const invalidStep =
        numericFields.find(({ key }) => key === firstInvalidField)?.step ??
        (firstInvalidField === 'personal_email'
          ? 1
          : firstInvalidField === 'designation'
            ? 2
            : firstInvalidField.startsWith('allowance_')
              ? 3
              : 0)
      setStep(invalidStep)
      return
    }
    const input: EmployeeWriteInput = {
      first_name: draft.first_name?.trim(),
      middle_name: draft.middle_name?.trim(),
      last_name: draft.last_name?.trim(),
      ...(employee ? {} : { email: draft.email?.trim() }),
      gender: draft.gender || 'male',
      marital_status: draft.marital_status || 'single',
      nationality: draft.nationality ?? '',
      date_of_birth: draft.date_of_birth || null,
      phone_number: draft.phone_number || null,
      other_phone: draft.other_phone || null,
      personal_email: draft.personal_email || null,
      address: draft.address ?? '',
      city: draft.city ?? '',
      state: draft.state ?? '',
      zip_code: draft.zip_code ?? '',
      country: draft.country ?? '',
      emergency_contact_name: draft.emergency_contact_name ?? '',
      emergency_contact_relationship: draft.emergency_contact_relationship ?? '',
      emergency_contact_phone: draft.emergency_contact_phone ?? '',
      designation: draft.designation ?? '',
      employment_type: draft.employment_type || 'full-time',
      ...(employee ? {} : { employment_status: draft.employment_status || 'active' }),
      branch_id: numberOrNull(draft.branch_id ?? ''),
      department_id: numberOrNull(draft.department_id ?? ''),
      role_id: numberOrNull(draft.role_id ?? ''),
      department_unit_ids: unitIds,
      reporting_to_id: numberOrNull(draft.reporting_to_id ?? ''),
      start_date: draft.start_date || null,
      probation_period: numberOrNull(draft.probation_period ?? ''),
      location: draft.location ?? '',
      work_schedule: draft.work_schedule ?? '',
      gross_salary: draft.gross_salary?.trim() || null,
      salary_frequency: draft.salary_frequency || 'monthly',
      bank_name: draft.bank_name ?? '',
      account_number: draft.account_number ?? '',
      tax_id: draft.tax_id ?? '',
      pension_number: draft.pension_number ?? '',
      pfa_provider: draft.pfa_provider ?? '',
      rsa_number: draft.rsa_number ?? '',
      employer_contribution: draft.employer_contribution?.trim() || null,
      hmo_current_plan: draft.hmo_current_plan ?? '',
      hmo_id_number: draft.hmo_id_number ?? '',
      hmo_dependents_covered: numberOrNull(draft.hmo_dependents_covered ?? '') ?? 0,
      allowances: buildAllowances(draft, employee?.allowances),
    }
    onSave(input, profileImage)
  }
  const field = (
    key: string,
    label: string,
    options?: {
      required?: boolean
      type?: string
      placeholder?: string
      maxLength?: number
    },
  ) => (
    <FormControl
      key={key}
      id={`employee-${key}`}
      label={label}
      required={options?.required}
      error={fieldErrors[key]}
    >
      <TextInput
        type={options?.type ?? 'text'}
        value={draft[key] ?? ''}
        onChange={(event) => patch(key, event.currentTarget.value)}
        required={options?.required}
        maxLength={options?.maxLength}
        placeholder={options?.placeholder}
        autoComplete="off"
      />
    </FormControl>
  )
  const select = (
    key: string,
    label: string,
    options: Array<{ value: string; label: string; disabled?: boolean }>,
    required = false,
  ) => (
    <FormControl
      key={key}
      id={`employee-${key}`}
      label={label}
      required={required}
      error={fieldErrors[key]}
    >
      <DropdownSelect
        id={`employee-${key}`}
        value={draft[key] ?? ''}
        onChange={(value) => patch(key, value)}
        options={[{ value: '', label: 'Not selected' }, ...options]}
        placeholder={`Select ${label.toLocaleLowerCase()}`}
        required={required}
        disabled={key === 'employment_status' && employee?.employment_status === 'terminated'}
      />
    </FormControl>
  )
  const dateField = (
    key: string,
    label: string,
    options?: { required?: boolean; max?: string },
  ) => (
    <FormControl
      key={key}
      id={`employee-${key}`}
      label={label}
      required={options?.required}
      error={fieldErrors[key]}
    >
      <DatePickerField
        id={`employee-${key}`}
        value={draft[key] ?? ''}
        onValueChange={(value) => patch(key, value)}
        max={options?.max}
        clearable
        required={options?.required}
      />
    </FormControl>
  )
  const selectedOptionLabel = (
    value: string | undefined,
    options: DropdownSelectOption[],
    fallback?: string | null,
  ) => options.find((option) => option.value === value)?.label ?? fallback ?? 'Not provided'
  const branches = branchesQuery.data?.items ?? []
  const departments = departmentsQuery.data?.items ?? []
  const roles = rolesQuery.data?.items ?? []
  const managers = (managersQuery.data?.items ?? []).filter(
    (manager) => manager.user_id !== employee?.user_id,
  )
  const managerOptions = managers.map((manager) => ({
    value: String(manager.user_id),
    label: `${manager.first_name} ${manager.last_name}`.trim(),
  }))
  const branchOptions = branches.map((item) => ({
    value: String(item.id),
    label: item.branch_name,
  }))
  const departmentOptions = departments.map((item) => ({
    value: String(item.id),
    label: item.name,
  }))
  const roleOptions = roles.map((item) => ({ value: String(item.id), label: item.name }))
  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next && !isSaving) onClose()
      }}
      title={employee ? 'Edit employee' : 'Add employee'}
      description={`Step ${step + 1} of ${STEPS.length} · ${STEPS[step]}`}
      size="xl"
      footer={
        <>
          <Button
            variant="outline"
            onClick={() => (step ? setStep(step - 1) : onClose())}
            disabled={isSaving}
          >
            {step ? 'Back' : 'Cancel'}
          </Button>
          {step < STEPS.length - 1 ? (
            <Button onClick={continueStep} disabled={isSaving}>
              {step === STEPS.length - 2 ? 'Review details' : 'Continue'}
            </Button>
          ) : (
            <Button type="submit" form="employee-form" isLoading={isSaving}>
              {employee ? 'Save changes' : 'Create employee'}
            </Button>
          )}
        </>
      }
    >
      <form id="employee-form" onSubmit={submit} className="space-y-4">
        <ol
          className="bg-surface-muted rounded-control flex min-w-0 gap-1 p-1.5"
          aria-label="Employee form steps"
        >
          {STEPS.map((title, index) => (
            <li
              key={title}
              aria-current={step === index ? 'step' : undefined}
              className={`rounded-control text-caption min-w-0 flex-1 px-1.5 py-2 text-center ${step === index ? 'bg-surface text-text-primary shadow-elevation-sm font-semibold' : 'text-text-muted'}`}
            >
              <span className="sm:hidden">{index + 1}</span>
              <span className="hidden sm:inline">
                {index + 1}. {title}
              </span>
            </li>
          ))}
        </ol>
        {error ? (
          <Alert tone="danger" role="alert" title={presentError(error, 'form-submit').title}>
            {presentError(error, 'form-submit').message} Your entered details are preserved.
          </Alert>
        ) : null}
        {step === 0 ? (
          <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
            <div className="border-border-subtle bg-surface rounded-control flex min-w-0 items-center gap-4 border p-3 sm:col-span-2">
              <span className="bg-primary-subtle text-primary rounded-control flex size-16 shrink-0 items-center justify-center overflow-hidden">
                {profileImageUrl ? (
                  <img
                    src={profileImageUrl}
                    alt="Employee profile photo preview"
                    className="size-full object-cover"
                    onError={() => setProfileImageUrl(null)}
                  />
                ) : (
                  <ImagePlus className="size-6" aria-hidden="true" />
                )}
              </span>
              <div className="min-w-0 flex-1 space-y-1.5">
                <FormControl
                  id="employee-profile-picture"
                  label="Profile photo"
                  description="PNG, JPG, or WEBP. Maximum file size: 15 MB."
                  error={profileImageError}
                >
                  <TextInput
                    type="file"
                    accept="image/png,image/jpeg,image/webp"
                    onChange={(event) => {
                      const file = event.currentTarget.files?.[0] ?? null
                      if (!file) return
                      const validType = ['image/png', 'image/jpeg', 'image/webp'].includes(
                        file.type,
                      )
                      if (!validType || file.size > PROFILE_IMAGE_MAX_BYTES) {
                        setProfileImageError(
                          !validType
                            ? 'Choose a PNG, JPG, or WEBP image.'
                            : 'Choose an image smaller than 15 MB.',
                        )
                        event.currentTarget.value = ''
                        return
                      }
                      setProfileImageError('')
                      if (profileImageObjectUrl.current)
                        URL.revokeObjectURL(profileImageObjectUrl.current)
                      const objectUrl = URL.createObjectURL(file)
                      profileImageObjectUrl.current = objectUrl
                      setProfileImageUrl(objectUrl)
                      setProfileImage(file)
                    }}
                    className="file:text-text-primary file:border-border-subtle file:bg-surface-muted file:rounded-control file:mr-3 file:border file:px-3 file:py-1.5"
                  />
                </FormControl>
                {profileImage?.name ? (
                  <p
                    className="text-caption text-text-secondary truncate"
                    title={profileImage.name}
                  >
                    Selected: {profileImage.name}
                  </p>
                ) : employee?.profile_picture ? (
                  <p className="text-caption text-text-muted">
                    Select a new image to replace this photo.
                  </p>
                ) : null}
              </div>
            </div>
            {field('first_name', 'First name', { required: true, maxLength: 150 })}
            {field('middle_name', 'Middle name')}
            {field('last_name', 'Last name', { required: true, maxLength: 150 })}
            {employee ? null : field('email', 'Work email', { required: true, type: 'email' })}
            {dateField('date_of_birth', 'Date of birth')}
            {select(
              'gender',
              'Gender',
              ['male', 'female', 'other'].map((value) => ({ value, label: statusLabel(value) })),
            )}
            {select(
              'marital_status',
              'Marital status',
              ['single', 'married', 'divorced', 'widowed'].map((value) => ({
                value,
                label: statusLabel(value),
              })),
            )}
            {field('nationality', 'Nationality')}
          </section>
        ) : null}
        {step === 1 ? (
          <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
            {field('phone_number', 'Phone number', { type: 'tel' })}
            {field('other_phone', 'Alternate phone', { type: 'tel' })}
            {field('personal_email', 'Personal email', { type: 'email' })}
            {field('country', 'Country')}
            {field('city', 'City')}
            {field('state', 'State / region')}
            {field('zip_code', 'Postal code')}
            {field('emergency_contact_name', 'Emergency contact name')}
            {field('emergency_contact_relationship', 'Relationship')}
            {field('emergency_contact_phone', 'Emergency contact phone', { type: 'tel' })}
            <FormControl id="employee-address" label="Address" className="sm:col-span-2">
              <TextArea
                value={draft.address ?? ''}
                onChange={(event) => patch('address', event.currentTarget.value)}
                rows={2}
                maxLength={500}
              />
            </FormControl>
          </section>
        ) : null}
        {step === 2 ? (
          <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
            {field('designation', 'Job title', { required: true })}
            {field('location', 'Work location')}
            {select(
              'employment_type',
              'Employment type',
              EMPLOYMENT_TYPES.map((value) => ({ value, label: statusLabel(value) })),
            )}
            {employee ? (
              <FormControl id="employee-employment-status" label="Current employment status">
                <div className="bg-surface border-border-subtle rounded-control flex min-h-11 flex-col justify-center gap-1 border px-3 py-2">
                  <span className="text-body-sm text-text-primary font-medium">
                    {statusLabel(employee.employment_status)}
                  </span>
                  <span className="text-caption text-text-secondary">
                    Use the profile actions to manage access, leave, deactivation, or exit.
                  </span>
                </div>
              </FormControl>
            ) : (
              select(
                'employment_status',
                'Employment status',
                ['active', 'on-probation', 'inactive', 'suspended'].map((value) => ({
                  value,
                  label: statusLabel(value),
                })),
              )
            )}
            {select('branch_id', 'Branch', branchOptions)}
            {select('department_id', 'Department', departmentOptions)}
            {select('role_id', 'Role', roleOptions)}
            {select('reporting_to_id', 'Reports to', managerOptions)}
            {dateField('start_date', 'Start date')}
            {field('probation_period', 'Probation (months)', { type: 'number' })}
            {field('work_schedule', 'Work schedule')}
            <fieldset className="border-border-subtle rounded-control space-y-2 border p-3 sm:col-span-2">
              <legend className="text-control-label text-text-secondary px-1 font-bold">
                Department units
              </legend>
              {selectedDepartmentIdOrNull === null ? (
                <p className="text-caption text-text-muted">
                  Choose a department to see its units.
                </p>
              ) : unitsQuery.isPending ? (
                <p role="status" className="text-caption text-text-muted">
                  Loading department units…
                </p>
              ) : unitsQuery.isError ? (
                <SectionErrorState
                  title="Units could not load"
                  description="Retry to choose department units, or continue without assigning any."
                  onRetry={() => void unitsQuery.refetch()}
                />
              ) : unitsQuery.data?.items.length ? (
                <div className="grid gap-2 sm:grid-cols-2">
                  {unitsQuery.data.items.map((unit) => (
                    <label
                      key={unit.id}
                      className="text-body-sm text-text-secondary flex min-h-10 items-center gap-2"
                    >
                      <input
                        type="checkbox"
                        checked={unitIds.includes(unit.id)}
                        onChange={(event) => {
                          const checked = event.currentTarget.checked
                          setUnitIds((current) =>
                            checked
                              ? [...current, unit.id]
                              : current.filter((id) => id !== unit.id),
                          )
                        }}
                      />
                      <span>{unit.name}</span>
                    </label>
                  ))}
                </div>
              ) : (
                <p className="text-caption text-text-muted">
                  No units are defined for this department.
                </p>
              )}
            </fieldset>
            {branchesQuery.isError ||
            departmentsQuery.isError ||
            rolesQuery.isError ||
            managersQuery.isError ? (
              <div className="sm:col-span-2">
                <SectionErrorState
                  title="Some assignment choices are unavailable"
                  description="You can keep this form open and retry the relevant list."
                  onRetry={() => {
                    void branchesQuery.refetch()
                    void departmentsQuery.refetch()
                    void rolesQuery.refetch()
                    void managersQuery.refetch()
                  }}
                />
              </div>
            ) : null}
          </section>
        ) : null}
        {step === 3 ? (
          <section className="bg-surface-muted border-border-subtle rounded-control grid gap-4 border p-4 sm:grid-cols-2">
            {field('gross_salary', 'Gross salary', { type: 'number' })}
            {select(
              'salary_frequency',
              'Salary frequency',
              ['monthly', 'weekly', 'yearly', 'daily'].map((value) => ({
                value,
                label: statusLabel(value),
              })),
            )}
            {field('bank_name', 'Bank name')}
            {field('account_number', 'Account number')}
            {field('tax_id', 'Tax ID')}
            {field('pension_number', 'Pension number')}
            {field('pfa_provider', 'Pension provider')}
            {field('rsa_number', 'RSA number')}
            {field('employer_contribution', 'Employer contribution', { type: 'number' })}
            {field('hmo_current_plan', 'HMO plan')}
            {field('hmo_id_number', 'HMO member ID')}
            {field('hmo_dependents_covered', 'Covered dependants', { type: 'number' })}
            <div className="space-y-3 sm:col-span-2">
              <div>
                <h3 className="text-label text-text-primary font-semibold">Allowances</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Add optional amounts in Nigerian naira. Leave a field blank when it does not
                  apply.
                </p>
              </div>
              <div className="grid gap-3 sm:grid-cols-3">
                {STANDARD_ALLOWANCE_FIELDS.map(({ key, label, draftKey }) => (
                  <FormControl
                    key={key}
                    id={`employee-${draftKey.replaceAll('_', '-')}`}
                    label={`${label} allowance (₦)`}
                    error={fieldErrors[draftKey]}
                  >
                    <TextInput
                      type="number"
                      step="any"
                      inputMode="decimal"
                      value={draft[draftKey] ?? ''}
                      onChange={(event) => patch(draftKey, event.currentTarget.value)}
                      placeholder="0.00"
                    />
                  </FormControl>
                ))}
              </div>
            </div>
          </section>
        ) : null}
        {step === 4 ? (
          <section className="space-y-4">
            <div className="border-border-subtle bg-surface-muted rounded-control border p-4">
              <h2 className="text-h3 font-semibold">Review employee details</h2>
              <p className="text-caption text-text-secondary mt-1">
                Confirm the information before{' '}
                {employee ? 'saving changes' : 'creating the employee'}. Sensitive identifiers are
                masked in this review.
              </p>
            </div>
            <EmployeeReviewGroup title="Identity" step={0} onEdit={setStep}>
              <EmployeeReviewValue
                label="Full name"
                value={[draft.first_name, draft.middle_name, draft.last_name]
                  .filter(Boolean)
                  .join(' ')}
              />
              <EmployeeReviewValue label="Work email" value={employee?.email ?? draft.email} />
              <EmployeeReviewValue label="Date of birth" value={draft.date_of_birth} />
              <EmployeeReviewValue label="Nationality" value={draft.nationality} />
              <EmployeeReviewValue
                label="Gender"
                value={draft.gender ? statusLabel(draft.gender) : ''}
              />
              <EmployeeReviewValue
                label="Marital status"
                value={draft.marital_status ? statusLabel(draft.marital_status) : ''}
              />
              <EmployeeReviewValue
                label="Profile photo"
                value={
                  profileImage?.name ??
                  (employee?.profile_picture ? 'Current photo retained' : 'No photo selected')
                }
              />
            </EmployeeReviewGroup>
            <EmployeeReviewGroup title="Contact" step={1} onEdit={setStep}>
              <EmployeeReviewValue label="Phone" value={draft.phone_number} />
              <EmployeeReviewValue label="Alternate phone" value={draft.other_phone} />
              <EmployeeReviewValue label="Personal email" value={draft.personal_email} />
              <EmployeeReviewValue label="Address" value={draft.address} />
              <EmployeeReviewValue
                label="Location"
                value={[draft.city, draft.state, draft.country].filter(Boolean).join(', ')}
              />
              <EmployeeReviewValue label="Postal code" value={draft.zip_code} />
              <EmployeeReviewValue label="Emergency contact" value={draft.emergency_contact_name} />
              <EmployeeReviewValue
                label="Emergency contact relationship"
                value={draft.emergency_contact_relationship}
              />
              <EmployeeReviewValue
                label="Emergency contact phone"
                value={draft.emergency_contact_phone}
              />
            </EmployeeReviewGroup>
            <EmployeeReviewGroup title="Employment" step={2} onEdit={setStep}>
              <EmployeeReviewValue label="Job title" value={draft.designation} />
              <EmployeeReviewValue
                label="Employment type"
                value={draft.employment_type ? statusLabel(draft.employment_type) : ''}
              />
              <EmployeeReviewValue
                label="Employment status"
                value={draft.employment_status ? statusLabel(draft.employment_status) : ''}
              />
              <EmployeeReviewValue
                label="Branch"
                value={selectedOptionLabel(draft.branch_id, branchOptions, employee?.branch_name)}
              />
              <EmployeeReviewValue
                label="Department"
                value={selectedOptionLabel(
                  draft.department_id,
                  departmentOptions,
                  employee?.department_name,
                )}
              />
              <EmployeeReviewValue
                label="Role"
                value={selectedOptionLabel(draft.role_id, roleOptions, employee?.role_name)}
              />
              <EmployeeReviewValue
                label="Reports to"
                value={selectedOptionLabel(
                  draft.reporting_to_id,
                  managerOptions,
                  employee?.reporting_to_id ? 'Existing manager assignment' : null,
                )}
              />
              <EmployeeReviewValue label="Start date" value={draft.start_date} />
              <EmployeeReviewValue label="Work location" value={draft.location} />
              <EmployeeReviewValue
                label="Probation period"
                value={draft.probation_period ? `${draft.probation_period} months` : ''}
              />
              <EmployeeReviewValue label="Work schedule" value={draft.work_schedule} />
              <EmployeeReviewValue
                label="Department units"
                value={unitsQuery.data?.items
                  .filter((unit) => unitIds.includes(unit.id))
                  .map((unit) => unit.name)
                  .join(', ')}
              />
            </EmployeeReviewGroup>
            <EmployeeReviewGroup title="Compensation and benefits" step={3} onEdit={setStep}>
              <EmployeeReviewValue
                label="Gross salary"
                value={
                  draft.gross_salary
                    ? `${draft.gross_salary} · ${statusLabel(draft.salary_frequency || 'monthly')}`
                    : ''
                }
              />
              <EmployeeReviewValue label="Bank" value={draft.bank_name} />
              <EmployeeReviewValue
                label="Account number"
                value={maskIdentifier(draft.account_number)}
              />
              <EmployeeReviewValue label="Tax ID" value={maskIdentifier(draft.tax_id)} />
              <EmployeeReviewValue
                label="Pension number"
                value={maskIdentifier(draft.pension_number)}
              />
              <EmployeeReviewValue label="RSA number" value={maskIdentifier(draft.rsa_number)} />
              <EmployeeReviewValue label="Pension provider" value={draft.pfa_provider} />
              <EmployeeReviewValue
                label="Employer contribution"
                value={draft.employer_contribution}
              />
              <EmployeeReviewValue label="HMO plan" value={draft.hmo_current_plan} />
              <EmployeeReviewValue
                label="HMO member ID"
                value={maskIdentifier(draft.hmo_id_number)}
              />
              <EmployeeReviewValue
                label="Covered dependants"
                value={draft.hmo_dependents_covered}
              />
              {STANDARD_ALLOWANCE_FIELDS.map(({ key, label, draftKey }) => (
                <EmployeeReviewValue
                  key={key}
                  label={`${label} allowance`}
                  value={formatNairaAmount(draft[draftKey])}
                />
              ))}
            </EmployeeReviewGroup>
          </section>
        ) : null}
      </form>
    </Dialog>
  )
}

function statusTone(status: string) {
  if (status === 'active') return 'success' as const
  if (status === 'on-probation' || status === 'on-leave') return 'warning' as const
  if (status === 'suspended' || status === 'terminated') return 'danger' as const
  return 'neutral' as const
}

function statusLabel(status: string) {
  return status.replaceAll('-', ' ').replace(/\b\w/g, (character) => character.toLocaleUpperCase())
}

export function EmployeesPage() {
  const search = useSearch({ from: '/_protected/hr/employees' }) as EmployeesSearch
  const navigate = useNavigate({ from: '/hr/employees' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canCreate = hasPermission(permissions, 'employees', 'create')
  const canUpdate = hasPermission(permissions, 'employees', 'update')
  const canExit = hasPermission(permissions, 'employees', 'exit')
  const params = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: search.search,
    view: search.view,
    branchId: search.branchId,
    departmentId: search.departmentId,
  }
  const listQuery = useQuery({
    queryKey: employeesQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => employeesApi.list(params, signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const branchesQuery = useQuery({
    queryKey: ['hr', 'employees', 'branch-choices', userId, employeeId],
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
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const departmentsQuery = useQuery({
    queryKey: ['hr', 'employees', 'department-choices', userId, employeeId],
    queryFn: ({ signal }) =>
      companyOrganizationApi.departments({ limit: 100, offset: 0, search: '' }, signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.reference,
  })
  const [editorOpen, setEditorOpen] = useState(false)
  const [editing, setEditing] = useState<EmployeeDto | null>(null)
  const [actionTarget, setActionTarget] = useState<EmployeeActionIntent | null>(null)
  const saveMutation = useMutation({
    mutationFn: async ({
      employee,
      input,
      profileImage,
    }: {
      employee: EmployeeDto | null
      input: EmployeeWriteInput
      profileImage: File | null
    }) => {
      const profilePicture = profileImage
        ? (await employeesApi.uploadProfilePicture(profileImage)).url
        : input.profile_picture
      const payload = { ...input, profile_picture: profilePicture }
      return employee
        ? employeesApi.update(employee.user_id, payload)
        : employeesApi.create(payload)
    },
    onSuccess: async (_result, variables) => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      showToast({
        tone: 'success',
        title: variables.employee ? 'Employee updated' : 'Employee added',
        description:
          `${variables.input.first_name ?? ''} ${variables.input.last_name ?? ''}`.trim(),
      })
      setEditorOpen(false)
      setEditing(null)
    },
  })
  const employeeActionMutation = useMutation<
    EmployeeDto | { detail: string },
    Error,
    EmployeeActionSubmission
  >({
    mutationFn: (submission: EmployeeActionSubmission) =>
      submission.type === 'status'
        ? employeesApi.update(submission.employee.user_id, {
            employment_status: submission.status,
          })
        : employeesApi.exit(submission.employee.user_id, {
            exit_date: submission.exitDate,
            reason: submission.reason,
          }),
    onSuccess: async (_result, submission) => {
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: employeesQueryKeys.all }),
        queryClient.invalidateQueries({ queryKey: ['hr', 'dashboard'] }),
      ])
      showToast({
        tone: 'success',
        title: submission.type === 'exit' ? 'Employee exited' : 'Employment status updated',
        description:
          submission.type === 'exit'
            ? 'Access has been disabled and the exit was recorded.'
            : `Status is now ${submission.status.replaceAll('-', ' ')}.`,
      })
      setActionTarget(null)
    },
  })
  const pageCount = Math.max(1, Math.ceil((listQuery.data?.count ?? 0) / search.pageSize))
  useEffect(() => {
    if (!listQuery.data || listQuery.isPlaceholderData || search.page <= pageCount) return
    void navigate({
      search: (previous: Record<string, unknown>) => ({
        ...validateEmployeesSearch(previous),
        page: pageCount,
      }),
      replace: true,
    })
  }, [listQuery.data, listQuery.isPlaceholderData, navigate, pageCount, search.page])
  const updateSearch = useCallback(
    (patch: Partial<EmployeesSearch>) =>
      void navigate({
        search: (previous: Record<string, unknown>) => ({
          ...validateEmployeesSearch(previous),
          ...patch,
          ...(patch.search !== undefined ||
          patch.view !== undefined ||
          patch.branchId !== undefined ||
          patch.departmentId !== undefined ||
          patch.pageSize !== undefined ||
          patch.page !== undefined
            ? { page: patch.page ?? 1 }
            : {}),
        }),
        replace: true,
      }),
    [navigate],
  )
  const commitSearch = useCallback(
    (value: string) => updateSearch({ search: value }),
    [updateSearch],
  )
  const openEditor = (employee: EmployeeDto | null) => {
    saveMutation.reset()
    setEditing(employee)
    setEditorOpen(true)
  }
  const openAction = (action: EmployeeActionIntent) => {
    employeeActionMutation.reset()
    setActionTarget(action)
  }
  return (
    <PageLayout
      title="Employees"
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="Add employee"
            leadingIcon={<Plus className="size-4" aria-hidden="true" />}
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
            onClick={() => openEditor(null)}
          >
            <span className="max-[479px]:hidden">Add employee</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-3.5 sm:p-4">
          <EmployeeStatusTabs view={search.view} onChange={(view) => updateSearch({ view })} />
          <div className="grid min-w-0 grid-cols-2 gap-3">
            <div className="col-span-2 min-w-0">
              <EmployeeSearchInput
                key={search.search}
                search={search.search}
                onCommit={commitSearch}
              />
            </div>
            <FormControl id="employee-branch-filter" label="Branch">
              <DropdownSelect
                id="employee-branch-filter"
                value={search.branchId}
                onChange={(branchId) => updateSearch({ branchId })}
                options={[
                  { value: 'all', label: 'All branches' },
                  ...(branchesQuery.data?.items ?? []).map((branch) => ({
                    value: String(branch.id),
                    label: branch.branch_name,
                  })),
                ]}
                placeholder={branchesQuery.isPending ? 'Loading branches' : 'All branches'}
                disabled={branchesQuery.isPending && !branchesQuery.data}
              />
            </FormControl>
            <FormControl id="employee-department-filter" label="Department">
              <DropdownSelect
                id="employee-department-filter"
                value={search.departmentId}
                onChange={(departmentId) => updateSearch({ departmentId })}
                options={[
                  { value: 'all', label: 'All departments' },
                  ...(departmentsQuery.data?.items ?? []).map((department) => ({
                    value: String(department.id),
                    label: department.name,
                  })),
                ]}
                placeholder={departmentsQuery.isPending ? 'Loading departments' : 'All departments'}
                disabled={departmentsQuery.isPending && !departmentsQuery.data}
              />
            </FormControl>
          </div>
          {branchesQuery.isError || departmentsQuery.isError ? (
            <SectionErrorState
              title="Some employee filters could not load"
              description="The directory remains available. Retry to restore the missing branch or department choices."
              onRetry={() => {
                void branchesQuery.refetch()
                void departmentsQuery.refetch()
              }}
            />
          ) : null}
        </Card>
        <div
          id="employee-results"
          role="tabpanel"
          aria-labelledby={`employee-view-tab-${search.view}`}
          tabIndex={0}
          className="space-y-4 focus-visible:outline-none"
        >
          {listQuery.isPending && !listQuery.data ? (
            <div className="space-y-3" role="status" aria-label="Loading employees">
              {[1, 2, 3].map((key) => (
                <Skeleton key={key} variant="card" />
              ))}
            </div>
          ) : null}
          {listQuery.isError && !listQuery.data ? (
            <ErrorState
              title="Employee directory could not load"
              description="Try again to reload employees in your authorized scope."
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          ) : null}
          {listQuery.isError && listQuery.data ? (
            <SectionErrorState
              title="Employee list refresh failed"
              description="Showing the last loaded results."
              onRetry={() => void listQuery.refetch()}
            />
          ) : null}
          {listQuery.data?.items.length ? (
            <section aria-label="Employee results" className="space-y-4">
              <div className="desktop:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
                {listQuery.data.items.map((employee) => {
                  const name = [employee.first_name, employee.middle_name, employee.last_name]
                    .filter(Boolean)
                    .join(' ')
                  const canViewEmployee =
                    hasPermission(permissions, 'employees', 'view') ||
                    (employee.user_id === session?.user.id &&
                      hasPermission(permissions, 'employees', 'view_own'))
                  const identity = (
                    <>
                      <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center overflow-hidden">
                        {employee.profile_picture ? (
                          <img
                            src={employee.profile_picture}
                            alt=""
                            className="size-full object-cover"
                          />
                        ) : (
                          <UserRound className="size-5" aria-hidden="true" />
                        )}
                      </span>
                      <span className="min-w-0">
                        <span className="text-label text-text-primary block truncate font-semibold">
                          {name}
                        </span>
                        <span className="text-caption text-text-secondary mt-1 block break-words">
                          {employee.designation || 'Position not set'}
                        </span>
                        <span className="text-caption text-text-muted mt-1 block break-words">
                          {employee.employee_id} · {employee.department_name ?? 'No department'}
                          {employee.branch_name ? ` · ${employee.branch_name}` : ''}
                        </span>
                      </span>
                    </>
                  )
                  return (
                    <Card key={employee.user_id} className="flex min-w-0 flex-col space-y-0 p-0">
                      <div className="flex min-w-0 flex-1 items-start gap-3 p-3.5 sm:p-4">
                        {canViewEmployee ? (
                          <Link
                            to="/hr/employees/$userId"
                            params={{ userId: String(employee.user_id) }}
                            aria-label={`View profile for ${name}`}
                            className="group rounded-control focus-visible:shadow-focus-ring flex min-w-0 flex-1 items-start gap-3 focus-visible:outline-none"
                          >
                            {identity}
                          </Link>
                        ) : (
                          <div className="flex min-w-0 flex-1 items-start gap-3">{identity}</div>
                        )}
                        <div className="shrink-0 pt-0.5">
                          <StatusChip
                            label={statusLabel(employee.employment_status)}
                            tone={statusTone(employee.employment_status)}
                          />
                        </div>
                      </div>
                      <div className="border-border-subtle flex min-w-0 justify-end border-t px-3.5 py-2.5 sm:px-4">
                        <EmployeeRowActions
                          employee={employee}
                          canView={canViewEmployee}
                          canUpdate={canUpdate}
                          canExit={canExit}
                          onEdit={openEditor}
                          onStatusChange={(target, status) =>
                            openAction({ type: 'status', employee: target, status })
                          }
                          onExit={(target) => openAction({ type: 'exit', employee: target })}
                        />
                      </div>
                    </Card>
                  )
                })}
              </div>
              <div className="border-border-subtle flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex flex-wrap items-center justify-between gap-x-4 gap-y-2">
                  <p className="text-caption text-text-secondary">
                    Showing{' '}
                    {listQuery.data.count === 0 ? 0 : (search.page - 1) * search.pageSize + 1}–
                    {Math.min(search.page * search.pageSize, listQuery.data.count)} of{' '}
                    {listQuery.data.count} employees
                  </p>
                  <FormControl id="employee-page-size" label="Rows per page">
                    <DropdownSelect
                      id="employee-page-size"
                      value={String(search.pageSize)}
                      onChange={(value) =>
                        updateSearch({
                          pageSize: Number(value) as EmployeesSearch['pageSize'],
                        })
                      }
                      options={[5, 10, 20, 50].map((size) => ({
                        value: String(size),
                        label: String(size),
                      }))}
                      className="w-24"
                    />
                  </FormControl>
                </div>
                <div className="flex justify-between gap-2 sm:justify-end">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={search.page <= 1 || listQuery.isFetching}
                    leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
                    onClick={() => updateSearch({ page: search.page - 1 })}
                  >
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={search.page >= pageCount || listQuery.isFetching}
                    onClick={() => updateSearch({ page: search.page + 1 })}
                  >
                    Next
                    <ChevronRight className="size-4" aria-hidden="true" />
                  </Button>
                </div>
              </div>
            </section>
          ) : null}
          {!listQuery.isPending && !listQuery.isError && listQuery.data?.items.length === 0 ? (
            <Card>
              <EmptyState
                title={
                  search.search || search.branchId !== 'all' || search.departmentId !== 'all'
                    ? 'No employees match these filters'
                    : search.view === 'active'
                      ? 'No active employees'
                      : 'No past employees'
                }
                description="Adjust the search and filters, or add an employee if you have access."
                action={
                  search.search || search.branchId !== 'all' || search.departmentId !== 'all' ? (
                    <Button
                      variant="outline"
                      onClick={() =>
                        updateSearch({ search: '', branchId: 'all', departmentId: 'all' })
                      }
                    >
                      Clear filters
                    </Button>
                  ) : undefined
                }
              />
            </Card>
          ) : null}
        </div>
      </div>
      {editorOpen ? (
        <EmployeeEditor
          key={editing?.user_id ?? 'new-employee'}
          open
          employee={editing}
          onClose={() => {
            if (!saveMutation.isPending) {
              setEditorOpen(false)
              setEditing(null)
            }
          }}
          onSave={(input, profileImage) =>
            saveMutation.mutate({ employee: editing, input, profileImage })
          }
          isSaving={saveMutation.isPending}
          error={saveMutation.error}
        />
      ) : null}
      <EmployeeActionDialog
        action={actionTarget}
        isPending={employeeActionMutation.isPending}
        error={employeeActionMutation.error}
        onClose={() => {
          if (!employeeActionMutation.isPending) setActionTarget(null)
        }}
        onConfirm={(submission) => employeeActionMutation.mutate(submission)}
      />
    </PageLayout>
  )
}
