import type { DepartmentChoice, DepartmentDto } from '@/modules/company/company-organization.api'

export function postingDepartmentOptions(
  departments: DepartmentDto[],
  choices: DepartmentChoice[],
): DepartmentChoice[] {
  const labelsByName = new Map(choices.map(({ value, label }) => [value, label]))

  return departments.map((department) => ({
    value: String(department.id),
    label: labelsByName.get(department.name) ?? department.name,
  }))
}
