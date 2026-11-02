import { ExternalLink, FileText, ImagePlus, Package2 } from 'lucide-react'

import type { AssetDto } from '@/modules/company/assets.api'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

const typeLabels: Record<string, string> = {
  laptop: 'Laptop',
  printer: 'Printer',
  vehicle: 'Vehicle',
  furniture: 'Furniture',
  equipment: 'Equipment',
  other: 'Other',
}

function statusLabel(status: string) {
  const labels: Record<string, string> = {
    available: 'Available',
    in_use: 'In use',
    'in-use': 'In use',
    active: 'Available',
    maintenance: 'Maintenance',
    retired: 'Retired',
    lost_stolen: 'Lost or stolen',
  }
  return labels[status] ?? status.replaceAll('_', ' ')
}

function statusTone(status: string): StatusTone {
  if (status === 'available' || status === 'active') return 'success'
  if (status === 'in_use' || status === 'in-use') return 'primary'
  if (status === 'maintenance') return 'warning'
  if (status === 'lost_stolen') return 'danger'
  return 'neutral'
}

function formatDate(value: string | null) {
  if (!value) return 'Not recorded'
  const date = new Date(value + (value.length === 10 ? 'T00:00:00' : ''))
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }).format(date)
}

function formatValue(value: string | number | null) {
  if (value == null || value === '') return 'Not recorded'
  const amount = Number(value)
  return Number.isFinite(amount)
    ? new Intl.NumberFormat(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(amount)
    : String(value)
}

function DetailValue({ label, value }: { label: string; value: string }) {
  return (
    <div className="min-w-0">
      <dt className="text-overline text-text-secondary">{label}</dt>
      <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
        {value || 'Not recorded'}
      </dd>
    </div>
  )
}

export function AssetDetailDialog({
  asset,
  open,
  onOpenChange,
}: {
  asset: AssetDto | null
  open: boolean
  onOpenChange: (open: boolean) => void
}) {
  if (!asset) return null
  const assetType = typeLabels[asset.asset_type] ?? asset.asset_type

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={asset.name}
      description={assetType + ' · Asset record ' + asset.id}
      size="lg"
      footer={
        <div className="flex justify-end">
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Close
          </Button>
        </div>
      }
    >
      <div className="space-y-4">
        <Card className="from-primary-subtle/70 to-surface flex min-w-0 items-center gap-4 bg-gradient-to-br p-4">
          <span className="bg-primary-subtle text-primary rounded-control flex size-12 shrink-0 items-center justify-center">
            <Package2 className="size-6" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <p className="text-overline text-text-secondary">Company asset</p>
            <p className="text-h3 text-text-primary mt-1 truncate font-semibold">{asset.name}</p>
            <p className="text-caption text-text-secondary mt-1">{assetType}</p>
          </div>
          <StatusChip label={statusLabel(asset.status)} tone={statusTone(asset.status)} />
        </Card>

        <div className="tablet:grid-cols-2 grid gap-3">
          <Card className="p-4">
            <h3 className="text-label text-text-primary mb-4 font-semibold">Asset information</h3>
            <dl className="grid grid-cols-1 gap-4">
              <DetailValue label="Serial number" value={asset.serial_number ?? ''} />
              <DetailValue label="IMEI" value={asset.imei ?? ''} />
              <DetailValue label="Manufacturer" value={asset.manufacturer ?? ''} />
            </dl>
          </Card>
          <Card className="p-4">
            <h3 className="text-label text-text-primary mb-4 font-semibold">
              Location and assignment
            </h3>
            <dl className="grid grid-cols-1 gap-4">
              <DetailValue label="Branch" value={asset.branch} />
              <DetailValue
                label="Assigned employee"
                value={
                  asset.assigned_to_id == null ? 'Unassigned' : 'Employee ' + asset.assigned_to_id
                }
              />
              <DetailValue
                label="Department"
                value={
                  asset.department_id == null ? 'Not assigned' : 'Department ' + asset.department_id
                }
              />
            </dl>
          </Card>
          <Card className="tablet:col-span-2 p-4">
            <h3 className="text-label text-text-primary mb-4 font-semibold">
              Purchase and warranty
            </h3>
            <dl className="tablet:grid-cols-2 grid grid-cols-1 gap-4">
              <DetailValue label="Purchase date" value={formatDate(asset.purchase_date)} />
              <DetailValue label="Asset value" value={formatValue(asset.value)} />
              <DetailValue label="Vendor" value={asset.vendor ?? ''} />
              <DetailValue label="Invoice number" value={asset.invoice_number ?? ''} />
              <DetailValue label="Warranty expiry" value={formatDate(asset.warranty_expiry_date)} />
            </dl>
          </Card>
          {asset.documents?.length ? (
            <Card className="tablet:col-span-2 p-4">
              <h3 className="text-label text-text-primary mb-3 font-semibold">
                Documents and images
              </h3>
              <ul className="space-y-2">
                {asset.documents.map((document, index) => (
                  <li
                    key={(document.url ?? document.name) + '-' + index}
                    className="border-border-subtle rounded-control flex min-w-0 items-center gap-3 border px-3 py-2.5"
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
                    ) : (
                      <span className="text-caption text-text-muted">No link</span>
                    )}
                  </li>
                ))}
              </ul>
            </Card>
          ) : null}
          <Card className="tablet:col-span-2 p-4">
            <h3 className="text-label text-text-primary mb-2 flex items-center gap-2 font-semibold">
              <FileText className="size-4" aria-hidden="true" /> Notes
            </h3>
            <p className="text-body-sm text-text-secondary whitespace-pre-wrap">
              {asset.notes?.trim() || 'No internal notes have been added.'}
            </p>
          </Card>
        </div>
      </div>
    </Dialog>
  )
}
