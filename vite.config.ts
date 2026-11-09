import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { fileURLToPath, URL } from 'node:url'
import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const configuredSiteOrigin =
    env.VITE_SITE_ORIGIN ||
    process.env.VERCEL_PROJECT_PRODUCTION_URL ||
    process.env.VERCEL_URL ||
    'http://localhost:5173'
  const siteOrigin = new URL(
    configuredSiteOrigin.includes('://') ? configuredSiteOrigin : `https://${configuredSiteOrigin}`,
  ).origin

  return {
    plugins: [
      react(),
      tailwindcss(),
      {
        name: 'bomach-social-metadata-origin',
        transformIndexHtml(html) {
          return html.replaceAll('__BOMACH_SITE_ORIGIN__', siteOrigin)
        },
      },
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      port: Number(env.BOMACH_OS_DEV_PORT || 5173),
      strictPort: true,
      watch: {
        ignored: ['**/dist/**'],
      },
      proxy: {
        '/api': {
          target: env.BOMACH_API_ORIGIN || 'http://127.0.0.1:8000',
          changeOrigin: true,
        },
        '/services': {
          target: env.BOMACH_SERVICES_DEV_ORIGIN || 'http://127.0.0.1:5175',
          changeOrigin: true,
          ws: true,
          rewrite: (path) => path.replace(/^\/services(?=\?|$)/, '/services/'),
        },
        '/marketing': {
          target: env.BOMACH_MARKETING_DEV_ORIGIN || 'http://127.0.0.1:5177',
          changeOrigin: true,
          ws: true,
          rewrite: (path) => path.replace(/^\/marketing(?=\?|$)/, '/marketing/'),
        },
      },
    },
  }
})
