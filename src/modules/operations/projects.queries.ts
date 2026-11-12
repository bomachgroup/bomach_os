import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { projectQueryKeys, projectsApi, type ProjectListParams } from './projects.api'

const standardRefresh = {
  staleTime: DATA_FRESHNESS_MS.standard,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
  retry: 1,
} as const

export const projectQueries = {
  overview: (userId: number, employeeId: string) =>
    queryOptions({
      queryKey: projectQueryKeys.overview(userId, employeeId),
      queryFn: ({ signal }) => projectsApi.overview(signal),
      ...standardRefresh,
      refetchInterval: 60_000,
      refetchIntervalInBackground: false,
    }),
  list: (userId: number, employeeId: string, params: ProjectListParams) =>
    queryOptions({
      queryKey: projectQueryKeys.list(userId, employeeId, params),
      queryFn: ({ signal }) => projectsApi.list(params, signal),
      ...standardRefresh,
      placeholderData: (previous) => previous,
    }),
  detail: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.detail(userId, employeeId, projectId),
      queryFn: ({ signal }) => projectsApi.detail(projectId, signal),
      ...standardRefresh,
    }),
  employees: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'members'),
      queryFn: ({ signal }) => projectsApi.employees(projectId, signal),
      ...standardRefresh,
    }),
  worksites: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'worksite'),
      queryFn: ({ signal }) => projectsApi.worksites(projectId, signal),
      ...standardRefresh,
    }),
  files: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'files'),
      queryFn: ({ signal }) => projectsApi.files(projectId, signal),
      ...standardRefresh,
    }),
  milestones: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'milestones'),
      queryFn: ({ signal }) => projectsApi.milestones(projectId, signal),
      ...standardRefresh,
    }),
  tasks: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'tasks'),
      queryFn: ({ signal }) => projectsApi.tasks(projectId, signal),
      ...standardRefresh,
    }),
  associates: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'associates'),
      queryFn: ({ signal }) => projectsApi.associates(projectId, signal),
      ...standardRefresh,
    }),
  meetings: (userId: number, employeeId: string, projectId: number) =>
    queryOptions({
      queryKey: projectQueryKeys.tab(userId, employeeId, projectId, 'meetings'),
      queryFn: ({ signal }) => projectsApi.meetings(projectId, signal),
      ...standardRefresh,
    }),
}
