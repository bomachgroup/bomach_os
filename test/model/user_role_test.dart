import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/model/user_model.dart';

void main() {
  test('parses the backend role_name field used during permission bootstrap', () {
    final user = User.fromJson({
      'user_id': 7,
      'id': 42,
      'email': 'ceo@example.com',
      'first_name': 'Chief',
      'last_name': 'Executive',
      'role_name': 'CEO',
    });

    expect(user.role, 'CEO');
  });
}
