import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { recruitmentApi } from './recruitment.api'

afterEach(() => vi.restoreAllMocks())

describe('recruitmentApi', () => {
  it('serializes posting filters and maps the paginated response', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 7,
          job_title: 'People Partner',
          department_id: 3,
          branch_id: 2,
          job_type: 'full_time',
          status: 'active',
          applicants_count: 4,
          created_at: '2026-10-01T10:00:00Z',
          updated_at: '2026-10-02T10:00:00Z',
          description: 'Build the people function',
          requirements: 'People operations',
          responsibilities: 'Support managers',
          salary_min: '1000000.00',
          salary_max: null,
          vacancy_count: 1,
          deadline: null,
          is_active: true,
        },
      ],
    })

    const result = await recruitmentApi.jobPostings({
      limit: 20,
      offset: 20,
      search: 'People',
      status: 'active',
      jobType: 'full_time',
      branchId: '2',
      departmentId: '3',
    })

    expect(get).toHaveBeenCalledWith(
      '/job-postings/?limit=20&offset=20&search=People&status=active&job_type=full_time&branch_id=2&department_id=3',
      { signal: undefined },
    )
    expect(result).toMatchObject({
      count: 1,
      items: [
        {
          id: 7,
          title: 'People Partner',
          branchId: 2,
          departmentId: 3,
          applicantsCount: 4,
          salaryMin: '1000000.00',
        },
      ],
    })
  })

  it('uses real applicant status and supported interview/offer endpoints', async () => {
    const applicant = {
      id: 12,
      first_name: 'Amina',
      last_name: 'Yusuf',
      email: 'amina@example.test',
      phone: '+2348000000000',
      job_posting: {
        id: 7,
        job_title: 'People Partner',
        department_id: 3,
        branch_id: 2,
        job_type: 'full_time',
        status: 'active',
        applicants_count: 1,
        created_at: '2026-10-01T10:00:00Z',
        updated_at: '2026-10-02T10:00:00Z',
      },
      status: 'interviewed',
      created_at: '2026-10-01T10:00:00Z',
      updated_at: '2026-10-02T10:00:00Z',
    }
    const patch = vi.spyOn(apiClient, 'patch').mockResolvedValue(applicant)
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({
      id: 8,
      applicant_id: 12,
      interviewer_id: 5,
      scheduled_at: '2026-11-01T09:30:00Z',
      meeting_link: 'https://meet.example.test/abc',
      feedback: null,
      status: 'scheduled',
      created_at: '2026-10-27T10:00:00Z',
    })

    const changed = await recruitmentApi.updateApplicantStatus(12, 'interviewed')
    const interview = await recruitmentApi.scheduleInterview(12, {
      interviewer_id: 5,
      scheduled_at: '2026-11-01T09:30:00Z',
      meeting_link: 'https://meet.example.test/abc',
    })

    expect(patch).toHaveBeenCalledWith('/applicants/12/status', { status: 'interviewed' })
    expect(changed).toMatchObject({ id: 12, status: 'interviewed', firstName: 'Amina' })
    expect(post).toHaveBeenCalledWith(
      '/applicants/12/interviews/',
      expect.objectContaining({ interviewer_id: 5 }),
    )
    expect(interview).toMatchObject({
      id: 8,
      applicantId: 12,
      interviewerId: 5,
      status: 'scheduled',
    })
  })

  it('maps offer values and submits content through the supported create endpoint', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({
      id: 19,
      applicant_id: 12,
      template: 'standard_full_time',
      annual_salary: '5400000.00',
      start_date: '2026-12-01T00:00:00Z',
      status: 'sent',
      sent_at: '2026-10-27T10:00:00Z',
      created_at: '2026-10-27T10:00:00Z',
    })
    const result = await recruitmentApi.createOfferLetter(12, {
      template: 'standard_full_time',
      annual_salary: 5_400_000,
      start_date: '2026-12-01T00:00:00Z',
      letter_content: 'We are pleased to offer you the role.',
    })

    expect(post).toHaveBeenCalledWith(
      '/applicants/12/offer-letters/',
      expect.objectContaining({ annual_salary: 5_400_000 }),
    )
    expect(result).toMatchObject({
      id: 19,
      applicantId: 12,
      annualSalary: '5400000.00',
      status: 'sent',
    })
  })
})
