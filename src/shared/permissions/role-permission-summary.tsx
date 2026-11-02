import { Check } from 'lucide-react'

import { Alert } from '@/shared/ui/alert'
import { StatusChip } from '@/shared/ui/status-chip'
import {
  getPermissionActionPresentation,
  permissionActionToneClasses,
} from './permission-action-presentation'
import { getPermissionAreaPresentation } from './permission-area-presentation'
import { getPermissionResourceLabel } from './permission-guidance'
import type { RolePermissionSummaryGroup } from './role-permission-groups'

function humanizePermissionAction(value: string) {
  return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export function RolePermissionSummary({ groups }: { groups: RolePermissionSummaryGroup[] }) {
  if (!groups.length) {
    return (
      <Alert role="status" tone="warning" title="This role grants no permissions">
        It can be saved, but it will not grant access to any work area.
      </Alert>
    )
  }

  return (
    <div
      role="region"
      aria-label="Selected permissions by work area"
      className="border-border-subtle bg-surface-muted/35 rounded-control max-h-[min(52dvh,32rem)] space-y-3 overflow-y-auto overscroll-contain border p-2.5 pr-1.5 sm:p-3"
    >
      {groups.map((area) => {
        const presentation = getPermissionAreaPresentation(area.id)
        const AreaIcon = presentation.icon
        const areaCount = area.resources.reduce((sum, [, actions]) => sum + actions.length, 0)

        return (
          <section
            key={area.id}
            className="bg-surface border-border-subtle rounded-control min-w-0 border p-3"
          >
            <div className="flex items-center gap-2">
              <span
                className={`${presentation.tone} rounded-control flex size-8 shrink-0 items-center justify-center`}
              >
                <AreaIcon className="size-4" aria-hidden="true" />
              </span>
              <h4 className="text-body-sm text-text-primary min-w-0 flex-1 font-semibold">
                {area.label}
              </h4>
              <StatusChip
                label={`${areaCount} ${areaCount === 1 ? 'permission' : 'permissions'}`}
                tone="info"
                dense
              />
            </div>
            <ul className="mt-3 grid gap-2 sm:grid-cols-2">
              {area.resources.map(([resource, actions]) => (
                <li
                  key={resource}
                  className="border-border-subtle bg-surface-muted/45 rounded-control min-w-0 border p-2.5"
                >
                  <span className="text-caption text-text-primary block font-semibold break-words">
                    {getPermissionResourceLabel(resource)}
                  </span>
                  <span className="mt-2 flex flex-wrap gap-1.5">
                    {actions.map((action) => {
                      const actionPresentation = getPermissionActionPresentation(action)
                      const ActionIcon = actionPresentation.icon

                      return (
                        <span
                          key={action}
                          className={`text-overline inline-flex min-h-7 max-w-full items-center gap-1.5 rounded-full border px-2 py-1 ${permissionActionToneClasses[actionPresentation.tone]}`}
                        >
                          <ActionIcon className="size-3.5 shrink-0" aria-hidden="true" />
                          <span className="break-words">{humanizePermissionAction(action)}</span>
                          <Check className="size-3 shrink-0 opacity-75" aria-hidden="true" />
                        </span>
                      )
                    })}
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )
      })}
    </div>
  )
}
