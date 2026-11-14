import { describe, expect, it } from 'vitest'

import type { OperationsWorksite } from './operations-registers.api'
import { projectIdForWorksiteSelection } from './operations-registers.forms'

const worksites = [
  { id: 53, project_id: 50 },
  { id: 54, project_id: null },
] as OperationsWorksite[]

describe('projectIdForWorksiteSelection', () => {
  it('selects the owning project when a project-linked site is chosen', () => {
    expect(projectIdForWorksiteSelection('', '53', worksites)).toBe('50')
  })

  it('preserves the current project when clearing or choosing a standalone site', () => {
    expect(projectIdForWorksiteSelection('50', '', worksites)).toBe('50')
    expect(projectIdForWorksiteSelection('', '54', worksites)).toBe('')
  })
})
