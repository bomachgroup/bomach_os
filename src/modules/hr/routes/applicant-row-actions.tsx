import { Pencil, Trash2 } from 'lucide-react'

import { RecruitmentRowActions } from './recruitment-row-actions'

type ApplicantRowActionsProps = {
  applicantName: string
  canEdit: boolean
  canDelete: boolean
  editLoading?: boolean
  editDisabled?: boolean
  onEdit: () => void
  onDelete: () => void
}

export function ApplicantRowActions({
  applicantName,
  canEdit,
  canDelete,
  editLoading = false,
  editDisabled = false,
  onEdit,
  onDelete,
}: ApplicantRowActionsProps) {
  return (
    <RecruitmentRowActions
      recordLabel={applicantName}
      actions={[
        ...(canEdit
          ? [
              {
                id: 'edit',
                label: editLoading ? 'Loading candidate…' : 'Edit candidate',
                icon: Pencil,
                onSelect: onEdit,
                disabled: editLoading || editDisabled,
              },
            ]
          : []),
        ...(canDelete
          ? [
              {
                id: 'delete',
                label: 'Delete candidate',
                icon: Trash2,
                onSelect: onDelete,
                danger: true,
              },
            ]
          : []),
      ]}
    />
  )
}
