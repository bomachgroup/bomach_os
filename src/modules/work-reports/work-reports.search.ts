import { z } from 'zod'

const reportSearchSchema = z.object({
  status: z.enum(['all', 'draft', 'submitted', 'approved', 'rejected']).catch('all'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type WorkReportsSearch = z.infer<typeof reportSearchSchema>

export function validateWorkReportsSearch(search: Record<string, unknown>): WorkReportsSearch {
  return reportSearchSchema.parse(search)
}
