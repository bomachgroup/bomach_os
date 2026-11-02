import { z } from 'zod'

const departmentSearchSchema = z.object({
  tab: z.enum(['departments', 'units']).catch('departments'),
  search: z.string().catch(''),
  departmentId: z
    .string()
    .catch('all')
    .transform((value) =>
      value === 'all' || (/^[1-9]\d*$/.test(value) && Number.isSafeInteger(Number(value)))
        ? value
        : 'all',
    ),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type DepartmentSearch = z.infer<typeof departmentSearchSchema>

export function validateDepartmentSearch(search: Record<string, unknown>): DepartmentSearch {
  return departmentSearchSchema.parse(search)
}

const chartSearchSchema = z.object({ scope: z.string().catch('company') })

export type OrgChartSearch = z.infer<typeof chartSearchSchema>

export function validateOrgChartSearch(search: Record<string, unknown>): OrgChartSearch {
  return chartSearchSchema.parse(search)
}
