import { z } from 'zod'

const schema = z.object({
  tab: z.enum(['workflows', 'requests']).catch('workflows'),
  status: z.enum(['all', 'pending', 'approved', 'rejected', 'cancelled']).catch('all'),
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type ApprovalWorkflowsSearch = z.infer<typeof schema>

export function validateApprovalWorkflowsSearch(
  search: Record<string, unknown>,
): ApprovalWorkflowsSearch {
  return schema.parse(search)
}
