import { z } from 'zod'

const schema = z.object({
  search: z.string().max(200).catch(''),
  status: z.enum(['all', 'pending', 'in_progress', 'completed', 'cancelled']).catch('all'),
  audience: z
    .enum([
      'all',
      'all_employees',
      'management',
      'new_hires',
      'department_specific',
      'leadership_team',
      'technical_staff',
      'sales_team',
      'customer_service',
    ])
    .catch('all'),
  program_id: z.coerce.number().int().positive().optional().catch(undefined),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  pageSize: z
    .number()
    .int()
    .or(
      z
        .string()
        .regex(/^(10|20|50)$/)
        .transform(Number),
    )
    .pipe(z.union([z.literal(10), z.literal(20), z.literal(50)]))
    .catch(10),
})

export type TrainingProgramsSearch = z.infer<typeof schema>

export function validateTrainingProgramsSearch(
  search: Record<string, unknown>,
): TrainingProgramsSearch {
  return schema.parse(search)
}
