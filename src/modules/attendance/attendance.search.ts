import { z } from 'zod'

const attendanceSearchSchema = z
  .object({
    dateFrom: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/)
      .catch(''),
    dateTo: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/)
      .catch(''),
    page: z.coerce.number().int().min(1).max(10_000).catch(1),
  })
  .transform((value) =>
    value.dateFrom && value.dateTo && value.dateFrom > value.dateTo
      ? { ...value, dateFrom: '', dateTo: '', page: 1 }
      : value,
  )

export type AttendanceSearch = z.infer<typeof attendanceSearchSchema>
export type AttendanceSetupSearch = AttendanceSearch & { sourceLocationId?: number }

export function validateAttendanceSearch(search: Record<string, unknown>): AttendanceSearch {
  return attendanceSearchSchema.parse(search)
}

export function validateAttendanceSetupSearch(
  search: Record<string, unknown>,
): AttendanceSetupSearch {
  const base = validateAttendanceSearch(search)
  const sourceLocationId = Number(search.sourceLocationId)
  return Number.isSafeInteger(sourceLocationId) && sourceLocationId > 0
    ? { ...base, sourceLocationId }
    : base
}
