class DecisionMatrixEntry {
  final int id;
  final int roleId;
  final String decisionType;
  final String? description;
  final bool canDecideAlone;
  final String? requiresApprovalFrom;
  final String? escalationPath;
  final String? conditions;
  final int sortOrder;
  final bool isActive;

  DecisionMatrixEntry({
    required this.id,
    required this.roleId,
    required this.decisionType,
    this.description,
    this.canDecideAlone = true,
    this.requiresApprovalFrom,
    this.escalationPath,
    this.conditions,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory DecisionMatrixEntry.fromJson(Map<String, dynamic> json) {
    return DecisionMatrixEntry(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      decisionType: json['decision_type'] ?? '',
      description: json['description'],
      canDecideAlone: json['can_decide_alone'] ?? true,
      requiresApprovalFrom: json['requires_approval_from'],
      escalationPath: json['escalation_path'],
      conditions: json['conditions'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'decision_type': decisionType,
      'description': description,
      'can_decide_alone': canDecideAlone,
      'requires_approval_from': requiresApprovalFrom,
      'escalation_path': escalationPath,
      'conditions': conditions,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
