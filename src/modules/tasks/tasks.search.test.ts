import { describe, expect, it } from 'vitest'

import { validateMyTasksSearch } from './tasks.search'

describe('validateMyTasksSearch', () => {
  it('normalizes URL values and parses a task detail ID', () => {
    expect(
      validateMyTasksSearch({
        status: 'pending',
        q: '  estimate  ',
        priority: 'high',
        sort: 'priority',
        page: '3',
        task: '42',
      }),
    ).toEqual({
      status: 'pending',
      q: 'estimate',
      priority: 'high',
      sort: 'priority',
      page: 3,
      task: 42,
    })
  })

  it('uses safe defaults for invalid or unsafe search values', () => {
    expect(
      validateMyTasksSearch({
        status: 'deleted',
        q: 'x'.repeat(121),
        priority: 'urgent',
        sort: 'random',
        page: '-1',
        task: 'not-a-number',
      }),
    ).toEqual({
      status: 'all',
      q: '',
      priority: 'all',
      sort: 'due_date',
      page: 1,
      task: undefined,
    })
  })
})
