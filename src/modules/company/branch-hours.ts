import type { BranchBusinessHoursDto, BranchBusinessHoursInput } from './branches.api'

export const WEEKDAYS = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
]

export type DayScheduleDraft = {
  mode: 'unset' | 'closed' | 'open'
  openTime: string
  closeTime: string
}

export function blankSchedule(): DayScheduleDraft[] {
  return WEEKDAYS.map(() => ({ mode: 'unset', openTime: '', closeTime: '' }))
}

export function draftHours(hours: BranchBusinessHoursDto[] | undefined): DayScheduleDraft[] {
  const schedule = blankSchedule()
  for (const item of hours ?? []) {
    if (item.day_of_week < 0 || item.day_of_week > 6) continue
    schedule[item.day_of_week] = item.is_open
      ? {
          mode: 'open',
          openTime: item.open_time?.slice(0, 5) ?? '',
          closeTime: item.close_time?.slice(0, 5) ?? '',
        }
      : { mode: 'closed', openTime: '', closeTime: '' }
  }
  return schedule
}

export function toHours(schedule: DayScheduleDraft[]): BranchBusinessHoursInput[] {
  return schedule.flatMap((day, day_of_week) => {
    if (day.mode === 'unset') return []
    return [
      {
        day_of_week,
        is_open: day.mode === 'open',
        open_time: day.mode === 'open' ? day.openTime : null,
        close_time: day.mode === 'open' ? day.closeTime : null,
      },
    ]
  })
}

export function validateHoursDraft(schedule: DayScheduleDraft[]): string | null {
  for (const [index, day] of schedule.entries()) {
    if (day.mode !== 'open') continue
    if (!day.openTime || !day.closeTime) {
      return `Add opening and closing times for ${WEEKDAYS[index]}.`
    }
    if (day.closeTime <= day.openTime) {
      return `Closing time must be later than opening time on ${WEEKDAYS[index]}.`
    }
  }
  return null
}
