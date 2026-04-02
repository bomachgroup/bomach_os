import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../src/services/marketing/marketing_service.dart';

class MarketingController extends GetxController {
  final MarketingService _service = MarketingService();
  final _storage = const FlutterSecureStorage();

  var isLoadingCampaigns = true.obs;
  var isLoadingContent = true.obs;
  var isSaving = false.obs;

  var campaignList = <MarketingCampaign>[].obs;
  var contentList = <MarketingContent>[].obs;
  var totalCampaigns = 0.obs;
  var totalContent = 0.obs;

  var campaignSearch = ''.obs;
  var contentSearch = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
    fetchContent();
  }

  // ─── CAMPAIGNS ────────────────────────────────────────────────────

  Future<void> fetchCampaigns({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingCampaigns.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getCampaigns(
        token,
        search: campaignSearch.value.isNotEmpty ? campaignSearch.value : null,
      );
      campaignList.assignAll(result.items);
      totalCampaigns.value = result.total;
    } catch (e) {
      log("Error fetching campaigns: $e");
    } finally {
      isLoadingCampaigns.value = false;
    }
  }

  Future<void> createCampaign(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.createCampaign(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchCampaigns(refresh: true);
        _showSnackBar(context, "Campaign created successfully");
      }
    } catch (e) {
      log("Create Campaign Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create campaign: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCampaign(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _service.deleteCampaign(token, id);
      if (context.mounted) {
        fetchCampaigns(refresh: true);
        _showSnackBar(context, "Campaign deleted");
      }
    } catch (e) {
      log("Delete Campaign Error: $e");
      if (context.mounted)
        _showErrorDialog(context, "Failed to delete campaign");
    }
  }

  // ─── CONTENT ──────────────────────────────────────────────────────

  Future<void> fetchContent({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingContent.value = true;
      final token = await _getToken();
      if (token == null) return;

      final result = await _service.getContent(
        token,
        search: contentSearch.value.isNotEmpty ? contentSearch.value : null,
      );
      contentList.assignAll(result.items);
      totalContent.value = result.total;
    } catch (e) {
      log("Error fetching content: $e");
    } finally {
      isLoadingContent.value = false;
    }
  }

  Future<void> createContent(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _service.createContent(token, data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchContent(refresh: true);
        _showSnackBar(context, "Content created successfully");
      }
    } catch (e) {
      log("Create Content Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create content: ${e.toString()}");
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteContent(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _service.deleteContent(token, id);
      if (context.mounted) {
        fetchContent(refresh: true);
        _showSnackBar(context, "Content deleted");
      }
    } catch (e) {
      log("Delete Content Error: $e");
      if (context.mounted)
        _showErrorDialog(context, "Failed to delete content");
    }
  }

  // ─── SEARCH ───────────────────────────────────────────────────────

  void onCampaignSearchChanged(String val) {
    campaignSearch.value = val;
    fetchCampaigns();
  }

  void onContentSearchChanged(String val) {
    contentSearch.value = val;
    fetchContent();
  }

  // ─── HELPERS ──────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("OK")),
        ],
      ),
    );
  }
}
