import 'dart:math';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:flutter/material.dart';


class HRPage extends StatefulWidget {
  const HRPage({super.key});

  @override
  State<HRPage> createState() => _HRPageState();
}

class _HRPageState extends State<HRPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define breakpoints based on available width
        final width = constraints.maxWidth;
        final bool isDesktop = width >= 1100;
        final bool isTablet = width >= 650 && width < 1100;
        final bool isMobile = width < 650;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              kSizedBox,

              // Responsive Grid for Stat Boxes
              _buildSummaryGrid(isDesktop, isTablet, isMobile),

              kSizedBox,

              // Middle Section: Chart & Birthdays
              // On Tablet/Mobile, we stack them. On Desktop, side-by-side.
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildChartSection()),
                    kSizedBoxWidth,
                    Expanded(flex: 1, child: _buildBirthdaysSection()),
                  ],
                )
              else ...[
                _buildChartSection(),
                kSizedBox,
                _buildBirthdaysSection(),
              ],

              kSizedBox,

              // Bottom Section: Audit Logs & Leaves
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAuditLogsSection()),
                    kSizedBoxWidth,
                    Expanded(child: _buildLeavesSection()),
                  ],
                )
              else ...[
                _buildAuditLogsSection(),
                kSizedBox,
                _buildLeavesSection(),
              ],
              kSizedBox,
            ],
          ),
        );
      },
    );
  }

  // 1. Header Section
  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const MyText(
          'HR & Administration',
          style: AppText.black_600_32,
        ),
        if (!isMobile)
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const MyText('Job Postings',
                    style: TextStyle(color: Colors.black)),
              ),
              kSizedBoxWidth,
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(CupertinoIcons.add,
                    color: Colors.white, size: 16),
                label: const MyText('Add Employee',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          )
      ],
    );
  }

  // 2. Summary Cards Row
  Widget _buildSummaryGrid(bool isDesktop, bool isTablet, bool isMobile) {
    return ResponsiveStatRow(
      cards: [
        _buildStatCard(
          title: 'Total Employees',
          count: '234',
          borderColor: Colors.green,
          countColor: Colors.green,
        ),
        _buildStatCard(
          title: 'New Hires (30 days)',
          count: '18',
          borderColor: const Color(0xFF1976D2),
          countColor: const Color(0xFF1976D2),
        ),
        _buildStatCard(
          title: 'Open Roles',
          count: '12',
          borderColor: const Color(0xFFC27803),
          countColor: const Color(0xFFC27803),
        ),
        _buildStatCard(
          title: 'New Hires',
          count: '2',
          borderColor: Colors.pinkAccent,
          countColor: Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color borderColor,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Text(count,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: countColor)),
        ],
      ),
    );
  }

  // 3. Charts Section
  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Headcount by Department',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Wrap in LayoutBuilder to handle chart responsiveness internally
          LayoutBuilder(builder: (context, constraints) {
            final bool narrow = constraints.maxWidth < 350;
            return Flex(
              direction: narrow ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CustomPaint(
                    painter: DonutChartPainter(),
                  ),
                ),
                SizedBox(width: narrow ? 0 : 40, height: narrow ? 20 : 0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(const Color(0xFF6C63FF), 'Development',
                          '78 employees'),
                      _buildLegendItem(
                          const Color(0xFFA063FF), 'Marketing', '42 employees'),
                      _buildLegendItem(
                          const Color(0xFFE91E63), 'Sales', '56 employees'),
                      _buildLegendItem(const Color(0xFFFF9800), 'Operations',
                          '35 employees'),
                      _buildLegendItem(
                          const Color(0xFF26A69A), 'Finance', '24 employees'),
                      _buildLegendItem(
                          const Color(0xFF42A5F5), 'HR', '12 employees'),
                    ],
                  ),
                )
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: MyText(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(width: 4),
                MyText(sub,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Birthdays Section
  Widget _buildBirthdaysSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Upcoming Birthdays',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildBirthdayTile(
              'N', 'Nicky Fry', 'Designer', 'Apr 24', Colors.purpleAccent),
          _buildBirthdayTile(
              'R', 'Rick Fry', 'Developer', 'May 11', Colors.pinkAccent),
          _buildBirthdayTile(
              'A', 'Alice Fry', 'Manager', 'May 06', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildBirthdayTile(
      String init, String name, String role, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: MyText(init,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                MyText(role,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          MyText(date, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  // 5. Audit Logs Section
  Widget _buildAuditLogsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Audit Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildAuditItem('Clark Changed Rose Ells', '08:12 AM'),
          _buildAuditItem('Garrett added a new employee', '06:45 AM'),
          _buildAuditItem('Sophie generated Payroll Report', 'Yesterday'),
          _buildAuditItem('System Backup completed', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildAuditItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                MyText(time,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 6. Recent Leaves Section
  Widget _buildLeavesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Recent Leaves',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildLeaveItem(
              'David West', '2024-12-01 - 2024-12-14', 'Approved', Colors.blue),
          _buildLeaveItem('Sarah Musa', '2024-12-01 - 2024-12-14', 'Pending',
              Colors.orange),
          _buildLeaveItem('Benji Rider 1', '2024-12-01 - 2024-12-14',
              'Rejected', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(
      String name, String date, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                MyText(date,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: MyText(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

// Zero-Dependency Donut Chart Painter
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 30.0;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -pi / 2;

    void drawSegment(Color color, double percentage) {
      paint.color = color;
      final sweepAngle = 2 * pi * percentage;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(const Color(0xFF6C63FF), 0.32); // Dev
    drawSegment(const Color(0xFFA063FF), 0.17); // Mkt
    drawSegment(const Color(0xFFE91E63), 0.23); // Sales
    drawSegment(const Color(0xFFFF9800), 0.14); // Ops
    drawSegment(const Color(0xFF26A69A), 0.09); // Fin
    drawSegment(const Color(0xFF42A5F5), 0.05); // HR
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
