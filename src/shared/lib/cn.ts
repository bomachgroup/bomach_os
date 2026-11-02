import { clsx, type ClassValue } from 'clsx'
import { extendTailwindMerge } from 'tailwind-merge'

// Keep the custom semantic type utilities in Tailwind Merge's font-size group.
// Otherwise `text-label text-text-secondary` is misread as two competing colors.
const twMerge = extendTailwindMerge({
  extend: {
    theme: {
      text: [
        'display-lg',
        'display-md',
        'h1',
        'h2',
        'h3',
        'h4',
        'body-lg',
        'body-md',
        'body-sm',
        'control-label',
        'control-value',
        'label',
        'caption',
        'overline',
      ],
    },
  },
})

export function cn(...values: ClassValue[]) {
  return twMerge(clsx(values))
}
