import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_lead_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Leads',
                  style: AppText.black_600_32,
                ),
                MyText(
                  'Leads',
                  style: AppText.black_600_14,
                ),
              ],
            ),
          ],
        ),
        kSizedBoxBG,
        Wrap(
          spacing: 8, // Horizontal space between items
          runSpacing: 8, // Vertical space when wrapping
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.white,
              ),
              child: 'New Leads',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AddLeadDialog();
                  },
                );
              },
            ),
            kSizedBoxWidth,
            SizedBox(
              width: 220,
              height: 48,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SortBar(
              text: 'Sort',
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: bodySpace(context),
                    ),
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context),
                      showBottomBorder: true,
                    ),
                  ),
                ),
              ),
              const MyPaginator(),
            ],
          ),
        )
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyCheckbox(
          isChecked: false,
          onChanged: (val) {},
          backgroundNotCheckedColor: AppColors.transparent,
          borderNotCheckedColor: AppColors.grey4,
        ),
      ),
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Leads ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Contact Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Email",
      )),
      const DataColumn(
        label: MyText(
          "Phone no.",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Lead Owner",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Date of creation",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(
      10,
      (index) {
        return DataRow(
          cells: <DataCell>[
            DataCell(
              onTap: () {},
              MyCheckbox(
                isChecked: false,
                onChanged: (val) {},
                backgroundNotCheckedColor: AppColors.transparent,
                borderNotCheckedColor: AppColors.grey4,
              ),
            ),
            const DataCell(
              MyText("001"),
            ),
            DataCell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const ViewLeadsDialog();
                  },
                );
              },
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    width: 36,
                    height: 36,
                    child: Image.asset('assets/icons/profile-icon.png'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        "Darlene Robertson",
                        size: 16,
                        weight: 400,
                        isSelectable: false,
                      ),
                      MyText(
                        "MTN Nigeria",
                        size: 14,
                        weight: 300,
                        isSelectable: false,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const DataCell(
              MyText("Jennygroup45@gmail.com"),
            ),
            const DataCell(
              MyText("+234 808 986 2487"),
            ),
            const DataCell(
              MyText("--"),
            ),
            const DataCell(
              MyText("27/09/2024"),
            ),
          ],
        );
      },
    );
  }
}

class ViewLeadsDialog extends StatefulWidget {
  const ViewLeadsDialog({super.key});

  @override
  ViewLeadsDialogState createState() => ViewLeadsDialogState();
}

class ViewLeadsDialogState extends State<ViewLeadsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1050),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.greyBg,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(kDefaultSpaceBG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText("Lead", size: 24, weight: 600),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/add-circle.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.white, BlendMode.srcIn),
                    ),
                    child: "Add Note",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddNoteDialog();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultSpaceBG, vertical: kDefaultSpaceBG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kSizedBox,
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              runSpacing: 15,
                              spacing: 15,
                              children: [
                                const ClientInfoCard(),
                                StatsCard(
                                  title: 'Service',
                                  value: 'Real Estate',
                                  icon: SvgPicture.asset(
                                    "assets/svg/star-chart.svg",
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                                StatsCard(
                                  title: 'Prospective value',
                                  value: '1000',
                                  icon: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const SizedBox(),
                                      Positioned(
                                        left: -10,
                                        child: SvgPicture.asset(
                                            "assets/svg/naira-coin.svg"),
                                      ),
                                      Positioned(
                                        child: SvgPicture.asset(
                                            "assets/svg/naira-coin.svg"),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ProfileInfoCard(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: DetailAndNotes(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientInfoCard extends StatelessWidget {
  const ClientInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: !isLargeScreen(context) ? double.infinity : 400,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Client',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          kSizedBoxSM,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/image/man-demo.png",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(
                      'Jane Okoro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const MyText(
                      'Business woman',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      'Date of creation: 27/09/2024',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: !isLargeScreen(context) ? double.infinity : 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyText(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue2,
                  ),
                ),
              ),
              icon,
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final infoItems = [
      {'label': 'Leads ID', 'value': '001'},
      {'label': 'Contact Name', 'value': 'Jane Okoro'},
      {'label': 'Phone', 'value': '+2349077745777'},
      {'label': 'Email', 'value': 'Janeokoro45@gmail.com'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Personal Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: infoItems.length,
            separatorBuilder: (context, index) => kSizedBoxSM,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: MyText(
                      infoItems[index]['label']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: MyText(
                      infoItems[index]['value']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DetailAndNotes extends StatelessWidget {
  const DetailAndNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.white,
            border: Border.all(
              color: AppColors.grey4,
              width: 0.6,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Detail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kSizedBoxSM,
              MyText(
                'Detail bfndsn sdbnm,adn sdvbjnm,sdv bjsvdv,mnsa sbdndms,',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 10,
              ),
            ],
          ),
        ),
        kSizedBox,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.white,
            border: Border.all(
              color: AppColors.grey4,
              width: 0.6,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyText(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kSizedBoxSM,
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (_, __) => kSizedBox,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        child: MyText("${index + 1}"),
                      ),
                      const Expanded(
                        child: MyText(
                          'Detail bfndsn sdbnm,adn sdvbjnm,sdv bjsvdv,mnsa sbdndms,',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 10,
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGrey2,
            ),
          ),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: AppColors.darkGrey2,
            ),
          ),
        ],
      ),
    );
  }
}

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.grey4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add Note',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form fields
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: "Enter Note",
                              spaceBetweenText: 10,
                              maxLines: 7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/kite.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.white, BlendMode.srcIn),
                    ),
                    child: 'Submit',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
