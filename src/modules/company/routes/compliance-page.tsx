import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  AlertTriangle,
  ArrowUpRight,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Clock3,
  ExternalLink,
  FileCheck2,
  Pencil,
  Plus,
  Search,
  Trash2,
} from 'lucide-react'
import { useCallback, useEffect, useState, type FormEvent } from 'react'

import {
  governanceApi,
  complianceApi,
  compliancePriorities,
  complianceQueryKeys,
  complianceRecordTypes,
  complianceStatuses,
  type ComplianceListParams,
  type ComplianceRecordDto,
} from '@/modules/company/governance.api'
import {
  complianceState,
  complianceTypeLabel,
  formatComplianceDate,
  safeComplianceDocumentUrl,
} from '@/modules/company/compliance-presentation'
import { AttachmentPicker } from '@/modules/company/components/governance-file-picker'
import { governanceUploadFileKey } from '@/modules/company/components/governance-file-picker-utils'
import {
  companyOrganizationApi,
  type DepartmentDto,
} from '@/modules/company/company-organization.api'
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
import { StatusChip } from '@/shared/ui/status-chip'

import type { ComplianceSearch } from '../governance.search'

const PAGE_SIZE = 10

type ComplianceDraft = {
  full_name: string
  email_address: string
  phone_number: string
  department_id: string
  compliance_type: string
  reference_number: string
  date_of_issue: string
  expiry_date: string
  issuing_authority: string
  status: string
  description: string
  contact_person: string
  contact_email: string
  cost: string
  priority_level: string
}

function draftFrom(record: ComplianceRecordDto | null): ComplianceDraft {
  return {
    full_name: record?.full_name ?? '',
    email_address: record?.email_address ?? '',
    phone_number: record?.phone_number ?? '',
    department_id: record ? String(record.department_id) : '',
    compliance_type: record?.compliance_type ?? complianceRecordTypes[0]?.value ?? '',
    reference_number: record?.reference_number ?? '',
    date_of_issue: record?.date_of_issue ?? '',
    expiry_date: record?.expiry_date ?? '',
    issuing_authority: record?.issuing_authority ?? '',
    status: record?.status ?? 'pending',
    description: record?.description ?? '',
    contact_person: record?.contact_person ?? '',
    contact_email: record?.contact_email ?? '',
    cost: record?.cost == null ? '' : String(record.cost),
    priority_level: record?.priority_level ?? '',
  }
}

function ComplianceSearchControl({
  search,
  onCommit,
}: {
  search: string
  onCommit: (value: string) => void
}) {
  const [value, setValue] = useState(search)
  useEffect(() => {
    const next = value.trim()
    if (next === search) return
    const timer = window.setTimeout(() => onCommit(next), 250)
    return () => window.clearTimeout(timer)
  }, [onCommit, search, value])
  return (
    <div className="space-y-1.5">
      <label
        htmlFor="compliance-search"
        className="text-control-label text-text-secondary block font-bold"
      >
        Search records
      </label>
      <div className="relative">
        <Search
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="compliance-search"
          type="search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Name, email, phone, or reference"
          className="pl-10"
        />
      </div>
    </div>
  )
}

function ComplianceEditor({
  record,
  departments,
  departmentsLoading,
  departmentsError,
  canBrowseDepartments,
  saving,
  onClose,
  onSave,
  onRetryDepartments,
}: {
  record: ComplianceRecordDto | null
  departments: DepartmentDto[]
  departmentsLoading: boolean
  departmentsError: unknown
  canBrowseDepartments: boolean
  saving: boolean
  onClose: () => void
  onSave: (recordId: number | null, payload: Record<string, unknown>) => Promise<void>
  onRetryDepartments: () => void
}) {
  const [draft, setDraft] = useState(() => draftFrom(record))
  const [error, setError] = useState('')
  const [existingDocuments, setExistingDocuments] = useState(() => record?.documents ?? [])
  const [documentFiles, setDocumentFiles] = useState<File[]>([])
  const [uploadedDocuments, setUploadedDocuments] = useState<Record<string, string>>({})
  const [uploading, setUploading] = useState(false)
  const [departmentId, setDepartmentId] = useState(draft.department_id)
  const update = (key: keyof ComplianceDraft, value: string) => {
    const nextIssueDate = key === 'date_of_issue' ? value : draft.date_of_issue
    const nextExpiryDate = key === 'expiry_date' ? value : draft.expiry_date
    if (
      error === 'Expiry date must be after the date of issue.' &&
      nextExpiryDate > nextIssueDate
    ) {
      setError('')
    }
    setDraft((previous) => ({ ...previous, [key]: value }))
  }
  const departmentOptions = departments.map((department) => ({
    value: String(department.id),
    label: department.name,
  }))
  if (
    record &&
    !departmentOptions.some((option) => option.value === String(record.department_id))
  ) {
    departmentOptions.push({
      value: String(record.department_id),
      label: `Department ${record.department_id} · current`,
    })
  }
  const hasDepartmentSelection = Boolean(
    departmentId && Number.isInteger(Number(departmentId)) && Number(departmentId) > 0,
  )

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    if (!departmentId || !Number.isInteger(Number(departmentId)) || Number(departmentId) < 1) {
      setError('Choose a valid department.')
      return
    }
    if (draft.expiry_date <= draft.date_of_issue) {
      setError('Expiry date must be after the date of issue.')
      return
    }
    const payload: Record<string, unknown> = {
      ...draft,
      department_id: Number(departmentId),
      reference_number: draft.reference_number.trim() || null,
      description: draft.description.trim() || null,
      contact_person: draft.contact_person.trim() || null,
      contact_email: draft.contact_email.trim() || null,
      cost: draft.cost.trim() ? Number(draft.cost) : null,
      priority_level: draft.priority_level || null,
      documents: [...existingDocuments],
    }
    try {
      if (documentFiles.length) {
        setUploading(true)
        const documents = payload.documents as string[]
        for (const file of documentFiles) {
          const key = governanceUploadFileKey(file)
          let url = uploadedDocuments[key]
          if (!url) {
            url = (await governanceApi.uploadFile(file)).url
            setUploadedDocuments((previous) => ({ ...previous, [key]: url }))
          }
          if (!documents.includes(url)) documents.push(url)
        }
      }
      await onSave(record?.id ?? null, payload)
      onClose()
    } catch (cause) {
      setError(presentError(cause, 'form-submit').message)
    } finally {
      setUploading(false)
    }
  }

  return (
    <Dialog
      open
      onOpenChange={(open) => !open && onClose()}
      title={record ? 'Edit compliance record' : 'New compliance record'}
      description="Keep the licence details and dates current for the responsible person."
      size="lg"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="compliance-record-form"
            isLoading={saving || uploading}
            disabled={!hasDepartmentSelection || (!record && !departments.length)}
          >
            {record ? 'Save changes' : 'Create record'}
          </Button>
        </>
      }
    >
      <form
        id="compliance-record-form"
        onSubmit={(event) => void submit(event)}
        className="space-y-5"
      >
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
        {departmentsError && !departments.length && canBrowseDepartments ? (
          <SectionErrorState
            error={departmentsError}
            title="Departments could not be loaded"
            onRetry={onRetryDepartments}
          />
        ) : null}
        {!canBrowseDepartments ? (
          <Alert tone="info">
            Your access does not include department browsing. This record keeps its current
            department; department assignment is unavailable here.
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Responsible person</h3>
            <p className="text-caption text-text-secondary mt-0.5">
              Identity and department associated with the compliance record.
            </p>
          </div>
          <div className="tablet:grid-cols-2 grid gap-4">
            <FormControl id="compliance-full-name" label="Full name" required>
              <TextInput
                id="compliance-full-name"
                required
                maxLength={255}
                value={draft.full_name}
                onChange={(e) => update('full_name', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="compliance-department" label="Department" required>
              <DropdownSelect
                id="compliance-department"
                value={departmentId}
                options={departmentOptions}
                onChange={setDepartmentId}
                placeholder={departmentsLoading ? 'Loading departments…' : 'Choose a department'}
                disabled={
                  departmentsLoading ||
                  (!canBrowseDepartments && Boolean(record)) ||
                  departmentOptions.length === 0
                }
                searchable
              />
            </FormControl>
            <FormControl id="compliance-email" label="Email" required>
              <TextInput
                id="compliance-email"
                type="email"
                required
                value={draft.email_address}
                onChange={(e) => update('email_address', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="compliance-phone" label="Phone" required>
              <TextInput
                id="compliance-phone"
                type="tel"
                required
                value={draft.phone_number}
                onChange={(e) => update('phone_number', e.currentTarget.value)}
              />
            </FormControl>
          </div>
        </FormSection>
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Compliance document</h3>
            <p className="text-caption text-text-secondary mt-0.5">
              Type, issuing authority, validity dates, and reference.
            </p>
          </div>
          <div className="phone:grid-cols-2 grid gap-4">
            <FormControl id="compliance-type" label="Compliance type" required>
              <DropdownSelect
                id="compliance-type"
                value={draft.compliance_type}
                options={complianceRecordTypes.map((item) => ({ ...item }))}
                onChange={(value) => update('compliance_type', value)}
              />
            </FormControl>
            <FormControl id="compliance-reference" label="Reference number">
              <TextInput
                id="compliance-reference"
                value={draft.reference_number}
                onChange={(e) => update('reference_number', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="compliance-issue-date" label="Date of issue" required>
              <DatePickerField
                required
                value={draft.date_of_issue}
                onValueChange={(value) => update('date_of_issue', value)}
              />
            </FormControl>
            <FormControl id="compliance-expiry-date" label="Expiry date" required>
              <DatePickerField
                min={draft.date_of_issue || undefined}
                required
                value={draft.expiry_date}
                onValueChange={(value) => update('expiry_date', value)}
              />
            </FormControl>
            <FormControl
              id="compliance-authority"
              label="Issuing authority"
              required
              className="phone:col-span-2"
            >
              <TextInput
                id="compliance-authority"
                required
                value={draft.issuing_authority}
                onChange={(e) => update('issuing_authority', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="compliance-status" label="Status" required>
              <DropdownSelect
                id="compliance-status"
                value={draft.status}
                options={complianceStatuses.map((item) => ({ ...item }))}
                onChange={(value) => update('status', value)}
              />
            </FormControl>
            <FormControl id="compliance-priority" label="Priority">
              <DropdownSelect
                id="compliance-priority"
                value={draft.priority_level}
                options={[
                  { value: '', label: 'No priority' },
                  ...compliancePriorities.map((item) => ({ ...item })),
                ]}
                onChange={(value) => update('priority_level', value)}
              />
            </FormControl>
            <FormControl id="compliance-cost" label="Cost">
              <TextInput
                id="compliance-cost"
                type="number"
                min="0"
                max="99999999.99"
                step="0.01"
                value={draft.cost}
                onChange={(e) => update('cost', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl
              id="compliance-description"
              label="Description"
              className="phone:col-span-2"
            >
              <TextArea
                id="compliance-description"
                rows={3}
                value={draft.description}
                onChange={(e) => update('description', e.currentTarget.value)}
              />
            </FormControl>
          </div>
        </FormSection>
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Contact and documents</h3>
            <p className="text-caption text-text-secondary mt-0.5">
              Optional contact details and supporting files.
            </p>
          </div>
          <div className="tablet:grid-cols-2 grid gap-4">
            <FormControl id="compliance-contact-person" label="Contact person">
              <TextInput
                id="compliance-contact-person"
                value={draft.contact_person}
                onChange={(e) => update('contact_person', e.currentTarget.value)}
              />
            </FormControl>
            <FormControl id="compliance-contact-email" label="Contact email">
              <TextInput
                id="compliance-contact-email"
                type="email"
                value={draft.contact_email}
                onChange={(e) => update('contact_email', e.currentTarget.value)}
              />
            </FormControl>
            {existingDocuments.length ? (
              <div className="tablet:col-span-2 space-y-2">
                <p className="text-control-label text-text-secondary">Current attachments</p>
                <ul className="phone:grid-cols-2 grid gap-2">
                  {existingDocuments.map((rawUrl, index) => {
                    const url = safeComplianceDocumentUrl(rawUrl)
                    return (
                      <li
                        key={`${record?.id ?? 'new'}-${rawUrl}-${index}`}
                        className="border-border-subtle bg-surface rounded-control flex min-w-0 items-center justify-between gap-2 border px-3 py-2"
                      >
                        {url ? (
                          <a
                            href={url}
                            target="_blank"
                            rel="noreferrer"
                            className="text-caption text-primary inline-flex min-w-0 items-center gap-2 hover:underline"
                          >
                            <ExternalLink className="size-3.5 shrink-0" aria-hidden="true" />
                            <span className="truncate">Document {index + 1}</span>
                          </a>
                        ) : (
                          <span className="text-caption text-text-muted min-w-0 truncate">
                            Document {index + 1} · link unavailable
                          </span>
                        )}
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          aria-label={`Remove document ${index + 1}`}
                          disabled={saving || uploading}
                          onClick={() =>
                            setExistingDocuments((previous) =>
                              previous.filter((_, documentIndex) => documentIndex !== index),
                            )
                          }
                        >
                          <Trash2 className="size-3.5" aria-hidden="true" />
                        </Button>
                      </li>
                    )
                  })}
                </ul>
              </div>
            ) : null}
            <FormControl
              id="compliance-document-files"
              label="Add supporting files"
              className="tablet:col-span-2"
            >
              <AttachmentPicker
                id="compliance-document-files"
                files={documentFiles}
                multiple
                disabled={saving || uploading}
                onChange={setDocumentFiles}
              />
            </FormControl>
          </div>
        </FormSection>
      </form>
    </Dialog>
  )
}

function ComplianceCard({
  record,
  search,
  canView,
  canEdit,
  canDelete,
  onEdit,
  onDelete,
}: {
  record: ComplianceRecordDto
  search: ComplianceSearch
  canView: boolean
  canEdit: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  const state = complianceState(record)
  const priority = compliancePriorities.find((item) => item.value === record.priority_level)?.label
  return (
    <article className="border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-sm rounded-control shadow-elevation-sm min-w-0 overflow-hidden border transition-colors">
      <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <FileCheck2 className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 flex-wrap items-start justify-between gap-2">
            <div className="min-w-0 flex-1 space-y-1">
              <h2 className="text-label text-text-primary font-semibold break-words">
                {complianceTypeLabel(record.compliance_type)}
              </h2>
              <p className="text-caption text-text-secondary break-words">
                <span className="text-text-primary font-medium">{record.full_name}</span>
                <span aria-hidden="true"> · </span>
                {record.issuing_authority || 'Issuing authority not provided'}
              </p>
            </div>
            <div className="flex shrink-0 flex-wrap items-center gap-2">
              <StatusChip label={state.label} tone={state.tone} dense />
              {priority ? <StatusChip label={`${priority} priority`} tone="neutral" dense /> : null}
            </div>
          </div>
        </div>
      </header>

      <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
        <div className="min-w-0">
          <dt className="text-caption text-text-muted inline-flex items-center gap-1.5">
            <CalendarDays className="size-3.5 shrink-0" aria-hidden="true" />
            Issued
          </dt>
          <dd className="text-body-sm text-text-primary mt-1 break-words">
            {formatComplianceDate(record.date_of_issue)}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted inline-flex items-center gap-1.5">
            <Clock3 className="size-3.5 shrink-0" aria-hidden="true" />
            Expires
          </dt>
          <dd className="text-body-sm text-text-primary mt-1 break-words">
            {formatComplianceDate(record.expiry_date)}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Reference</dt>
          <dd className="text-body-sm text-text-primary mt-1 break-all">
            {record.reference_number || 'Not provided'}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Responsible email</dt>
          <dd className="text-body-sm text-text-primary mt-1 break-all">
            <a className="hover:text-primary" href={`mailto:${record.email_address}`}>
              {record.email_address}
            </a>
          </dd>
        </div>
      </dl>

      {state.hint ? (
        <div className="border-border-subtle phone:px-5 border-t px-4 py-3">
          <p className="text-caption text-warning-foreground inline-flex items-center gap-1.5">
            <AlertTriangle className="size-3.5 shrink-0" aria-hidden="true" />
            {state.hint}
          </p>
        </div>
      ) : null}
      {record.description ? (
        <div className="border-border-subtle phone:px-5 border-t px-4 py-3">
          <p className="text-overline text-text-muted">Summary</p>
          <p className="text-body-sm text-text-secondary mt-1 line-clamp-2 break-words">
            {record.description}
          </p>
        </div>
      ) : null}
      <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
        <p className="text-overline text-text-muted min-w-0 break-all">
          Record ID · {record.reference_number || `#${record.id}`}
        </p>
        <div className="phone:justify-end flex min-w-0 flex-wrap items-center gap-2">
          {canView ? (
            <Link
              to="/company/compliance/$recordId"
              params={{ recordId: String(record.id) }}
              search={search}
              className="text-caption text-primary border-primary/20 bg-primary-subtle/45 hover:bg-primary-subtle focus-visible:shadow-focus-ring rounded-control inline-flex min-h-9 items-center justify-center gap-2 border px-3 font-semibold transition-colors focus-visible:outline-none"
            >
              Details <ArrowUpRight className="size-3.5" aria-hidden="true" />
            </Link>
          ) : null}
          {canEdit ? (
            <Button
              variant="outline"
              size="sm"
              onClick={onEdit}
              leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
            >
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button
              variant="outline"
              size="sm"
              onClick={onDelete}
              leadingIcon={<Trash2 className="size-3.5" aria-hidden="true" />}
            >
              Delete
            </Button>
          ) : null}
        </div>
      </footer>
    </article>
  )
}

export function CompliancePage() {
  const search = useSearch({ from: '/_protected/company/compliance' }) as ComplianceSearch
  const navigate = useNavigate({ from: '/company/compliance' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const [editor, setEditor] = useState<ComplianceRecordDto | null | undefined>(undefined)
  const [deleteRecord, setDeleteRecord] = useState<ComplianceRecordDto | null>(null)
  const canList = hasPermission(permissions, 'compliance_records', 'list')
  const canView = hasPermission(permissions, 'compliance_records', 'view')
  const canCreate = hasPermission(permissions, 'compliance_records', 'create')
  const canEdit = hasPermission(permissions, 'compliance_records', 'update')
  const canDelete = hasPermission(permissions, 'compliance_records', 'delete')
  const canBrowseDepartments = hasPermission(permissions, 'departments', 'list')
  const params: ComplianceListParams = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    complianceType: search.complianceType,
  }
  const listQuery = useQuery({
    queryKey: complianceQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => complianceApi.list(params, signal),
    enabled: Boolean(session && canList),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const departmentQuery = useQuery({
    queryKey: complianceQueryKeys.departments(userId, employeeId),
    queryFn: ({ signal }) =>
      companyOrganizationApi.departments({ limit: 100, offset: 0, search: '' }, signal),
    enabled: Boolean(
      session && editor !== undefined && hasPermission(permissions, 'departments', 'list'),
    ),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const saveMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number | null; payload: Record<string, unknown> }) =>
      id ? complianceApi.update(id, payload) : complianceApi.create(payload),
    onSuccess: async (_result, variables) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.lists(userId, employeeId),
        }),
        ...(variables.id
          ? [
              queryClient.invalidateQueries({
                queryKey: complianceQueryKeys.detail(userId, employeeId, variables.id),
              }),
            ]
          : []),
      ])
      setEditor(undefined)
      showToast({
        title: variables.id ? 'Compliance record updated' : 'Compliance record created',
        description: 'The compliance register is up to date.',
        tone: 'success',
      })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (id: number) => complianceApi.delete(id),
    onSuccess: async (_result, id) => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.lists(userId, employeeId),
        }),
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.detail(userId, employeeId, id),
        }),
      ])
      setDeleteRecord(null)
      showToast({
        title: 'Compliance record deleted',
        description: 'The record has been removed.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Record could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })
  const updateSearch = useCallback(
    (value: string) =>
      void navigate({
        search: (previous: ComplianceSearch) => ({ ...previous, search: value, page: 1 }),
      }),
    [navigate],
  )
  const records = listQuery.data?.items ?? []
  const total = listQuery.data?.count ?? 0
  const departmentChoices = departmentQuery.data?.items ?? []

  return (
    <PageLayout
      title="Compliance register"
      subtitle="Track licences, regulatory records, and upcoming expiry dates."
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Governance & oversight</p>
              <h2 className="text-h2 mt-1 font-semibold">Records</h2>
              <p className="text-caption text-text-secondary mt-1">
                {total.toLocaleString()} record{total === 1 ? '' : 's'} in this view
              </p>
            </div>
            {canCreate ? (
              <Button
                className="shrink-0"
                size="sm"
                onClick={() => setEditor(null)}
                leadingIcon={<Plus className="size-4" aria-hidden="true" />}
              >
                New
              </Button>
            ) : null}
          </div>
          <div className="tablet:grid-cols-[minmax(16rem,1fr)_minmax(12rem,0.5fr)] tablet:items-end grid gap-3">
            <ComplianceSearchControl
              key={search.search}
              search={search.search}
              onCommit={updateSearch}
            />
            <FormControl id="compliance-type-filter" label="Compliance type">
              <DropdownSelect
                id="compliance-type-filter"
                value={search.complianceType}
                options={[
                  { value: '', label: 'All compliance types' },
                  ...complianceRecordTypes.map((item) => ({ ...item })),
                ]}
                onChange={(value) =>
                  void navigate({
                    search: (previous: ComplianceSearch) => ({
                      ...previous,
                      complianceType: value,
                      page: 1,
                    }),
                  })
                }
              />
            </FormControl>
          </div>
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
            title="Compliance records could not be loaded"
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
              icon={<FileCheck2 className="size-5" aria-hidden="true" />}
              title="No compliance records found"
              description={
                search.search || search.complianceType
                  ? 'Try a different search or clear the type filter.'
                  : 'Add the first record to start tracking compliance requirements.'
              }
              action={
                canCreate ? (
                  <Button
                    onClick={() => setEditor(null)}
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
              <ComplianceCard
                key={record.id}
                record={record}
                search={search}
                canView={canView}
                canEdit={canEdit}
                canDelete={canDelete}
                onEdit={() => setEditor(record)}
                onDelete={() => setDeleteRecord(record)}
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
                    search: (previous: ComplianceSearch) => ({
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
                    search: (previous: ComplianceSearch) => ({
                      ...previous,
                      page: search.page + 1,
                    }),
                  })
                }
              >
                Next
                <ChevronRight className="size-4" aria-hidden="true" />
              </Button>
            </div>
          </Card>
        ) : null}

        {editor !== undefined ? (
          <ComplianceEditor
            record={editor}
            departments={departmentChoices}
            departmentsLoading={departmentQuery.isPending && canBrowseDepartments}
            departmentsError={departmentQuery.error}
            canBrowseDepartments={canBrowseDepartments}
            saving={saveMutation.isPending}
            onClose={() => setEditor(undefined)}
            onSave={async (id, payload) => {
              await saveMutation.mutateAsync({ id, payload })
            }}
            onRetryDepartments={() => void departmentQuery.refetch()}
          />
        ) : null}
        {deleteRecord ? (
          <Dialog
            open
            onOpenChange={(open) => !open && setDeleteRecord(null)}
            title="Delete compliance record?"
            description="This permanently removes the record from the register."
            size="sm"
            fitContent
            compactOnMobile
            footer={
              <>
                <Button variant="outline" onClick={() => setDeleteRecord(null)}>
                  Cancel
                </Button>
                <Button
                  variant="danger"
                  isLoading={deleteMutation.isPending}
                  onClick={() => deleteMutation.mutate(deleteRecord.id)}
                >
                  Delete record
                </Button>
              </>
            }
          >
            <Alert tone="warning">
              This action cannot be undone. {complianceTypeLabel(deleteRecord.compliance_type)} ·{' '}
              {deleteRecord.full_name}
            </Alert>
          </Dialog>
        ) : null}
      </div>
    </PageLayout>
  )
}
