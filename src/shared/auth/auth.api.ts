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
  role: { id: number; name: string } | null
  permissions: Record<string, string[]>
}

export interface EmployeeProfileDto {
  id?: number
  user_id: number
  employee_id: string
  username: string
  email: string
  first_name?: string
  middle_name?: string | null
  last_name?: string
  gender?: string | null
  marital_status?: string | null
  nationality?: string | null
  phone_number?: string | null
  personal_email?: string | null
  date_of_birth?: string | null
  address?: string | null
  city?: string | null
  state?: string | null
  zip_code?: string | null
  country?: string | null
  profile_picture?: string | null
  is_verified?: boolean
  is_active?: boolean
  designation?: string | null
  employment_type?: string | null
  employment_status?: string | null
  branch_id?: number | null
  branch_name?: string | null
  branch?: { id: number; branch_name: string } | null
  department_id?: number | null
  department_name?: string | null
  department?: { id: number; name: string } | null
  role_id?: number | null
  role_name?: string | null
  location?: string | null
  reporting_to_id?: number | null
  start_date?: string | null
  created_at?: string
  updated_at?: string
}

export interface RoleDto {
  id: number
  name: string
  permissions: Record<string, string[]>
  [key: string]: unknown
}

export interface TwoFactorStatusDto {
  success: boolean
  two_factor_enabled: boolean
}

export interface BrowserTwoFactorChallengeStatusDto {
  success: true
  pending: boolean
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

  browserTwoFactorChallengeStatus: (signal?: AbortSignal) =>
    apiClient.get<BrowserTwoFactorChallengeStatusDto>('/auth/browser/two-factor/status', {
      signal,
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

  twoFactorStatus: (signal?: AbortSignal) =>
    apiClient.get<TwoFactorStatusDto>('/auth/2fa/status', { signal }),

  setTwoFactor: (enabled: boolean, password: string) =>
    apiClient.post<TwoFactorStatusDto>(enabled ? '/auth/2fa/enable' : '/auth/2fa/disable', {
      password,
    }),
}
