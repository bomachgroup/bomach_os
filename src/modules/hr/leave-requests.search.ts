import { z } from 'zod'

export const DEFAULT_HR_LEAVE_REQUEST_STATUS = 'pending' as const

const schema = z.object({
  search: z.string().max(200).catch(''),
  status: z
    .enum(['all', 'pending', 'history', 'approved', 'rejected', 'cancelled'])
    .catch(DEFAULT_HR_LEAVE_REQUEST_STATUS),
  kind: z.enum(['all', 'leave', 'absence', 'running_late', 'attendance_exception']).catch('all'),
  request_id: z.coerce.number().int().positive().optional().catch(undefined),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  pageSize: z.coerce
    .number()
    .pipe(z.union([z.literal(10), z.literal(20), z.literal(50)]))
    .catch(10),
})

export type HRLeaveRequestsSearch = z.infer<typeof schema>

export function validateHRLeaveRequestsSearch(
  search: Record<string, unknown>,
): HRLeaveRequestsSearch {
  return schema.parse(search)
}
