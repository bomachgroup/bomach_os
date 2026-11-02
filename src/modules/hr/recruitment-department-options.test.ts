import { describe, expect, it } from 'vitest'

import type { DepartmentChoice, DepartmentDto } from '@/modules/company/company-organization.api'
import { postingDepartmentOptions } from './recruitment-department-options'

describe('postingDepartmentOptions', () => {
  it('uses numeric department IDs with the backend display labels', () => {
    const departments: DepartmentDto[] = [
      { id: 2, name: 'hr', description: '' },
      { id: 4, name: 'finance', description: '' },
    ]
    const choices: DepartmentChoice[] = [
      { value: 'hr', label: 'Human Resources' },
      { value: 'finance', label: 'Finance' },
    ]

    expect(postingDepartmentOptions(departments, choices)).toEqual([
      { value: '2', label: 'Human Resources' },
      { value: '4', label: 'Finance' },
    ])
  })

  it('keeps a usable label if the backend adds a department without a choice label', () => {
    expect(postingDepartmentOptions([{ id: 8, name: 'engineering', description: '' }], [])).toEqual(
      [{ value: '8', label: 'engineering' }],
    )
  })
})
