import { z } from 'zod'

export const DEFAULT_HR_WORK_REPORT_STATUS = 'submitted' as const

const hrWorkReportsSearchSchema = z.object({
  search: z.string().catch(''),
  status: z
    .enum(['all', 'draft', 'submitted', 'approved', 'rejected'])
    .catch(DEFAULT_HR_WORK_REPORT_STATUS),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  reportId: z.number().int().positive().optional(),
})

export type HRWorkReportsSearch = z.infer<typeof hrWorkReportsSearchSchema>

export function validateHRWorkReportsSearch(search: Record<string, unknown>): HRWorkReportsSearch {
  const reportId = Number(search.reportId)
  return hrWorkReportsSearchSchema.parse({
    ...search,
    reportId: Number.isSafeInteger(reportId) && reportId > 0 ? reportId : undefined,
  })
}
