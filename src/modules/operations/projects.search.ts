export const PROJECT_TABS = [
  'overview',
  'members',
  'worksite',
  'files',
  'milestones',
  'tasks',
  'associates',
  'meetings',
] as const

export type ProjectTab = (typeof PROJECT_TABS)[number]

export interface ProjectsSearch {
  search: string
  status: string
  priority: string
  page: number
  archived: boolean
}

export interface ProjectDetailSearch {
  tab: ProjectTab
}

const PROJECT_STATUSES = ['planning', 'in_progress', 'on_hold', 'completed', 'cancelled']
const PROJECT_PRIORITIES = ['low', 'medium', 'high', 'critical']

function positivePage(value: unknown): number {
  const page = Number(value)
  return Number.isSafeInteger(page) && page > 0 && page <= 10000 ? page : 1
}

function booleanValue(value: unknown): boolean {
  return value === true || value === 'true' || value === '1'
}

export function validateProjectsSearch(search: Record<string, unknown>): ProjectsSearch {
  return {
    search: typeof search.search === 'string' ? search.search.trim().slice(0, 120) : '',
    status:
      typeof search.status === 'string' && PROJECT_STATUSES.includes(search.status)
        ? search.status
        : '',
    priority:
      typeof search.priority === 'string' && PROJECT_PRIORITIES.includes(search.priority)
        ? search.priority
        : '',
    page: positivePage(search.page),
    archived: booleanValue(search.archived),
  }
}

export function validateProjectDetailSearch(search: Record<string, unknown>): ProjectDetailSearch {
  return {
    tab:
      typeof search.tab === 'string' && PROJECT_TABS.includes(search.tab as ProjectTab)
        ? (search.tab as ProjectTab)
        : 'overview',
  }
}
