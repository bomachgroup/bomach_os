import { z } from 'zod'

const schema = z.object({
  tab: z
    .enum([
      'overview',
      'org-chart',
      'career-path',
      'kpis',
      'targets',
      'performance-analytics',
      'task-templates',
      'sops',
      'daily-routine',
      'training',
      'success-playbook',
      'resources',
    ])
    .catch('overview'),
})

export type RoleDetailSearch = z.infer<typeof schema>
export const validateRoleDetailSearch = (search: Record<string, unknown>) => schema.parse(search)
