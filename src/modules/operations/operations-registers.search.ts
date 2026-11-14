const taskStatuses = ['active', 'all', 'pending', 'in_progress', 'completed', 'cancelled']
const siteStatuses = ['all', 'setup', 'active', 'inactive', 'completed']
const reportStatuses = ['submitted', 'all', 'draft', 'approved', 'rejected']

function pageValue(value: unknown): number {
  const page = Number(value)
  return Number.isSafeInteger(page) && page > 0 && page <= 10000 ? page : 1
}

function idValue(value: unknown): number | null {
  const id = Number(value)
  return Number.isSafeInteger(id) && id > 0 ? id : null
}

function textValue(value: unknown, max = 120): string {
  return typeof value === 'string' ? value.trim().slice(0, max) : ''
}

export interface WorksitesSearch {
  search: string
  status: string
  projectId: number | null
  page: number
}

export interface OperationsTasksSearch {
  search: string
  status: string
  priority: string
  projectId: number | null
  worksiteId: number | null
  page: number
}

export interface EngineeringReportsSearch {
  status: string
  employeeId: number | null
  projectId: number | null
  worksiteId: number | null
  dateFrom: string
  dateTo: string
  page: number
}

export function validateWorksitesSearch(search: Record<string, unknown>): WorksitesSearch {
  return {
    search: textValue(search.search),
    status:
      typeof search.status === 'string' && siteStatuses.includes(search.status)
        ? search.status
        : 'all',
    projectId: idValue(search.projectId),
    page: pageValue(search.page),
  }
}

export function validateOperationsTasksSearch(
  search: Record<string, unknown>,
): OperationsTasksSearch {
  return {
    search: textValue(search.search),
    status:
      typeof search.status === 'string' && taskStatuses.includes(search.status)
        ? search.status
        : 'active',
    priority: ['low', 'medium', 'high'].includes(String(search.priority))
      ? String(search.priority)
      : '',
    projectId: idValue(search.projectId),
    worksiteId: idValue(search.worksiteId),
    page: pageValue(search.page),
  }
}

export function validateEngineeringReportsSearch(
  search: Record<string, unknown>,
): EngineeringReportsSearch {
  return {
    status:
      typeof search.status === 'string' && reportStatuses.includes(search.status)
        ? search.status
        : 'submitted',
    employeeId: idValue(search.employeeId),
    projectId: idValue(search.projectId),
    worksiteId: idValue(search.worksiteId),
    dateFrom: textValue(search.dateFrom, 10),
    dateTo: textValue(search.dateTo, 10),
    page: pageValue(search.page),
  }
}
