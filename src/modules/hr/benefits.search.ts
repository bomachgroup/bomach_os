import { z } from 'zod'

const schema = z.object({
  search: z.string().max(200).catch(''),
  status: z.enum(['all', 'pending', 'approved', 'cancelled', 'paid']).catch('all'),
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

export type BenefitsSearch = z.infer<typeof schema>

export function validateBenefitsSearch(search: Record<string, unknown>): BenefitsSearch {
  return schema.parse(search)
}
