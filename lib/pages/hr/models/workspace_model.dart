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
  final WorkspaceStatus status;
  final String? rejectionReason;
  final String? verifiedByName;
  final String? verifiedAt;
  final String? expiresAt;
  final bool isActive;
  final bool isExpired;
  final bool canBeUsed; // backend's authoritative clock-in gate
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
    this.status = WorkspaceStatus.unknown,
    this.rejectionReason,
    this.verifiedByName,
    this.verifiedAt,
    this.expiresAt,
    this.isActive = true,
    this.isExpired = false,
    this.canBeUsed = false,
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
    if (canBeUsed) return true;
    // Defensive fallback for older responses that don't include can_be_used:
    // only grant eligibility when we have a positive approval signal.
    return status == WorkspaceStatus.approved && isActive && !isExpired;
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
      workspaceName: json['name']?.toString() ??
          json['workspace_name']?.toString() ??
          '',
      locationType:
          json['location_type']?.toString() ?? 'branch',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      radiusMeters: parseInt(
        json['allowed_radius_meters'] ?? json['radius_meters'],
      ),
      branchName: json['branch_name']?.toString(),
      status: status,
      rejectionReason: json['rejection_reason']?.toString(),
      verifiedByName: json['verified_by_name']?.toString() ??
          json['approved_by_name']?.toString(),
      verifiedAt: json['verified_at']?.toString() ??
          json['approved_at']?.toString(),
      expiresAt: json['expires_at']?.toString() ??
          json['expiry_date']?.toString(),
      isActive: json['is_active'] != false, // default true
      isExpired: json['is_expired'] == true,
      canBeUsed: json['can_be_used'] == true,
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
