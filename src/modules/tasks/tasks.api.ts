import { apiClient } from '@/shared/api/api-client'

export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled'
export type TaskPriority = 'low' | 'medium' | 'high'
export type TaskListStatus = 'all' | 'pending' | 'in_progress' | 'completed'
export type TaskPriorityFilter = 'all' | TaskPriority
export type TaskSort = 'due_date' | 'priority'

export interface TaskProjectDto {
  id: number
  name: string
  short_code: string
  status: string
  location: string | null
  priority: string
  progress: number
  start_date: string | null
  deadline: string | null
}

export interface TaskMilestoneDto {
  id: number
  name: string
  status: string
  priority: string
  progress: number
  start_date: string | null
  end_date: string | null
}

export interface MyTaskDto {
  id: number
  project_id: number | null
  project: TaskProjectDto | null
  milestone_id: number | null
  milestone: TaskMilestoneDto | null
  name: string
  description: string | null
  status: TaskStatus | string
  priority: TaskPriority | string
  due_date: string | null
  estimated_hours: string | number | null
  created_at: string
  updated_at: string
}

export interface TaskPageDto {
  count: number
  items: MyTaskDto[]
}

export interface MyTasksSummaryDto {
  total: number
  pending: number
  in_progress: number
  completed: number
  cancelled: number
}

export interface MyTasksListParams {
  status: TaskListStatus
  priority: TaskPriorityFilter
  sort: TaskSort
  limit: number
  offset: number
}

function listSearchParams(params: MyTasksListParams): URLSearchParams {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
    sort: params.sort,
  })
  if (params.status !== 'all') search.set('status', params.status)
  if (params.priority !== 'all') search.set('priority', params.priority)
  return search
}

export const myTasksApi = {
  list: (params: MyTasksListParams, signal?: AbortSignal) =>
    apiClient.get<TaskPageDto>(`/my-tasks?${listSearchParams(params)}`, { signal }),

  summary: (signal?: AbortSignal) =>
    apiClient.get<MyTasksSummaryDto>('/my-tasks/summary', { signal }),

  detail: (taskId: number, signal?: AbortSignal) =>
    apiClient.get<MyTaskDto>(`/my-tasks/${taskId}`, { signal }),

  updateStatus: (taskId: number, status: Extract<TaskStatus, 'in_progress' | 'completed'>) =>
    apiClient.patch<MyTaskDto>(`/my-tasks/${taskId}/status`, { status }),
}
