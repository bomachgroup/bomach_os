import 'dart:developer';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bomach_os/src/model/approval_model.dart';
import 'package:bomach_os/src/model/board_model.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:bomach_os/src/model/departments_units_model.dart';
import 'package:bomach_os/src/services/approval_service.dart';
import 'package:bomach_os/src/services/branch_service.dart';
import 'package:bomach_os/src/services/broadcast_service.dart';
import 'package:bomach_os/src/services/employees_services.dart';

class BroadcastController extends GetxController {
  final BroadcastService _broadcastService = BroadcastService();
  final BranchService _branchService = BranchService();
  final EmployeeService _employeeService = EmployeeService();
  final ApprovalService _approvalService = ApprovalService();
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
  var notificationFilter = ''.obs; // empty = all
  var unreadCount = 0.obs;
  var isLoadingNotifications = false.obs;

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
    fetchNotifications();
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

      await _broadcastService.deleteAnnouncement(accessToken: token, id: id);

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

  // ─── NOTIFICATIONS (Integrated with ApprovalService) ────────

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingNotifications.value = true;

      final token = await _getToken();
      if (token == null) return;

      final result = await _approvalService.getRequests(
        accessToken: token,
        limit: 50,
      );

      final List<NotificationItem> mapped = result.items.map((req) {
        return NotificationItem(
          title: req.flowName.isNotEmpty ? req.flowName : 'Approval Request',
          subtitle: 'Status: ${req.statusDisplay}',
          description: req.reason.isNotEmpty
              ? req.reason
              : '${req.requestedByName} requested approval for ${req.requestTypeDisplay.toLowerCase()}.',
          time: _getTimeAgo(req.createdAt),
          category: _mapRequestToCategory(req),
          isRead: false,
        );
      }).toList();

      notifications.assignAll(mapped);
      filterNotifications(notificationFilter.value);
      unreadCount.value = mapped.length;
    } catch (e) {
      log("Error fetching notifications (approvals): $e");
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  String _mapRequestToCategory(ApprovalRequest req) {
    final type = req.requestType.toLowerCase();
    if (type.contains('leave') || type.contains('loan')) return 'Staff';
    if (type.contains('asset') || type.contains('procure')) return 'Admin';
    return 'Admin';
  }

  String _getTimeAgo(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return 'Just now';
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(dateTime);

      if (diff.inDays >= 7) {
        return '${(diff.inDays / 7).floor()}w ago';
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeStr;
    }
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
