import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:bms_front_end/src/services/employees_services.dart';
import 'package:bms_front_end/src/model/employees_model.dart';

/// Tests the EmployeeService create/fetch flow end-to-end
/// using a mock Dio adapter (no live API calls).
///
/// We test the service layer directly because the EmployeeController
/// depends on Flutter's BuildContext and FlutterSecureStorage,
/// making it harder to unit test without a full widget test harness.
/// The service layer is where the actual API logic lives.
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late EmployeeService service;
  const token = 'test-token';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://bomachauth.bgbot.app'));
    dioAdapter = DioAdapter(dio: dio);
    service = EmployeeService(dioOverride: dio);
  });

  group('Employee creation flow (end-to-end service)', () {
    test('create → fetch verifies employee appears in list', () async {
      // Step 1: Create employee
      final createPayload = _minimalCreatePayload();
      final createdResponse = _employeeApiResponse(userId: 99);

      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.reply(201, createdResponse),
        data: createPayload,
      );

      final created = await service.createEmployee(token, createPayload);
      expect(created.id, '99');
      expect(created.email, 'newbie@bomach.com');

      // Step 2: Fetch employees and verify the new one is in the list
      dioAdapter.onGet(
        '/api/v1/employees/employees',
        (server) => server.reply(200, {
          'items': [createdResponse],
          'count': 1,
        }),
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

      expect(result.count, 1);
      expect(result.list.first.id, '99');
      expect(result.list.first.email, 'newbie@bomach.com');
    });

    test('toJson produces payload that matches API schema', () {
      final employee = Employee(
        id: '0',
        email: 'schema@test.com',
        password: 'Password@123',
        firstName: 'Schema',
        lastName: 'Test',
        gender: 'female',
        maritalStatus: 'married',
        nationality: 'Nigerian',
        phoneNumber: '08000000000',
        dateOfBirth: DateTime(1990, 3, 25),
        branchId: 1,
        departmentId: 2,
        departmentUnitId: 3,
        levelId: 5,
        designation: 'Developer',
        employmentType: 'full-time',
        employmentStatus: 'active',
        startDate: DateTime(2024, 1, 1),
        grossSalary: 300000,
        bankName: 'Access',
        accountNumber: '1234567890',
      );

      final json = employee.toJson();

      // Required fields per API schema
      expect(json['email'], isNotEmpty);
      expect(json['first_name'], isNotEmpty);
      expect(json['last_name'], isNotEmpty);
      expect(json['password'], 'Password@123');

      // Correct types for API
      expect(json['branch_id'], isA<int>());
      expect(json['department_id'], isA<int>());
      expect(json['level_id'], isA<int>());
      expect(json['gross_salary'], isA<num>());
      expect(json['is_active'], isA<bool>());
      expect(json['allowances'], isA<Map>());
      expect(json['probation_period'], isA<int>());
      expect(json['employer_contribution'], isA<num>());
      expect(json['hmo_dependents_covered'], isA<int>());

      // Date format matches API expectation (yyyy-MM-dd)
      expect(json['date_of_birth'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(json['start_date'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('service handles network timeout gracefully', () async {
      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.throws(
          -1,
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/employees/employees'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          ),
        ),
        data: Matchers.any,
      );

      expect(
        () => service.createEmployee(token, {}),
        throwsA(isA<Exception>()),
      );
    });

    test('service extracts error detail from 400 response', () async {
      dioAdapter.onPost(
        '/api/v1/employees/employees',
        (server) => server.reply(400, {
          'detail': 'A user with this email already exists',
        }),
        data: Matchers.any,
      );

      try {
        await service.createEmployee(token, {'email': 'dup@test.com'});
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('400'));
      }
    });
  });
}

Map<String, dynamic> _minimalCreatePayload() => {
      'email': 'newbie@bomach.com',
      'first_name': 'New',
      'last_name': 'Employee',
      'password': 'Password@123',
      'gender': 'male',
      'marital_status': 'single',
      'branch_id': 1,
      'department_id': 2,
      'level_id': 3,
    };

Map<String, dynamic> _employeeApiResponse({required int userId}) => {
      'user_id': userId,
      'id': 50,
      'employee_id': 'MEM-NEW',
      'email': 'newbie@bomach.com',
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
