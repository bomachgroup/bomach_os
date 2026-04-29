import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bomach_os/main.dart';
import 'package:bomach_os/src/services/events/event_service.dart';

class EventController extends GetxController {
  final EventService _service = EventService();

  var events = <Event>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  String get _token => prefs.getString('access_token') ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getEvents(_token);
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
      await _service.createEvent(_token, data);
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
      await _service.deleteEvent(_token, id);
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
