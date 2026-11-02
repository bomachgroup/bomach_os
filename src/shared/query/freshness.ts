/** Cache age thresholds. These are freshness windows, not polling intervals. */
export const DATA_FRESHNESS_MS = {
  live: 30_000,
  standard: 60_000,
  history: 120_000,
  reference: 300_000,
} as const
