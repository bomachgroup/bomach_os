export type ApiFieldErrors = Record<string, string | string[]>

export interface ApiErrorOptions {
  status: number
  code?: string
  details?: unknown
  fieldErrors?: ApiFieldErrors
  cause?: unknown
}

export class ApiError extends Error {
  readonly status: number
  readonly code: string | undefined
  readonly details: unknown
  readonly fieldErrors: ApiFieldErrors | undefined

  constructor(message: string, options: ApiErrorOptions) {
    super(message, { cause: options.cause })
    this.name = 'ApiError'
    this.status = options.status
    this.code = options.code
    this.details = options.details
    this.fieldErrors = options.fieldErrors
  }
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError
}
