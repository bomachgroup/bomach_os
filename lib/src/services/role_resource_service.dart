import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_resource_models.dart';

class RoleResourceService {
  final Dio _dio;

  static final String _baseUrl = ApiConstants.baseUrl;

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

  static const _kindMap = {
    ResourceType.physicalResource: 'physical',
    ResourceType.softwareTool: 'software',
    ResourceType.referenceDocument: 'document',
    ResourceType.technicalSkill: 'skill',
    ResourceType.softSkill: 'soft_skill',
    ResourceType.experienceRequirement: 'experience',
    ResourceType.certification: 'certification',
  };

  // ─── GENERIC RESOURCE CRUD ───────────────────────────────────────────

  Future<({List<Map<String, dynamic>> list, int count})> _listResources(
    String token, {
    required int roleId,
    required ResourceType type,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final kind = _kindMap[type]!;
      final response = await _dio.get(
        '/api/v1/roles/$roleId/resources',
        queryParameters: {
          'kind': kind,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );
      final data = response.data as Map? ?? {};
      final items = (data['items'] as List?) ?? [];
      return (
        list: items.cast<Map<String, dynamic>>(),
        count: (data['count'] as int?) ?? items.length,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _createResource(
    String token,
    int roleId,
    ResourceType type,
    Map<String, dynamic> payload,
  ) async {
    try {
      payload['kind'] = _kindMap[type]!;
      final res = await _dio.post(
        '/api/v1/roles/$roleId/resources',
        data: payload,
        options: _authOptions(token),
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _updateResource(
    String token,
    int roleId,
    int resourceId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.patch(
        '/api/v1/roles/$roleId/resources/$resourceId',
        data: payload,
        options: _authOptions(token),
      );
      return res.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _deleteResource(String token, int roleId, int resourceId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/resources/$resourceId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PHYSICAL RESOURCES ───────────────────────────────────────────────

  Future<({List<PhysicalResource> list, int count})> listPhysicalResources(
      String token,
      {required int roleId,
      int limit = 100,
      int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.physicalResource,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => PhysicalResource.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<PhysicalResource> createPhysicalResource(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.physicalResource, payload);
    return PhysicalResource.fromJson(r);
  }

  Future<PhysicalResource> updatePhysicalResource(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return PhysicalResource.fromJson(r);
  }

  Future<void> deletePhysicalResource(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── SOFTWARE TOOLS ───────────────────────────────────────────────────

  Future<({List<SoftwareTool> list, int count})> listSoftwareTools(String token,
      {required int roleId, int limit = 100, int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.softwareTool,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => SoftwareTool.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<SoftwareTool> createSoftwareTool(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.softwareTool, payload);
    return SoftwareTool.fromJson(r);
  }

  Future<SoftwareTool> updateSoftwareTool(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return SoftwareTool.fromJson(r);
  }

  Future<void> deleteSoftwareTool(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── REFERENCE DOCUMENTS ──────────────────────────────────────────────

  Future<({List<ReferenceDocument> list, int count})> listReferenceDocuments(
      String token,
      {required int roleId,
      int limit = 100,
      int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.referenceDocument,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => ReferenceDocument.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<ReferenceDocument> createReferenceDocument(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.referenceDocument, payload);
    return ReferenceDocument.fromJson(r);
  }

  Future<ReferenceDocument> updateReferenceDocument(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return ReferenceDocument.fromJson(r);
  }

  Future<void> deleteReferenceDocument(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── TECHNICAL SKILLS ─────────────────────────────────────────────────

  Future<({List<TechnicalSkill> list, int count})> listTechnicalSkills(
      String token,
      {required int roleId,
      int limit = 100,
      int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.technicalSkill,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => TechnicalSkill.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<TechnicalSkill> createTechnicalSkill(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.technicalSkill, payload);
    return TechnicalSkill.fromJson(r);
  }

  Future<TechnicalSkill> updateTechnicalSkill(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return TechnicalSkill.fromJson(r);
  }

  Future<void> deleteTechnicalSkill(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── SOFT SKILLS ──────────────────────────────────────────────────────

  Future<({List<SoftSkill> list, int count})> listSoftSkills(String token,
      {required int roleId, int limit = 100, int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.softSkill,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => SoftSkill.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<SoftSkill> createSoftSkill(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r =
        await _createResource(token, roleId, ResourceType.softSkill, payload);
    return SoftSkill.fromJson(r);
  }

  Future<SoftSkill> updateSoftSkill(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return SoftSkill.fromJson(r);
  }

  Future<void> deleteSoftSkill(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── EXPERIENCE REQUIREMENTS ──────────────────────────────────────────

  Future<({List<ExperienceRequirement> list, int count})>
      listExperienceRequirements(String token,
          {required int roleId, int limit = 100, int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.experienceRequirement,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => ExperienceRequirement.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<ExperienceRequirement> createExperienceRequirement(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.experienceRequirement, payload);
    return ExperienceRequirement.fromJson(r);
  }

  Future<ExperienceRequirement> updateExperienceRequirement(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return ExperienceRequirement.fromJson(r);
  }

  Future<void> deleteExperienceRequirement(
      String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  // ─── CERTIFICATIONS ───────────────────────────────────────────────────

  Future<({List<Certification> list, int count})> listCertifications(
      String token,
      {required int roleId,
      int limit = 100,
      int offset = 0}) async {
    final r = await _listResources(token,
        roleId: roleId,
        type: ResourceType.certification,
        limit: limit,
        offset: offset);
    return (
      list: r.list.map((j) => Certification.fromJson(j)).toList(),
      count: r.count
    );
  }

  Future<Certification> createCertification(
      String token, int roleId, Map<String, dynamic> payload) async {
    final r = await _createResource(
        token, roleId, ResourceType.certification, payload);
    return Certification.fromJson(r);
  }

  Future<Certification> updateCertification(
      String token, int roleId, int id, Map<String, dynamic> payload) async {
    final r = await _updateResource(token, roleId, id, payload);
    return Certification.fromJson(r);
  }

  Future<void> deleteCertification(String token, int roleId, int id) async {
    await _deleteResource(token, roleId, id);
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final msg = (body is Map)
          ? (body['message'] ?? body['detail'] ?? error.message)
          : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $error');
  }
}
