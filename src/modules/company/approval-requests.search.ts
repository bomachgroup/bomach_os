import { z } from 'zod'

const approvalRequestsSearchSchema = z.object({
  status: z.enum(['all', 'pending', 'approved', 'rejected', 'cancelled']).catch('all'),
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type ApprovalRequestsSearch = z.infer<typeof approvalRequestsSearchSchema>

export function validateApprovalRequestsSearch(
  search: Record<string, unknown>,
): ApprovalRequestsSearch {
  return approvalRequestsSearchSchema.parse(search)
}
