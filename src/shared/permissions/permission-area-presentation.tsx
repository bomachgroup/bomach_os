import {
  BriefcaseBusiness,
  Building2,
  CalendarClock,
  CircleDollarSign,
  Handshake,
  ShieldCheck,
  UsersRound,
  Workflow,
} from 'lucide-react'

const permissionAreaPresentations = {
  people: { icon: UsersRound, tone: 'bg-primary-subtle text-primary' },
  roles: { icon: BriefcaseBusiness, tone: 'bg-info-subtle text-info-foreground' },
  attendance: { icon: CalendarClock, tone: 'bg-success-subtle text-success-foreground' },
  finance: { icon: CircleDollarSign, tone: 'bg-warning-subtle text-warning-foreground' },
  operations: { icon: Workflow, tone: 'bg-primary-subtle text-primary' },
  services: { icon: Handshake, tone: 'bg-info-subtle text-info-foreground' },
  governance: { icon: Building2, tone: 'bg-surface-muted text-text-secondary' },
  other: { icon: ShieldCheck, tone: 'bg-surface-muted text-text-secondary' },
}

export function getPermissionAreaPresentation(areaId: string) {
  return (
    permissionAreaPresentations[areaId as keyof typeof permissionAreaPresentations] ??
    permissionAreaPresentations.other
  )
}
