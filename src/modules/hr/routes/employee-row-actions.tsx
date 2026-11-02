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
import {
  Eye,
  CalendarClock,
  LogOut,
  MoreHorizontal,
  Pencil,
  UserRoundCheck,
  UserRoundX,
} from 'lucide-react'

import type { EmployeeDto } from '@/modules/hr/employees.api'
import { Button } from '@/shared/ui/button'

type EmployeeStatusAction = 'active' | 'inactive' | 'suspended'

type EmployeeRowActionsProps = {
  employee: EmployeeDto
  canView: boolean
  canUpdate: boolean
  canExit: boolean
  onEdit: (employee: EmployeeDto) => void
  onStatusChange: (employee: EmployeeDto, status: EmployeeStatusAction) => void
  onExit: (employee: EmployeeDto) => void
}

type MenuItem = {
  key: string
  label: string
  icon: typeof Eye
  tone?: 'danger' | 'warning' | 'success'
  run?: () => void
}

function getMenuPosition(trigger: HTMLElement, itemCount: number) {
  const rect = trigger.getBoundingClientRect()
  const padding = 8
  const width = Math.min(224, window.innerWidth - padding * 2)
  const height = itemCount * 40 + 12
  const openAbove = window.innerHeight - rect.bottom < height && rect.top > height

  return {
    position: 'fixed' as const,
    top: openAbove ? Math.max(padding, rect.top - height - 4) : rect.bottom + 4,
    left: Math.min(
      Math.max(padding, rect.right - width),
      Math.max(padding, window.innerWidth - width - padding),
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
  const index = focusable.indexOf(trigger)
  focusable[index + direction]?.focus()
}

export function EmployeeRowActions({
  employee,
  canView,
  canUpdate,
  canExit,
  onEdit,
  onStatusChange,
  onExit,
}: EmployeeRowActionsProps) {
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const itemRefs = useRef<Array<HTMLElement | null>>([])
  const menuId = useId()
  const [open, setOpen] = useState(false)
  const [position, setPosition] = useState<CSSProperties | null>(null)
  const isTerminated = employee.employment_status === 'terminated'
  const accountIsActive = employee.account_is_active
  const isOnLeave = employee.employment_status === 'on-leave'
  const isSuspended = employee.employment_status === 'suspended'
  const isInactive = employee.employment_status === 'inactive'
  const name = [employee.first_name, employee.last_name].filter(Boolean).join(' ')

  const items: MenuItem[] = []
  if (canView) items.push({ key: 'view', label: 'View employee', icon: Eye })
  if (canUpdate) items.push({ key: 'edit', label: 'Edit details', icon: Pencil })
  if (canUpdate && !isTerminated) {
    if (!accountIsActive || isInactive || isSuspended) {
      items.push({
        key: 'activate',
        label: 'Activate employee',
        icon: UserRoundCheck,
        tone: 'success',
        run: () => onStatusChange(employee, 'active'),
      })
    }
    if (
      canView &&
      ['active', 'on-probation', 'suspended', 'on-leave'].includes(employee.employment_status)
    ) {
      items.push({
        key: 'leave',
        label: isOnLeave ? 'Manage leave / return' : 'Manage leave',
        icon: CalendarClock,
        tone: 'warning',
      })
    }
    if (accountIsActive && !isSuspended) {
      items.push({
        key: 'suspend',
        label: 'Suspend access',
        icon: UserRoundX,
        tone: 'warning',
        run: () => onStatusChange(employee, 'suspended'),
      })
    }
    if (!isInactive) {
      items.push({
        key: 'deactivate',
        label: 'Deactivate employee',
        icon: UserRoundX,
        run: () => onStatusChange(employee, 'inactive'),
      })
    }
  }
  if (canExit && !isTerminated) {
    items.push({
      key: 'exit',
      label: 'Exit / offboard',
      icon: LogOut,
      tone: 'danger',
      run: () => onExit(employee),
    })
  }

  const visibleItems = items.length >= 4 ? items.slice(0, 2) : items
  const overflowItems = items.length >= 4 ? items.slice(2) : []

  const closeMenu = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPosition(null)
    if (restoreFocus) requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  const openMenu = () => {
    const trigger = triggerRef.current
    if (!trigger || overflowItems.length === 0) return
    setPosition(getMenuPosition(trigger, overflowItems.length))
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
      setPosition(getMenuPosition(trigger, overflowItems.length))
    }

    document.addEventListener('pointerdown', handlePointerDown, true)
    window.addEventListener('resize', reposition)
    window.addEventListener('scroll', reposition, true)
    return () => {
      document.removeEventListener('pointerdown', handlePointerDown, true)
      window.removeEventListener('resize', reposition)
      window.removeEventListener('scroll', reposition, true)
    }
  }, [closeMenu, overflowItems.length, open])

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

  if (!items.length) return null

  const renderVisibleItem = ({ key, label, icon: Icon, tone, run }: MenuItem) => {
    const variant = tone === 'danger' ? 'danger' : 'outline'
    const className = tone === 'warning' ? 'border-warning/30 text-warning' : undefined
    if (key === 'view') {
      return (
        <Link
          key={key}
          to="/hr/employees/$userId"
          params={{ userId: String(employee.user_id) }}
          aria-label={`View ${name || employee.employee_id}`}
          className="text-caption border-border-strong bg-surface text-text-primary hover:bg-surface-muted focus-visible:shadow-focus-ring rounded-control inline-flex min-h-9 items-center justify-center gap-2 border px-3 font-semibold whitespace-nowrap focus-visible:outline-none"
        >
          <Icon className="size-4 shrink-0" aria-hidden="true" />
          {label}
        </Link>
      )
    }
    if (key === 'leave') {
      return (
        <Link
          key={key}
          to="/hr/employees/$userId"
          params={{ userId: String(employee.user_id) }}
          search={{ section: 'leave' }}
          aria-label={`${label} for ${name || employee.employee_id}`}
          className="text-caption border-border-strong bg-surface text-text-primary hover:bg-surface-muted focus-visible:shadow-focus-ring rounded-control inline-flex min-h-9 items-center justify-center gap-2 border px-3 font-semibold whitespace-nowrap focus-visible:outline-none"
        >
          <Icon className="size-4 shrink-0" aria-hidden="true" />
          {label}
        </Link>
      )
    }
    return (
      <Button
        key={key}
        variant={variant}
        size="sm"
        leadingIcon={<Icon className="size-4 shrink-0" aria-hidden="true" />}
        className={className}
        onClick={() => {
          run?.()
          if (key === 'edit') onEdit(employee)
        }}
      >
        {label}
      </Button>
    )
  }

  return (
    <>
      <div className="flex min-w-0 flex-wrap items-center justify-end gap-2">
        {visibleItems.map(renderVisibleItem)}
        {overflowItems.length ? (
          <button
            ref={triggerRef}
            type="button"
            aria-label={`More actions for ${name || employee.employee_id}`}
            aria-haspopup="menu"
            aria-expanded={open}
            aria-controls={menuId}
            onClick={() => (open ? closeMenu() : openMenu())}
            className="rounded-control border-border-subtle text-text-secondary hover:bg-surface-muted hover:text-text-primary focus-visible:shadow-focus-ring inline-flex size-9 items-center justify-center border transition-colors focus-visible:outline-none"
          >
            <MoreHorizontal className="size-4" aria-hidden="true" />
          </button>
        ) : null}
      </div>
      {open && position
        ? createPortal(
            <div
              ref={menuRef}
              id={menuId}
              role="menu"
              aria-label={`Actions for ${name || employee.employee_id}`}
              onKeyDown={handleMenuKeyDown}
              style={position}
              className="border-border-subtle bg-surface rounded-control shadow-overlay overflow-hidden border p-1.5"
            >
              {overflowItems.map(({ key, label, icon: Icon, tone, run }, index) => {
                const className = `rounded-control text-body-sm hover:bg-surface-muted focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none ${tone === 'danger' ? 'text-danger' : tone === 'warning' ? 'text-warning' : tone === 'success' ? 'text-success' : 'text-text-primary'}`
                if (key === 'view') {
                  return (
                    <Link
                      key={key}
                      ref={(element) => {
                        itemRefs.current[index] = element
                      }}
                      to="/hr/employees/$userId"
                      params={{ userId: String(employee.user_id) }}
                      role="menuitem"
                      tabIndex={-1}
                      aria-label={`View ${name || employee.employee_id}`}
                      onClick={() => closeMenu()}
                      className={className}
                    >
                      <Icon className="size-4 shrink-0" aria-hidden="true" />
                      {label}
                    </Link>
                  )
                }
                if (key === 'leave') {
                  return (
                    <Link
                      key={key}
                      ref={(element) => {
                        itemRefs.current[index] = element
                      }}
                      to="/hr/employees/$userId"
                      params={{ userId: String(employee.user_id) }}
                      search={{ section: 'leave' }}
                      role="menuitem"
                      tabIndex={-1}
                      aria-label={`${label} for ${name || employee.employee_id}`}
                      onClick={() => closeMenu()}
                      className={className}
                    >
                      <Icon className="size-4 shrink-0" aria-hidden="true" />
                      {label}
                    </Link>
                  )
                }
                return (
                  <button
                    key={key}
                    ref={(element) => {
                      itemRefs.current[index] = element
                    }}
                    type="button"
                    role="menuitem"
                    tabIndex={-1}
                    onClick={() => {
                      closeMenu()
                      run?.()
                      if (key === 'edit') onEdit(employee)
                    }}
                    className={className}
                  >
                    <Icon className="size-4 shrink-0" aria-hidden="true" />
                    {label}
                  </button>
                )
              })}
            </div>,
            document.body,
          )
        : null}
    </>
  )
}

export type { EmployeeStatusAction }
