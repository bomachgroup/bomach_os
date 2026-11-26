import { describe, expect, it, vi } from 'vitest'

import { openNotificationHref } from './open-notification-href'

describe('openNotificationHref', () => {
  it('passes internal paths and query parameters separately to the router', () => {
    const navigate = vi.fn()

    openNotificationHref('/company/partners/17?tab=messages&conversation=4#latest', navigate)

    expect(navigate).toHaveBeenCalledWith({
      to: '/company/partners/17',
      search: { tab: 'messages', conversation: '4' },
      hash: '#latest',
    })
  })

  it('supports internal paths without a query or hash', () => {
    const navigate = vi.fn()

    openNotificationHref('/notifications', navigate)

    expect(navigate).toHaveBeenCalledWith({
      to: '/notifications',
      search: {},
      hash: undefined,
    })
  })
})
