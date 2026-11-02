import { apiClient } from '@/shared/api/api-client'

export type JobPostingStatus = 'draft' | 'pending' | 'active' | 'closed' | 'cancelled'
export type JobType = 'full_time' | 'part_time' | 'contract' | 'internship' | 'temporary'
export type ApplicantStatus =
  'applied' | 'shortlisted' | 'interviewed' | 'offered' | 'hired' | 'rejected'

export interface JobPosting {
  id: number
  title: string
  departmentId: number | null
  branchId: number
  jobType: JobType | string
  status: JobPostingStatus | string
  description: string
  requirements: string
  responsibilities: string
  salaryMin: string | null
  salaryMax: string | null
  vacancyCount: number
  applicantsCount: number
  deadline: string | null
  isActive: boolean
  createdAt: string
  updatedAt: string
}

export type JobPostingListItem = Pick<
  JobPosting,
  | 'id'
  | 'title'
  | 'departmentId'
  | 'branchId'
  | 'jobType'
  | 'status'
  | 'applicantsCount'
  | 'createdAt'
  | 'updatedAt'
>

export interface Applicant {
  id: number
  firstName: string
  lastName: string
  email: string
  phone: string
  jobPosting: JobPostingListItem
  status: ApplicantStatus | string
  resume: string | null
  coverLetter: string | null
  createdAt: string
  updatedAt: string
  address: string | null
  currentJobTitle: string | null
  yearsOfExperience: number | null
  highestEducation: string | null
  institutionName: string | null
  source: string | null
  expectedSalary: string | null
  notes: string | null
}

export interface JobPostingListParams {
  limit: number
  offset: number
  search: string
  status: string
  jobType: string
  branchId: string
  departmentId: string
}

export interface ApplicantListParams {
  limit: number
  offset: number
  search: string
  status: string
  jobPostingId: string
}

export interface JobPostingInput {
  job_title: string
  department_id: number | null
  branch_id: number
  job_type: JobType
  status: JobPostingStatus
  description: string
  requirements: string
  responsibilities: string
  salary_min: number | null
  salary_max: number | null
  deadline: string | null
  is_active: boolean
}

export interface ApplicantInput {
  first_name: string
  last_name: string
  email: string
  phone: string
  job_posting_id: number
  status: ApplicantStatus
  resume: string | null
  cover_letter: string | null
  notes: string | null
  address: string | null
  current_job_title: string | null
  years_of_experience: number | null
  highest_education: string | null
  institution_name: string | null
  source: string | null
  expected_salary: number | null
}

interface PageDto<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

interface JobPostingDto {
  id: number
  job_title: string
  department_id: number | null
  branch_id: number
  job_type: string
  status: string
  description?: string | null
  requirements?: string | null
  responsibilities?: string | null
  salary_min?: string | number | null
  salary_max?: string | number | null
  vacancy_count?: number
  applicants_count: number
  deadline?: string | null
  is_active?: boolean
  created_at: string
  updated_at: string
}

interface ApplicantDto {
  id: number
  first_name: string
  last_name: string
  email: string
  phone: string
  job_posting: JobPostingListDto
  status: string
  resume?: string | null
  cover_letter?: string | null
  created_at: string
  updated_at: string
  address?: string | null
  current_job_title?: string | null
  years_of_experience?: number | null
  highest_education?: string | null
  institution_name?: string | null
  source?: string | null
  expected_salary?: string | number | null
  notes?: string | null
}

interface JobPostingListDto {
  id: number
  job_title: string
  department_id: number | null
  branch_id: number
  job_type: string
  status: string
  applicants_count: number
  created_at: string
  updated_at: string
}

export interface JobPostingSummary {
  total: number
  active: number
  pending: number
  closed: number
  draft: number
}

export interface InterviewRecord {
  id: number
  applicantId: number
  interviewerId: number
  scheduledAt: string
  meetingLink: string | null
  feedback: string | null
  status: string
  createdAt: string
}

export interface InterviewInput {
  interviewer_id: number
  scheduled_at: string
  meeting_link: string | null
}

export interface OfferLetterRecord {
  id: number
  applicantId: number
  template: string
  annualSalary: string
  startDate: string
  status: string
  sentAt: string | null
  createdAt: string
}

export interface OfferLetterInput {
  template: string
  annual_salary: number
  start_date: string
  letter_content: string
}

interface InterviewDto {
  id: number
  applicant_id: number
  interviewer_id: number
  scheduled_at: string
  meeting_link?: string | null
  feedback?: string | null
  status: string
  created_at: string
}

interface OfferLetterDto {
  id: number
  applicant_id: number
  template: string
  annual_salary: string | number
  start_date: string
  status: string
  sent_at?: string | null
  created_at: string
}

function mapJobPosting(dto: JobPostingDto): JobPosting {
  return {
    id: dto.id,
    title: dto.job_title,
    departmentId: dto.department_id,
    branchId: dto.branch_id,
    jobType: dto.job_type,
    status: dto.status,
    description: dto.description ?? '',
    requirements: dto.requirements ?? '',
    responsibilities: dto.responsibilities ?? '',
    salaryMin: dto.salary_min == null ? null : String(dto.salary_min),
    salaryMax: dto.salary_max == null ? null : String(dto.salary_max),
    vacancyCount: dto.vacancy_count ?? 1,
    applicantsCount: dto.applicants_count,
    deadline: dto.deadline ?? null,
    isActive: dto.is_active ?? true,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function mapJobPostingListItem(dto: JobPostingListDto): JobPostingListItem {
  return {
    id: dto.id,
    title: dto.job_title,
    departmentId: dto.department_id,
    branchId: dto.branch_id,
    jobType: dto.job_type,
    status: dto.status,
    applicantsCount: dto.applicants_count,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function mapApplicant(dto: ApplicantDto): Applicant {
  return {
    id: dto.id,
    firstName: dto.first_name,
    lastName: dto.last_name,
    email: dto.email,
    phone: dto.phone,
    jobPosting: mapJobPostingListItem(dto.job_posting),
    status: dto.status,
    resume: dto.resume ?? null,
    coverLetter: dto.cover_letter ?? null,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
    address: dto.address ?? null,
    currentJobTitle: dto.current_job_title ?? null,
    yearsOfExperience: dto.years_of_experience ?? null,
    highestEducation: dto.highest_education ?? null,
    institutionName: dto.institution_name ?? null,
    source: dto.source ?? null,
    expectedSalary: dto.expected_salary == null ? null : String(dto.expected_salary),
    notes: dto.notes ?? null,
  }
}

function mapInterview(dto: InterviewDto): InterviewRecord {
  return {
    id: dto.id,
    applicantId: dto.applicant_id,
    interviewerId: dto.interviewer_id,
    scheduledAt: dto.scheduled_at,
    meetingLink: dto.meeting_link ?? null,
    feedback: dto.feedback ?? null,
    status: dto.status,
    createdAt: dto.created_at,
  }
}

function mapOffer(dto: OfferLetterDto): OfferLetterRecord {
  return {
    id: dto.id,
    applicantId: dto.applicant_id,
    template: dto.template,
    annualSalary: String(dto.annual_salary),
    startDate: dto.start_date,
    status: dto.status,
    sentAt: dto.sent_at ?? null,
    createdAt: dto.created_at,
  }
}

function jobPostingParams(params: JobPostingListParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.status !== 'all') search.set('status', params.status)
  if (params.jobType !== 'all') search.set('job_type', params.jobType)
  if (params.branchId !== 'all') search.set('branch_id', params.branchId)
  if (params.departmentId !== 'all') search.set('department_id', params.departmentId)
  return search
}

function applicantParams(params: ApplicantListParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.status !== 'all') search.set('status', params.status)
  if (params.jobPostingId !== 'all') search.set('job_posting_id', params.jobPostingId)
  return search
}

export const recruitmentApi = {
  jobPostings: async (params: JobPostingListParams, signal?: AbortSignal) => {
    const page = await apiClient.get<PageDto<JobPostingDto>>(
      `/job-postings/?${jobPostingParams(params)}`,
      { signal },
    )
    return { count: page.count, items: page.items.map(mapJobPosting) }
  },
  jobPosting: async (id: number, signal?: AbortSignal) =>
    mapJobPosting(await apiClient.get<JobPostingDto>(`/job-postings/${id}`, { signal })),
  jobPostingSummary: () => apiClient.get<JobPostingSummary>('/job-postings/stats/summary'),
  createJobPosting: async (input: JobPostingInput) =>
    mapJobPosting(await apiClient.post<JobPostingDto>('/job-postings/', input)),
  updateJobPosting: async (id: number, input: JobPostingInput) =>
    mapJobPosting(await apiClient.put<JobPostingDto>(`/job-postings/${id}`, input)),
  updateJobPostingStatus: async (id: number, status: JobPostingStatus) =>
    mapJobPosting(await apiClient.patch<JobPostingDto>(`/job-postings/${id}/status`, { status })),
  deleteJobPosting: (id: number) => apiClient.delete<{ detail: string }>(`/job-postings/${id}`),
  applicants: async (params: ApplicantListParams, signal?: AbortSignal) => {
    const page = await apiClient.get<PageDto<ApplicantDto>>(
      `/applicants/?${applicantParams(params)}`,
      { signal },
    )
    return { count: page.count, items: page.items.map(mapApplicant) }
  },
  applicant: async (id: number, signal?: AbortSignal) =>
    mapApplicant(await apiClient.get<ApplicantDto>(`/applicants/${id}`, { signal })),
  createApplicant: async (input: ApplicantInput) =>
    mapApplicant(await apiClient.post<ApplicantDto>('/applicants/', input)),
  updateApplicant: async (id: number, input: ApplicantInput) =>
    mapApplicant(await apiClient.put<ApplicantDto>(`/applicants/${id}`, input)),
  updateApplicantStatus: async (id: number, status: ApplicantStatus) =>
    mapApplicant(await apiClient.patch<ApplicantDto>(`/applicants/${id}/status`, { status })),
  deleteApplicant: (id: number) => apiClient.delete<{ detail: string }>(`/applicants/${id}`),
  interviews: async (applicantId: number, signal?: AbortSignal) => {
    const page = await apiClient.get<PageDto<InterviewDto>>(
      `/applicants/${applicantId}/interviews/?limit=50&offset=0`,
      { signal },
    )
    return { count: page.count, items: page.items.map(mapInterview) }
  },
  scheduleInterview: async (applicantId: number, input: InterviewInput) =>
    mapInterview(
      await apiClient.post<InterviewDto>(`/applicants/${applicantId}/interviews/`, input),
    ),
  offerLetters: async (applicantId: number, signal?: AbortSignal) => {
    const page = await apiClient.get<PageDto<OfferLetterDto>>(
      `/applicants/${applicantId}/offer-letters/?limit=50&offset=0`,
      { signal },
    )
    return { count: page.count, items: page.items.map(mapOffer) }
  },
  createOfferLetter: async (applicantId: number, input: OfferLetterInput) =>
    mapOffer(
      await apiClient.post<OfferLetterDto>(`/applicants/${applicantId}/offer-letters/`, input),
    ),
}
