import { apiClient } from '@/shared/api/api-client'

export interface PerformanceReview {
  id: number
  employeeId: number
  employeeName: string
  reviewerId: number
  reviewerName: string
  reviewDate: string
  reviewPeriod: string
  overallRating: number
  strengths: string
  areasForImprovement: string
  feedback: string | null
  employeeComment: string | null
  createdAt: string
  updatedAt: string
}

interface PerformanceReviewDto {
  id: number
  employee_id: number
  employee_name: string
  reviewer_id: number
  reviewer_name: string
  review_date: string
  review_period: string
  overall_rating: number | string
  strengths: string
  areas_for_improvement: string
  feedback?: string | null
  employee_comment?: string | null
  created_at: string
  updated_at: string
}

interface PerformanceReviewApiPage {
  count: number
  items: PerformanceReviewDto[]
}

export interface PerformanceReviewListParams {
  search: string
  rating: 'all' | number
  limit: number
  offset: number
}

export interface PerformanceReviewInput {
  employee_id: number
  reviewer_id: number
  review_date: string
  review_period: string
  overall_rating: number
  strengths: string
  areas_for_improvement: string
  feedback: string | null
  employee_comment: string | null
}

function mapReview(dto: PerformanceReviewDto): PerformanceReview {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    employeeName: dto.employee_name?.trim() || `Employee #${dto.employee_id}`,
    reviewerId: dto.reviewer_id,
    reviewerName: dto.reviewer_name?.trim() || `Employee #${dto.reviewer_id}`,
    reviewDate: dto.review_date,
    reviewPeriod: dto.review_period,
    overallRating: Number(dto.overall_rating),
    strengths: dto.strengths ?? '',
    areasForImprovement: dto.areas_for_improvement ?? '',
    feedback: dto.feedback ?? null,
    employeeComment: dto.employee_comment ?? null,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

export const performanceReviewsApi = {
  list: async (params: PerformanceReviewListParams, signal?: AbortSignal) => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.search.trim()) query.set('search', params.search.trim())
    if (params.rating !== 'all') {
      query.set('min_rating', String(params.rating))
      query.set('max_rating', String(params.rating))
    }
    const page = await apiClient.get<PerformanceReviewApiPage>(`/performance-reviews/?${query}`, {
      signal,
    })
    return { count: page.count, items: page.items.map(mapReview) }
  },
  create: async (input: PerformanceReviewInput) =>
    mapReview(await apiClient.post<PerformanceReviewDto>('/performance-reviews/', input)),
  update: async (id: number, input: Omit<PerformanceReviewInput, 'employee_id' | 'reviewer_id'>) =>
    mapReview(await apiClient.put<PerformanceReviewDto>(`/performance-reviews/${id}`, input)),
  remove: (id: number) => apiClient.delete<void>(`/performance-reviews/${id}`),
}
