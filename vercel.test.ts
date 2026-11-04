import { afterEach, describe, expect, it, vi } from 'vitest'

describe('Vercel routing', () => {
  afterEach(() => {
    vi.unstubAllEnvs()
    vi.resetModules()
  })

  it('keeps APIs and Services external rewrites ahead of the React fallback', async () => {
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
        source: '/media/(.*)',
        destination: 'https://api.example.test/media/$1',
      },
      {
        source: '/services',
        destination: 'https://services-mocha-xi.vercel.app/services',
      },
      {
        source: '/services/(.*)',
        destination: 'https://services-mocha-xi.vercel.app/services/$1',
      },
      {
        source: '/(.*)',
        destination: '/index.html',
      },
    ])
    expect(config.headers?.[0]).toMatchObject({ source: '/api/(.*)' })
    expect(config.headers?.[1]).toMatchObject({ source: '/media/(.*)' })
  })

  it('keeps production API routing environment-specific while retaining the Services upstream', async () => {
    vi.stubEnv('VERCEL_ENV', 'production')
    vi.stubEnv('BOMACH_API_PRODUCTION_ORIGIN', 'https://api.example.prod')

    const { config } = await import('./vercel')
    const rewrites = config.rewrites as Array<{ source: string; destination: string }>

    expect(rewrites[0]).toEqual({
      source: '/api/(.*)',
      destination: 'https://api.example.prod/api/$1',
    })
    expect(rewrites[2].destination).toBe('https://services-mocha-xi.vercel.app/services')
  })
})
