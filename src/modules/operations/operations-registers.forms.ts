import type { OperationsWorksite } from './operations-registers.api'

export function projectIdForWorksiteSelection(
  currentProjectId: string,
  selectedWorksiteId: string,
  worksites: OperationsWorksite[],
) {
  const selectedWorksite = worksites.find((site) => String(site.id) === selectedWorksiteId)
  return selectedWorksite?.project_id ? String(selectedWorksite.project_id) : currentProjectId
}
