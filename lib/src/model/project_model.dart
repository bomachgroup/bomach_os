class ProjectModel {
  final int id;
  final String projectCode;
  final String projectName;
  final List<String> members;
  final String client;
  final int status;

  ProjectModel({required this.id, required this.projectCode, required this.projectName, required this.members, required this.client, required this.status,});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      projectCode: json['projectCode'],
      projectName: json['projectName'],
      members: json['members'],
      client: json['client'],
      status: json['status'],
    );
  }
}
