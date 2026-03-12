import 'package:bms_front_end/src/model/board_model.dart';

// ─── APPROVAL FLOW MODEL ────────────────────────────────────────────

/// Model for an Approval Flow from /api/v1/approvals/flows/
/// TODO: Verify field names match actual API response — adjust as needed.
class ApprovalFlow {
  final int id;
  final String name;
  final String action;
  final String actionDisplay;
  final int levels;
  final List<String> approvers;
  final List<String> approverDisplays;
  final String status;
  final String statusDisplay;
  final String notes;
  final String createdAt;
  final String updatedAt;

  ApprovalFlow({
    required this.id,
    required this.name,
    required this.action,
    required this.actionDisplay,
    required this.levels,
    required this.approvers,
    required this.approverDisplays,
    required this.status,
    required this.statusDisplay,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApprovalFlow.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ApprovalFlow(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['workflow_name'] ?? '',
      action: json['action'] ?? json['action_type'] ?? '',
      actionDisplay: json['action_display'] ?? json['action'] ?? json['action_type'] ?? '',
      levels: json['levels'] is int
          ? json['levels']
          : int.tryParse(json['levels']?.toString() ?? '') ?? 0,
      approvers: parseStringList(json['approvers']),
      approverDisplays: parseStringList(json['approver_displays'] ?? json['approvers']),
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ─── APPROVAL REQUEST MODEL ─────────────────────────────────────────

/// Model for an Approval Request from /api/v1/approvals/requests/
/// TODO: Verify field names match actual API response — adjust as needed.
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
      requestTypeDisplay: json['request_type_display'] ?? json['request_type'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      requestedBy: json['requested_by']?.toString() ?? '',
      requestedByName: json['requested_by_name'] ?? json['requested_by_display'] ?? '',
      approvedBy: json['approved_by']?.toString(),
      rejectedBy: json['rejected_by']?.toString(),
      reason: json['reason'] ?? json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ─── APPROVAL FLOW CHOICES ──────────────────────────────────────────

/// Choices returned by GET /api/v1/approvals/flows/choices
/// TODO: Verify key names match actual API response.
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
          // If it's a list of strings or pairs
          final str = e.toString();
          return BoardFieldOption(value: str, label: str);
        }).toList();
      }
      return [];
    }

    return ApprovalFlowChoices(
      actions: parseOptions(json['actions'] ?? json['action_types'] ?? json['action']),
      approverTypes: parseOptions(json['approver_types'] ?? json['approvers']),
      statuses: parseOptions(json['statuses'] ?? json['status']),
      levels: parseOptions(json['levels']),
    );
  }
}
