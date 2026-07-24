class RoleSuccessPlaybook {
  final int id;
  final int roleId;
  final String title;
  final String description;
  final String kind; // e.g. best_practice, common_mistake, winning_strategy, lesson_learned
  final int sequence;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleSuccessPlaybook({
    required this.id,
    required this.roleId,
    required this.title,
    this.description = '',
    required this.kind,
    this.sequence = 1,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleSuccessPlaybook.fromJson(Map<String, dynamic> json) {
    return RoleSuccessPlaybook(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      kind: json['kind'] ?? 'best_practice',
      sequence: json['sequence'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'kind': kind,
      if (description.isNotEmpty) 'description': description,
      'sequence': sequence,
      'is_active': isActive,
    };
  }

  static const List<Map<String, String>> kindOptions = [
    {'value': 'best_practice', 'label': 'Best Practice'},
    {'value': 'common_mistake', 'label': 'Common Mistake'},
    {'value': 'winning_strategy', 'label': 'Winning Strategy'},
    {'value': 'lesson_learned', 'label': 'Lesson Learned'},
  ];
}
