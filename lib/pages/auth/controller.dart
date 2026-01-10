import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../src/app_routes/app_route_constants.dart';
import '../../src/model/user_model.dart';
import 'service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
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
    // Check auth immediately when the controller is created.
    // This is neccessary to avoid navigation without authentication.
    // TODO: Display a loading screen while checking auth initially.
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
      _showSnackBar(context, 'Please enter both User ID and PIN', isError: true);
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

      // Updating currentUser.value will trigger GoRouter to redirect automatically!
      final user = await _authService.getCurrentUser(accessToken: response.accessToken);
      currentUser.value = user;

      if (context.mounted) {
        _showSnackBar(context, 'Login Successful');
      }

    } on AuthException catch (e) {
      if (context.mounted) _showDialog(context, "Error", e.message);
    } catch (e) {
      if (context.mounted) {
         _showDialog(context, "Connection Error", "Please check your internet connection.");
      }
    } finally {
      isLoading.value = false;
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
        _showDialog(context, "Check your Email", message, onConfirm: () {
          // TODO: Build route
          // context.push(RouteConstants.resetPassword);
        });
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
        _showDialog(
          context,
          "Success",
          message,
          confirmText: "Login Now",
          onConfirm: () => context.go(RouteConstants.login),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) _showDialog(context, "Error", e.message);
    } finally {
      isLoading.value = false;
    }
  }


 Future<void> checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final isValid = await _authService.verifyToken(accessToken: token);
        if (isValid) {
          final user = await _authService.getCurrentUser(accessToken: token);
          currentUser.value = user; 
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }
}
