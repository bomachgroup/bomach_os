class RoleStakeholder {
  final int id;
  final int roleId;
  final String name;
  final String type;
  final String? organization;
  final String? communicationProtocol;
  final String? description;
  final int sortOrder;
  final bool isActive;

  RoleStakeholder({
    required this.id,
    required this.roleId,
    required this.name,
    this.type = 'internal',
    this.organization,
    this.communicationProtocol,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory RoleStakeholder.fromJson(Map<String, dynamic> json) {
    return RoleStakeholder(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'internal',
      organization: json['organization'],
      communicationProtocol: json['communication_protocol'],
      description: json['description'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'name': name,
      'type': type,
      'organization': organization,
      'communication_protocol': communicationProtocol,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  static const List<String> typeOptions = ['internal', 'external'];
}
