import { BranchLocationCapture } from './branch-location-capture'
import { FormControl, TextInput } from '@/shared/ui/form-control'

export function BranchGeofenceFields({
  idPrefix,
  active = true,
  latitude,
  longitude,
  radius,
  latitudeError,
  longitudeError,
  radiusError,
  onClear,
  onLatitudeChange,
  onLongitudeChange,
  onRadiusChange,
}: {
  idPrefix: string
  active?: boolean
  latitude: string
  longitude: string
  radius: string
  latitudeError?: string
  longitudeError?: string
  radiusError?: string
  onClear?: () => void
  onLatitudeChange: (value: string) => void
  onLongitudeChange: (value: string) => void
  onRadiusChange: (value: string) => void
}) {
  return (
    <div className="space-y-4">
      <BranchLocationCapture
        idPrefix={idPrefix}
        active={active}
        latitude={latitude}
        longitude={longitude}
        latitudeError={latitudeError}
        longitudeError={longitudeError}
        onClear={onClear}
        onLatitudeChange={onLatitudeChange}
        onLongitudeChange={onLongitudeChange}
      />
      <FormControl
        id={`${idPrefix}-radius`}
        label="Attendance radius (metres)"
        required
        error={radiusError}
        description="Between 1 and 5000 metres; default is 100."
      >
        <TextInput
          type="number"
          min={1}
          max={5000}
          step={1}
          value={radius}
          onChange={(event) => onRadiusChange(event.currentTarget.value)}
        />
      </FormControl>
    </div>
  )
}
