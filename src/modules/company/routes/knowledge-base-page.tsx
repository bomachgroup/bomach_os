import { Info, LibraryBig } from 'lucide-react'
import { Link } from '@tanstack/react-router'

import { Alert } from '@/shared/ui/alert'
import { Card } from '@/shared/ui/card'
import { PageLayout } from '@/shared/ui/page-layout'

export function KnowledgeBasePage() {
  return (
    <PageLayout title="Knowledge Base" subtitle="Cross-role documents, templates, and references.">
      <div className="flex min-h-[42vh] items-center justify-center py-4">
        <Card className="tablet:p-8 w-full max-w-3xl p-5">
          <div className="mx-auto flex max-w-2xl flex-col items-center text-center">
            <span className="bg-primary-subtle text-primary rounded-surface flex size-14 items-center justify-center">
              <LibraryBig className="size-7" aria-hidden="true" />
            </span>
            <h2 className="text-h2 mt-4 font-semibold">Company Knowledge Base is unavailable</h2>
            <p className="text-body-sm text-text-secondary mt-2">
              The current backend contract does not publish a company-wide Knowledge Base. This page
              will not show sample documents or offer actions that cannot be saved.
            </p>
            <Alert tone="info" role="status" className="mt-5 w-full text-left">
              <span className="mb-1 flex items-center gap-2 font-semibold">
                <Info aria-hidden="true" className="size-4" />
                Available now
              </span>
              Use role resources and the Success Playbook where applicable, or add a supported
              Knowledge Base API before implementing shared documents.
            </Alert>
            <Link
              to="/dashboard/role"
              className="border-border-strong bg-surface text-text-primary hover:bg-surface-muted focus-visible:shadow-focus-ring rounded-control text-label mt-5 inline-flex min-h-11 items-center justify-center border px-4 py-2 font-semibold focus-visible:outline-none"
            >
              Open My Role resources
            </Link>
          </div>
        </Card>
      </div>
    </PageLayout>
  )
}
