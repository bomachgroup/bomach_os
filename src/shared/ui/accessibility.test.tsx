import axe from 'axe-core'
import { render } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Alert } from './alert'
import { Button } from './button'
import { FormControl, TextInput } from './form-control'
import { StatusChip } from './status-chip'

describe('shared UI accessibility', () => {
  it('has no basic axe violations in a representative form and feedback composition', async () => {
    const { container } = render(
      <main>
        <h1>Company profile</h1>
        <FormControl id="company-name" label="Company name" required description="Legal name.">
          <TextInput />
        </FormControl>
        <Button>Save company</Button>
        <StatusChip label="Active" tone="success" />
        <Alert role="status">Changes are saved.</Alert>
      </main>,
    )

    const results = await axe.run(container, {
      rules: { 'color-contrast': { enabled: false } },
    })

    expect(results.violations.map(({ id }) => id)).toEqual([])
  })
})
