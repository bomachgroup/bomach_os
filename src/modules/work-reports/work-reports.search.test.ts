import { describe, expect, it } from 'vitest'

import { hasNonCanonicalWorkReportsSearch, validateWorkReportsSearch } from './work-reports.search'

describe('validateWorkReportsSearch', () => {
  it('defaults to the all reports filter and normalizes invalid search values', () => {
    expect(validateWorkReportsSearch({ type: 'unknown', status: 'wrong', page: '-1' })).toEqual({
      type: 'all',
      status: 'all',
      page: 1,
    })
  })

  it('maps existing daily and site tab URLs into unified type filters', () => {
    expect(validateWorkReportsSearch({ tab: 'daily', status: 'rejected', page: '3' })).toEqual({
      type: 'daily',
      status: 'rejected',
      page: 3,
    })
    expect(
      validateWorkReportsSearch({
        tab: 'site',
        status: 'approved',
        siteStatus: 'rejected',
        engineeringPage: 2,
        surveyPage: 4,
      }),
    ).toEqual({ type: 'site', status: 'rejected', page: 1 })
  })

  it('preserves explicit unified filters and strips retired tab state', () => {
    expect(
      validateWorkReportsSearch({
        type: 'engineering',
        status: 'submitted',
        page: '2',
        tab: 'site',
      }),
    ).toEqual({ type: 'engineering', status: 'submitted', page: 2 })
  })

  it('canonicalizes retired and invalid URL parameters without changing clean search state', () => {
    expect(
      hasNonCanonicalWorkReportsSearch(
        '?tab=site&status=all&siteStatus=rejected&page=1&engineeringPage=2',
      ),
    ).toBe(true)
    expect(hasNonCanonicalWorkReportsSearch('?type=all&status=rejected&page=3')).toBe(false)
    expect(hasNonCanonicalWorkReportsSearch('?type=wrong&status=all&page=1')).toBe(true)
  })
})
