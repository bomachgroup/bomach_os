import 'dart:js_interop';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import '../../../src/utils/face_liveness_interop.dart';

class FaceLivenessDialog extends StatefulWidget {
  const FaceLivenessDialog({super.key});

  @override
  State<FaceLivenessDialog> createState() => _FaceLivenessDialogState();
}

class _FaceLivenessDialogState extends State<FaceLivenessDialog> {
  final String viewType = 'face-liveness-video';
  String _statusMessage = 'Starting camera...';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Register the raw video element for HtmlElementView
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final web.HTMLVideoElement videoElement = web.HTMLVideoElement()
        ..id = viewType
        ..autoplay = true
        ..controls = false
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)'; // Mirror for user-facing camera
      return videoElement;
    });

    // Setup Dart callbacks
    onBiometricProgress = _onProgress.toJS;
    onBiometricError = _onError.toJS;
    onBiometricSuccess = _onSuccess.toJS;

    // We must wait a frame for the view to render into the DOM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          startLivenessCheck(viewType.toJS);
        }
      });
    });
  }

  void _onProgress(JSString msg) {
    if (mounted) {
      setState(() {
        _statusMessage = msg.toDart;
      });
    }
  }

  void _onError(JSString errMsg) {
    if (mounted) {
      setState(() {
        _isError = true;
        _statusMessage = errMsg.toDart;
      });
    }
  }

  void _onSuccess(JSString base64Image) {
    if (mounted) {
      Navigator.of(context).pop(base64Image.toDart);
    }
  }

  @override
  void dispose() {
    stopLivenessCheck();
    super.dispose();
  }

  Color _borderColor() {
    if (_statusMessage.contains('Verified')) return AppColors.success;
    if (_statusMessage.contains('LEFT') || _statusMessage.contains('RIGHT')) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Face Verification',
      subtitle: 'Keep your face within the circle and follow the prompts.',
      size: DialogSize.sm,
      scrollable: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: AppRadii.brLg,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadii.brLg,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    HtmlElementView(viewType: viewType),
                    // Custom circle overlay to guide the user
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _borderColor().withValues(alpha: 0.8),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isError
                  ? AppColors.dangerSubtle
                  : AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
              border: Border.all(
                color: _isError
                    ? AppColors.danger.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              _statusMessage,
              style: AppTextStyles.bodyMd.copyWith(
                color: _isError ? AppColors.danger : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel Verification',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
