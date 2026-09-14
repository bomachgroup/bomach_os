import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/model/employees_model.dart';

void main() {
  group('Employee.fromJson', () {
    test('parses a full API response correctly', () {
      final json = _fullEmployeeJson();
      final employee = Employee.fromJson(json);

      // Identifiers — user_id maps to id
      expect(employee.id, '10');
      expect(employee.tableId, '3');
      expect(employee.employeeId, 'MEM-063');

      // Personal
      expect(employee.email, 'john@example.com');
      expect(employee.firstName, 'John');
      expect(employee.lastName, 'Doe');
      expect(employee.middleName, 'M');
      expect(employee.gender, 'male');
      expect(employee.maritalStatus, 'single');
      expect(employee.nationality, 'Nigerian');
      expect(employee.phoneNumber, '08012345678');
      expect(employee.dateOfBirth, DateTime(1995, 6, 15));
      expect(employee.profilePicture, 'https://img.example.com/pic.jpg');

      // Status
      expect(employee.isVerified, true);
      expect(employee.isActive, true);

      // Contact
      expect(employee.personalEmail, 'john.personal@gmail.com');
      expect(employee.otherPhoneNumber, '08098765432');
      expect(employee.streetAddress, '10 Marina St');
      expect(employee.city, 'Lagos');
      expect(employee.state, 'Lagos');
      expect(employee.zipCode, '100001');
      expect(employee.country, 'Nigeria');

      // Emergency
      expect(employee.emergencyContactName, 'Jane Doe');
      expect(employee.emergencyContactRelationship, 'Spouse');
      expect(employee.emergencyContactPhone, '08011111111');

      // Work
      expect(employee.designation, 'Software Engineer');
      expect(employee.employmentType, 'full-time');
      expect(employee.employmentStatus, 'active');
      expect(employee.branchId, 1);
      expect(employee.branchName, 'HQ');
      expect(employee.departmentId, 2);
      expect(employee.departmentName, 'Engineering');
      expect(employee.levelId, 5);
      expect(employee.employeeLevel, 'Senior');
      expect(employee.reportingToId, 3);
      expect(employee.startDate, DateTime(2023, 1, 10));

      // Compensation
      expect(employee.grossSalary, 500000.0);
      expect(employee.salaryFrequency, 'monthly');
      expect(employee.bankName, 'GTBank');
      expect(employee.accountNumber, '0123456789');
      expect(employee.allowances, {'transport': 50000});

      // Helpers
      expect(employee.fullName, 'John Doe');
      expect(employee.role, 'Senior');
    });

    test('handles missing/null optional fields gracefully', () {
      final json = {
        'user_id': 1,
        'id': 1,
        'email': 'minimal@test.com',
        'first_name': 'Min',
        'last_name': 'User',
      };

      final employee = Employee.fromJson(json);

      expect(employee.id, '1');
      expect(employee.email, 'minimal@test.com');
      expect(employee.firstName, 'Min');
      expect(employee.lastName, 'User');

      // All optional fields should be null or default
      expect(employee.middleName, isNull);
      expect(employee.gender, isNull);
      expect(employee.phoneNumber, isNull);
      expect(employee.dateOfBirth, isNull);
      expect(employee.branchId, isNull);
      expect(employee.departmentId, isNull);
      expect(employee.levelId, isNull);
      expect(employee.isActive, true); // default
      expect(employee.isVerified, false); // default
      expect(employee.grossSalary, 0.0); // defaults to 0.0
      expect(employee.allowances, isEmpty);
    });

    test('handles string-typed integer fields (branch_id, department_id)', () {
      final json = {
        'user_id': '5',
        'email': 'str@test.com',
        'first_name': 'Str',
        'last_name': 'Fields',
        'branch_id': '3',
        'department_id': '7',
        'level_id': '12',
        'reporting_to_id': '2',
      };

      final employee = Employee.fromJson(json);

      expect(employee.branchId, 3);
      expect(employee.departmentId, 7);
      expect(employee.levelId, 12);
      expect(employee.reportingToId, 2);
    });

    test('handles gross_salary as string', () {
      final json = {
        'user_id': 1,
        'email': 'sal@test.com',
        'first_name': 'Sal',
        'last_name': 'Test',
        'gross_salary': '750000.50',
      };

      final employee = Employee.fromJson(json);
      expect(employee.grossSalary, 750000.50);
    });

    test('handles gross_salary as num', () {
      final json = {
        'user_id': 1,
        'email': 'sal@test.com',
        'first_name': 'Sal',
        'last_name': 'Test',
        'gross_salary': 250000,
      };

      final employee = Employee.fromJson(json);
      expect(employee.grossSalary, 250000.0);
    });
  });

  group('Employee.toJson', () {
    test('produces valid API payload with all required fields', () {
      final employee = Employee(
        id: '10',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password@123',
        gender: 'male',
        maritalStatus: 'single',
        nationality: 'Nigerian',
        branchId: 1,
        departmentId: 2,
        levelId: 5,
        grossSalary: 500000,
        employmentType: 'full-time',
        employmentStatus: 'active',
        dateOfBirth: DateTime(1995, 6, 15),
        startDate: DateTime(2023, 1, 10),
      );

      final json = employee.toJson();

      expect(json['email'], 'john@example.com');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['password'], 'Password@123');
      expect(json['gender'], 'male');
      expect(json['branch_id'], 1);
      expect(json['department_id'], 2);
      expect(json['level_id'], 5);
      expect(json['gross_salary'], 500000);
      expect(json['employment_type'], 'full-time');
      expect(json['is_active'], true);
      expect(json['date_of_birth'], '1995-06-15');
      expect(json['start_date'], '2023-01-10');
    });

    test('omits password when null', () {
      final employee = Employee(
        id: '1',
        email: 'test@test.com',
        firstName: 'Test',
        lastName: 'User',
      );

      final json = employee.toJson();
      expect(json.containsKey('password'), false);
    });

    test('provides defaults for null optional fields', () {
      final employee = Employee(
        id: '1',
        email: 'test@test.com',
        firstName: 'Test',
        lastName: 'User',
      );

      final json = employee.toJson();

      expect(json['gender'], 'male');
      expect(json['marital_status'], 'single');
      expect(json['nationality'], 'Nigerian');
      expect(json['employment_type'], 'full-time');
      expect(json['employment_status'], 'active');
      expect(json['branch_id'], 0);
      expect(json['department_id'], 0);
      expect(json['level_id'], 0);
      expect(json['gross_salary'], 0);
      expect(json['salary_frequency'], 'monthly');
      expect(json['allowances'], isEmpty);
    });
  });

  group('Employee helpers', () {
    test('fullName concatenates first and last name', () {
      final e = Employee(
          id: '1', email: 'e@e.com', firstName: 'Ada', lastName: 'Lovelace');
      expect(e.fullName, 'Ada Lovelace');
    });

    test('role returns roleName first, then employeeLevel, then designation, then Staff', () {
      final withRoleName = Employee(
          id: '1',
          email: 'e@e.com',
          firstName: 'A',
          lastName: 'B',
          roleName: 'Lead Engineer',
          employeeLevel: 'CEO',
          designation: 'Manager');
      expect(withRoleName.role, 'Lead Engineer');

      final withLevel = Employee(
          id: '1',
          email: 'e@e.com',
          firstName: 'A',
          lastName: 'B',
          employeeLevel: 'CEO');
      expect(withLevel.role, 'CEO');

      final withDesignation = Employee(
          id: '1',
          email: 'e@e.com',
          firstName: 'A',
          lastName: 'B',
          designation: 'Manager');
      expect(withDesignation.role, 'Manager');

      final noRole =
          Employee(id: '1', email: 'e@e.com', firstName: 'A', lastName: 'B');
      expect(noRole.role, 'Staff');
    });

    test('fromJson parses roleName from role_name, role string, or role map', () {
      final fromRoleName = Employee.fromJson({
        'user_id': 1,
        'email': 'e@e.com',
        'first_name': 'A',
        'last_name': 'B',
        'role_name': 'Project Manager',
      });
      expect(fromRoleName.roleName, 'Project Manager');
      expect(fromRoleName.role, 'Project Manager');

      final fromRoleString = Employee.fromJson({
        'user_id': 2,
        'email': 'e@e.com',
        'first_name': 'A',
        'last_name': 'B',
        'role': 'Product Owner',
      });
      expect(fromRoleString.roleName, 'Product Owner');
      expect(fromRoleString.role, 'Product Owner');

      final fromRoleMap = Employee.fromJson({
        'user_id': 3,
        'email': 'e@e.com',
        'first_name': 'A',
        'last_name': 'B',
        'role': {'id': 5, 'name': 'DevOps Engineer'},
      });
      expect(fromRoleMap.roleName, 'DevOps Engineer');
      expect(fromRoleMap.role, 'DevOps Engineer');
    });
  });
}

Map<String, dynamic> _fullEmployeeJson() => {
      'user_id': 10,
      'id': 3,
      'employee_id': 'MEM-063',
      'email': 'john@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'middle_name': 'M',
      'gender': 'male',
      'marital_status': 'single',
      'nationality': 'Nigerian',
      'phone_number': '08012345678',
      'date_of_birth': '1995-06-15',
      'profile_picture': 'https://img.example.com/pic.jpg',
      'is_verified': true,
      'is_active': true,
      'personal_email': 'john.personal@gmail.com',
      'other_phone': '08098765432',
      'street_address': '10 Marina St',
      'city': 'Lagos',
      'state': 'Lagos',
      'zip_code': '100001',
      'country': 'Nigeria',
      'emergency_contact_name': 'Jane Doe',
      'emergency_contact_relationship': 'Spouse',
      'emergency_contact_phone': '08011111111',
      'designation': 'Software Engineer',
      'employment_type': 'full-time',
      'employment_status': 'active',
      'branch_id': 1,
      'branch_name': 'HQ',
      'department_id': 2,
      'department_name': 'Engineering',
      'department_unit_id': 4,
      'department_unit_name': 'Backend',
      'level_id': 5,
      'employee_level': 'Senior',
      'location': 'Lagos',
      'reporting_to_id': 3,
      'reporting_to_name': 'Boss Man',
      'start_date': '2023-01-10',
      'probation_period': '3',
      'work_schedule': '9-5',
      'gross_salary': 500000.0,
      'salary_frequency': 'monthly',
      'allowances': {'transport': 50000},
      'bank_name': 'GTBank',
      'account_number': '0123456789',
      'tax_id': 'TAX001',
      'pension_number': 'PEN001',
      'pfa_provider': 'Leadway',
      'rsa_number': 'RSA001',
      'employer_contribution': 25000.0,
      'hmo_current_plan': 'Gold',
      'hmo_id_number': 'HMO001',
      'hmo_dependents_covered': 2,
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-06-01T00:00:00.000Z',
    };
