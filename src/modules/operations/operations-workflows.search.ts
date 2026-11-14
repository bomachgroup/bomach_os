type SearchRecord = Record<string, unknown>

function text(value: unknown, fallback = '') {
  return typeof value === 'string' ? value : fallback
}

function page(value: unknown) {
  const number = Number(value)
  return Number.isInteger(number) && number > 0 ? number : 1
}

export interface SurveyWorkflowSearch {
  search: string
  status: string
  employeeId: number | null
  projectId: number | null
  worksiteId: number | null
  dateFrom: string
  dateTo: string
  page: number
}

export function validateSurveyWorkflowSearch(search: SearchRecord): SurveyWorkflowSearch {
  const number = (value: unknown) => (Number(value) > 0 ? Number(value) : null)
  return {
    search: text(search.search),
    status: text(search.status, 'submitted'),
    employeeId: number(search.employeeId),
    projectId: number(search.projectId),
    worksiteId: number(search.worksiteId),
    dateFrom: text(search.dateFrom),
    dateTo: text(search.dateTo),
    page: page(search.page),
  }
}

export interface ContractWorkflowSearch {
  search: string
  status: string
  contractType: string
  page: number
}

export function validateContractWorkflowSearch(search: SearchRecord): ContractWorkflowSearch {
  return {
    search: text(search.search),
    status: text(search.status),
    contractType: text(search.contractType),
    page: page(search.page),
  }
}

export interface MeetingWorkflowSearch {
  search: string
  status: string
  locationType: string
  dateFrom: string
  dateTo: string
  projectId: number | null
  myMeetings: boolean
  page: number
}

export function validateMeetingWorkflowSearch(search: SearchRecord): MeetingWorkflowSearch {
  return {
    search: text(search.search),
    status: text(search.status),
    locationType: text(search.locationType),
    dateFrom: text(search.dateFrom),
    dateTo: text(search.dateTo),
    projectId: Number(search.projectId) > 0 ? Number(search.projectId) : null,
    myMeetings: search.myMeetings === true || search.myMeetings === 'true',
    page: page(search.page),
  }
}
