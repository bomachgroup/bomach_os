import { useState, type ReactNode } from 'react'

interface CompanyLogoImageProps {
  src: string | null | undefined
  alt: string
  className: string
  fallback: ReactNode
}

/** Show the supplied company mark when a configured logo URL is unavailable. */
export function CompanyLogoImage({ src, alt, className, fallback }: CompanyLogoImageProps) {
  const [failedSource, setFailedSource] = useState<string | null>(null)

  if (!src || failedSource === src) return fallback

  return <img src={src} alt={alt} className={className} onError={() => setFailedSource(src)} />
}
