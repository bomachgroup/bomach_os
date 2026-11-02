import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { loansApi } from './loans.api'

afterEach(() => vi.restoreAllMocks())

describe('loansApi', () => {
  it('supports the all, pending and history backend list filters', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    await loansApi.list({ limit: 10, offset: 0, search: '', status: 'all' })
    await loansApi.list({ limit: 20, offset: 20, search: 'Amina', status: 'pending' })
    await loansApi.list({ limit: 10, offset: 0, search: '', status: 'history' })
    expect(get).toHaveBeenNthCalledWith(1, '/loans?limit=10&offset=0', { signal: undefined })
    expect(get).toHaveBeenNthCalledWith(
      2,
      '/loans?limit=20&offset=20&search=Amina&status=pending',
      { signal: undefined },
    )
    expect(get).toHaveBeenNthCalledWith(3, '/loans?limit=10&offset=0&status=history', {
      signal: undefined,
    })
  })

  it('sends employee targeting only when provided and exposes pending update and decisions', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 9 })
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue({ id: 9 })
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ id: 9 })
    const payload = {
      loan_amount: 75000,
      repayment_date: '2026-12-01',
      reason: 'Tuition',
      emergency_contact_name: 'Ifeoma',
      emergency_contact_phone: '+23480000000',
      employee_user_id: 12,
    }
    await loansApi.create(payload)
    await loansApi.get(9)
    await loansApi.update(9, { reason: 'Updated reason' })
    await loansApi.approve(9)
    await loansApi.reject(9)
    expect(post).toHaveBeenNthCalledWith(1, '/loans', payload)
    expect(get).toHaveBeenCalledWith('/loans/9', { signal: undefined })
    expect(put).toHaveBeenCalledWith('/loans/9', { reason: 'Updated reason' })
    expect(post).toHaveBeenNthCalledWith(2, '/loans/9/approve')
    expect(post).toHaveBeenNthCalledWith(3, '/loans/9/reject')
  })

  it('uploads a supporting document as multipart form data and returns its stored URL', async () => {
    const file = new File(['proof'], 'proof.pdf', { type: 'application/pdf' })
    const post = vi
      .spyOn(apiClient, 'post')
      .mockResolvedValue({ url: 'https://files.example.test/proof.pdf' })

    await expect(loansApi.uploadAttachment(file)).resolves.toEqual({
      url: 'https://files.example.test/proof.pdf',
    })

    const [path, body] = post.mock.calls[0]
    expect(path).toBe('/others/upload-file')
    expect(body).toBeInstanceOf(FormData)
    expect((body as FormData).get('file')).toBe(file)
  })
})
