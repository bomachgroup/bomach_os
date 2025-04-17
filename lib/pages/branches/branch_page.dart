import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:table_calendar/table_calendar.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enugu Branch',
                        style: AppText.black_600_32,
                      ),
                      kSizedBoxWidthSM,
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 24,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyOutlinedButton(
                        child: 'Company profile',
                        onTap: () {},
                      ),
                      kSizedBoxWidth,
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.whiteColor,
                        ),
                        child: 'New Branch',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        SizedBox(
          width: isLargeScreen(context) ? media.width - 300 : media.width,
          child: LayoutGrid(
            gridFit: GridFit.passthrough,
            columnSizes: isSmallScreen(context) ? [1.fr] : [2.fr, 1.fr],
            rowSizes: isSmallScreen(context) ? [auto, auto] : [auto],
            columnGap: kDefaultSpaceBG,
            rowGap: kDefaultSpaceBG,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSmallScreen(context)) kSizedBox,
                  _buildSummaryGrid(),
                  kSizedBox,
                  kSizedBoxSM,
                  _buildClientInvoiceSection(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBranchDateTimeCard(),
                  kSizedBox,
                  kSizedBoxSM,
                  _buildCompanySchedule(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutGrid(
      columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: isSmallScreen(context)
          ? [
              auto,
              auto,
              auto,
              auto,
            ]
          : const [
              auto,
              auto,
            ],
      columnGap: kDefaultSpaceBG,
      rowGap: kDefaultSpaceBG,
      children: [
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          subtext: '4 new employees added',
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withOpacity(0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blueColor.withOpacity(0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          subtext: '4 new employees added',
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withOpacity(0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blueColor.withOpacity(0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          subtext: '4 new employees added',
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withOpacity(0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blueColor.withOpacity(0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          subtext: '4 new employees added',
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withOpacity(0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blueColor.withOpacity(0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required Widget bigIcon,
    required Widget smallIcon,
    required String subtext,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  bigIcon,
                ],
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            Row(
              children: [
                smallIcon,
                kSizedBoxWidthSM,
                Text(
                  subtext,
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInvoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Client Invoice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        kSizedBoxSM,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                padding: const EdgeInsets.symmetric(
                    vertical: kDefaultSpace, horizontal: kDefaultSpace),
                decoration: BoxDecoration(
                  border: index + 1 == 3
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.grey1),
                        ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description, color: Colors.red),
                    kSizedBoxWidthSM,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice #1273636'),
                        Text('Chijiokeugo@nggs')
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.download),
                    kSizedBoxWidthSM,
                    Icon(Icons.share)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySchedule() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Company Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.blue),
              ],
            ),
          ),
          // In a real app, you'd use a calendar package or custom implementation
          SizedBox(
            height: 400,
            child: TableCalendar(
              availableGestures: AvailableGestures.none,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              firstDay: DateTime(1990),
              lastDay: DateTime.now(),
              focusedDay: DateTime.now(),
              onDaySelected: (selectedDay, focusedDay) {},
              onFormatChanged: (format) {},
              onPageChanged: (focusedDay) {},
              headerStyle: const HeaderStyle(
                titleCentered: true,
                leftChevronIcon: Icon(Icons.arrow_back),
                rightChevronIcon: Icon(Icons.arrow_forward),
              ),
              calendarStyle: const CalendarStyle(
                rangeHighlightColor: AppColors.blueColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: MyText('Wednesday, 06 July 2023',
                            size: 16, weight: 300)),
                    Icon(Icons.more_vert)
                  ],
                ),
                kSizedBox,
                _buildScheduleItem(
                  time: '09:30',
                  title: 'UI/UX Designer',
                  subtitle: 'Practical Task Review',
                ),
                kSizedBox,
                _buildScheduleItem(
                  time: '12:00',
                  title: 'Flutter Developer',
                  subtitle: 'Resume Review',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: kDefaultSpace),
          width: 2,
          height: 51,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBranchDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch and Dropdown
          Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Enugu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            kSizedBoxWidthSM,
                            Icon(
                              Icons.arrow_drop_down_circle_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Spacer(),
                    // // Time Display
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wb_sunny_outlined,
                            color: AppColors.grey1, size: 49),
                        kSizedBoxWidthSM,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '8:02:09 AM',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              ' WAT',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          kSizedBox,
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                '18th November 2023',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
