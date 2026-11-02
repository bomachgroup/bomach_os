import { z } from 'zod'

const schema = z.object({
  search: z.string().max(200).catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
  pageSize: z.coerce
    .number()
    .pipe(z.union([z.literal(5), z.literal(10), z.literal(20), z.literal(50)]))
    .catch(10),
  view: z.enum(['active', 'past']).catch('active'),
  branchId: z.union([z.literal('all'), z.string().regex(/^[1-9]\d{0,15}$/)]).catch('all'),
  departmentId: z.union([z.literal('all'), z.string().regex(/^[1-9]\d{0,15}$/)]).catch('all'),
})

export type EmployeesSearch = z.infer<typeof schema>
export const validateEmployeesSearch = (search: Record<string, unknown>) => schema.parse(search)

const profileSchema = z.object({
  section: z
    .enum([
      'profile',
      'documents',
      'reviews',
      'benefits',
      'performance-plan',
      'activity',
      'tasks',
      'work-reports',
      'leave',
    ])
    .catch('profile'),
})

export type EmployeeProfileSearch = z.infer<typeof profileSchema>
export const validateEmployeeProfileSearch = (search: Record<string, unknown>) =>
  profileSchema.parse(search)
