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
  final twoFactorCodeController = TextEditingController();
  var isPending2Fa = false.obs;
  var is2FaEnabled = false.obs;
  String? currentSessionToken;

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
    twoFactorCodeController.dispose();
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

      if (response.requires2Fa) {
        // Pending 2FA
        isPending2Fa.value = true;
        _storage.write(key: 'session_token', value: response.sessionToken);

        if (context.mounted) {
          _showSnackBar(context, response.detail.isNotEmpty ? response.detail : '2FA code sent to your email');
          context.push(RouteConstants.twoFactorVerify);
        }
        return;
      }

      // If 2FA is disabled and it returns access token right away
      if (response.accessToken.isNotEmpty) {
        await _storage.write(key: 'access_token', value: response.accessToken);
        await _storage.write(key: 'refresh_token', value: response.refreshToken);
        await _storage.write(key: 'user_id', value: response.userId.toString());

        // Fetch permissions
        await _fetchUserPermissions(response.accessToken, response.userId);

        // Fetch profile
        await _fetchUserProfile(response.accessToken, response.userId);

        if (context.mounted) {
          _showSnackBar(context, 'Login Successful');
          context.go(RouteConstants.home);
        }
      } else {
        throw AuthException(message: 'Invalid server response without access token or session token');
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

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    bool isObscure = true;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirm Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to proceed with 2FA changes.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => isObscure = !isObscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle 2FA Setting
  Future<void> toggle2Fa(BuildContext context, bool isEnabled) async {
    final password = await _showPasswordDialog(context);
    if (password == null || password.isEmpty) {
      if (context.mounted) {
         _showSnackBar(context, 'Password is required to change 2FA settings', isError: true);
      }
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null || currentUser.value == null) return;

      bool newStatus;
      if (isEnabled) {
        newStatus = await _authService.enable2Fa(token, password);
      } else {
        newStatus = await _authService.disable2Fa(token, password);
      }

      is2FaEnabled.value = newStatus;
      
      if (context.mounted) {
        _showSnackBar(context, newStatus ? '2FA Enabled' : '2FA Disabled');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to update 2FA setting: $e', isError: true);
      }
    }
  }

  Future<void> _fetchUserProfile(String token, int userId) async {
    try {
      final user =
          await _authService.getCurrentUser(accessToken: token, userId: userId);
      currentUser.value = user;

      try {
        is2FaEnabled.value = await _authService.get2FaStatus(token);
      } catch (e) {
        log('Failed to fetch 2FA status: $e');
      }
    } catch (e) {
      log("Failed to fetch user profile: $e");
      // If profile fetch fails (e.g. not an employee), we MUST logout the user
      // so they aren't stuck in a partially authenticated state.
      await logout();
      throw AuthException(message: e is AuthException ? e.message : 'Could not find employee profile');
    }
  }

  Future<void> _fetchUserPermissions(String token, int userId) async {
    try {
      log("AuthController: Fetching roles for user $userId.");

      final roles = await _authService.getEmployeeRoles(
          accessToken: token, userId: userId);

      if (roles.isEmpty) {
        log("AuthController: No roles found. Loading default permissions.");
        _permissionService.loadDefaultPermissions();
      } else {
        _permissionService.loadPermissions(roles);
      }
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

  Future<void> verify2Fa(BuildContext context) async {
    if (twoFactorCodeController.text.trim().isEmpty) {
      _showSnackBar(context, 'Please enter the 6-digit code', isError: true);
      return;
    }
    if (currentSessionToken == null || currentSessionToken!.isEmpty) {
      _showSnackBar(context, 'Session expired. Please log in again.', isError: true);
      context.go(RouteConstants.login);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final response = await _authService.verify2Fa(
        sessionToken: currentSessionToken!,
        code: twoFactorCodeController.text.trim(),
      );

      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);
      await _storage.write(key: 'user_id', value: response.userId.toString());

      // Fetch permissions
      await _fetchUserPermissions(response.accessToken, response.userId);

      await _fetchUserProfile(response.accessToken, response.userId);

      currentSessionToken = null;
      twoFactorCodeController.clear();

      if (context.mounted) {
        _showSnackBar(context, 'Login Successful');
        context.go(RouteConstants.home);
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
