bool isValidSurveyAttachmentUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      uri.hasAuthority &&
      (uri.scheme == 'https' || uri.scheme == 'http');
}

bool hasValidSurveyActivities(List<SurveyActivity> activities) =>
    activities.any((item) => item.description.trim().isNotEmpty);

bool hasValidBearingDistancePoints(List<BearingDistancePoint> points) {
  if (points.isEmpty) return false;
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final seconds = double.tryParse(p.azimuthSeconds);
    final distance = double.tryParse(p.distance);
    if (p.pointNumber != i + 1 ||
        p.azimuthDegrees < 0 ||
        p.azimuthDegrees > 359 ||
        p.azimuthMinutes < 0 ||
        p.azimuthMinutes > 59 ||
        seconds == null ||
        seconds < 0 ||
        seconds >= 60 ||
        distance == null ||
        distance <= 0) return false;
  }
  return true;
}

bool hasValidXyzPoints(List<XyzSurveyPoint> points) {
  if (points.isEmpty) return false;
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    if (p.pointNumber != i + 1 ||
        [p.northing, p.easting, p.elevation]
            .any((v) => double.tryParse(v) == null)) return false;
  }
  return true;
}

bool hasPairedGpsCoordinates(String? latitude, String? longitude) =>
    (latitude == null || latitude.trim().isEmpty) ==
    (longitude == null || longitude.trim().isEmpty);

class SurveyActivity {
  const SurveyActivity({required this.description});
  final String description;
  factory SurveyActivity.fromJson(Map<String, dynamic> json) =>
      SurveyActivity(description: json['description']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'description': description};
}

class SurveyExpenseLine {
  const SurveyExpenseLine(
      {required this.category,
      required this.name,
      required this.amount,
      required this.description});
  final String category, name, amount, description;
  factory SurveyExpenseLine.fromJson(Map<String, dynamic> json) =>
      SurveyExpenseLine(
          category: json['expense_category']?.toString() ?? '',
          name: json['name']?.toString() ?? '',
          amount: json['amount']?.toString() ?? '0.00',
          description: json['description']?.toString() ?? '');
  Map<String, dynamic> toJson() => {
        'expense_category': category,
        'name': name,
        'amount': amount,
        'description': description
      };
}

class SurveyMaterialUsed {
  const SurveyMaterialUsed(
      {required this.equipmentId,
      required this.quantityUsed,
      this.name = '',
      this.unit = ''});
  final int equipmentId;
  final String quantityUsed, name, unit;
  factory SurveyMaterialUsed.fromJson(Map<String, dynamic> json) =>
      SurveyMaterialUsed(
          equipmentId: _int(json['equipment_id']),
          quantityUsed: json['quantity_used']?.toString() ?? '0',
          name: json['name']?.toString() ?? '',
          unit: json['unit']?.toString() ?? '');
  Map<String, dynamic> toJson() =>
      {'equipment_id': equipmentId, 'quantity_used': quantityUsed};
}

class SurveyAttachment {
  const SurveyAttachment({required this.url, required this.description});
  final String url, description;
  factory SurveyAttachment.fromJson(Map<String, dynamic> json) =>
      SurveyAttachment(
          url: json['url']?.toString() ?? '',
          description: json['description']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'url': url, 'description': description};
}

class BearingDistancePoint {
  const BearingDistancePoint(
      {required this.pointNumber,
      required this.azimuthDegrees,
      required this.azimuthMinutes,
      required this.azimuthSeconds,
      required this.distance});
  final int pointNumber, azimuthDegrees, azimuthMinutes;
  final String azimuthSeconds, distance;
  factory BearingDistancePoint.fromJson(Map<String, dynamic> json) =>
      BearingDistancePoint(
          pointNumber: _int(json['point_number']),
          azimuthDegrees: _int(json['azimuth_degrees']),
          azimuthMinutes: _int(json['azimuth_minutes']),
          azimuthSeconds: json['azimuth_seconds']?.toString() ?? '0',
          distance: json['distance']?.toString() ?? '0');
  Map<String, dynamic> toJson() => {
        'point_number': pointNumber,
        'azimuth_degrees': azimuthDegrees,
        'azimuth_minutes': azimuthMinutes,
        'azimuth_seconds': azimuthSeconds,
        'distance': distance
      };
}

class XyzSurveyPoint {
  const XyzSurveyPoint(
      {required this.pointNumber,
      required this.northing,
      required this.easting,
      required this.elevation});
  final int pointNumber;
  final String northing, easting, elevation;
  factory XyzSurveyPoint.fromJson(Map<String, dynamic> json) => XyzSurveyPoint(
      pointNumber: _int(json['point_number']),
      northing: json['northing']?.toString() ?? '',
      easting: json['easting']?.toString() ?? '',
      elevation: json['elevation']?.toString() ?? '');
  Map<String, dynamic> toJson() => {
        'point_number': pointNumber,
        'northing': northing,
        'easting': easting,
        'elevation': elevation
      };
}

class SurveySiteReport {
  const SurveySiteReport(
      {required this.id,
      required this.reportType,
      required this.employeeId,
      required this.employeeName,
      required this.status,
      required this.worksiteId,
      required this.worksiteName,
      required this.date,
      required this.workDataType,
      required this.measurementUnit,
      required this.coordinateSystem,
      required this.datum,
      required this.coordinateZone,
      required this.activities,
      required this.expenses,
      required this.materialsUsed,
      required this.attachments,
      required this.bearingDistancePoints,
      required this.xyzPoints,
      required this.submissionVersion,
      required this.createdAt,
      required this.updatedAt,
      this.projectId,
      this.projectName = '',
      this.taskId,
      this.taskName = '',
      this.gpsLatitude,
      this.gpsLongitude,
      this.rating,
      this.feedback = '',
      this.reviewedById});

  final int id, employeeId, worksiteId, submissionVersion;
  final String reportType,
      employeeName,
      status,
      worksiteName,
      date,
      workDataType,
      measurementUnit,
      coordinateSystem,
      datum,
      coordinateZone,
      createdAt,
      updatedAt;
  final int? projectId, taskId, rating, reviewedById;
  final String projectName, taskName;
  final String? gpsLatitude, gpsLongitude;
  final String feedback;
  final List<SurveyActivity> activities;
  final List<SurveyExpenseLine> expenses;
  final List<SurveyMaterialUsed> materialsUsed;
  final List<SurveyAttachment> attachments;
  final List<BearingDistancePoint> bearingDistancePoints;
  final List<XyzSurveyPoint> xyzPoints;

  factory SurveySiteReport.fromJson(Map<String, dynamic> json) {
    final p = json['payload'] is Map
        ? Map<String, dynamic>.from(json['payload'])
        : json;
    List<T> rows<T>(String key, T Function(Map<String, dynamic>) parse) =>
        p[key] is List
            ? (p[key] as List)
                .whereType<Map>()
                .map((e) => parse(Map<String, dynamic>.from(e)))
                .toList()
            : <T>[];
    return SurveySiteReport(
        id: _int(json['id']),
        reportType: json['report_type']?.toString() ?? 'survey_site',
        employeeId: _int(json['employee_id']),
        employeeName: json['employee_name']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        worksiteId: _int(p['worksite_id']),
        worksiteName: p['worksite_name']?.toString() ??
            json['worksite_name']?.toString() ??
            '',
        projectId: _nullableInt(p['project_id']),
        projectName: p['project_name']?.toString() ?? '',
        taskId: _nullableInt(p['task_id']),
        taskName: p['task_name']?.toString() ?? '',
        date: p['date']?.toString() ?? '',
        workDataType: p['work_data_type']?.toString() ?? 'bearing_distance',
        measurementUnit: p['measurement_unit']?.toString() ?? 'metres',
        coordinateSystem: p['coordinate_system']?.toString() ?? '',
        datum: p['datum']?.toString() ?? '',
        coordinateZone: p['coordinate_zone']?.toString() ?? '',
        gpsLatitude: p['gps_latitude']?.toString(),
        gpsLongitude: p['gps_longitude']?.toString(),
        activities: rows('activities', SurveyActivity.fromJson),
        expenses: rows('expenses', SurveyExpenseLine.fromJson),
        materialsUsed: rows('materials_used', SurveyMaterialUsed.fromJson),
        attachments: rows('attachments', SurveyAttachment.fromJson),
        bearingDistancePoints:
            rows('bearing_distance_points', BearingDistancePoint.fromJson),
        xyzPoints: rows('xyz_points', XyzSurveyPoint.fromJson),
        submissionVersion: _int(p['submission_version']),
        rating: _nullableInt(p['rating'] ?? json['rating']),
        reviewedById: _nullableInt(p['reviewed_by_id']),
        feedback:
            p['feedback']?.toString() ?? json['feedback']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '');
  }

  Map<String, dynamic> toJson({bool includeWorkDataType = true}) => {
        'worksite_id': worksiteId,
        if (projectId != null) 'project_id': projectId,
        if (taskId != null) 'task_id': taskId,
        'date': date,
        if (includeWorkDataType) 'work_data_type': workDataType,
        'measurement_unit': measurementUnit,
        if (coordinateSystem.isNotEmpty) 'coordinate_system': coordinateSystem,
        if (datum.isNotEmpty) 'datum': datum,
        if (coordinateZone.isNotEmpty) 'coordinate_zone': coordinateZone,
        if (gpsLatitude != null) 'gps_latitude': gpsLatitude,
        if (gpsLongitude != null) 'gps_longitude': gpsLongitude,
        'activities': activities.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'materials_used': materialsUsed.map((e) => e.toJson()).toList(),
        'attachments': attachments.map((e) => e.toJson()).toList(),
        'bearing_distance_points':
            bearingDistancePoints.map((e) => e.toJson()).toList(),
        'xyz_points': xyzPoints.map((e) => e.toJson()).toList(),
      };
}

class SurveyUnifiedReport {
  const SurveyUnifiedReport(
      {required this.id,
      required this.reportType,
      required this.status,
      required this.employeeId,
      required this.employeeName,
      required this.summary,
      required this.createdAt,
      required this.updatedAt});
  final int id, employeeId;
  final String reportType, status, employeeName, summary, createdAt, updatedAt;
  factory SurveyUnifiedReport.fromJson(Map<String, dynamic> j) =>
      SurveyUnifiedReport(
          id: _int(j['id']),
          reportType: j['report_type']?.toString() ?? '',
          status: j['status']?.toString() ?? '',
          employeeId: _int(j['employee_id']),
          employeeName: j['employee_name']?.toString() ?? '',
          summary: j['summary']?.toString() ?? '',
          createdAt: j['created_at']?.toString() ?? '',
          updatedAt: j['updated_at']?.toString() ?? '');
}

int _int(dynamic x) => int.tryParse(x?.toString() ?? '') ?? 0;
int? _nullableInt(dynamic x) => x == null ? null : int.tryParse(x.toString());
