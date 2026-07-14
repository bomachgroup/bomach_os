class RoleKnowledgeEntry {
  final int id;
  final int? roleId;
  final String title;
  final String? description;
  final String category;
  final String? url;
  final String? filePath;
  final String? tags;
  final String uploadedBy;
  final String createdAt;
  final String updatedAt;

  RoleKnowledgeEntry({
    required this.id,
    this.roleId,
    required this.title,
    this.description,
    this.category = 'Reference',
    this.url,
    this.filePath,
    this.tags,
    this.uploadedBy = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RoleKnowledgeEntry.fromJson(Map<String, dynamic> json) {
    return RoleKnowledgeEntry(
      id: json['id'] ?? 0,
      roleId: json['role_id'],
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Reference',
      url: json['url'],
      filePath: json['file_path'],
      tags: json['tags'],
      uploadedBy: json['uploaded_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'title': title,
      'description': description,
      'category': category,
      'url': url,
      'file_path': filePath,
      'tags': tags,
    };
  }

  static const List<String> categoryOptions = [
    'SOP',
    'Policy',
    'Template',
    'Reference',
    'Guide',
    'Form',
  ];
}
