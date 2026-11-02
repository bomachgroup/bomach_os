export type BrowserPermissionState = PermissionState | 'unknown'
export type BrowserPermissionName = 'camera' | 'geolocation'

/** Read a browser permission without prompting for it. The prompt is triggered only by a user action. */
export async function getBrowserPermissionState(
  name: BrowserPermissionName,
): Promise<BrowserPermissionState> {
  if (!navigator.permissions?.query) return 'unknown'
  try {
    const status = await navigator.permissions.query({ name } as PermissionDescriptor)
    return status.state
  } catch {
    // Camera permission queries are not implemented consistently across browsers.
    return 'unknown'
  }
}

export function permissionStateLabel(state: BrowserPermissionState | 'checking') {
  switch (state) {
    case 'granted':
      return 'Permission allowed'
    case 'prompt':
      return 'Browser will ask'
    case 'denied':
      return 'Blocked in browser'
    case 'checking':
      return 'Checking access'
    default:
      return 'Checked when started'
  }
}
