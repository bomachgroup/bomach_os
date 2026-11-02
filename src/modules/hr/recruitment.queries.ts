import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { ApplicantListParams, JobPostingListParams } from './recruitment.api'
import { recruitmentApi } from './recruitment.api'

export const recruitmentQueryKeys = {
  all: ['hr', 'recruitment'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...recruitmentQueryKeys.all, userId, employeeId] as const,
  postings: (userId: number, employeeId: string) =>
    [...recruitmentQueryKeys.scoped(userId, employeeId), 'postings'] as const,
  postingList: (userId: number, employeeId: string, params: JobPostingListParams) =>
    [...recruitmentQueryKeys.postings(userId, employeeId), 'list', params] as const,
  posting: (userId: number, employeeId: string, id: number) =>
    [...recruitmentQueryKeys.postings(userId, employeeId), 'detail', id] as const,
  postingSummary: (userId: number, employeeId: string) =>
    [...recruitmentQueryKeys.postings(userId, employeeId), 'summary'] as const,
  applicants: (userId: number, employeeId: string) =>
    [...recruitmentQueryKeys.scoped(userId, employeeId), 'applicants'] as const,
  applicantList: (userId: number, employeeId: string, params: ApplicantListParams) =>
    [...recruitmentQueryKeys.applicants(userId, employeeId), 'list', params] as const,
  applicant: (userId: number, employeeId: string, id: number) =>
    [...recruitmentQueryKeys.applicants(userId, employeeId), 'detail', id] as const,
}

export const jobPostingListQueryOptions = (
  userId: number,
  employeeId: string,
  params: JobPostingListParams,
) =>
  queryOptions({
    queryKey: recruitmentQueryKeys.postingList(userId, employeeId, params),
    queryFn: ({ signal }) => recruitmentApi.jobPostings(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const jobPostingQueryOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: recruitmentQueryKeys.posting(userId, employeeId, id),
    queryFn: ({ signal }) => recruitmentApi.jobPosting(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const jobPostingSummaryQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: recruitmentQueryKeys.postingSummary(userId, employeeId),
    queryFn: () => recruitmentApi.jobPostingSummary(),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const applicantListQueryOptions = (
  userId: number,
  employeeId: string,
  params: ApplicantListParams,
) =>
  queryOptions({
    queryKey: recruitmentQueryKeys.applicantList(userId, employeeId, params),
    queryFn: ({ signal }) => recruitmentApi.applicants(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const applicantQueryOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: recruitmentQueryKeys.applicant(userId, employeeId, id),
    queryFn: ({ signal }) => recruitmentApi.applicant(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
