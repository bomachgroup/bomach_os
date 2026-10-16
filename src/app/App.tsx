import { useState } from 'react'

import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { ToastProvider, useToast } from '@/shared/feedback/toast-provider'
import {
  EmptyState,
  ErrorState,
  PageSkeleton,
  SectionErrorState,
  SuccessState,
} from '@/shared/ui/feedback-states'
import { FeedbackIcon } from '@/shared/ui/feedback-icon'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageHeader } from '@/shared/ui/page-header'
import { StatusChip } from '@/shared/ui/status-chip'
import { Tooltip } from '@/shared/ui/tooltip'

function FoundationPreview() {
  const [dialogOpen, setDialogOpen] = useState(false)
  const { showToast } = useToast()

  return (
    <main className="min-h-svh bg-background px-4 py-6 text-text-primary tablet:px-6 tablet:py-8 desktop:px-8 desktop:py-10">
      <div className="mx-auto max-w-[1440px] space-y-6">
        <PageHeader
          title="Bomach OS"
          subtitle="Shared foundation preview"
          actions={
            <>
              <Button variant="outline" onClick={() => setDialogOpen(true)}>
                Open responsive dialog
              </Button>
              <Tooltip content="Keyboard users can focus this action to see its hint.">
                <Button
                  variant="ghost"
                  size="icon"
                  aria-label="Help about this preview"
                  onClick={() =>
                    showToast({
                      title: 'Component preview',
                      description: 'This local page is for reviewing shared patterns.',
                    })
                  }
                >
                  <FeedbackIcon name="info" className="size-5" />
                </Button>
              </Tooltip>
            </>
          }
        />

        <Alert tone="info" title="Foundation work in progress">
          This local preview is for reviewing shared visual and interaction patterns. It is not a
          product route and will be replaced by the Bomach shell.
        </Alert>

        <div className="grid items-start gap-5 tablet:grid-cols-2">
          <Card>
            <section className="space-y-4" aria-labelledby="button-preview">
              <div>
                <h2 id="button-preview" className="text-h3 font-semibold">
                  Buttons and focus
                </h2>
                <p className="mt-1 text-body-sm text-text-secondary">
                  Semantic variants, keyboard focus, pending, and disabled states.
                </p>
              </div>
              <div className="flex flex-wrap items-center gap-3">
                <Button>Primary action</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="outline">Outline</Button>
                <Button variant="danger">Destructive</Button>
                <Button disabled>Disabled</Button>
                <Button isLoading>Saving</Button>
              </div>
              <div className="flex flex-wrap gap-2">
                <Button
                  variant="outline"
                  onClick={() =>
                    showToast({
                      title: 'Preview success notification',
                      description: 'This message demonstrates the shared toast style.',
                      tone: 'success',
                    })
                  }
                >
                  Preview success toast
                </Button>
                <Button
                  variant="outline"
                  onClick={() =>
                    showToast({
                      title: 'Preview error notification',
                      description: 'Feature actions choose the message and context.',
                      tone: 'danger',
                    })
                  }
                >
                  Preview error toast
                </Button>
              </div>
            </section>
          </Card>

          <Card>
            <section className="space-y-4" aria-labelledby="form-preview">
              <div>
                <h2 id="form-preview" className="text-h3 font-semibold">
                  Form fields
                </h2>
                <p className="mt-1 text-body-sm text-text-secondary">
                  Labels, help, required markers, and inline validation feedback.
                </p>
              </div>
              <FormControl
                id="company-name-preview"
                label="Company name"
                required
                description="Enter the name used on company records."
              >
                <TextInput placeholder="Enter a company name" />
              </FormControl>
              <FormControl
                id="company-email-preview"
                label="Company email"
                error="Enter a valid email address."
                required
              >
                <TextInput type="email" placeholder="name@example.com" />
              </FormControl>
              <FormControl
                id="company-notes-preview"
                label="Notes"
                description="Long help and validation messages should wrap without clipping."
              >
                <TextArea placeholder="Add notes" />
              </FormControl>
            </section>
          </Card>

          <Card>
            <section className="space-y-4" aria-labelledby="feedback-preview">
              <div>
                <h2 id="feedback-preview" className="text-h3 font-semibold">
                  Alerts and status chips
                </h2>
                <p className="mt-1 text-body-sm text-text-secondary">
                  Persistent feedback and explicit status tone selection.
                </p>
              </div>
              <div className="flex flex-wrap gap-2">
                <StatusChip label="Active" tone="success" />
                <StatusChip label="Pending approval" tone="warning" />
                <StatusChip label="Needs attention" tone="danger" dense />
                <StatusChip label="Information" tone="info" />
                <StatusChip label="Unassigned" />
              </div>
              <Alert tone="warning" title="Review required">
                Keep information that affects the current task visible in the page.
              </Alert>
              <SectionErrorState
                title="A section can be retried"
                description="A section failure does not need to hide the rest of the page."
                onRetry={() =>
                  showToast({ title: 'Retry action preview', tone: 'info' })
                }
              />
            </section>
          </Card>

          <Card className="tablet:col-span-2">
            <section className="space-y-3" aria-labelledby="states-preview">
              <div>
                <h2 id="states-preview" className="text-h3 font-semibold">
                  Empty, error, and success states
                </h2>
                <p className="mt-1 text-body-sm text-text-secondary">
                  Page state components provide layout; the owning feature decides when they apply.
                </p>
              </div>
              <EmptyState
                title="No records yet"
                description="A successful empty result can offer a relevant next action."
                action={<Button size="sm">Create a record</Button>}
                className="min-h-44 rounded-control border border-border-subtle"
              />
              <div className="grid gap-3 desktop:grid-cols-2">
                <ErrorState
                  title="Could not load this page"
                  description="The error view keeps retry or return actions close to the explanation."
                  action={<Button variant="outline" size="sm">Try again</Button>}
                  className="min-h-44 rounded-control border border-border-subtle"
                />
                <SuccessState
                  title="Request completed"
                  description="Use a full success state for a completed workflow with next steps."
                  reference="REQ-2048"
                  action={<Button size="sm">View request</Button>}
                  className="min-h-44 rounded-control border border-border-subtle"
                />
              </div>
            </section>
          </Card>

          <Card className="tablet:col-span-2">
            <section className="space-y-4" aria-labelledby="loading-preview">
              <div>
                <h2 id="loading-preview" className="text-h3 font-semibold">
                  Loading skeleton
                </h2>
                <p className="mt-1 text-body-sm text-text-secondary">
                  Match initial loading placeholders to the page structure and keep reduced-motion
                  preferences respected.
                </p>
              </div>
              <PageSkeleton className="max-w-5xl" />
            </section>
          </Card>
        </div>
      </div>

      <Dialog
        open={dialogOpen}
        onOpenChange={setDialogOpen}
        title="Responsive dialog"
        description="This follows the reviewed Flutter dialog pattern and becomes full-screen below 700px."
        size="md"
        footer={
          <>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={() => setDialogOpen(false)}>Done</Button>
          </>
        }
      >
        <div className="space-y-4">
          <p className="text-body-md text-text-secondary">
            The header and footer stay available while long dialog content scrolls. Escape closes
            the dialog and returns focus to the control that opened it.
          </p>
          <FormControl
            id="dialog-company-name"
            label="Company name"
            description="The field remains usable at narrow widths."
          >
            <TextInput placeholder="Company name" />
          </FormControl>
          <div className="h-48 rounded-control bg-surface-muted p-4 text-body-sm text-text-secondary">
            Scrollable dialog content preview
          </div>
        </div>
      </Dialog>
    </main>
  )
}

export default function App() {
  return (
    <ToastProvider>
      <FoundationPreview />
    </ToastProvider>
  )
}
