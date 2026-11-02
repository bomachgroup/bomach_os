import {
  BadgeCheck,
  Bell,
  Building2,
  CalendarDays,
  ClipboardCheck,
  Clock3,
  FileCheck2,
  FileText,
  Network,
  ShieldAlert,
  Target,
  UsersRound,
  Wallet,
  type LucideIcon,
  type LucideProps,
} from 'lucide-react'

import type { NotificationIconName } from './notification-presentation'

const icons: Record<NotificationIconName, LucideIcon> = {
  bell: Bell,
  calendar: CalendarDays,
  clock: Clock3,
  report: FileCheck2,
  money: Wallet,
  page: FileText,
  people: UsersRound,
  task: ClipboardCheck,
  building: Building2,
  approvals: BadgeCheck,
  warning: ShieldAlert,
  target: Target,
  org: Network,
}

export function NotificationTypeIcon({
  name,
  ...props
}: LucideProps & { name: NotificationIconName }) {
  const Icon = icons[name]
  return <Icon aria-hidden="true" focusable="false" strokeWidth={1.8} {...props} />
}
