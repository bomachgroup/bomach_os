import { describe, expect, it } from 'vitest'

import {
  validateContractWorkflowSearch,
  validateMeetingWorkflowSearch,
  validateSurveyWorkflowSearch,
} from './operations-workflows.search'

describe('Operations workflow route search', () => {
  it('defaults Survey Reports to submitted and sanitizes pagination', () => {
    expect(validateSurveyWorkflowSearch({ page: '-2', employeeId: '0' })).toEqual({
      search: '',
      status: 'submitted',
      employeeId: null,
      projectId: null,
      worksiteId: null,
      dateFrom: '',
      dateTo: '',
      page: 1,
    })
  })

  it('preserves valid Contract filters and falls back from invalid pages', () => {
    expect(
      validateContractWorkflowSearch({
        search: 'renewal',
        status: 'active',
        contractType: 'fixed_price',
        page: '2',
      }),
    ).toEqual({
      search: 'renewal',
      status: 'active',
      contractType: 'fixed_price',
      page: 2,
    })
    expect(validateContractWorkflowSearch({ page: 'not-a-page' }).page).toBe(1)
  })

  it('parses boolean and optional Meeting filters from URL strings', () => {
    expect(
      validateMeetingWorkflowSearch({
        status: 'scheduled',
        locationType: 'virtual',
        dateFrom: '2026-11-01',
        dateTo: '2026-11-30',
        projectId: '17',
        myMeetings: 'true',
        page: 3,
      }),
    ).toEqual({
      search: '',
      status: 'scheduled',
      locationType: 'virtual',
      dateFrom: '2026-11-01',
      dateTo: '2026-11-30',
      projectId: 17,
      myMeetings: true,
      page: 3,
    })
  })
})
