import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { performanceReviewsApi, type PerformanceReviewInput } from './performance-reviews.api'

const dto = {
  id: 8,
  employee_id: 23,
  employee_name: 'Amaka Okafor',
  reviewer_id: 19,
  reviewer_name: 'HR Reviewer',
  review_date: '2026-10-27',
  review_period: 'Q4 2026',
  overall_rating: 4,
  rating_display: '4 / 5',
  strengths: 'Clear communication',
  areas_for_improvement: 'Delegation',
  feedback: null,
  employee_comment: 'Thank you',
  created_at: '2026-10-27T10:00:00Z',
  updated_at: '2026-10-27T10:00:00Z',
}

const input: PerformanceReviewInput = {
  employee_id: 23,
  reviewer_id: 19,
  review_date: '2026-10-27',
  review_period: 'Q4 2026',
  overall_rating: 4,
  strengths: 'Clear communication',
  areas_for_improvement: 'Delegation',
  feedback: null,
  employee_comment: null,
}

afterEach(() => vi.restoreAllMocks())

describe('performanceReviewsApi', () => {
  it('sends supported search, rating, and pagination filters and maps named records', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 1, items: [dto] })

    const result = await performanceReviewsApi.list({
      search: ' Amina Q4 ',
      rating: 4,
      limit: 20,
      offset: 40,
    })

    expect(get).toHaveBeenCalledWith(
      '/performance-reviews/?limit=20&offset=40&search=Amina+Q4&min_rating=4&max_rating=4',
      { signal: undefined },
    )
    expect(result.items[0]).toMatchObject({
      id: 8,
      employeeId: 23,
      employeeName: 'Amaka Okafor',
      reviewerName: 'HR Reviewer',
      overallRating: 4,
      feedback: null,
    })
  })

  it('supports create, update, and delete using the existing API contract', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue(dto)
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue(dto)
    const del = vi.spyOn(apiClient, 'delete').mockResolvedValue(undefined)

    await performanceReviewsApi.create(input)
    await performanceReviewsApi.update(8, {
      review_date: input.review_date,
      review_period: input.review_period,
      overall_rating: input.overall_rating,
      strengths: input.strengths,
      areas_for_improvement: input.areas_for_improvement,
      feedback: input.feedback,
      employee_comment: input.employee_comment,
    })
    await performanceReviewsApi.remove(8)

    expect(post).toHaveBeenCalledWith('/performance-reviews/', input)
    expect(put).toHaveBeenCalledWith('/performance-reviews/8', {
      review_date: input.review_date,
      review_period: input.review_period,
      overall_rating: input.overall_rating,
      strengths: input.strengths,
      areas_for_improvement: input.areas_for_improvement,
      feedback: input.feedback,
      employee_comment: input.employee_comment,
    })
    expect(del).toHaveBeenCalledWith('/performance-reviews/8')
  })
})
