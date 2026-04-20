import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';

import 'controller/biometrics_controller.dart';
import 'models/attendance_models.dart';
import 'widget/setup_workspace_dialog.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  final BiometricsController controller = Get.put(BiometricsController());
  final _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

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
        controller.fetchWorkspace(token),
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

  Future<void> _openWorkspaceSetup() async {
    final token = await _getToken(context);
    if (token == null || !mounted) return;
    showDialog(
      context: context,
      builder: (_) => SetupWorkspaceDialog(token: token),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title + Workspace Status ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child:
                    MyText('Attendance Management', style: AppText.black_500_32),
              ),
              Obx(() => _buildFaceChip()),
              const SizedBox(width: 8),
              Obx(() => _buildWorkspaceChip()),
            ],
          ),
          kSizedBox,

          // --- Workspace Warning Banner ---
          Obx(() {
            if (controller.workspace.value != null ||
                controller.isFetchingWorkspace.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFCC02).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Workspace Not Configured',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A3800),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set up your workspace location to enable face-verified clock-in.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown.shade400),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _openWorkspaceSetup,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Setup Now',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            );
          }),

          // --- Face Registration Banner ---
          Obx(() {
            if (controller.hasFace.value ||
                controller.isFetchingStatus.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF0055FF).withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0055FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.face_rounded,
                          color: Color(0xFF0055FF), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Face Not Registered',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B1F4D),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Register your face so you can clock in and out with it.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF476A9E)),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => TextButton(
                          onPressed: controller.isAuthenticating.value
                              ? null
                              : _openFaceSetup,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF0055FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: controller.isAuthenticating.value
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Register Face',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                        )),
                  ],
                ),
              ),
            );
          }),

          // --- 1. Action Cards (Clock In / Clock Out) ---
          _buildLiveClockCard(),
          kSizedBox,

          // --- 2. Graph Section ---
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0XFFD5D5D5), width: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText("Attendance Graph",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(children: [
                        Text("This Week", style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16)
                      ]),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SimpleChartPainter(),
                  ),
                ),
              ],
            ),
          ),
          kSizedBox,

          // --- 3. Table Section ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        hintText: 'Search...',
                        leading: Icon(Icons.search,
                            color: Colors.grey.withValues(alpha: 0.5)),
                      ),
                    ),
                    Row(
                      children: [
                        _buildFilterBtn("All Staff"),
                        const SizedBox(width: 12),
                        _buildFilterBtn("Today"),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.dailyAttendanceList.isEmpty) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("No records found."),
                    ));
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Employee')),
                        DataColumn(label: Text('Clock In')),
                        DataColumn(label: Text('Clock Out')),
                        DataColumn(label: Text('Hours Worked')),
                      ],
                      rows: controller.dailyAttendanceList.map((day) {
                        return DataRow(cells: [
                          DataCell(Text(day.date)),
                          DataCell(Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(Icons.person,
                                    size: 16, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(day.employeeName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(day.role,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                ],
                              )
                            ],
                          )),
                          DataCell(Text(day.clockInTime ?? '--:--')),
                          DataCell(Text(day.clockOutTime ?? '--:--')),
                          DataCell(Text(day.hoursWorked)),
                        ]);
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Face registration chip ─────────────────────────────────────────────

  Widget _buildFaceChip() {
    if (controller.isFetchingStatus.value) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final registered = controller.hasFace.value;
    final color =
        registered ? const Color(0xFF10B981) : Colors.orange;

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
          final ok = await controller.removeBiometric(token,
              biometricType: 'face');
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
              child:
                  Text('Remove Face', style: TextStyle(color: Colors.red))),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              registered ? Icons.face_rounded : Icons.face_retouching_off,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              registered ? 'Face registered' : 'Face not set',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 14, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  // ── Workspace status chip ──────────────────────────────────────────────

  Widget _buildWorkspaceChip() {
    final ws = controller.workspace.value;
    final loading = controller.isFetchingWorkspace.value;

    if (loading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return InkWell(
      onTap: _openWorkspaceSetup,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ws != null
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ws != null
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ws != null ? Icons.location_on_rounded : Icons.location_off_rounded,
              size: 14,
              color: ws != null ? const Color(0xFF10B981) : Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              ws != null ? ws.workspaceName : 'No workspace',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ws != null ? const Color(0xFF10B981) : Colors.orange,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.settings_rounded,
              size: 12,
              color: ws != null
                  ? const Color(0xFF10B981).withValues(alpha: 0.7)
                  : Colors.orange.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  // ── Unified Time Card ───────────────────────────────────────

  Widget _buildLiveClockCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          const MyText("Current Time",
              style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 8),
          StreamBuilder<String>(
            stream: _timeStream,
            builder: (context, snapshot) {
              return MyText(
                snapshot.data ?? "--:--:--",
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
              DateFormat('EEEE, MMMM d, yyyy').format(controller.trustedTime),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          Obx(() {
            final todayDateStr =
                DateFormat('yyyy-MM-dd').format(controller.trustedTime);
            // Need to import collection for firstWhereOrNull, but let's just use firstWhere with orElse
            final todayRecord = controller.dailyAttendanceList.firstWhere(
              (r) => r.date == todayDateStr,
              orElse: () => DailyAttendance(date: todayDateStr),
            );

            final timeIn = todayRecord.clockInTime ?? '--:--';
            final timeOut = todayRecord.clockOutTime ?? '--:--';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeStatusItem("Time In", timeIn, Icons.login,
                    const Color(0xFF00C853)),
                Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                _buildTimeStatusItem("Time Out", timeOut, Icons.logout,
                    const Color(0xFF2962FF)),
              ],
            );
          }),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  buttonText: "Clock In",
                  buttonColor: const Color(0xFF00C853),
                  onTap: () => _handleClockAction(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  buttonText: "Clock Out",
                  buttonColor: const Color(0xFF2962FF),
                  onTap: () => _handleClockAction(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButton(
      {required String buttonText,
      required Color buttonColor,
      required VoidCallback onTap}) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Obx(() {
          final expectedType = buttonText == "Clock In" ? 'clock_in' : 'clock_out';
          if (controller.isAuthenticating.value && controller.authActionType.value == expectedType) {
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
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
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

  Widget _buildFilterBtn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Text(text,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey)
        ],
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(size.width * 0.2, size.height * 0.5, size.width * 0.4,
        size.height * 0.8, size.width * 0.5, size.height * 0.4);
    path.cubicTo(size.width * 0.6, size.height * 0.1, size.width * 0.8,
        size.height * 0.6, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = const Color(0xFF00C853);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
