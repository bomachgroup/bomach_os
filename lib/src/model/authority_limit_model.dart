class AuthorityLimit {
  final String? id;
  final String roleId;
  final String resource;
  final String action;
  final double? maxAmount;
  final String? currency;
  final int? maxQuantity;
  final String? conditions;
  final String? approvalLevel;
  final List<int> requiredApproverRoleIds;
  final bool requiresSequentialApproval;
  final DateTime createdAt;
  final DateTime updatedAt;

  AuthorityLimit({
    this.id,
    required this.roleId,
    required this.resource,
    required this.action,
    this.maxAmount,
    this.currency,
    this.maxQuantity,
    this.conditions,
    this.approvalLevel,
    this.requiredApproverRoleIds = const [],
    this.requiresSequentialApproval = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthorityLimit.fromJson(Map<String, dynamic> json) {
    return AuthorityLimit(
      id: json['id']?.toString(),
      roleId: json['role_id']?.toString() ?? '',
      resource: json['resource']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      maxAmount: json['max_amount'] != null
          ? double.tryParse(json['max_amount'].toString())
          : null,
      currency: json['currency']?.toString(),
      maxQuantity: json['max_quantity'] != null
          ? int.tryParse(json['max_quantity'].toString())
          : null,
      conditions: json['conditions']?.toString(),
      approvalLevel: json['approval_level']?.toString(),
      requiredApproverRoleIds: json['required_approver_role_ids'] != null
          ? List<int>.from(json['required_approver_role_ids'])
          : [],
      requiresSequentialApproval: json['requires_sequential_approval'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'role_id': roleId,
      'resource': resource,
      'action': action,
      'max_amount': maxAmount,
      'currency': currency,
      'max_quantity': maxQuantity,
      'conditions': conditions,
      'approval_level': approvalLevel,
      'required_approver_role_ids': requiredApproverRoleIds,
      'requires_sequential_approval': requiresSequentialApproval,
    };
  }

  AuthorityLimit copyWith({
    String? id,
    String? roleId,
    String? resource,
    String? action,
    double? maxAmount,
    String? currency,
    int? maxQuantity,
    String? conditions,
    String? approvalLevel,
    List<int>? requiredApproverRoleIds,
    bool? requiresSequentialApproval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthorityLimit(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      resource: resource ?? this.resource,
      action: action ?? this.action,
      maxAmount: maxAmount ?? this.maxAmount,
      currency: currency ?? this.currency,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      conditions: conditions ?? this.conditions,
      approvalLevel: approvalLevel ?? this.approvalLevel,
      requiredApproverRoleIds: requiredApproverRoleIds ?? this.requiredApproverRoleIds,
      requiresSequentialApproval: requiresSequentialApproval ?? this.requiresSequentialApproval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}