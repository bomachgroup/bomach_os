import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:bms_front_end/src/services/employees_services.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late EmployeeService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    service = EmployeeService(dioOverride: dio);
  });

  group('createEmployee', () {
    test('sends POST and returns parsed Employee on 201', () async {
      final requestData = {
        'email': 'new@test.com',
        'first_name': 'New',
        'last_name': 'Employee',
        'password': 'Password@123',
        'gender': 'male',
        'branch_id': 1,
        'department_id': 2,
        'level_id': 3,
      };

      final responseData = {
        'user_id': 42,
        'id': 10,
        'employee_id': 'MEM-100',
        'email': 'new@test.com',
        'first_name': 'New',
        'last_name': 'Employee',
        'gender': 'male',
        'is_active': true,
        'is_verified': false,
        'branch_id': 1,
        'branch_name': 'HQ',
        'department_id': 2,
        'department_name': 'IT',
        'level_id': 3,
        'gross_salary': '0.00',
        'allowances': {},
        'employment_type': 'full-time',
        'created_at': '2024-03-18T10:00:00.000Z',
        'updated_at': '2024-03-18T10:00:00.000Z',
      };

      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.reply(201, responseData),
        data: requestData,
      );

      final employee = await service.createEmployee(token, requestData);

      expect(employee.id, '42');
      expect(employee.email, 'new@test.com');
      expect(employee.firstName, 'New');
      expect(employee.lastName, 'Employee');
      expect(employee.branchId, 1);
      expect(employee.departmentId, 2);
    });

    test('throws on 400 validation error', () async {
      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.reply(400, {
          'detail': 'Email already exists',
        }),
        data: Matchers.any,
      );

      expect(
        () => service.createEmployee(token, {'email': 'dup@test.com'}),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('400'),
        )),
      );
    });

    test('throws on 401 unauthorized', () async {
      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.reply(401, {'detail': 'Unauthorized'}),
        data: Matchers.any,
      );

      expect(
        () => service.createEmployee('bad-token', {}),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('401'),
        )),
      );
    });
  });

  group('getEmployees', () {
    test('parses paginated response correctly', () async {
      final responseData = {
        'items': [
          {
            'user_id': 1,
            'id': 1,
            'email': 'emp1@test.com',
            'first_name': 'Emp',
            'last_name': 'One',
            'is_active': true,
            'gross_salary': '100000',
            'allowances': {},
            'employment_type': 'full-time',
          },
          {
            'user_id': 2,
            'id': 2,
            'email': 'emp2@test.com',
            'first_name': 'Emp',
            'last_name': 'Two',
            'is_active': true,
            'gross_salary': 200000,
            'allowances': {},
            'employment_type': 'part-time',
          },
        ],
        'count': 25,
      };

      dioAdapter.onGet(
        '/api/v1/employees/employees',
        (server) => server.reply(200, responseData),
        queryParameters: {
          'is_active': true,
          'limit': 10,
          'offset': 0,
        },
      );

      final result = await service.getEmployees(
        token,
        isActive: true,
        limit: 10,
        offset: 0,
      );

      expect(result.list.length, 2);
      expect(result.count, 25);
      expect(result.list[0].email, 'emp1@test.com');
      expect(result.list[0].grossSalary, 100000.0);
      expect(result.list[1].email, 'emp2@test.com');
      expect(result.list[1].employmentType, 'part-time');
    });
  });

  group('updateEmployee', () {
    test('sends PUT and returns updated Employee', () async {
      final updateData = {'first_name': 'Updated'};
      final responseData = {
        'user_id': 10,
        'id': 3,
        'email': 'john@test.com',
        'first_name': 'Updated',
        'last_name': 'Doe',
        'is_active': true,
        'gross_salary': 500000,
        'allowances': {},
      };

      dioAdapter.onPut(
        '/api/v1/employees/employees/10',
        (server) => server.reply(200, responseData),
        data: updateData,
      );

      final employee = await service.updateEmployee(token, '10', updateData);

      expect(employee.firstName, 'Updated');
      expect(employee.id, '10');
    });
  });

  group('getDepartments', () {
    test('parses department list', () async {
      dioAdapter.onGet(
        '/api/v1/employees/department',
        (server) => server.reply(200, {
          'items': [
            {'id': 1, 'name': 'Engineering', 'description': 'Tech team'},
            {'id': 2, 'name': 'HR', 'description': 'People team'},
          ],
          'count': 2,
        }),
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final departments = await service.getDepartments(token);

      expect(departments.length, 2);
      expect(departments[0].name, 'Engineering');
      expect(departments[1].name, 'HR');
    });
  });
}
