import { z } from 'zod'

const schema = z.object({
  tab: z.enum(['announcements', 'events']).catch('announcements'),
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type BroadcastSearch = z.infer<typeof schema>

export function validateBroadcastSearch(search: Record<string, unknown>): BroadcastSearch {
  return schema.parse(search)
}
