export function formatRecruitmentMoney(value: string | null | undefined) {
  if (value == null || value.trim() === '') return 'Not specified'
  const amount = Number(value)
  if (!Number.isFinite(amount)) return value

  const formatted = new Intl.NumberFormat('en-NG', { maximumFractionDigits: 2 }).format(amount)
  return `₦${formatted}`
}
