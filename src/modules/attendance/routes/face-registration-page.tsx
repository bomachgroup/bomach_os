import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { Camera, CheckCircle2, ShieldCheck } from 'lucide-react'

import { isApiError } from '@/shared/api/api-error'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip } from '@/shared/ui/status-chip'

import { attendanceApi } from '../attendance.api'
import { attendanceQueryKeys, biometricStatusQueryOptions } from '../attendance.queries'
import type { AttendanceSearch } from '../attendance.search'
import { FaceCaptureDialog } from '../components/face-capture-dialog'

export function FaceRegistrationPage() {
  const navigate = useNavigate()
  const search = useSearch({
    from: '/_protected/hr/attendance/face-registration',
  }) as AttendanceSearch
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const canRead =
    hasPermission(session?.permissions ?? {}, 'attendance', 'list') ||
    hasPermission(session?.permissions ?? {}, 'attendance', 'list_own')
  const statusQuery = useQuery({
    ...biometricStatusQueryOptions(userId, employeeId),
    enabled: Boolean(session && canRead),
  })
  const enrollMutation = useMutation({ mutationFn: attendanceApi.enrollFace })
  const [captureOpen, setCaptureOpen] = useState(false)
  const faceReady = Boolean(statusQuery.data?.biometric_enabled && statusQuery.data?.has_face)

  function backToAttendance() {
    void navigate({
      to: '/hr/attendance',
      search: { dateFrom: search.dateFrom, dateTo: search.dateTo, page: search.page },
    })
  }

  async function saveFace(image: string) {
    try {
      await enrollMutation.mutateAsync(image)
    } catch (error) {
      if (isApiError(error)) throw error
      throw new Error('Face verification could not be saved. Try the guided check again.', {
        cause: error,
      })
    }
    await queryClient.invalidateQueries({
      queryKey: attendanceQueryKeys.status(userId, employeeId),
    })
    toast.showToast({
      title: 'Face verification saved',
      description: 'Your face setup is ready for attendance clocking.',
      tone: 'success',
    })
    backToAttendance()
  }

  if (sessionQuery.isPending) {
    return (
      <PageLayout
        title="Face verification"
        subtitle="Securely set up face verification for attendance."
      >
        <Card className="space-y-4" aria-busy="true" aria-label="Loading face verification">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
        </Card>
      </PageLayout>
    )
  }
  if (sessionQuery.isError || !session) {
    return (
      <PageLayout
        title="Face verification"
        subtitle="Securely set up face verification for attendance."
      >
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )
  }
  if (!canRead) {
    return (
      <PageLayout
        title="Face verification"
        subtitle="Securely set up face verification for attendance."
      >
        <Card>
          <ErrorState
            title="You can’t set up face verification"
            description="Your account needs access to your attendance record."
          />
        </Card>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Face verification"
      subtitle="Set up or refresh the face check used when you clock in and out."
      leading={<ShieldCheck className="size-[18px]" aria-hidden="true" />}
      backLink={
        <Button
          variant="ghost"
          size="sm"
          className={pageBackLinkClassName}
          onClick={backToAttendance}
        >
          <PageBackLinkContent>Attendance</PageBackLinkContent>
        </Button>
      }
      contentClassName="space-y-5"
    >
      {statusQuery.isPending ? (
        <Card className="space-y-3" aria-busy="true">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
        </Card>
      ) : statusQuery.isError && !statusQuery.data ? (
        <Card>
          <SectionErrorState
            description="Face verification status could not load."
            error={statusQuery.error}
            onRetry={() => void statusQuery.refetch()}
          />
        </Card>
      ) : (
        <div className="desktop:grid-cols-[minmax(0,1.25fr)_minmax(18rem,.75fr)] grid gap-4">
          <Card className="space-y-5">
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div className="flex min-w-0 items-start gap-3">
                <span
                  className={`rounded-control flex size-11 shrink-0 items-center justify-center ${faceReady ? 'bg-success-subtle text-success-foreground' : 'bg-warning-subtle text-warning-foreground'}`}
                >
                  {faceReady ? (
                    <CheckCircle2 className="size-5" aria-hidden="true" />
                  ) : (
                    <Camera className="size-5" aria-hidden="true" />
                  )}
                </span>
                <div>
                  <h2 className="text-h3 text-text-primary font-semibold">Face enrollment</h2>
                  <p className="text-body-sm text-text-secondary mt-1">
                    {faceReady
                      ? 'Your face is enrolled and biometric verification is enabled.'
                      : 'A guided face check is required before clocking.'}
                  </p>
                </div>
              </div>
              <StatusChip
                label={faceReady ? 'Ready' : 'Setup required'}
                tone={faceReady ? 'success' : 'warning'}
              />
            </div>
            <div className="border-border-subtle tablet:grid-cols-3 grid gap-3 border-t pt-4">
              {[
                ['Center', 'Look directly at the camera.'],
                ['Turn', 'Follow the randomized left and right prompts.'],
                ['Confirm', 'Return to center before your image is captured.'],
              ].map(([title, description], index) => (
                <div key={title} className="bg-surface-muted rounded-control flex gap-3 p-3">
                  <span className="bg-primary-subtle text-primary rounded-pill text-caption flex size-7 shrink-0 items-center justify-center font-semibold">
                    {index + 1}
                  </span>
                  <div className="min-w-0">
                    <p className="text-label text-text-primary font-semibold">{title}</p>
                    <p className="text-caption text-text-secondary mt-0.5">{description}</p>
                  </div>
                </div>
              ))}
            </div>
            <Alert tone="info" title="Camera and privacy">
              Allow camera access when prompted. Face movement is checked on this device; the final
              image is sent securely to the attendance service.
            </Alert>
            <div className="border-border-subtle flex flex-wrap justify-end gap-2 border-t pt-4">
              <Button variant="outline" onClick={backToAttendance}>
                Cancel
              </Button>
              <Button
                onClick={() => setCaptureOpen(true)}
                leadingIcon={<Camera className="size-4" />}
              >
                {faceReady ? 'Re-register face' : 'Register face'}
              </Button>
            </div>
          </Card>
          <Card className="space-y-3">
            <h2 className="text-label text-text-primary font-semibold">Before you begin</h2>
            <ul className="text-body-sm text-text-secondary list-disc space-y-2 pl-5">
              <li>Use a supported browser over a secure connection.</li>
              <li>Allow camera access and face the camera in even light.</li>
              <li>Keep only your face in the frame and follow each prompt.</li>
              <li>You can cancel at any time before saving the enrollment.</li>
            </ul>
          </Card>
        </div>
      )}
      {statusQuery.isError && statusQuery.data ? (
        <Alert tone="warning" title="Showing the last confirmed status">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span>The latest face status refresh failed.</span>
            <Button variant="outline" size="sm" onClick={() => void statusQuery.refetch()}>
              Retry
            </Button>
          </div>
        </Alert>
      ) : null}
      <FaceCaptureDialog
        open={captureOpen}
        onOpenChange={setCaptureOpen}
        title={faceReady ? 'Re-register face verification' : 'Register face verification'}
        description="Complete the guided face check before saving your enrollment."
        busy={enrollMutation.isPending}
        actionLabel="Save face enrollment"
        onCapture={saveFace}
      />
    </PageLayout>
  )
}
