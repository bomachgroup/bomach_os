import { describe, expect, it } from 'vitest'

import { draftHours, toHours } from './branch-hours'

describe('branch business-hours mapping', () => {
  it('keeps unset days distinct from closed days and preserves open-day times', () => {
    const draft = draftHours([
      {
        id: 1,
        day_of_week: 0,
        day_name: 'Monday',
        open_time: null,
        close_time: null,
        is_open: false,
      },
      {
        id: 2,
        day_of_week: 2,
        day_name: 'Wednesday',
        open_time: '08:30:00',
        close_time: '16:45:00',
        is_open: true,
      },
    ])

    expect(draft[0]).toEqual({ mode: 'closed', openTime: '', closeTime: '' })
    expect(draft[1]).toEqual({ mode: 'unset', openTime: '', closeTime: '' })
    expect(draft[2]).toEqual({ mode: 'open', openTime: '08:30', closeTime: '16:45' })
    expect(toHours(draft)).toEqual([
      { day_of_week: 0, is_open: false, open_time: null, close_time: null },
      { day_of_week: 2, is_open: true, open_time: '08:30', close_time: '16:45' },
    ])
  })
})
