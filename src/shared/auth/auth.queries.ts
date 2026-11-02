import { queryOptions } from '@tanstack/react-query'

import { authApi } from './auth.api'

export const authQueryKeys = {
  twoFactorChallengeStatus: ['auth', 'browser-two-factor-challenge'] as const,
}

export const browserTwoFactorChallengeQueryOptions = () =>
  queryOptions({
    queryKey: authQueryKeys.twoFactorChallengeStatus,
    queryFn: ({ signal }) => authApi.browserTwoFactorChallengeStatus(signal),
    retry: false,
    staleTime: 0,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
