import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/departments_units_model.dart';
import 'package:bomach_os/src/services/employees_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late EmployeeService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = EmployeeService(dioOverride: dio);
  });

  test('uses the published organization endpoints for departments', () async {
    adapter.onGet(
      '/api/v1/organization/department',
      (server) => server.reply(200, {
        'items': [
          {'id': 7, 'name': 'Operations', 'description': 'Operations team'},
        ],
        'count': 1,
      }),
      queryParameters: {'limit': 25, 'offset': 5, 'search': 'Ops'},
    );

    final result = await service.getDepartments(
      token,
      search: 'Ops',
      limit: 25,
      offset: 5,
    );

    expect(result.single.name, 'Operations');
  });

  test('uses the published organization endpoints for department units', () async {
    adapter.onGet(
      '/api/v1/organization/unit',
      (server) => server.reply(200, {
        'items': [
          {'id': 8, 'name': 'Field Operations', 'department_id': 7},
        ],
        'count': 1,
      }),
      queryParameters: {
        'department_id': '7',
        'limit': 25,
        'offset': 5,
      },
    );

    final result = await service.getDepartmentUnits(
      token,
      departmentId: '7',
      limit: 25,
      offset: 5,
    );

    expect(result.single.name, 'Field Operations');
  });

  test('department and unit mutations use the published organization endpoints', () async {
    adapter.onPost(
      '/api/v1/organization/department',
      (server) => server.reply(201, {'id': 7, 'name': 'Operations'}),
      data: {'name': 'Operations', 'description': 'Operations team'},
    );
    adapter.onPut(
      '/api/v1/organization/department/7',
      (server) => server.reply(200, {'id': 7, 'name': 'Operations Updated'}),
      data: {'name': 'Operations Updated', 'description': 'Updated'},
    );
    adapter.onPost(
      '/api/v1/organization/unit',
      (server) => server.reply(201, {'id': 8, 'name': 'Field Operations'}),
      data: {
        'id': '8',
        'name': 'Field Operations',
        'description': '',
        'department_id': '7',
      },
    );
    adapter.onPut(
      '/api/v1/organization/unit/8',
      (server) => server.reply(200, {'id': 8, 'name': 'Field Operations Updated'}),
      data: {
        'id': '8',
        'name': 'Field Operations Updated',
        'description': '',
        'department_id': '7',
      },
    );

    final department = await service.createDepartment(token, 'Operations', 'Operations team');
    final updatedDepartment = await service.updateDepartment(token, '7', 'Operations Updated', 'Updated');
    final unit = DepartmentUnit(
      id: '8',
      name: 'Field Operations',
      description: '',
      departmentId: '7',
    );
    final updatedUnit = DepartmentUnit(
      id: '8',
      name: 'Field Operations Updated',
      description: '',
      departmentId: '7',
    );
    final createdUnit = await service.createDepartmentUnit(token, unit);
    final savedUpdatedUnit = await service.updateDepartmentUnit(token, '8', updatedUnit);

    expect(department.name, 'Operations');
    expect(updatedDepartment.name, 'Operations Updated');
    expect(createdUnit.name, 'Field Operations');
    expect(savedUpdatedUnit.name, 'Field Operations Updated');
  });
}
