import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../src/app_routes/app_route_constants.dart';
import '../../src/model/user_model.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/permission_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final PermissionService _permissionService = Get.put(PermissionService());
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  Rx<User?> currentUser = Rx<User?>(null);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetCodeController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    resetCodeController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message,
      {VoidCallback? onConfirm, String confirmText = "OK"}) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: TextStyle(
                color: title.toLowerCase().contains("error")
                    ? Colors.red
                    : Colors.black)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar(context, 'Please enter both User ID and PIN',
          isError: true);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);
      await _storage.write(key: 'user_id', value: response.userId.toString());
      
      // Fetch permissions
      await _fetchUserPermissions(response.accessToken, response.userId);

      await _fetchUserProfile(response.accessToken, response.userId);

      if (context.mounted) {
        _showSnackBar(context, 'Login Successful');
      }
    } on AuthException catch (e) {
      if (context.mounted) _showDialog(context, "Error", e.message);
    } catch (e) {
      if (context.mounted) {
        _showDialog(context, "Connection Error",
            "Please check your internet connection.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserProfile(String token, int userId) async {
    try {
      final user =
          await _authService.getCurrentUser(accessToken: token, userId: userId);
      currentUser.value = user;
    } catch (e) {
      log("Fetch Profile Failed: $e");
      throw AuthException(message: 'Could not find user');
    }
  }

  Future<void> _fetchUserPermissions(String token, int userId) async {
    try {
      final roles = await _authService.getEmployeeRoles(
          accessToken: token, userId: userId);
      _permissionService.loadPermissions(roles);
    } catch (e) {
      log("Fetch Permissions Failed: $e");
      // Load default minimal permissions so user can at least see the dashboard
      _permissionService.loadDefaultPermissions();
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await _authService.logout(accessToken: token);
      }
    } catch (e) {
      log("Logout error: $e");
    } finally {
      await _storage.deleteAll();
      _permissionService.clearPermissions();
      currentUser.value = null;
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> forgotPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      _showSnackBar(context, 'Please enter your email', isError: true);
      return;
    }
    try {
      isLoading.value = true;
      final message = await _authService.forgotPassword(email: email);
      if (context.mounted) {
        _showDialog(context, "Check your Email", message);
      }
    } on AuthException catch (e) {
      if (context.mounted) _showDialog(context, "Error", e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    try {
      isLoading.value = true;
      final message = await _authService.resetPassword(
        email: emailController.text.trim(),
        code: resetCodeController.text.trim(),
        newPassword: newPasswordController.text,
      );
      if (context.mounted) {
        _showDialog(context, "Success", message,
            confirmText: "Login Now",
            onConfirm: () => context.go(RouteConstants.login));
      }
    } on AuthException catch (e) {
      if (context.mounted) _showDialog(context, "Error", e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      final userIdString = await _storage.read(key: 'user_id');

      if (accessToken != null && userIdString != null) {
        final userId = int.parse(userIdString);

        final isValid =
            await _authService.verifyToken(accessToken: accessToken);

        if (isValid) {
          await _fetchUserPermissions(accessToken, userId);
          await _fetchUserProfile(accessToken, userId);
        } else {
          if (refreshToken != null) {
            log("Access token expired. Attempting refresh...");
            await _tryTokenRefresh(refreshToken, userId);
          } else {
            await logout();
          }
        }
      } else {
        await logout();
      }
    } catch (e) {
      log("Auth check error: $e");
      await logout();
    }
  }

  Future<void> _tryTokenRefresh(String refreshToken, int userId) async {
    try {
      final accessToken =
          await _authService.refreshToken(refreshToken: refreshToken);

      if (accessToken.isNotEmpty) {
        await _storage.write(key: 'access_token', value: accessToken);
      }

      log("Token refreshed successfully.");

      await _fetchUserPermissions(accessToken, userId);
      await _fetchUserProfile(accessToken, userId);
    } catch (e) {
      log("Token refresh failed: $e");
      await logout();
    }
  }
}
