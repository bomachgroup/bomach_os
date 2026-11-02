const DEPARTMENT_CATEGORY_LABELS: Record<string, string> = {
  operations: 'Operations',
  marketing: 'Marketing',
  finance: 'Finance',
  it: 'IT',
  hr: 'HR',
  'human resources': 'HR',
  legal: 'Legal',
}

/** Formats a saved department category for people while leaving API values unchanged. */
export function departmentCategoryLabel(value: string): string {
  const normalized = value.trim().toLocaleLowerCase('en')
  const knownLabel = DEPARTMENT_CATEGORY_LABELS[normalized]
  if (knownLabel) return knownLabel

  return normalized
    .replace(/[_-]+/g, ' ')
    .replace(/\b\w/g, (character) => character.toLocaleUpperCase('en'))
}
