import { z } from 'zod'

const partnerDeskSchema = z.object({
  search: z.string().catch(''),
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type PartnerDeskSearch = z.infer<typeof partnerDeskSchema>

export function validatePartnerDeskSearch(search: Record<string, unknown>): PartnerDeskSearch {
  return partnerDeskSchema.parse(search)
}

const partnerDetailSchema = z.object({
  tab: z.enum(['contacts', 'messages']).catch('contacts'),
  conversation: z.coerce.number().int().positive().optional(),
})

export type PartnerDetailSearch = z.infer<typeof partnerDetailSchema>

export function validatePartnerDetailSearch(search: Record<string, unknown>): PartnerDetailSearch {
  return partnerDetailSchema.parse(search)
}

const partnerAppSchema = z.object({
  tab: z.enum(['home', 'work', 'messages', 'notifications', 'profile']).catch('home'),
  conversation: z.coerce.number().int().positive().optional(),
})

export type PartnerAppSearch = z.infer<typeof partnerAppSchema>

export function validatePartnerAppSearch(search: Record<string, unknown>): PartnerAppSearch {
  return partnerAppSchema.parse(search)
}

const partnerTwoFactorSchema = z.object({
  next: z.enum(['home', 'profile']).catch('home'),
})

export type PartnerTwoFactorSearch = z.infer<typeof partnerTwoFactorSchema>

export function validatePartnerTwoFactorSearch(
  search: Record<string, unknown>,
): PartnerTwoFactorSearch {
  return partnerTwoFactorSchema.parse(search)
}
