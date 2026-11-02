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
import { MoreHorizontal, type LucideIcon } from 'lucide-react'

import { Button } from '@/shared/ui/button'

export type RecruitmentMenuAction = {
  id: string
  label: string
  icon: LucideIcon
  onSelect: () => void
  disabled?: boolean
  danger?: boolean
  className?: string
}

function menuPosition(trigger: HTMLElement, itemCount: number): CSSProperties {
  const rect = trigger.getBoundingClientRect()
  const padding = 8
  const width = Math.min(224, window.innerWidth - padding * 2)
  const height = itemCount * 40 + 12
  const openAbove = window.innerHeight - rect.bottom < height && rect.top > height
  return {
    position: 'fixed',
    top: openAbove ? Math.max(padding, rect.top - height - 4) : rect.bottom + 4,
    left: Math.min(
      Math.max(padding, rect.right - width),
      Math.max(padding, window.innerWidth - width - padding),
    ),
    width,
    maxHeight: window.innerHeight - padding * 2,
    overflowY: 'auto',
    zIndex: 250,
  }
}

function visibleEnabledItems(items: Array<HTMLButtonElement | null>) {
  return items.filter(
    (item): item is HTMLButtonElement =>
      item !== null && !item.disabled && window.getComputedStyle(item).display !== 'none',
  )
}

export function RecruitmentRowActions({
  recordLabel,
  actions,
}: {
  recordLabel: string
  actions: RecruitmentMenuAction[]
}) {
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const itemRefs = useRef<Array<HTMLButtonElement | null>>([])
  const menuId = useId()
  const [open, setOpen] = useState(false)
  const [position, setPosition] = useState<CSSProperties | null>(null)

  const close = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPosition(null)
    if (restoreFocus) requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  function openMenu() {
    const trigger = triggerRef.current
    if (!trigger || actions.length === 0) return
    setPosition(menuPosition(trigger, actions.length))
    setOpen(true)
    requestAnimationFrame(() => visibleEnabledItems(itemRefs.current)[0]?.focus())
  }

  useEffect(() => {
    if (!open) return
    const onPointerDown = (event: PointerEvent) => {
      const target = event.target as Node
      if (triggerRef.current?.contains(target) || menuRef.current?.contains(target)) return
      close()
    }
    const reposition = () => {
      if (triggerRef.current?.isConnected) {
        setPosition(menuPosition(triggerRef.current, actions.length))
      } else {
        close()
      }
    }
    document.addEventListener('pointerdown', onPointerDown, true)
    window.addEventListener('resize', reposition)
    window.addEventListener('scroll', reposition, true)
    return () => {
      document.removeEventListener('pointerdown', onPointerDown, true)
      window.removeEventListener('resize', reposition)
      window.removeEventListener('scroll', reposition, true)
    }
  }, [actions.length, close, open])

  function handleKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    const enabled = visibleEnabledItems(itemRefs.current)
    const activeIndex = enabled.indexOf(document.activeElement as HTMLButtonElement)
    if (event.key === 'Escape') {
      event.preventDefault()
      close(true)
    } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      const direction = event.key === 'ArrowDown' ? 1 : -1
      const next = activeIndex < 0 ? 0 : (activeIndex + direction + enabled.length) % enabled.length
      enabled[next]?.focus()
    } else if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault()
      enabled[event.key === 'Home' ? 0 : enabled.length - 1]?.focus()
    }
  }

  if (!actions.length) return null

  return (
    <>
      <Button
        ref={triggerRef}
        type="button"
        size="icon"
        variant="outline"
        aria-label={`More actions for ${recordLabel}`}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => (open ? close() : openMenu())}
      >
        <MoreHorizontal className="size-4" aria-hidden="true" />
      </Button>
      {open && position
        ? createPortal(
            <div
              ref={menuRef}
              id={menuId}
              role="menu"
              aria-label={`Actions for ${recordLabel}`}
              style={position}
              className="bg-surface border-border-subtle shadow-elevation-lg rounded-control border p-1.5"
              onKeyDown={handleKeyDown}
            >
              {actions.map(
                ({ id, label, icon: Icon, onSelect, disabled, danger, className }, index) => (
                  <button
                    key={id}
                    ref={(element) => {
                      itemRefs.current[index] = element
                    }}
                    type="button"
                    role="menuitem"
                    disabled={disabled}
                    className={`focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2 rounded px-2.5 text-left text-sm font-medium focus-visible:outline-none disabled:cursor-wait disabled:opacity-60 ${danger ? 'text-danger hover:bg-danger-subtle/60' : 'text-text-primary hover:bg-surface-muted'} ${className ?? ''}`}
                    onClick={() => {
                      close()
                      onSelect()
                    }}
                  >
                    <Icon className="size-4 shrink-0" aria-hidden="true" />
                    {label}
                  </button>
                ),
              )}
            </div>,
            document.body,
          )
        : null}
    </>
  )
}
