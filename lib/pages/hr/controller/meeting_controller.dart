import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/model/employees_model.dart';
import '../../../src/services/employees_services.dart';
import '../../../src/services/hr/meetings_service.dart';
import '../models/meeting_model.dart';

class MeetingController extends GetxController {
  final MeetingsService _service = MeetingsService();
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  var meetings = <Meeting>[].obs;
  var employees = <Employee>[].obs;
  var isLoading = false.obs;
  var isLoadingEmployees = false.obs;
  var isSaving = false.obs;
  var totalCount = 0.obs;
  var currentSearch = ''.obs;
  var currentLimit = 10.obs;
  var currentOffset = 0.obs;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.replaceFirst('Bearer ', '');
    return token.replaceAll('"', '').trim();
  }

  void _snack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> fetchEmployees({String? search}) async {
    try {
      isLoadingEmployees(true);
      final token = await _getToken();
      if (token == null) return;
      final result = await _employeeService.getEmployees(
        token,
        search: search,
        isActive: true,
        limit: 200,
      );
      employees.assignAll(result.list);
    } catch (_) {
      // non-critical — search field degrades gracefully
    } finally {
      isLoadingEmployees(false);
    }
  }

  Future<void> fetchMeetings(BuildContext context,
      {String? search, String? status}) async {
    try {
      if (search != null) {
        currentSearch.value = search;
        currentOffset.value = 0;
      }
      isLoading(true);
      final token = await _getToken();
      if (token == null) return;
      final result = await _service.getMeetings(
        token,
        search: currentSearch.value.isEmpty ? null : currentSearch.value,
        status: status,
        limit: currentLimit.value,
        offset: currentOffset.value,
      );
      meetings.assignAll(result.items);
      totalCount.value = result.count;
    } catch (e) {
      _snack(context, 'Failed to load meetings: $e', error: true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> createMeeting(BuildContext context, Meeting meeting) async {
    try {
      isSaving(true);
      final token = await _getToken();
      if (token == null) return;
      await _service.createMeeting(token, meeting);
      _snack(context, 'Meeting created successfully');
      Navigator.of(context).pop();
      fetchMeetings(context);
    } catch (e) {
      _snack(context, 'Failed to create meeting: $e', error: true);
    } finally {
      isSaving(false);
    }
  }

  Future<void> updateMeeting(
      BuildContext context, int id, Meeting meeting) async {
    try {
      isSaving(true);
      final token = await _getToken();
      if (token == null) return;
      await _service.updateMeeting(token, id, meeting);
      _snack(context, 'Meeting updated successfully');
      Navigator.of(context).pop();
      fetchMeetings(context);
    } catch (e) {
      _snack(context, 'Failed to update meeting: $e', error: true);
    } finally {
      isSaving(false);
    }
  }

  Future<void> deleteMeeting(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _service.deleteMeeting(token, id);
      _snack(context, 'Meeting cancelled');
      fetchMeetings(context);
    } catch (e) {
      _snack(context, 'Failed to cancel meeting: $e', error: true);
    }
  }
}
