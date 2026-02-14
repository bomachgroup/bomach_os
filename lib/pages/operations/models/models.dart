class DashboardStats {
  final int activeProjects;
  final String totalBudget;
  final double budgetUtilization;
  final int totalTasks;
  final int totalWorksites;
  final int totalContracts;
  final int totalTimelines;

  DashboardStats({
    required this.activeProjects,
    required this.totalBudget,
    required this.budgetUtilization,
    required this.totalTasks,
    required this.totalWorksites,
    required this.totalContracts,
    required this.totalTimelines,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeProjects:
          int.tryParse(json['active_projects']?.toString() ?? '0') ?? 0,
      totalBudget: json['total_budget']?.toString() ?? "0",
      budgetUtilization:
          double.tryParse(json['budget_utilization']?.toString() ?? '0') ?? 0.0,
      totalTasks: int.tryParse(json['total_tasks']?.toString() ?? '0') ?? 0,
      totalWorksites:
          int.tryParse(json['total_worksites']?.toString() ?? '0') ?? 0,
      totalContracts:
          int.tryParse(json['total_contracts']?.toString() ?? '0') ?? 0,
      totalTimelines:
          int.tryParse(json['total_timelines']?.toString() ?? '0') ?? 0,
    );
  }
}

class Project {
  final int id;
  final String name;
  final String shortCode;
  final String category;
  final String department;
  final int clientId;
  final String location;
  final String priority;
  final String status;
  final String summary;
  final double budget;
  final double progress;
  final String startDate;
  final String deadline;
  final String fileUrl;

  Project({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.category,
    required this.department,
    required this.clientId,
    required this.location,
    required this.priority,
    required this.status,
    required this.summary,
    required this.budget,
    required this.progress,
    required this.startDate,
    required this.deadline,
    required this.fileUrl,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      shortCode: json['short_code']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      clientId: int.tryParse(json['client_id']?.toString() ?? '0') ?? 0,
      location: json['location']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0,
      startDate: json['start_date']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_code': shortCode,
      'category': category,
      'department': department,
      'client_id': clientId,
      'location': location,
      'priority': priority,
      'status': status,
      'summary': summary,
      'budget': budget,
      'progress': progress,
      'start_date': startDate,
      'deadline': deadline,
      'file_url': fileUrl,
    };
  }
}

class Task {
  final int id;
  final int projectId;
  final String name;
  final String description;
  final String status;
  final String priority;
  final List<int> assignedTo;
  final String dueDate;
  final double estimatedHours;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.dueDate,
    required this.estimatedHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['assigned_to'];
    List<int> assignedIds = [];
    if (list != null && list is List) {
      assignedIds = list.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    return Task(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      assignedTo: assignedIds,
      dueDate: json['due_date']?.toString() ?? '',
      estimatedHours:
          double.tryParse(json['estimated_hours']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'name': name,
      'description': description,
      'status': status,
      'priority': priority,
      'assigned_to': assignedTo,
      'due_date': dueDate,
      'estimated_hours': estimatedHours,
    };
  }
}

class Worksite {
  final int id;
  final int projectId;
  final String name;
  final String location;
  final String status;
  final String description;
  final String createdAt;
  final String updatedAt;

  Worksite({
    required this.id,
    required this.projectId,
    required this.name,
    required this.location,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Worksite.fromJson(Map<String, dynamic> json) {
    return Worksite(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'name': name,
      'location': location,
      'status': status,
      'description': description,
    };
  }
}

class Contract {
  final int id;
  final int projectId;
  final String contractNumber;
  final String contractType;
  final String status;
  final double value;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Contract({
    required this.id,
    required this.projectId,
    required this.contractNumber,
    required this.contractType,
    required this.status,
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      contractNumber: json['contract_number']?.toString() ?? '',
      contractType: json['contract_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'contract_number': contractNumber,
      'contract_type': contractType,
      'status': status,
      'value': value,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class TimelineModel {
  final int id;
  final int projectId;
  final String name;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  TimelineModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
