import { useEffect, useRef, useState } from 'react'
import { ImagePlus, Paperclip, X } from 'lucide-react'

import { Button } from '@/shared/ui/button'

import { governanceUploadFileKey } from './governance-file-picker-utils'

const MAX_UPLOAD_BYTES = 15 * 1024 * 1024
const ALLOWED_ATTACHMENT_TYPES = ['application/pdf']

function isImage(file: File) {
  return file.type.startsWith('image/') || /\.(avif|gif|jpe?g|png|webp)$/i.test(file.name)
}

function isAllowedAttachment(file: File) {
  return isImage(file) || ALLOWED_ATTACHMENT_TYPES.includes(file.type) || /\.pdf$/i.test(file.name)
}

const fileKey = governanceUploadFileKey

export function AttachmentPicker({
  id,
  files,
  onChange,
  multiple = false,
  disabled = false,
}: {
  id: string
  files: File[]
  onChange: (files: File[]) => void
  multiple?: boolean
  disabled?: boolean
}) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [error, setError] = useState('')

  function acceptFiles(list: FileList | null) {
    if (!list?.length) return
    const incoming = Array.from(list)
    const invalid = incoming.find((file) => !isAllowedAttachment(file))
    if (invalid) {
      setError('Choose an image or PDF file.')
      if (inputRef.current) inputRef.current.value = ''
      return
    }
    const tooLarge = incoming.find((file) => file.size > MAX_UPLOAD_BYTES)
    if (tooLarge) {
      setError('Each file must be 15 MB or smaller.')
      if (inputRef.current) inputRef.current.value = ''
      return
    }

    setError('')
    const next = multiple ? [...files] : []
    for (const file of incoming) {
      if (!next.some((current) => fileKey(current) === fileKey(file))) next.push(file)
    }
    onChange(next)
    if (inputRef.current) inputRef.current.value = ''
  }

  return (
    <div className="space-y-2">
      <input
        ref={inputRef}
        id={id}
        type="file"
        accept="image/*,.pdf,application/pdf"
        multiple={multiple}
        disabled={disabled}
        className="sr-only"
        aria-label="Choose image or PDF"
        onChange={(event) => acceptFiles(event.currentTarget.files)}
      />
      <div className="flex flex-wrap items-center gap-2">
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={disabled}
          leadingIcon={<Paperclip className="size-3.5" aria-hidden="true" />}
          onClick={() => inputRef.current?.click()}
        >
          Choose file
        </Button>
        <p className="text-caption text-text-muted">Images or PDF · up to 15 MB per file</p>
      </div>
      {error ? (
        <p className="text-caption text-danger-foreground" role="alert">
          {error}
        </p>
      ) : null}
      {files.length ? (
        <ul className="flex flex-wrap gap-2" aria-label="Selected files">
          {files.map((file) => (
            <li
              key={fileKey(file)}
              className="border-border-subtle bg-surface-muted text-caption inline-flex max-w-full items-center gap-2 rounded-full border px-2.5 py-1.5"
            >
              {isImage(file) ? (
                <ImagePlus className="text-primary size-3.5 shrink-0" aria-hidden="true" />
              ) : (
                <Paperclip className="text-text-muted size-3.5 shrink-0" aria-hidden="true" />
              )}
              <span className="max-w-48 truncate">{file.name}</span>
              <button
                type="button"
                className="text-text-muted hover:text-text-primary focus-visible:shadow-focus-ring rounded-full p-0.5 focus-visible:outline-none"
                aria-label={`Remove ${file.name}`}
                disabled={disabled}
                onClick={() => onChange(files.filter((item) => fileKey(item) !== fileKey(file)))}
              >
                <X className="size-3.5" aria-hidden="true" />
              </button>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}

export function ProfileImagePicker({
  id,
  currentUrl,
  initials,
  file,
  onChange,
  onClear,
  disabled = false,
}: {
  id: string
  currentUrl: string | null | undefined
  initials: string
  file: File | null
  onChange: (file: File | null) => void
  onClear: () => void
  disabled?: boolean
}) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [preview, setPreview] = useState<{ file: File; src: string } | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!file) return
    const reader = new FileReader()
    reader.addEventListener('load', () => {
      if (typeof reader.result === 'string') setPreview({ file, src: reader.result })
    })
    reader.readAsDataURL(file)
    return () => reader.abort()
  }, [file])

  function selectImage(list: FileList | null) {
    const selected = list?.item(0)
    if (!selected) return
    const image = isImage(selected)
    if (!image) {
      setError('Choose an image file.')
    } else if (selected.size > MAX_UPLOAD_BYTES) {
      setError('The image must be 15 MB or smaller.')
    } else {
      setError('')
      onChange(selected)
    }
    if (inputRef.current) inputRef.current.value = ''
  }

  const previewUrl = preview?.file === file ? preview.src : ''
  const imageUrl = previewUrl || (!file ? currentUrl || '' : '')

  return (
    <div className="flex flex-wrap items-center gap-4">
      <div className="bg-primary-subtle text-primary border-border-subtle text-label flex size-16 shrink-0 items-center justify-center overflow-hidden rounded-full border font-semibold">
        {imageUrl ? (
          <img className="size-full object-cover" src={imageUrl} alt="Shareholder profile" />
        ) : (
          initials || 'SH'
        )}
      </div>
      <div className="min-w-0 space-y-1.5">
        <input
          ref={inputRef}
          id={id}
          type="file"
          accept="image/*"
          disabled={disabled}
          className="sr-only"
          aria-label="Choose profile photo"
          onChange={(event) => selectImage(event.currentTarget.files)}
        />
        <div className="flex flex-wrap gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            disabled={disabled}
            leadingIcon={<ImagePlus className="size-3.5" aria-hidden="true" />}
            onClick={() => inputRef.current?.click()}
          >
            Choose photo
          </Button>
          {file || currentUrl ? (
            <Button
              type="button"
              variant="ghost"
              size="sm"
              disabled={disabled}
              onClick={() => {
                onChange(null)
                onClear()
                setError('')
              }}
            >
              Remove photo
            </Button>
          ) : null}
        </div>
        <p className="text-caption text-text-muted">JPG, PNG, or WEBP · up to 15 MB</p>
        {error ? (
          <p className="text-caption text-danger-foreground" role="alert">
            {error}
          </p>
        ) : null}
      </div>
    </div>
  )
}
