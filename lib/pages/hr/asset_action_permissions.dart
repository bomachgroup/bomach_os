List<String> visibleAssetActions({
  required bool canEdit,
  required bool canDelete,
}) => [
      'view',
      if (canEdit) 'edit',
      if (canDelete) 'delete',
    ];
