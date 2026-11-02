import { useEffect, useRef, useState, type FormEvent, type ReactNode } from 'react'
import { useForm } from '@tanstack/react-form'
import { useQuery } from '@tanstack/react-query'
import {
  CircleDollarSign,
  CheckCircle2,
  ChevronLeft,
  ExternalLink,
  FileText,
  ImagePlus,
  MapPin,
  Package2,
  Paperclip,
  Pencil,
  Trash2,
  Upload,
} from 'lucide-react'

import {
  assetQueryKeys,
  assetsApi,
  type AssetChoiceDto,
  type AssetDto,
  type AssetStatus,
  type AssetType,
  type AssetWriteInput,
} from '@/modules/company/assets.api'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import {
  CreationFlowActions,
  CreationFlowStepper,
  type CreationFlowStep,
} from '@/shared/ui/creation-flow'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { SectionErrorState } from '@/shared/ui/feedback-states'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

const assetTypeOptions: DropdownSelectOption[] = [
  { value: 'laptop', label: 'Laptop' },
  { value: 'printer', label: 'Printer' },
  { value: 'vehicle', label: 'Vehicle' },
  { value: 'furniture', label: 'Furniture' },
  { value: 'equipment', label: 'Equipment' },
  { value: 'other', label: 'Other' },
]

const statusOptions: DropdownSelectOption[] = [
  { value: 'available', label: 'Available' },
  { value: 'in_use', label: 'In use' },
  { value: 'maintenance', label: 'Maintenance' },
  { value: 'retired', label: 'Retired' },
  { value: 'lost_stolen', label: 'Lost or stolen' },
]

type AssetFlowStep = 'identity' | 'location' | 'records' | 'review'

const ASSET_FLOW_STEPS: (CreationFlowStep & { id: AssetFlowStep })[] = [
  {
    id: 'identity',
    label: 'Asset',
    compactLabel: 'Asset',
    title: 'Asset information',
    detail: 'Identify the asset and its manufacturer.',
  },
  {
    id: 'location',
    label: 'Location',
    compactLabel: 'Place',
    title: 'Location and assignment',
    detail: 'Choose the branch and record who or which department is responsible.',
  },
  {
    id: 'records',
    label: 'Records',
    compactLabel: 'Records',
    title: 'Purchase, warranty and records',
    detail: 'Add available purchase, warranty, document and note details.',
  },
  {
    id: 'review',
    label: 'Review',
    compactLabel: 'Review',
    title: 'Review and confirm',
    detail: 'Check the asset record before saving it to the company register.',
  },
]

type AssetFormValues = {
  name: string
  assetType: AssetType
  branch: string
  assignedToId: string
  departmentId: string
  purchaseDate: string
  value: string
  vendor: string
  invoiceNumber: string
  status: AssetStatus
  warrantyExpiryDate: string
  notes: string
  serialNumber: string
  imei: string
  manufacturer: string
  documents: AssetDto['documents']
}

type AssetFormErrors = Partial<Record<keyof AssetFormValues, string>>

function AssetFormSection({
  title,
  description,
  children,
  className,
  hidden,
}: {
  title: string
  description: string
  children: ReactNode
  className?: string
  hidden?: boolean
}) {
  return (
    <FormSection className={className} hidden={hidden}>
      <div className="mb-4">
        <h3 className="text-label text-text-primary font-semibold">{title}</h3>
        <p className="text-caption text-text-secondary mt-1">{description}</p>
      </div>
      {children}
    </FormSection>
  )
}

function formValues(asset: AssetDto | null): AssetFormValues {
  const normalizedStatus = asset?.status === 'in-use' ? 'in_use' : asset?.status
  return {
    name: asset?.name ?? '',
    assetType: (asset?.asset_type ?? 'equipment') as AssetType,
    branch: asset?.branch ?? '',
    assignedToId: asset?.assigned_to_id == null ? '' : String(asset.assigned_to_id),
    departmentId: asset?.department_id == null ? '' : String(asset.department_id),
    purchaseDate: asset?.purchase_date ?? '',
    value: asset?.value == null ? '' : String(asset.value),
    vendor: asset?.vendor ?? '',
    invoiceNumber: asset?.invoice_number ?? '',
    status: (normalizedStatus === 'active'
      ? 'available'
      : (normalizedStatus ?? 'available')) as AssetStatus,
    warrantyExpiryDate: asset?.warranty_expiry_date ?? '',
    notes: asset?.notes ?? '',
    serialNumber: asset?.serial_number ?? '',
    imei: asset?.imei ?? '',
    manufacturer: asset?.manufacturer ?? '',
    documents: asset?.documents ?? [],
  }
}

function validate(values: AssetFormValues): AssetFormErrors {
  const errors: AssetFormErrors = {}
  if (!values.name.trim()) errors.name = 'Enter an asset name.'
  else if (values.name.trim().length > 255) errors.name = 'Use 255 characters or fewer.'
  if (!assetTypeOptions.some((option) => option.value === values.assetType)) {
    errors.assetType = 'Choose a supported asset type.'
  }
  if (!values.branch) errors.branch = 'Choose a branch.'
  else if (values.branch.length > 100) errors.branch = 'Use 100 characters or fewer.'
  if (
    values.assignedToId &&
    (!Number.isSafeInteger(Number(values.assignedToId)) || Number(values.assignedToId) < 1)
  ) {
    errors.assignedToId = 'Choose a valid employee.'
  }
  if (
    values.departmentId &&
    (!Number.isSafeInteger(Number(values.departmentId)) || Number(values.departmentId) < 1)
  ) {
    errors.departmentId = 'Choose a valid department.'
  }
  if (values.value.trim()) {
    const [whole = '', fraction = ''] = values.value.trim().split('.')
    const significantWhole = whole.replace(/^0+/, '') || '0'
    if (
      !/^\d+(?:\.\d{1,2})?$/.test(values.value.trim()) ||
      significantWhole.length > 10 ||
      fraction.length > 2
    ) {
      errors.value = 'Enter a non-negative amount with up to 10 whole digits and 2 decimal places.'
    }
  }
  if (values.vendor.length > 255) errors.vendor = 'Use 255 characters or fewer.'
  if (values.invoiceNumber.length > 100) errors.invoiceNumber = 'Use 100 characters or fewer.'
  if (values.serialNumber.length > 100) errors.serialNumber = 'Use 100 characters or fewer.'
  if (values.imei.length > 100) errors.imei = 'Use 100 characters or fewer.'
  if (values.manufacturer.length > 100) errors.manufacturer = 'Use 100 characters or fewer.'
  if (!statusOptions.some((option) => option.value === values.status)) {
    errors.status = 'Choose a supported asset status.'
  }
  return errors
}

function validateStep(values: AssetFormValues, step: AssetFlowStep): AssetFormErrors {
  const errors = validate(values)
  const stepFields: Record<AssetFlowStep, (keyof AssetFormValues)[]> = {
    identity: ['name', 'assetType', 'serialNumber', 'imei', 'manufacturer'],
    location: ['branch', 'assignedToId', 'departmentId', 'status'],
    records: ['value', 'vendor', 'invoiceNumber'],
    review: Object.keys(errors) as (keyof AssetFormValues)[],
  }
  const fields = new Set(stepFields[step])
  return Object.fromEntries(
    Object.entries(errors).filter(([field]) => fields.has(field as keyof AssetFormValues)),
  ) as AssetFormErrors
}

function stepForErrors(errors: AssetFormErrors): number {
  const identityFields: (keyof AssetFormValues)[] = [
    'name',
    'assetType',
    'serialNumber',
    'imei',
    'manufacturer',
  ]
  const locationFields: (keyof AssetFormValues)[] = [
    'branch',
    'assignedToId',
    'departmentId',
    'status',
  ]
  if (identityFields.some((field) => errors[field])) return 0
  if (locationFields.some((field) => errors[field])) return 1
  return 2
}

function withCurrentChoice(
  choices: AssetChoiceDto[] | undefined,
  value: string,
  fallbackLabel: string,
): DropdownSelectOption[] {
  const options = (choices ?? []).map(({ value: optionValue, label, description }) => ({
    value: optionValue,
    label,
    description: description ?? undefined,
  }))
  if (value && !options.some((option) => option.value === value)) {
    options.push({ value, label: fallbackLabel, description: undefined })
  }
  return options
}

function nullableText(value: string): string | null {
  return value.trim() || null
}

function optionLabel(options: DropdownSelectOption[], value: string, emptyLabel = 'Not provided') {
  if (!value) return emptyLabel
  return options.find((option) => option.value === value)?.label ?? value
}

function reviewStatusTone(status: AssetStatus): StatusTone {
  if (status === 'available') return 'success'
  if (status === 'in_use') return 'primary'
  if (status === 'maintenance') return 'warning'
  if (status === 'lost_stolen') return 'danger'
  return 'neutral'
}

function AssetReviewValue({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="min-w-0">
      <dt className="text-overline text-text-secondary px-1">{label}</dt>
      <dd className="border-border-subtle bg-surface-muted/55 text-body-sm text-text-primary rounded-control mt-1 min-h-10 min-w-0 border px-3 py-2 font-medium break-words">
        {value || 'Not provided'}
      </dd>
    </div>
  )
}

function AssetReviewGroup({
  title,
  step,
  icon,
  onChange,
  children,
}: {
  title: string
  step: number
  icon: ReactNode
  onChange: (step: number) => void
  children: ReactNode
}) {
  return (
    <section className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm tablet:p-5 min-w-0 border p-4">
      <div className="border-border-subtle mb-4 flex min-w-0 items-center justify-between gap-3 border-b pb-3">
        <div className="flex min-w-0 items-center gap-2.5">
          <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
            {icon}
          </span>
          <h3 className="text-label text-text-primary min-w-0 font-semibold">{title}</h3>
        </div>
        <Button
          variant="ghost"
          size="sm"
          aria-label={'Edit ' + title}
          onClick={() => onChange(step)}
          leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
        >
          Edit
        </Button>
      </div>
      {children}
    </section>
  )
}

export function AssetFormDialog({
  open,
  onOpenChange,
  asset,
  userId,
  employeeId,
  onSave,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  asset: AssetDto | null
  userId: number
  employeeId: string
  onSave: (input: AssetWriteInput, assetId: number | null) => Promise<void>
}) {
  const fileInputRef = useRef<HTMLInputElement>(null)
  const formElement = useRef<HTMLFormElement>(null)
  const intentionalSubmit = useRef(false)
  const [activeStep, setActiveStep] = useState(0)
  const [formErrors, setFormErrors] = useState<AssetFormErrors>({})
  const [focusInvalidAttempt, setFocusInvalidAttempt] = useState(0)
  const [formError, setFormError] = useState<string | null>(null)
  const [uploadError, setUploadError] = useState<string | null>(null)
  const [uploadType, setUploadType] = useState<'Document' | 'Image'>('Document')
  const [uploading, setUploading] = useState(false)
  const [saving, setSaving] = useState(false)

  const choicesQuery = useQuery({
    queryKey: assetQueryKeys.choices(userId, employeeId),
    queryFn: ({ signal }) => assetsApi.choices(signal),
    enabled: open,
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const form = useForm({
    defaultValues: formValues(asset),
    onSubmit: async ({ value }) => {
      const errors = validate(value)
      setFormErrors(errors)
      setFormError(null)
      if (Object.keys(errors).length) {
        setActiveStep(stepForErrors(errors))
        setFocusInvalidAttempt((attempt) => attempt + 1)
        return
      }

      const input: AssetWriteInput = {
        name: value.name.trim(),
        asset_type: value.assetType,
        branch: value.branch,
        assigned_to_id: value.assignedToId ? Number(value.assignedToId) : null,
        department_id: value.departmentId ? Number(value.departmentId) : null,
        purchase_date: nullableText(value.purchaseDate),
        value: nullableText(value.value),
        vendor: nullableText(value.vendor),
        invoice_number: nullableText(value.invoiceNumber),
        status: value.status,
        warranty_expiry_date: nullableText(value.warrantyExpiryDate),
        notes: nullableText(value.notes),
        serial_number: nullableText(value.serialNumber),
        imei: nullableText(value.imei),
        manufacturer: nullableText(value.manufacturer),
        documents: value.documents,
      }
      setSaving(true)
      try {
        await onSave(input, asset?.id ?? null)
      } catch (error) {
        setFormError(presentError(error, 'form-submit').message)
      } finally {
        setSaving(false)
      }
    },
  })

  useEffect(() => {
    if (!open) return
    form.reset(formValues(asset))
    // eslint-disable-next-line react-hooks/set-state-in-effect -- Reset wizard-local state when this dialog opens or switches records.
    setActiveStep(0)
    setFormErrors({})
    setFormError(null)
    setUploadError(null)
    setUploadType('Document')
    intentionalSubmit.current = false
    // Reset only when opening or switching the asset, not when its query cache refreshes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [asset?.id, form, open])

  useEffect(() => {
    if (!focusInvalidAttempt) return
    formElement.current
      ?.querySelector<HTMLElement>('section:not([hidden]) [aria-invalid="true"]')
      ?.focus()
  }, [activeStep, focusInvalidAttempt])

  useEffect(() => {
    if (!open) return
    const dialogBody = formElement.current?.parentElement
    // eslint-disable-next-line react-hooks/immutability -- Scrolling the dialog body is an intentional DOM side effect.
    if (dialogBody) dialogBody.scrollTop = 0
  }, [activeStep, open])

  const branchOptions = withCurrentChoice(
    choicesQuery.data?.branches,
    asset?.branch ?? '',
    asset?.branch ?? '',
  )
  const departmentOptions = withCurrentChoice(
    choicesQuery.data?.departments,
    asset?.department_id == null ? '' : String(asset.department_id),
    'Department ' + (asset?.department_id ?? ''),
  )
  const employeeOptions = withCurrentChoice(
    choicesQuery.data?.employees,
    asset?.assigned_to_id == null ? '' : String(asset.assigned_to_id),
    'Employee ' + (asset?.assigned_to_id ?? ''),
  )
  const activeStepId = ASSET_FLOW_STEPS[activeStep]?.id ?? 'identity'

  function handleOpenChange(nextOpen: boolean) {
    if (!nextOpen) {
      setActiveStep(0)
      setFormErrors({})
      setFormError(null)
      setUploadError(null)
      intentionalSubmit.current = false
    }
    onOpenChange(nextOpen)
  }

  function goToStep(index: number) {
    if (index < 0 || index >= activeStep || saving || uploading) return
    setFormErrors({})
    setFormError(null)
    setActiveStep(index)
  }

  function continueStep() {
    if (activeStepId === 'review' || saving || uploading) return
    const errors = validateStep(form.state.values, activeStepId)
    setFormErrors(errors)
    setFormError(null)
    if (Object.keys(errors).length) {
      setFocusInvalidAttempt((attempt) => attempt + 1)
      return
    }
    if (activeStepId === 'location' && !choicesQuery.data && !asset) return
    setActiveStep((step) => Math.min(step + 1, ASSET_FLOW_STEPS.length - 1))
  }

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    event.stopPropagation()
    if (activeStepId !== 'review') {
      continueStep()
      return
    }
    if (!intentionalSubmit.current) return
    intentionalSubmit.current = false
    void form.handleSubmit()
  }

  async function uploadSelectedFile(
    file: File | undefined,
    documents: AssetDto['documents'],
    onDocumentsChange: (next: AssetDto['documents']) => void,
  ) {
    if (!file) return
    setUploadError(null)
    if (file.size > 15 * 1024 * 1024) {
      setUploadError('Choose a file smaller than 15 MB.')
      return
    }
    if (uploadType === 'Image' && !file.type.startsWith('image/')) {
      setUploadError('Choose an image file or change the upload type to Document.')
      return
    }

    setUploading(true)
    try {
      const result = await assetsApi.upload(file)
      onDocumentsChange([...documents, { name: file.name, type: uploadType, url: result.url }])
    } catch (error) {
      setUploadError(presentError(error, 'form-submit').message)
    } finally {
      setUploading(false)
      if (fileInputRef.current) fileInputRef.current.value = ''
    }
  }

  function clearError(field: keyof AssetFormValues) {
    if (!formErrors[field]) return
    setFormErrors((current) => {
      const next = { ...current }
      delete next[field]
      return next
    })
  }

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={asset ? 'Edit asset' : 'New asset'}
      description={
        asset ? 'Update the company asset record.' : 'Add a company-owned asset to the register.'
      }
      size="xl"
      className="tablet:max-h-[92dvh]"
      bodyClassName="space-y-5"
      dismissDisabled={uploading || saving}
      footer={
        <CreationFlowActions
          leading={
            <Button
              variant="outline"
              onClick={() => handleOpenChange(false)}
              disabled={saving || uploading}
            >
              Cancel
            </Button>
          }
        >
          {activeStep > 0 ? (
            <Button
              variant="outline"
              leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
              onClick={() => goToStep(activeStep - 1)}
              disabled={saving || uploading}
            >
              Previous
            </Button>
          ) : null}
          {activeStepId !== 'review' ? (
            <Button
              onClick={continueStep}
              disabled={
                saving || uploading || (activeStepId === 'location' && !choicesQuery.data && !asset)
              }
            >
              Next
            </Button>
          ) : (
            <Button
              type="submit"
              form="asset-form"
              onClick={() => {
                intentionalSubmit.current = true
              }}
              isLoading={saving}
              disabled={saving || uploading}
            >
              {asset ? 'Save changes' : 'Create asset'}
            </Button>
          )}
        </CreationFlowActions>
      }
    >
      <form ref={formElement} id="asset-form" className="space-y-5" noValidate onSubmit={submit}>
        {formError ? (
          <Alert tone="danger" role="alert" title="Asset could not be saved">
            {formError}
          </Alert>
        ) : null}
        {choicesQuery.isError && activeStepId === 'location' ? (
          <SectionErrorState
            title="Asset choices could not be loaded"
            description="Retry to load the branch, employee and department options needed for this form."
            error={choicesQuery.error}
            onRetry={() => void choicesQuery.refetch()}
          />
        ) : null}

        <CreationFlowStepper
          steps={ASSET_FLOW_STEPS}
          currentStep={activeStep}
          maxSelectableStep={activeStep}
          onStepSelect={goToStep}
          ariaLabel={asset ? 'Asset update' : 'Asset setup'}
          variant="horizontal"
          eyebrow={asset ? 'Asset update' : 'New asset'}
          hideDetailBelow480
        />
        <p className="sr-only" role="status" aria-live="polite">
          Step {activeStep + 1} of {ASSET_FLOW_STEPS.length}: {ASSET_FLOW_STEPS[activeStep]?.label}
        </p>

        <AssetFormSection
          hidden={activeStepId !== 'identity'}
          className="space-y-4"
          title="Asset information"
          description="Identify the asset and its manufacturer."
        >
          <div className="tablet:grid-cols-2 grid gap-4">
            <form.Field name="name">
              {(field) => (
                <FormControl id="asset-name" label="Asset name" required error={formErrors.name}>
                  <TextInput
                    value={field.state.value}
                    maxLength={255}
                    onChange={(event) => {
                      clearError('name')
                      field.handleChange(event.currentTarget.value)
                    }}
                    placeholder="For example, MacBook Pro 14-inch"
                    autoComplete="off"
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="assetType">
              {(field) => (
                <FormControl
                  id="asset-type"
                  label="Asset type"
                  required
                  error={formErrors.assetType}
                >
                  <DropdownSelect
                    value={field.state.value}
                    options={assetTypeOptions}
                    onChange={(value) => {
                      clearError('assetType')
                      field.handleChange(value as AssetType)
                    }}
                    placeholder="Select asset type"
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="serialNumber">
              {(field) => (
                <FormControl
                  id="asset-serial"
                  label="Serial number"
                  error={formErrors.serialNumber}
                >
                  <TextInput
                    value={field.state.value}
                    maxLength={100}
                    onChange={(event) => {
                      clearError('serialNumber')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="imei">
              {(field) => (
                <FormControl id="asset-imei" label="IMEI" error={formErrors.imei}>
                  <TextInput
                    value={field.state.value}
                    maxLength={100}
                    onChange={(event) => {
                      clearError('imei')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="manufacturer">
              {(field) => (
                <FormControl
                  id="asset-manufacturer"
                  label="Manufacturer"
                  error={formErrors.manufacturer}
                  className="tablet:col-span-2"
                >
                  <TextInput
                    value={field.state.value}
                    maxLength={100}
                    onChange={(event) => {
                      clearError('manufacturer')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
        </AssetFormSection>

        <AssetFormSection
          hidden={activeStepId !== 'location'}
          className="space-y-4"
          title="Location and assignment"
          description="Set where the asset belongs and who is responsible for it."
        >
          <div className="tablet:grid-cols-2 grid gap-4">
            <form.Field name="branch">
              {(field) => (
                <FormControl id="asset-branch" label="Branch" required error={formErrors.branch}>
                  <DropdownSelect
                    value={field.state.value}
                    options={branchOptions}
                    onChange={(value) => {
                      clearError('branch')
                      field.handleChange(value)
                    }}
                    placeholder={choicesQuery.isLoading ? 'Loading branches' : 'Select branch'}
                    disabled={choicesQuery.isLoading || choicesQuery.isError}
                    searchable
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="assignedToId">
              {(field) => (
                <FormControl id="asset-assigned-to" label="Assigned employee">
                  <DropdownSelect
                    value={field.state.value}
                    options={[{ value: '', label: 'Unassigned' }, ...employeeOptions]}
                    onChange={(value) => {
                      clearError('assignedToId')
                      field.handleChange(value)
                    }}
                    placeholder="Unassigned"
                    disabled={choicesQuery.isLoading || choicesQuery.isError}
                    searchable
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="departmentId">
              {(field) => (
                <FormControl id="asset-department" label="Department">
                  <DropdownSelect
                    value={field.state.value}
                    options={[{ value: '', label: 'No department' }, ...departmentOptions]}
                    onChange={(value) => {
                      clearError('departmentId')
                      field.handleChange(value)
                    }}
                    placeholder="No department"
                    disabled={choicesQuery.isLoading || choicesQuery.isError}
                    searchable
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="status">
              {(field) => (
                <FormControl id="asset-status" label="Status" required error={formErrors.status}>
                  <DropdownSelect
                    value={field.state.value}
                    options={statusOptions}
                    onChange={(value) => {
                      clearError('status')
                      field.handleChange(value as AssetStatus)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
        </AssetFormSection>

        <AssetFormSection
          hidden={activeStepId !== 'records'}
          className="space-y-4"
          title="Purchase and warranty"
          description="Capture the available financial and coverage details."
        >
          <div className="tablet:grid-cols-2 grid gap-4">
            <form.Field name="purchaseDate">
              {(field) => (
                <FormControl id="asset-purchase-date" label="Purchase date">
                  <DatePickerField
                    value={field.state.value}
                    onValueChange={field.handleChange}
                    clearable
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="value">
              {(field) => (
                <FormControl id="asset-value" label="Asset value" error={formErrors.value}>
                  <TextInput
                    type="number"
                    min="0"
                    max="9999999999.99"
                    step="0.01"
                    inputMode="decimal"
                    value={field.state.value}
                    onChange={(event) => {
                      clearError('value')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="vendor">
              {(field) => (
                <FormControl id="asset-vendor" label="Vendor" error={formErrors.vendor}>
                  <TextInput
                    value={field.state.value}
                    maxLength={255}
                    onChange={(event) => {
                      clearError('vendor')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="invoiceNumber">
              {(field) => (
                <FormControl
                  id="asset-invoice"
                  label="Invoice number"
                  error={formErrors.invoiceNumber}
                >
                  <TextInput
                    value={field.state.value}
                    maxLength={100}
                    onChange={(event) => {
                      clearError('invoiceNumber')
                      field.handleChange(event.currentTarget.value)
                    }}
                  />
                </FormControl>
              )}
            </form.Field>
            <form.Field name="warrantyExpiryDate">
              {(field) => (
                <FormControl id="asset-warranty" label="Warranty expiry">
                  <DatePickerField
                    value={field.state.value}
                    onValueChange={field.handleChange}
                    clearable
                  />
                </FormControl>
              )}
            </form.Field>
          </div>
        </AssetFormSection>

        <AssetFormSection
          hidden={activeStepId !== 'records'}
          className="space-y-4"
          title="Documents and notes"
          description="Attach a receipt, warranty, manual or photo, then add internal context."
        >
          {uploadError ? (
            <Alert tone="danger" role="alert" className="mb-4">
              {uploadError}
            </Alert>
          ) : null}
          <form.Field name="documents">
            {(field) => (
              <div className="space-y-3">
                <div className="tablet:flex-row tablet:items-end flex flex-col gap-3">
                  <FormControl
                    id="asset-upload-type"
                    label="File type"
                    className="tablet:w-48 w-full"
                  >
                    <DropdownSelect
                      value={uploadType}
                      options={[
                        { value: 'Document', label: 'Document' },
                        { value: 'Image', label: 'Image' },
                      ]}
                      onChange={(value) => setUploadType(value as 'Document' | 'Image')}
                    />
                  </FormControl>
                  <input
                    ref={fileInputRef}
                    className="sr-only"
                    type="file"
                    accept={
                      uploadType === 'Image' ? 'image/*' : '.pdf,.doc,.docx,.xls,.xlsx,.csv,.txt'
                    }
                    onChange={(event) => {
                      void uploadSelectedFile(
                        event.currentTarget.files?.[0],
                        field.state.value,
                        field.handleChange,
                      )
                    }}
                    aria-label={'Choose ' + uploadType.toLowerCase() + ' to upload'}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    leadingIcon={<Upload className="size-4" aria-hidden="true" />}
                    isLoading={uploading}
                    disabled={choicesQuery.isError || saving}
                    onClick={() => fileInputRef.current?.click()}
                  >
                    {uploading ? 'Uploading file' : 'Upload ' + uploadType.toLowerCase()}
                  </Button>
                </div>
                {uploading ? (
                  <p role="status" aria-live="polite" className="text-caption text-text-secondary">
                    Uploading file to the company file service. Keep this form open until it
                    finishes.
                  </p>
                ) : null}
                {field.state.value.length ? (
                  <ul className="space-y-2" aria-label="Attached files">
                    {field.state.value.map((document, index) => (
                      <li
                        key={(document.url ?? document.name) + '-' + index}
                        className="border-border-subtle bg-surface-muted/40 rounded-control flex min-w-0 items-center gap-3 border px-3 py-2.5"
                      >
                        <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                          {document.type === 'Image' ? (
                            <ImagePlus className="size-4" aria-hidden="true" />
                          ) : (
                            <FileText className="size-4" aria-hidden="true" />
                          )}
                        </span>
                        <span
                          className="text-body-sm min-w-0 flex-1 truncate font-medium"
                          title={document.name}
                        >
                          {document.name}
                        </span>
                        {document.url ? (
                          <a
                            href={document.url}
                            target="_blank"
                            rel="noreferrer"
                            className="text-caption text-primary inline-flex shrink-0 items-center gap-1 font-semibold"
                          >
                            Open <ExternalLink className="size-3.5" aria-hidden="true" />
                          </a>
                        ) : null}
                        <Button
                          type="button"
                          variant="ghost"
                          size="icon"
                          aria-label={'Remove ' + document.name}
                          onClick={() =>
                            field.handleChange(
                              field.state.value.filter((_, itemIndex) => itemIndex !== index),
                            )
                          }
                        >
                          <Trash2 className="size-4" aria-hidden="true" />
                        </Button>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p className="text-caption text-text-secondary inline-flex items-center gap-2">
                    <Paperclip className="size-4" aria-hidden="true" /> No files attached.
                  </p>
                )}
              </div>
            )}
          </form.Field>
          <form.Field name="notes">
            {(field) => (
              <FormControl id="asset-notes" label="Notes" className="mt-4">
                <TextArea
                  value={field.state.value}
                  onChange={(event) => field.handleChange(event.currentTarget.value)}
                  rows={3}
                />
              </FormControl>
            )}
          </form.Field>
        </AssetFormSection>
        <section hidden={activeStepId !== 'review'} aria-label="Review asset details">
          <form.Subscribe selector={(state) => state.values}>
            {(values) => (
              <div className="space-y-4">
                <header className="border-border-subtle from-primary-subtle/70 via-primary-subtle/25 to-surface rounded-surface shadow-elevation-sm relative overflow-hidden border bg-gradient-to-br">
                  <span
                    aria-hidden="true"
                    className="from-primary via-primary/35 pointer-events-none absolute inset-x-0 top-0 h-[3px] bg-gradient-to-r to-transparent"
                  />
                  <div className="tablet:items-center tablet:p-5 flex min-w-0 items-start gap-3 p-4">
                    <span className="bg-surface text-primary rounded-surface flex size-12 shrink-0 items-center justify-center border border-white/80 shadow-sm">
                      <Package2 className="size-5" aria-hidden="true" />
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="text-overline text-primary font-semibold">
                        {asset ? 'Asset update' : 'New company asset'} · Review
                      </p>
                      <h3 className="text-h3 mt-1 font-semibold break-words">
                        {values.name.trim() || 'Unnamed asset'}
                      </h3>
                      <div className="mt-2.5 flex flex-wrap items-center gap-2">
                        <StatusChip
                          label={optionLabel(assetTypeOptions, values.assetType)}
                          tone="primary"
                          dense
                        />
                        <StatusChip
                          label={optionLabel(statusOptions, values.status)}
                          tone={reviewStatusTone(values.status)}
                          dense
                        />
                      </div>
                    </div>
                  </div>
                  <div className="border-border-subtle bg-surface/70 text-caption text-text-secondary tablet:px-5 flex items-center gap-2 border-t px-4 py-3">
                    <CheckCircle2 className="text-primary size-4 shrink-0" aria-hidden="true" />
                    Check the details below. Nothing is saved until you confirm.
                  </div>
                </header>

                <div className="desktop:grid desktop:grid-cols-2 desktop:items-start desktop:gap-4 desktop:space-y-0 min-w-0 space-y-4">
                  <AssetReviewGroup
                    title="Asset information"
                    step={0}
                    icon={<Package2 className="size-4" aria-hidden="true" />}
                    onChange={goToStep}
                  >
                    <dl className="grid min-w-0 grid-cols-1 gap-3 min-[480px]:grid-cols-2">
                      <AssetReviewValue label="Asset name" value={values.name.trim()} />
                      <AssetReviewValue
                        label="Asset type"
                        value={optionLabel(assetTypeOptions, values.assetType)}
                      />
                      <AssetReviewValue label="Serial number" value={values.serialNumber.trim()} />
                      <AssetReviewValue label="IMEI" value={values.imei.trim()} />
                      <AssetReviewValue label="Manufacturer" value={values.manufacturer.trim()} />
                    </dl>
                  </AssetReviewGroup>

                  <AssetReviewGroup
                    title="Location and assignment"
                    step={1}
                    icon={<MapPin className="size-4" aria-hidden="true" />}
                    onChange={goToStep}
                  >
                    <dl className="grid min-w-0 grid-cols-1 gap-3 min-[480px]:grid-cols-2">
                      <AssetReviewValue
                        label="Branch"
                        value={optionLabel(branchOptions, values.branch)}
                      />
                      <AssetReviewValue
                        label="Assigned employee"
                        value={optionLabel(employeeOptions, values.assignedToId, 'Unassigned')}
                      />
                      <AssetReviewValue
                        label="Department"
                        value={optionLabel(departmentOptions, values.departmentId, 'No department')}
                      />
                      <AssetReviewValue
                        label="Status"
                        value={optionLabel(statusOptions, values.status)}
                      />
                    </dl>
                  </AssetReviewGroup>

                  <AssetReviewGroup
                    title="Purchase and warranty"
                    step={2}
                    icon={<CircleDollarSign className="size-4" aria-hidden="true" />}
                    onChange={goToStep}
                  >
                    <dl className="grid min-w-0 grid-cols-1 gap-3 min-[480px]:grid-cols-2">
                      <AssetReviewValue label="Purchase date" value={values.purchaseDate} />
                      <AssetReviewValue
                        label="Asset value"
                        value={
                          values.value.trim()
                            ? Number(values.value).toLocaleString('en-NG', {
                                maximumFractionDigits: 2,
                              })
                            : 'Not provided'
                        }
                      />
                      <AssetReviewValue label="Vendor" value={values.vendor.trim()} />
                      <AssetReviewValue
                        label="Invoice number"
                        value={values.invoiceNumber.trim()}
                      />
                      <AssetReviewValue label="Warranty expiry" value={values.warrantyExpiryDate} />
                    </dl>
                  </AssetReviewGroup>

                  <AssetReviewGroup
                    title="Documents and notes"
                    step={2}
                    icon={<FileText className="size-4" aria-hidden="true" />}
                    onChange={goToStep}
                  >
                    <dl className="grid min-w-0 grid-cols-1 gap-3 min-[480px]:grid-cols-2">
                      <AssetReviewValue
                        label="Documents"
                        value={
                          values.documents.length ? (
                            <ul className="space-y-1">
                              {values.documents.map((document, index) => (
                                <li key={(document.url ?? document.name) + '-' + index}>
                                  {document.name}{' '}
                                  <span className="text-text-secondary">({document.type})</span>
                                </li>
                              ))}
                            </ul>
                          ) : (
                            'No documents attached'
                          )
                        }
                      />
                      <AssetReviewValue
                        label="Notes"
                        value={
                          values.notes.trim() ? (
                            <span className="whitespace-pre-wrap">{values.notes.trim()}</span>
                          ) : (
                            'Not provided'
                          )
                        }
                      />
                    </dl>
                  </AssetReviewGroup>
                </div>
              </div>
            )}
          </form.Subscribe>
        </section>
      </form>
    </Dialog>
  )
}
