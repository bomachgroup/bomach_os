import '../models/models.dart' as real;
import '../models/task_approval_models.dart' as approval;

extension TaskToApproval on real.Task {
  approval.Task toApprovalTask() {
    return approval.Task(
      id: id.toString(),
      code: '#$id',
      title: name,
      description: description,
      assignedTo: assignedTo.isNotEmpty ? assignedTo.first : '',
      assignedToId: assignedTo.isNotEmpty ? assignedTo.first : '',
      projectId: projectId.toString(),
      startDate: DateTime.now(),
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
      status: _mapStatus(status),
      priority: _mapPriority(priority),
      estimatedHours: estimatedHours,
    );
  }

  approval.TaskStatus _mapStatus(String s) {
    switch (s.toLowerCase().trim()) {
      case 'pending':
        return approval.TaskStatus.pending;
      case 'in_progress':
      case 'in progress':
        return approval.TaskStatus.inProgress;
      case 'completed':
        return approval.TaskStatus.completed;
      case 'on_hold':
      case 'on hold':
        return approval.TaskStatus.onHold;
      case 'rejected':
        return approval.TaskStatus.rejected;
      default:
        return approval.TaskStatus.pending;
    }
  }

  approval.TaskPriority _mapPriority(String s) {
    switch (s.toLowerCase().trim()) {
      case 'high':
        return approval.TaskPriority.high;
      case 'medium':
        return approval.TaskPriority.medium;
      case 'low':
        return approval.TaskPriority.low;
      default:
        return approval.TaskPriority.medium;
    }
  }
}
