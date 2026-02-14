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
      activeProjects: json['active_projects'] ?? 0,
      totalBudget: json['total_budget']?.toString() ?? "0",
      budgetUtilization: (json['budget_utilization'] ?? 0).toDouble(),
      totalTasks: json['total_tasks'] ?? 0,
      totalWorksites: json['total_worksites'] ?? 0,
      totalContracts: json['total_contracts'] ?? 0,
      totalTimelines: json['total_timelines'] ?? 0,
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortCode: json['short_code'] ?? '',
      category: json['category'] ?? '',
      department: json['department'] ?? '',
      clientId: json['client_id'] ?? 0,
      location: json['location'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      summary: json['summary'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      progress: (json['progress'] ?? 0).toDouble(),
      startDate: json['start_date'] ?? '',
      deadline: json['deadline'] ?? '',
      fileUrl: json['file_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    return Task(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      assignedTo:
          (json['assigned_to'] as List?)?.map((e) => e as int).toList() ?? [],
      dueDate: json['due_date'] ?? '',
      estimatedHours: (json['estimated_hours'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      contractNumber: json['contract_number'] ?? '',
      contractType: json['contract_type'] ?? '',
      status: json['status'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
