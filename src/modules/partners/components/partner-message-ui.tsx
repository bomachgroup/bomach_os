import {
  Check,
  Download,
  FileText,
  Image as ImageIcon,
  Paperclip,
  RotateCw,
  Send,
  Video,
  X,
} from 'lucide-react'
import { useRef, useState, type ChangeEvent, type FormEvent, type KeyboardEvent } from 'react'

import type { PartnerMessageDto } from '@/modules/partners/partner.api'
import { Alert } from '@/shared/ui/alert'

const MAX_FILES = 5
const MAX_FILE_SIZE = 20 * 1024 * 1024
const ACCEPTED_EXTENSIONS = new Set([
  '.pdf',
  '.doc',
  '.docx',
  '.xls',
  '.xlsx',
  '.ppt',
  '.pptx',
  '.csv',
  '.txt',
  '.jpg',
  '.jpeg',
  '.png',
  '.mp4',
  '.m4v',
  '.mov',
  '.webm',
])

function extension(filename: string) {
  return filename.slice(filename.lastIndexOf('.')).toLowerCase()
}

function formatFileSize(size: number) {
  if (size < 1024 * 1024) return `${Math.max(1, Math.round(size / 1024))} KB`
  return `${(size / (1024 * 1024)).toFixed(1)} MB`
}

function formatClock(value: string, formatter: (value: string) => string) {
  return formatter(value)
}

export function PartnerMessageAttachments({
  attachments,
}: {
  attachments: NonNullable<PartnerMessageDto['attachments']>
}) {
  if (!attachments.length) return null

  return (
    <div className="mt-3 grid min-w-0 gap-2 sm:grid-cols-2">
      {attachments.map((attachment) => {
        const filename = attachment.original_filename
        const isImage = attachment.content_type.startsWith('image/') && attachment.preview_url
        const isVideo = attachment.content_type.startsWith('video/') && attachment.preview_url
        if (isImage) {
          return (
            <a
              key={attachment.id}
              className="group border-border-subtle bg-surface block min-w-0 overflow-hidden rounded-xl border"
              href={attachment.download_url}
              target="_blank"
              rel="noreferrer"
              aria-label={`Open image ${filename}`}
            >
              <img
                src={attachment.preview_url}
                alt={filename}
                loading="lazy"
                className="bg-surface-muted max-h-64 w-full object-contain"
              />
              <span className="text-caption text-text-secondary flex min-w-0 items-center gap-2 px-3 py-2">
                <ImageIcon className="size-4 shrink-0" aria-hidden="true" />
                <span className="min-w-0 flex-1 truncate">{filename}</span>
                <span className="shrink-0">{formatFileSize(attachment.size)}</span>
              </span>
            </a>
          )
        }
        if (isVideo) {
          return (
            <div
              key={attachment.id}
              className="border-border-subtle bg-surface min-w-0 overflow-hidden rounded-xl border"
            >
              <video
                className="max-h-64 w-full bg-black object-contain"
                controls
                preload="metadata"
                aria-label={filename}
                src={attachment.preview_url}
              />
              <span className="text-caption text-text-secondary flex min-w-0 items-center gap-2 px-3 py-2">
                <Video className="size-4 shrink-0" aria-hidden="true" />
                <span className="min-w-0 flex-1 truncate">{filename}</span>
                <a
                  className="text-primary focus-visible:shadow-focus-ring rounded p-1"
                  href={attachment.download_url}
                  aria-label={`Download ${filename}`}
                >
                  <Download className="size-4" aria-hidden="true" />
                </a>
              </span>
            </div>
          )
        }
        return (
          <a
            key={attachment.id}
            href={attachment.download_url}
            className="border-border-subtle bg-surface hover:bg-surface-muted focus-visible:shadow-focus-ring flex min-w-0 items-center gap-3 rounded-xl border p-3 transition-colors focus-visible:outline-none"
          >
            <span className="bg-primary-subtle text-primary flex size-10 shrink-0 items-center justify-center rounded-xl">
              <FileText className="size-5" aria-hidden="true" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="text-body-sm text-text-primary block truncate font-semibold">
                {filename}
              </span>
              <span className="text-caption text-text-muted">
                Document · {formatFileSize(attachment.size)}
              </span>
            </span>
            <Download className="text-text-muted size-4 shrink-0" aria-hidden="true" />
          </a>
        )
      })}
    </div>
  )
}

export function PartnerMessageTimeline({
  messages,
  isOwnMessage,
  counterpartName,
  formatDate,
}: {
  messages: PartnerMessageDto[]
  isOwnMessage: (message: PartnerMessageDto) => boolean
  counterpartName: string
  formatDate: (value: string) => string
}) {
  return (
    <div className="space-y-3" role="log" aria-label="Conversation messages" aria-live="polite">
      {[...messages].reverse().map((message) => {
        const own = isOwnMessage(message)
        return (
          <article
            key={message.id}
            className={`flex min-w-0 ${own ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[92%] min-w-0 rounded-2xl border px-3.5 py-3 shadow-sm sm:max-w-[78%] ${own ? 'border-primary/20 bg-primary-subtle/70 rounded-br-md' : 'border-border-subtle bg-surface rounded-bl-md'}`}
            >
              {!own ? (
                <p className="text-caption text-primary mb-1 font-semibold">
                  {message.sender_name || counterpartName}
                </p>
              ) : null}
              {message.body ? (
                <p className="text-body-sm text-text-primary break-words whitespace-pre-wrap">
                  {message.body}
                </p>
              ) : null}
              <PartnerMessageAttachments attachments={message.attachments ?? []} />
              <div className="mt-2 flex items-center justify-end gap-1">
                <time className="text-caption text-text-muted">
                  {formatClock(message.created_at, formatDate)}
                </time>
                {own ? (
                  <Check
                    className="text-primary size-3.5"
                    role="img"
                    aria-label="Stored successfully"
                  >
                    <title>Stored successfully</title>
                  </Check>
                ) : null}
              </div>
            </div>
          </article>
        )
      })}
    </div>
  )
}

export function PartnerMessageComposer({
  sending,
  error,
  onSend,
  placeholder = 'Write a message…',
}: {
  sending: boolean
  error?: string
  onSend: (body: string, files: File[]) => Promise<void>
  placeholder?: string
}) {
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [body, setBody] = useState('')
  const [files, setFiles] = useState<File[]>([])
  const [localError, setLocalError] = useState('')
  const [sendFailed, setSendFailed] = useState(false)
  const visibleSendError = localError || (sendFailed ? error : undefined)

  function addFiles(event: ChangeEvent<HTMLInputElement>) {
    const selected = Array.from(event.currentTarget.files ?? [])
    event.currentTarget.value = ''
    setLocalError('')
    if (selected.some((file) => !ACCEPTED_EXTENSIONS.has(extension(file.name)))) {
      setLocalError('Choose a supported image, video, or document file.')
      return
    }
    if (selected.some((file) => file.size > MAX_FILE_SIZE)) {
      setLocalError('Each attachment must be 20 MB or smaller.')
      return
    }
    if (files.length + selected.length > MAX_FILES) {
      setLocalError('A message can include up to five attachments.')
      return
    }
    setSendFailed(false)
    setFiles((current) => [...current, ...selected])
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setLocalError('')
    if (!body.trim() && !files.length) {
      setLocalError('Write a message or attach a file.')
      return
    }
    setSendFailed(false)
    try {
      await onSend(body.trim(), files)
      setBody('')
      setFiles([])
    } catch {
      // Keep the draft and attachments available for retry.
      setSendFailed(true)
    }
  }

  const showResend = sendFailed && Boolean(body.trim() || files.length)

  function handleComposerKeyDown(event: KeyboardEvent<HTMLTextAreaElement>) {
    if (event.key === 'Enter' && !event.shiftKey && !event.nativeEvent.isComposing) {
      event.preventDefault()
      event.currentTarget.form?.requestSubmit()
    }
  }

  return (
    <form
      aria-busy={sending}
      className="border-border-subtle bg-surface-muted/50 space-y-2 border-t p-3 sm:p-4"
      onSubmit={submit}
    >
      {files.length ? (
        <ul className="flex min-w-0 flex-wrap gap-2" aria-label="Attachments to send">
          {files.map((file, index) => (
            <li
              key={`${file.name}-${file.lastModified}-${index}`}
              className="border-border-subtle bg-surface flex max-w-full min-w-0 items-center gap-2 rounded-xl border px-2.5 py-2"
            >
              {file.type.startsWith('image/') ? (
                <ImageIcon className="text-primary size-4 shrink-0" aria-hidden="true" />
              ) : file.type.startsWith('video/') ? (
                <Video className="text-primary size-4 shrink-0" aria-hidden="true" />
              ) : (
                <FileText className="text-primary size-4 shrink-0" aria-hidden="true" />
              )}
              <span className="text-caption text-text-primary min-w-0 truncate">{file.name}</span>
              <span className="text-caption text-text-muted shrink-0">
                {formatFileSize(file.size)}
              </span>
              <button
                type="button"
                className="focus-visible:shadow-focus-ring text-text-muted hover:text-danger rounded-full p-1 focus-visible:outline-none"
                aria-label={`Remove ${file.name}`}
                onClick={() => {
                  setSendFailed(false)
                  setFiles((current) => current.filter((_, fileIndex) => fileIndex !== index))
                }}
              >
                <X className="size-4" aria-hidden="true" />
              </button>
            </li>
          ))}
        </ul>
      ) : null}
      <div className="border-border-subtle bg-surface focus-within:border-primary focus-within:shadow-focus-ring flex min-w-0 items-end gap-2 rounded-2xl border p-2 transition-colors">
        <input
          ref={fileInputRef}
          type="file"
          className="sr-only"
          multiple
          accept="image/jpeg,image/png,video/mp4,video/quicktime,video/webm,.m4v,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.csv,.txt"
          onChange={addFiles}
          aria-label="Choose image, video, or document attachments"
        />
        <button
          type="button"
          className="focus-visible:shadow-focus-ring text-text-secondary hover:bg-surface-muted mb-0.5 flex size-10 shrink-0 items-center justify-center rounded-full transition-colors focus-visible:outline-none disabled:opacity-50"
          aria-label="Add attachment"
          title="Add photo, video, or document"
          disabled={sending || files.length >= MAX_FILES}
          onClick={() => fileInputRef.current?.click()}
        >
          <Paperclip className="size-5" aria-hidden="true" />
        </button>
        <textarea
          aria-label="Message"
          rows={1}
          value={body}
          onChange={(event) => {
            setSendFailed(false)
            setBody(event.currentTarget.value)
          }}
          onKeyDown={handleComposerKeyDown}
          placeholder={placeholder}
          disabled={sending}
          className="text-body-sm text-text-primary placeholder:text-text-muted max-h-36 min-h-10 min-w-0 flex-1 resize-y border-0 bg-transparent px-2 py-2.5 focus:outline-none disabled:opacity-60"
        />
        <button
          type="submit"
          disabled={sending || (!body.trim() && !files.length)}
          aria-label={showResend ? 'Resend message' : 'Send message'}
          title={showResend ? 'Resend message' : 'Send message'}
          className={`focus-visible:shadow-focus-ring mb-0.5 flex h-10 shrink-0 items-center justify-center transition-colors focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50 ${showResend ? 'bg-danger text-text-on-primary hover:bg-danger-hover gap-2 rounded-full px-3' : 'bg-primary text-text-on-primary hover:bg-primary-hover size-10 rounded-full'}`}
        >
          {sending ? (
            <span
              aria-hidden="true"
              className="size-4 animate-spin rounded-full border-2 border-current border-r-transparent"
            />
          ) : showResend ? (
            <>
              <RotateCw className="size-4" aria-hidden="true" />
              <span className="text-caption font-semibold">Resend</span>
            </>
          ) : (
            <Send className="size-4" aria-hidden="true" />
          )}
        </button>
      </div>
      <p className="text-caption text-text-muted pl-12">
        {sending
          ? 'Sending message…'
          : 'Photos, videos, and documents · up to 5 files, 20 MB each · Enter to send, Shift+Enter for a new line'}
      </p>
      {visibleSendError ? (
        <Alert tone="danger" role="alert">
          {visibleSendError}
          {sendFailed ? (
            <p className="mt-1">Your draft is still here. Select Resend message to try again.</p>
          ) : null}
        </Alert>
      ) : sendFailed ? (
        <Alert tone="danger" role="alert">
          The message could not be sent. Your draft is still here; resend it when ready.
        </Alert>
      ) : null}
    </form>
  )
}
