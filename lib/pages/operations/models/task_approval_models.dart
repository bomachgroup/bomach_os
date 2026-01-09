/// Task Approval Models for Operations Module
library task_approval_models;

/// Task status enum
enum TaskStatus {
  pending('Pending', '⏳'),
  inProgress('In Progress', '🔄'),
  completed('Completed', '✅'),
  onHold('On Hold', '⏸'),
  rejected('Rejected', '❌');

  final String displayName;
  final String emoji;

  const TaskStatus(this.displayName, this.emoji);

  String getColor() {
    switch (this) {
      case TaskStatus.pending:
        return '#94A3B8';
      case TaskStatus.inProgress:
        return '#3B82F6';
      case TaskStatus.completed:
        return '#16A34A';
      case TaskStatus.onHold:
        return '#F59E0B';
      case TaskStatus.rejected:
        return '#EF4444';
    }
  }
}

/// Task priority enum
enum TaskPriority {
  low('Low', '🟢'),
  medium('Medium', '🟡'),
  high('High', '🔴');

  final String displayName;
  final String emoji;

  const TaskPriority(this.displayName, this.emoji);
}

/// Task approval action enum
enum TaskApprovalAction { approve, reject, requestRework }

/// Task data model
class Task {
  final String id;
  final String code;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToId;
  final String projectId;
  final DateTime startDate;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final double estimatedHours;
  final double? actualHours;
  final List<String> attachments;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? reworkNotes;
  final List<TaskComment>? comments;

  Task({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToId,
    required this.projectId,
    required this.startDate,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.estimatedHours,
    this.actualHours,
    this.attachments = const [],
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.reworkNotes,
    this.comments,
  });

  /// Calculate days remaining
  int get daysRemaining {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Check if task is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != TaskStatus.completed;
  }

  /// Copy with method for immutability
  Task copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToId,
    String? projectId,
    DateTime? startDate,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    double? estimatedHours,
    double? actualHours,
    List<String>? attachments,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? reworkNotes,
    List<TaskComment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToId: assignedToId ?? this.assignedToId,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      attachments: attachments ?? this.attachments,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reworkNotes: reworkNotes ?? this.reworkNotes,
      comments: comments ?? this.comments,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToId': assignedToId,
      'projectId': projectId,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.displayName,
      'priority': priority.displayName,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'attachments': attachments,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'reworkNotes': reworkNotes,
    };
  }
}

/// Task comment model
class TaskComment {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String content;
  final DateTime createdAt;
  final List<String>? attachments;

  TaskComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
    };
  }
}

/// Task approval result
class TaskApprovalResult {
  final TaskApprovalAction action;
  final String feedback;
  final String? reworkInstructions;
  final int? rating; // 1-5 star rating
  final DateTime approvedAt;

  TaskApprovalResult({
    required this.action,
    required this.feedback,
    this.reworkInstructions,
    this.rating,
    required this.approvedAt,
  });
}
