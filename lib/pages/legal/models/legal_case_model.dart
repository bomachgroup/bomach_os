class LegalCase {
  final int id;
  final String caseName;
  final String caseType;
  final String caseTypeDisplay;
  final String status;
  final String statusDisplay;
  final String? exposure;
  final String? nextHearing;
  final String? caseNumber;
  final String description;
  final String? dateFiled;
  final String? dateClosed;
  final String createdAt;
  final String updatedAt;

  LegalCase({
    required this.id,
    required this.caseName,
    required this.caseType,
    required this.caseTypeDisplay,
    required this.status,
    required this.statusDisplay,
    this.exposure,
    this.nextHearing,
    this.caseNumber,
    required this.description,
    this.dateFiled,
    this.dateClosed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] ?? 0,
      caseName: json['case_name'] ?? '',
      caseType: json['case_type'] ?? '',
      caseTypeDisplay: json['case_type_display'] ?? json['case_type'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      exposure: json['exposure'],
      nextHearing: json['next_hearing'],
      caseNumber: json['case_number'],
      description: json['description'] ?? '',
      dateFiled: json['date_filed'],
      dateClosed: json['date_closed'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'case_name': caseName,
      'case_type': caseType,
      if (status.isNotEmpty) 'status': status,
      if (exposure != null && exposure!.isNotEmpty) 'exposure': exposure,
      if (nextHearing != null && nextHearing!.isNotEmpty)
        'next_hearing': nextHearing,
      if (caseNumber != null && caseNumber!.isNotEmpty)
        'case_number': caseNumber,
      if (description.isNotEmpty) 'description': description,
      if (dateFiled != null && dateFiled!.isNotEmpty) 'date_filed': dateFiled,
      if (dateClosed != null && dateClosed!.isNotEmpty)
        'date_closed': dateClosed,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'case_name': caseName,
      'case_type': caseType,
      'status': status,
      'exposure': exposure,
      'next_hearing': nextHearing,
      'case_number': caseNumber,
      'description': description,
      'date_filed': dateFiled,
      'date_closed': dateClosed,
    };
  }
}

class LegalCaseStatistics {
  final int totalCases;
  final int openCases;
  final int inProgressCases;
  final int settledCases;
  final int closedCases;
  final int wonCases;
  final int lostCases;
  final int dismissedCases;
  final int pendingCases;
  final String totalExposure;
  final int upcomingHearings;
  final Map<String, int> casesByType;

  LegalCaseStatistics({
    required this.totalCases,
    required this.openCases,
    required this.inProgressCases,
    required this.settledCases,
    required this.closedCases,
    required this.wonCases,
    required this.lostCases,
    required this.dismissedCases,
    required this.pendingCases,
    required this.totalExposure,
    required this.upcomingHearings,
    required this.casesByType,
  });

  factory LegalCaseStatistics.fromJson(Map<String, dynamic> json) {
    final casesByTypeRaw = json['cases_by_type'];
    final Map<String, int> casesByType = {};
    if (casesByTypeRaw is Map) {
      casesByTypeRaw.forEach((key, value) {
        casesByType[key.toString()] =
            value is int ? value : int.tryParse(value.toString()) ?? 0;
      });
    }

    return LegalCaseStatistics(
      totalCases: json['total_cases'] ?? 0,
      openCases: json['open_cases'] ?? 0,
      inProgressCases: json['in_progress_cases'] ?? 0,
      settledCases: json['settled_cases'] ?? 0,
      closedCases: json['closed_cases'] ?? 0,
      wonCases: json['won_cases'] ?? 0,
      lostCases: json['lost_cases'] ?? 0,
      dismissedCases: json['dismissed_cases'] ?? 0,
      pendingCases: json['pending_cases'] ?? 0,
      totalExposure: json['total_exposure']?.toString() ?? '0.00',
      upcomingHearings: json['upcoming_hearings'] ?? 0,
      casesByType: casesByType,
    );
  }
}
