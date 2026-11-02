import { z } from 'zod'

const myLeavesSearchSchema = z.object({
  kind: z.enum(['all', 'leave', 'attendance_exception']).catch('all'),
  status: z.enum(['all', 'pending', 'approved', 'rejected', 'cancelled']).catch('all'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type MyLeavesSearch = z.infer<typeof myLeavesSearchSchema>

export function validateMyLeavesSearch(search: Record<string, unknown>): MyLeavesSearch {
  return myLeavesSearchSchema.parse(search)
}
