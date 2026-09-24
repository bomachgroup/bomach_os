import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Profile password update using the existing email-code reset API flow.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({
    required this.email,
    this.authService,
    this.onCompleted,
    super.key,
  });

  final String email;
  final AuthService? authService;
  final VoidCallback? onCompleted;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  late final AuthService _authService = widget.authService ?? AuthService();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _codeRequested = false;
  bool _isLoading = false;
  bool _obscurePasswords = true;
  String? _errorMessage;
  String? _statusMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      final message = await _authService.forgotPassword(email: widget.email);
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _statusMessage = message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _readableError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_isLoading) return;
    final code = _codeController.text.trim();
    if (code.length < 4 || code.length > 12) {
      setState(
          () => _errorMessage = 'Enter the verification code from your email.');
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (_passwordController.text != _confirmationController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      await _authService.resetPassword(
        email: widget.email,
        code: code,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _readableError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _readableError(Object error) => error is AuthException
      ? error.message
      : 'Could not update your password. Please try again.';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.lock, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Change password',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We’ll send a verification code to ${widget.email}.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              if (_codeRequested) ...[
                const SizedBox(height: 20),
                TextField(
                  key: const ValueKey('password-reset-code'),
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: const InputDecoration(
                    labelText: 'Enter verification code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('new-password'),
                  controller: _passwordController,
                  obscureText: _obscurePasswords,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'New password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscurePasswords
                          ? 'Show passwords'
                          : 'Hide passwords',
                      onPressed: () => setState(
                        () => _obscurePasswords = !_obscurePasswords,
                      ),
                      icon: Icon(
                        _obscurePasswords ? Iconsax.eye : Iconsax.eye_slash,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('confirm-new-password'),
                  controller: _confirmationController,
                  obscureText: _obscurePasswords,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: const TextStyle(color: AppColors.success),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  key: const ValueKey('password-change-error'),
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isLoading
                    ? null
                    : _codeRequested
                        ? _updatePassword
                        : _requestCode,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_codeRequested ? Iconsax.tick_circle : Iconsax.sms),
                label: Text(
                  _isLoading
                      ? 'Please wait…'
                      : _codeRequested
                          ? 'Update password'
                          : 'Send verification code',
                ),
              ),
              if (_codeRequested)
                TextButton(
                  onPressed: _isLoading ? null : _requestCode,
                  child: const Text('Resend code'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
