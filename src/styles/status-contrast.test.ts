import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

import { describe, expect, it } from 'vitest'

const styles = readFileSync(resolve(process.cwd(), 'src/styles/index.css'), 'utf8')

function colorToken(name: string) {
  const match = styles.match(new RegExp(`--color-${name}:\\s*(#[0-9a-fA-F]{6})\\b`))
  expect(match, `CSS color token --color-${name} must be declared`).not.toBeNull()
  return match![1]
}

function luminance(hex: string) {
  const [red, green, blue] = hex
    .slice(1)
    .match(/../g)!
    .map((channel) => parseInt(channel, 16) / 255)
    .map((channel) => (channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4))

  return 0.2126 * red + 0.7152 * green + 0.0722 * blue
}

function contrastRatio(foreground: string, background: string) {
  const first = luminance(foreground)
  const second = luminance(background)
  return (Math.max(first, second) + 0.05) / (Math.min(first, second) + 0.05)
}

describe('semantic status text colors', () => {
  it.each(['success', 'warning', 'danger', 'info'])(
    '%s foreground meets normal-text AA contrast',
    (tone) => {
      expect(
        contrastRatio(colorToken(`${tone}-foreground`), colorToken(`${tone}-subtle`)),
      ).toBeGreaterThanOrEqual(4.5)
    },
  )
})
