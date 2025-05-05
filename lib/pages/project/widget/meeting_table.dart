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
                children: [
                  Expanded(
                    child: Wrap(
                      runSpacing: 15,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: MyText(
                            "O2 Arena Estate Dev",
                            size: 24,
                            weight: 600,
                            maxLines: 1,
                          ),
                        ),
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
                                  icon:
                                      SvgPicture.asset("assets/svg/note2.svg"),
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
                                  icon: SvgPicture.asset(
                                      "assets/svg/notification.svg"),
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
                ],
              ),
            ),
            SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultSpaceBG, vertical: kDefaultSpaceBG),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MeetingInfoCard(),
                      kSizedBox,
                      SuggestionsAndComments(),
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

class SuggestionsAndComments extends StatelessWidget {
  const SuggestionsAndComments({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MyText(
                  'Suggestions and comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          kSizedBoxSM,
          Column(
            children: [
              MessageBubble(
                message:
                    '@janeagbo she talk up the function of a program manager.',
                time: '9:54 PM',
                isMe: false,
              ),
              MessageBubble(
                message: 'I solely think thats gonna be the best idea for now',
                time: '9:54 PM',
                isMe: false,
              ),
              MessageBubble(
                message:
                    'uhh... I guess we should give everyone time to think about and come up with a better suggestion..',
                time: '9:54 PM',
                isMe: true,
              ),
            ],
          ),
          kSizedBoxSM,
          ChatInputField(),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Conditional order of widgets based on isMe
            if (!isMe) CurvedBackground(isMe: isMe),

            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.blue : AppColors.grey6,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyText(
                    message,
                    style: TextStyle(
                      color: isMe ? AppColors.grey6 : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? AppColors.grey6 : Colors.black54,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          "assets/svg/two-checks.svg",
                          height: 12,
                          width: 12,
                          colorFilter: ColorFilter.mode(
                            isMe ? AppColors.grey6 : Colors.black54,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Add the curved background for my messages
            if (isMe) CurvedBackground(isMe: isMe),
          ],
        ),
      ),
    );
  }
}

class CurvedBackground extends StatelessWidget {
  final bool isMe;

  const CurvedBackground({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 20,
      child: CustomPaint(
        painter: CurvePainter(isMe: isMe),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final bool isMe;

  CurvePainter({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? AppColors.blue : AppColors.grey6
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..isAntiAlias = true;

    final path = Path();

    if (isMe) {
      // Right side bubble tail
      path.moveTo(0, 0);
      path.lineTo(0, 20);
      path.lineTo(12, 20);
      path.quadraticBezierTo(4, 16, 0, 0);
      path.close();
    } else {
      // Left side bubble tail
      path.moveTo(12, 0);
      path.lineTo(12, 20);
      path.lineTo(0, 20);
      path.quadraticBezierTo(8, 16, 12, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'Write a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.card,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.card,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.card,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.greyBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: PopupMenuButton<String>(
                color: AppColors.white,
                icon: SvgPicture.asset("assets/svg/clip.svg"),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'photo',
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svg/picture.svg"),
                        kSizedBoxWidthSM,
                        const Text('Photo or video'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svg/camera.svg"),
                        kSizedBoxWidthSM,
                        const Text('Camera'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'file',
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svg/file.svg"),
                        kSizedBoxWidthSM,
                        const Text('File'),
                      ],
                    ),
                  ),
                ],
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset("assets/svg/emoji.svg"),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset("assets/svg/record.svg"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
