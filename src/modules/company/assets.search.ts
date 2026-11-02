import { z } from 'zod'

const assetSearchSchema = z.object({
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type AssetsSearch = z.infer<typeof assetSearchSchema>

export function validateAssetsSearch(search: Record<string, unknown>): AssetsSearch {
  return assetSearchSchema.parse(search)
}
