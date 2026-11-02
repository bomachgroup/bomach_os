import { Info, Target } from 'lucide-react'

import { Alert } from '@/shared/ui/alert'
import { Card } from '@/shared/ui/card'
import { PageLayout } from '@/shared/ui/page-layout'

export function OkrBoardPage() {
  return (
    <PageLayout title="OKR Board" subtitle="Track objectives and key results across the company.">
      <div className="flex min-h-[42vh] items-center justify-center py-4">
        <Card className="tablet:p-8 w-full max-w-3xl p-5">
          <div className="mx-auto flex max-w-2xl flex-col items-center text-center">
            <span className="bg-warning-subtle text-warning-foreground rounded-surface flex size-14 items-center justify-center">
              <Target className="size-7" aria-hidden="true" />
            </span>
            <h2 className="text-h2 mt-4 font-semibold">OKR Board is not available yet</h2>
            <p className="text-body-sm text-text-secondary mt-2">
              The published API does not currently expose company or role OKR endpoints. The
              available revenue execution OKRs are branch and owner scoped, so they do not provide
              the company-wide objectives required for this board.
            </p>
            <Alert tone="info" role="status" className="mt-5 w-full text-left">
              <span className="mb-1 flex items-center gap-2 font-semibold">
                <Info aria-hidden="true" className="size-4" />
                Backend contract needed
              </span>
              Objective, key result, owner, period, progress, status, and approval or review
              actions.
            </Alert>
          </div>
        </Card>
      </div>
    </PageLayout>
  )
}
