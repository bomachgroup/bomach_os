import 'dart:developer';

import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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

  // `location_type` is required by the backend's SubmitWorkLocationRequest.
  // The backend's enum is `branch` | `remote` | `site`; the OpenAPI spec
  // declares the field as a plain string (no enum constraint), so if the
  // backend ever broadens its choices we'll need to update this map.
  static const _locationTypes = <String, String>{
    'Branch': 'branch',
    'Remote': 'remote',
    'Site': 'site',
  };
  String _locationLabel = 'Branch';

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
      locationType: _locationTypes[_locationLabel] ?? 'branch',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      AppToast.success(context, 'Submitted for approval');
    } else {
      AppToast.error(context, controller.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Submit Workspace',
      subtitle: 'Submit a new work location for admin approval.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSubtle,
                borderRadius: AppRadii.brMd,
                border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle,
                      color: AppColors.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your submission will be reviewed by an admin before "
                      "it's usable for clock-in.",
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'GPS Location',
              subtitle:
                  'Capture your current coordinates. We use these to define the geofence.',
              child: _buildLocationSection(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Workspace details',
              subtitle: 'Give this location a name and choose its type.',
              child: Column(
                children: [
                  MyTextFormField(
                    controller: _nameCtrl,
                    title: 'Workspace Name',
                    hintText: 'e.g. Home Office, Lagos Branch',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Workspace name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  MyDropdown(
                    title: 'Location Type',
                    hintText: _locationLabel,
                    items: _locationTypes.keys.toList(),
                    initialSelection: _locationLabel,
                    onChanged: (val) {
                      if (val != null) setState(() => _locationLabel = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Notes',
              child: MyTextFormField(
                controller: _notesCtrl,
                title: 'Notes (optional)',
                hintText:
                    'Anything the admin should know about this location',
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(() {
          final submitting = Get.find<BiometricsController>()
              .isSettingUpWorkspace
              .value;
          return MyOutlinedButton(
            child: 'Cancel',
            height: 44,
            onTap:
                submitting ? null : () => Navigator.of(context).pop(),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          );
        }),
        Obx(() {
          final submitting = Get.find<BiometricsController>()
              .isSettingUpWorkspace
              .value;
          return MyElevatedButton(
            width: 200,
            height: 44,
            child: submitting ? 'Submitting...' : 'Submit for Approval',
            icon: submitting
                ? null
                : const Icon(Iconsax.send_2,
                    size: 18, color: AppColors.textOnPrimary),
            onTap: submitting ? null : _submit,
          );
        }),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    if (_position != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successSubtle,
          borderRadius: AppRadii.brMd,
          border:
              Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.tick_circle,
                    color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Location captured',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${_position!.latitude.toStringAsFixed(6)}\n'
              'Lng: ${_position!.longitude.toStringAsFixed(6)}\n'
              'Accuracy: ${_position!.accuracy.toStringAsFixed(1)}m',
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textPrimary, height: 1.5),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchingLocation ? null : _fetchLocation,
              icon: const Icon(Iconsax.refresh, size: 14),
              label: Text(
                'Re-fetch',
                style:
                    AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          if (_locationError != null) ...[
            Text(
              _locationError!,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: MyElevatedButton(
              height: 44,
              child: _fetchingLocation
                  ? 'Getting location...'
                  : 'Capture Current Location',
              icon: _fetchingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.textOnPrimary),
                    )
                  : const Icon(Iconsax.location,
                      size: 18, color: AppColors.textOnPrimary),
              onTap: _fetchingLocation ? null : _fetchLocation,
            ),
          ),
        ],
      ),
    );
  }
}
