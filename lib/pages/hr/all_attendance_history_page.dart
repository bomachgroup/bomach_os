import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/pages/hr/controller/biometrics_controller.dart';
import 'package:bomach_os/pages/hr/models/attendance_models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// Full-page view showing the complete list of daily attendance entries
/// with a back button to return to the main attendance screen.
class AllAttendanceHistoryPage extends StatelessWidget {
  const AllAttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BiometricsController>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Attendance History',
                subtitle: 'Complete log of all your clock-in and clock-out records.',
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left),
                  tooltip: 'Back to Attendance',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.dailyAttendanceList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.dailyAttendanceList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No attendance records found.',
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
                      DataCell(Text(
                        day.clockInTime ?? '--:--',
                        style: const TextStyle(fontSize: 13),
                      )),
                      DataCell(_buildClockOutCell(day)),
                      DataCell(_buildHoursCell(day)),
                    ]),
                    mobileCardBuilder: (day, index) => _buildMobileCard(day),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClockOutCell(DailyAttendance day) {
    if (day.isMissedClockOut) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2, size: 12, color: Color(0xFFD97706)),
            SizedBox(width: 4),
            Text(
              'Missed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    }
    return Text(day.clockOutTime ?? '--:--', style: const TextStyle(fontSize: 13));
  }

  Widget _buildHoursCell(DailyAttendance day) {
    if (day.isMissedClockOut) {
      return const Text(
        'Incomplete',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral400,
        ),
      );
    }
    return Text(
      day.hoursWorked,
      style: AppTextStyles.h4,
    );
  }

  Widget _buildMobileCard(DailyAttendance day) {
    return AppCard(
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
              if (day.isMissedClockOut)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.warning_2, size: 12, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text(
                        'Missed Clock-Out',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    const Text('Clock In', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(day.clockInTime ?? '--:--', style: AppTextStyles.h4),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clock Out', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    if (day.isMissedClockOut)
                      const Text('Missed',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309)))
                    else
                      Text(day.clockOutTime ?? '--:--',
                          style: AppTextStyles.h4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _prettyDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEE, MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}
