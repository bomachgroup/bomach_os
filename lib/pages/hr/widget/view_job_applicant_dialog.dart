import 'dart:developer';

import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';
import '../models/interview_model.dart';
import '../models/offer_letter_model.dart';
import '../../../src/services/hr/interview_service.dart';
import '../../../src/services/hr/offer_letter_service.dart';
import 'add_candidate_dialog.dart';

class ViewJobApplicantDialog extends StatefulWidget {
  final Applicant applicant;
  const ViewJobApplicantDialog({super.key, required this.applicant});

  @override
  State<ViewJobApplicantDialog> createState() => _ViewJobApplicantDialogState();
}

class _ViewJobApplicantDialogState extends State<ViewJobApplicantDialog> {
  final ApplicantController _controller = Get.find<ApplicantController>();
  final InterviewService _interviewService = InterviewService();
  final OfferLetterService _offerLetterService = OfferLetterService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int _selectedTab = 0;

  // Interview state
  List<Interview> _interviews = [];
  bool _interviewsLoading = false;

  // Offer letter state
  List<OfferLetter> _offerLetters = [];
  bool _offersLoading = false;

  int get _applicantIdInt =>
      int.tryParse(widget.applicant.id) ?? 0;

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    return token.startsWith('Bearer ')
        ? token.replaceFirst('Bearer ', '')
        : token.replaceAll('"', '').trim();
  }

  Future<void> _loadInterviews() async {
    setState(() => _interviewsLoading = true);
    try {
      final token = await _getToken();
      if (token == null) return;
      final result = await _interviewService.getInterviews(token, _applicantIdInt);
      setState(() => _interviews = result.items);
    } catch (e) {
      log('Load interviews error: $e');
    } finally {
      setState(() => _interviewsLoading = false);
    }
  }

  Future<void> _loadOfferLetters() async {
    setState(() => _offersLoading = true);
    try {
      final token = await _getToken();
      if (token == null) return;
      final result = await _offerLetterService.getOfferLetters(token, _applicantIdInt);
      setState(() => _offerLetters = result.items);
    } catch (e) {
      log('Load offer letters error: $e');
    } finally {
      setState(() => _offersLoading = false);
    }
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 1 && _interviews.isEmpty && !_interviewsLoading) {
      _loadInterviews();
    } else if (index == 2 && _offerLetters.isEmpty && !_offersLoading) {
      _loadOfferLetters();
    }
  }

  void _showScheduleInterviewDialog() {
    showDialog(
      context: context,
      builder: (_) => _ScheduleInterviewDialog(
        applicantId: _applicantIdInt,
        interviewService: _interviewService,
        onSaved: _loadInterviews,
      ),
    );
  }

  void _showCreateOfferLetterDialog() {
    showDialog(
      context: context,
      builder: (_) => _CreateOfferLetterDialog(
        applicantId: _applicantIdInt,
        offerLetterService: _offerLetterService,
        onSaved: _loadOfferLetters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.applicant.stage.toLowerCase();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(widget.applicant.firstName[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              '${widget.applicant.firstName} ${widget.applicant.lastName}',
                              size: 18,
                              weight: 700),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(4)),
                                child: MyText(
                                    widget.applicant.stage.toUpperCase(),
                                    size: 10,
                                    color: Colors.pink,
                                    weight: 600),
                              ),
                              const SizedBox(width: 8),
                              MyText(
                                  "Applied: ${widget.applicant.createdAt?.toString().split(' ')[0] ?? '-'}",
                                  size: 12,
                                  color: Colors.grey),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                children: [
                  _buildTab("Overview", 0),
                  _buildTab("Interview", 1),
                  _buildTab("Offer", 2),
                ],
              ),
            ),

            // Body
            Expanded(child: _buildTabBody(stage)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(String stage) {
    switch (_selectedTab) {
      case 1:
        return _buildInterviewTab();
      case 2:
        return _buildOfferTab();
      default:
        return _buildOverviewTab(stage);
    }
  }

  Widget _buildOverviewTab(String stage) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText("Candidate Information", size: 14, weight: 700),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem("Email", widget.applicant.email)),
                    Expanded(
                        child: _buildInfoItem("Phone", widget.applicant.phone)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoItem(
                            "LinkedIn",
                            widget.applicant.linkedinUrl?.isNotEmpty == true
                                ? widget.applicant.linkedinUrl!
                                : '-')),
                    Expanded(
                        child: _buildInfoItem(
                            "Portfolio",
                            widget.applicant.portfolioUrl?.isNotEmpty == true
                                ? widget.applicant.portfolioUrl!
                                : '-')),
                  ],
                ),
                const SizedBox(height: 32),
                const MyText("Notes", size: 14, weight: 700),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                      widget.applicant.notes ?? "No notes available.",
                      size: 13,
                      color: Colors.grey.shade700),
                )
              ],
            ),
          ),

          const SizedBox(width: 24),

          // RIGHT COLUMN
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText("Actions", size: 14, weight: 700),
                const SizedBox(height: 12),
                if (stage == 'applied') ...[
                  _buildActionButton(
                      "Shortlist Candidate",
                      const Color(0xFF0055FF),
                      () => _controller.moveApplicantToStage(
                          context, widget.applicant.id, 'shortlisted')),
                  const SizedBox(height: 8),
                  _buildActionButton(
                      "Reject",
                      AppColors.red,
                      () => _controller.rejectApplicant(
                          context, widget.applicant.id)),
                ] else if (stage == 'shortlisted' || stage == 'screening') ...[
                  _buildActionButton(
                      "Schedule Interview",
                      Colors.orange,
                      () => _controller.moveApplicantToStage(
                          context, widget.applicant.id, 'interview')),
                  const SizedBox(height: 8),
                  _buildActionButton(
                      "Reject",
                      AppColors.red,
                      () => _controller.rejectApplicant(
                          context, widget.applicant.id)),
                ] else if (stage == 'interview' ||
                    stage == 'interviewed') ...[
                  _buildActionButton(
                      "Hire Candidate",
                      Colors.green,
                      () => _controller.moveApplicantToStage(
                          context, widget.applicant.id, 'hired')),
                  const SizedBox(height: 8),
                  _buildActionButton(
                      "Reject",
                      AppColors.red,
                      () => _controller.rejectApplicant(
                          context, widget.applicant.id)),
                ] else ...[
                  _buildActionButton("Edit Candidate", Colors.grey, () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (_) => AddCandidateDialog(
                            applicant: widget.applicant));
                  }),
                ],
                const SizedBox(height: 32),
                const MyText("Documents", size: 14, weight: 700),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                          child: MyText("Resume.pdf", size: 13, weight: 500)),
                      Icon(Icons.download, size: 18, color: Colors.grey),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MyText("Interviews", size: 14, weight: 700),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _showScheduleInterviewDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: const Text("Schedule Interview",
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _interviewsLoading
                ? const Center(child: CircularProgressIndicator())
                : _interviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_note,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const MyText("No interviews scheduled",
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _interviews.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final interview = _interviews[i];
                          return _buildInterviewTile(interview);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewTile(Interview interview) {
    Color statusColor;
    switch (interview.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(Icons.event, color: statusColor, size: 20),
      ),
      title: MyText(
          interview.scheduledAt.isNotEmpty
              ? _formatDateTime(interview.scheduledAt)
              : 'No date set',
          size: 14,
          weight: 600),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (interview.meetingLink?.isNotEmpty == true)
            MyText(interview.meetingLink!, size: 12, color: Colors.blue),
          if (interview.feedback?.isNotEmpty == true)
            MyText('Feedback: ${interview.feedback!}',
                size: 12, color: Colors.grey),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          interview.status.toUpperCase(),
          style: TextStyle(
              fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildOfferTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MyText("Offer Letters", size: 14, weight: 700),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _showCreateOfferLetterDialog,
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: const Text("Create Offer Letter",
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _offersLoading
                ? const Center(child: CircularProgressIndicator())
                : _offerLetters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const MyText("No offer letters yet",
                                size: 14, color: Colors.grey),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _offerLetters.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final offer = _offerLetters[i];
                          return _buildOfferTile(offer);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTile(OfferLetter offer) {
    Color statusColor;
    switch (offer.status) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'sent':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(Icons.description, color: statusColor, size: 20),
      ),
      title: MyText(
          offer.template.isNotEmpty ? offer.template : 'Offer Letter',
          size: 14,
          weight: 600),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText('Salary: ₦${offer.annualSalary}', size: 12, color: Colors.grey),
          if (offer.startDate.isNotEmpty)
            MyText('Start: ${offer.startDate}', size: 12, color: Colors.grey),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          offer.status.toUpperCase(),
          style: TextStyle(
              fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _selectTab(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
        child: Column(
          children: [
            MyText(title,
                size: 13,
                weight: isActive ? 600 : 400,
                color: isActive ? const Color(0xFF0055FF) : Colors.grey),
            if (isActive)
              Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  color: const Color(0xFF0055FF))
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, color: Colors.grey),
        const SizedBox(height: 4),
        MyText(value, size: 13, weight: 600),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

// ─── Schedule Interview Dialog ────────────────────────────────────────────────

class _ScheduleInterviewDialog extends StatefulWidget {
  final int applicantId;
  final InterviewService interviewService;
  final VoidCallback onSaved;

  const _ScheduleInterviewDialog({
    required this.applicantId,
    required this.interviewService,
    required this.onSaved,
  });

  @override
  State<_ScheduleInterviewDialog> createState() =>
      _ScheduleInterviewDialogState();
}

class _ScheduleInterviewDialogState extends State<_ScheduleInterviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _interviewerIdCtrl = TextEditingController();
  final _meetingLinkCtrl = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _saving = false;

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    return token.startsWith('Bearer ')
        ? token.replaceFirst('Bearer ', '')
        : token.replaceAll('"', '').trim();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _scheduledDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) setState(() => _scheduledTime = time);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_scheduledDate == null || _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')));
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await _getToken();
      if (token == null || !mounted) return;

      final scheduledAt = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );

      final interview = Interview(
        applicantId: widget.applicantId,
        interviewerId:
            int.tryParse(_interviewerIdCtrl.text.trim()) ?? 0,
        scheduledAt: scheduledAt.toUtc().toIso8601String(),
        meetingLink: _meetingLinkCtrl.text.trim().isEmpty
            ? null
            : _meetingLinkCtrl.text.trim(),
      );

      await widget.interviewService.createInterview(
          token, widget.applicantId, interview);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      log('Schedule interview error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to schedule interview: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _interviewerIdCtrl.dispose();
    _meetingLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Interview'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _interviewerIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Interviewer ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_scheduledDate == null
                          ? 'Pick Date'
                          : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(_scheduledTime == null
                          ? 'Pick Time'
                          : _scheduledTime!.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meetingLinkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meeting Link (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055FF)),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Schedule',
                  style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─── Create Offer Letter Dialog ───────────────────────────────────────────────

class _CreateOfferLetterDialog extends StatefulWidget {
  final int applicantId;
  final OfferLetterService offerLetterService;
  final VoidCallback onSaved;

  const _CreateOfferLetterDialog({
    required this.applicantId,
    required this.offerLetterService,
    required this.onSaved,
  });

  @override
  State<_CreateOfferLetterDialog> createState() =>
      _CreateOfferLetterDialogState();
}

class _CreateOfferLetterDialogState extends State<_CreateOfferLetterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _templateCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DateTime? _startDate;
  bool _saving = false;

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    return token.startsWith('Bearer ')
        ? token.replaceFirst('Bearer ', '')
        : token.replaceAll('"', '').trim();
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')));
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await _getToken();
      if (token == null || !mounted) return;

      final startDateStr =
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';

      final offer = OfferLetter(
        applicantId: widget.applicantId,
        template: _templateCtrl.text.trim(),
        annualSalary: _salaryCtrl.text.trim(),
        startDate: startDateStr,
        letterContent: _contentCtrl.text.trim(),
      );

      await widget.offerLetterService.createOfferLetter(
          token, widget.applicantId, offer);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      log('Create offer letter error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to create offer letter: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _templateCtrl.dispose();
    _salaryCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Offer Letter'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _templateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Annual Salary (₦)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_startDate == null
                    ? 'Pick Start Date'
                    : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                onPressed: _pickStartDate,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Letter Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Create',
                  style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
