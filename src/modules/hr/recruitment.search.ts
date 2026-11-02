import { z } from 'zod'

const idFilter = z.union([z.literal('all'), z.string().regex(/^[1-9]\d{0,15}$/)])

const schema = z.object({
  tab: z.enum(['jobs', 'pipeline']).catch('jobs'),
  search: z.string().max(200).catch(''),
  status: z.enum(['all', 'draft', 'pending', 'active', 'closed', 'cancelled']).catch('all'),
  jobType: z
    .enum(['all', 'full_time', 'part_time', 'contract', 'internship', 'temporary'])
    .catch('all'),
  branchId: idFilter.catch('all'),
  departmentId: idFilter.catch('all'),
  candidateStatus: z
    .enum(['all', 'applied', 'shortlisted', 'interviewed', 'offered', 'hired', 'rejected'])
    .catch('all'),
  jobPostingId: idFilter.catch('all'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  pageSize: z.coerce
    .number()
    .pipe(z.union([z.literal(10), z.literal(20), z.literal(50)]))
    .catch(10),
})

export type RecruitmentSearch = z.infer<typeof schema>

export function hasRecruitmentFilters(search: RecruitmentSearch): boolean {
  const sharedFilters =
    search.search.trim() !== '' || search.branchId !== 'all' || search.departmentId !== 'all'

  return search.tab === 'jobs'
    ? sharedFilters || search.status !== 'all' || search.jobType !== 'all'
    : sharedFilters || search.candidateStatus !== 'all' || search.jobPostingId !== 'all'
}

export function validateRecruitmentSearch(search: Record<string, unknown>): RecruitmentSearch {
  return schema.parse(search)
}
