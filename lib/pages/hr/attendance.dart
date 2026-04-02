import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';

import 'controller/biometrics_controller.dart';
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
        (_) => DateFormat('HH:mm:ss').format(DateTime.now()),
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
      ]);
    }
  }

  Future<void> _handleClockAction(bool isClockIn) async {
    final token = await _getToken(context);
    if (token != null) {
      await controller.performClockAction(token, isClockIn: isClockIn);
      if (controller.errorMessage.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(controller.errorMessage.value),
            backgroundColor: Colors.red));
      } else if (controller.successMessage.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(controller.successMessage.value),
            backgroundColor: Colors.green));
      }
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

          // --- 1. Action Cards (Clock In / Clock Out) ---
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  title: "Time In",
                  buttonColor: const Color(0xFF00C853),
                  buttonText: "Clock In",
                  onTap: () => _handleClockAction(true),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTimeCard(
                  title: "Time Out",
                  buttonColor: const Color(0xFF2962FF),
                  buttonText: "Clock Out",
                  onTap: () => _handleClockAction(false),
                ),
              ),
            ],
          ),
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

  // ── Time card with step feedback ───────────────────────────────────────

  Widget _buildTimeCard({
    required String title,
    required Color buttonColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          MyText(title, color: const Color(0xFF2E7D32), weight: 600, size: 14),
          const SizedBox(height: 16),
          StreamBuilder<String>(
            stream: _timeStream,
            builder: (context, snapshot) {
              return MyText(
                snapshot.data ?? "--:--:--",
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Obx(() {
                if (controller.isAuthenticating.value) {
                  final step = controller.clockStepMessage.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                      if (step.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(step,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 9)),
                        ),
                    ],
                  );
                }
                return Text(buttonText,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold));
              }),
            ),
          )
        ],
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
