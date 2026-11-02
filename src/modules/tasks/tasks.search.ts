import { z } from 'zod'

const myTasksSearchSchema = z.object({
  status: z.enum(['all', 'pending', 'in_progress', 'completed']).catch('all'),
  priority: z.enum(['all', 'low', 'medium', 'high']).catch('all'),
  sort: z.enum(['due_date', 'priority']).catch('due_date'),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  task: z.number().int().positive().optional(),
})

export type MyTasksSearch = z.infer<typeof myTasksSearchSchema>

export function validateMyTasksSearch(search: Record<string, unknown>): MyTasksSearch {
  const rawTask = search.task
  const candidate = typeof rawTask === 'string' ? Number(rawTask) : rawTask
  const task =
    typeof candidate === 'number' && Number.isSafeInteger(candidate) && candidate > 0
      ? candidate
      : undefined
  return myTasksSearchSchema.parse({ ...search, task })
}
