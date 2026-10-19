import type { KeyboardEvent as ReactKeyboardEvent } from 'react'

import {
  NAVIGATION_CATEGORIES,
  type NavigationGroup,
  type ProtectedDestination,
} from '@/app/navigation/route-manifest'

export function navigationGroupLabel(group: NavigationGroup) {
  return group === 'Dashboard' ? 'My Work' : group
}

export function navigationCategoryLabel(
  destination: Pick<ProtectedDestination, 'group' | 'navigationCategory'>,
) {
  if (!destination.navigationCategory) return undefined
  return NAVIGATION_CATEGORIES[destination.group].find(
    (category) => category.id === destination.navigationCategory,
  )?.label
}

export function handleDrawerKeyDown(event: ReactKeyboardEvent<HTMLDivElement>) {
  if (event.key !== 'Tab') return
  const drawer = event.currentTarget
  const closeButton = drawer.querySelector<HTMLElement>('[data-drawer-close]')
  const focusable = [
    ...drawer.querySelectorAll<HTMLElement>(
      'a[href], button:not([disabled]), input:not([disabled])',
    ),
  ].filter((element) => element !== closeButton)
  if (closeButton) focusable.unshift(closeButton)
  if (focusable.length === 0) return
  const first = focusable[0]!
  const last = focusable[focusable.length - 1]!
  if (event.shiftKey && document.activeElement === first) {
    event.preventDefault()
    last.focus()
  } else if (!event.shiftKey && document.activeElement === last) {
    event.preventDefault()
    first.focus()
  }
}
