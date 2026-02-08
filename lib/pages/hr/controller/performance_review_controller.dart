import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:get/get.dart';

import '../../../src/services/hr/performance_review.dart';
import '../models/performance_review.dart';

class PerformanceReviewController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final PerformanceReviewService _service = PerformanceReviewService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var performanceReviews = <PerformanceReview>[].obs;

  var limit = 100;
  var offset = 0;

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPerformanceReviews();
  }

  Future<void> fetchPerformanceReviews() async {
    try {
      isLoading(true);
      final context = Get.context;
      if (context == null) return;
      final token = await _getToken(context);
      if (token == null) {
        _showSnackBar(context, 'Error', 'Authentication token not found');
        return;
      }
      final reviews = await _service.getPerformanceReviews(token,
          limit: limit, offset: offset);
      performanceReviews.assignAll(reviews);
    } catch (e) {
      final context = Get.context;
      if (context != null)
        _showSnackBar(context, 'Error', 'Failed to fetch reviews: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createReview(PerformanceReview review) async {
    try {
      isSaving(true);
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) {
        _showSnackBar(context, 'Error', 'Authentication token not found');
        return false;
      }
      final createdReview =
          await _service.createPerformanceReview(token, review);
      if (createdReview != null) {
        await fetchPerformanceReviews();
        _showSnackBar(
            context, 'Success', 'Performance review created successfully');
        return true;
      }
      return false;
    } catch (e) {
      final context = Get.context;
      if (context != null)
        _showSnackBar(context, 'Error', 'Failed to create review: $e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateReview(String id, PerformanceReview review) async {
    try {
      isSaving(true);
      final context = Get.context;
      if (context == null) return false;
      final token = await _getToken(context);
      if (token == null) {
        _showSnackBar(context, 'Error', 'Authentication token not found');
        return false;
      }
      if (id.isEmpty) {
        _showSnackBar(context, 'Error', 'Review ID is missing');
        return false;
      }
      await _service.updatePerformanceReview(token, id, review);
      await fetchPerformanceReviews();
      _showSnackBar(
          context, 'Success', 'Performance review updated successfully');
      return true;
    } catch (e) {
      final context = Get.context;
      if (context != null)
        _showSnackBar(context, 'Error', 'Failed to update review: $e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      performanceReviews.removeWhere((r) => r.id == id);
      final context = Get.context;
      if (context == null) return;
      final token = await _getToken(context);
      if (token == null) {
        _showSnackBar(context, 'Error', 'Authentication token not found');
        return;
      }
      await _service.deletePerformanceReview(token, id);
      _showSnackBar(context, 'Success', 'Review deleted successfully');
    } catch (e) {
      fetchPerformanceReviews();
      final context = Get.context;
      if (context != null)
        _showSnackBar(context, 'Error', 'Failed to delete review: $e');
    }
  }

  void _showSnackBar(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
