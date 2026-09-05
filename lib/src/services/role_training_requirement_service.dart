import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_training_requirement_model.dart';

class RoleTrainingRequirementService {
  final Dio _dio;

  RoleTrainingRequirementService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<RoleTrainingRequirement> items, int count})> listRequirements(
    String token, {
    required int roleId,
    String? requirementType,
    int? trainingProgramId,
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/roles/$roleId/training-requirements',
        queryParameters: {
          if (requirementType != null) 'requirement_type': requirementType,
          if (trainingProgramId != null)
            'training_program_id': trainingProgramId,
          if (isActive != null) 'is_active': isActive,
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final rawItems = data is Map ? data['items'] : data;
      final items = rawItems is List ? rawItems : const <dynamic>[];
      final count = data is Map && data['count'] is num
          ? (data['count'] as num).toInt()
          : items.length;

      return (
        items: items
            .map((item) => RoleTrainingRequirement.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList(),
        count: count,
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<RoleTrainingRequirement> createRequirement(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/training-requirements',
        data: payload,
        options: _authOptions(token),
      );
      return RoleTrainingRequirement.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<RoleTrainingRequirement> updateRequirement(
    String token,
    int roleId,
    int requirementId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/roles/$roleId/training-requirements/$requirementId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleTrainingRequirement.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<void> deleteRequirement(
      String token, int roleId, int requirementId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/training-requirements/$requirementId',
        options: _authOptions(token),
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final detail = body is Map
          ? (body['detail'] ?? body['message'] ?? error.message)
          : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $detail');
    }
    return Exception('Unexpected error: $error');
  }
}
