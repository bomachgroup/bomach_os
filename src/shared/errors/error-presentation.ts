import { ApiError, type ApiFieldErrors } from '@/shared/api/api-error'

export type ErrorPresentationContext =
  | 'default'
  | 'login'
  | 'two-factor'
  | 'form-submit'
  | 'page-load'
  | 'section-load'
  | 'background-action'
  | 'destructive-action'

export interface UserFacingError {
  title: string
  message: string
  placement: 'field' | 'form' | 'toast' | 'section' | 'page' | 'redirect'
  retryable: boolean
  fieldErrors?: ApiFieldErrors
}

function placementFor(context: ErrorPresentationContext): UserFacingError['placement'] {
  if (context === 'page-load') return 'page'
  if (context === 'section-load') return 'section'
  if (context === 'form-submit' || context === 'login' || context === 'two-factor') return 'form'
  return 'toast'
}

function isOffline(): boolean {
  return typeof navigator !== 'undefined' && navigator.onLine === false
}

function safeMessage(message: string | undefined, fallback: string): string {
  const value = message?.trim()
  if (!value) return fallback
  const technical =
    /traceback|stack trace|django\.|pydantic|integrityerror|attributeerror|typeerror|keyerror|botocore|boto3|invalidaccesskeyid|signaturedoesnotmatch|(?:not null|unique|foreign key) constraint failed|database is locked|sqlite(?:3)?\.|sql (?:syntax|error)/i
  return technical.test(value) ? fallback : value
}

function networkError(context: ErrorPresentationContext): UserFacingError {
  const offline = isOffline()
  return {
    title: offline ? 'You are offline' : 'Connection problem',
    message: offline
      ? 'Reconnect to the internet, then try again.'
      : 'BOMACH OS could not reach the server. Check your connection or try again shortly.',
    placement: placementFor(context),
    retryable: true,
  }
}

export function presentError(
  error: unknown,
  context: ErrorPresentationContext = 'default',
): UserFacingError {
  if (!(error instanceof ApiError)) {
    return {
      title: context === 'page-load' ? 'Unable to load this page' : 'Something went wrong',
      message: 'An unexpected problem occurred. Please try again.',
      placement: placementFor(context),
      retryable: true,
    }
  }

  if (error.status === 0 || error.code === 'NETWORK_ERROR') return networkError(context)

  if (context === 'login') {
    if (error.status === 401 || error.status === 400) {
      return {
        title: 'Sign-in unsuccessful',
        message: 'The email address or password is incorrect. Check both and try again.',
        placement: 'form',
        retryable: true,
      }
    }
    if (error.status === 403) {
      return {
        title: 'Sign-in not permitted',
        message: 'This account cannot access BOMACH OS. Contact an administrator if you need help.',
        placement: 'form',
        retryable: false,
      }
    }
    if (error.status === 429) {
      return {
        title: 'Too many attempts',
        message: 'Please wait a moment before trying again.',
        placement: 'form',
        retryable: true,
      }
    }
    if (error.status >= 500) {
      return {
        title: 'Sign-in service unavailable',
        message: 'The sign-in service is temporarily unavailable. Please try again shortly.',
        placement: 'form',
        retryable: true,
      }
    }
  }

  if (context === 'two-factor' && [400, 401].includes(error.status)) {
    return {
      title: 'Code not accepted',
      message: 'The verification code is incorrect or has expired. Enter a new code and try again.',
      placement: 'form',
      retryable: true,
    }
  }

  if (error.status === 401) {
    return {
      title: 'Session expired',
      message: 'Sign in again to continue.',
      placement: 'redirect',
      retryable: false,
    }
  }

  if (error.status === 403) {
    return {
      title: 'Permission required',
      message:
        context === 'page-load'
          ? 'Your account does not have access to this page.'
          : context === 'section-load'
            ? 'Your account does not have permission to view this section.'
            : 'You do not have permission to complete this action.',
      placement: placementFor(context),
      retryable: false,
    }
  }

  if (error.status === 400 || error.status === 422) {
    const fieldErrors = sanitizeFieldErrors(error.fieldErrors)
    const singleFieldError = fieldErrors
      ? Object.values(fieldErrors)
          .map((value) => (Array.isArray(value) ? value[0] : value))
          .find(Boolean)
      : undefined
    return {
      title: 'Check the highlighted information',
      message:
        singleFieldError ?? safeMessage(error.message, 'Review the information and try again.'),
      placement: 'form',
      retryable: true,
      ...(fieldErrors ? { fieldErrors } : {}),
    }
  }

  if (error.status === 404) {
    return {
      title: 'Record not found',
      message: 'This record may have been removed or you may no longer have access to it.',
      placement: placementFor(context),
      retryable: false,
    }
  }

  if (error.status === 409) {
    return {
      title: 'The record has changed',
      message: 'Refresh the latest information before trying again.',
      placement: placementFor(context),
      retryable: true,
    }
  }

  if (error.status === 429) {
    return {
      title: 'Too many requests',
      message: 'Please wait a moment before trying again.',
      placement: placementFor(context),
      retryable: true,
    }
  }

  if (error.status >= 500) {
    return {
      title: 'Service temporarily unavailable',
      message: 'BOMACH OS could not complete this request. Please try again shortly.',
      placement: placementFor(context),
      retryable: true,
    }
  }

  return {
    title: 'Action unsuccessful',
    message: safeMessage(error.message, 'The action could not be completed. Please try again.'),
    placement: placementFor(context),
    retryable: true,
  }
}

function sanitizeFieldErrors(fieldErrors: ApiFieldErrors | undefined): ApiFieldErrors | undefined {
  if (!fieldErrors) return undefined
  const sanitized = Object.fromEntries(
    Object.entries(fieldErrors)
      .map(([key, value]) => [
        key,
        Array.isArray(value)
          ? value.map((message) => safeMessage(message, 'Check this value and try again.'))
          : safeMessage(value, 'Check this value and try again.'),
      ])
      .filter(([, value]) => (Array.isArray(value) ? value.length > 0 : Boolean(value))),
  ) as ApiFieldErrors
  return Object.keys(sanitized).length ? sanitized : undefined
}
