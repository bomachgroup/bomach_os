import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/role_training_requirement_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RoleTrainingRequirementService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = RoleTrainingRequirementService(dioOverride: dio);
  });

  test('loads role training requirements with published filters', () async {
    adapter.onGet(
      '/api/v1/roles/12/training-requirements',
      (server) => server.reply(200, {
        'items': [
          {
            'id': 5,
            'role_id': 12,
            'training_program_id': 44,
            'training_program': {
              'id': 44,
              'program_name': 'Safety induction',
              'provider': 'BOMACH Academy',
              'status': 'scheduled',
              'start_date': '2026-09-10',
              'end_date': '2026-09-12',
            },
            'requirement_type': 'mandatory',
            'sequence': 1,
            'is_active': true,
            'created_at': '2026-09-01T10:00:00Z',
            'updated_at': '2026-09-01T10:00:00Z',
          },
        ],
        'count': 1,
      }),
      queryParameters: {
        'requirement_type': 'mandatory',
        'training_program_id': 44,
        'is_active': true,
        'search': 'safety',
        'limit': 20,
        'offset': 40,
      },
    );

    final result = await service.listRequirements(
      'token',
      roleId: 12,
      requirementType: 'mandatory',
      trainingProgramId: 44,
      isActive: true,
      search: 'safety',
      limit: 20,
      offset: 40,
    );

    expect(result.count, 1);
    expect(result.items.single.trainingProgram.programName, 'Safety induction');
    expect(result.items.single.isMandatory, isTrue);
    expect(result.items.single.toTrainingProgram().isMandatory, isTrue);
  });
}
