import { z } from 'zod'

export const BOARD_SECTIONS = [
  'meetings',
  'resolutions',
  'investors',
  'associates',
  'partners',
] as const
export type BoardSection = (typeof BOARD_SECTIONS)[number]

const boardSearchSchema = z.object({
  tab: z.enum(BOARD_SECTIONS).catch('meetings'),
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type BoardSearch = z.infer<typeof boardSearchSchema>

export function validateBoardSearch(search: Record<string, unknown>): BoardSearch {
  return boardSearchSchema.parse(search)
}

const complianceSearchSchema = z.object({
  search: z.string().catch(''),
  complianceType: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type ComplianceSearch = z.infer<typeof complianceSearchSchema>

export function validateComplianceSearch(search: Record<string, unknown>): ComplianceSearch {
  return complianceSearchSchema.parse(search)
}
