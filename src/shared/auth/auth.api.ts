import { apiClient } from '@/shared/api/api-client'

export interface BrowserLoginRequest {
  email: string
  password: string
}

export interface BrowserLoginResponse {
  success: true
  requires_2fa: boolean
  user_id?: number
  detail: string
}

export interface CurrentUserDto {
  id: number
  email: string
  username: string
  first_name?: string | null
  last_name?: string | null
  phone_number?: string | null
  is_verified: boolean
  created_at: string
}

export interface EmployeeProfileDto {
  user_id: number
  employee_id: string
  username: string
  email: string
  first_name: string
  last_name: string
  designation?: string
  employment_status?: string
  is_active?: boolean
  [key: string]: unknown
}

export interface RoleDto {
  id: number
  name: string
  permissions: Record<string, string[]>
  [key: string]: unknown
}

export interface PermissionsCatalogDto {
  permissions_map: Record<string, string[]>
}

export interface TwoFactorStatusDto {
  success: boolean
  two_factor_enabled: boolean
}

export interface AuthSuccessDto {
  success: boolean
  detail?: string
}

export const authApi = {
  login: (data: BrowserLoginRequest) =>
    apiClient.post<BrowserLoginResponse>('/auth/browser/login', data, {
      skipRefresh: true,
    }),

  verifyTwoFactor: (code: string) =>
    apiClient.post<{ success: true; user_id: number }>(
      '/auth/browser/verify-2fa',
      { code },
      { skipRefresh: true },
    ),

  cancelTwoFactor: () =>
    apiClient.post<AuthSuccessDto>('/auth/browser/cancel-2fa', undefined, {
      skipRefresh: true,
    }),

  logout: () => apiClient.post<AuthSuccessDto>('/auth/browser/logout'),

  forgotPassword: (email: string) =>
    apiClient.post<AuthSuccessDto>(
      '/auth/browser/forgot-password',
      { email },
      { skipRefresh: true },
    ),

  resetPassword: (data: { email: string; code: string; new_password: string }) =>
    apiClient.post<AuthSuccessDto>('/auth/browser/reset-password', data, {
      skipRefresh: true,
    }),

  currentUser: (signal?: AbortSignal) => apiClient.get<CurrentUserDto>('/auth/me', { signal }),

  employeeProfile: (userId: number, signal?: AbortSignal) =>
    apiClient.get<EmployeeProfileDto>(`/employees/employees/${userId}`, { signal }),

  employeeRole: (userId: number, signal?: AbortSignal) =>
    apiClient.get<RoleDto>(`/roles/employees/${userId}`, { signal }),

  permissionsCatalog: (signal?: AbortSignal) =>
    apiClient.get<PermissionsCatalogDto>('/roles/permissions-map', { signal }),

  twoFactorStatus: (signal?: AbortSignal) =>
    apiClient.get<TwoFactorStatusDto>('/auth/2fa/status', { signal }),

  setTwoFactor: (enabled: boolean, password: string) =>
    apiClient.post<TwoFactorStatusDto>(enabled ? '/auth/2fa/enable' : '/auth/2fa/disable', {
      password,
    }),
}
