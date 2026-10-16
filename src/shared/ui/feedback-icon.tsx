import type { ReactNode, SVGProps } from 'react'

export type FeedbackIconName = 'success' | 'info' | 'warning' | 'danger' | 'close'

const paths: Record<FeedbackIconName, ReactNode> = {
  success: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="m8 12 2.5 2.5L16.5 9" />
    </>
  ),
  info: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v5M12 8h.01" />
    </>
  ),
  warning: (
    <>
      <path d="m10.3 3.9-8 14A2.1 2.1 0 0 0 4.1 21h15.8a2.1 2.1 0 0 0 1.8-3.1l-8-14a2 2 0 0 0-3.4 0Z" />
      <path d="M12 9v4M12 17h.01" />
    </>
  ),
  danger: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="m9 9 6 6m0-6-6 6" />
    </>
  ),
  close: <path d="m18 6-12 12M6 6l12 12" />,
}

export function FeedbackIcon({
  name,
  ...props
}: SVGProps<SVGSVGElement> & { name: FeedbackIconName }) {
  return (
    <svg
      aria-hidden="true"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      {paths[name]}
    </svg>
  )
}
