import { afterEach, describe, expect, it, vi } from 'vitest'

describe('Vercel routing', () => {
  afterEach(() => {
    vi.unstubAllEnvs()
    vi.resetModules()
  })

  it('keeps APIs and product rewrites ahead of the React fallback', async () => {
    vi.stubEnv('VERCEL_ENV', 'preview')
    vi.stubEnv('BOMACH_API_STAGING_ORIGIN', 'https://api.example.test')

    const { config } = await import('./vercel')
    const rewrites = config.rewrites as Array<{ source: string; destination: string }>

    expect(rewrites.slice(0, -1)).toEqual([
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
        destination: 'https://services-mocha-xi.vercel.app/__bomach_shared/services',
      },
      {
        source: '/services/',
        destination: 'https://services-mocha-xi.vercel.app/__bomach_shared/services',
      },
      {
        source: '/services/(.*)',
        destination: 'https://services-mocha-xi.vercel.app/__bomach_shared/services/$1',
      },
      {
        source: '/marketing',
        destination: 'https://marketing-wine-alpha.vercel.app/__bomach_shared/marketing/',
      },
      {
        source: '/marketing/(.*)',
        destination: 'https://marketing-wine-alpha.vercel.app/__bomach_shared/marketing/$1',
      },
    ])
    const spaFallback = rewrites.at(-1) as {
      source: string
      destination: string
    }
    expect(spaFallback).toEqual({
      source: '/((?!assets(?:/|$)).*)',
      destination: '/index.html',
    })
    const spaRouteMatcher = new RegExp(`^${spaFallback.source}$`)
    expect(spaRouteMatcher.test('/company/partners')).toBe(true)
    expect(spaRouteMatcher.test('/')).toBe(true)
    expect(spaRouteMatcher.test('/assets/old-partner-chunk.js')).toBe(false)
    expect(spaRouteMatcher.test('/assets')).toBe(false)
    const appHtmlHeader = config.headers?.find(({ source }) => source.includes('assets/'))
    expect(appHtmlHeader).toEqual({
      source: '/((?!api/|media/|assets/|services(?:/|$)|marketing(?:/|$)).*)',
      headers: [{ key: 'Cache-Control', value: 'no-cache' }],
    })
    const appHtmlHeaderMatcher = new RegExp(`^${appHtmlHeader?.source}$`)
    expect(appHtmlHeaderMatcher.test('/company/partners')).toBe(true)
    expect(appHtmlHeaderMatcher.test('/')).toBe(true)
    expect(appHtmlHeaderMatcher.test('/assets/old-partner-chunk.js')).toBe(false)
    expect(appHtmlHeaderMatcher.test('/api/v1/auth/me')).toBe(false)
    expect(appHtmlHeaderMatcher.test('/media/file.pdf')).toBe(false)
    expect(appHtmlHeaderMatcher.test('/services/tasks')).toBe(false)
    expect(appHtmlHeaderMatcher.test('/marketing/campaigns')).toBe(false)
    expect(config.headers?.[1]).toMatchObject({ source: '/api/(.*)' })
    expect(config.headers?.[2]).toMatchObject({ source: '/media/(.*)' })
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
    expect(rewrites[5].destination).toBe(
      'https://marketing-wine-alpha.vercel.app/__bomach_shared/marketing/',
    )
  })
})
