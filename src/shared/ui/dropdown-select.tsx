import {
  useCallback,
  useEffect,
  useId,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
  type KeyboardEvent,
  type ReactNode,
} from 'react'
import { createPortal } from 'react-dom'
import { Check, ChevronDown, Search } from 'lucide-react'

import { cn } from '@/shared/lib/cn'
import { CONTROL_SIZE_CLASSES } from '@/shared/ui/control-sizing'

export type DropdownSelectOption = {
  value: string
  label: string
  description?: string
  icon?: ReactNode
  iconClassName?: string
  disabled?: boolean
}

export type DropdownSelectProps = {
  id?: string
  label?: string
  value: string
  options: DropdownSelectOption[]
  onChange: (value: string) => void
  placeholder?: string
  'aria-label'?: string
  disabled?: boolean
  required?: boolean
  'aria-describedby'?: string
  'aria-invalid'?: boolean | 'true' | 'false'
  'aria-required'?: boolean | 'true' | 'false'
  searchable?: boolean
  menuMinWidth?: number
  searchPlaceholder?: string
  emptyMessage?: string
  className?: string
}

type DropdownMenuPosition = {
  position: 'absolute' | 'fixed'
  top: number
  left: number
  width: number
  maxHeight: number
  optionListMaxHeight: number
  zIndex: number
}

function menuPosition(
  trigger: HTMLElement,
  optionCount: number,
  searchable: boolean,
  menuMinWidth: number,
): DropdownMenuPosition {
  const rect = trigger.getBoundingClientRect()
  const viewportPadding = 8
  const dialog = trigger.closest('dialog[open]')
  const dialogRect = dialog?.getBoundingClientRect()
  const dialogBorder = dialog ? Math.max(dialog.clientLeft, 1) : 0
  const dialogTopBorder = dialog ? Math.max(dialog.clientTop, 1) : 0
  const bounds = dialogRect
    ? {
        top: dialogRect.top + dialogTopBorder,
        right: dialogRect.right - dialogBorder,
        bottom: dialogRect.bottom - dialogTopBorder,
        left: dialogRect.left + dialogBorder,
      }
    : {
        top: viewportPadding,
        right: window.innerWidth - viewportPadding,
        bottom: window.innerHeight - viewportPadding,
        left: viewportPadding,
      }
  const estimatedHeight = Math.min(288, Math.max(48, optionCount * 40 + (searchable ? 48 : 8)))
  const spaceAbove = Math.max(0, rect.top - bounds.top - 4)
  const spaceBelow = Math.max(0, bounds.bottom - rect.bottom - 4)
  const openAbove =
    spaceBelow < estimatedHeight && (spaceAbove >= estimatedHeight || spaceAbove > spaceBelow)
  const availableHeight = openAbove ? spaceAbove : spaceBelow
  const maxHeight = Math.max(40, Math.min(estimatedHeight, availableHeight))
  const width = Math.min(Math.max(rect.width, menuMinWidth), bounds.right - bounds.left)
  const left = Math.min(Math.max(bounds.left, rect.left), bounds.right - width)
  const viewportTop = openAbove ? rect.top - maxHeight - 4 : rect.bottom + 4

  return {
    // A transformed native dialog creates a containing block for fixed
    // descendants, so dialog menus use local absolute coordinates and stay
    // inside the clipped dialog surface.
    position: dialog ? 'absolute' : 'fixed',
    top: dialogRect ? viewportTop - dialogRect.top - dialogTopBorder : viewportTop,
    left: dialogRect ? left - dialogRect.left - dialogBorder : left,
    width,
    maxHeight,
    optionListMaxHeight: Math.max(32, maxHeight - (searchable ? 48 : 8)),
    zIndex: 200,
  }
}

export function DropdownSelect({
  id,
  label,
  value,
  options,
  onChange,
  placeholder = 'Select an option',
  'aria-label': ariaLabel,
  disabled = false,
  required = false,
  'aria-describedby': describedBy,
  'aria-invalid': invalid,
  'aria-required': ariaRequired,
  searchable,
  menuMinWidth = 0,
  searchPlaceholder = 'Search options',
  emptyMessage = 'No options found.',
  className,
}: DropdownSelectProps) {
  const generatedId = useId()
  const controlId = id ?? `dropdown-${generatedId}`
  const labelId = `${controlId}-label`
  const valueId = `${controlId}-value`
  const listboxId = `${controlId}-options`
  const rootRef = useRef<HTMLDivElement>(null)
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const searchRef = useRef<HTMLInputElement>(null)
  const optionRefs = useRef<Array<HTMLButtonElement | null>>([])
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [position, setPosition] = useState<DropdownMenuPosition | null>(null)
  const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null)
  const isSearchable = searchable ?? options.length >= 7
  const selectedIndex = options.findIndex((option) => option.value === value)
  const selectedOption = selectedIndex >= 0 ? options[selectedIndex] : undefined
  const filteredOptions = useMemo(() => {
    const query = search.trim().toLocaleLowerCase()
    if (!query) return options
    return options.filter((option) =>
      `${option.label} ${option.description ?? ''}`.toLocaleLowerCase().includes(query),
    )
  }, [options, search])

  const closeMenu = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPosition(null)
    setPortalContainer(null)
    setSearch('')
    if (restoreFocus) requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  const openMenu = (initialIndex = selectedIndex) => {
    const trigger = triggerRef.current
    if (!trigger || disabled) return
    setPortalContainer(trigger.closest('dialog[open]') ?? document.body)
    setPosition(menuPosition(trigger, options.length, isSearchable, menuMinWidth))
    setOpen(true)
    requestAnimationFrame(() => {
      if (isSearchable) {
        searchRef.current?.focus()
      } else {
        const firstEnabled = options.findIndex(
          (option, index) => index >= Math.max(0, initialIndex) && !option.disabled,
        )
        const fallback = options.findIndex((option) => !option.disabled)
        optionRefs.current[firstEnabled >= 0 ? firstEnabled : fallback]?.focus()
      }
    })
  }

  const toggleMenu = () => {
    if (disabled) return
    if (open) closeMenu()
    else openMenu()
  }

  useLayoutEffect(() => {
    if (!open || !triggerRef.current) return
    setPosition(
      menuPosition(triggerRef.current, filteredOptions.length, isSearchable, menuMinWidth),
    )
  }, [filteredOptions.length, isSearchable, menuMinWidth, open])

  useEffect(() => {
    if (!open) return

    const handlePointerDown = (event: PointerEvent) => {
      const target = event.target as Node
      if (rootRef.current?.contains(target) || menuRef.current?.contains(target)) return
      closeMenu()
    }
    const reposition = () => {
      if (triggerRef.current) {
        setPosition(
          menuPosition(triggerRef.current, filteredOptions.length, isSearchable, menuMinWidth),
        )
      }
    }

    document.addEventListener('pointerdown', handlePointerDown, true)
    window.addEventListener('resize', reposition)
    window.addEventListener('scroll', reposition, true)
    return () => {
      document.removeEventListener('pointerdown', handlePointerDown, true)
      window.removeEventListener('resize', reposition)
      window.removeEventListener('scroll', reposition, true)
    }
  }, [closeMenu, filteredOptions.length, isSearchable, menuMinWidth, open])

  useEffect(() => {
    if (!open || !isSearchable) return
    searchRef.current?.focus()
  }, [isSearchable, open])

  function focusOption(index: number, direction: -1 | 1 = 1) {
    if (!filteredOptions.length) return
    const enabled = filteredOptions
      .map((option) => ({ option, optionIndex: options.indexOf(option) }))
      .filter(({ option }) => !option.disabled)
    if (!enabled.length) return
    const current = enabled.findIndex(({ optionIndex }) => optionIndex === index)
    const next =
      index < 0
        ? enabled[0]
        : !Number.isFinite(index) || index >= options.length
          ? enabled[enabled.length - 1]
          : current >= 0
            ? enabled[(current + direction + enabled.length) % enabled.length]
            : direction > 0
              ? (enabled.find(({ optionIndex }) => optionIndex > index) ?? enabled[0])
              : ([...enabled].reverse().find(({ optionIndex }) => optionIndex < index) ??
                enabled[enabled.length - 1])
    optionRefs.current[options.indexOf(next.option)]?.focus()
  }

  function handleMenuKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    const focusedIndex = options.findIndex(
      (_, index) => optionRefs.current[index] === document.activeElement,
    )
    if (event.key === 'Escape') {
      event.preventDefault()
      closeMenu(true)
    } else if (event.key === 'ArrowDown') {
      event.preventDefault()
      focusOption(focusedIndex < 0 ? -1 : focusedIndex, 1)
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      focusOption(focusedIndex < 0 ? Number.POSITIVE_INFINITY : focusedIndex, -1)
    } else if (event.key === 'Home') {
      event.preventDefault()
      focusOption(-1)
    } else if (event.key === 'End') {
      event.preventDefault()
      focusOption(Number.POSITIVE_INFINITY, -1)
    } else if ((event.key === 'Enter' || event.key === ' ') && focusedIndex >= 0) {
      event.preventDefault()
      optionRefs.current[focusedIndex]?.click()
    } else if (event.key === 'Tab') {
      closeMenu()
    }
  }

  const menu =
    open && position ? (
      <div
        ref={menuRef}
        id={listboxId}
        role="listbox"
        data-dropdown-menu=""
        aria-labelledby={label ? `${labelId} ${valueId}` : undefined}
        aria-label={!label ? (ariaLabel ?? selectedOption?.label ?? placeholder) : undefined}
        className="border-border-subtle bg-surface shadow-elevation-lg rounded-control overflow-hidden border p-1"
        style={{
          position: position.position,
          top: position.top,
          left: position.left,
          width: position.width,
          maxHeight: position.maxHeight,
          zIndex: position.zIndex,
        }}
        onKeyDown={handleMenuKeyDown}
      >
        {isSearchable ? (
          <div className="border-border-subtle bg-surface-muted/60 rounded-control mx-1 mt-1 mb-1 flex items-center gap-2 border px-2.5">
            <Search className="text-text-muted size-3.5 shrink-0" aria-hidden="true" />
            <input
              ref={searchRef}
              type="search"
              value={search}
              placeholder={searchPlaceholder}
              aria-label={searchPlaceholder}
              className="text-caption text-text-primary placeholder:text-text-muted min-h-8 min-w-0 flex-1 bg-transparent outline-none"
              onChange={(event) => setSearch(event.currentTarget.value)}
              onKeyDown={(event: KeyboardEvent<HTMLInputElement>) => {
                if (event.key === 'ArrowDown') {
                  event.preventDefault()
                  focusOption(-1, 1)
                }
                if (event.key === 'ArrowUp') {
                  event.preventDefault()
                  focusOption(Number.POSITIVE_INFINITY, -1)
                }
                if (event.key === 'Escape') {
                  event.preventDefault()
                  closeMenu(true)
                }
              }}
            />
          </div>
        ) : null}
        <div
          className="max-h-64 overflow-y-auto"
          role="presentation"
          style={{ maxHeight: position.optionListMaxHeight }}
        >
          {filteredOptions.length ? (
            filteredOptions.map((option) => {
              const optionIndex = options.indexOf(option)
              const selected = option.value === value
              return (
                <button
                  key={option.value}
                  ref={(node) => {
                    optionRefs.current[optionIndex] = node
                  }}
                  type="button"
                  role="option"
                  aria-selected={selected}
                  disabled={option.disabled}
                  tabIndex={-1}
                  className={cn(
                    'text-body-sm rounded-control flex min-h-10 w-full items-center gap-2.5 px-3 py-2 text-left transition-colors disabled:cursor-not-allowed disabled:opacity-50',
                    selected
                      ? 'bg-primary-subtle text-primary font-semibold'
                      : 'text-text-secondary hover:bg-surface-muted hover:text-text-primary',
                  )}
                  onClick={() => {
                    if (option.disabled) return
                    onChange(option.value)
                    closeMenu(true)
                  }}
                >
                  <span
                    className="flex size-4 shrink-0 items-center justify-center"
                    aria-hidden="true"
                  >
                    {selected ? <Check className="size-3.5" /> : null}
                  </span>
                  {option.icon ? (
                    <span
                      className={cn(
                        'flex size-4 shrink-0 items-center justify-center',
                        option.iconClassName,
                      )}
                    >
                      {option.icon}
                    </span>
                  ) : null}
                  <span className="min-w-0 flex-1">
                    <span className="block leading-snug break-words whitespace-normal">
                      {option.label}
                    </span>
                    {option.description ? (
                      <span className="text-caption text-text-muted mt-0.5 block leading-snug font-normal break-words whitespace-normal">
                        {option.description}
                      </span>
                    ) : null}
                  </span>
                </button>
              )
            })
          ) : (
            <p className="text-caption text-text-muted px-3 py-3">{emptyMessage}</p>
          )}
        </div>
      </div>
    ) : null

  return (
    <div ref={rootRef} className={cn('min-w-0', className)}>
      {label ? (
        <label
          id={labelId}
          htmlFor={controlId}
          className="text-control-label text-text-secondary mb-1.5 block font-bold"
        >
          {label}
        </label>
      ) : null}
      <button
        ref={triggerRef}
        id={controlId}
        type="button"
        role="combobox"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-controls={open ? listboxId : undefined}
        aria-labelledby={label ? `${labelId} ${valueId}` : undefined}
        aria-label={ariaLabel}
        aria-disabled={disabled || undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid}
        aria-required={required || ariaRequired || undefined}
        disabled={disabled}
        className={cn(
          'border-border-subtle bg-surface text-text-primary hover:border-border-strong focus-visible:shadow-focus-ring rounded-control focus-visible:border-primary flex w-full items-center justify-between gap-2.5 border text-left font-medium transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50',
          CONTROL_SIZE_CLASSES,
          open && 'border-primary shadow-focus-ring',
        )}
        onClick={toggleMenu}
        onKeyDown={(event) => {
          if (
            event.key === 'ArrowDown' ||
            event.key === 'ArrowUp' ||
            event.key === 'Enter' ||
            event.key === ' '
          ) {
            event.preventDefault()
            if (open) optionRefs.current[selectedIndex]?.focus()
            else openMenu()
          } else if (event.key === 'Escape' && open) {
            event.preventDefault()
            closeMenu(true)
          }
        }}
      >
        {selectedOption?.icon ? (
          <span
            className={cn(
              'flex size-4 shrink-0 items-center justify-center',
              selectedOption.iconClassName,
            )}
            aria-hidden="true"
          >
            {selectedOption.icon}
          </span>
        ) : null}
        <span
          id={valueId}
          className={cn('min-w-0 flex-1 truncate', !selectedOption && 'text-text-muted')}
        >
          {selectedOption?.label ?? placeholder}
        </span>
        <ChevronDown
          className={cn(
            'text-text-muted size-4 shrink-0 transition-transform',
            open && 'rotate-180',
          )}
          aria-hidden="true"
        />
      </button>
      {portalContainer && menu ? createPortal(menu, portalContainer) : null}
    </div>
  )
}
