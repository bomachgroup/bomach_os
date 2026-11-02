import { describe, expect, it } from 'vitest'

import { hasRecruitmentFilters, validateRecruitmentSearch } from './recruitment.search'

describe('validateRecruitmentSearch', () => {
  it('keeps candidate/job filters shareable and validates page size', () => {
    expect(
      validateRecruitmentSearch({
        tab: 'pipeline',
        search: 'Amina',
        candidateStatus: 'interviewed',
        jobPostingId: '17',
        page: '2',
        pageSize: '20',
      }),
    ).toMatchObject({
      tab: 'pipeline',
      search: 'Amina',
      candidateStatus: 'interviewed',
      jobPostingId: '17',
      page: 2,
      pageSize: 20,
    })
  })

  it('falls back for invalid scopes and bounds free-text input', () => {
    expect(
      validateRecruitmentSearch({
        branchId: '-4',
        status: 'invalid',
        search: 'x'.repeat(201),
        page: '0',
      }),
    ).toMatchObject({
      branchId: 'all',
      status: 'all',
      search: '',
      page: 1,
      tab: 'jobs',
    })
  })
})

describe('hasRecruitmentFilters', () => {
  const defaults = validateRecruitmentSearch({})

  it('recognizes job search, status, type, branch, and department filters', () => {
    expect(hasRecruitmentFilters(defaults)).toBe(false)
    expect(hasRecruitmentFilters({ ...defaults, search: '  accountant  ' })).toBe(true)
    expect(hasRecruitmentFilters({ ...defaults, status: 'active' })).toBe(true)
    expect(hasRecruitmentFilters({ ...defaults, jobType: 'contract' })).toBe(true)
    expect(hasRecruitmentFilters({ ...defaults, branchId: '3' })).toBe(true)
    expect(hasRecruitmentFilters({ ...defaults, departmentId: '2' })).toBe(true)
  })

  it('recognizes candidate stage, posting, and shared filters', () => {
    const pipeline = validateRecruitmentSearch({ tab: 'pipeline' })

    expect(hasRecruitmentFilters(pipeline)).toBe(false)
    expect(hasRecruitmentFilters({ ...pipeline, candidateStatus: 'shortlisted' })).toBe(true)
    expect(hasRecruitmentFilters({ ...pipeline, jobPostingId: '17' })).toBe(true)
    expect(hasRecruitmentFilters({ ...pipeline, search: 'Amina' })).toBe(true)
  })
})
