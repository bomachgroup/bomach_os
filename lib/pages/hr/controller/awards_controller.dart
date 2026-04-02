import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/services/hr/awards_service.dart';
import '../models/awards_model.dart';

class AwardsController extends GetxController {
  final AwardService _service = AwardService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var awardsList = <Award>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchAwards(String token, {int? year}) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getAwards(
        token,
        year: year,
        limit: limit,
        offset: offset,
      );
      awardsList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load awards: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createAward(String token, Award award) async {
    try {
      isSaving(true);
      await _service.createAward(token, award);
      await fetchAwards(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateAward(String token, String id, Award award) async {
    try {
      isSaving(true);
      await _service.updateAward(token, id, award);
      await fetchAwards(token);
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteAward(String token, String id) async {
    try {
      await _service.deleteAward(token, id);
      awardsList.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      await fetchAwards(token);
      return false;
    }
  }
}
