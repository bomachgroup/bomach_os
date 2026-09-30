import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/invoice.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/input/upload_file.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';
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
    return PageScaffold(
      children: [
        Column(
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
                          MyText(
                            'Enugu Branch',
                            style: AppTextStyles.displayLg,
                          ),
                          kSizedBoxWidthSM,
                          Icon(
                            Iconsax.arrow_down_1,
                            size: 24,
                          ),
                        ],
                      ),
                      Wrap(
                        runSpacing: 15,
                        children: [
                          MyOutlinedButton(
                            child: 'Company profile',
                            onTap: () {},
                          ),
                          kSizedBoxWidth,
                          MyElevatedButton(
                            icon: const Icon(
                              Iconsax.add_circle,
                              color: AppColors.white,
                            ),
                            child: 'New Branch',
                            onTap: () {
                              showCreateBranchModal(context);
                            },
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
              color: AppColors.success.withValues(alpha: 0.2),
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
                color: AppColors.primary.withValues(alpha: 0.15)),
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
              color: AppColors.success.withValues(alpha: 0.2),
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
                color: AppColors.primary.withValues(alpha: 0.15)),
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
              color: AppColors.success.withValues(alpha: 0.2),
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
                color: AppColors.primary.withValues(alpha: 0.15)),
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
              color: AppColors.success.withValues(alpha: 0.2),
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
                color: AppColors.primary.withValues(alpha: 0.15)),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
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
                  MyText(
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
            MyText(
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
                Expanded(
                  child: MyText(
                    subtext,
                    // overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.neutral800,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 4,
          children: [
            const MyText(
              'Client Invoice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const MyText(
                'View all',
                isSelectable: false,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        kSizedBoxSM,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                decoration: BoxDecoration(
                  border: index + 1 == 3
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.neutral500),
                        ),
                ),
                child: const InvoiceCard(),
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
            color: Colors.grey.withValues(alpha: 0.2),
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
                Expanded(
                  child: MyText(
                    'Company Schedule',
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                kSizedBoxWidthSM,
                Icon(Iconsax.calendar_1, color: AppColors.primary),
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
                leftChevronIcon: Icon(Iconsax.arrow_left_2),
                rightChevronIcon: Icon(Iconsax.arrow_right_3),
              ),
              calendarStyle: const CalendarStyle(
                rangeHighlightColor: AppColors.primary,
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
                    Icon(Iconsax.more)
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
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Row(
      children: [
        MyText(
          time,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: compact ? 8 : kDefaultSpace),
          width: 2,
          height: 51,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.withValues(alpha: 0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                title,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
              MyText(
                subtitle,
                style: const TextStyle(
                  color: AppColors.black,
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
            color: Colors.grey.withValues(alpha: 0.2),
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
                        MyText(
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
                            MyText(
                              'Enugu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            kSizedBoxWidthSM,
                            Icon(
                              Iconsax.arrow_circle_down,
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
                        Icon(Iconsax.sun,
                            color: AppColors.neutral500, size: 49),
                        kSizedBoxWidthSM,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              '8:02:09 AM',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            MyText(
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
              MyText(
                'Today:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral800,
                ),
              ),
              MyText(
                '18th November 2023',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showCreateBranchModal(BuildContext context) {
    final TextEditingController branchNameController = TextEditingController();
    final TextEditingController officeAddressController =
        TextEditingController();
    final TextEditingController lgaController = TextEditingController();
    final TextEditingController startDateController2 = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.background,
            ),
            padding: const EdgeInsets.all(kDefaultSpace),
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText("Create Branch",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: branchNameController,
                          hintText: "---",
                          title: 'Branch Name*',
                        ),
                      ),
                      kSizedBoxWidth,
                      Expanded(
                        child: MyDropdown(
                          items: const [
                            'Nigeria',
                            'Ghana',
                          ],
                          onChanged: (val) {},
                          hintText: '---',
                          title: 'Country*',
                        ),
                      ),
                    ],
                  ),

                  kSizedBoxBG,

                  Row(
                    children: [
                      Expanded(
                        child: MyDropdown(
                          items: const ['Lagos', 'Abuja'],
                          onChanged: (val) {},
                          hintText: '---',
                          title: 'State*',
                        ),
                      ),
                      kSizedBoxWidth,
                      Expanded(
                        child: MyTextFormField(
                          controller: lgaController,
                          hintText: "---",
                          title: 'L.G.A*',
                        ),
                      ),
                    ],
                  ),

                  kSizedBoxBG,

                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          maxLines: 3,
                          controller: officeAddressController,
                          hintText: "---",
                          title: 'Office Address*',
                        ),
                      ),
                    ],
                  ),
                  kSizedBoxBG,

                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: startDateController2,
                          hintText: "---",
                          title: 'Start date (optional)*',
                          onTap: () async {
                            DateTime? picked = await showDatePopover(
                              context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              startDateController2.text =
                                  formatAppDate(picked.toLocal());
                            }
                          },
                        ),
                      ),
                      kSizedBoxWidth,
                      Expanded(
                        child: MyTextFormField(
                          controller: startDateController2,
                          hintText: "---",
                          title: 'Start date (optional)*',
                          onTap: () async {
                            DateTime? picked = await showDatePopover(
                              context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              startDateController2.text =
                                  formatAppDate(picked.toLocal());
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  kSizedBoxBG,
                  const MyText(
                    "Upload Branch File (optional)",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  kSizedBoxSM,
                  const UploadFile(),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.end,
                          children: [
                            MyOutlinedButton(
                              textColor: AppColors.neutral500,
                              borderColor: null,
                              child: 'Cancel',
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            MyElevatedButton(
                              icon: const Icon(
                                Iconsax.tick_circle,
                                color: AppColors.white,
                              ),
                              child: 'Save',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
