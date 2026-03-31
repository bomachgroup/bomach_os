import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bms_front_end/src/model/board_model.dart';
import 'package:bms_front_end/src/model/employees_model.dart';
import 'package:bms_front_end/src/model/partner_model.dart';
import 'package:bms_front_end/src/services/board_service.dart';
import 'package:bms_front_end/src/services/employees_services.dart';
import 'package:bms_front_end/src/services/partner_service.dart';

class BoardController extends GetxController {
  final BoardService _boardService = BoardService();
  final EmployeeService _employeeService = EmployeeService();
  final PartnerService _partnerService = PartnerService();
  final _storage = const FlutterSecureStorage();

  // ─── Current tab ───────────────────────────────────────────────
  var currentTab = 'Meetings'.obs;

  // ─── Meetings state ────────────────────────────────────────────
  var isLoadingMeetings = true.obs;
  var isSavingMeeting = false.obs;
  var meetingList = <BoardMeeting>[].obs;
  var meetingSearchQuery = ''.obs;
  var meetingCurrentPage = 1.obs;
  var meetingLimit = 10.obs;
  var meetingTotalItems = 0.obs;

  // ─── Resolutions state ─────────────────────────────────────────
  var isLoadingResolutions = true.obs;
  var isSavingResolution = false.obs;
  var resolutionList = <BoardResolution>[].obs;
  var resolutionSearchQuery = ''.obs;
  var resolutionCurrentPage = 1.obs;
  var resolutionLimit = 10.obs;
  var resolutionTotalItems = 0.obs;

  // ─── Investors state ──────────────────────────────────────────
  var isLoadingInvestors = true.obs;
  var investorList = <Employee>[].obs;
  var investorSearchQuery = ''.obs;
  var investorCurrentPage = 1.obs;
  var investorLimit = 10.obs;
  var investorTotalItems = 0.obs;

  // ─── Associates state ─────────────────────────────────────────
  var isLoadingAssociates = true.obs;
  var associateList = <Employee>[].obs;
  var associateSearchQuery = ''.obs;
  var associateCurrentPage = 1.obs;
  var associateLimit = 10.obs;
  var associateTotalItems = 0.obs;

  // ─── Partners state ───────────────────────────────────────────
  var isLoadingPartners = true.obs;
  var isSavingPartner = false.obs;
  var partnerList = <Partner>[].obs;
  var partnerSearchQuery = ''.obs;
  var partnerCurrentPage = 1.obs;
  var partnerLimit = 10.obs;
  var partnerTotalItems = 0.obs;

  // ─── Field choices ─────────────────────────────────────────────
  var meetingChoices = Rxn<MeetingFieldChoices>();
  var resolutionChoices = Rxn<ResolutionFieldChoices>();

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
    fetchResolutions();
    fetchInvestors();
    fetchAssociates();
    fetchPartners();
    loadMeetingChoices();
    loadResolutionChoices();
  }

  // ─── MEETINGS CRUD ─────────────────────────────────────────────

  Future<void> fetchMeetings({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingMeetings.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (meetingCurrentPage.value - 1) * meetingLimit.value;

      final result = await _boardService.getMeetings(
        accessToken: token,
        search: meetingSearchQuery.value.isNotEmpty
            ? meetingSearchQuery.value
            : null,
        limit: meetingLimit.value,
        offset: offset,
      );

      meetingList.assignAll(result.items);
      meetingTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching meetings: $e");
    } finally {
      isLoadingMeetings.value = false;
    }
  }

  Future<void> createMeeting(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingMeeting.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _boardService.createMeeting(accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchMeetings(refresh: true);
        _showSnackBar(context, "Meeting scheduled successfully");
      }
    } catch (e) {
      log("Create Meeting Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to create meeting: ${e.toString()}");
      }
    } finally {
      isSavingMeeting.value = false;
    }
  }

  Future<void> updateMeeting(
      BuildContext context, int meetingId, Map<String, dynamic> data) async {
    try {
      isSavingMeeting.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _boardService.updateMeeting(
          accessToken: token, meetingId: meetingId, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchMeetings(refresh: true);
        _showSnackBar(context, "Meeting updated successfully");
      }
    } catch (e) {
      log("Update Meeting Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update meeting");
      }
    } finally {
      isSavingMeeting.value = false;
    }
  }

  Future<void> cancelMeeting(BuildContext context, int meetingId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _boardService.cancelMeeting(
          accessToken: token, meetingId: meetingId);

      if (context.mounted) {
        fetchMeetings(refresh: true);
        _showSnackBar(context, "Meeting cancelled successfully");
      }
    } catch (e) {
      log("Cancel Meeting Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to cancel meeting");
      }
    }
  }

  // ─── RESOLUTIONS CRUD ──────────────────────────────────────────

  Future<void> fetchResolutions({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingResolutions.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset =
          (resolutionCurrentPage.value - 1) * resolutionLimit.value;

      final result = await _boardService.getResolutions(
        accessToken: token,
        search: resolutionSearchQuery.value.isNotEmpty
            ? resolutionSearchQuery.value
            : null,
        limit: resolutionLimit.value,
        offset: offset,
      );

      resolutionList.assignAll(result.items);
      resolutionTotalItems.value = result.total;
    } catch (e) {
      log("Error fetching resolutions: $e");
    } finally {
      isLoadingResolutions.value = false;
    }
  }

  Future<void> createResolution(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingResolution.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _boardService.createResolution(accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchResolutions(refresh: true);
        _showSnackBar(context, "Resolution submitted successfully");
      }
    } catch (e) {
      log("Create Resolution Error: $e");
      if (context.mounted) {
        _showErrorDialog(
            context, "Failed to create resolution: ${e.toString()}");
      }
    } finally {
      isSavingResolution.value = false;
    }
  }

  Future<void> updateResolution(
      BuildContext context, int resolutionId, Map<String, dynamic> data) async {
    try {
      isSavingResolution.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _boardService.updateResolution(
          accessToken: token, resolutionId: resolutionId, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchResolutions(refresh: true);
        _showSnackBar(context, "Resolution updated successfully");
      }
    } catch (e) {
      log("Update Resolution Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to update resolution");
      }
    } finally {
      isSavingResolution.value = false;
    }
  }

  Future<void> archiveResolution(
      BuildContext context, int resolutionId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _boardService.archiveResolution(
          accessToken: token, resolutionId: resolutionId);

      if (context.mounted) {
        fetchResolutions(refresh: true);
        _showSnackBar(context, "Resolution archived successfully");
      }
    } catch (e) {
      log("Archive Resolution Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to archive resolution");
      }
    }
  }

  Future<void> approveResolution(
      BuildContext context, int resolutionId) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _boardService.approveResolution(
          accessToken: token, resolutionId: resolutionId);

      if (context.mounted) {
        fetchResolutions(refresh: true);
        _showSnackBar(context, "Resolution approved successfully");
      }
    } catch (e) {
      log("Approve Resolution Error: $e");
      if (context.mounted) {
        _showErrorDialog(context, "Failed to approve resolution");
      }
    }
  }

  // ─── FIELD CHOICES ─────────────────────────────────────────────

  Future<void> loadMeetingChoices() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      meetingChoices.value =
          await _boardService.getMeetingChoices(accessToken: token);
    } catch (e) {
      log("Error loading meeting choices: $e");
      // Fallback defaults
      meetingChoices.value = MeetingFieldChoices(
        statuses: [
          BoardFieldOption(value: 'scheduled', label: 'Scheduled'),
          BoardFieldOption(value: 'completed', label: 'Completed'),
          BoardFieldOption(value: 'cancelled', label: 'Cancelled'),
          BoardFieldOption(value: 'postponed', label: 'Postponed'),
        ],
        locationTypes: [
          BoardFieldOption(value: 'physical', label: 'Physical'),
          BoardFieldOption(value: 'virtual', label: 'Virtual'),
          BoardFieldOption(value: 'hybrid', label: 'Hybrid'),
        ],
      );
    }
  }

  Future<void> loadResolutionChoices() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      resolutionChoices.value =
          await _boardService.getResolutionChoices(accessToken: token);
    } catch (e) {
      log("Error loading resolution choices: $e");
      // Fallback defaults
      resolutionChoices.value = ResolutionFieldChoices(
        resolutionTypes: [
          BoardFieldOption(value: 'financial', label: 'Financial'),
          BoardFieldOption(value: 'strategic', label: 'Strategic'),
          BoardFieldOption(value: 'governance', label: 'Governance'),
          BoardFieldOption(value: 'administrative', label: 'Administrative'),
        ],
        statuses: [
          BoardFieldOption(value: 'pending', label: 'Pending'),
          BoardFieldOption(value: 'approved', label: 'Approved'),
          BoardFieldOption(value: 'rejected', label: 'Rejected'),
          BoardFieldOption(value: 'archived', label: 'Archived'),
        ],
      );
    }
  }

  // ─── INVESTORS / ASSOCIATES / PARTNERS (Employees API) ────────

  /// Fetches investors from employees API.
  /// TODO: Replace 'investor' with the correct employment_type filter value
  /// once the actual API filter key/value is confirmed.
  Future<void> fetchInvestors({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingInvestors.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (investorCurrentPage.value - 1) * investorLimit.value;

      final result = await _employeeService.getEmployees(
        token,
        // TODO: Replace 'investor' with the correct filter value for investors
        employmentType: 'investor',
        search: investorSearchQuery.value.isNotEmpty
            ? investorSearchQuery.value
            : null,
        limit: investorLimit.value,
        offset: offset,
      );

      investorList.assignAll(result.list);
      investorTotalItems.value = result.count;
    } catch (e) {
      log("Error fetching investors: $e");
    } finally {
      isLoadingInvestors.value = false;
    }
  }

  /// Fetches associates from employees API.
  /// TODO: Replace 'associate' with the correct employment_type filter value
  /// once the actual API filter key/value is confirmed.
  Future<void> fetchAssociates({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingAssociates.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (associateCurrentPage.value - 1) * associateLimit.value;

      final result = await _employeeService.getEmployees(
        token,
        // TODO: Replace 'associate' with the correct filter value for associates
        employmentType: 'associate',
        search: associateSearchQuery.value.isNotEmpty
            ? associateSearchQuery.value
            : null,
        limit: associateLimit.value,
        offset: offset,
      );

      associateList.assignAll(result.list);
      associateTotalItems.value = result.count;
    } catch (e) {
      log("Error fetching associates: $e");
    } finally {
      isLoadingAssociates.value = false;
    }
  }

  Future<void> fetchPartners({bool refresh = false}) async {
    try {
      if (!refresh) isLoadingPartners.value = true;

      final token = await _getToken();
      if (token == null) return;

      final offset = (partnerCurrentPage.value - 1) * partnerLimit.value;

      final result = await _partnerService.getPartners(
        accessToken: token,
        search: partnerSearchQuery.value.isNotEmpty
            ? partnerSearchQuery.value
            : null,
        limit: partnerLimit.value,
        offset: offset,
      );

      partnerList.assignAll(result.items);
      partnerTotalItems.value = result.count;
    } catch (e) {
      log("Error fetching partners: $e");
    } finally {
      isLoadingPartners.value = false;
    }
  }

  Future<void> createPartner(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      isSavingPartner.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _partnerService.createPartner(accessToken: token, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchPartners(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Partner created"), backgroundColor: Colors.green));
      }
    } catch (e) {
      log("Create partner error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      isSavingPartner.value = false;
    }
  }

  Future<void> updatePartner(
      BuildContext context, int id, Map<String, dynamic> data) async {
    try {
      isSavingPartner.value = true;
      final token = await _getToken();
      if (token == null) return;

      await _partnerService.updatePartner(
          accessToken: token, partnerId: id, data: data);

      if (context.mounted) {
        Navigator.pop(context);
        fetchPartners(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Partner updated"), backgroundColor: Colors.green));
      }
    } catch (e) {
      log("Update partner error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      isSavingPartner.value = false;
    }
  }

  Future<void> deletePartner(BuildContext context, int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _partnerService.deletePartner(accessToken: token, partnerId: id);

      partnerList.removeWhere((p) => p.id == id);
      partnerTotalItems.value = partnerTotalItems.value - 1;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Partner deleted"), backgroundColor: Colors.green));
      }
    } catch (e) {
      log("Delete partner error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // ─── FILTER ACTIONS ────────────────────────────────────────────

  void onMeetingSearchChanged(String val) {
    meetingSearchQuery.value = val;
    meetingCurrentPage.value = 1;
    fetchMeetings();
  }

  void onResolutionSearchChanged(String val) {
    resolutionSearchQuery.value = val;
    resolutionCurrentPage.value = 1;
    fetchResolutions();
  }

  void onInvestorSearchChanged(String val) {
    investorSearchQuery.value = val;
    investorCurrentPage.value = 1;
    fetchInvestors();
  }

  void onAssociateSearchChanged(String val) {
    associateSearchQuery.value = val;
    associateCurrentPage.value = 1;
    fetchAssociates();
  }

  void onPartnerSearchChanged(String val) {
    partnerSearchQuery.value = val;
    partnerCurrentPage.value = 1;
    fetchPartners();
  }

  // ─── PAGINATION ────────────────────────────────────────────────

  void meetingGoToPage(int page) {
    meetingCurrentPage.value = page;
    fetchMeetings();
  }

  void meetingSetLimit(int newLimit) {
    meetingLimit.value = newLimit;
    meetingCurrentPage.value = 1;
    fetchMeetings();
  }

  void resolutionGoToPage(int page) {
    resolutionCurrentPage.value = page;
    fetchResolutions();
  }

  void resolutionSetLimit(int newLimit) {
    resolutionLimit.value = newLimit;
    resolutionCurrentPage.value = 1;
    fetchResolutions();
  }

  void investorGoToPage(int page) {
    investorCurrentPage.value = page;
    fetchInvestors();
  }

  void investorSetLimit(int newLimit) {
    investorLimit.value = newLimit;
    investorCurrentPage.value = 1;
    fetchInvestors();
  }

  void associateGoToPage(int page) {
    associateCurrentPage.value = page;
    fetchAssociates();
  }

  void associateSetLimit(int newLimit) {
    associateLimit.value = newLimit;
    associateCurrentPage.value = 1;
    fetchAssociates();
  }

  void partnerGoToPage(int page) {
    partnerCurrentPage.value = page;
    fetchPartners();
  }

  void partnerSetLimit(int newLimit) {
    partnerLimit.value = newLimit;
    partnerCurrentPage.value = 1;
    fetchPartners();
  }

  // ─── HELPERS ───────────────────────────────────────────────────

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
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
