import 'package:bms_front_end/src/model/board_model.dart';

// ─── APPROVAL FLOW MODEL ────────────────────────────────────────────

class ApprovalFlow {
  final int id;
  final String name;
  final String action;
  final String actionDisplay;
  final bool isActive;
  final String description;
  final List<ApprovalFlowStep> steps;
  final String createdAt;
  final String updatedAt;

  // Derived display helpers
  String get status => isActive ? 'active' : 'inactive';
  String get statusDisplay => isActive ? 'Active' : 'Inactive';
  // Kept for backwards compat with ViewWorkflowDialog
  int get levels => steps.length;
  List<String> get approvers =>
      steps.map((s) => s.requiredLevel).where((s) => s.isNotEmpty).toList();
  List<String> get approverDisplays => approvers;
  String get notes => description;

  ApprovalFlow({
    required this.id,
    required this.name,
    required this.action,
    required this.actionDisplay,
    required this.isActive,
    this.description = '',
    this.steps = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApprovalFlow.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final parsedSteps = rawSteps is List
        ? rawSteps.map((s) => ApprovalFlowStep.fromJson(s)).toList()
        : <ApprovalFlowStep>[];

    return ApprovalFlow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      action: json['action_type'] ?? json['action'] ?? '',
      actionDisplay: json['action_type_display'] ??
          json['action_type'] ??
          json['action'] ??
          '',
      isActive: json['is_active'] ?? true,
      description: json['description'] ?? json['notes'] ?? '',
      steps: parsedSteps,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ─── APPROVAL FLOW STEP ──────────────────────────────────────────────

class ApprovalFlowStep {
  final int stepOrder;
  final String stepName;
  final String requiredLevel;

  ApprovalFlowStep({
    required this.stepOrder,
    required this.stepName,
    required this.requiredLevel,
  });

  factory ApprovalFlowStep.fromJson(Map<String, dynamic> json) {
    return ApprovalFlowStep(
      stepOrder: json['step_order'] ?? 0,
      stepName: json['step_name'] ?? '',
      requiredLevel: json['required_level'] ?? '',
    );
  }
}

// ─── APPROVAL REQUEST MODEL ─────────────────────────────────────────

class ApprovalRequest {
  final int id;
  final int flowId;
  final String flowName;
  final String requestType;
  final String requestTypeDisplay;
  final String status;
  final String statusDisplay;
  final String requestedBy;
  final String requestedByName;
  final String? approvedBy;
  final String? rejectedBy;
  final String reason;
  final String createdAt;
  final String updatedAt;

  ApprovalRequest({
    required this.id,
    required this.flowId,
    this.flowName = '',
    required this.requestType,
    this.requestTypeDisplay = '',
    required this.status,
    this.statusDisplay = '',
    required this.requestedBy,
    this.requestedByName = '',
    this.approvedBy,
    this.rejectedBy,
    this.reason = '',
    required this.createdAt,
    this.updatedAt = '',
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] ?? 0,
      flowId: json['flow_id'] ?? json['flow'] ?? 0,
      flowName: json['flow_name'] ?? json['flow_display'] ?? '',
      requestType: json['request_type'] ?? json['action'] ?? '',
      requestTypeDisplay:
          json['request_type_display'] ?? json['request_type'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      requestedBy: json['requested_by']?.toString() ?? '',
      requestedByName:
          json['requested_by_name'] ?? json['requested_by_display'] ?? '',
      approvedBy: json['approved_by']?.toString(),
      rejectedBy: json['rejected_by']?.toString(),
      reason: json['reason'] ?? json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ─── APPROVAL FLOW CHOICES ──────────────────────────────────────────

class ApprovalFlowChoices {
  final List<BoardFieldOption> actions;
  final List<BoardFieldOption> approverTypes;
  final List<BoardFieldOption> statuses;
  final List<BoardFieldOption> levels;

  ApprovalFlowChoices({
    required this.actions,
    required this.approverTypes,
    required this.statuses,
    required this.levels,
  });

  factory ApprovalFlowChoices.fromJson(Map<String, dynamic> json) {
    List<BoardFieldOption> parseOptions(dynamic raw) {
      if (raw is List) {
        return raw.map((e) {
          if (e is Map<String, dynamic>) {
            return BoardFieldOption(
              value: e['value']?.toString() ?? '',
              label: e['label']?.toString() ?? e['display']?.toString() ?? '',
            );
          }
          final str = e.toString();
          return BoardFieldOption(value: str, label: str);
        }).toList();
      }
      return [];
    }

    return ApprovalFlowChoices(
      actions: parseOptions(
          json['action_types'] ?? json['actions'] ?? json['action']),
      approverTypes: parseOptions(json['approver_types'] ?? json['approvers']),
      statuses: parseOptions(json['statuses'] ?? json['status']),
      levels: parseOptions(json['levels']),
    );
  }
}
