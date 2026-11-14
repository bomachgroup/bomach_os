import { describe, expect, it } from 'vitest'

import {
  validateEngineeringReportsSearch,
  validateOperationsTasksSearch,
  validateWorksitesSearch,
} from './operations-registers.search'

describe('Operations register search validation', () => {
  it('opens Tasks on active work and preserves explicit history filters', () => {
    expect(validateOperationsTasksSearch({})).toMatchObject({
      status: 'active',
      page: 1,
      priority: '',
      projectId: null,
      worksiteId: null,
    })
    expect(
      validateOperationsTasksSearch({
        status: 'completed',
        priority: 'high',
        projectId: '12',
        worksiteId: '4',
        page: '3',
      }),
    ).toMatchObject({
      status: 'completed',
      priority: 'high',
      projectId: 12,
      worksiteId: 4,
      page: 3,
    })
  })

  it('opens Engineering reports on submitted items and supports all-history scope', () => {
    expect(validateEngineeringReportsSearch({})).toMatchObject({
      status: 'submitted',
      employeeId: null,
      projectId: null,
      worksiteId: null,
      page: 1,
    })
    expect(
      validateEngineeringReportsSearch({
        status: 'all',
        employeeId: '9',
        projectId: '12',
        worksiteId: '4',
        dateFrom: '2026-10-01',
        dateTo: '2026-10-31',
        page: '2',
      }),
    ).toEqual({
      status: 'all',
      employeeId: 9,
      projectId: 12,
      worksiteId: 4,
      dateFrom: '2026-10-01',
      dateTo: '2026-10-31',
      page: 2,
    })
  })

  it('normalizes invalid IDs, page numbers, statuses, and overlong search text', () => {
    expect(
      validateWorksitesSearch({
        search: `  ${'x'.repeat(150)} `,
        status: 'unknown',
        projectId: '-1',
        page: '0',
      }),
    ).toEqual({
      search: 'x'.repeat(120),
      status: 'all',
      projectId: null,
      page: 1,
    })
    expect(
      validateEngineeringReportsSearch({ status: 'drafts', employeeId: 'nope' }),
    ).toMatchObject({
      status: 'submitted',
      employeeId: null,
    })
  })
})
