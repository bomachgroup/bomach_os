import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bms_front_end/src/model/board_model.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:bms_front_end/src/services/broadcast_service.dart';

class BroadcastController extends GetxController {
  final BroadcastService _broadcastService = BroadcastService();
  final _storage = const FlutterSecureStorage();

  // ─── Current tab ───────────────────────────────────────────────
  var currentTab = 'Announcements'.obs;

  // ─── Announcements state ──────────────────────────────────────
  var isLoadingAnnouncements = true.obs;
  var isSavingAnnouncement = false.obs;
  var announcementList = <Announcement>[].obs;
  var announcementSearchQuery = ''.obs;
  var announcementCurrentPage = 1.obs;
  var announcementLimit = 10.obs;
  var announcementTotalItems = 0.obs;

  // ─── Events state ─────────────────────────────────────────────
  var isLoadingEvents = true.obs;
  var isSavingEvent = false.obs;
  var eventList = <BroadcastEvent>[].obs;
  var eventSearchQuery = ''.obs;
  var eventCurrentPage = 1.obs;
  var eventLimit = 10.obs;
  var eventTotalItems = 0.obs;

  // ─── Notifications state (UI-only) ────────────────────────────
  var notifications = <NotificationItem>[].obs;
  var filteredNotifications = <NotificationItem>[].obs;
  var notificationFilter = ''.obs; // empty = all
  var unreadCount = 0.obs;

  // ─── Field choices ────────────────────────────────────────────
  var announcementChoices = Rxn<AnnouncementFieldChoices>();

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
    fetchEvents();
    loadAnnouncementChoices();
    loadDummyNotifications();
  }

  // ─── ANNOUNCEMENTS CRUD ───────────────────────────────────────

  Future<void> fetchAnnouncements({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingAnnouncements.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset =
          (announcementCurrentPage.value - 1) * announcementLimit.value;

      final result = await _broadcastService.getAnnouncements(
        accessToken: token,
        search: announcementSearchQuery.value.isNotEmpty
            ? announcementSearchQuery.value
            : null,
        limit: announcementLimit.value,
        offset: offset,
      );

      announcementList.assignAll(result.items);
      announcementTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching announcements: $e");
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  Future<void> createAnnouncement(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingAnnouncement.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Announcement payload: $data");
      await _broadcastService.createAnnouncement(
          accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAnnouncements(refresh: true);
        _showSnackBar(context, "Announcement created successfully");
      }
    } catch (e) {
      log("Create Announcement Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create announcement: ${e.toString()}");
      }
    } finally {
      isSavingAnnouncement.value = false;
    }
  }

  Future<void> updateAnnouncement(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSavingAnnouncement.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _broadcastService.updateAnnouncement(
          accessToken: token, id: id, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchAnnouncements(refresh: true);
        _showSnackBar(context, "Announcement updated successfully");
      }
    } catch (e) {
      log("Update Announcement Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update announcement");
      }
    } finally {
      isSavingAnnouncement.value = false;
    }
  }

  Future<void> deleteAnnouncement(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _broadcastService.deleteAnnouncement(
          accessToken: token, id: id);

      if (context.mounted) {
        fetchAnnouncements(refresh: true);
        _showSnackBar(context, "Announcement deleted successfully");
      }
    } catch (e) {
      log("Delete Announcement Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete announcement");
      }
    }
  }

  // ─── EVENTS CRUD ──────────────────────────────────────────────

  Future<void> fetchEvents({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingEvents.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (eventCurrentPage.value - 1) * eventLimit.value;

      final result = await _broadcastService.getEvents(
        accessToken: token,
        search: eventSearchQuery.value.isNotEmpty
            ? eventSearchQuery.value
            : null,
        limit: eventLimit.value,
        offset: offset,
      );

      eventList.assignAll(result.items);
      eventTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching events: $e");
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> createEvent(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingEvent.value = true;
      final token = await _getToken();
      if (token == null) return;

      log("Create Event payload: $data");
      await _broadcastService.createEvent(accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchEvents(refresh: true);
        _showSnackBar(context, "Event created successfully");
      }
    } catch (e) {
      log("Create Event Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create event: ${e.toString()}");
      }
    } finally {
      isSavingEvent.value = false;
    }
  }

  Future<void> updateEvent(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSavingEvent.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _broadcastService.updateEvent(
          accessToken: token, id: id, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchEvents(refresh: true);
        _showSnackBar(context, "Event updated successfully");
      }
    } catch (e) {
      log("Update Event Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update event");
      }
    } finally {
      isSavingEvent.value = false;
    }
  }

  Future<void> deleteEvent(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _broadcastService.deleteEvent(accessToken: token, id: id);

      if (context.mounted) {
        fetchEvents(refresh: true);
        _showSnackBar(context, "Event deleted successfully");
      }
    } catch (e) {
      log("Delete Event Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to delete event");
      }
    }
  }

  // ─── FIELD CHOICES ────────────────────────────────────────────

  Future<void> loadAnnouncementChoices() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      announcementChoices.value =
          await _broadcastService.getAnnouncementChoices(accessToken: token);
    } catch (e) {
      log("Error loading announcement choices: $e");
      // Fallback defaults
      announcementChoices.value = AnnouncementFieldChoices(
        announcementTypes: [
          BoardFieldOption(value: 'general', label: 'General'),
          BoardFieldOption(value: 'urgent', label: 'Urgent'),
          BoardFieldOption(value: 'policy', label: 'Policy'),
          BoardFieldOption(value: 'event', label: 'Event'),
        ],
        priorities: [
          BoardFieldOption(value: 'low', label: 'Low'),
          BoardFieldOption(value: 'normal', label: 'Normal'),
          BoardFieldOption(value: 'high', label: 'High'),
          BoardFieldOption(value: 'urgent', label: 'Urgent'),
        ],
      );
    }
  }

  // ─── NOTIFICATIONS (UI-only, dummy data) ──────────────────────

  /// TODO: Replace with real API integration when notification endpoints are available
  void loadDummyNotifications() {
    final dummyData = <NotificationItem>[
      NotificationItem(
        title: 'Announcement',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Admin',
      ),
      NotificationItem(
        title: 'Approvals',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Admin',
      ),
      NotificationItem(
        title: 'Tasks',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Staff',
      ),
      NotificationItem(
        title: 'Security Alert',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Admin',
      ),
      NotificationItem(
        title: 'Announcement',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Associate',
      ),
      NotificationItem(
        title: 'Announcement',
        subtitle: 'Company-wide policy update',
        description: 'A new update to company policy has been published',
        time: '2h ago',
        category: 'Investor',
      ),
    ];
    notifications.assignAll(dummyData);
    filteredNotifications.assignAll(dummyData);
    unreadCount.value =
        dummyData.where((n) => !n.isRead).length;
  }

  void filterNotifications(String category) {
    notificationFilter.value = category;
    if (category.isEmpty) {
      filteredNotifications.assignAll(notifications);
    } else {
      filteredNotifications.assignAll(
          notifications.where((n) => n.category == category).toList());
    }
  }

  void markAllRead() {
    // TODO: Call real API when available
    unreadCount.value = 0;
  }

  // ─── FILTER / SEARCH ACTIONS ──────────────────────────────────

  void onAnnouncementSearchChanged(String val) {
    announcementSearchQuery.value = val;
    announcementCurrentPage.value = 1;
    fetchAnnouncements();
  }

  void onEventSearchChanged(String val) {
    eventSearchQuery.value = val;
    eventCurrentPage.value = 1;
    fetchEvents();
  }

  // ─── PAGINATION ───────────────────────────────────────────────

  void announcementGoToPage(int page) {
    announcementCurrentPage.value = page;
    fetchAnnouncements();
  }

  void announcementSetLimit(int newLimit) {
    announcementLimit.value = newLimit;
    announcementCurrentPage.value = 1;
    fetchAnnouncements();
  }

  void eventGoToPage(int page) {
    eventCurrentPage.value = page;
    fetchEvents();
  }

  void eventSetLimit(int newLimit) {
    eventLimit.value = newLimit;
    eventCurrentPage.value = 1;
    fetchEvents();
  }

  // ─── HELPERS ──────────────────────────────────────────────────

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
