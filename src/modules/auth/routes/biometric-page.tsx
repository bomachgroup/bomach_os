import { Link } from '@tanstack/react-router'

import { AuthPageFrame } from '../components/auth-page-frame'

export function BiometricPage() {
  return (
    <AuthPageFrame>
      <div className="space-y-6 text-center">
        <div>
          <h1 className="text-display-lg font-semibold">Biometric Login</h1>
          <p className="text-body-md text-text-secondary mt-3">
            Biometric sign-in is not supported in this browser.
          </p>
        </div>

        <div
          className="mx-auto flex size-40 items-center justify-center rounded-full border-4 border-neutral-800 text-neutral-800"
          aria-hidden="true"
        >
          <svg
            viewBox="0 0 90 90"
            className="size-[90px]"
            fill="none"
            stroke="currentColor"
            strokeWidth="3.4"
            strokeLinecap="round"
          >
            <path d="M45 12c-17 0-30 13-30 30M45 23c-11 0-19 8-19 19M45 34c-5 0-8 4-8 9 0 12-2 22-7 31M45 12c17 0 30 13 30 30 0 14-2 25-8 35M45 23c11 0 19 8 19 19 0 12-1 22-6 31M45 34c5 0 8 4 8 9 0 9 1 17 4 24M14 48c1 12 0 21-4 29M76 48c0 8-1 15-4 22" />
          </svg>
        </div>

        <Link
          className="rounded-control bg-primary text-text-on-primary focus-visible:shadow-focus-ring text-label inline-flex min-h-12 w-full items-center justify-center px-5 py-2.5 font-semibold focus-visible:outline-none"
          to="/login"
        >
          Use Password Instead
        </Link>
      </div>
    </AuthPageFrame>
  )
}
