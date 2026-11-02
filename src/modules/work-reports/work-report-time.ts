/** Duration in decimal hours, rounded to one decimal place. Overnight shifts are supported. */
export function calculateWorkHours(start: string, end: string): number | null {
  if (!/^\d{2}:\d{2}$/.test(start) || !/^\d{2}:\d{2}$/.test(end) || start === end) return null
  const [startHour, startMinute] = start.split(':').map(Number)
  const [endHour, endMinute] = end.split(':').map(Number)
  if (startHour > 23 || endHour > 23 || startMinute > 59 || endMinute > 59) return null
  const startMinutes = startHour * 60 + startMinute
  let endMinutes = endHour * 60 + endMinute
  if (endMinutes < startMinutes) endMinutes += 24 * 60
  const minutes = endMinutes - startMinutes
  if (minutes < 3) return null
  return Math.round((minutes / 60) * 10) / 10
}

export function localDateInputValue(date = new Date()): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}
