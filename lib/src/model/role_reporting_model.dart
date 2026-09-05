class RoleReportingNode {
  final int? id;
  final String name;

  const RoleReportingNode({required this.id, required this.name});

  factory RoleReportingNode.fromJson(dynamic value) {
    if (value is Map) {
      return RoleReportingNode(
        id: _toInt(value['id'] ?? value['role_id']),
        name: value['name']?.toString() ??
            value['role_name']?.toString() ??
            'Unnamed role',
      );
    }
    return RoleReportingNode(id: _toInt(value), name: 'Role #$value');
  }
}

class RoleReportingTree {
  final int? roleId;
  final RoleReportingNode? reportsTo;
  final List<RoleReportingNode> directReports;

  const RoleReportingTree({
    required this.roleId,
    required this.reportsTo,
    required this.directReports,
  });

  factory RoleReportingTree.fromJson(Map<String, dynamic> json) {
    final rawDirectReports = json['direct_reports'] ?? json['children'];
    final directReports = rawDirectReports is Iterable
        ? rawDirectReports.map(RoleReportingNode.fromJson).toList()
        : const <RoleReportingNode>[];

    final rawReportsTo = json['reports_to'] ?? json['parent'];
    return RoleReportingTree(
      roleId: _toInt(json['role_id'] ?? json['id']),
      reportsTo: rawReportsTo == null
          ? null
          : RoleReportingNode.fromJson(rawReportsTo),
      directReports: directReports,
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
