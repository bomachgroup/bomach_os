import { describe, expect, it } from 'vitest'

import { ApiError } from '@/shared/api/api-error'
import { presentError } from './error-presentation'

describe('presentError', () => {
  it('hides database constraint details returned as client errors', () => {
    const error = new ApiError('NOT NULL constraint failed: user_boardresolution.attachment_url', {
      status: 400,
    })

    expect(presentError(error, 'form-submit').message).toBe('Review the information and try again.')
  })

  it('presents missing collection endpoints as retryable list failures', () => {
    const error = new ApiError('Not Found', { status: 404 })

    expect(presentError(error, 'collection-load')).toMatchObject({
      title: 'This list could not load',
      placement: 'page',
      retryable: true,
    })
  })

  it('presents missing section endpoints as retryable section failures', () => {
    const error = new ApiError('Not Found', { status: 404 })

    expect(presentError(error, 'section-load')).toMatchObject({
      title: 'This section could not load',
      placement: 'section',
      retryable: true,
    })
  })

  it('keeps missing records distinct from missing collections', () => {
    const error = new ApiError('Not Found', { status: 404 })

    expect(presentError(error, 'page-load')).toMatchObject({
      title: 'Record not found',
      retryable: false,
    })
  })
})
