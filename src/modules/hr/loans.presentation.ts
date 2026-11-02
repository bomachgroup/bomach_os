export function formatLoanCurrency(value: string | number) {
  const normalized = String(value).replaceAll(',', '').trim()
  const amount = Number(normalized)
  if (!normalized || !Number.isFinite(amount)) return String(value)

  return `₦${new Intl.NumberFormat('en-NG', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)}`
}

export function formatLoanDate(value: string | null | undefined) {
  if (!value) return 'Not scheduled'
  const datePart = value.slice(0, 10)
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(datePart)
  if (!match) return value

  const [, year, month, day] = match
  const date = new Date(Number(year), Number(month) - 1, Number(day))
  if (
    date.getFullYear() !== Number(year) ||
    date.getMonth() !== Number(month) - 1 ||
    date.getDate() !== Number(day)
  ) {
    return value
  }

  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(date)
}

export function formatLoanAmountInput(value: string) {
  const normalized = value.replaceAll(',', '')
  if (!/^\d*(?:\.\d*)?$/.test(normalized)) return null

  const [whole = '', fraction] = normalized.split('.')
  const groupedWhole = whole.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  return fraction === undefined ? groupedWhole : `${groupedWhole}.${fraction}`
}

export function groupedLoanCaretPosition(value: string, characterCount: number) {
  if (characterCount === 0) return 0
  let charactersSeen = 0
  for (let index = 0; index < value.length; index += 1) {
    if (value[index] !== ',') charactersSeen += 1
    if (charactersSeen >= characterCount) return index + 1
  }
  return value.length
}

export function loanStatusTone(status: string) {
  const normalized = status.toLocaleLowerCase()
  if (normalized === 'approved') return 'success' as const
  if (normalized === 'pending') return 'warning' as const
  if (normalized === 'rejected') return 'danger' as const
  return 'neutral' as const
}
