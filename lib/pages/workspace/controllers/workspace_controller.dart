import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/hr/meetings_service.dart';
import '../../hr/models/meeting_model.dart';

class WorkspaceController extends GetxController {
  final MeetingsService _meetingsService = MeetingsService();
  final _storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var meetings = <Meeting>[].obs;
  var totalMeetings = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
  }

  Future<void> fetchMeetings({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _meetingsService.getMeetings(token);
      meetings.assignAll(result.items);
      totalMeetings.value = result.count;
    } catch (e) {
      log("Error fetching meetings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }
}
