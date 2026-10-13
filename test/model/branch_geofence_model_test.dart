import 'package:bomach_os/src/model/branch_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('branch parses backend GPS centre and attendance radius', () {
    final branch = Branch.fromJson({
      'id': 5,
      'branch_name': 'Enugu',
      'latitude': '6.441200',
      'longitude': 7.4981,
      'attendance_radius_meters': 250,
      'is_active': true,
      'is_operational': true,
    });

    expect(branch.latitude, 6.4412);
    expect(branch.longitude, 7.4981);
    expect(branch.attendanceRadiusMeters, 250);
  });

  test('branches without an attendance point keep the default radius', () {
    final branch = Branch.fromJson({
      'id': 6,
      'branch_name': 'Remote office',
      'latitude': null,
      'longitude': null,
    });

    expect(branch.latitude, isNull);
    expect(branch.longitude, isNull);
    expect(branch.attendanceRadiusMeters, 100);
  });
}
