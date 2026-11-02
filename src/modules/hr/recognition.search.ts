import { z } from 'zod'

const pageSchema = z.object({
  search: z.string().max(200).catch(''),
  year: z.union([z.literal('all'), z.string().regex(/^20\d{2}$/)]).catch('all'),
  month: z.union([z.literal('all'), z.string().regex(/^(?:[1-9]|1[0-2])$/)]).catch('all'),
  action: z.string().max(60).catch('all'),
  category: z.string().max(100).catch('all'),
  award_id: z.coerce.number().int().positive().optional().catch(undefined),
  case_id: z.coerce.number().int().positive().optional().catch(undefined),
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

export type RecognitionSearch = z.infer<typeof pageSchema>

export function validateRecognitionSearch(search: Record<string, unknown>): RecognitionSearch {
  return pageSchema.parse(search)
}

const leaderboardSchema = z.object({
  month: z.coerce
    .number()
    .int()
    .min(1)
    .max(12)
    .catch(new Date().getMonth() + 1),
  year: z.coerce.number().int().min(2000).max(2100).catch(new Date().getFullYear()),
})

export type LeaderboardSearch = z.infer<typeof leaderboardSchema>

export function validateLeaderboardSearch(search: Record<string, unknown>): LeaderboardSearch {
  return leaderboardSchema.parse(search)
}

export function matchesRecognitionText(
  values: Array<string | null | undefined>,
  search: string,
): boolean {
  const terms = search.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean)
  if (terms.length === 0) return true
  const content = values.filter(Boolean).join(' ').toLocaleLowerCase()
  return terms.every((term) => content.includes(term))
}
