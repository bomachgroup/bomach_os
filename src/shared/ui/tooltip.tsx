import {
  cloneElement,
  useCallback,
  useId,
  useLayoutEffect,
  useRef,
  useState,
  type CSSProperties,
  type FocusEvent,
  type ReactElement,
  type ReactNode,
} from 'react'
import { createPortal } from 'react-dom'

import { cn } from '@/shared/lib/cn'

type TooltipChildProps = { 'aria-describedby'?: string }

interface TooltipProps {
  content: ReactNode
  children: ReactElement<TooltipChildProps>
  className?: string
  placement?: 'top' | 'bottom' | 'right'
  showDelayMs?: number
}

export function Tooltip({
  content,
  children,
  className,
  placement = 'top',
  showDelayMs = 250,
}: TooltipProps) {
  const tooltipId = useId()
  const triggerRef = useRef<HTMLSpanElement>(null)
  const tooltipRef = useRef<HTMLSpanElement>(null)
  const showTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const [visible, setVisible] = useState(false)
  const [position, setPosition] = useState<CSSProperties>({})
  const [portalTarget, setPortalTarget] = useState<HTMLElement | null>(null)
  const existingDescription = children.props['aria-describedby']
  const describedBy =
    [existingDescription, portalTarget ? tooltipId : null].filter(Boolean).join(' ') || undefined
  const child = cloneElement(children, { 'aria-describedby': describedBy })

  const updatePosition = useCallback(() => {
    const trigger = triggerRef.current
    const tooltip = tooltipRef.current
    if (!trigger || !tooltip) return

    const viewportWidth = document.documentElement.clientWidth
    const viewportHeight = document.documentElement.clientHeight
    const dialog = trigger.closest('dialog')
    const dialogRect = dialog?.getBoundingClientRect()
    const dialogClientLeft = dialog?.clientLeft ?? 0
    const dialogClientTop = dialog?.clientTop ?? 0
    const originLeft = dialogRect ? dialogRect.left + dialogClientLeft : 0
    const originTop = dialogRect ? dialogRect.top + dialogClientTop : 0
    const gutter = 8
    const bounds = dialogRect
      ? {
          left: dialogRect.left + dialogClientLeft + gutter,
          top: dialogRect.top + dialogClientTop + gutter,
          right: dialogRect.right - dialogClientLeft - gutter,
          bottom: dialogRect.bottom - dialogClientTop - gutter,
        }
      : {
          left: gutter,
          top: gutter,
          right: viewportWidth - gutter,
          bottom: viewportHeight - gutter,
        }
    tooltip.style.maxWidth = `${Math.max(0, Math.min(viewportWidth - 2 * gutter, bounds.right - bounds.left))}px`
    const triggerRect = trigger.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    const leftForRight = triggerRect.right + gutter
    const rightFits = leftForRight + tooltipRect.width <= bounds.right
    const desiredLeft =
      placement === 'right'
        ? rightFits
          ? leftForRight
          : triggerRect.left - tooltipRect.width - gutter
        : Math.max(
            bounds.left,
            Math.min(
              triggerRect.left + triggerRect.width / 2 - tooltipRect.width / 2,
              bounds.right - tooltipRect.width,
            ),
          )
    const left = Math.max(bounds.left, Math.min(desiredLeft, bounds.right - tooltipRect.width))
    const topAbove = triggerRect.top - tooltipRect.height - gutter
    const topBelow = triggerRect.bottom + gutter
    const aboveFits = topAbove >= bounds.top
    const belowFits = topBelow + tooltipRect.height <= bounds.bottom
    const useAbove =
      placement === 'right'
        ? false
        : placement === 'top'
          ? aboveFits || !belowFits
          : !belowFits && aboveFits

    const desiredTop =
      placement === 'right'
        ? Math.max(
            bounds.top,
            Math.min(
              triggerRect.top + triggerRect.height / 2 - tooltipRect.height / 2,
              bounds.bottom - tooltipRect.height,
            ),
          )
        : useAbove
          ? topAbove
          : topBelow
    const top = Math.max(bounds.top, Math.min(desiredTop, bounds.bottom - tooltipRect.height))
    setPosition({ left: left - originLeft, top: top - originTop })
  }, [placement])

  useLayoutEffect(() => {
    if (!visible) return
    updatePosition()
    window.addEventListener('resize', updatePosition)
    window.addEventListener('scroll', updatePosition, true)
    return () => {
      window.removeEventListener('resize', updatePosition)
      window.removeEventListener('scroll', updatePosition, true)
    }
  }, [visible, updatePosition])

  function handleBlur(event: FocusEvent<HTMLSpanElement>) {
    const nextTarget = event.relatedTarget
    if (!(nextTarget instanceof Node) || !event.currentTarget.contains(nextTarget)) {
      setVisible(false)
    }
  }

  function clearShowTimer() {
    if (showTimerRef.current !== null) {
      clearTimeout(showTimerRef.current)
      showTimerRef.current = null
    }
  }

  function revealTooltip() {
    setPortalTarget(
      (currentTarget) => currentTarget ?? triggerRef.current?.closest('dialog') ?? document.body,
    )
    setVisible(true)
  }

  useLayoutEffect(
    () => () => {
      if (showTimerRef.current !== null) clearTimeout(showTimerRef.current)
    },
    [],
  )

  return (
    <span
      ref={triggerRef}
      className={cn('inline-flex', className)}
      onPointerEnter={(event) => {
        if (event.pointerType === 'touch') return
        clearShowTimer()
        showTimerRef.current = setTimeout(revealTooltip, showDelayMs)
      }}
      onPointerLeave={() => {
        clearShowTimer()
        setVisible(false)
      }}
      onFocus={() => {
        clearShowTimer()
        revealTooltip()
      }}
      onBlur={handleBlur}
    >
      {child}
      {portalTarget
        ? createPortal(
            <span
              ref={tooltipRef}
              id={tooltipId}
              role="tooltip"
              style={{
                position: 'fixed',
                width: 'max-content',
                display: visible ? 'block' : 'none',
                visibility: visible ? 'visible' : 'hidden',
                opacity: visible ? 1 : 0,
                ...position,
              }}
              className="z-tooltip text-caption shadow-elevation-md rounded-control pointer-events-none border border-neutral-700 bg-neutral-900 px-3 py-2 text-white transition-opacity"
            >
              {content}
            </span>,
            portalTarget,
          )
        : null}
    </span>
  )
}
