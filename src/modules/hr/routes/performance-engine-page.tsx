import {
  Activity,
  ArrowDownUp,
  Award,
  BellRing,
  Blocks,
  ChartNoAxesCombined,
  ClipboardList,
  GitBranch,
  Layers3,
  Network,
  ShieldCheck,
  UsersRound,
} from 'lucide-react'

import { Alert } from '@/shared/ui/alert'
import { Card } from '@/shared/ui/card'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'

const CAPABILITIES = [
  {
    title: 'Performance control tower',
    group: 'Management overview',
    icon: ChartNoAxesCombined,
    description:
      'A company-wide view of average performance, achievement, employees needing attention, and team trends.',
    details: [
      'Department and branch summaries',
      'At-risk and achieved indicators',
      'Manager intervention queue',
    ],
  },
  {
    title: 'Target cascade',
    group: 'Targets and measurement',
    icon: GitBranch,
    description:
      'Trace strategy from company objectives through teams, roles, and individual work.',
    details: [
      'Role-level target inheritance',
      'Proration and dependencies',
      'Controlled target overrides',
    ],
  },
  {
    title: 'Role library',
    group: 'Role foundations',
    icon: UsersRound,
    description:
      'Maintain role templates that preserve expectations and operating knowledge as people change.',
    details: [
      'Role-specific KPI packs',
      'Mission and core routines',
      'Quality thresholds and dependencies',
    ],
  },
  {
    title: 'Target and KPI designer',
    group: 'Targets and measurement',
    icon: ClipboardList,
    description:
      'Define measurable outcomes, cadence, weights, quality gates, and the rules behind each target.',
    details: [
      'Daily through annual cadence',
      'Weighted measures',
      'Proration and quality controls',
    ],
  },
  {
    title: 'Secondary assignments',
    group: 'Role foundations',
    icon: Layers3,
    description:
      'Represent temporary project, team, or acting responsibilities without replacing a person’s primary role.',
    details: [
      'Assignment type and weighting',
      'Expiry and review dates',
      'Promote a proven assignment into a role template',
    ],
  },
  {
    title: 'Role continuity packs',
    group: 'Role foundations',
    icon: ShieldCheck,
    description:
      'Give a replacement the operating context needed to continue work without relying on the former role holder.',
    details: [
      'Core procedures and tools',
      'Approvals and escalation paths',
      'Structured first-days handover',
    ],
  },
  {
    title: 'Employee scorecards',
    group: 'Targets and measurement',
    icon: Activity,
    description:
      'Combine role targets, assignments, verified source data, and approved exceptions into a period view.',
    details: [
      'Target and achievement breakdown',
      'Period-over-period trend',
      'Performance bands and applicable adjustments',
    ],
  },
  {
    title: 'Appraisal and rewards',
    group: 'Review and action',
    icon: Award,
    description:
      'Support consistent appraisals and reward recommendations with policy checks before any compensation action.',
    details: [
      'Defined achievement bands',
      'Recognition and accountability signals',
      'Separate HR and Finance approval',
    ],
  },
  {
    title: 'Next actions',
    group: 'Review and action',
    icon: BellRing,
    description:
      'Identify off-track measures early and turn verified blockers into practical employee guidance and manager follow-up.',
    details: [
      'Early risk indicators',
      'Dependency-aware context',
      'Employee and manager action queues',
    ],
  },
  {
    title: 'Module data bridge',
    group: 'Data foundations',
    icon: Network,
    description:
      'Keep operational modules as the source of actual work while sharing evidence-backed results with performance tracking.',
    details: [
      'Source events and evidence references',
      'Controlled ingestion by module',
      'Recalculation from verified actuals',
    ],
  },
]

function CapabilityCard({
  title,
  group,
  icon: Icon,
  description,
  details,
  index,
}: (typeof CAPABILITIES)[number] & { index: number }) {
  return (
    <Card className="tablet:p-5 flex min-w-0 flex-col p-4">
      <div className="flex items-start gap-3">
        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
          <Icon className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <p className="text-overline text-primary font-semibold">{group}</p>
          <h2 className="text-label text-text-primary mt-1 font-semibold">{title}</h2>
        </div>
        <StatusChip label="Planned" tone="neutral" dense />
      </div>
      <p className="text-body-sm text-text-secondary mt-4 leading-relaxed">{description}</p>
      <ul className="border-border-subtle mt-4 space-y-2 border-t pt-3">
        {details.map((detail) => (
          <li key={`${index}-${detail}`} className="text-caption text-text-secondary flex gap-2">
            <span className="bg-primary mt-1.5 size-1.5 shrink-0 rounded-full" aria-hidden="true" />
            <span>{detail}</span>
          </li>
        ))}
      </ul>
    </Card>
  )
}

export function PerformanceEnginePage() {
  return (
    <PageLayout
      title="Performance Engine"
      subtitle="A planned framework for role expectations, targets, scorecards, and review decisions."
      leading={<Blocks className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="from-primary-subtle/70 to-surface tablet:p-7 overflow-hidden bg-gradient-to-br p-5">
          <div className="tablet:flex-row tablet:items-center tablet:justify-between flex min-w-0 flex-col gap-5">
            <div className="tablet:flex-row tablet:items-start tablet:gap-4 flex min-w-0 flex-col items-start gap-3">
              <span className="bg-surface text-primary shadow-elevation-sm flex size-12 shrink-0 items-center justify-center rounded-2xl">
                <ArrowDownUp className="size-6" aria-hidden="true" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-primary font-semibold">Capability roadmap</p>
                <h2 className="text-h2 text-text-primary mt-1 font-semibold">
                  One system for clear, evidence-based performance
                </h2>
                <p className="text-body-sm text-text-secondary mt-2 max-w-3xl leading-relaxed">
                  The roadmap below describes intended capabilities. They are not connected to live
                  records yet; no scores, recommendations, or actions are being generated here.
                </p>
              </div>
            </div>
            <StatusChip label="Not live yet" tone="warning" />
          </div>
        </Card>

        <Alert tone="warning" title="Performance Engine APIs are not available">
          The current backend does not provide the role-target, actuals, assignment, or appraisal
          services needed to power this workspace. Existing Monthly Scorecard and Employee
          Evaluation pages continue to use their separate supported APIs.
        </Alert>

        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 className="text-h3 text-text-primary font-semibold">Planned capabilities</h2>
            <p className="text-caption text-text-secondary mt-1">
              Ten connected areas, grouped by how performance work is managed.
            </p>
          </div>
          <StatusChip label={`${CAPABILITIES.length} roadmap areas`} tone="neutral" />
        </div>

        <div className="tablet:grid-cols-2 desktop:grid-cols-3 grid min-w-0 gap-3">
          {CAPABILITIES.map((capability, index) => (
            <CapabilityCard key={capability.title} {...capability} index={index} />
          ))}
        </div>
      </div>
    </PageLayout>
  )
}
