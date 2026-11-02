import { z } from 'zod'

const branchSearchSchema = z.object({
  search: z.string().catch(''),
  operationalStatus: z.string().catch('all'),
  branchRole: z.string().catch('all'),
  recordState: z.enum(['all', 'active', 'inactive']).catch('all'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type BranchDirectorySearch = z.infer<typeof branchSearchSchema>

export function validateBranchDirectorySearch(
  search: Record<string, unknown>,
): BranchDirectorySearch {
  return branchSearchSchema.parse(search)
}
