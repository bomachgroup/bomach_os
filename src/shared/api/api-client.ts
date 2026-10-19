import { ApiError, type ApiFieldErrors } from './api-error'

type RequestBody = BodyInit | object | null | undefined

export interface ApiRequestOptions extends Omit<RequestInit, 'body' | 'credentials'> {
  skipRefresh?: boolean
}

interface ApiErrorPayload {
  detail?: unknown
  message?: unknown
  code?: unknown
  errors?: unknown
}

export const SESSION_ESTABLISHED_KEY = 'bomach:session-established'
export const SESSION_EXPIRED_NOTICE_KEY = 'bomach:session-expired-notice'
export const SESSION_EXPIRED_EVENT = 'bomach:session-expired'
export const BROWSER_REQUEST_HEADER = 'X-Bomach-Request'
export const BROWSER_REQUEST_VALUE = 'browser'

const API_BASE_URL = '/api/v1'
let refreshPromise: Promise<boolean> | null = null

function buildUrl(path: string): string {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`
  return `${API_BASE_URL}${normalizedPath}`
}

function isNativeBody(body: RequestBody): body is BodyInit {
  return (
    body !== null &&
    body !== undefined &&
    (typeof body === 'string' ||
      body instanceof Blob ||
      body instanceof FormData ||
      body instanceof URLSearchParams ||
      body instanceof ArrayBuffer ||
      ArrayBuffer.isView(body))
  )
}

async function parseResponse(response: Response): Promise<unknown> {
  if (response.status === 204 || response.status === 205) return undefined
  const contentType = response.headers.get('content-type') ?? ''
  if (contentType.includes('application/json')) {
    try {
      return await response.json()
    } catch (cause) {
      throw new ApiError('The server returned an unreadable response.', {
        status: response.status,
        code: 'INVALID_RESPONSE',
        cause,
      })
    }
  }
  const text = await response.text()
  return text || undefined
}

function getPayloadMessage(payload: ApiErrorPayload | undefined): string | undefined {
  if (!payload) return undefined
  if (typeof payload.detail === 'string' && payload.detail.trim()) return payload.detail.trim()
  if (typeof payload.message === 'string' && payload.message.trim()) return payload.message.trim()
  return undefined
}

function getFieldErrors(errors: unknown): ApiFieldErrors | undefined {
  if (!errors || typeof errors !== 'object' || Array.isArray(errors)) return undefined
  const fields: ApiFieldErrors = {}
  for (const [key, value] of Object.entries(errors)) {
    if (typeof value === 'string' || Array.isArray(value)) {
      fields[key] = Array.isArray(value)
        ? value.filter((item): item is string => typeof item === 'string')
        : value
    }
  }
  return Object.keys(fields).length ? fields : undefined
}

async function executeRequest(
  path: string,
  method: string,
  body: RequestBody,
  options: ApiRequestOptions,
): Promise<Response> {
  const { skipRefresh: _skipRefresh, headers: inputHeaders, ...requestOptions } = options
  void _skipRefresh
  const headers = new Headers(inputHeaders)
  if (!headers.has('Accept')) headers.set('Accept', 'application/json')
  if (!['GET', 'HEAD', 'OPTIONS', 'TRACE'].includes(method.toUpperCase())) {
    headers.set(BROWSER_REQUEST_HEADER, BROWSER_REQUEST_VALUE)
  }

  let requestBody: BodyInit | null | undefined
  if (isNativeBody(body)) requestBody = body
  else if (body === null) requestBody = null
  else if (body !== undefined) {
    headers.set('Content-Type', 'application/json')
    requestBody = JSON.stringify(body)
  }

  try {
    return await fetch(buildUrl(path), {
      ...requestOptions,
      method,
      headers,
      credentials: 'include',
      cache: 'no-store',
      ...(requestBody !== undefined ? { body: requestBody } : {}),
    })
  } catch (cause) {
    if (options.signal?.aborted) throw cause
    throw new ApiError('The server could not be reached. Check your connection and try again.', {
      status: 0,
      code: 'NETWORK_ERROR',
      cause,
    })
  }
}

function announceExpiredSession(): void {
  if (typeof window === 'undefined') return
  const hadSession = window.sessionStorage.getItem(SESSION_ESTABLISHED_KEY) === '1'
  window.sessionStorage.removeItem(SESSION_ESTABLISHED_KEY)
  if (hadSession) {
    window.sessionStorage.setItem(SESSION_EXPIRED_NOTICE_KEY, '1')
    window.dispatchEvent(new CustomEvent(SESSION_EXPIRED_EVENT))
  }
}

async function refreshSession(): Promise<boolean> {
  if (refreshPromise) return refreshPromise

  refreshPromise = (async () => {
    try {
      const response = await executeRequest('/auth/browser/refresh', 'POST', undefined, {
        skipRefresh: true,
      })
      if (!response.ok) {
        await parseResponse(response)
        announceExpiredSession()
        return false
      }
      return true
    } catch {
      announceExpiredSession()
      return false
    } finally {
      refreshPromise = null
    }
  })()

  return refreshPromise
}

async function request<TResponse>(
  path: string,
  method: string,
  body: RequestBody,
  options: ApiRequestOptions,
): Promise<TResponse> {
  let response = await executeRequest(path, method, body, options)

  if (response.status === 401 && !options.skipRefresh) {
    const refreshed = await refreshSession()
    if (refreshed && !options.signal?.aborted) {
      response = await executeRequest(path, method, body, { ...options, skipRefresh: true })
    }
  }

  if (response.status === 401 && !options.skipRefresh) announceExpiredSession()

  const payload = await parseResponse(response)
  if (!response.ok) {
    const errorPayload =
      typeof payload === 'object' && payload !== null ? (payload as ApiErrorPayload) : undefined
    throw new ApiError(
      getPayloadMessage(errorPayload) || 'The request could not be completed. Please try again.',
      {
        status: response.status,
        ...(typeof errorPayload?.code === 'string' ? { code: errorPayload.code } : {}),
        details: payload,
        fieldErrors: getFieldErrors(errorPayload?.errors),
      },
    )
  }

  return payload as TResponse
}

export const apiClient = {
  get: <TResponse>(path: string, options: Omit<ApiRequestOptions, 'body'> = {}) =>
    request<TResponse>(path, 'GET', undefined, options),

  post: <TResponse>(path: string, body?: RequestBody, options: ApiRequestOptions = {}) =>
    request<TResponse>(path, 'POST', body, options),

  put: <TResponse>(path: string, body?: RequestBody, options: ApiRequestOptions = {}) =>
    request<TResponse>(path, 'PUT', body, options),

  patch: <TResponse>(path: string, body?: RequestBody, options: ApiRequestOptions = {}) =>
    request<TResponse>(path, 'PATCH', body, options),

  delete: <TResponse>(path: string, options: Omit<ApiRequestOptions, 'body'> = {}) =>
    request<TResponse>(path, 'DELETE', undefined, options),
}
