import { useQuery } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import { ArrowUpRight, Clock3, FileCheck2, FileText } from 'lucide-react'
import type { ReactNode } from 'react'

import {
  complianceApi,
  compliancePriorities,
  complianceQueryKeys,
  type ComplianceRecordDto,
} from '@/modules/company/governance.api'
import {
  complianceState,
  complianceTypeLabel,
  formatComplianceDate,
  safeComplianceDocumentUrl,
} from '@/modules/company/compliance-presentation'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { StatusChip } from '@/shared/ui/status-chip'

import type { ComplianceSearch } from '../governance.search'

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
          <a className="hover:text-primary underline-offset-2 hover:underline" href={href}>
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
      <h2 className="text-label text-text-primary font-semibold">{title}</h2>
      <dl className="tablet:grid-cols-2 mt-4 grid min-w-0 gap-x-6">{children}</dl>
    </Card>
  )
}

function documentLabel(value: string, index: number) {
  const url = safeComplianceDocumentUrl(value)
  if (!url) return `Document ${index + 1}`
  const filename = new URL(url).pathname.split('/').filter(Boolean).at(-1)
  if (!filename) return `Document ${index + 1}`
  try {
    return decodeURIComponent(filename)
  } catch {
    return filename
  }
}

function isImageDocument(value: string) {
  const url = safeComplianceDocumentUrl(value)
  return Boolean(url && /\.(avif|gif|jpe?g|png|webp)$/i.test(new URL(url).pathname))
}

function complianceCost(value: number | null) {
  return value == null
    ? 'Not provided'
    : value.toLocaleString(undefined, { maximumFractionDigits: 2 })
}

function ComplianceDetails({ record }: { record: ComplianceRecordDto }) {
  const state = complianceState(record)
  const daysUntilExpiry =
    record.is_expired || record.status === 'expired'
      ? record.days_until_expiry < 0
        ? `Expired ${Math.abs(record.days_until_expiry)} day${Math.abs(record.days_until_expiry) === 1 ? '' : 's'} ago`
        : 'Expired'
      : record.days_until_expiry === 0
        ? 'Expires today'
        : record.days_until_expiry > 0
          ? `${record.days_until_expiry} day${record.days_until_expiry === 1 ? '' : 's'} remaining`
          : 'Expired'

  return (
    <div className="space-y-5">
      <div className="desktop:grid-cols-2 grid min-w-0 gap-5">
        <DetailSection title="Responsible person">
          <DetailField label="Full name" value={record.full_name} />
          <DetailField label="Department" value={`Department ${record.department_id}`} />
          <DetailField
            label="Responsible email"
            value={record.email_address}
            href={`mailto:${record.email_address}`}
          />
          <DetailField
            label="Phone"
            value={record.phone_number}
            href={`tel:${record.phone_number}`}
          />
          <DetailField label="Contact person" value={record.contact_person} />
          <DetailField
            label="Contact email"
            value={record.contact_email}
            href={record.contact_email ? `mailto:${record.contact_email}` : undefined}
          />
        </DetailSection>

        <DetailSection title="Compliance document">
          <DetailField label="Type" value={complianceTypeLabel(record.compliance_type)} />
          <DetailField label="Issuing authority" value={record.issuing_authority} />
          <DetailField label="Reference number" value={record.reference_number} />
          <DetailField label="Cost" value={complianceCost(record.cost)} />
        </DetailSection>

        <DetailSection title="Validity and status">
          <DetailField label="Date of issue" value={formatComplianceDate(record.date_of_issue)} />
          <DetailField label="Expiry date" value={formatComplianceDate(record.expiry_date)} />
          <DetailField label="Time to expiry" value={daysUntilExpiry} />
          <DetailField label="Record status" value={state.label} />
          {state.hint ? <DetailField label="Expiry notice" value={state.hint} /> : null}
        </DetailSection>

        <DetailSection title="Record history">
          <DetailField label="Created" value={formatComplianceDate(record.created_at)} />
          <DetailField label="Last updated" value={formatComplianceDate(record.updated_at)} />
          <DetailField label="Record number" value={record.id} />
        </DetailSection>
      </div>

      <Card className="phone:p-5 min-w-0 p-4">
        <h2 className="text-label text-text-primary font-semibold">Description</h2>
        <p className="text-body-sm text-text-secondary break-words whitespace-pre-wrap">
          {record.description || 'No description has been added.'}
        </p>
      </Card>

      <Card className="phone:p-5 min-w-0 p-4">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <FileText className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <h2 className="text-label text-text-primary font-semibold">Supporting documents</h2>
            <p className="text-caption text-text-secondary mt-1">
              {record.documents.length
                ? `${record.documents.length} attached file${record.documents.length === 1 ? '' : 's'}`
                : 'No files have been attached.'}
            </p>
          </div>
        </div>
        {record.documents.length ? (
          <ul className="tablet:grid-cols-2 mt-4 grid min-w-0 gap-3">
            {record.documents.map((rawUrl, index) => {
              const url = safeComplianceDocumentUrl(rawUrl)
              if (!url) {
                return (
                  <li
                    key={`${record.id}-${index}`}
                    className="border-border-subtle bg-surface-muted text-caption text-text-muted rounded-control border p-3"
                  >
                    {documentLabel(rawUrl, index)} · link unavailable
                  </li>
                )
              }
              const label = documentLabel(url, index)
              return (
                <li
                  key={`${record.id}-${index}`}
                  className="border-border-subtle bg-surface-muted/50 rounded-control min-w-0 overflow-hidden border"
                >
                  {isImageDocument(url) ? (
                    <a href={url} target="_blank" rel="noreferrer" aria-label={`Open ${label}`}>
                      <img
                        src={url}
                        alt={label}
                        loading="lazy"
                        referrerPolicy="no-referrer"
                        className="bg-surface max-h-72 w-full object-contain"
                      />
                    </a>
                  ) : null}
                  <div className="flex min-w-0 items-center justify-between gap-3 p-3">
                    <p className="text-body-sm text-text-primary min-w-0 truncate font-medium">
                      {label}
                    </p>
                    <a
                      href={url}
                      target="_blank"
                      rel="noreferrer"
                      className="text-caption text-primary inline-flex min-h-9 shrink-0 items-center gap-1.5 font-semibold"
                    >
                      Open file <ArrowUpRight className="size-3.5" aria-hidden="true" />
                    </a>
                  </div>
                </li>
              )
            })}
          </ul>
        ) : null}
      </Card>
    </div>
  )
}

export function ComplianceRecordDetailPage() {
  const params = useParams({ from: '/_protected/company/compliance/$recordId' })
  const search = useSearch({ from: '/_protected/company/compliance/$recordId' }) as ComplianceSearch
  const navigate = useNavigate({ from: '/_protected/company/compliance/$recordId' })
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const id = Number(params.recordId)
  const validId = Number.isSafeInteger(id) && id > 0
  const canView = hasPermission(session?.permissions ?? {}, 'compliance_records', 'view')
  const query = useQuery({
    queryKey: complianceQueryKeys.detail(userId, employeeId, validId ? id : 0),
    queryFn: ({ signal }) => complianceApi.detail(id, signal),
    enabled: Boolean(session && canView && validId),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const backLink = (
    <Link to="/company/compliance" search={search} className={pageBackLinkClassName}>
      <PageBackLinkContent>Compliance register</PageBackLinkContent>
    </Link>
  )

  if (!validId) {
    return (
      <PageLayout title="Compliance record not found" backLink={backLink}>
        <EmptyState
          title="This record link is invalid"
          description="Return to the Compliance register and open a record from its list."
          action={
            <Button
              variant="outline"
              onClick={() => void navigate({ to: '/company/compliance', search })}
            >
              Back to Compliance
            </Button>
          }
        />
      </PageLayout>
    )
  }

  if (!canView) {
    return (
      <PageLayout title="Compliance details" backLink={backLink}>
        <EmptyState
          title="You do not have access to these details"
          description="Your Compliance permissions do not include viewing this record."
        />
      </PageLayout>
    )
  }

  const record = query.data
  if (query.isPending && !record) {
    return (
      <PageLayout title="Compliance details" backLink={backLink}>
        <div className="space-y-4">
          <Skeleton className="h-28" />
          <div className="desktop:grid-cols-2 grid gap-4">
            <Skeleton className="h-52" />
            <Skeleton className="h-52" />
          </div>
          <Skeleton className="h-40" />
        </div>
      </PageLayout>
    )
  }

  if (!record && query.error) {
    const notFound = query.error instanceof ApiError && query.error.status === 404
    return (
      <PageLayout
        title={notFound ? 'Compliance record not found' : 'Compliance details'}
        backLink={backLink}
      >
        {notFound ? (
          <EmptyState
            title="Compliance record not found"
            description="This record may have been removed or is outside your access scope."
            action={
              <Button
                variant="outline"
                onClick={() => void navigate({ to: '/company/compliance', search })}
              >
                Back to Compliance
              </Button>
            }
          />
        ) : (
          <ErrorState
            title="Compliance details could not load"
            description="Check your connection and try loading these details again."
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
  const state = complianceState(record)
  const priority = compliancePriorities.find((item) => item.value === record.priority_level)?.label

  return (
    <PageLayout
      title={complianceTypeLabel(record.compliance_type)}
      backLink={backLink}
      actions={
        <div className="flex flex-wrap items-center gap-2">
          <StatusChip label={state.label} tone={state.tone} />
          {priority ? <StatusChip label={`${priority} priority`} tone="neutral" /> : null}
        </div>
      }
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
            <span className="bg-surface text-primary border-primary/10 rounded-surface shadow-elevation-sm phone:size-14 flex size-12 shrink-0 items-center justify-center border">
              <FileCheck2 className="size-6" aria-hidden="true" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-caption text-primary font-semibold">Compliance profile</p>
              <h2 className="text-label text-text-primary mt-1 font-semibold break-words">
                {record.full_name}
              </h2>
              <p className="text-body-sm text-text-secondary mt-1 break-all">
                {record.issuing_authority} · {record.reference_number || `Record ${record.id}`}
              </p>
            </div>
          </div>
        </Card>
        {state.hint ? (
          <Alert tone={state.tone === 'warning' ? 'warning' : 'info'}>
            <span className="inline-flex items-center gap-2">
              <Clock3 className="size-4 shrink-0" aria-hidden="true" /> {state.hint}
            </span>
          </Alert>
        ) : null}
        <ComplianceDetails record={record} />
        <div className="flex justify-start">
          <Button
            variant="outline"
            onClick={() => void navigate({ to: '/company/compliance', search })}
          >
            Back to Compliance register
          </Button>
        </div>
      </div>
    </PageLayout>
  )
}
