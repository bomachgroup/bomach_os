import { z } from 'zod'

const kpiManagementSearchSchema = z.object({
  search: z.string().max(200).catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type KpiManagementSearch = z.infer<typeof kpiManagementSearchSchema>

export function validateKpiManagementSearch(search: Record<string, unknown>) {
  return kpiManagementSearchSchema.parse(search)
}
