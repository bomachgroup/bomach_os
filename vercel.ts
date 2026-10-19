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
  rewrites: [
    routes.rewrite('/api/:path*', `${apiOrigin.origin}/api/:path*`),
    routes.rewrite('/(.*)', '/index.html'),
  ],
  headers: [
    {
      source: '/api/:path*',
      headers: [
        { key: 'Cache-Control', value: 'private, no-store, max-age=0' },
        { key: 'CDN-Cache-Control', value: 'no-store' },
        { key: 'Vercel-CDN-Cache-Control', value: 'no-store' },
      ],
    },
  ],
}
