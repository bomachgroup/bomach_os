import 'package:bms_front_end/components/button/icon_button.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MeetingTable extends StatefulWidget {
  const MeetingTable({super.key});

  @override
  State<MeetingTable> createState() => _MeetingTableState();
}

class _MeetingTableState extends State<MeetingTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "S/N",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Subject of the meeting",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Date",
      )),
      const DataColumn(
        label: MyText(
          "Location",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Atte. members",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Meeting files",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          MyText("#001"),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return const MeetingViewDialog();
              },
            );
          },
          const MyText(
            "O2 Arena Estate dev",
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        const DataCell(
          MyText("02/02/2025", size: 16, weight: 400),
        ),
        const DataCell(
          MyText("Offline"),
        ),
        const DataCell(
          MyText("23"),
        ),
        const DataCell(
          MyText("2"),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}

class MeetingViewDialog extends StatefulWidget {
  const MeetingViewDialog({super.key});

  @override
  MeetingViewDialogState createState() => MeetingViewDialogState();
}

class MeetingViewDialogState extends State<MeetingViewDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 734),
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
                  const MyText("O2 Arena Estate Dev", size: 24, weight: 600),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyIconButton(
                            icon: SvgPicture.asset("assets/svg/plus.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {
                              // showDialog(
                              //   context: context,
                              //   builder: (context) {
                              //   },
                              // );
                            },
                          ),
                          kSizedBoxWidthSM,
                          MyIconButton(
                            icon: SvgPicture.asset("assets/svg/note2.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {
                              // showDialog(
                              //   context: context,
                              //   builder: (context) {
                              //   },
                              // );
                            },
                          ),
                          kSizedBoxWidthSM,
                          MyIconButton(
                            icon:
                                SvgPicture.asset("assets/svg/notification.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  )
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
                      const Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              runSpacing: 15,
                              spacing: 15,
                              children: [],
                            ),
                          ),
                        ],
                      ),
                      const MeetingInfoCard(),
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
                        child: const Column(
                          children: [
                            MyText(
                              'Suggestions and comments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
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

class MeetingInfoCard extends StatelessWidget {
  const MeetingInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final infoItems = [
      {'label': 'Subject of the meeting', 'value': 'O2 Arena Dev'},
      {'label': 'Date/Time', 'value': '9am, 23rd July, 2024'},
      {'label': 'Location', 'value': 'Offline'},
      {'label': 'Address', 'value': 'Amadeo event center Enugu, Nigeria'},
      {'label': 'Attendance', 'value': '23 members'},
      {'label': 'Meeting files', 'value': '23 files'},
      {'label': 'Adjourned', 'value': 'Mrs. Jane okoro'},
      {'label': 'End time', 'value': '3:30pm'},
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
            'Meeting Info',
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
          kSizedBox,
          const MyText(
            "Meeting files",
            weight: 400,
            size: 14,
          ),
          kSizedBoxSM,
          Row(
            children: [
              Column(
                children: [
                  SvgPicture.asset(
                    "assets/svg/note3.svg",
                    colorFilter: const ColorFilter.mode(
                      AppColors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  kSizedBoxTiny,
                  const MyText(
                    "3 files",
                    weight: 300,
                    size: 14,
                  ),
                ],
              ),
              kSizedBoxWidth,
              Column(
                children: [
                  SvgPicture.asset(
                    "assets/svg/todo3.svg",
                    colorFilter: const ColorFilter.mode(
                      AppColors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  kSizedBoxTiny,
                  const MyText(
                    "3 files",
                    weight: 300,
                    size: 14,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
