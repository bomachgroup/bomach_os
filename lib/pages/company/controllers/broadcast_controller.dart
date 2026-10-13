import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bomach_os/src/model/board_model.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/model/departments_units_model.dart';
import 'package:bomach_os/src/services/branch_service.dart';
import 'package:bomach_os/src/services/broadcast_service.dart';
import 'package:bomach_os/src/services/notification_service.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/services/employees_services.dart';

class BroadcastController extends GetxController {
  final BroadcastService _broadcastService = BroadcastService();
  final BranchService _branchService = BranchService();
  final EmployeeService _employeeService = EmployeeService();
  final NotificationService _notificationService = NotificationService();
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

  // ─── Notifications state (Integrated) ─────────────────────────
  var notifications = <NotificationItem>[].obs;
  var filteredNotifications = <NotificationItem>[].obs;
  var notificationFilter = 'All'.obs;
  var unreadCount = 0.obs;
  var isLoadingNotifications = false.obs;
  var notificationError = ''.obs;
  var notificationTotalCount = 0.obs;

  // ─── Field choices ────────────────────────────────────────────
  var announcementChoices = Rxn<AnnouncementFieldChoices>();

  // ─── Branch & Department data for targeting ───────────────────
  var branches = <Branch>[].obs;
  var departments = <Department>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
    fetchEvents();
    loadAnnouncementChoices();
    _fetchBranchesAndDepartments();
  }

  void setCurrentTab(String tab) {
    currentTab.value = tab;
    if (tab == 'Notifications') fetchNotifications();
  }

  Future<void> _fetchBranchesAndDepartments() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final results = await Future.wait([
        _branchService.getBranches(accessToken: token, limit: 200),
        _employeeService.getDepartments(token, limit: 200),
      ]);
      branches
          .assignAll((results[0] as ({List<Branch> items, int total})).items);
      departments.assignAll(results[1] as List<Department>);
    } catch (e) {
      log("Error fetching branches/departments for broadcast: $e");
    }
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
        _showErrorDialog(
            context, "Failed to update announcement: ${e.toString()}");
      }
    } finally {
      isSavingAnnouncement.value = false;
    }
  }

  Future<void> deleteAnnouncement(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _broadcastService.deleteAnnouncement(accessToken: token, id: id);

      if (context.mounted) {
        fetchAnnouncements(refresh: true);
        _showSnackBar(context, "Announcement deleted successfully");
      }
    } catch (e) {
      log("Delete Announcement Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to delete announcement: ${e.toString()}");
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
        search:
            eventSearchQuery.value.isNotEmpty ? eventSearchQuery.value : null,
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
        _showErrorDialog(context, "Failed to create event: ${e.toString()}");
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

  // ─── NOTIFICATIONS ──────────────────────────────────────────

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (notifications.isEmpty || !refresh) {
        isLoadingNotifications.value = true;
      }
      notificationError.value = '';

      final token = await _getToken();
      if (token == null) return;

      final inbox = await _notificationService.list(token: token, limit: 50);
      notifications.assignAll(inbox.items);
      notificationTotalCount.value = inbox.total;
      try {
        unreadCount.value =
            await _notificationService.unreadCount(token: token);
      } catch (_) {
        unreadCount.value = inbox.items.where((item) => !item.isRead).length;
      }
      filterNotifications(notificationFilter.value);
    } catch (e) {
      log("Error fetching notifications: $e");
      notificationError.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  void filterNotifications(String category) {
    notificationFilter.value = category;
    filteredNotifications.assignAll(switch (category) {
      'Unread' => notifications.where((n) => !n.isRead).toList(),
      'Read' => notifications.where((n) => n.isRead).toList(),
      _ => notifications.toList(),
    });
  }

  Future<void> markNotificationRead(NotificationItem notification) async {
    if (notification.isRead || notification.id == null) return;
    if (!Get.find<PermissionService>().has(Perms.notificationsMarkRead)) return;
    try {
      final token = await _getToken();
      if (token == null) return;
      final updated = await _notificationService.markRead(
        token: token,
        notificationId: notification.id!,
      );
      final index = notifications.indexWhere((item) => item.id == updated.id);
      if (index >= 0) notifications[index] = updated;
      unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 30);
      filterNotifications(notificationFilter.value);
    } catch (e) {
      notificationError.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    if (!Get.find<PermissionService>().has(Perms.notificationsMarkAllRead)) {
      return;
    }
    try {
      final token = await _getToken();
      if (token == null) return;
      await _notificationService.markAllRead(token: token);
      notifications
          .assignAll(notifications.map((n) => n.copyWith(isRead: true)));
      unreadCount.value = 0;
      filterNotifications(notificationFilter.value);
    } catch (e) {
      notificationError.value = e.toString().replaceFirst('Exception: ', '');
    }
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

  Future<String?> getToken() async {
    return await _getToken();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    DialogScaffold.show(
      context,
      title: "Error",
      size: DialogSize.sm,
      body: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("OK")),
      ],
    );
  }
}
