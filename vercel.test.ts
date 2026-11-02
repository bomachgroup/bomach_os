import { afterEach, describe, expect, it, vi } from 'vitest'

describe('Vercel API routing', () => {
  afterEach(() => {
    vi.unstubAllEnvs()
    vi.resetModules()
  })

  it('proxies every API path before the React fallback', async () => {
    vi.stubEnv('VERCEL_ENV', 'preview')
    vi.stubEnv('BOMACH_API_STAGING_ORIGIN', 'https://api.example.test')

    const { config } = await import('./vercel')
    const rewrites = config.rewrites as Array<{ source: string; destination: string }>

    expect(rewrites).toEqual([
      {
        source: '/api/(.*)',
        destination: 'https://api.example.test/api/$1',
      },
      {
        source: '/(.*)',
        destination: '/index.html',
      },
    ])
    expect(config.headers?.[0]).toMatchObject({ source: '/api/(.*)' })
  })
})
