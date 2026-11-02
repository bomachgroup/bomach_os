import { z } from 'zod'

const schema = z.object({
  search: z.string().max(200).catch(''),
  rating: z.enum(['all', '1', '2', '3', '4', '5']).catch('all'),
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

export type PerformanceReviewsSearch = z.infer<typeof schema>

export function validatePerformanceReviewsSearch(
  search: Record<string, unknown>,
): PerformanceReviewsSearch {
  return schema.parse(search)
}
