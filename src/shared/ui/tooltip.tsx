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
} from 'react'

import { cn } from '@/shared/lib/cn'

type TooltipChildProps = { 'aria-describedby'?: string }

interface TooltipProps {
  content: string
  children: ReactElement<TooltipChildProps>
  className?: string
  placement?: 'top' | 'bottom'
}

export function Tooltip({
  content,
  children,
  className,
  placement = 'top',
}: TooltipProps) {
  const tooltipId = useId()
  const triggerRef = useRef<HTMLSpanElement>(null)
  const tooltipRef = useRef<HTMLSpanElement>(null)
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
    const left = Math.max(
      gutter,
      Math.min(
        triggerRect.left + triggerRect.width / 2 - tooltipRect.width / 2,
        viewportWidth - tooltipRect.width - gutter,
      ),
    )
    const topAbove = triggerRect.top - tooltipRect.height - gutter
    const topBelow = triggerRect.bottom + gutter
    const useAbove = placement === 'top' ? topAbove >= gutter : topBelow + tooltipRect.height > viewportHeight - gutter

    setPosition({ left, top: useAbove ? Math.max(gutter, topAbove) : topBelow })
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

  return (
    <span
      ref={triggerRef}
      className={cn('inline-flex', className)}
      onPointerEnter={() => setVisible(true)}
      onPointerLeave={() => setVisible(false)}
      onFocus={() => setVisible(true)}
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
        className="pointer-events-none z-tooltip rounded-sm bg-neutral-900 px-2 py-1 text-caption text-white shadow-elevation-md transition-opacity"
      >
        {content}
      </span>
    </span>
  )
}
