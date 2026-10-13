/// Approval lifecycle for a work location. Mirrors backend `status` enum
/// ("PENDING" | "APPROVED" | "REJECTED") returned by `WorkLocationSchema`.
enum WorkspaceStatus { pending, approved, rejected, unknown }

extension WorkspaceStatusX on WorkspaceStatus {
  String get label {
    switch (this) {
      case WorkspaceStatus.pending:
        return 'Pending';
      case WorkspaceStatus.approved:
        return 'Approved';
      case WorkspaceStatus.rejected:
        return 'Rejected';
      case WorkspaceStatus.unknown:
        return 'Unknown';
    }
  }

  static WorkspaceStatus parse(dynamic raw) {
    final s = (raw?.toString() ?? '').toLowerCase();
    switch (s) {
      case 'approved':
        return WorkspaceStatus.approved;
      case 'pending':
        return WorkspaceStatus.pending;
      case 'rejected':
        return WorkspaceStatus.rejected;
      default:
        return WorkspaceStatus.unknown;
    }
  }
}

/// Flutter mirror of the backend `WorkLocationSchema`.
/// Endpoint: `GET /api/v1/biometric/location/whitelisted` (employee self)
/// and `GET /api/v1/biometric/location/pending` (admin all-pending).
///
/// The user never edits `radiusMeters` — it's set by the admin at approval
/// time (default 100m). It's stored here only so the client-side geofence
/// check at clock-in can use whatever the admin actually approved.
///
/// Clock-in eligibility is the backend-authoritative `can_be_used` field.
/// We still derive a client-side [canClockIn] fallback for defensiveness
/// when the backend response omits it.
class WorkspaceConfig {
  final int? id;
  final String workspaceName; // → name
  final String locationType; // → location_type (required by backend)
  final double latitude;
  final double longitude;
  final int radiusMeters; // → allowed_radius_meters (admin-controlled)
  final String? branchName;
  final int? branchId;
  final WorkspaceStatus status;
  final String? rejectionReason;
  final String? verifiedByName;
  final String? verifiedAt;
  final String? expiresAt;
  final bool isActive;
  final bool isExpired;
  final String? deactivatedAt;
  final String deactivationReason;
  final String deactivationNote;
  final bool? canBeUsed; // backend's authoritative clock-in gate
  final String notes;
  final int? employeeId; // admin-view: who submitted it
  final String? employeeName;
  final String? createdAt;
  final String? updatedAt;

  WorkspaceConfig({
    this.id,
    required this.workspaceName,
    this.locationType = 'branch',
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
    this.branchName,
    this.branchId,
    this.status = WorkspaceStatus.unknown,
    this.rejectionReason,
    this.verifiedByName,
    this.verifiedAt,
    this.expiresAt,
    this.isActive = true,
    this.isExpired = false,
    this.deactivatedAt,
    this.deactivationReason = '',
    this.deactivationNote = '',
    this.canBeUsed,
    this.notes = '',
    this.employeeId,
    this.employeeName,
    this.createdAt,
    this.updatedAt,
  });

  /// True when the workspace is in a state that allows clock-in.
  /// Prefers backend's `can_be_used`; falls back to a conservative
  /// client-side derivation if the field is missing.
  bool get canClockIn {
    if (canBeUsed != null) return canBeUsed!;
    // Defensive fallback for older responses that don't include can_be_used:
    // only grant eligibility when we have a positive approval signal.
    return status == WorkspaceStatus.approved && isActive && !isExpired;
  }

  String get lifecycleLabel {
    if (status == WorkspaceStatus.pending) return 'Pending approval';
    if (status == WorkspaceStatus.rejected) return 'Rejected';
    if (status != WorkspaceStatus.approved) return 'Unknown';
    if (isExpired || deactivationReason == 'expired') return 'Expired';
    if (!isActive && deactivationReason == 'admin') return 'Revoked';
    if (!isActive) return 'Inactive';
    return 'Active';
  }

  factory WorkspaceConfig.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v, {int fallback = 100}) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    // Backwards compat: older mock data may use `is_verified: true` instead
    // of the new `status: "APPROVED"`. Fold both into the new enum.
    WorkspaceStatus status;
    if (json.containsKey('status') && json['status'] != null) {
      status = WorkspaceStatusX.parse(json['status']);
    } else if (json['is_verified'] == true) {
      status = WorkspaceStatus.approved;
    } else {
      status = WorkspaceStatus.pending;
    }

    return WorkspaceConfig(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      workspaceName:
          json['name']?.toString() ?? json['workspace_name']?.toString() ?? '',
      locationType: json['location_type']?.toString() ?? 'branch',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      radiusMeters: parseInt(
        json['allowed_radius_meters'] ?? json['radius_meters'],
      ),
      branchName: json['branch_name']?.toString(),
      branchId: json['branch_id'] is int
          ? json['branch_id']
          : int.tryParse(json['branch_id']?.toString() ?? ''),
      status: status,
      rejectionReason: json['rejection_reason']?.toString(),
      verifiedByName: json['verified_by_name']?.toString() ??
          json['approved_by_name']?.toString(),
      verifiedAt:
          json['verified_at']?.toString() ?? json['approved_at']?.toString(),
      expiresAt:
          json['expires_at']?.toString() ?? json['expiry_date']?.toString(),
      isActive: json['is_active'] != false, // default true
      isExpired: json['is_expired'] == true,
      deactivatedAt: json['deactivated_at']?.toString(),
      deactivationReason: json['deactivation_reason']?.toString() ?? '',
      deactivationNote: json['deactivation_note']?.toString() ?? '',
      canBeUsed:
          json.containsKey('can_be_used') ? json['can_be_used'] == true : null,
      notes: json['notes']?.toString() ?? '',
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? ''),
      employeeName: json['employee_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class WorkLocationExtension {
  final int id;
  final int workLocationId;
  final String locationName;
  final int requestedById;
  final String requestedByName;
  final String requestedExpiresAt;
  final String? expiryAtRequest;
  final String reason;
  final String status;
  final String? reviewedByName;
  final String? reviewedAt;
  final String? approvedExpiresAt;
  final String decisionReason;
  final String createdAt;

  const WorkLocationExtension({
    required this.id,
    required this.workLocationId,
    required this.locationName,
    required this.requestedById,
    required this.requestedByName,
    required this.requestedExpiresAt,
    required this.expiryAtRequest,
    required this.reason,
    required this.status,
    required this.reviewedByName,
    required this.reviewedAt,
    required this.approvedExpiresAt,
    required this.decisionReason,
    required this.createdAt,
  });

  factory WorkLocationExtension.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    return WorkLocationExtension(
      id: asInt(json['id']),
      workLocationId: asInt(json['work_location_id']),
      locationName: json['location_name']?.toString() ?? '',
      requestedById: asInt(json['requested_by_id']),
      requestedByName: json['requested_by_name']?.toString() ?? '',
      requestedExpiresAt: json['requested_expires_at']?.toString() ?? '',
      expiryAtRequest: json['expiry_at_request']?.toString(),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      reviewedByName: json['reviewed_by_name']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      approvedExpiresAt: json['approved_expires_at']?.toString(),
      decisionReason: json['decision_reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class WorkLocationAuditEvent {
  final int id;
  final String eventType;
  final String? actorName;
  final String reason;
  final Map<String, dynamic> metadata;
  final String createdAt;

  const WorkLocationAuditEvent({
    required this.id,
    required this.eventType,
    required this.actorName,
    required this.reason,
    required this.metadata,
    required this.createdAt,
  });

  factory WorkLocationAuditEvent.fromJson(Map<String, dynamic> json) {
    return WorkLocationAuditEvent(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      eventType: json['event_type']?.toString() ?? '',
      actorName: json['actor_name']?.toString(),
      reason: json['reason']?.toString() ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
