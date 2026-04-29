import 'dart:developer';

import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../src/services/hr/interview_service.dart';
import '../../../src/services/hr/offer_letter_service.dart';
import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';
import '../models/interview_model.dart';
import '../models/offer_letter_model.dart';
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

  int get _applicantIdInt => int.tryParse(widget.applicant.id) ?? 0;

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
      final result =
          await _interviewService.getInterviews(token, _applicantIdInt);
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
      final result =
          await _offerLetterService.getOfferLetters(token, _applicantIdInt);
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

  // ── Status helpers ─────────────────────────────────────────────────

  StatusTone _applicantStatusTone(String stage) {
    switch (stage.toLowerCase()) {
      case 'applied':
        return StatusTone.neutral;
      case 'screening':
      case 'shortlisted':
        return StatusTone.info;
      case 'interview':
      case 'interviewed':
        return StatusTone.warning;
      case 'offer':
        return StatusTone.primary;
      case 'hired':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'withdrawn':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _interviewStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusTone.success;
      case 'cancelled':
      case 'canceled':
        return StatusTone.danger;
      case 'scheduled':
        return StatusTone.warning;
      default:
        return StatusTone.warning;
    }
  }

  StatusTone _offerStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'sent':
        return StatusTone.info;
      default:
        return StatusTone.warning;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.applicant.stage.toLowerCase();
    final fullName =
        '${widget.applicant.firstName} ${widget.applicant.lastName}'.trim();

    return DialogScaffold(
      title: 'Applicant Profile',
      subtitle: fullName.isEmpty ? 'Applicant details' : fullName,
      size: DialogSize.lg,
      bodyPadding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSummaryBanner(stage, fullName),
          ),
          _buildTabBar(),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildTabBody(stage),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(String stage, String fullName) {
    final initial = widget.applicant.firstName.isNotEmpty
        ? widget.applicant.firstName[0].toUpperCase()
        : '?';
    final appliedDate =
        widget.applicant.createdAt?.toString().split(' ')[0] ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Unknown applicant' : fullName,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _capitalize(widget.applicant.stage),
                      tone: _applicantStatusTone(stage),
                    ),
                    _buildMetaChip(
                      icon: Iconsax.calendar_1,
                      label: 'Applied $appliedDate',
                    ),
                    if (widget.applicant.email.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.sms,
                        label: widget.applicant.email,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Interview', 1),
          _buildTab('Offer', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTab == index;
    return InkWell(
      onTap: () => _selectTab(index),
      borderRadius: AppRadii.brSm,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMd.copyWith(
                color:
                    isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 30,
              color: isActive ? AppColors.primary : Colors.transparent,
            ),
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

  // ── Overview tab ──────────────────────────────────────────────────

  Widget _buildOverviewTab(String stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          title: 'Candidate information',
          children: [
            _detailRow('Email', widget.applicant.email),
            _detailRow('Phone', widget.applicant.phone),
            _detailRow(
              'LinkedIn',
              widget.applicant.linkedinUrl?.isNotEmpty == true
                  ? widget.applicant.linkedinUrl!
                  : '-',
            ),
            _detailRow(
              'Portfolio',
              widget.applicant.portfolioUrl?.isNotEmpty == true
                  ? widget.applicant.portfolioUrl!
                  : '-',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailSection(
          title: 'Notes',
          children: [
            Text(
              widget.applicant.notes == null ||
                      widget.applicant.notes!.isEmpty
                  ? 'No notes available.'
                  : widget.applicant.notes!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailSection(
          title: 'Documents',
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.brMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppRadii.brMd,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Iconsax.document_text,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Resume.pdf',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Download',
                    icon: const Icon(Iconsax.document_download, size: 18),
                    color: AppColors.primary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionsSection(stage),
      ],
    );
  }

  Widget _buildActionsSection(String stage) {
    final List<Widget> actions = [];

    if (stage == 'applied') {
      actions.addAll([
        _actionButton(
          label: 'Shortlist Candidate',
          icon: Iconsax.tick_circle,
          color: AppColors.primary,
          onTap: () => _controller.moveApplicantToStage(
              context, widget.applicant.id, 'shortlisted'),
        ),
        _actionButton(
          label: 'Reject',
          icon: Iconsax.close_circle,
          color: AppColors.danger,
          outlined: true,
          onTap: () =>
              _controller.rejectApplicant(context, widget.applicant.id),
        ),
      ]);
    } else if (stage == 'shortlisted' || stage == 'screening') {
      actions.addAll([
        _actionButton(
          label: 'Schedule Interview',
          icon: Iconsax.calendar_1,
          color: AppColors.warning,
          onTap: () => _controller.moveApplicantToStage(
              context, widget.applicant.id, 'interview'),
        ),
        _actionButton(
          label: 'Reject',
          icon: Iconsax.close_circle,
          color: AppColors.danger,
          outlined: true,
          onTap: () =>
              _controller.rejectApplicant(context, widget.applicant.id),
        ),
      ]);
    } else if (stage == 'interview' || stage == 'interviewed') {
      actions.addAll([
        _actionButton(
          label: 'Hire Candidate',
          icon: Iconsax.tick_circle,
          color: AppColors.success,
          onTap: () => _controller.moveApplicantToStage(
              context, widget.applicant.id, 'hired'),
        ),
        _actionButton(
          label: 'Reject',
          icon: Iconsax.close_circle,
          color: AppColors.danger,
          outlined: true,
          onTap: () =>
              _controller.rejectApplicant(context, widget.applicant.id),
        ),
      ]);
    } else {
      actions.add(
        _actionButton(
          label: 'Edit Candidate',
          icon: Iconsax.edit,
          color: AppColors.primary,
          outlined: true,
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) =>
                  AddCandidateDialog(applicant: widget.applicant),
            );
          },
        ),
      );
    }

    return _buildDetailSection(
      title: 'Actions',
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions,
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    if (outlined) {
      return MyOutlinedButton(
        child: label,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        icon: Icon(icon, size: 18, color: color),
        textColor: color,
        borderColor: color,
        onTap: onTap,
      );
    }
    return MyElevatedButton(
      child: label,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      bgColor: color,
      icon: Icon(icon, size: 18, color: AppColors.textOnPrimary),
      onTap: onTap,
    );
  }

  // ── Interview tab ─────────────────────────────────────────────────

  Widget _buildInterviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Interviews', style: AppTextStyles.h4),
            MyElevatedButton(
              child: 'Schedule Interview',
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              icon: const Icon(Iconsax.add,
                  size: 18, color: AppColors.textOnPrimary),
              onTap: _showScheduleInterviewDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_interviewsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_interviews.isEmpty)
          _buildEmptyState(
            icon: Iconsax.calendar_1,
            title: 'No interviews scheduled',
            subtitle:
                'Schedule an interview to keep this candidate moving forward.',
          )
        else
          Column(
            children: [
              for (var i = 0; i < _interviews.length; i++) ...[
                if (i != 0) const SizedBox(height: 12),
                _buildInterviewTile(_interviews[i]),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildInterviewTile(Interview interview) {
    final tone = _interviewStatusTone(interview.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            alignment: Alignment.center,
            child: const Icon(Iconsax.calendar_1,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.scheduledAt.isNotEmpty
                      ? _formatDateTime(interview.scheduledAt)
                      : 'No date set',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (interview.meetingLink?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    interview.meetingLink!,
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.primary),
                  ),
                ],
                if (interview.feedback?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Feedback: ${interview.feedback!}',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusChip(label: _capitalize(interview.status), tone: tone),
        ],
      ),
    );
  }

  // ── Offer tab ─────────────────────────────────────────────────────

  Widget _buildOfferTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Offer Letters', style: AppTextStyles.h4),
            MyElevatedButton(
              child: 'Create Offer Letter',
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              bgColor: AppColors.success,
              icon: const Icon(Iconsax.add,
                  size: 18, color: AppColors.textOnPrimary),
              onTap: _showCreateOfferLetterDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_offersLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_offerLetters.isEmpty)
          _buildEmptyState(
            icon: Iconsax.document_text,
            title: 'No offer letters yet',
            subtitle:
                'Create an offer letter once the candidate is ready to move forward.',
          )
        else
          Column(
            children: [
              for (var i = 0; i < _offerLetters.length; i++) ...[
                if (i != 0) const SizedBox(height: 12),
                _buildOfferTile(_offerLetters[i]),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildOfferTile(OfferLetter offer) {
    final tone = _offerStatusTone(offer.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            alignment: Alignment.center,
            child: const Icon(Iconsax.document_text,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.template.isNotEmpty ? offer.template : 'Offer Letter',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Salary: ₦${offer.annualSalary}',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (offer.startDate.isNotEmpty)
                  Text(
                    'Start: ${offer.startDate}',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusChip(label: _capitalize(offer.status), tone: tone),
        ],
      ),
    );
  }

  // ── Shared building blocks ────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
      AppToast.info(context, 'Please select date and time');
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
        interviewerId: int.tryParse(_interviewerIdCtrl.text.trim()) ?? 0,
        scheduledAt: scheduledAt.toUtc().toIso8601String(),
        meetingLink: _meetingLinkCtrl.text.trim().isEmpty
            ? null
            : _meetingLinkCtrl.text.trim(),
      );

      await widget.interviewService
          .createInterview(token, widget.applicantId, interview);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      log('Schedule interview error: $e');
      if (mounted) {
        AppToast.error(context, 'Failed to schedule interview: $e');
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
    return DialogScaffold(
      title: 'Schedule Interview',
      subtitle: 'Set a date, time, and link for the interview.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextFormField(
              controller: _interviewerIdCtrl,
              title: 'Interviewer ID',
              hintText: 'Enter interviewer ID',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPickerTile(
                    icon: Iconsax.calendar_1,
                    label: _scheduledDate == null
                        ? 'Pick Date'
                        : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerTile(
                    icon: Iconsax.clock,
                    label: _scheduledTime == null
                        ? 'Pick Time'
                        : _scheduledTime!.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _meetingLinkCtrl,
              title: 'Meeting Link (optional)',
              hintText: 'https://meet.example.com/…',
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          child: _saving ? 'Scheduling...' : 'Schedule',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isLoading: _saving,
          icon: const Icon(Iconsax.calendar_tick,
              size: 18, color: AppColors.textOnPrimary),
          onTap: _saving ? () {} : _save,
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
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
      AppToast.info(context, 'Please select a start date');
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

      await widget.offerLetterService
          .createOfferLetter(token, widget.applicantId, offer);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      log('Create offer letter error: $e');
      if (mounted) {
        AppToast.error(context, 'Failed to create offer letter: $e');
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
    return DialogScaffold(
      title: 'Create Offer Letter',
      subtitle: 'Compose an offer letter for this candidate.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextFormField(
              controller: _templateCtrl,
              title: 'Template Name',
              hintText: 'e.g. Standard Engineering Offer',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _salaryCtrl,
              title: 'Annual Salary (₦)',
              hintText: 'e.g. 5000000',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildPickerTile(
              icon: Iconsax.calendar_1,
              label: _startDate == null
                  ? 'Pick Start Date'
                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _contentCtrl,
              title: 'Letter Content',
              hintText: 'Type the body of the offer letter…',
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          child: _saving ? 'Creating...' : 'Create',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isLoading: _saving,
          bgColor: AppColors.success,
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          onTap: _saving ? () {} : _save,
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
