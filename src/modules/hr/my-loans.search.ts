import { z } from 'zod'

const schema = z.object({
  status: z.enum(['all', 'pending', 'approved', 'rejected']).catch('all'),
  request_id: z.coerce.number().int().positive().optional().catch(undefined),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  pageSize: z
    .number()
    .int()
    .or(
      z
        .string()
        .regex(/^(10|20|50)$/)
        .transform(Number),
    )
    .pipe(z.union([z.literal(10), z.literal(20), z.literal(50)]))
    .catch(10),
})

export type MyLoansSearch = z.infer<typeof schema>

export function validateMyLoansSearch(search: Record<string, unknown>): MyLoansSearch {
  return schema.parse(search)
}
