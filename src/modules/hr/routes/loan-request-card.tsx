import {
  Banknote,
  Briefcase,
  CalendarDays,
  Check,
  Clock3,
  ExternalLink,
  Pencil,
  UserRound,
  X,
} from 'lucide-react'
import type { ReactNode } from 'react'

import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { StatusChip } from '@/shared/ui/status-chip'

import type { LoanListItem } from '../loans.api'
import { formatLoanCurrency, formatLoanDate, loanStatusTone } from '../loans.presentation'

function LoanFact({ icon, label, value }: { icon: ReactNode; label: string; value: string }) {
  return (
    <div className="min-w-0">
      <dt className="text-caption text-text-secondary flex items-center gap-1.5">
        <span className="text-primary" aria-hidden="true">
          {icon}
        </span>
        {label}
      </dt>
      <dd className="text-body-sm text-text-primary mt-1 break-words">{value}</dd>
    </div>
  )
}

export function LoanRequestCard({
  loan,
  personal = false,
  isOwn,
  canView,
  canUpdate,
  canApprove,
  canReject,
  onView,
  onEdit,
  onDecision,
}: {
  loan: LoanListItem
  personal?: boolean
  isOwn: boolean
  canView: boolean
  canUpdate: boolean
  canApprove: boolean
  canReject: boolean
  onView: () => void
  onEdit: () => void
  onDecision: (loan: LoanListItem, status: 'approved' | 'rejected') => void
}) {
  const status = loan.status.toLocaleLowerCase()
  const isPending = status === 'pending'
  const canEdit = canView && canUpdate && isOwn && isPending
  const canReview = !isOwn && isPending && (canApprove || canReject)
  const jobTitle = loan.job_title && loan.job_title !== 'N/A' ? loan.job_title : 'Not provided'

  return (
    <Card className="min-w-0 overflow-hidden p-0">
      <article className="grid h-full min-w-0 grid-rows-[auto_1fr_auto]">
        <header className="desktop:p-5 flex min-w-0 items-start gap-3 p-4">
          <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
            <UserRound className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <h3 className="text-label text-text-primary font-semibold break-words">
              {personal ? 'Your loan request' : loan.employee_name}
            </h3>
          </div>
          <div className="flex shrink-0 flex-col items-end gap-1.5">
            <StatusChip dense label={status.replaceAll('_', ' ')} tone={loanStatusTone(status)} />
            {!personal && isOwn ? <StatusChip dense label="You" tone="neutral" /> : null}
          </div>
        </header>

        <dl className="phone:grid-cols-2 bg-surface-muted/65 border-border-subtle desktop:px-5 grid min-w-0 grid-cols-1 gap-x-4 gap-y-3 border-y px-4 py-3.5">
          <LoanFact
            icon={<Banknote className="size-3.5" />}
            label="Requested amount"
            value={formatLoanCurrency(loan.loan_amount)}
          />
          <LoanFact
            icon={<CalendarDays className="size-3.5" />}
            label="Planned repayment"
            value={formatLoanDate(loan.repayment_date)}
          />
          <LoanFact icon={<Briefcase className="size-3.5" />} label="Role" value={jobTitle} />
          <LoanFact
            icon={<Clock3 className="size-3.5" />}
            label="Submitted"
            value={formatLoanDate(loan.created_at)}
          />
        </dl>

        <div className="min-w-0">
          <section className="desktop:px-5 px-4 py-3" aria-label="Loan request reason">
            <h4 className="text-caption text-text-secondary font-semibold">Reason for request</h4>
            <p className="text-body-sm text-text-primary mt-1 line-clamp-2 break-words">
              {loan.reason}
            </p>
          </section>
          <footer className="border-border-subtle desktop:flex-row desktop:items-center desktop:justify-between desktop:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
            <p className="text-caption text-text-muted break-all">
              Request ID <span aria-hidden="true">·</span> #{loan.id}
            </p>
            <div className="flex flex-wrap justify-end gap-2">
              {canView ? (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={onView}
                  leadingIcon={<ExternalLink className="size-4" />}
                >
                  Details
                </Button>
              ) : null}
              {canEdit ? (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={onEdit}
                  leadingIcon={<Pencil className="size-4" />}
                >
                  Edit
                </Button>
              ) : null}
              {canReview && canReject ? (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => onDecision(loan, 'rejected')}
                  leadingIcon={<X className="size-4" />}
                >
                  Reject
                </Button>
              ) : null}
              {canReview && canApprove ? (
                <Button
                  size="sm"
                  onClick={() => onDecision(loan, 'approved')}
                  leadingIcon={<Check className="size-4" />}
                >
                  Approve
                </Button>
              ) : null}
            </div>
          </footer>
        </div>
      </article>
    </Card>
  )
}
