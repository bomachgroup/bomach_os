import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/services/hr/asset_services.dart';
import '../models/assets_model.dart';


class AssetController extends GetxController {
  final AssetService _service = AssetService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var assetList = <Asset>[].obs;
  var errorMessage = ''.obs;

  int limit = 100;
  int offset = 0;

  Future<void> fetchAssets(String token) async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getAssets(
        token,
        limit: limit,
        offset: offset,
      );
      assetList.assignAll(result);
    } catch (e) {
      errorMessage('Failed to load assets: $e');
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createAsset(String token, Asset asset) async {
    try {
      isSaving(true);
      await _service.createAsset(token, asset);
      await fetchAssets(token);
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateAsset(String token, String id, Asset asset) async {
    try {
      isSaving(true);
      await _service.updateAsset(token, id, asset);
      await fetchAssets(token); 
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteAsset(String token, String id) async {
    try {
      await _service.deleteAsset(token, id);
      assetList.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      await fetchAssets(token); 
      return false;
    }
  }
}