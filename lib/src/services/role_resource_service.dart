import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_resource_models.dart';

class RoleResourceService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  RoleResourceService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ─── PHYSICAL RESOURCES ───────────────────────────────────────────────

  Future<({List<PhysicalResource> list, int count})> listPhysicalResources(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    try {
      final response = await _dio.get('/role-physical-resources/',
          queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
          options: _authOptions(token));
      final data = response.data as Map? ?? {};
      final items = (data['items'] as List?) ?? [];
      return (list: items.map((j) => PhysicalResource.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
    } catch (e) { throw _handleError(e); }
  }

  Future<PhysicalResource> createPhysicalResource(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-physical-resources/', data: payload, options: _authOptions(token));
    return PhysicalResource.fromJson(res.data);
  }

  Future<PhysicalResource> updatePhysicalResource(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-physical-resources/$id', data: payload, options: _authOptions(token));
    return PhysicalResource.fromJson(res.data);
  }

  Future<void> deletePhysicalResource(String token, int id) async {
    await _dio.delete('/role-physical-resources/$id', options: _authOptions(token));
  }

  // ─── SOFTWARE TOOLS ───────────────────────────────────────────────────

  Future<({List<SoftwareTool> list, int count})> listSoftwareTools(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-software-tools/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
    final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => SoftwareTool.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<SoftwareTool> createSoftwareTool(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-software-tools/', data: payload, options: _authOptions(token));
    return SoftwareTool.fromJson(res.data);
  }

  Future<SoftwareTool> updateSoftwareTool(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-software-tools/$id', data: payload, options: _authOptions(token));
    return SoftwareTool.fromJson(res.data);
  }

  Future<void> deleteSoftwareTool(String token, int id) async {
    await _dio.delete('/role-software-tools/$id', options: _authOptions(token));
  }

  // ─── REFERENCE DOCUMENTS ──────────────────────────────────────────────

  Future<({List<ReferenceDocument> list, int count})> listReferenceDocuments(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-reference-documents/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
      final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => ReferenceDocument.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<ReferenceDocument> createReferenceDocument(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-reference-documents/', data: payload, options: _authOptions(token));
    return ReferenceDocument.fromJson(res.data);
  }

  Future<ReferenceDocument> updateReferenceDocument(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-reference-documents/$id', data: payload, options: _authOptions(token));
    return ReferenceDocument.fromJson(res.data);
  }

  Future<void> deleteReferenceDocument(String token, int id) async {
    await _dio.delete('/role-reference-documents/$id', options: _authOptions(token));
  }

  // ─── TECHNICAL SKILLS ─────────────────────────────────────────────────

  Future<({List<TechnicalSkill> list, int count})> listTechnicalSkills(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-technical-skills/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
      final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => TechnicalSkill.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<TechnicalSkill> createTechnicalSkill(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-technical-skills/', data: payload, options: _authOptions(token));
    return TechnicalSkill.fromJson(res.data);
  }

  Future<TechnicalSkill> updateTechnicalSkill(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-technical-skills/$id', data: payload, options: _authOptions(token));
    return TechnicalSkill.fromJson(res.data);
  }

  Future<void> deleteTechnicalSkill(String token, int id) async {
    await _dio.delete('/role-technical-skills/$id', options: _authOptions(token));
  }

  // ─── SOFT SKILLS ──────────────────────────────────────────────────────

  Future<({List<SoftSkill> list, int count})> listSoftSkills(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-soft-skills/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
      final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => SoftSkill.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<SoftSkill> createSoftSkill(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-soft-skills/', data: payload, options: _authOptions(token));
    return SoftSkill.fromJson(res.data);
  }

  Future<SoftSkill> updateSoftSkill(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-soft-skills/$id', data: payload, options: _authOptions(token));
    return SoftSkill.fromJson(res.data);
  }

  Future<void> deleteSoftSkill(String token, int id) async {
    await _dio.delete('/role-soft-skills/$id', options: _authOptions(token));
  }

  // ─── EXPERIENCE REQUIREMENTS ──────────────────────────────────────────

  Future<({List<ExperienceRequirement> list, int count})> listExperienceRequirements(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-experience-requirements/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
      final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => ExperienceRequirement.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<ExperienceRequirement> createExperienceRequirement(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-experience-requirements/', data: payload, options: _authOptions(token));
    return ExperienceRequirement.fromJson(res.data);
  }

  Future<ExperienceRequirement> updateExperienceRequirement(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-experience-requirements/$id', data: payload, options: _authOptions(token));
    return ExperienceRequirement.fromJson(res.data);
  }

  Future<void> deleteExperienceRequirement(String token, int id) async {
    await _dio.delete('/role-experience-requirements/$id', options: _authOptions(token));
  }

  // ─── CERTIFICATIONS ───────────────────────────────────────────────────

  Future<({List<Certification> list, int count})> listCertifications(
    String token, {int? roleId, int limit = 100, int offset = 0}) async {
    final res = await _dio.get('/role-certifications/',
        queryParameters: _queryParams(roleId: roleId, limit: limit, offset: offset),
        options: _authOptions(token));
      final data = res.data as Map? ?? {};
    final items = (data['items'] as List?) ?? [];
    return (list: items.map((j) => Certification.fromJson(j as Map<String, dynamic>)).toList(), count: (data['count'] as int?) ?? items.length);
  }

  Future<Certification> createCertification(String token, Map<String, dynamic> payload) async {
    final res = await _dio.post('/role-certifications/', data: payload, options: _authOptions(token));
    return Certification.fromJson(res.data);
  }

  Future<Certification> updateCertification(String token, int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/role-certifications/$id', data: payload, options: _authOptions(token));
    return Certification.fromJson(res.data);
  }

  Future<void> deleteCertification(String token, int id) async {
    await _dio.delete('/role-certifications/$id', options: _authOptions(token));
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────

  Map<String, dynamic> _queryParams({int? roleId, int limit = 100, int offset = 0}) {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (roleId != null) params['role_id'] = roleId;
    return params;
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final msg = error.response?.data?['message'] ?? error.response?.data?['detail'] ?? error.message;
      return Exception('API Error: ${error.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $error');
  }
}
