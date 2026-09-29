import 'package:intl/intl.dart';

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
  final int? departmentId;
  final int? clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final List<String> employeeIds;
  final int? serviceOrderId;
  final String location;
  final String priority;
  final String status;
  final String summary;
  final double budget;
  final String budgetCurrency;
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
    this.departmentId,
    this.clientId,
    this.clientName = '',
    this.clientEmail = '',
    this.clientPhone = '',
    this.employeeIds = const [],
    this.serviceOrderId,
    required this.location,
    required this.priority,
    required this.status,
    required this.summary,
    required this.budget,
    this.budgetCurrency = 'NGN',
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
      departmentId: json['department_id'] == null
          ? null
          : int.tryParse(json['department_id'].toString()),
      clientId: json['client_id'] == null
          ? null
          : int.tryParse(json['client_id'].toString()),
      clientName: json['client_name']?.toString() ??
          (json['client'] is Map
              ? json['client']['name']?.toString() ?? ''
              : ''),
      clientEmail: json['client_email']?.toString() ??
          (json['client'] is Map
              ? json['client']['email']?.toString() ?? ''
              : ''),
      clientPhone: json['client_phone']?.toString() ??
          (json['client'] is Map
              ? json['client']['phone']?.toString() ?? ''
              : ''),
      employeeIds: (json['employee_ids'] is List
              ? json['employee_ids'] as List
              : json['employees'] is List
                  ? (json['employees'] as List)
                      .map((row) => row is Map ? row['id'] : row)
                      .toList()
                  : const <dynamic>[])
          .map((id) => id.toString())
          .toList(),
      serviceOrderId: json['service_order_id'] == null
          ? null
          : int.tryParse(json['service_order_id'].toString()),
      location: json['location']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      budgetCurrency: json['budget_currency']?.toString() ??
          json['currency']?.toString() ??
          'NGN',
      progress: double.tryParse(json['progress']?.toString() ?? '0') ?? 0.0,
      startDate: json['start_date']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson({bool includeStatus = true}) {
    return {
      'name': name,
      'short_code': shortCode,
      'category': category,
      if (departmentId != null) 'department_id': departmentId,
      if (clientId != null) 'client_id': clientId,
      'employee_ids': employeeIds.map(int.tryParse).whereType<int>().toList(),
      if (serviceOrderId != null) 'service_order_id': serviceOrderId,
      'location': location,
      'priority': priority,
      'summary': summary,
      'budget': budget,
      'budget_currency': budgetCurrency,
      'progress': progress,
      'start_date': startDate,
      'deadline': deadline,
      'file_url': fileUrl,
      if (includeStatus) 'status': status,
    };
  }

  String get formattedBudget => NumberFormat('#,##0.##').format(budget);
}

class Task {
  final int id;
  final int projectId;
  final int? milestoneId;
  final String name;
  final String description;
  final String status;
  final String priority;
  final List<String> assignedTo;
  final String dueDate;
  final double estimatedHours;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.projectId,
    this.milestoneId,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedTo, // List<String> of employee IDs
    required this.dueDate,
    required this.estimatedHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['assigned_to'];
    List<String> assignedIds = [];
    if (list != null && list is List) {
      assignedIds = list.map((e) => e.toString()).toList();
    }

    return Task(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      milestoneId: json['milestone_id'] != null
          ? int.tryParse(json['milestone_id'].toString())
          : null,
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
      'project_id': projectId == 0 ? null : projectId,
      if (milestoneId != null) 'milestone_id': milestoneId,
      'name': name,
      'description': description.isEmpty ? null : description,
      'status': status,
      'priority': priority,
      'assigned_to': assignedTo,
      'due_date': dueDate.isEmpty ? null : dueDate,
      'estimated_hours': estimatedHours > 0 ? estimatedHours : null,
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
  final int? clientId;
  final int? leadId;
  final String createdAt;
  final String updatedAt;

  Worksite({
    required this.id,
    required this.projectId,
    required this.name,
    required this.location,
    required this.status,
    required this.description,
    this.clientId,
    this.leadId,
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
      clientId: json['client_id'] == null
          ? null
          : int.tryParse(json['client_id'].toString()),
      leadId: json['lead_id'] == null
          ? null
          : int.tryParse(json['lead_id'].toString()),
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
      'client_id': clientId,
      'lead_id': leadId,
    };
  }
}

class Contract {
  final int id;
  final int projectId;
  final String name;
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
    required this.name,
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
      name: json['name']?.toString() ?? '',
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
      'name': name,
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

class Milestone {
  final int id;
  final int projectId;
  final String name;
  final String description;
  final String priority;
  final String status;
  final String budget;
  final int progress;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Milestone({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    required this.budget,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      budget: json['budget']?.toString() ?? '0',
      progress: int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
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
      'description': description.isEmpty ? null : description,
      'priority': priority,
      'status': status,
      'budget': budget.isEmpty ? null : budget,
      'progress': progress,
      'start_date': startDate.isEmpty ? null : startDate,
      'end_date': endDate.isEmpty ? null : endDate,
    };
  }
}

class SiteEquipment {
  final int id;
  final int worksiteId;
  final String name;
  final String unitValue;
  final String createdAt;
  final String updatedAt;

  SiteEquipment({
    required this.id,
    required this.worksiteId,
    required this.name,
    required this.unitValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SiteEquipment.fromJson(Map<String, dynamic> json) {
    return SiteEquipment(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      worksiteId: int.tryParse(json['worksite_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      unitValue: json['unit_value']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'worksite_id': worksiteId, 'name': name, 'unit_value': unitValue};
  }
}

class ProjectEmployee {
  final String id;
  final String employeeId;
  final String email;
  final String fullName;
  final String phone;
  final String position;
  final bool isActive;
  final String departmentName;
  final String branchName;
  final String employmentType;

  ProjectEmployee({
    required this.id,
    required this.employeeId,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.position,
    required this.isActive,
    required this.departmentName,
    required this.branchName,
    required this.employmentType,
  });

  factory ProjectEmployee.fromJson(Map<String, dynamic> json) {
    return ProjectEmployee(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      isActive: json['is_active'] == true,
      departmentName: json['department_name']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      employmentType: json['employment_type']?.toString() ?? '',
    );
  }
}
