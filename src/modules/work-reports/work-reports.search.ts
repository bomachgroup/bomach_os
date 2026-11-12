import { z } from 'zod'

const workReportsSearchSchema = z.object({
  type: z.enum(['all', 'daily', 'site', 'engineering', 'survey']).catch('all'),
  status: z.enum(['all', 'draft', 'submitted', 'approved', 'rejected']).catch('all'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type WorkReportsSearch = z.infer<typeof workReportsSearchSchema>

const currentWorkReportsSearchKeys = new Set(['type', 'status', 'page'])

/** Normalize old tab links into the unified type/status filter state. */
export function validateWorkReportsSearch(search: Record<string, unknown>): WorkReportsSearch {
  const tab = search.tab
  const legacyType = tab === 'daily' ? 'daily' : tab === 'site' ? 'site' : 'all'
  const legacyStatus = tab === 'site' ? search.siteStatus : search.status
  return workReportsSearchSchema.parse({
    ...search,
    type: search.type ?? legacyType,
    status: search.type == null ? (legacyStatus ?? search.status) : search.status,
  })
}

/** Return true when a URL contains retired keys or values that need canonicalizing. */
export function hasNonCanonicalWorkReportsSearch(searchStr: string): boolean {
  const params = new URLSearchParams(searchStr)
  if (!params.toString()) return false
  if ([...params.keys()].some((key) => !currentWorkReportsSearchKeys.has(key))) return true

  const normalized = validateWorkReportsSearch(Object.fromEntries(params))
  return (
    (params.has('type') && params.get('type') !== normalized.type) ||
    (params.has('status') && params.get('status') !== normalized.status) ||
    (params.has('page') && params.get('page') !== String(normalized.page))
  )
}
