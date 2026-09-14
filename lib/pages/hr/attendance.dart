import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
        (_) => DateFormat('hh:mm a').format(controller.trustedTime),
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
      AppToast.success(context, controller.successMessage.value);
    } else if (controller.errorMessage.isNotEmpty) {
      AppToast.error(context, controller.errorMessage.value);
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
      AppToast.error(context, controller.errorMessage.value);
    } else if (controller.successMessage.isNotEmpty) {
      AppToast.success(context, controller.successMessage.value);
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
    return PageScaffold(
      header: PageHeader(
        title: 'Attendance',
        subtitle: 'Clock in with face verification and track your attendance.',
        trailing: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Obx(() => _buildFaceHeroChip()),
            Obx(() => _buildWorkspaceHeroChip()),
          ],
        ),
      ),
      children: [
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
          AppToast.info(
              context,
              ok
                  ? controller.successMessage.value
                  : controller.errorMessage.value);
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
        icon: registered ? Iconsax.emoji_happy : Iconsax.emoji_normal,
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
      icon = Iconsax.location_slash;
    } else if (approved > 0) {
      label = pending > 0
          ? '$approved approved · $pending pending'
          : '$approved approved';
      icon = Iconsax.location;
    } else if (pending > 0) {
      label = '$pending awaiting approval';
      icon = Iconsax.timer;
    } else if (rejected > 0) {
      label = rejected == 1 ? 'Workspace rejected' : '$rejected rejected';
      icon = Iconsax.location_slash;
    } else {
      label = '$total submitted';
      icon = Iconsax.location;
    }

    return _heroChip(icon: icon, label: label);
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
        icon: Iconsax.calendar_1,
        color: AppColors.success,
      ),
      _StatCardData(
        title: 'This Month',
        value: '${stats.thisMonthDays}',
        subtitle: 'days clocked in',
        icon: Iconsax.calendar_1,
        color: AppColors.primary,
      ),
      _StatCardData(
        title: 'Avg Hours / Day',
        value: stats.avgHoursLabel,
        subtitle: 'based on this month',
        icon: Iconsax.timer_1,
        color: AppColors.warning,
      ),
      _StatCardData(
        title: 'Last Clock-In',
        value: stats.lastClockInRelative,
        subtitle: stats.lastClockInExact,
        icon: Iconsax.login_1,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return ResponsiveStatRow(
      cards: cards.map((c) => _statCard(c)).toList(),
    );
  }

  Widget _statCard(_StatCardData c) {
    return AppCard(
      padding: const EdgeInsets.all(20),
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
                    color: AppColors.neutral500,
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
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
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
    return AppCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Text("Current Time",
              style: TextStyle(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          StreamBuilder<String>(
            stream: _timeStream,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ??
                    DateFormat('hh:mm a').format(controller.trustedTime),
                style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.neutral900),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(DateFormat('EEEE, MMMM d, yyyy').format(controller.trustedTime),
              style:
                  const TextStyle(color: AppColors.neutral500, fontSize: 15)),
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
                    "Time In", timeIn, Iconsax.login_1, AppColors.success),
                Container(width: 1, height: 40, color: AppColors.neutral200),
                _buildTimeStatusItem(
                    "Time Out", timeOut, Iconsax.logout_1, AppColors.primary),
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
                        buttonColor: AppColors.success,
                        onTap: enabled ? () => _handleClockAction(true) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        buttonText: "Clock Out",
                        buttonColor: AppColors.primary,
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
                        const Icon(Iconsax.info_circle,
                            color: AppColors.warning, size: 16),
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
                    color: AppColors.neutral500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900)),
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
          disabledBackgroundColor: AppColors.neutral300,
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
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.location,
                    color: AppColors.primary, size: 18),
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
                          color: AppColors.neutral900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Submit a location for approval. Admin sets the geofence radius.',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.neutral500),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openSubmitWorkspace,
                icon: const Icon(Iconsax.location_add, size: 16),
                label: const Text('Submit New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
            if (controller.errorMessage.value.isNotEmpty &&
                controller.workspaces.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Text(
                      'Error loading workspaces',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.neutral500),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final token = await _getToken(context);
                        if (token != null && mounted) {
                          await controller.fetchWorkspaces(token);
                        }
                      },
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
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
                    const Divider(height: 1, color: AppColors.neutral100),
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
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.location_add,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'No workspaces yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Submit your first workspace to start clocking in.\n'
            "Admin will review it before it's usable.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openSubmitWorkspace,
            icon: const Icon(Iconsax.location_add, size: 16),
            label: const Text('Submit Your First Workspace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ws.latitude.toStringAsFixed(5)}, '
                    '${ws.longitude.toStringAsFixed(5)}'
                    '${ws.createdAt != null ? ' · submitted ${_shortDate(ws.createdAt!)}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View details',
              icon: const Icon(Iconsax.arrow_right_3,
                  color: AppColors.neutral400),
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
          AppColors.success,
          AppColors.success.withValues(alpha: 0.12),
          Iconsax.tick_circle,
        );
      case WorkspaceStatus.pending:
        return (
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.12),
          Iconsax.timer,
        );
      case WorkspaceStatus.rejected:
        return (
          AppColors.danger,
          AppColors.danger.withValues(alpha: 0.12),
          Iconsax.close_circle,
        );
      case WorkspaceStatus.unknown:
        return (
          AppColors.neutral500,
          AppColors.neutral500.withValues(alpha: 0.12),
          Iconsax.info_circle,
        );
    }
  }

  // ── History table ──────────────────────────────────────────────────────

  Widget _buildHistoryTable() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.clock,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Attendance History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
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
                    style: TextStyle(color: AppColors.neutral400),
                  ),
                ),
              );
            }
            return ResponsiveTable<DailyAttendance>(
              items: controller.dailyAttendanceList,
              columns: const [
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('CLOCK IN')),
                DataColumn(label: Text('CLOCK OUT')),
                DataColumn(label: Text('HOURS')),
              ],
              rowBuilder: (day, index) => DataRow(cells: [
                DataCell(Text(
                  _prettyDate(day.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                    fontSize: 13,
                  ),
                )),
                DataCell(Text(day.clockInTime ?? '--:--',
                    style: const TextStyle(fontSize: 13))),
                DataCell(Text(day.clockOutTime ?? '--:--',
                    style: const TextStyle(fontSize: 13))),
                DataCell(Text(
                  day.hoursWorked,
                  style: AppTextStyles.h4,
                )),
              ]),
              mobileCardBuilder: (day, index) => AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _prettyDate(day.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            day.hoursWorked,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Clock In',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              Text(day.clockInTime ?? '--:--',
                                  style: AppTextStyles.h4),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Clock Out',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              Text(day.clockOutTime ?? '--:--',
                                  style: AppTextStyles.h4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
