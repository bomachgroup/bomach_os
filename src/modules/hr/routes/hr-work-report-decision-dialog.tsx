import { Check, CircleAlert, X } from 'lucide-react'

import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { FormControl, TextArea } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import type { WorkReport } from '@/modules/work-reports/work-reports.api'

const RATING_OPTIONS = [
  { value: '', label: 'No rating' },
  ...[1, 2, 3, 4, 5].map((rating) => ({ value: String(rating), label: `${rating} / 5` })),
]

type Decision = 'approve' | 'reject'

function displayDate(value: string) {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

export function HRWorkReportDecisionDialog({
  report,
  decision,
  rating,
  feedback,
  busy,
  error,
  confirmAllowed,
  onRatingChange,
  onFeedbackChange,
  onConfirm,
  onClose,
}: {
  report: WorkReport | null
  decision: Decision | null
  rating: string
  feedback: string
  busy: boolean
  error: string
  confirmAllowed: boolean
  onRatingChange: (value: string) => void
  onFeedbackChange: (value: string) => void
  onConfirm: (decision: Decision) => void
  onClose: () => void
}) {
  const isOpen = Boolean(report && decision)
  const isReject = decision === 'reject'
  const employeeName = report?.employeeName?.trim() || `Employee #${report?.employeeId ?? ''}`

  return (
    <Dialog
      open={isOpen}
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
      title={isReject ? 'Reject work report?' : 'Approve work report?'}
      description={
        report ? `${employeeName} · ${displayDate(report.day)}` : 'Confirm your review decision.'
      }
      size="md"
      fitContent
      compactOnMobile
      dismissDisabled={busy}
      footer={
        <div className="flex flex-wrap justify-end gap-2">
          <Button variant="outline" disabled={busy} onClick={onClose}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="hr-work-report-decision-form"
            variant={isReject ? 'danger' : 'primary'}
            isLoading={busy}
            disabled={!report || !decision || !confirmAllowed}
            leadingIcon={
              isReject ? (
                <X className="size-4" aria-hidden="true" />
              ) : (
                <Check className="size-4" aria-hidden="true" />
              )
            }
          >
            {isReject ? 'Reject report' : 'Approve report'}
          </Button>
        </div>
      }
    >
      {report && decision ? (
        <form
          id="hr-work-report-decision-form"
          className="space-y-4"
          noValidate
          onSubmit={(event) => {
            event.preventDefault()
            onConfirm(decision)
          }}
        >
          <FormSection className="space-y-4">
            <div className="flex items-start gap-3">
              <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                {isReject ? (
                  <CircleAlert className="size-5" aria-hidden="true" />
                ) : (
                  <Check className="size-5" aria-hidden="true" />
                )}
              </span>
              <div>
                <h3 className="text-label font-semibold">Report summary</h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  Confirm the employee and reporting period before recording your decision.
                </p>
              </div>
            </div>
            <div className="border-border-subtle bg-surface rounded-control border p-4">
              <p className="text-body-sm text-text-primary font-semibold">{employeeName}</p>
              <p className="text-caption text-text-secondary mt-1">
                {displayDate(report.day)} · {report.hoursWorked.toFixed(1)} hours
              </p>
            </div>
          </FormSection>
          <FormSection className="space-y-4">
            <div className="flex items-start gap-3">
              <span
                className={
                  isReject
                    ? 'bg-warning-subtle text-warning-foreground rounded-control flex size-10 shrink-0 items-center justify-center'
                    : 'bg-info-subtle text-info-foreground rounded-control flex size-10 shrink-0 items-center justify-center'
                }
              >
                {isReject ? (
                  <CircleAlert className="size-5" aria-hidden="true" />
                ) : (
                  <Check className="size-5" aria-hidden="true" />
                )}
              </span>
              <div>
                <h3 className="text-label font-semibold">
                  {isReject ? 'Request a revision' : 'Approval details'}
                </h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  {isReject
                    ? 'Give the employee clear, actionable feedback for the next submission.'
                    : 'Approval is recorded in the report history. A rating and feedback are optional.'}
                </p>
              </div>
            </div>
            {isReject ? (
              <Alert tone="warning" title="The employee can revise and resubmit">
                Rejecting marks this report as needing revision and sends your feedback to the
                employee.
              </Alert>
            ) : (
              <FormControl id="work-report-rating" label="Rating (optional)">
                <DropdownSelect
                  value={rating}
                  options={RATING_OPTIONS}
                  onChange={onRatingChange}
                  aria-label="Optional work report rating"
                />
              </FormControl>
            )}
            <FormControl
              id="work-report-feedback"
              label={isReject ? 'Reason for rejection' : 'Feedback (optional)'}
              required={isReject}
              description={isReject ? 'Required before rejecting this report.' : undefined}
            >
              <TextArea
                value={feedback}
                onChange={(event) => onFeedbackChange(event.currentTarget.value)}
                maxLength={2000}
                rows={4}
                placeholder={
                  isReject
                    ? 'Explain what needs to be corrected'
                    : 'Share optional context with the employee'
                }
                aria-invalid={isReject && error ? 'true' : undefined}
              />
            </FormControl>
          </FormSection>
          {error ? (
            <Alert tone="danger" title="Decision not saved" role="alert">
              {error}
            </Alert>
          ) : null}
        </form>
      ) : null}
    </Dialog>
  )
}
