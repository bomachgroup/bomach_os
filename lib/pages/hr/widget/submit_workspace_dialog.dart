import 'dart:developer';

import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../controller/biometrics_controller.dart';

/// Submit-for-approval workspace dialog. The user provides:
///   - Workspace name (required)
///   - GPS location captured via the browser (required)
///   - Notes (optional)
///
/// The radius is hardcoded server-side to 100m — we never show or ask for
/// it here. After submit, the workspace lands as PENDING and is reviewed by
/// an admin.
class SubmitWorkspaceDialog extends StatefulWidget {
  final String token;
  const SubmitWorkspaceDialog({super.key, required this.token});

  @override
  State<SubmitWorkspaceDialog> createState() => _SubmitWorkspaceDialogState();
}

class _SubmitWorkspaceDialogState extends State<SubmitWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _location = LocationService();

  Position? _position;
  bool _fetchingLocation = false;
  String? _locationError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _fetchingLocation = true;
      _locationError = null;
    });

    try {
      final hasPermission = await _location.ensurePermission();
      if (!hasPermission) {
        setState(() => _locationError =
            'Location permission denied. Enable it in your browser settings.');
        return;
      }

      final pos = await _location.getCurrentPosition();
      setState(() => _position = pos);
    } catch (e) {
      log('Fetch location error: $e');
      setState(() => _locationError = 'Failed to get location. Try again.');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_position == null) {
      setState(() => _locationError = 'Capture your current location first.');
      return;
    }

    final controller = Get.find<BiometricsController>();
    final success = await controller.submitWorkspace(
      widget.token,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      workspaceName: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Submitted for approval'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(controller.errorMessage.value),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_location_alt_rounded,
                          color: AppColors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const MyText(
                      'Submit Workspace',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your submission will be reviewed by an admin before '
                        "it's usable for clock-in.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // GPS section
                      const MyText(
                        'GPS Location',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLocationSection(),

                      const SizedBox(height: 20),

                      // Workspace name
                      const MyText(
                        'Workspace Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Home Office, Lagos Branch',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Workspace name is required'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Notes
                      const MyText(
                        'Notes (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesCtrl,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              "Anything the admin should know about this location",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Obx(() {
              final submitting = Get.find<BiometricsController>()
                  .isSettingUpWorkspace
                  .value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit for Approval',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    if (_position != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 16),
                SizedBox(width: 8),
                Text(
                  'Location captured',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF047857)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_position!.latitude.toStringAsFixed(6)}\n'
              'Lng: ${_position!.longitude.toStringAsFixed(6)}\n'
              'Accuracy: ${_position!.accuracy.toStringAsFixed(1)}m',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF166534),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchingLocation ? null : _fetchLocation,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Re-fetch', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          if (_locationError != null) ...[
            Text(
              _locationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchingLocation ? null : _fetchLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: _fetchingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                _fetchingLocation
                    ? 'Getting location...'
                    : 'Capture Current Location',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
