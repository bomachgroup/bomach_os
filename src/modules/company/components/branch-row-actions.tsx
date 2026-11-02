import {
  useCallback,
  useEffect,
  useId,
  useRef,
  useState,
  type CSSProperties,
  type KeyboardEvent,
} from 'react'
import { createPortal } from 'react-dom'
import { Link } from '@tanstack/react-router'
import { Eye, MoreHorizontal, Pencil } from 'lucide-react'

import type { BranchDto } from '@/modules/company/branches.api'
import type { BranchDirectorySearch } from '@/modules/company/branches.search'

type BranchRowActionsProps = {
  branch: BranchDto
  search: BranchDirectorySearch
  canView: boolean
  canEdit: boolean
  onEdit: () => void
}

function getMenuPosition(trigger: HTMLElement, itemCount: number) {
  const rect = trigger.getBoundingClientRect()
  const viewportPadding = 8
  const width = Math.min(192, window.innerWidth - viewportPadding * 2)
  const estimatedHeight = itemCount * 40 + 12
  const openAbove = window.innerHeight - rect.bottom < estimatedHeight && rect.top > estimatedHeight

  return {
    position: 'fixed' as const,
    top: openAbove ? Math.max(viewportPadding, rect.top - estimatedHeight - 4) : rect.bottom + 4,
    left: Math.min(
      Math.max(viewportPadding, rect.right - width),
      Math.max(viewportPadding, window.innerWidth - width - viewportPadding),
    ),
    width,
    zIndex: 250,
  } satisfies CSSProperties
}

function focusAdjacentTo(trigger: HTMLElement, direction: -1 | 1) {
  const focusable = Array.from(
    document.querySelectorAll<HTMLElement>(
      'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
    ),
  ).filter(
    (element) =>
      element.tabIndex >= 0 &&
      !element.closest('[role="menu"]') &&
      !element.closest('[aria-hidden="true"]') &&
      element.getClientRects().length > 0,
  )
  const triggerIndex = focusable.indexOf(trigger)
  const next = focusable[triggerIndex + direction]
  next?.focus()
}

export function BranchRowActions({
  branch,
  search,
  canView,
  canEdit,
  onEdit,
}: BranchRowActionsProps) {
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const itemRefs = useRef<Array<HTMLElement | null>>([])
  const menuId = useId()
  const [open, setOpen] = useState(false)
  const [position, setPosition] = useState<CSSProperties | null>(null)
  const itemCount = Number(canView) + Number(canEdit)

  const closeMenu = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPosition(null)
    if (restoreFocus) requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  const openMenu = () => {
    const trigger = triggerRef.current
    if (!trigger || itemCount === 0) return
    setPosition(getMenuPosition(trigger, itemCount))
    setOpen(true)
    requestAnimationFrame(() => itemRefs.current.find(Boolean)?.focus())
  }

  useEffect(() => {
    if (!open) return

    const handlePointerDown = (event: PointerEvent) => {
      const target = event.target as Node
      if (triggerRef.current?.contains(target) || menuRef.current?.contains(target)) return
      closeMenu()
    }
    const reposition = () => {
      const trigger = triggerRef.current
      if (!trigger?.isConnected) {
        closeMenu()
        return
      }
      setPosition(getMenuPosition(trigger, itemCount))
    }

    document.addEventListener('pointerdown', handlePointerDown, true)
    window.addEventListener('resize', reposition)
    window.addEventListener('scroll', reposition, true)
    return () => {
      document.removeEventListener('pointerdown', handlePointerDown, true)
      window.removeEventListener('resize', reposition)
      window.removeEventListener('scroll', reposition, true)
    }
  }, [closeMenu, itemCount, open])

  const handleMenuKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    const enabledItems = itemRefs.current.filter((item): item is HTMLElement => item !== null)
    const activeIndex = enabledItems.indexOf(document.activeElement as HTMLElement)
    if (event.key === 'Escape') {
      event.preventDefault()
      closeMenu(true)
    } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      const direction = event.key === 'ArrowDown' ? 1 : -1
      const nextIndex =
        activeIndex < 0 ? 0 : (activeIndex + direction + enabledItems.length) % enabledItems.length
      enabledItems[nextIndex]?.focus()
    } else if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault()
      enabledItems[event.key === 'Home' ? 0 : enabledItems.length - 1]?.focus()
    } else if (event.key === 'Tab') {
      event.preventDefault()
      const direction = event.shiftKey ? -1 : 1
      closeMenu()
      requestAnimationFrame(() => {
        if (triggerRef.current) focusAdjacentTo(triggerRef.current, direction)
      })
    }
  }

  if (!canView && !canEdit) return null

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        aria-label={`More actions for ${branch.branch_name}`}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => (open ? closeMenu() : openMenu())}
        className="rounded-control border-border-subtle text-caption text-text-secondary hover:bg-surface-muted hover:text-text-primary focus-visible:shadow-focus-ring inline-flex min-h-9 items-center gap-1.5 border px-2.5 font-semibold whitespace-nowrap transition-colors focus-visible:outline-none"
      >
        <MoreHorizontal className="size-4" aria-hidden="true" />
        More
      </button>
      {open && position
        ? createPortal(
            <div
              ref={menuRef}
              id={menuId}
              role="menu"
              aria-label={`Actions for ${branch.branch_name}`}
              onKeyDown={handleMenuKeyDown}
              style={position}
              className="border-border-subtle bg-surface rounded-control shadow-overlay overflow-hidden border p-1.5"
            >
              {canView ? (
                <Link
                  ref={(element) => {
                    itemRefs.current[0] = element
                  }}
                  to="/company/branch/$branchId"
                  params={{ branchId: String(branch.id) }}
                  search={search}
                  role="menuitem"
                  tabIndex={-1}
                  aria-label={`View details for ${branch.branch_name}`}
                  onClick={() => closeMenu()}
                  className="rounded-control text-body-sm text-text-primary hover:bg-surface-muted focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none"
                >
                  <Eye className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                  View branch details
                </Link>
              ) : null}
              {canEdit ? (
                <button
                  ref={(element) => {
                    itemRefs.current[Number(canView)] = element
                  }}
                  type="button"
                  role="menuitem"
                  tabIndex={-1}
                  onClick={() => {
                    closeMenu()
                    onEdit()
                  }}
                  className="rounded-control text-body-sm text-text-primary hover:bg-surface-muted focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none"
                >
                  <Pencil className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                  Edit branch
                </button>
              ) : null}
            </div>,
            document.body,
          )
        : null}
    </>
  )
}
