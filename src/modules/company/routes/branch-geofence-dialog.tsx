import { useState, type FormEvent } from 'react'

import { validateGeofenceDraft } from '@/modules/company/branch-location'
import type { BranchDto, BranchUpdateInput } from '@/modules/company/branches.api'
import { presentError } from '@/shared/errors'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { FormSection } from '@/shared/ui/form-section'
import { BranchGeofenceFields } from '../components/branch-geofence-fields'

export function BranchGeofenceDialog({
  open,
  branch,
  onOpenChange,
  onSave,
}: {
  open: boolean
  branch: BranchDto
  onOpenChange: (open: boolean) => void
  onSave: (input: BranchUpdateInput) => Promise<void>
}) {
  const [saving, setSaving] = useState(false)

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={`Update geofence · ${branch.branch_name}`}
      description="Capture or enter the attendance point and radius for this branch."
      size="md"
      bodyClassName="space-y-4"
      footer={
        <>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button type="submit" form="branch-geofence-form" isLoading={saving}>
            Save geofence
          </Button>
        </>
      }
    >
      {open ? (
        <BranchGeofenceForm
          branch={branch}
          onOpenChange={onOpenChange}
          onSave={onSave}
          onSavingChange={setSaving}
        />
      ) : null}
    </Dialog>
  )
}

function BranchGeofenceForm({
  branch,
  onOpenChange,
  onSave,
  onSavingChange,
}: {
  branch: BranchDto
  onOpenChange: (open: boolean) => void
  onSave: (input: BranchUpdateInput) => Promise<void>
  onSavingChange: (saving: boolean) => void
}) {
  const [latitude, setLatitude] = useState(() =>
    branch.latitude == null ? '' : String(branch.latitude),
  )
  const [longitude, setLongitude] = useState(() =>
    branch.longitude == null ? '' : String(branch.longitude),
  )
  const [radius, setRadius] = useState(() => String(branch.attendance_radius_meters || 100))
  const [formError, setFormError] = useState<string | null>(null)

  function updateLatitude(value: string) {
    setLatitude(value)
    if (formError) setFormError(validateGeofenceDraft(value, longitude, radius))
  }

  function updateLongitude(value: string) {
    setLongitude(value)
    if (formError) setFormError(validateGeofenceDraft(latitude, value, radius))
  }

  function clearLocationPoint() {
    setLatitude('')
    setLongitude('')
    if (formError) setFormError(validateGeofenceDraft('', '', radius))
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)
    const validationError = validateGeofenceDraft(latitude, longitude, radius)
    if (validationError) {
      setFormError(validationError)
      return
    }

    onSavingChange(true)
    try {
      await onSave({
        latitude: latitude.trim() === '' ? null : Number(latitude),
        longitude: longitude.trim() === '' ? null : Number(longitude),
        attendance_radius_meters: Number(radius),
      })
      onOpenChange(false)
    } catch (error) {
      setFormError(presentError(error, 'form-submit').message)
    } finally {
      onSavingChange(false)
    }
  }

  return (
    <form
      id="branch-geofence-form"
      onSubmit={(event) => void submit(event)}
      noValidate
      className="space-y-4"
    >
      {formError ? (
        <Alert tone="danger" title="Geofence not saved" role="alert">
          {formError}
        </Alert>
      ) : null}

      <FormSection className="space-y-4">
        <div>
          <h3 className="text-label font-semibold">Attendance geofence</h3>
          <p className="text-caption text-text-secondary mt-1">
            Capture a GPS point or enter coordinates and choose the attendance radius.
          </p>
        </div>
        <BranchGeofenceFields
          idPrefix="geofence"
          active
          latitude={latitude}
          longitude={longitude}
          radius={radius}
          onClear={clearLocationPoint}
          onLatitudeChange={updateLatitude}
          onLongitudeChange={updateLongitude}
          onRadiusChange={(value) => {
            setRadius(value)
            if (formError) setFormError(validateGeofenceDraft(latitude, longitude, value))
          }}
        />
      </FormSection>
    </form>
  )
}
