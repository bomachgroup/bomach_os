import { z } from 'zod'

const currentDate = new Date()

const periodFields = {
  month: z.coerce
    .number()
    .int()
    .min(1)
    .max(12)
    .catch(currentDate.getMonth() + 1),
  year: z.coerce.number().int().min(2000).max(2100).catch(currentDate.getFullYear()),
}

const scorecardSchema = z.object(periodFields)
const evaluationSchema = z.object({
  ...periodFields,
  employee_id: z.coerce.number().int().positive().optional().catch(undefined),
})

export type ScorecardSearch = z.infer<typeof scorecardSchema>
export type EvaluationSearch = z.infer<typeof evaluationSchema>

export function validateScorecardSearch(search: Record<string, unknown>): ScorecardSearch {
  return scorecardSchema.parse(search)
}

export function validateEvaluationSearch(search: Record<string, unknown>): EvaluationSearch {
  return evaluationSchema.parse(search)
}
