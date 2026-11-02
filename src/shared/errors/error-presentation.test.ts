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
})
