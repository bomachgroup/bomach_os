import 'package:bomach_os/pages/dashboad/widget/change_password_dialog.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(baseUrl: 'https://bomach.test');

  String? requestedEmail;
  String? resetEmail;
  String? resetCode;
  String? resetPasswordValue;

  @override
  Future<String> forgotPassword({required String email}) async {
    requestedEmail = email;
    return 'Verification code sent';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resetEmail = email;
    resetCode = code;
    resetPasswordValue = newPassword;
    return 'Password updated successfully';
  }
}

void main() {
  testWidgets('requests a code and changes password from the profile flow',
      (tester) async {
    final service = _FakeAuthService();
    var closed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangePasswordDialog(
          email: 'person@example.com',
          authService: service,
          onCompleted: () => closed = true,
        ),
      ),
    ));

    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();
    expect(service.requestedEmail, 'person@example.com');
    expect(find.text('Enter verification code'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('password-reset-code')), '123456');
    await tester.enterText(
        find.byKey(const ValueKey('new-password')), 'a-strong-password');
    await tester.enterText(
      find.byKey(const ValueKey('confirm-new-password')),
      'a-strong-password',
    );
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(service.resetEmail, 'person@example.com');
    expect(service.resetCode, '123456');
    expect(service.resetPasswordValue, 'a-strong-password');
    expect(closed, isTrue);
  });

  testWidgets('does not submit when the new passwords do not match',
      (tester) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangePasswordDialog(
            email: 'person@example.com', authService: service),
      ),
    ));
    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('password-reset-code')), '123456');
    await tester.enterText(
        find.byKey(const ValueKey('new-password')), 'first-password');
    await tester.enterText(
      find.byKey(const ValueKey('confirm-new-password')),
      'different-password',
    );
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(service.resetPasswordValue, isNull);
  });

  testWidgets('enforces the password minimum from the API contract',
      (tester) async {
    final service = _FakeAuthService();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangePasswordDialog(
          email: 'person@example.com',
          authService: service,
        ),
      ),
    ));
    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('password-reset-code')),
      '1234',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-password')),
      'short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('confirm-new-password')),
      'short',
    );
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(
        find.text('Password must be at least 8 characters.'), findsOneWidget);
    expect(service.resetPasswordValue, isNull);
  });
}
