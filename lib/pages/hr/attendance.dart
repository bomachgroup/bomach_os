import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/biometrics_controller.dart';
import 'models/attendance_models.dart';
import 'models/workspace_model.dart';
import 'widget/submit_workspace_dialog.dart';
import 'widget/workspace_details_dialog.dart';

/// Attendance page.
///
/// Two data boundaries drive the layout:
///   1) **Clock-in eligibility**: derived from [BiometricsController.canClockIn]
///      which requires at least one APPROVED workspace. The clock card is
///      disabled otherwise, with a status-specific sub-label explaining why.
///   2) **Workspace list**: shows every submission (any status) so the user
///      can track approvals without guessing. Radius is never shown — it's
///      admin-controlled at approval time and irrelevant to the employee.
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  final BiometricsController controller = Get.put(BiometricsController());
  final _storage = const FlutterSecureStorage();

  Stream<String> get _timeStream => Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateFormat('hh:mm:ss a').format(controller.trustedTime),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  Future<void> _refreshData() async {
    final token = await _getToken(context);
    if (token != null) {
      await Future.wait([
        controller.fetchAttendanceHistory(token),
        controller.fetchWorkspaces(token),
        controller.fetchBiometricStatus(token),
      ]);
    }
  }

  Future<void> _openFaceSetup() async {
    final token = await _getToken(context);
    if (token == null || !mounted) return;
    final ok = await controller.performFaceSetup(token, context: context);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(controller.successMessage.value),
          backgroundColor: Colors.green));
    } else if (controller.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(controller.errorMessage.value),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _handleClockAction(bool isClockIn) async {
    final token = await _getToken(context);
    if (token == null || !mounted) return;
    await controller.performClockAction(
      token,
      isClockIn: isClockIn,
      context: context,
    );
    if (!mounted) return;
    if (controller.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(controller.errorMessage.value),
          backgroundColor: Colors.red));
    } else if (controller.successMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(controller.successMessage.value),
          backgroundColor: Colors.green));
    }
  }

  Future<void> _openSubmitWorkspace() async {
    final token = await _getToken(context);
    if (token == null || !mounted) return;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (_) => SubmitWorkspaceDialog(token: token),
    );
    // Controller already prepended locally; no need to refetch unless it
    // reports a failure and we want a clean state.
    if (submitted == true && mounted) {
      // Refresh in background to pull server-assigned fields (timestamps, etc).
      await controller.fetchWorkspaces(token);
    }
  }

  Future<void> _openWorkspaceDetails(WorkspaceConfig ws) async {
    final token = await _getToken(context);
    if (token == null || !mounted) return;
    await showDialog(
      context: context,
      builder: (_) => WorkspaceDetailsDialog(token: token, workspace: ws),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          _buildHeroBanner(),
          kSizedBox,

          // Stats row
          Obx(() => _buildStatsRow(_computeStats(controller.rawRecords))),
          kSizedBox,

          // Clock In/Out card
          _buildLiveClockCard(),
          kSizedBox,

          // My Workspaces card
          _buildWorkspacesCard(),
          kSizedBox,

          // Attendance history table
          _buildHistoryTable(),
        ],
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.darkBlue2],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.access_time_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Clock in with face verification and track your attendance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Obx(() => _buildFaceHeroChip()),
              Obx(() => _buildWorkspaceHeroChip()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaceHeroChip() {
    if (controller.isFetchingStatus.value) {
      return _heroChipSkeleton();
    }
    final registered = controller.hasFace.value;
    return PopupMenuButton<String>(
      tooltip: 'Face registration',
      onSelected: (v) async {
        if (v == 'register' || v == 're-register') {
          await _openFaceSetup();
        } else if (v == 'remove') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Remove face registration?'),
              content: const Text(
                  'You will need to register again before clocking in with face verification.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Remove',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm != true || !mounted) return;
          final token = await _getToken(context);
          if (token == null || !mounted) return;
          final ok =
              await controller.removeBiometric(token, biometricType: 'face');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? controller.successMessage.value
                : controller.errorMessage.value),
            backgroundColor: ok ? Colors.green : Colors.red,
          ));
        }
      },
      itemBuilder: (_) => [
        if (!registered)
          const PopupMenuItem(value: 'register', child: Text('Register Face')),
        if (registered) ...[
          const PopupMenuItem(
              value: 're-register', child: Text('Re-register Face')),
          const PopupMenuItem(
              value: 'remove',
              child: Text('Remove Face', style: TextStyle(color: Colors.red))),
        ],
      ],
      child: _heroChip(
        icon: registered ? Icons.face_rounded : Icons.face_retouching_off,
        label: registered ? 'Face registered' : 'Face not registered',
      ),
    );
  }

  Widget _buildWorkspaceHeroChip() {
    if (controller.isFetchingWorkspace.value) {
      return _heroChipSkeleton();
    }

    final total = controller.workspaces.length;
    // Status-based counts (what shows on the row chips) — NOT clock-in
    // eligibility, because an APPROVED workspace may be expired/inactive
    // and should still read as "approved" to the user.
    final approved = controller.workspaces
        .where((w) => w.status == WorkspaceStatus.approved)
        .length;
    final pending = controller.workspaces
        .where((w) => w.status == WorkspaceStatus.pending)
        .length;
    final rejected = controller.workspaces
        .where((w) => w.status == WorkspaceStatus.rejected)
        .length;

    String label;
    IconData icon;
    if (total == 0) {
      label = 'No workspace submitted';
      icon = Icons.location_off_rounded;
    } else if (approved > 0) {
      label = pending > 0
          ? '$approved approved · $pending pending'
          : '$approved approved';
      icon = Icons.location_on_rounded;
    } else if (pending > 0) {
      label = '$pending awaiting approval';
      icon = Icons.hourglass_top_rounded;
    } else if (rejected > 0) {
      label = rejected == 1 ? 'Workspace rejected' : '$rejected rejected';
      icon = Icons.location_off_rounded;
    } else {
      label = '$total submitted';
      icon = Icons.location_on_rounded;
    }

    return _heroChip(icon: icon, label: label);
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChipSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────

  Widget _buildStatsRow(_AttendanceStats stats) {
    final cards = [
      _StatCardData(
        title: 'This Week',
        value: '${stats.thisWeekDays}',
        subtitle: 'days clocked in',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF10B981),
      ),
      _StatCardData(
        title: 'This Month',
        value: '${stats.thisMonthDays}',
        subtitle: 'days clocked in',
        icon: Icons.event_note_rounded,
        color: AppColors.blue,
      ),
      _StatCardData(
        title: 'Avg Hours / Day',
        value: stats.avgHoursLabel,
        subtitle: 'based on this month',
        icon: Icons.timelapse_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StatCardData(
        title: 'Last Clock-In',
        value: stats.lastClockInRelative,
        subtitle: stats.lastClockInExact,
        icon: Icons.login_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 720
                ? 2
                : 1;
        const spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: _statCard(c)))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(_StatCardData c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c.icon, color: c.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            c.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  _AttendanceStats _computeStats(List<BiometricAttendanceRecord> records) {
    final now = controller.trustedTime;
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    // Group records by day (yyyy-MM-dd) so we count unique days, not events.
    final Map<String, List<BiometricAttendanceRecord>> byDay = {};
    for (final r in records) {
      final key = DateFormat('yyyy-MM-dd').format(r.timestamp);
      byDay.putIfAbsent(key, () => []).add(r);
    }

    int thisWeek = 0;
    int thisMonth = 0;
    Duration monthTotal = Duration.zero;
    int monthDaysWithPair = 0;
    BiometricAttendanceRecord? lastClockIn;

    byDay.forEach((dateKey, events) {
      events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final dayDate = DateTime.parse(dateKey);
      final hasClockIn = events.any((e) => e.attendanceType == 'CLOCK_IN');
      if (!hasClockIn) return;

      if (!dayDate.isBefore(weekStart)) thisWeek++;
      if (!dayDate.isBefore(monthStart)) {
        thisMonth++;
        final ci = events.firstWhere((e) => e.attendanceType == 'CLOCK_IN');
        final co = events.lastWhere((e) => e.attendanceType == 'CLOCK_OUT',
            orElse: () => ci);
        if (co != ci) {
          monthTotal += co.timestamp.difference(ci.timestamp);
          monthDaysWithPair++;
        }
      }
    });

    for (final r in records) {
      if (r.attendanceType != 'CLOCK_IN') continue;
      if (lastClockIn == null || r.timestamp.isAfter(lastClockIn.timestamp)) {
        lastClockIn = r;
      }
    }

    String avgLabel = '0h';
    if (monthDaysWithPair > 0) {
      final avgMinutes = monthTotal.inMinutes ~/ monthDaysWithPair;
      final h = avgMinutes ~/ 60;
      final m = avgMinutes % 60;
      avgLabel = '${h}h ${m}m';
    }

    return _AttendanceStats(
      thisWeekDays: thisWeek,
      thisMonthDays: thisMonth,
      avgHoursLabel: avgLabel,
      lastClockInRelative:
          lastClockIn == null ? '—' : _relativeTime(lastClockIn.timestamp, now),
      lastClockInExact: lastClockIn == null
          ? 'No records yet'
          : DateFormat('EEE, MMM d · hh:mm a').format(lastClockIn.timestamp),
    );
  }

  String _relativeTime(DateTime t, DateTime now) {
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(t);
  }

  // ── Live clock + Clock In/Out card ─────────────────────────────────────

  Widget _buildLiveClockCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const MyText("Current Time",
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          StreamBuilder<String>(
            stream: _timeStream,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ??
                    DateFormat('hh:mm:ss a').format(controller.trustedTime),
                style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xFF0F172A)),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(DateFormat('EEEE, MMMM d, yyyy').format(controller.trustedTime),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          Obx(() {
            final todayDateStr =
                DateFormat('yyyy-MM-dd').format(controller.trustedTime);
            final todayRecord = controller.dailyAttendanceList.firstWhere(
              (r) => r.date == todayDateStr,
              orElse: () => DailyAttendance(date: todayDateStr),
            );

            final timeIn = todayRecord.clockInTime ?? '--:--';
            final timeOut = todayRecord.clockOutTime ?? '--:--';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeStatusItem(
                    "Time In", timeIn, Icons.login, const Color(0xFF00C853)),
                Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                _buildTimeStatusItem(
                    "Time Out", timeOut, Icons.logout, const Color(0xFF2962FF)),
              ],
            );
          }),
          const SizedBox(height: 24),
          Obx(() {
            final disabledReason = _disabledReason();
            final enabled = disabledReason == null;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        buttonText: "Clock In",
                        buttonColor: const Color(0xFF00C853),
                        onTap: enabled ? () => _handleClockAction(true) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        buttonText: "Clock Out",
                        buttonColor: const Color(0xFF2962FF),
                        onTap: enabled ? () => _handleClockAction(false) : null,
                      ),
                    ),
                  ],
                ),
                if (disabledReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              const Color(0xFFFDBA74).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFFB45309), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            disabledReason,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Returns null when clock-in is allowed, else a human-readable reason.
  String? _disabledReason() {
    if (controller.isFetchingWorkspace.value ||
        controller.isFetchingStatus.value) {
      return 'Loading your status…';
    }
    if (!controller.hasFace.value) {
      return 'Register your face before clocking in.';
    }
    if (controller.workspaces.isEmpty) {
      return 'Submit a workspace for approval before clocking in.';
    }
    if (controller.approvedWorkspace != null) return null;

    // At this point there's ≥1 submission but none are clock-in eligible.
    // Explain the specific blocker so the user knows what to do.
    final approved = controller.workspaces
        .where((w) => w.status == WorkspaceStatus.approved)
        .toList();
    if (approved.isNotEmpty) {
      if (approved.any((w) => w.isExpired)) {
        return 'Your approved workspace has expired. Ask an admin to renew it '
            'or submit a new one.';
      }
      if (approved.any((w) => !w.isActive)) {
        return 'Your workspace was deactivated by an admin. Submit a new one '
            'to clock in.';
      }
      return 'Your workspace is approved but not currently usable. Contact an '
          'admin if this seems wrong.';
    }
    if (controller.hasPendingSubmission) {
      return 'Your workspace submission is awaiting admin approval.';
    }
    if (controller.workspaces
        .every((w) => w.status == WorkspaceStatus.rejected)) {
      return 'Your workspace was rejected. Delete it and submit a new one.';
    }
    return 'You need an approved workspace to clock in.';
  }

  Widget _buildTimeStatusItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildActionButton(
      {required String buttonText,
      required Color buttonColor,
      required VoidCallback? onTap}) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Obx(() {
          final expectedType =
              buttonText == "Clock In" ? 'clock_in' : 'clock_out';
          if (controller.isAuthenticating.value &&
              controller.authActionType.value == expectedType) {
            final step = controller.clockStepMessage.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
                if (step.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ]
              ],
            );
          }
          return Text(buttonText,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15));
        }),
      ),
    );
  }

  // ── Workspaces card ────────────────────────────────────────────────────

  Widget _buildWorkspacesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Workspaces',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Submit a location for approval. Admin sets the geofence radius.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openSubmitWorkspace,
                icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                label: const Text('Submit New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isFetchingWorkspace.value &&
                controller.workspaces.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.workspaces.isEmpty) {
              return _buildEmptyWorkspaces();
            }
            return Column(
              children: [
                for (int i = 0; i < controller.workspaces.length; i++) ...[
                  _buildWorkspaceRow(controller.workspaces[i]),
                  if (i < controller.workspaces.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkspaces() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_location_alt_rounded,
                color: AppColors.blue, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'No workspaces yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Submit your first workspace to start clocking in.\n'
            "Admin will review it before it's usable.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openSubmitWorkspace,
            icon: const Icon(Icons.add_location_alt_rounded, size: 16),
            label: const Text('Submit Your First Workspace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceRow(WorkspaceConfig ws) {
    final (statusColor, statusBg, statusIcon) = _statusStyles(ws.status);
    return InkWell(
      onTap: () => _openWorkspaceDetails(ws),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    ws.status.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Name + coords
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ws.workspaceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ws.latitude.toStringAsFixed(5)}, '
                    '${ws.longitude.toStringAsFixed(5)}'
                    '${ws.createdAt != null ? ' · submitted ${_shortDate(ws.createdAt!)}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View details',
              icon: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8)),
              onPressed: () => _openWorkspaceDetails(ws),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return raw;
    }
  }

  (Color, Color, IconData) _statusStyles(WorkspaceStatus s) {
    switch (s) {
      case WorkspaceStatus.approved:
        return (
          const Color(0xFF10B981),
          const Color(0xFF10B981).withValues(alpha: 0.12),
          Icons.check_circle_rounded,
        );
      case WorkspaceStatus.pending:
        return (
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.12),
          Icons.hourglass_top_rounded,
        );
      case WorkspaceStatus.rejected:
        return (
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withValues(alpha: 0.12),
          Icons.cancel_rounded,
        );
      case WorkspaceStatus.unknown:
        return (
          const Color(0xFF64748B),
          const Color(0xFF64748B).withValues(alpha: 0.12),
          Icons.help_outline_rounded,
        );
    }
  }

  // ── History table ──────────────────────────────────────────────────────

  Widget _buildHistoryTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.blue, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Attendance History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value &&
                controller.dailyAttendanceList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.dailyAttendanceList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No attendance records yet.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('CLOCK IN')),
                  DataColumn(label: Text('CLOCK OUT')),
                  DataColumn(label: Text('HOURS')),
                ],
                rows: controller.dailyAttendanceList.map((day) {
                  return DataRow(cells: [
                    DataCell(Text(
                      _prettyDate(day.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(Text(day.clockInTime ?? '--:--',
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Text(day.clockOutTime ?? '--:--',
                        style: const TextStyle(fontSize: 13))),
                    DataCell(Text(
                      day.hoursWorked,
                      style: AppText.black_600_14,
                    )),
                  ]);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _prettyDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEE, MMM d').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _AttendanceStats {
  final int thisWeekDays;
  final int thisMonthDays;
  final String avgHoursLabel;
  final String lastClockInRelative;
  final String lastClockInExact;
  _AttendanceStats({
    required this.thisWeekDays,
    required this.thisMonthDays,
    required this.avgHoursLabel,
    required this.lastClockInRelative,
    required this.lastClockInExact,
  });
}
