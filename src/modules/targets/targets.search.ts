import { z } from 'zod'

const targetSearchSchema = z.object({
  scope: z.enum(['active', 'all']).catch('active'),
  period: z
    .enum(['all', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom'])
    .catch('all'),
  status: z.enum(['all', 'submitted', 'approved', 'rejected']).catch('all'),
  targetsPage: z.coerce.number().int().min(1).max(10_000).catch(1),
  reportsPage: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type MyTargetsSearch = z.infer<typeof targetSearchSchema>

export function validateMyTargetsSearch(search: Record<string, unknown>): MyTargetsSearch {
  return targetSearchSchema.parse(search)
}
