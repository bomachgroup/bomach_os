# Temporary npm Audit Exception

Reviewed: 2026-10-30
Review trigger: the first compatible `@vercel/config` release, or before the next production dependency review

## Zod under `@vercel/config`

- Advisory: [GHSA-mrhx-c7xc-m3w5](https://github.com/advisories/GHSA-mrhx-c7xc-m3w5), high severity.
- Resolved package: `@vercel/config@0.12.0` -> `zod@3.25.76`.
- The advisory lists `zod@4.6.6` as patched. The current `@vercel/config` dependency range is `zod@^3.22.0`; forcing Zod 4 would cross that range and has not been verified against Vercel config parsing.
- `@vercel/config` is a development dependency used to compile `vercel.ts` during deployment. The affected copy is not included in the browser runtime bundle. The application uses its separate root Zod 4 dependency.

## Decision And Controls

Keep this as a temporary dependency exception rather than apply an unverified major-version override. The exception is limited to the build-time Vercel configuration parser; do not treat it as a blanket acceptance for other Zod copies or application runtime use.

Re-evaluate on the first compatible upstream release and before production dependency review. When re-evaluating, update the dependency and lockfile, run `npm audit` and `npm audit --omit=dev`, and exercise Vercel configuration compilation and the production build. Remove this exception once the resolved package is patched.
