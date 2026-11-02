import type { StatusTone } from '@/shared/ui/status-chip'

import type { NotificationTone } from './notification-presentation'

export const notificationToneClasses: Record<
  NotificationTone,
  {
    surface: string
    border: string
    rail: string
    icon: string
    chip: string
    chipTone: StatusTone
  }
> = {
  success: {
    surface: 'bg-success-subtle/20',
    border: 'border-success/30',
    rail: 'bg-success',
    icon: 'bg-success-subtle text-success-foreground',
    chip: 'bg-success-subtle text-success-foreground',
    chipTone: 'success',
  },
  warning: {
    surface: 'bg-warning-subtle/25',
    border: 'border-warning/35',
    rail: 'bg-warning',
    icon: 'bg-warning-subtle text-warning-foreground',
    chip: 'bg-warning-subtle text-warning-foreground',
    chipTone: 'warning',
  },
  danger: {
    surface: 'bg-danger-subtle/20',
    border: 'border-danger/35',
    rail: 'bg-danger',
    icon: 'bg-danger-subtle text-danger-foreground',
    chip: 'bg-danger-subtle text-danger-foreground',
    chipTone: 'danger',
  },
  info: {
    surface: 'bg-info-subtle/20',
    border: 'border-info/30',
    rail: 'bg-info',
    icon: 'bg-info-subtle text-info-foreground',
    chip: 'bg-info-subtle text-info-foreground',
    chipTone: 'info',
  },
  neutral: {
    surface: 'bg-surface',
    border: 'border-border-subtle',
    rail: 'bg-neutral-300',
    icon: 'bg-surface-muted text-text-secondary',
    chip: 'bg-surface-muted text-text-secondary',
    chipTone: 'neutral',
  },
}
