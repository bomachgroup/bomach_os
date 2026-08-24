import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bomach_os/src/services/events/event_service.dart';

class EventController extends GetxController {
  final EventService _service = EventService();
  final _storage = const FlutterSecureStorage();

  var events = <Event>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  /// Audit B4 fix: tokens live in FlutterSecureStorage (written at login),
  /// never in SharedPreferences. The old `prefs.getString('access_token')`
  /// read a key nothing ever writes, so every request went out with an
  /// empty bearer and the calendar could never load.
  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) {
      token = token.replaceFirst('Bearer ', '');
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      errorMessage('');
      final token = await _getToken();
      if (token == null) {
        errorMessage('Please sign in to view events.');
        return;
      }
      final result = await _service.getEvents(token);
      events.assignAll(result.items);
    } catch (e) {
      errorMessage('Failed to load events: $e');
      debugPrint("EventController fetchEvents error: $e");
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    try {
      isLoading(true);
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Please sign in again.');
        return false;
      }
      await _service.createEvent(token, data);
      await fetchEvents();
      Get.snackbar('Success', 'Event created successfully');
      return true;
    } catch (e) {
      debugPrint("EventController createEvent error: $e");
      Get.snackbar('Error', 'Failed to create event');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteEvent(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        Get.snackbar('Error', 'Please sign in again.');
        return false;
      }
      await _service.deleteEvent(token, id);
      events.removeWhere((e) => e.id == id);
      Get.snackbar('Success', 'Event deleted successfully');
      return true;
    } catch (e) {
      debugPrint("EventController deleteEvent error: $e");
      Get.snackbar('Error', 'Failed to delete event');
      await fetchEvents();
      return false;
    }
  }

  /// Group events by normalized date (year, month, day) for calendar display.
  Map<DateTime, List<Event>> get eventsByDay {
    final Map<DateTime, List<Event>> grouped = {};
    for (final event in events) {
      final parsed = DateTime.tryParse(event.eventTimeFrom);
      if (parsed != null) {
        final key = DateTime(parsed.year, parsed.month, parsed.day);
        grouped.putIfAbsent(key, () => []).add(event);
      }
    }
    return grouped;
  }

  List<Event> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return eventsByDay[key] ?? [];
  }
}
