import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../src/services/role_kpi_service.dart';
import '../../../src/services/role_okr_service.dart';

enum TargetType { kpi, okr }

class TargetItem {
  final TargetType type;
  final String title;
  final String subtitle;
  final double? progress;
  final String? unit;
  final String? frequency;
  final String? quarterOrYear;
  final dynamic source;

  TargetItem({
    required this.type,
    required this.title,
    required this.subtitle,
    this.progress,
    this.unit,
    this.frequency,
    this.quarterOrYear,
    this.source,
  });
}

class TargetsController extends GetxController {
  final RoleKpiService _kpiService = RoleKpiService();
  final RoleOkrService _okrService = RoleOkrService();
  final _storage = const FlutterSecureStorage();

  var targets = <TargetItem>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  int? scopedRoleId;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchTargets({int? roleId}) async {
    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null) return;

      final role = roleId ?? scopedRoleId;
      if (role == null) return;

      final items = <TargetItem>[];

      try {
        final kpiResult = await _kpiService.listRoleKpis(
          token,
          roleId: role,
          limit: 100,
        );
        for (final kpi in kpiResult.list) {
          items.add(TargetItem(
            type: TargetType.kpi,
            title: kpi.metricName,
            subtitle: 'Target: ${kpi.target} ${kpi.unit}',
            progress: kpi.target > 0 ? null : null,
            unit: kpi.unit,
            frequency: kpi.frequency,
            source: kpi,
          ));
        }
      } catch (_) {}

      try {
        final okrResult = await _okrService.listRoleOkrs(
          token,
          roleId: role,
          limit: 100,
        );
        for (final okr in okrResult.list) {
          final avgProgress = okr.overallProgress;

          items.add(TargetItem(
            type: TargetType.okr,
            title: okr.objective,
            subtitle: 'Q${okr.quarter} ${okr.year}',
            progress: avgProgress,
            quarterOrYear: 'Q${okr.quarter} ${okr.year}',
            source: okr,
          ));
        }
      } catch (_) {}

      targets.assignAll(items);
    } catch (e) {
      log('TargetsController.fetchTargets error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
