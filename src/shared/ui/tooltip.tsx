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
  const existingDescription = children.props['aria-describedby']
  const describedBy = [existingDescription, tooltipId].filter(Boolean).join(' ')
  const child = cloneElement(children, { 'aria-describedby': describedBy })

  const updatePosition = useCallback(() => {
    const trigger = triggerRef.current
    const tooltip = tooltipRef.current
    if (!trigger || !tooltip) return

    const viewportWidth = document.documentElement.clientWidth
    const viewportHeight = document.documentElement.clientHeight
    tooltip.style.maxWidth = `${Math.max(0, viewportWidth - 16)}px`
    const triggerRect = trigger.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    const gutter = 8
    const leftForRight = triggerRect.right + gutter
    const rightFits = leftForRight + tooltipRect.width <= viewportWidth - gutter
    const left =
      placement === 'right'
        ? rightFits
          ? leftForRight
          : Math.max(gutter, triggerRect.left - tooltipRect.width - gutter)
        : Math.max(
            gutter,
            Math.min(
              triggerRect.left + triggerRect.width / 2 - tooltipRect.width / 2,
              viewportWidth - tooltipRect.width - gutter,
            ),
          )
    const topAbove = triggerRect.top - tooltipRect.height - gutter
    const topBelow = triggerRect.bottom + gutter
    const aboveFits = topAbove >= gutter
    const belowFits = topBelow + tooltipRect.height <= viewportHeight - gutter
    const useAbove =
      placement === 'right'
        ? false
        : placement === 'top'
          ? aboveFits || !belowFits
          : !belowFits && aboveFits

    const top =
      placement === 'right'
        ? Math.max(
            gutter,
            Math.min(
              triggerRect.top + triggerRect.height / 2 - tooltipRect.height / 2,
              viewportHeight - tooltipRect.height - gutter,
            ),
          )
        : useAbove
          ? Math.max(gutter, topAbove)
          : Math.min(topBelow, viewportHeight - tooltipRect.height - gutter)
    setPosition({ left, top })
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
        showTimerRef.current = setTimeout(() => setVisible(true), showDelayMs)
      }}
      onPointerLeave={() => {
        clearShowTimer()
        setVisible(false)
      }}
      onFocus={() => {
        clearShowTimer()
        setVisible(true)
      }}
      onBlur={handleBlur}
    >
      {child}
      <span
        ref={tooltipRef}
        id={tooltipId}
        role="tooltip"
        style={{
          position: 'fixed',
          width: 'max-content',
          visibility: visible ? 'visible' : 'hidden',
          opacity: visible ? 1 : 0,
          ...position,
        }}
        className="z-tooltip text-caption shadow-elevation-md rounded-control pointer-events-none border border-neutral-700 bg-neutral-900 px-3 py-2 text-white transition-opacity"
      >
        {content}
      </span>
    </span>
  )
}
