import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { assetsApi } from './assets.api'

afterEach(() => vi.restoreAllMocks())

describe('assetsApi', () => {
  it('serializes the search and offset pagination for the register', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await assetsApi.list({ limit: 10, offset: 20, search: 'serial 42' })

    expect(get).toHaveBeenCalledWith('/assets/?limit=10&offset=20&search=serial+42', {
      signal: undefined,
    })
  })

  it('uses the asset-scoped choices contract', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      branches: [],
      employees: [],
      departments: [],
    })

    await assetsApi.choices()

    expect(get).toHaveBeenCalledWith('/assets/choices', { signal: undefined })
  })

  it('uploads a selected file through the existing shared upload endpoint', async () => {
    const post = vi
      .spyOn(apiClient, 'post')
      .mockResolvedValue({ url: 'https://files.test/receipt.pdf' })
    const file = new File(['receipt'], 'receipt.pdf', { type: 'application/pdf' })

    await assetsApi.upload(file)

    expect(post).toHaveBeenCalledWith('/others/upload-file', expect.any(FormData))
    const formData = post.mock.calls[0]?.[1] as FormData
    expect(formData.get('file')).toBe(file)
  })
})
