import { describe, expect, it } from 'vitest'

import { validateBranchDirectorySearch } from './branches.search'

describe('validateBranchDirectorySearch', () => {
  it('retains valid URL filters and pagination', () => {
    expect(
      validateBranchDirectorySearch({
        search: 'regional manager',
        operationalStatus: 'under_maintenance',
        branchRole: 'state_headquarters',
        recordState: 'inactive',
        page: '3',
      }),
    ).toEqual({
      search: 'regional manager',
      operationalStatus: 'under_maintenance',
      branchRole: 'state_headquarters',
      recordState: 'inactive',
      page: 3,
    })
  })

  it('recovers from malformed search state with safe defaults', () => {
    expect(
      validateBranchDirectorySearch({
        search: 4,
        operationalStatus: null,
        branchRole: false,
        recordState: 'archived',
        page: 0,
      }),
    ).toEqual({
      search: '',
      operationalStatus: 'all',
      branchRole: 'all',
      recordState: 'all',
      page: 1,
    })
  })
})
