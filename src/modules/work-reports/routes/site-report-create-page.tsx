import {
  useEffect,
  useMemo,
  useRef,
  useState,
  type DragEvent,
  type FormEvent,
  type ReactNode,
} from 'react'
import { useForm } from '@tanstack/react-form'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  Activity,
  ArrowLeft,
  CalendarDays,
  CheckCircle2,
  ClipboardList,
  FilePlus2,
  FileText,
  LoaderCircle,
  MapPin,
  Paperclip,
  Pencil,
  Plus,
  Receipt,
  Ruler,
  Trash2,
  Upload,
} from 'lucide-react'

import { ApiError } from '@/shared/api/api-error'
import { presentError } from '@/shared/errors'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { CreationFlowActions, CreationFlowStepper } from '@/shared/ui/creation-flow'
import { DatePickerField } from '@/shared/ui/date-picker-field'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { PageLayout } from '@/shared/ui/page-layout'
import { ReportEvidenceList, type ReportEvidenceItem } from '../components/report-summary'
import { workReportsApi } from '../work-reports.api'
import { StatusChip } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import { myWorkReportsQueryKeys } from '../my-work-reports.queries'
import { siteReportsApi, type SiteReportType } from '../site-reports.api'
import {
  siteReportQueryKeys,
  siteEquipmentOptions,
  siteTasksOptions,
  siteWorksitesOptions,
} from '../site-reports.queries'
import { localDateInputValue } from '../work-report-time'
import type { WorkReportsSearch } from '../work-reports.search'

type CreateValues = { worksiteId: string; date: string }
type ActivityDraft = { activityType: string; description: string }
type ExpenseDraft = { category: string; name: string; amount: string; description: string }
type MaterialDraft = { equipmentId: string; quantity: string }
type BearingDraft = { degrees: string; minutes: string; seconds: string; distance: string }
type XyzDraft = { northing: string; easting: string; elevation: string }
type AttachmentDraft = { file: File; url?: string }
type SiteReportFormStep = 0 | 1 | 2 | 3 | 4
type SiteReportValidationInput = {
  reportType: SiteReportType
  values: CreateValues
  activities: ActivityDraft[]
  expenses: ExpenseDraft[]
  materials: MaterialDraft[]
  canListEquipment: boolean
  dataType: 'bearing_distance' | 'site_points_xyz'
  bearingPoints: BearingDraft[]
  xyzPoints: XyzDraft[]
  latitude: string
  longitude: string
}
type SiteReportValidationError = { message: string; focusId: string }
type SiteReportServerFieldErrors = {
  fields: Record<string, string>
  unmapped: string[]
}

const activityTypes = [
  { value: 'concrete_work', label: 'Concrete work' },
  { value: 'carpentry_work', label: 'Carpentry work' },
  { value: 'water_supply', label: 'Water supply' },
]
const expenseCategories = [
  { value: 'labour', label: 'Labour' },
  { value: 'material_equipment', label: 'Material / equipment' },
]
const dataTypes = [
  { value: 'bearing_distance', label: 'Bearing and distance' },
  { value: 'site_points_xyz', label: 'Site points (XYZ)' },
]
const units = [
  { value: 'metres', label: 'Metres' },
  { value: 'feet', label: 'Feet' },
]

function typeLabel(type: SiteReportType): string {
  return type === 'engineering' ? 'Engineering site report' : 'Survey site report'
}

function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(bytes >= 10 * 1024 * 1024 ? 0 : 1)} MB`
}

function formatReportDate(value: string): string {
  if (!isValidDateInput(value)) return value || 'Not selected'
  const [year, month, day] = value.split('-').map(Number)
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function formatNaira(value: string): string {
  const amount = Number(value)
  return Number.isFinite(amount)
    ? new Intl.NumberFormat('en-NG', {
        style: 'currency',
        currency: 'NGN',
        maximumFractionDigits: 2,
      }).format(amount)
    : value
}

function isValidDateInput(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false
  const [year, month, day] = value.split('-').map(Number)
  const date = new Date(year, month - 1, day)
  return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day
}

function validateSiteReportStep(
  step: SiteReportFormStep,
  input: SiteReportValidationInput,
): SiteReportValidationError | null {
  if (step === 0) {
    if (
      !Number.isSafeInteger(Number(input.values.worksiteId)) ||
      Number(input.values.worksiteId) < 1
    )
      return { message: 'Choose a worksite for this report.', focusId: 'site-create-worksite' }
    if (!isValidDateInput(input.values.date))
      return { message: 'Choose a valid report date.', focusId: 'site-create-date' }
    return null
  }

  if (step === 1) {
    const invalidActivityIndex = input.activities.findIndex((item) => !item.description.trim())
    if (invalidActivityIndex >= 0)
      return {
        message: 'Add at least one activity and complete each activity description.',
        focusId: `site-create-activity-${invalidActivityIndex}`,
      }

    if (input.reportType === 'survey') {
      const invalidBearingIndex = input.bearingPoints.findIndex((point) => {
        const degrees = Number(point.degrees)
        const minutes = Number(point.minutes)
        const seconds = Number(point.seconds)
        const distance = Number(point.distance)
        return (
          point.degrees === '' ||
          point.minutes === '' ||
          point.seconds === '' ||
          point.distance === '' ||
          !Number.isInteger(degrees) ||
          degrees < 0 ||
          degrees > 359 ||
          !Number.isInteger(minutes) ||
          minutes < 0 ||
          minutes > 59 ||
          !Number.isFinite(seconds) ||
          seconds < 0 ||
          seconds >= 60 ||
          !Number.isFinite(distance) ||
          distance <= 0
        )
      })
      const invalidXyzIndex = input.xyzPoints.findIndex((point) =>
        [point.northing, point.easting, point.elevation].some(
          (coordinate) => coordinate.trim() === '' || !Number.isFinite(Number(coordinate)),
        ),
      )
      const invalidBearing = input.dataType === 'bearing_distance' && invalidBearingIndex >= 0
      const invalidXyz = input.dataType === 'site_points_xyz' && invalidXyzIndex >= 0
      if (invalidBearing || invalidXyz) {
        const bearingPoint = input.bearingPoints[invalidBearingIndex]
        const degrees = Number(bearingPoint?.degrees)
        const minutes = Number(bearingPoint?.minutes)
        const seconds = Number(bearingPoint?.seconds)
        const distance = Number(bearingPoint?.distance)
        const invalidBearingField =
          !bearingPoint?.degrees || !Number.isInteger(degrees) || degrees < 0 || degrees > 359
            ? 'degrees'
            : !bearingPoint.minutes || !Number.isInteger(minutes) || minutes < 0 || minutes > 59
              ? 'minutes'
              : !bearingPoint.seconds || !Number.isFinite(seconds) || seconds < 0 || seconds >= 60
                ? 'seconds'
                : !bearingPoint.distance || !Number.isFinite(distance) || distance <= 0
                  ? 'distance'
                  : 'degrees'
        const xyzPoint = input.xyzPoints[invalidXyzIndex]
        const invalidXyzField =
          !xyzPoint?.northing.trim() || !Number.isFinite(Number(xyzPoint?.northing))
            ? 'northing'
            : !xyzPoint?.easting?.trim() || !Number.isFinite(Number(xyzPoint?.easting))
              ? 'easting'
              : 'elevation'
        return {
          message:
            input.dataType === 'bearing_distance'
              ? 'Add a complete bearing point with an angle from 0–359° and a distance greater than zero.'
              : 'Add a complete survey point with valid northing, easting, and elevation values.',
          focusId:
            input.dataType === 'bearing_distance'
              ? `site-create-bearing-${invalidBearingField}-${invalidBearingIndex}`
              : `site-create-xyz-${invalidXyzField}-${invalidXyzIndex}`,
        }
      }

      const lat = input.latitude.trim() ? Number(input.latitude) : null
      const lng = input.longitude.trim() ? Number(input.longitude) : null
      if (
        (lat === null) !== (lng === null) ||
        (lat !== null && (!Number.isFinite(lat) || lat < -90 || lat > 90)) ||
        (lng !== null && (!Number.isFinite(lng) || lng < -180 || lng > 180))
      )
        return {
          message: 'Enter both GPS coordinates, with a valid latitude and longitude.',
          focusId:
            lat === null || !Number.isFinite(lat) || lat < -90 || lat > 90
              ? 'site-create-gps-latitude'
              : 'site-create-gps-longitude',
        }
    }
    return null
  }

  if (step === 2) {
    const invalidExpenseIndex = input.expenses.findIndex((item) => {
      const amount = Number(item.amount)
      return (
        !item.category ||
        !item.name.trim() ||
        !item.description.trim() ||
        !Number.isFinite(amount) ||
        amount <= 0
      )
    })
    if (invalidExpenseIndex >= 0) {
      const invalidExpense = input.expenses[invalidExpenseIndex]
      return {
        message: 'Complete each expense and enter an amount greater than zero.',
        focusId: !invalidExpense.category
          ? `site-create-expense-category-${invalidExpenseIndex}`
          : !invalidExpense.name.trim()
            ? `site-create-expense-name-${invalidExpenseIndex}`
            : !Number.isFinite(Number(invalidExpense.amount)) || Number(invalidExpense.amount) <= 0
              ? `site-create-expense-amount-${invalidExpenseIndex}`
              : `site-create-expense-description-${invalidExpenseIndex}`,
      }
    }

    const invalidMaterialIndex = input.canListEquipment
      ? input.materials.findIndex((item) => {
          const quantity = Number(item.quantity)
          return !item.equipmentId || !Number.isFinite(quantity) || quantity <= 0
        })
      : -1
    if (invalidMaterialIndex >= 0) {
      const invalidMaterial = input.materials[invalidMaterialIndex]
      return {
        message: 'Choose an inventory item and enter a quantity greater than zero.',
        focusId: !invalidMaterial.equipmentId
          ? `site-create-material-${invalidMaterialIndex}`
          : `site-create-material-quantity-${invalidMaterialIndex}`,
      }
    }
    return null
  }

  if (step === 3) {
    return null
  }
  return null
}

function mapSiteReportServerFieldErrors(error: ApiError): SiteReportServerFieldErrors {
  const fields: Record<string, string> = {}
  const unmapped: string[] = []
  const fieldTargets: Record<string, string> = {
    worksite_id: 'site-create-worksite',
    date: 'site-create-date',
    task_id: 'site-create-task',
    latitude: 'site-create-gps-latitude',
    longitude: 'site-create-gps-longitude',
  }
  const nestedTargets: Record<string, Record<string, string>> = {
    activities: { description: 'activity' },
    expenses: {
      category: 'expense-category',
      expense_category: 'expense-category',
      name: 'expense-name',
      amount: 'expense-amount',
      description: 'expense-description',
    },
    materials_used: {
      equipment_id: 'material',
      quantity_used: 'material-quantity',
      quantity: 'material-quantity',
    },
    bearing_distance_points: {
      azimuth_degrees: 'bearing-degrees',
      degrees: 'bearing-degrees',
      azimuth_minutes: 'bearing-minutes',
      minutes: 'bearing-minutes',
      azimuth_seconds: 'bearing-seconds',
      seconds: 'bearing-seconds',
      distance: 'bearing-distance',
    },
    xyz_points: {
      northing: 'xyz-northing',
      easting: 'xyz-easting',
      elevation: 'xyz-elevation',
    },
  }

  for (const [key, rawMessage] of Object.entries(error.fieldErrors ?? {})) {
    const message = Array.isArray(rawMessage) ? rawMessage.join(' ') : rawMessage
    const path = key
      .replace(/\[(\d+)\]/g, '.$1')
      .split('.')
      .map((part) => part.toLowerCase())
    const resource = path[0]
    let fieldId = fieldTargets[resource]

    if (!fieldId && resource === 'activities') {
      const itemIndex = Number.isInteger(Number(path[1])) ? Number(path[1]) : 0
      fieldId = `site-create-activity-${itemIndex}`
    } else if (!fieldId && resource && nestedTargets[resource]) {
      const itemIndex = Number.isInteger(Number(path[1])) ? Number(path[1]) : 0
      const fieldName = path[1] && Number.isInteger(Number(path[1])) ? path[2] : path[1]
      const defaultFields: Record<string, string> = {
        expenses: 'expense-name',
        materials_used: 'material',
        bearing_distance_points: 'bearing-degrees',
        xyz_points: 'xyz-northing',
      }
      const fieldPrefix = nestedTargets[resource][fieldName ?? ''] ?? defaultFields[resource]
      if (fieldPrefix) fieldId = `site-create-${fieldPrefix}-${itemIndex}`
    }

    if (fieldId) fields[fieldId] = message
    else unmapped.push(`${key}: ${message}`)
  }

  return { fields, unmapped }
}

function ReviewSection({
  title,
  detail,
  icon,
  onEdit,
  children,
}: {
  title: string
  detail?: string
  icon: ReactNode
  onEdit: () => void
  children: ReactNode
}) {
  return (
    <section className="rounded-surface border-border-subtle bg-surface tablet:p-5 min-w-0 border p-4 shadow-sm">
      <div className="mb-4 flex min-w-0 items-start justify-between gap-3">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            {icon}
          </span>
          <div className="min-w-0">
            <h3 className="text-label text-text-primary font-semibold">{title}</h3>
            {detail ? <p className="text-caption text-text-secondary mt-0.5">{detail}</p> : null}
          </div>
        </div>
        <Button
          type="button"
          variant="ghost"
          size="sm"
          leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
          onClick={onEdit}
          aria-label={`Edit ${title.toLowerCase()}`}
        >
          Edit
        </Button>
      </div>
      {children}
    </section>
  )
}

function ReviewMetric({
  icon,
  label,
  value,
}: {
  icon: ReactNode
  label: string
  value: ReactNode
}) {
  return (
    <div className="rounded-control border-border-subtle bg-surface-muted/70 tablet:p-4 min-w-0 border p-3">
      <div className="flex items-center gap-2">
        <span className="bg-surface text-primary rounded-control flex size-8 shrink-0 items-center justify-center">
          {icon}
        </span>
        <span className="text-caption text-text-secondary">{label}</span>
      </div>
      <p className="text-body-sm text-text-primary mt-2 font-semibold break-words">{value}</p>
    </div>
  )
}

function ReviewItem({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="min-w-0">
      <p className="text-caption text-text-secondary">{label}</p>
      <p className="text-body-sm text-text-primary mt-1 font-medium break-words">{children}</p>
    </div>
  )
}

export function SiteReportCreatePage() {
  const params = useParams({ strict: false }) as { reportType?: string }
  const type =
    params.reportType === 'engineering' || params.reportType === 'survey' ? params.reportType : null
  const search = useSearch({ strict: false }) as WorkReportsSearch
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const resource = type === 'engineering' ? 'engineering_site_reports' : 'survey_site_reports'
  const canCreate = Boolean(type && hasPermission(permissions, resource, 'create'))
  const canListWorksites = hasPermission(permissions, 'worksites', 'list')
  const canListTasks = hasPermission(permissions, 'tasks', 'list')
  const canListEquipment = hasPermission(permissions, 'site_equipment', 'list')
  const [activities, setActivities] = useState<ActivityDraft[]>([
    { activityType: 'concrete_work', description: '' },
  ])
  const [expenses, setExpenses] = useState<ExpenseDraft[]>([])
  const [materials, setMaterials] = useState<MaterialDraft[]>([])
  const [bearingPoints, setBearingPoints] = useState<BearingDraft[]>([
    { degrees: '', minutes: '', seconds: '', distance: '' },
  ])
  const [xyzPoints, setXyzPoints] = useState<XyzDraft[]>([
    { northing: '', easting: '', elevation: '' },
  ])
  const [taskId, setTaskId] = useState('')
  const [dataType, setDataType] = useState<'bearing_distance' | 'site_points_xyz'>(
    'bearing_distance',
  )
  const [measurementUnit, setMeasurementUnit] = useState('metres')
  const [coordinateSystem, setCoordinateSystem] = useState('')
  const [datum, setDatum] = useState('')
  const [coordinateZone, setCoordinateZone] = useState('')
  const [latitude, setLatitude] = useState('')
  const [longitude, setLongitude] = useState('')
  const [tomorrow, setTomorrow] = useState('')
  const [comments, setComments] = useState('')
  const [attachments, setAttachments] = useState<AttachmentDraft[]>([])
  const [attachmentError, setAttachmentError] = useState('')
  const [uploadStatus, setUploadStatus] = useState('')
  const [isUploading, setIsUploading] = useState(false)
  const [isDraggingFiles, setIsDraggingFiles] = useState(false)
  const [formError, setFormError] = useState('')
  const [serverFieldErrors, setServerFieldErrors] = useState<Record<string, string>>({})
  const [validationError, setValidationError] = useState<SiteReportValidationError | null>(null)
  const [step, setStep] = useState<SiteReportFormStep>(0)
  const [furthestStep, setFurthestStep] = useState<SiteReportFormStep>(0)
  const [reviewReady, setReviewReady] = useState(false)
  const attachmentsInput = useRef<HTMLInputElement>(null)
  const flowSteps = [
    { id: 'context', label: 'Report context', compactLabel: 'Context' },
    {
      id: 'work',
      label: type === 'survey' ? 'Measurements and activities' : 'Activities',
      compactLabel: type === 'survey' ? 'Site work' : 'Activities',
    },
    { id: 'costs', label: 'Expenses and materials', compactLabel: 'Costs' },
    {
      id: 'evidence',
      label: type === 'engineering' ? 'Notes and evidence' : 'Attachments',
      compactLabel: 'Evidence',
    },
    { id: 'review', label: 'Review', compactLabel: 'Review' },
  ]

  function validationFor(stepToValidate: SiteReportFormStep, values: CreateValues) {
    return validateSiteReportStep(stepToValidate, {
      reportType: type ?? 'engineering',
      values,
      activities,
      expenses,
      materials,
      canListEquipment,
      dataType,
      bearingPoints,
      xyzPoints,
      latitude,
      longitude,
    })
  }

  function addAttachmentFiles(files: File[]) {
    const maxBytes = 15 * 1024 * 1024
    const blockedExtensions = new Set([
      '.exe',
      '.dll',
      '.bat',
      '.cmd',
      '.com',
      '.msi',
      '.scr',
      '.ps1',
      '.sh',
      '.apk',
      '.ipa',
      '.jar',
    ])
    const accepted = files.filter((file) => {
      const extension = file.name.slice(file.name.lastIndexOf('.')).toLowerCase()
      return file.size <= maxBytes && !blockedExtensions.has(extension)
    })
    const rejected = files.filter((file) => !accepted.includes(file))
    if (accepted.length) {
      setAttachments((current) => [...current, ...accepted.map((file) => ({ file }))])
    }
    setAttachmentError(
      rejected.length
        ? `${rejected.map((file) => file.name).join(', ')} could not be added. Choose files under 15 MB; executable files are not allowed.`
        : '',
    )
    setFormError('')
  }

  function handleAttachmentDrop(event: DragEvent<HTMLDivElement>) {
    event.preventDefault()
    setIsDraggingFiles(false)
    addAttachmentFiles(Array.from(event.dataTransfer.files))
  }

  async function uploadSelectedAttachments(): Promise<string[] | null> {
    if (!attachments.length) return []
    setIsUploading(true)
    setAttachmentError('')
    const nextAttachments = [...attachments]
    let currentFileName = ''
    try {
      for (const [index, attachment] of nextAttachments.entries()) {
        if (attachment.url) continue
        currentFileName = attachment.file.name
        setUploadStatus(
          `Uploading ${index + 1} of ${nextAttachments.length}: ${attachment.file.name}`,
        )
        const response = await workReportsApi.upload(attachment.file)
        nextAttachments[index] = { ...attachment, url: response.url }
        setAttachments([...nextAttachments])
      }
      return nextAttachments
        .map((attachment) => attachment.url)
        .filter((url): url is string => !!url)
    } catch (error) {
      const detail = presentError(error, 'form-submit').message
      setFormError(
        `“${currentFileName || 'A selected file'}” could not be uploaded. ${detail} Your entries are still here.`,
      )
      return null
    } finally {
      setIsUploading(false)
      setUploadStatus('')
    }
  }

  function focusValidationError(focusId: string) {
    window.requestAnimationFrame(() => document.getElementById(focusId)?.focus())
  }

  function clearFieldValidationError(focusId: string) {
    setValidationError((current) => (current?.focusId === focusId ? null : current))
    setServerFieldErrors((current) => {
      if (!(focusId in current)) return current
      const next = { ...current }
      delete next[focusId]
      return next
    })
  }

  function fieldValidationMessage(focusId: string) {
    return (
      serverFieldErrors[focusId] ??
      (validationError?.focusId === focusId ? validationError.message : undefined)
    )
  }

  function continueToNextStep() {
    setFormError('')
    setServerFieldErrors({})
    setValidationError(null)
    setReviewReady(false)
    const invalid = validationFor(step, form.state.values)
    if (invalid) {
      setValidationError(invalid)
      focusValidationError(invalid.focusId)
      return
    }
    const nextStep = Math.min(4, step + 1) as SiteReportFormStep
    setStep(nextStep)
    setFurthestStep((current) => Math.max(current, nextStep) as SiteReportFormStep)
  }

  function goToStep(targetStep: number) {
    if (targetStep > furthestStep || targetStep < 0 || targetStep > 4) return
    setFormError('')
    setServerFieldErrors({})
    setValidationError(null)
    setReviewReady(false)
    setStep(targetStep as SiteReportFormStep)
  }

  useEffect(() => {
    if (step !== 4) return
    const frame = window.requestAnimationFrame(() => setReviewReady(true))
    return () => window.cancelAnimationFrame(frame)
  }, [step])

  const mutation = useMutation({
    mutationFn: async (input: Parameters<typeof siteReportsApi.create>[1]) => {
      if (!type) throw new Error('Choose an available site report type.')
      return siteReportsApi.create(type, input)
    },
    onSuccess: async (report) => {
      if (!type) return
      toast.showToast({
        title: 'Report created',
        description: `${typeLabel(type)} was saved as a draft.`,
        tone: 'success',
      })
      await Promise.all([
        client.invalidateQueries({ queryKey: myWorkReportsQueryKeys.scoped(userId, employeeKey) }),
        client.invalidateQueries({
          queryKey: siteReportQueryKeys.lists(type, userId, employeeKey),
        }),
      ])
      await navigate({
        to: '/dashboard/my-reports/site/$reportType/$reportId',
        params: { reportType: type, reportId: String(report.id) },
        search: { ...search, type: 'site', page: 1 },
      })
    },
    onError: (error) => {
      if (error instanceof ApiError && error.fieldErrors) {
        const mapped = mapSiteReportServerFieldErrors(error)
        const firstFieldId = Object.keys(mapped.fields)[0]
        setServerFieldErrors(mapped.fields)
        setValidationError(null)
        if (firstFieldId) {
          const targetStep =
            firstFieldId.includes('worksite') || firstFieldId.includes('date')
              ? 0
              : firstFieldId.includes('expense') || firstFieldId.includes('material')
                ? 2
                : 1
          setStep(targetStep)
          focusValidationError(firstFieldId)
        }
        setFormError(
          mapped.unmapped.length
            ? `${mapped.unmapped.join(' ')} Your entries are still here.`
            : firstFieldId
              ? ''
              : `${presentError(error, 'form-submit').message} Your entries are still here.`,
        )
        return
      }
      setFormError(`${presentError(error, 'form-submit').message} Your entries are still here.`)
    },
  })

  const form = useForm({
    defaultValues: { worksiteId: '', date: localDateInputValue() } satisfies CreateValues,
    onSubmit: async ({ value }) => {
      setFormError('')
      setServerFieldErrors({})
      setValidationError(null)
      if (!type || !canCreate || !canListWorksites) {
        setFormError('Your account is not allowed to create this report type or list worksites.')
        return
      }
      for (let candidate = 0; candidate < 4; candidate += 1) {
        const invalid = validationFor(candidate as SiteReportFormStep, value)
        if (invalid) {
          setValidationError(invalid)
          setServerFieldErrors({})
          setStep(candidate as SiteReportFormStep)
          focusValidationError(invalid.focusId)
          return
        }
      }
      const activityLines = activities.filter((item) => item.description.trim())
      const attachmentUrls = await uploadSelectedAttachments()
      if (!attachmentUrls) return
      const lat = latitude.trim() ? Number(latitude) : null
      const lng = longitude.trim() ? Number(longitude) : null

      const common = {
        worksite_id: Number(value.worksiteId),
        ...(selectedWorksite?.project_id ? { project_id: selectedWorksite.project_id } : {}),
        ...(canListTasks && taskId ? { task_id: Number(taskId) } : {}),
        date: value.date,
        expenses: expenses.map((item) => ({
          expense_category: item.category,
          name: item.name.trim(),
          amount: item.amount,
          description: item.description.trim(),
        })),
        ...(canListEquipment
          ? {
              materials_used: materials.map((item) => ({
                equipment_id: Number(item.equipmentId),
                quantity_used: item.quantity,
              })),
            }
          : {}),
        attachments: attachmentUrls,
      }
      if (type === 'engineering') {
        await mutation
          .mutateAsync({
            ...common,
            tomorrow_activities: tomorrow,
            comments_suggestions: comments,
            activities: activityLines.map((item) => ({
              activity_type: item.activityType,
              description: item.description.trim(),
            })),
          })
          .catch(() => undefined)
        return
      }

      await mutation
        .mutateAsync({
          ...common,
          work_data_type: dataType,
          measurement_unit: measurementUnit,
          coordinate_system: coordinateSystem,
          datum,
          coordinate_zone: coordinateZone,
          gps_latitude: lat === null ? null : String(lat),
          gps_longitude: lng === null ? null : String(lng),
          activities: activityLines.map((item) => ({ description: item.description.trim() })),
          ...(dataType === 'bearing_distance'
            ? {
                bearing_distance_points: bearingPoints.map((point, index) => ({
                  point_number: index + 1,
                  azimuth_degrees: Number(point.degrees),
                  azimuth_minutes: Number(point.minutes),
                  azimuth_seconds: point.seconds,
                  distance: point.distance,
                })),
              }
            : {
                xyz_points: xyzPoints.map((point, index) => ({
                  point_number: index + 1,
                  northing: point.northing,
                  easting: point.easting,
                  elevation: point.elevation,
                })),
              }),
        })
        .catch(() => undefined)
    },
  })

  const worksitesQuery = useQuery({
    ...siteWorksitesOptions(userId),
    enabled: Boolean(session && canCreate && canListWorksites),
  })
  const selectedWorksite = worksitesQuery.data?.find(
    (worksite) => String(worksite.id) === form.state.values.worksiteId,
  )
  const tasksQuery = useQuery({
    ...siteTasksOptions(userId, selectedWorksite?.project_id ?? 0),
    enabled: Boolean(session && canListTasks && selectedWorksite?.project_id),
  })
  const equipmentQuery = useQuery({
    ...siteEquipmentOptions(userId, Number(form.state.values.worksiteId) || 0),
    enabled: Boolean(session && canListEquipment && form.state.values.worksiteId),
  })

  const worksiteOptions = useMemo(
    () => (worksitesQuery.data ?? []).map((site) => ({ value: String(site.id), label: site.name })),
    [worksitesQuery.data],
  )
  const equipmentOptions = useMemo(
    () =>
      (equipmentQuery.data ?? []).map((item) => ({
        value: String(item.id),
        label: `${item.name} · ${item.quantity} ${item.unit}`,
      })),
    [equipmentQuery.data],
  )
  const taskOptions = useMemo(
    () =>
      (tasksQuery.data ?? []).map((task) => ({
        value: String(task.id),
        label: task.title?.trim() || task.name?.trim() || `Task #${task.id}`,
      })),
    [tasksQuery.data],
  )

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (step < 4) {
      continueToNextStep()
      return
    }
    if (!reviewReady) return
    setFormError('')
    void form.handleSubmit()
  }

  const listBackLink = (
    <Link
      to="/dashboard/my-reports"
      search={{ ...search, type: type ?? 'all' }}
      className={pageBackLinkClassName}
    >
      <PageBackLinkContent>My Work Reports</PageBackLinkContent>
    </Link>
  )

  if (!type || !session || !canCreate || !canListWorksites) {
    return (
      <PageLayout title="New site report" backLink={listBackLink} actionsInline>
        <ErrorState
          title="You can’t create this report"
          description="Creating a site report requires its create permission and permission to list worksites."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  if (worksitesQuery.isPending) {
    return (
      <PageLayout
        title={`New ${typeLabel(type).toLocaleLowerCase()}`}
        backLink={listBackLink}
        actionsInline
      >
        <Skeleton variant="card" className="h-80" />
      </PageLayout>
    )
  }

  if (worksitesQuery.isError) {
    return (
      <PageLayout
        title={`New ${typeLabel(type).toLocaleLowerCase()}`}
        backLink={listBackLink}
        actionsInline
      >
        <Card>
          <ErrorState
            title="Worksites could not load"
            description="Retry the worksite lookup before creating a site report."
            error={worksitesQuery.error}
            action={
              <Button variant="outline" onClick={() => void worksitesQuery.refetch()}>
                Try again
              </Button>
            }
          />
        </Card>
      </PageLayout>
    )
  }

  if (!worksitesQuery.data?.length) {
    return (
      <PageLayout
        title={`New ${typeLabel(type).toLocaleLowerCase()}`}
        backLink={listBackLink}
        actionsInline
      >
        <Card>
          <EmptyState
            title="No worksite is assigned to you"
            description={`A ${typeLabel(type).toLocaleLowerCase()} must be linked to a worksite. Ask an administrator to add or assign one to your access scope, then return here and choose New report → ${typeLabel(type)}.`}
            icon={<FilePlus2 className="text-primary size-6" aria-hidden="true" />}
            action={
              <Button
                variant="outline"
                onClick={() =>
                  void navigate({
                    to: '/dashboard/my-reports',
                    search: { ...search, type },
                  })
                }
              >
                <ArrowLeft className="size-4" aria-hidden="true" />
                Back to My Work Reports
              </Button>
            }
          />
        </Card>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title={`New ${typeLabel(type).toLocaleLowerCase()}`}
      subtitle="Record site activity and save it as a draft for review."
      leading={<FilePlus2 className="size-[18px]" aria-hidden="true" />}
      backLink={
        <Link
          to="/dashboard/my-reports"
          search={{ ...search, type: type === 'engineering' ? 'engineering' : 'survey' }}
          className={pageBackLinkClassName}
        >
          <PageBackLinkContent>My Work Reports</PageBackLinkContent>
        </Link>
      }
      actionsInline
      contentClassName="space-y-0"
    >
      <div className="desktop:grid-cols-[16rem_minmax(0,1fr)] desktop:items-start desktop:gap-6 grid min-w-0 gap-5">
        <CreationFlowStepper
          ariaLabel="Site report form"
          steps={flowSteps}
          currentStep={step}
          maxSelectableStep={furthestStep}
          onStepSelect={goToStep}
          variant="responsive"
        />
        <div className="min-w-0 space-y-5">
          {formError ? (
            <Alert tone="danger" role="alert" title="Report not created">
              {formError}
            </Alert>
          ) : null}
          {uploadStatus ? (
            <div
              role="status"
              aria-live="polite"
              className="bg-primary-subtle text-primary rounded-control flex items-center gap-2.5 px-3 py-2.5"
            >
              <LoaderCircle className="size-4 shrink-0 animate-spin" aria-hidden="true" />
              <span className="text-body-sm min-w-0">{uploadStatus}</span>
            </div>
          ) : null}
          <form onSubmit={handleSubmit} className="space-y-5">
            {step === 0 ? (
              <FormSection className="space-y-4">
                <div>
                  <h2 className="text-h3 text-text-primary font-semibold">Report context</h2>
                  <p className="text-body-sm text-text-secondary mt-1">
                    Choose the site and date. Your employee profile will be attached by the server.
                  </p>
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <form.Field name="worksiteId">
                    {(field) => (
                      <FormControl
                        id="site-create-worksite"
                        label="Worksite"
                        required
                        error={fieldValidationMessage('site-create-worksite')}
                      >
                        <DropdownSelect
                          aria-label="Worksite"
                          value={field.state.value}
                          options={worksiteOptions}
                          placeholder="Choose a worksite"
                          searchable
                          onChange={(value) => {
                            field.handleChange(value)
                            clearFieldValidationError('site-create-worksite')
                            setTaskId('')
                            setMaterials([])
                          }}
                        />
                      </FormControl>
                    )}
                  </form.Field>
                  <form.Field name="date">
                    {(field) => (
                      <FormControl
                        id="site-create-date"
                        label="Report date"
                        required
                        error={fieldValidationMessage('site-create-date')}
                      >
                        <DatePickerField
                          id="site-create-date"
                          required
                          value={field.state.value}
                          onValueChange={(value) => {
                            field.handleChange(value)
                            clearFieldValidationError('site-create-date')
                          }}
                        />
                      </FormControl>
                    )}
                  </form.Field>
                </div>
                {selectedWorksite?.project_id ? (
                  <p className="text-caption text-text-secondary">
                    Linked project #{selectedWorksite.project_id}
                  </p>
                ) : null}
                {canListTasks && selectedWorksite?.project_id ? (
                  tasksQuery.isError ? (
                    <Alert tone="warning" title="Tasks could not load">
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <span>You can still create the report without linking a task.</span>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => void tasksQuery.refetch()}
                        >
                          Retry task lookup
                        </Button>
                      </div>
                    </Alert>
                  ) : taskOptions.length ? (
                    <FormControl id="site-create-task" label="Task (optional)">
                      <DropdownSelect
                        aria-label="Task (optional)"
                        value={taskId}
                        options={taskOptions}
                        placeholder="No task selected"
                        disabled={tasksQuery.isPending}
                        onChange={setTaskId}
                      />
                    </FormControl>
                  ) : null
                ) : null}
              </FormSection>
            ) : null}

            {step === 1 && type === 'survey' ? (
              <FormSection className="space-y-4">
                <div>
                  <h2 className="text-h3 text-text-primary font-semibold">Survey measurements</h2>
                  <p className="text-body-sm text-text-secondary mt-1">
                    Choose the measurement format and record its points.
                  </p>
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <FormControl id="site-create-data-type" label="Measurement format" required>
                    <DropdownSelect
                      aria-label="Measurement format"
                      value={dataType}
                      options={dataTypes}
                      onChange={(value) => setDataType(value as typeof dataType)}
                    />
                  </FormControl>
                  <FormControl id="site-create-unit" label="Measurement unit" required>
                    <DropdownSelect
                      aria-label="Measurement unit"
                      value={measurementUnit}
                      options={units}
                      onChange={setMeasurementUnit}
                    />
                  </FormControl>
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  {(
                    [
                      ['Coordinate system', coordinateSystem, setCoordinateSystem],
                      ['Datum', datum, setDatum],
                      ['Coordinate zone', coordinateZone, setCoordinateZone],
                      ['GPS latitude', latitude, setLatitude],
                      ['GPS longitude', longitude, setLongitude],
                    ] as const
                  ).map(([label, value, onChange]) => (
                    <FormControl
                      key={label}
                      id={`site-create-${label.toLowerCase().replaceAll(' ', '-')}`}
                      label={label}
                      error={fieldValidationMessage(
                        `site-create-${label.toLowerCase().replaceAll(' ', '-')}`,
                      )}
                    >
                      <TextInput
                        inputMode={label.startsWith('GPS') ? 'decimal' : undefined}
                        value={value}
                        onChange={(event) => {
                          onChange(event.target.value)
                          clearFieldValidationError(
                            `site-create-${label.toLowerCase().replaceAll(' ', '-')}`,
                          )
                        }}
                      />
                    </FormControl>
                  ))}
                </div>
                {dataType === 'bearing_distance' ? (
                  <section className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <h3 className="text-label text-text-primary font-semibold">
                        Bearing and distance points
                      </h3>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          setBearingPoints((items) => [
                            ...items,
                            { degrees: '', minutes: '', seconds: '', distance: '' },
                          ])
                        }
                      >
                        <Plus className="size-4" aria-hidden="true" /> Add point
                      </Button>
                    </div>
                    {bearingPoints.map((point, index) => (
                      <div
                        key={index}
                        className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-4"
                      >
                        {(
                          [
                            ['degrees', 'Degrees'],
                            ['minutes', 'Minutes'],
                            ['seconds', 'Seconds'],
                            ['distance', `Distance (${measurementUnit})`],
                          ] as const
                        ).map(([key, label]) => (
                          <FormControl
                            key={key}
                            id={`site-create-bearing-${key}-${index}`}
                            label={label}
                            required
                            error={fieldValidationMessage(`site-create-bearing-${key}-${index}`)}
                          >
                            <TextInput
                              inputMode="decimal"
                              value={point[key]}
                              onChange={(event) => {
                                setBearingPoints((items) =>
                                  items.map((item, row) =>
                                    row === index ? { ...item, [key]: event.target.value } : item,
                                  ),
                                )
                                clearFieldValidationError(`site-create-bearing-${key}-${index}`)
                              }}
                            />
                          </FormControl>
                        ))}
                        <div className="flex justify-end sm:col-span-4">
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            disabled={bearingPoints.length === 1}
                            onClick={() =>
                              setBearingPoints((items) => items.filter((_, row) => row !== index))
                            }
                            aria-label={`Remove bearing point ${index + 1}`}
                          >
                            <Trash2 className="size-4" aria-hidden="true" /> Remove point
                          </Button>
                        </div>
                      </div>
                    ))}
                  </section>
                ) : (
                  <section className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <h3 className="text-label text-text-primary font-semibold">
                        XYZ site points
                      </h3>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          setXyzPoints((items) => [
                            ...items,
                            { northing: '', easting: '', elevation: '' },
                          ])
                        }
                      >
                        <Plus className="size-4" aria-hidden="true" /> Add point
                      </Button>
                    </div>
                    {xyzPoints.map((point, index) => (
                      <div
                        key={index}
                        className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-3"
                      >
                        {(
                          [
                            ['northing', 'Northing'],
                            ['easting', 'Easting'],
                            ['elevation', 'Elevation'],
                          ] as const
                        ).map(([key, label]) => (
                          <FormControl
                            key={key}
                            id={`site-create-xyz-${key}-${index}`}
                            label={label}
                            required
                            error={fieldValidationMessage(`site-create-xyz-${key}-${index}`)}
                          >
                            <TextInput
                              inputMode="decimal"
                              value={point[key]}
                              onChange={(event) => {
                                setXyzPoints((items) =>
                                  items.map((item, row) =>
                                    row === index ? { ...item, [key]: event.target.value } : item,
                                  ),
                                )
                                clearFieldValidationError(`site-create-xyz-${key}-${index}`)
                              }}
                            />
                          </FormControl>
                        ))}
                        <div className="flex justify-end sm:col-span-3">
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            disabled={xyzPoints.length === 1}
                            onClick={() =>
                              setXyzPoints((items) => items.filter((_, row) => row !== index))
                            }
                            aria-label={`Remove XYZ point ${index + 1}`}
                          >
                            <Trash2 className="size-4" aria-hidden="true" /> Remove point
                          </Button>
                        </div>
                      </div>
                    ))}
                  </section>
                )}
              </FormSection>
            ) : null}

            {step === 1 ? (
              <FormSection className="space-y-4">
                <div className="flex flex-wrap items-start justify-between gap-2">
                  <div>
                    <h2 className="text-h3 text-text-primary font-semibold">Activities</h2>
                    <p className="text-body-sm text-text-secondary mt-1">
                      At least one completed activity is required.
                    </p>
                  </div>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setActivities((items) => [
                        ...items,
                        {
                          activityType: type === 'engineering' ? 'concrete_work' : 'general_survey',
                          description: '',
                        },
                      ])
                    }
                  >
                    <Plus className="size-4" aria-hidden="true" /> Add activity
                  </Button>
                </div>
                {activities.map((activity, index) => (
                  <div
                    key={index}
                    className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-2"
                  >
                    {type === 'engineering' ? (
                      <FormControl
                        id={`site-create-activity-type-${index}`}
                        label="Activity type"
                        required
                      >
                        <DropdownSelect
                          aria-label={`Activity ${index + 1} type`}
                          value={activity.activityType}
                          options={activityTypes}
                          onChange={(activityType) =>
                            setActivities((items) =>
                              items.map((item, row) =>
                                row === index ? { ...item, activityType } : item,
                              ),
                            )
                          }
                        />
                      </FormControl>
                    ) : null}
                    <FormControl
                      id={`site-create-activity-${index}`}
                      label={`Activity ${index + 1}`}
                      required
                      error={fieldValidationMessage(`site-create-activity-${index}`)}
                    >
                      <TextArea
                        rows={2}
                        value={activity.description}
                        onChange={(event) => {
                          setActivities((items) =>
                            items.map((item, row) =>
                              row === index ? { ...item, description: event.target.value } : item,
                            ),
                          )
                          clearFieldValidationError(`site-create-activity-${index}`)
                        }}
                      />
                    </FormControl>
                    <div className="flex justify-end sm:col-span-2">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        disabled={activities.length === 1}
                        onClick={() =>
                          setActivities((items) => items.filter((_, row) => row !== index))
                        }
                        aria-label={`Remove activity ${index + 1}`}
                      >
                        <Trash2 className="size-4" aria-hidden="true" /> Remove activity
                      </Button>
                    </div>
                  </div>
                ))}
              </FormSection>
            ) : null}

            {step === 2 ? (
              <FormSection className="space-y-4">
                <div className="flex flex-wrap items-start justify-between gap-2">
                  <div>
                    <h2 className="text-h3 text-text-primary font-semibold">
                      Expenses and materials
                    </h2>
                    <p className="text-body-sm text-text-secondary mt-1">
                      These sections are optional.
                    </p>
                  </div>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setExpenses((items) => [
                        ...items,
                        { category: 'labour', name: '', amount: '', description: '' },
                      ])
                    }
                  >
                    <Plus className="size-4" aria-hidden="true" /> Add expense
                  </Button>
                </div>
                {expenses.map((expense, index) => (
                  <div
                    key={index}
                    className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-2"
                  >
                    <FormControl
                      id={`site-create-expense-category-${index}`}
                      label="Category"
                      required
                      error={fieldValidationMessage(`site-create-expense-category-${index}`)}
                    >
                      <DropdownSelect
                        aria-label={`Expense ${index + 1} category`}
                        value={expense.category}
                        options={expenseCategories}
                        onChange={(category) => {
                          setExpenses((items) =>
                            items.map((item, row) =>
                              row === index ? { ...item, category } : item,
                            ),
                          )
                          clearFieldValidationError(`site-create-expense-category-${index}`)
                        }}
                      />
                    </FormControl>
                    <FormControl
                      id={`site-create-expense-name-${index}`}
                      label="Expense name"
                      required
                      error={fieldValidationMessage(`site-create-expense-name-${index}`)}
                    >
                      <TextInput
                        value={expense.name}
                        onChange={(event) => {
                          setExpenses((items) =>
                            items.map((item, row) =>
                              row === index ? { ...item, name: event.target.value } : item,
                            ),
                          )
                          clearFieldValidationError(`site-create-expense-name-${index}`)
                        }}
                      />
                    </FormControl>
                    <FormControl
                      id={`site-create-expense-amount-${index}`}
                      label="Amount (NGN)"
                      required
                      error={fieldValidationMessage(`site-create-expense-amount-${index}`)}
                    >
                      <TextInput
                        inputMode="decimal"
                        value={expense.amount}
                        onChange={(event) => {
                          setExpenses((items) =>
                            items.map((item, row) =>
                              row === index ? { ...item, amount: event.target.value } : item,
                            ),
                          )
                          clearFieldValidationError(`site-create-expense-amount-${index}`)
                        }}
                      />
                    </FormControl>
                    <FormControl
                      id={`site-create-expense-description-${index}`}
                      label="Description"
                      required
                      error={fieldValidationMessage(`site-create-expense-description-${index}`)}
                    >
                      <TextInput
                        value={expense.description}
                        onChange={(event) => {
                          setExpenses((items) =>
                            items.map((item, row) =>
                              row === index ? { ...item, description: event.target.value } : item,
                            ),
                          )
                          clearFieldValidationError(`site-create-expense-description-${index}`)
                        }}
                      />
                    </FormControl>
                    <div className="flex justify-end sm:col-span-2">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() =>
                          setExpenses((items) => items.filter((_, row) => row !== index))
                        }
                        aria-label={`Remove expense ${index + 1}`}
                      >
                        <Trash2 className="size-4" aria-hidden="true" /> Remove expense
                      </Button>
                    </div>
                  </div>
                ))}
                {canListEquipment ? (
                  <section className="border-border-subtle space-y-3 border-t pt-4">
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <div>
                        <h3 className="text-label text-text-primary font-semibold">
                          Materials used
                        </h3>
                        <p className="text-caption text-text-secondary mt-1">
                          Only inventory for the selected worksite is available.
                        </p>
                      </div>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        disabled={!selectedWorksite || equipmentQuery.isError}
                        onClick={() =>
                          setMaterials((items) => [...items, { equipmentId: '', quantity: '' }])
                        }
                      >
                        <Plus className="size-4" aria-hidden="true" /> Add material
                      </Button>
                    </div>
                    {equipmentQuery.isError ? (
                      <Alert tone="warning" title="Inventory could not load">
                        <div className="flex flex-wrap items-center justify-between gap-2">
                          <span>You can continue without recording material usage.</span>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => void equipmentQuery.refetch()}
                          >
                            Retry inventory
                          </Button>
                        </div>
                      </Alert>
                    ) : null}
                    {materials.map((material, index) => (
                      <div
                        key={index}
                        className="bg-surface-muted rounded-control grid gap-3 p-3 sm:grid-cols-[minmax(0,1fr)_12rem_auto] sm:items-end"
                      >
                        <FormControl
                          id={`site-create-material-${index}`}
                          label="Inventory item"
                          required
                          error={fieldValidationMessage(`site-create-material-${index}`)}
                        >
                          <DropdownSelect
                            aria-label={`Material ${index + 1} inventory item`}
                            value={material.equipmentId}
                            options={equipmentOptions}
                            placeholder={
                              equipmentQuery.isPending ? 'Loading inventory' : 'Choose inventory'
                            }
                            disabled={equipmentQuery.isPending || !equipmentOptions.length}
                            onChange={(equipmentId) => {
                              setMaterials((items) =>
                                items.map((item, row) =>
                                  row === index ? { ...item, equipmentId } : item,
                                ),
                              )
                              clearFieldValidationError(`site-create-material-${index}`)
                            }}
                          />
                        </FormControl>
                        <FormControl
                          id={`site-create-material-quantity-${index}`}
                          label="Quantity used"
                          required
                          error={fieldValidationMessage(`site-create-material-quantity-${index}`)}
                        >
                          <TextInput
                            inputMode="decimal"
                            value={material.quantity}
                            onChange={(event) => {
                              setMaterials((items) =>
                                items.map((item, row) =>
                                  row === index ? { ...item, quantity: event.target.value } : item,
                                ),
                              )
                              clearFieldValidationError(`site-create-material-quantity-${index}`)
                            }}
                          />
                        </FormControl>
                        <Button
                          type="button"
                          variant="ghost"
                          size="sm"
                          onClick={() =>
                            setMaterials((items) => items.filter((_, row) => row !== index))
                          }
                          aria-label={`Remove material ${index + 1}`}
                        >
                          <Trash2 className="size-4" aria-hidden="true" /> Remove
                        </Button>
                      </div>
                    ))}
                  </section>
                ) : null}
              </FormSection>
            ) : null}

            {step === 3 && type === 'engineering' ? (
              <FormSection className="space-y-4">
                <h2 className="text-h3 text-text-primary font-semibold">Next steps and notes</h2>
                <FormControl id="site-create-tomorrow" label="Work planned for tomorrow">
                  <TextArea
                    rows={3}
                    value={tomorrow}
                    onChange={(event) => setTomorrow(event.target.value)}
                  />
                </FormControl>
                <FormControl id="site-create-comments" label="Comments and suggestions">
                  <TextArea
                    rows={3}
                    value={comments}
                    onChange={(event) => setComments(event.target.value)}
                  />
                </FormControl>
              </FormSection>
            ) : null}

            {step === 3 ? (
              <FormSection className="tablet:p-6 space-y-5">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="flex min-w-0 items-start gap-3">
                    <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                      <Paperclip className="size-5" aria-hidden="true" />
                    </span>
                    <div className="min-w-0">
                      <h2 className="text-h3 text-text-primary font-semibold">Attachments</h2>
                      <p className="text-body-sm text-text-secondary mt-1 max-w-2xl">
                        Add photos, drawings, or documents to support your report. Each file can be
                        up to 15 MB.
                      </p>
                    </div>
                  </div>
                  <span className="text-caption text-text-secondary bg-surface-muted rounded-pill px-3 py-1.5">
                    {attachments.length} {attachments.length === 1 ? 'file' : 'files'}
                  </span>
                </div>

                <input
                  ref={attachmentsInput}
                  id="site-create-attachments"
                  aria-label="Supporting evidence files"
                  type="file"
                  multiple
                  className="sr-only"
                  tabIndex={-1}
                  onChange={(event) => {
                    addAttachmentFiles(Array.from(event.currentTarget.files ?? []))
                    event.currentTarget.value = ''
                  }}
                />
                <div
                  onDragEnter={(event) => {
                    event.preventDefault()
                    setIsDraggingFiles(true)
                  }}
                  onDragOver={(event) => event.preventDefault()}
                  onDragLeave={(event) => {
                    if (!event.currentTarget.contains(event.relatedTarget as Node | null))
                      setIsDraggingFiles(false)
                  }}
                  onDrop={handleAttachmentDrop}
                  className={`rounded-surface flex min-h-44 flex-col items-center justify-center border-2 border-dashed px-5 py-6 text-center transition-colors ${isDraggingFiles ? 'border-primary bg-primary-subtle/60' : 'border-border-strong bg-surface-muted/40'}`}
                >
                  <span className="text-primary bg-primary-subtle rounded-surface mb-3 flex size-11 items-center justify-center">
                    <Upload className="size-5" aria-hidden="true" />
                  </span>
                  <p className="text-label text-text-primary font-semibold">
                    Add files to this report
                  </p>
                  <p className="text-caption text-text-secondary mt-1 max-w-sm">
                    Drop files here or choose them from your device. Upload starts when you create
                    the draft.
                  </p>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="mt-4"
                    aria-describedby={attachmentError ? 'site-create-attachments-error' : undefined}
                    aria-invalid={attachmentError ? 'true' : undefined}
                    leadingIcon={<Paperclip className="size-4" aria-hidden="true" />}
                    onClick={() => attachmentsInput.current?.click()}
                  >
                    Choose files
                  </Button>
                </div>
                {attachmentError ? (
                  <p
                    id="site-create-attachments-error"
                    className="text-body-sm text-danger"
                    role="alert"
                  >
                    {attachmentError}
                  </p>
                ) : null}
                <ReportEvidenceList
                  items={attachments.map((attachment, index): ReportEvidenceItem => ({
                    id: `attachment-${index}`,
                    name: attachment.file.name,
                    detail: attachment.url
                      ? 'Uploaded; will be linked when the draft is saved'
                      : formatFileSize(attachment.file.size),
                    mediaType: attachment.file.type,
                    href: attachment.url,
                    status: attachment.url ? undefined : 'ready',
                  }))}
                  onRemove={(id) => {
                    const index = Number(id.replace('attachment-', ''))
                    setAttachments((current) =>
                      current.filter((_, itemIndex) => itemIndex !== index),
                    )
                  }}
                />
              </FormSection>
            ) : null}

            {step === 4 ? (
              <div className="tablet:space-y-5 space-y-4" aria-label="Report review">
                <Card className="border-primary/15 overflow-hidden p-0">
                  <div className="from-primary-subtle/75 via-surface to-surface border-primary/10 tablet:p-6 flex flex-wrap items-start justify-between gap-4 border-b bg-gradient-to-r p-4">
                    <div className="flex min-w-0 items-start gap-3">
                      <span className="bg-primary text-text-on-primary rounded-surface flex size-11 shrink-0 items-center justify-center shadow-sm">
                        <CheckCircle2 className="size-5" aria-hidden="true" />
                      </span>
                      <div className="min-w-0">
                        <p className="text-overline text-primary font-semibold">Ready to save</p>
                        <h2 className="text-h2 text-text-primary mt-1 font-semibold">
                          Review your report
                        </h2>
                        <p className="text-body-sm text-text-secondary mt-1">
                          Creating this report saves it as a draft. Open the saved report to submit
                          it for review.
                        </p>
                      </div>
                    </div>
                    <StatusChip
                      label={type === 'engineering' ? 'Engineering' : 'Survey'}
                      tone="primary"
                      icon={<FileText className="size-3.5" />}
                    />
                  </div>
                  <div
                    role="group"
                    aria-label="Report summary"
                    className="phone:grid-cols-2 desktop:grid-cols-3 tablet:p-5 grid min-w-0 gap-2.5 p-4"
                  >
                    <ReviewMetric
                      icon={<MapPin className="size-4" aria-hidden="true" />}
                      label="Worksite"
                      value={selectedWorksite?.name ?? 'Not selected'}
                    />
                    <ReviewMetric
                      icon={<CalendarDays className="size-4" aria-hidden="true" />}
                      label="Report date"
                      value={formatReportDate(form.state.values.date)}
                    />
                    <ReviewMetric
                      icon={<Activity className="size-4" aria-hidden="true" />}
                      label="Activities"
                      value={`${activities.filter((item) => item.description.trim()).length} recorded`}
                    />
                  </div>
                </Card>

                <ReviewSection
                  title="Activities completed"
                  detail="Work recorded for this site report"
                  icon={<ClipboardList className="size-5" aria-hidden="true" />}
                  onEdit={() => goToStep(1)}
                >
                  <ul className="space-y-2">
                    {activities
                      .filter((item) => item.description.trim())
                      .map((activity, index) => (
                        <li
                          key={`${index}-${activity.description}`}
                          className="rounded-control border-border-subtle bg-surface-muted/60 flex min-w-0 items-start gap-3 border p-3"
                        >
                          <span className="bg-success-subtle text-success-foreground text-caption mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full font-semibold">
                            {index + 1}
                          </span>
                          <div className="min-w-0">
                            <p className="text-caption text-text-secondary">
                              {activityTypes.find((item) => item.value === activity.activityType)
                                ?.label ?? 'Activity'}
                            </p>
                            <p className="text-body-sm text-text-primary mt-0.5 break-words whitespace-pre-wrap">
                              {activity.description.trim()}
                            </p>
                          </div>
                        </li>
                      ))}
                  </ul>
                </ReviewSection>

                {type === 'survey' ? (
                  <ReviewSection
                    title="Survey measurements"
                    detail={`${dataType === 'bearing_distance' ? bearingPoints.length : xyzPoints.length} ${dataType === 'bearing_distance' ? 'bearing and distance' : 'XYZ'} ${dataType === 'bearing_distance' ? 'point' : 'point'}${(dataType === 'bearing_distance' ? bearingPoints.length : xyzPoints.length) === 1 ? '' : 's'} · ${measurementUnit}`}
                    icon={<Ruler className="size-5" aria-hidden="true" />}
                    onEdit={() => goToStep(1)}
                  >
                    {dataType === 'bearing_distance' ? (
                      <ul className="space-y-2">
                        {bearingPoints.map((point, index) => (
                          <li
                            key={`bearing-${index}`}
                            className="rounded-control border-border-subtle bg-surface-muted/60 phone:grid-cols-2 grid min-w-0 gap-2 border p-3"
                          >
                            <ReviewItem label={`Point ${index + 1}`}>
                              {`${point.degrees}° ${point.minutes}′ ${point.seconds}″`}
                            </ReviewItem>
                            <ReviewItem label="Distance">{`${point.distance} ${measurementUnit}`}</ReviewItem>
                          </li>
                        ))}
                      </ul>
                    ) : (
                      <ul className="space-y-2">
                        {xyzPoints.map((point, index) => (
                          <li
                            key={`xyz-${index}`}
                            className="rounded-control border-border-subtle bg-surface-muted/60 phone:grid-cols-3 grid min-w-0 gap-3 border p-3"
                          >
                            <ReviewItem label={`Point ${index + 1} · Northing`}>
                              {point.northing}
                            </ReviewItem>
                            <ReviewItem label="Easting">{point.easting}</ReviewItem>
                            <ReviewItem label="Elevation">{point.elevation}</ReviewItem>
                          </li>
                        ))}
                      </ul>
                    )}
                    {coordinateSystem || datum || coordinateZone || (latitude && longitude) ? (
                      <div
                        role="group"
                        aria-label="Survey reference details"
                        className="border-border-subtle phone:grid-cols-2 mt-3 grid min-w-0 gap-3 border-t pt-3"
                      >
                        {coordinateSystem ? (
                          <ReviewItem label="Coordinate system">{coordinateSystem}</ReviewItem>
                        ) : null}
                        {datum ? <ReviewItem label="Datum">{datum}</ReviewItem> : null}
                        {coordinateZone ? (
                          <ReviewItem label="Coordinate zone">{coordinateZone}</ReviewItem>
                        ) : null}
                        {latitude && longitude ? (
                          <ReviewItem label="GPS coordinates">
                            {latitude}, {longitude}
                          </ReviewItem>
                        ) : null}
                      </div>
                    ) : null}
                  </ReviewSection>
                ) : null}

                <ReviewSection
                  title="Expenses and materials"
                  detail="Costs and inventory used on this report"
                  icon={<Receipt className="size-5" aria-hidden="true" />}
                  onEdit={() => goToStep(2)}
                >
                  {expenses.length || materials.length ? (
                    <div className="space-y-4">
                      {expenses.length ? (
                        <div className="space-y-2">
                          <p className="text-caption text-text-secondary font-semibold tracking-wide uppercase">
                            Expenses ·{' '}
                            {formatNaira(
                              expenses
                                .reduce((sum, item) => sum + Number(item.amount || 0), 0)
                                .toString(),
                            )}
                          </p>
                          <ul className="divide-border-subtle divide-y">
                            {expenses.map((item, index) => (
                              <li
                                key={`expense-${index}`}
                                className="flex min-w-0 flex-wrap items-start justify-between gap-2 py-3 first:pt-1"
                              >
                                <div className="min-w-0">
                                  <p className="text-body-sm text-text-primary font-semibold break-words">
                                    {item.name}
                                  </p>
                                  <p className="text-caption text-text-secondary mt-0.5 break-words">
                                    {expenseCategories.find(
                                      (category) => category.value === item.category,
                                    )?.label ?? item.category}
                                    {item.description.trim() ? ` · ${item.description.trim()}` : ''}
                                  </p>
                                </div>
                                <span className="text-body-sm text-text-primary shrink-0 font-semibold">
                                  {formatNaira(item.amount)}
                                </span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      ) : null}
                      {materials.length ? (
                        <div className="space-y-2">
                          <p className="text-caption text-text-secondary font-semibold tracking-wide uppercase">
                            Materials used
                          </p>
                          <ul className="divide-border-subtle divide-y">
                            {materials.map((item, index) => (
                              <li
                                key={`material-${index}`}
                                className="flex min-w-0 flex-wrap items-start justify-between gap-2 py-3 first:pt-1"
                              >
                                <span className="text-body-sm text-text-primary min-w-0 break-words">
                                  {equipmentOptions.find(
                                    (option) => option.value === item.equipmentId,
                                  )?.label ?? 'Selected inventory item'}
                                </span>
                                <span className="text-body-sm text-text-primary shrink-0 font-semibold">
                                  {item.quantity}
                                </span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      ) : null}
                    </div>
                  ) : (
                    <p className="text-body-sm text-text-secondary">
                      No expenses or materials added.
                    </p>
                  )}
                </ReviewSection>

                {type === 'engineering' ? (
                  <ReviewSection
                    title="Notes and next steps"
                    detail="Optional follow-up information"
                    icon={<FileText className="size-5" aria-hidden="true" />}
                    onEdit={() => goToStep(3)}
                  >
                    {tomorrow.trim() || comments.trim() ? (
                      <div className="space-y-3">
                        {tomorrow.trim() ? (
                          <div>
                            <p className="text-caption text-text-secondary font-medium">
                              Work planned for tomorrow
                            </p>
                            <p className="text-body-sm text-text-primary mt-1 whitespace-pre-wrap">
                              {tomorrow.trim()}
                            </p>
                          </div>
                        ) : null}
                        {comments.trim() ? (
                          <div>
                            <p className="text-caption text-text-secondary font-medium">
                              Comments and suggestions
                            </p>
                            <p className="text-body-sm text-text-primary mt-1 whitespace-pre-wrap">
                              {comments.trim()}
                            </p>
                          </div>
                        ) : null}
                      </div>
                    ) : (
                      <p className="text-body-sm text-text-secondary">No additional notes.</p>
                    )}
                  </ReviewSection>
                ) : null}

                <ReviewSection
                  title="Attachments"
                  detail={`${attachments.length} ${attachments.length === 1 ? 'file selected' : 'files selected'}`}
                  icon={<Paperclip className="size-5" aria-hidden="true" />}
                  onEdit={() => goToStep(3)}
                >
                  {attachments.length ? (
                    <ReportEvidenceList
                      items={attachments.map((attachment, index): ReportEvidenceItem => ({
                        id: `review-attachment-${index}`,
                        name: attachment.file.name,
                        detail: attachment.url
                          ? 'Uploaded; ready to link'
                          : formatFileSize(attachment.file.size),
                        mediaType: attachment.file.type,
                        href: attachment.url,
                        status: attachment.url ? 'attached' : 'ready',
                      }))}
                    />
                  ) : (
                    <p className="text-body-sm text-text-secondary">No files attached.</p>
                  )}
                </ReviewSection>
              </div>
            ) : null}

            <CreationFlowActions
              className="bg-surface border-border-subtle rounded-control shadow-elevation-sm tablet:p-4 border p-3"
              leading={
                <div className="flex flex-wrap items-center gap-2">
                  {step > 0 ? (
                    <Button
                      type="button"
                      variant="outline"
                      disabled={mutation.isPending || isUploading || form.state.isSubmitting}
                      onClick={() => {
                        setFormError('')
                        setReviewReady(false)
                        setStep((current) => Math.max(0, current - 1) as SiteReportFormStep)
                      }}
                      leadingIcon={<ArrowLeft className="size-4" />}
                    >
                      Previous
                    </Button>
                  ) : null}
                  <Link
                    to="/dashboard/my-reports"
                    search={{ ...search, type }}
                    className="text-body-sm text-text-secondary hover:text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center px-3 font-medium focus-visible:outline-none"
                  >
                    Cancel
                  </Link>
                </div>
              }
            >
              {step < 4 ? (
                <Button type="button" disabled={mutation.isPending} onClick={continueToNextStep}>
                  Continue
                </Button>
              ) : (
                <Button
                  type="submit"
                  aria-label={
                    isUploading
                      ? 'Uploading report files'
                      : mutation.isPending
                        ? 'Creating report'
                        : 'Create report'
                  }
                  className="ml-auto shrink-0 whitespace-nowrap"
                  disabled={
                    !reviewReady || form.state.isSubmitting || mutation.isPending || isUploading
                  }
                >
                  {isUploading ? (
                    'Uploading…'
                  ) : mutation.isPending ? (
                    'Creating…'
                  ) : (
                    <>
                      <span className="tablet:hidden">Create</span>
                      <span className="tablet:inline hidden">Create report</span>
                    </>
                  )}
                </Button>
              )}
            </CreationFlowActions>
          </form>
        </div>
      </div>
    </PageLayout>
  )
}
