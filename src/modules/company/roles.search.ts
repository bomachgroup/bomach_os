import { z } from 'zod'

const schema = z.object({
  search: z.string().max(200).catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type RolesSearch = z.infer<typeof schema>
export const validateRolesSearch = (search: Record<string, unknown>) => schema.parse(search)
