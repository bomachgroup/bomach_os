import { routes, type VercelConfig } from '@vercel/config/v1'

const deploymentEnvironment = process.env.VERCEL_ENV
const apiOriginVariable =
  deploymentEnvironment === 'production'
    ? 'BOMACH_API_PRODUCTION_ORIGIN'
    : 'BOMACH_API_STAGING_ORIGIN'
const configuredApiOrigin = process.env[apiOriginVariable]

if (!configuredApiOrigin) {
  throw new Error(
    `Set ${apiOriginVariable} in the Vercel project environment before deploying Bomach OS.`,
  )
}

const apiOrigin = new URL(configuredApiOrigin)
if (apiOrigin.protocol !== 'https:') {
  throw new Error(`${apiOriginVariable} must use HTTPS.`)
}
if (
  apiOrigin.username ||
  apiOrigin.password ||
  apiOrigin.pathname !== '/' ||
  apiOrigin.search ||
  apiOrigin.hash
) {
  throw new Error(`${apiOriginVariable} must be an HTTPS origin without credentials or a path.`)
}

export const config: VercelConfig = {
  framework: 'vite',
  buildCommand: 'npm run build',
  outputDirectory: 'dist',
  rewrites: [
    // Match every API path as a regex, including root collection routes with
    // or without a trailing slash, before the SPA fallback can claim it.
    routes.rewrite('/api/(.*)', `${apiOrigin.origin}/api/$1`),
    // Service documents and estate images are returned as backend-relative media paths.
    routes.rewrite('/media/(.*)', `${apiOrigin.origin}/media/$1`),
    // Keep Services independently deployed while composing it under this host.
    // This private upstream prefix avoids colliding with standalone-domain redirects.
    routes.rewrite('/services', 'https://services-mocha-xi.vercel.app/__bomach_shared/services/'),
    routes.rewrite(
      '/services/(.*)',
      'https://services-mocha-xi.vercel.app/__bomach_shared/services/$1',
    ),
    // Marketing remains an independent deployment and is composed under the Bomach host.
    routes.rewrite(
      '/marketing',
      'https://marketing-wine-alpha.vercel.app/__bomach_shared/marketing/',
    ),
    routes.rewrite(
      '/marketing/(.*)',
      'https://marketing-wine-alpha.vercel.app/__bomach_shared/marketing/$1',
    ),
    routes.rewrite('/(.*)', '/index.html'),
  ],
  headers: [
    {
      source: '/api/(.*)',
      headers: [
        { key: 'Cache-Control', value: 'private, no-store, max-age=0' },
        { key: 'CDN-Cache-Control', value: 'no-store' },
        { key: 'Vercel-CDN-Cache-Control', value: 'no-store' },
      ],
    },
    {
      source: '/media/(.*)',
      headers: [
        { key: 'Cache-Control', value: 'private, no-store, max-age=0' },
        { key: 'CDN-Cache-Control', value: 'no-store' },
        { key: 'Vercel-CDN-Cache-Control', value: 'no-store' },
      ],
    },
  ],
}
