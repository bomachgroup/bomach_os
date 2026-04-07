import 'dart:js_interop';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Face Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black12,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      HtmlElementView(viewType: viewType),
                      // Custom circle overlay to guide the user
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _statusMessage.contains('Verified')
                                  ? Colors.green
                                  : _statusMessage.contains('LEFT') ||
                                          _statusMessage.contains('RIGHT')
                                      ? Colors.orange
                                      : Colors.blueAccent.withValues(alpha: 0.5),
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
            Text(
              _statusMessage,
              style: TextStyle(
                color: _isError ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Cancel Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
