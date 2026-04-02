import 'dart:developer';

import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../controller/biometrics_controller.dart';

class SetupWorkspaceDialog extends StatefulWidget {
  final String token;
  const SetupWorkspaceDialog({super.key, required this.token});

  @override
  State<SetupWorkspaceDialog> createState() => _SetupWorkspaceDialogState();
}

class _SetupWorkspaceDialogState extends State<SetupWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '100');
  final _location = LocationService();

  Position? _position;
  bool _fetchingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<BiometricsController>();
    final ws = controller.workspace.value;
    if (ws != null) {
      _nameCtrl.text = ws.workspaceName;
      _radiusCtrl.text = ws.radiusMeters.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _radiusCtrl.dispose();
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
        setState(() =>
            _locationError = 'Location permission denied. Enable in browser settings.');
        return;
      }

      final pos = await _location.getCurrentPosition();
      setState(() => _position = pos);
    } catch (e) {
      log('Fetch location error: $e');
      setState(() => _locationError = 'Failed to get location. Try again.');
    } finally {
      setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_position == null) {
      setState(() => _locationError = 'Please fetch your location first.');
      return;
    }

    final controller = Get.find<BiometricsController>();
    final radius = int.tryParse(_radiusCtrl.text.trim());
    if (radius == null || radius < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Radius must be at least 10 meters'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final success = await controller.saveWorkspace(
      widget.token,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      workspaceName: _nameCtrl.text.trim(),
      radiusMeters: radius,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Workspace saved successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(controller.errorMessage.value),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = Get.find<BiometricsController>().workspace.value != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
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
                      child: const Icon(Icons.location_on_rounded,
                          color: AppColors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    MyText(
                      isEdit ? 'Update Workspace' : 'Setup Workspace',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
                      // Location fetch
                      const MyText('GPS Location',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B))),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: _position != null
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 16),
                                      SizedBox(width: 8),
                                      MyText('Location captured',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lat: ${_position!.latitude.toStringAsFixed(6)}\n'
                                    'Lng: ${_position!.longitude.toStringAsFixed(6)}\n'
                                    'Accuracy: ${_position!.accuracy.toStringAsFixed(1)}m',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        height: 1.5),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed:
                                        _fetchingLocation ? null : _fetchLocation,
                                    icon: const Icon(Icons.refresh, size: 14),
                                    label: const Text('Re-fetch',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  if (_locationError != null) ...[
                                    Text(
                                      _locationError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _fetchingLocation
                                          ? null
                                          : _fetchLocation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: _fetchingLocation
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white))
                                          : const Icon(
                                              Icons.my_location_rounded,
                                              size: 18),
                                      label: Text(
                                        _fetchingLocation
                                            ? 'Getting location...'
                                            : 'Fetch Current Location',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Workspace name
                      const MyText('Workspace Name',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Main Office, Site A',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),

                      const SizedBox(height: 20),

                      // Radius
                      const MyText('Allowed Radius (meters)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _radiusCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g., 100',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          suffixText: 'meters',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 10) {
                            return 'Minimum 10 meters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        'Employees must be within this radius of the GPS coordinates to clock in/out.',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Obx(() {
              final saving =
                  Get.find<BiometricsController>().isSettingUpWorkspace.value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? 'Update' : 'Save',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
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
}
