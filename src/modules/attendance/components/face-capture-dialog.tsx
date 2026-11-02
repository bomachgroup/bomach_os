import { useEffect, useRef, useState } from 'react'
import { Camera, Check, RotateCcw, ShieldCheck } from 'lucide-react'

import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'

import {
  getBrowserPermissionState,
  permissionStateLabel,
  type BrowserPermissionState,
} from '../browser-permissions'

type FaceApiModule = typeof import('@vladmandic/face-api')
type ChallengeDirection = 'left' | 'right'
type ChallengeStep = 'center' | ChallengeDirection | 'return'
type FaceLandmarkDetection = {
  detection: { box: { x: number; y: number; width: number; height: number } }
  landmarks: { positions: Array<{ x: number; y: number }> }
}

const stepNames: Record<ChallengeStep, string> = {
  center: 'Look straight at the camera',
  left: 'Turn your head to the left',
  right: 'Turn your head to the right',
  return: 'Return your face to the center',
}
const stableFramesRequired = 3
const centerThreshold = 0.15
const turnThreshold = 0.3
const minFaceWidth = 0.2
const maxFaceWidth = 0.78
let faceRuntimePromise: Promise<FaceApiModule> | null = null

function loadFaceRuntime() {
  if (!faceRuntimePromise) {
    faceRuntimePromise = import('@vladmandic/face-api')
      .then(async (faceApi) => {
        await Promise.all([
          faceApi.nets.tinyFaceDetector.loadFromUri('/face-models'),
          faceApi.nets.faceLandmark68Net.loadFromUri('/face-models'),
        ])
        return faceApi
      })
      .catch((error: unknown) => {
        faceRuntimePromise = null
        throw error
      })
  }
  return faceRuntimePromise
}

function challengeSteps(): ChallengeStep[] {
  const first: ChallengeDirection = Math.random() < 0.5 ? 'left' : 'right'
  return ['center', first, first === 'left' ? 'right' : 'left', 'return']
}

function stopStream(stream: MediaStream | null) {
  stream?.getTracks().forEach((track) => track.stop())
}

function cameraErrorMessage(error: unknown) {
  if (!navigator.mediaDevices?.getUserMedia) {
    return 'Camera access is unavailable in this browser. Use a supported browser over a secure connection.'
  }
  const name = error instanceof DOMException ? error.name : ''
  if (name === 'NotAllowedError' || name === 'SecurityError') {
    return 'Camera access is blocked for this site. Allow it in browser site settings, then try again; a saved site block cannot be overridden by the app.'
  }
  if (name === 'NotFoundError' || name === 'OverconstrainedError') {
    return 'No usable front camera was found on this device.'
  }
  if (name === 'NotReadableError') {
    return 'The camera is busy. Close other apps using it, then retry.'
  }
  return 'The camera could not start. Check camera access and try again.'
}

function guidanceForFace(
  faceCount: number,
  video: HTMLVideoElement,
  detection: FaceLandmarkDetection | undefined,
): { message: string; yaw: number | null } {
  if (faceCount === 0 || !detection) {
    return { message: 'Move into the frame and make sure your face is clearly visible.', yaw: null }
  }
  if (faceCount > 1) {
    return { message: 'Only one person should be in the camera frame.', yaw: null }
  }
  const box = detection.detection.box
  if (!video.videoWidth || !video.videoHeight || !box.width) {
    return { message: 'Hold still while the camera adjusts.', yaw: null }
  }
  const widthRatio = box.width / video.videoWidth
  const centerX = box.x + box.width / 2
  const centerY = box.y + box.height / 2
  if (widthRatio < minFaceWidth) {
    return { message: 'Move a little closer to the camera.', yaw: null }
  }
  if (widthRatio > maxFaceWidth) {
    return { message: 'Move a little farther from the camera.', yaw: null }
  }
  if (
    Math.abs(centerX / video.videoWidth - 0.5) > 0.2 ||
    Math.abs(centerY / video.videoHeight - 0.5) > 0.22
  ) {
    return { message: 'Center your face inside the guide.', yaw: null }
  }
  const nose = detection.landmarks.positions[30]
  if (!nose) return { message: 'Keep your face in view.', yaw: null }
  // The preview is mirrored, so invert the landmark direction to match the user's perspective.
  return { message: '', yaw: -(nose.x - centerX) / (box.width / 2) }
}

export function FaceCaptureDialog({
  open,
  onOpenChange,
  title,
  description,
  busy = false,
  actionLabel,
  onCapture,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  description: string
  busy?: boolean
  actionLabel: string
  onCapture: (image: string) => Promise<void>
}) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const streamRef = useRef<MediaStream | null>(null)
  const faceApiRef = useRef<FaceApiModule | null>(null)
  const latestCaptureRef = useRef(onCapture)
  const photoRef = useRef<string | null>(null)
  const [photo, setPhoto] = useState<string | null>(null)
  const [cameraError, setCameraError] = useState<string | null>(null)
  const [captureError, setCaptureError] = useState<string | null>(null)
  const [modelLoading, setModelLoading] = useState(false)
  const [step, setStep] = useState(0)
  const [steps, setSteps] = useState<ChallengeStep[]>(challengeSteps)
  const [guidance, setGuidance] = useState(stepNames.center)
  const [faceDetected, setFaceDetected] = useState(false)
  const [cameraAttempt, setCameraAttempt] = useState(0)
  const [cameraPermission, setCameraPermission] = useState<BrowserPermissionState | 'checking'>(
    'checking',
  )
  const [cameraStarted, setCameraStarted] = useState(false)
  const [cameraRequesting, setCameraRequesting] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const streamActiveRef = useRef(false)
  const cameraRequestIdRef = useRef(0)

  useEffect(() => {
    latestCaptureRef.current = onCapture
  }, [onCapture])

  useEffect(() => {
    if (!open) return
    let active = true
    void getBrowserPermissionState('camera').then((permission) => {
      if (active) setCameraPermission(permission)
    })
    return () => {
      active = false
    }
  }, [open])

  useEffect(() => {
    if (!open || !cameraStarted) return
    let cancelled = false
    let timer: number | undefined
    let detectionRunning = false
    let enteredAt = Date.now()
    let stableFrames = 0
    let currentStep = 0
    const activeSteps = steps
    const effectStream = streamRef.current

    const captureVerifiedFrame = () => {
      const video = videoRef.current
      if (!video?.videoWidth || !video.videoHeight) {
        throw new Error('The camera is still starting. Restart the guided check and try again.')
      }
      const scale = Math.min(1, 1280 / video.videoWidth)
      const canvas = document.createElement('canvas')
      canvas.width = Math.round(video.videoWidth * scale)
      canvas.height = Math.round(video.videoHeight * scale)
      const context = canvas.getContext('2d')
      if (!context) throw new Error('The face image could not be prepared. Retry the check.')
      context.translate(canvas.width, 0)
      context.scale(-1, 1)
      context.drawImage(video, 0, 0, canvas.width, canvas.height)
      const encoded = canvas.toDataURL('image/jpeg', 0.85).split(',')[1]
      if (!encoded)
        throw new Error('The verified face image could not be created. Retry the check.')
      photoRef.current = encoded
      setPhoto(encoded)
      setGuidance('Face check complete. Review and continue.')
      stopStream(streamRef.current)
      streamRef.current = null
      streamActiveRef.current = false
    }

    async function runDetection() {
      if (cancelled || detectionRunning) return
      const video = videoRef.current
      const faceApi = faceApiRef.current
      if (!video || !faceApi || video.readyState < HTMLMediaElement.HAVE_CURRENT_DATA) {
        timer = window.setTimeout(() => void runDetection(), 180)
        return
      }
      detectionRunning = true
      try {
        const detections = (await faceApi
          .detectAllFaces(
            video,
            new faceApi.TinyFaceDetectorOptions({ inputSize: 224, scoreThreshold: 0.5 }),
          )
          .withFaceLandmarks()) as FaceLandmarkDetection[]
        if (cancelled) return
        const face = detections[0]
        const alignment = guidanceForFace(detections.length, video, face)
        setFaceDetected(detections.length === 1)
        if (alignment.yaw === null) {
          stableFrames = 0
          setGuidance(alignment.message)
        } else if (Date.now() - enteredAt < 800) {
          // Give the user a moment to read each new instruction.
        } else {
          const target = activeSteps[currentStep]
          const matched =
            target === 'center' || target === 'return'
              ? Math.abs(alignment.yaw) < centerThreshold
              : target === 'left'
                ? alignment.yaw < -turnThreshold
                : alignment.yaw > turnThreshold
          if (matched) {
            stableFrames += 1
            setGuidance(
              stableFrames >= stableFramesRequired
                ? 'Position confirmed.'
                : `Hold still… ${stableFrames}/${stableFramesRequired}`,
            )
            if (stableFrames >= stableFramesRequired) {
              if (currentStep >= activeSteps.length - 1) {
                captureVerifiedFrame()
              } else {
                currentStep += 1
                enteredAt = Date.now()
                stableFrames = 0
                setStep(currentStep)
                setGuidance(stepNames[activeSteps[currentStep] ?? 'center'])
              }
            }
          } else {
            stableFrames = 0
            setGuidance(stepNames[target ?? 'center'])
          }
        }
      } catch {
        if (!cancelled) {
          setCameraError(
            'The face check stopped unexpectedly. Restart the guided check to try again.',
          )
          stopStream(streamRef.current)
          streamRef.current = null
          streamActiveRef.current = false
          setCameraStarted(false)
        }
      } finally {
        detectionRunning = false
        if (!cancelled && streamActiveRef.current && !photoRef.current) {
          timer = window.setTimeout(() => void runDetection(), 180)
        }
      }
    }

    async function start() {
      let cameraReady = false
      try {
        const stream = effectStream
        if (!stream) {
          throw new Error('Camera access is required before the guided face check can start.')
        }
        if (videoRef.current) {
          videoRef.current.srcObject = stream
          await videoRef.current.play()
        }
        cameraReady = true
        const faceApi = await loadFaceRuntime()
        faceApiRef.current = faceApi
        if (cancelled) return
        streamActiveRef.current = true
        setModelLoading(false)
        void runDetection()
      } catch (error) {
        if (cancelled) return
        const message = error instanceof Error ? error.message : ''
        stopStream(effectStream)
        if (streamRef.current === effectStream) streamRef.current = null
        streamActiveRef.current = false
        setCameraError(
          cameraReady
            ? 'The on-device face check could not load. Check your connection and retry.'
            : message.startsWith('Camera access is required')
              ? message
              : cameraErrorMessage(error),
        )
        setModelLoading(false)
        setCameraStarted(false)
      }
    }
    void start()

    return () => {
      cancelled = true
      if (timer !== undefined) window.clearTimeout(timer)
      stopStream(effectStream)
      if (streamRef.current === effectStream) streamRef.current = null
      streamActiveRef.current = false
    }
  }, [cameraAttempt, cameraStarted, open, steps])

  async function requestCameraAccess() {
    setCameraError(null)
    setCaptureError(null)
    if (cameraPermission === 'checking') return
    if (cameraPermission === 'denied') {
      setCameraError(
        'Camera access is blocked for this site. Allow it in browser site settings, then select Check camera access again.',
      )
      return
    }
    if (!navigator.mediaDevices?.getUserMedia) {
      setCameraError(
        'Camera access is unavailable in this browser. Use a supported browser over a secure connection.',
      )
      return
    }

    const requestId = cameraRequestIdRef.current + 1
    cameraRequestIdRef.current = requestId
    setCameraRequesting(true)
    setModelLoading(true)
    try {
      // Keep this request directly inside the user action so an undecided browser permission
      // can display its native prompt before the face models start downloading.
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'user', width: { ideal: 640 }, height: { ideal: 480 } },
        audio: false,
      })
      if (cameraRequestIdRef.current !== requestId) {
        stopStream(stream)
        return
      }
      stopStream(streamRef.current)
      streamRef.current = stream
      streamActiveRef.current = false
      setCameraPermission('granted')
      setCameraAttempt((attempt) => attempt + 1)
      setCameraStarted(true)
    } catch (error) {
      if (cameraRequestIdRef.current !== requestId) return
      setModelLoading(false)
      setCameraError(cameraErrorMessage(error))
      void getBrowserPermissionState('camera').then(setCameraPermission)
    } finally {
      if (cameraRequestIdRef.current === requestId) setCameraRequesting(false)
    }
  }

  async function recheckCameraPermission() {
    const permission = await getBrowserPermissionState('camera')
    setCameraPermission(permission)
    if (permission !== 'denied') setCameraError(null)
  }

  function resetForRetry() {
    cameraRequestIdRef.current += 1
    stopStream(streamRef.current)
    streamRef.current = null
    streamActiveRef.current = false
    photoRef.current = null
    setPhoto(null)
    setCameraError(null)
    setCaptureError(null)
    setFaceDetected(false)
    setGuidance(stepNames.center)
    setStep(0)
    setSteps(challengeSteps())
    setModelLoading(false)
    setCameraStarted(false)
    setCameraRequesting(false)
    void getBrowserPermissionState('camera').then(setCameraPermission)
  }

  function retake() {
    resetForRetry()
    void requestCameraAccess()
  }

  function handleOpenChange(nextOpen: boolean) {
    if (nextOpen) setCameraPermission('checking')
    if (!nextOpen && !submitting && !busy) {
      cameraRequestIdRef.current += 1
      stopStream(streamRef.current)
      streamRef.current = null
      streamActiveRef.current = false
      photoRef.current = null
      setPhoto(null)
      setCameraError(null)
      setCaptureError(null)
      setFaceDetected(false)
      setGuidance(stepNames.center)
      setStep(0)
      setSteps(challengeSteps())
      setModelLoading(false)
      setCameraStarted(false)
      setCameraRequesting(false)
    }
    onOpenChange(nextOpen)
  }

  async function submit() {
    if (!photo || submitting || busy) return
    setCaptureError(null)
    setSubmitting(true)
    try {
      await latestCaptureRef.current(photo)
      onOpenChange(false)
    } catch (error) {
      setCaptureError(
        error instanceof Error
          ? error.message
          : 'The face action could not be completed. Try again.',
      )
    } finally {
      setSubmitting(false)
    }
  }

  const hasCameraIssue = Boolean(cameraError) || cameraPermission === 'denied'
  const showFaceChallenge = cameraStarted || Boolean(photo)

  return (
    <Dialog
      open={open}
      onOpenChange={handleOpenChange}
      title={title}
      description={description}
      size="lg"
      footer={
        <>
          <Button
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={submitting || busy}
          >
            Cancel
          </Button>
          {photo ? (
            <>
              <Button
                variant="outline"
                onClick={retake}
                disabled={submitting || busy}
                leadingIcon={<RotateCcw className="size-4" />}
              >
                Retake
              </Button>
              <Button
                onClick={() => void submit()}
                isLoading={submitting || busy}
                leadingIcon={<ShieldCheck className="size-4" />}
              >
                {actionLabel}
              </Button>
            </>
          ) : null}
        </>
      }
    >
      <div className="mx-auto w-full max-w-5xl space-y-4">
        {cameraError ? (
          <Alert tone="danger" title="Guided face check unavailable" role="alert">
            {cameraError}
          </Alert>
        ) : cameraPermission === 'denied' ? (
          <Alert tone="danger" title="Camera access is blocked" role="alert">
            Allow camera access for this site in your browser settings. The browser can show its
            permission prompt when access is undecided, but it cannot override a saved block.
          </Alert>
        ) : captureError ? (
          <Alert tone="danger" title="Face action was not saved" role="alert">
            {captureError}
          </Alert>
        ) : null}
        {showFaceChallenge ? (
          <div
            className="tablet:hidden flex gap-1.5"
            aria-label={`Step ${step + 1} of ${steps.length}`}
            role="progressbar"
            aria-valuemin={1}
            aria-valuemax={steps.length}
            aria-valuenow={photo ? steps.length : step + 1}
          >
            {steps.map((challenge, index) => (
              <span
                key={`${challenge}-${index}`}
                className={`rounded-pill h-1 flex-1 ${photo || index < step ? 'bg-primary' : index === step ? 'bg-primary/55' : 'bg-border-subtle'}`}
              />
            ))}
          </div>
        ) : null}
        <div className="tablet:grid-cols-[minmax(0,1.35fr)_minmax(15rem,0.8fr)] grid gap-4">
          <div className="rounded-surface tablet:mx-0 tablet:aspect-auto tablet:min-h-[20rem] relative mx-auto aspect-[4/3] w-full overflow-hidden bg-neutral-950">
            {photo ? (
              <img
                className="size-full object-cover"
                src={`data:image/jpeg;base64,${photo}`}
                alt="Verified face preview"
              />
            ) : cameraError ? (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-6 text-center text-white/80">
                <span className="flex size-14 items-center justify-center rounded-full bg-white/10">
                  <Camera className="size-6" aria-hidden="true" />
                </span>
                <span className="text-body-sm font-medium">Camera feed unavailable</span>
              </div>
            ) : !cameraStarted ? (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-6 text-center text-white/80">
                <span className="flex size-14 items-center justify-center rounded-full bg-white/10">
                  <Camera className="size-6" aria-hidden="true" />
                </span>
                <span className="text-body-sm font-medium">
                  {cameraRequesting ? 'Waiting for camera permission…' : 'Camera is off'}
                </span>
              </div>
            ) : (
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="size-full -scale-x-100 object-cover"
              />
            )}
            {!photo && cameraStarted && !hasCameraIssue ? (
              <div
                className={`pointer-events-none absolute inset-x-0 top-1/2 mx-auto h-[72%] w-[56%] -translate-y-1/2 rounded-[50%] border-2 shadow-[0_0_0_999px_rgb(0_0_0_/_0.23)] ${faceDetected ? 'border-success' : 'border-white/85'}`}
              />
            ) : null}
            {modelLoading && cameraStarted ? (
              <div className="absolute inset-0 flex items-end justify-center bg-neutral-950/40 p-4">
                <p className="rounded-control text-caption bg-neutral-950/70 px-3 py-2 text-white">
                  Preparing on-device face check…
                </p>
              </div>
            ) : null}
          </div>
          <div className="space-y-3">
            {!showFaceChallenge ? (
              <div className="border-border-subtle bg-surface-muted rounded-control space-y-3 border p-4">
                <div className="flex items-start gap-3">
                  <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
                    <Camera className="size-4" aria-hidden="true" />
                  </span>
                  <div className="min-w-0">
                    <p className="text-caption text-primary font-semibold tracking-wide uppercase">
                      {permissionStateLabel(cameraPermission)}
                    </p>
                    <p className="text-label text-text-primary mt-1 font-semibold">
                      {cameraPermission === 'denied'
                        ? 'Allow camera in browser settings'
                        : cameraPermission === 'granted'
                          ? 'Ready to start face check'
                          : 'Camera permission needed'}
                    </p>
                    <p className="text-caption text-text-secondary mt-1">
                      {cameraPermission === 'denied'
                        ? 'After changing the site permission, check again here. The face scan will not start while access is blocked.'
                        : cameraPermission === 'prompt'
                          ? 'Select continue and your browser will ask for camera access before the face scan starts.'
                          : cameraPermission === 'granted'
                            ? 'The camera is allowed. Start when you are ready to follow the face prompts.'
                            : 'Your browser will check access when you continue. The camera starts only after access is allowed.'}
                    </p>
                  </div>
                </div>
                <Button
                  onClick={() =>
                    cameraPermission === 'denied'
                      ? void recheckCameraPermission()
                      : void requestCameraAccess()
                  }
                  disabled={cameraPermission === 'checking' || cameraRequesting}
                  isLoading={cameraRequesting}
                  leadingIcon={
                    cameraPermission === 'denied' ? (
                      <RotateCcw className="size-4" aria-hidden="true" />
                    ) : (
                      <Camera className="size-4" aria-hidden="true" />
                    )
                  }
                  className="w-full"
                >
                  {cameraPermission === 'denied'
                    ? 'Check camera access again'
                    : 'Enable camera and start'}
                </Button>
              </div>
            ) : null}
            <div className="border-border-subtle bg-surface-muted rounded-control border p-4">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-caption text-primary font-semibold tracking-wide uppercase">
                    {photo
                      ? 'Verified'
                      : modelLoading
                        ? 'Preparing face check'
                        : cameraStarted
                          ? `Guided check · ${step + 1} of ${steps.length}`
                          : 'Camera permission'}
                  </p>
                  <p
                    className="text-label text-text-primary mt-1 font-semibold"
                    aria-live="polite"
                    role="status"
                  >
                    {photo
                      ? 'Face check complete'
                      : cameraStarted
                        ? guidance
                        : cameraPermission === 'denied'
                          ? 'Access is blocked for this site'
                          : 'Start the camera to begin'}
                  </p>
                </div>
                {photo ? (
                  <Check
                    className="text-success-foreground mt-1 size-5 shrink-0"
                    aria-hidden="true"
                  />
                ) : null}
              </div>
              <p className="text-caption text-text-secondary mt-2">
                Keep one face in frame and follow each prompt. The turn order changes each time.
              </p>
            </div>
            {showFaceChallenge ? (
              <div className="border-border-subtle rounded-control space-y-1.5 border p-3">
                {[
                  'Center your face',
                  'First head turn',
                  'Second head turn',
                  'Return to center',
                ].map((label, index) => {
                  const complete = Boolean(photo) || index < step
                  const active = !photo && index === step
                  return (
                    <div
                      key={label}
                      className={`rounded-control flex items-center gap-2.5 px-2.5 py-2 ${active ? 'bg-primary-subtle/60' : ''}`}
                    >
                      <span
                        className={`text-caption flex size-6 shrink-0 items-center justify-center rounded-full font-semibold ${complete ? 'bg-success-subtle text-success-foreground' : active ? 'bg-primary text-text-on-primary' : 'bg-surface-muted text-text-muted'}`}
                      >
                        {complete ? <Check className="size-3.5" aria-hidden="true" /> : index + 1}
                      </span>
                      <span
                        className={`text-caption ${active ? 'text-text-primary font-semibold' : 'text-text-secondary'}`}
                      >
                        {label}
                      </span>
                    </div>
                  )
                })}
              </div>
            ) : null}
            {faceDetected && !photo && !modelLoading ? (
              <div className="border-success/20 bg-success-subtle rounded-control flex items-center gap-2 border px-3 py-2">
                <span className="bg-success-foreground size-1.5 rounded-full" aria-hidden="true" />
                <span className="text-caption text-success-foreground font-medium">
                  Face detected in the guide
                </span>
              </div>
            ) : null}
          </div>
        </div>
        <p className="text-caption text-text-secondary flex items-start justify-center gap-2 text-center">
          <ShieldCheck className="text-primary mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <span>
            Stay in good light. Face detection runs on this device; only the final verified image is
            sent to BOMACH.
          </span>
        </p>
      </div>
    </Dialog>
  )
}
