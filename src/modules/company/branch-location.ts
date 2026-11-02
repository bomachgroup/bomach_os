export function validateGeofenceDraft(
  latitude: string,
  longitude: string,
  radius: string,
): string | null {
  const hasLatitude = latitude.trim() !== ''
  const hasLongitude = longitude.trim() !== ''
  const parsedLatitude = hasLatitude ? Number(latitude) : null
  const parsedLongitude = hasLongitude ? Number(longitude) : null
  const parsedRadius = Number(radius)

  if (hasLatitude !== hasLongitude) {
    return 'Enter both coordinates, or clear both to remove the location point.'
  }
  if (
    (parsedLatitude !== null &&
      (!Number.isFinite(parsedLatitude) || Math.abs(parsedLatitude) > 90)) ||
    (parsedLongitude !== null &&
      (!Number.isFinite(parsedLongitude) || Math.abs(parsedLongitude) > 180))
  ) {
    return 'Enter a valid latitude from −90 to 90 and longitude from −180 to 180.'
  }
  if (!Number.isInteger(parsedRadius) || parsedRadius < 1 || parsedRadius > 5000) {
    return 'Choose an attendance radius from 1 to 5000 metres.'
  }

  return null
}
