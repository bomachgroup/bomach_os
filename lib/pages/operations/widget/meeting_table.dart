import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

class MeetingTable extends StatefulWidget {
  const MeetingTable({super.key});

  @override
  State<MeetingTable> createState() => _MeetingTableState();
}

class _MeetingTableState extends State<MeetingTable> {
  final ScrollController _scrollController = ScrollController();

  int _pageSize = 10;
  int _currentPage = 1;

  // Mock dataset — replace with controller when wired up.
  static const _totalMeetings = 10;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Meeting Log', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalMeetings recorded meetings with agendas and attendees',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Minutes',
                  tone: StatusTone.primary,
                  icon: Iconsax.calendar_1,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          _buildTable(),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: PaginatorFooter(
              totalItems: _totalMeetings,
              limit: _pageSize,
              currentPage: _currentPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
              onLimitChanged: (newLimit) => setState(() {
                _pageSize = newLimit;
                _currentPage = 1;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            List.generate(_totalMeetings, (index) => _buildMobileCard(index)),
      ),
    );
  }

  Widget _buildMobileCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.brLg,
          onTap: () => showDialog(
            context: context,
            builder: (_) => const MeetingViewDialog(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${(index + 1).toString().padLeft(3, '0')}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    StatusChip(
                      label: index.isEven ? 'Completed' : 'Scheduled',
                      tone: index.isEven
                          ? StatusTone.success
                          : StatusTone.primary,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'O2 Arena Estate Dev',
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('02-02-2025', style: AppTextStyles.bodySm),
                    Text('Offline', style: AppTextStyles.bodySm),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.people,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('23 Attendees',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.document,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('2 Files',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppRadii.brSm,
                        onTapDown: (details) async {
                          await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                            ),
                            items: const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'cancel', child: Text('Cancel')),
                            ],
                          );
                          // Handle menu selection here
                        },
                        onTap: () {},
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.brSm,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Icon(Iconsax.more,
                              size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog showing a meeting's info panel and the suggestions/comments thread.
class MeetingViewDialog extends StatefulWidget {
  const MeetingViewDialog({super.key});

  @override
  MeetingViewDialogState createState() => MeetingViewDialogState();
}

class MeetingViewDialogState extends State<MeetingViewDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'O2 Arena Estate Dev',
      subtitle: 'Meeting details, attendees, files and discussion',
      size: DialogSize.lg,
      bodyPadding: const EdgeInsets.all(20),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _IconActionButton(
                icon: Iconsax.add,
                tooltip: 'Add entry',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Iconsax.note_2,
                tooltip: 'Notes',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Iconsax.notification,
                tooltip: 'Notify attendees',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const MeetingInfoCard(),
          const SizedBox(height: 16),
          const SuggestionsAndComments(),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.brMd,
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, size: 18, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class SuggestionsAndComments extends StatelessWidget {
  const SuggestionsAndComments({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.messages_2, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Suggestions and comments', style: AppTextStyles.h4),
            ],
          ),
          SizedBox(height: 12),
          MessageBubble(
            message: '@janeagbo she talk up the function of a program manager.',
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
          SizedBox(height: 12),
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
    final bubbleColor = isMe ? AppColors.primary : AppColors.surfaceMuted;
    final textColor = isMe ? AppColors.white : AppColors.textPrimary;
    final timeColor =
        isMe ? AppColors.white.withValues(alpha: 0.8) : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) CurvedBackground(isMe: isMe),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isMe ? 14 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.bodyMd.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: timeColor,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/svg/two-checks.svg',
                            height: 12,
                            width: 12,
                            colorFilter: ColorFilter.mode(
                              timeColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
      ..color = isMe ? AppColors.primary : AppColors.surfaceMuted
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..isAntiAlias = true;

    final path = Path();

    if (isMe) {
      // Right-side bubble tail
      path.moveTo(0, 0);
      path.lineTo(0, 20);
      path.lineTo(12, 20);
      path.quadraticBezierTo(4, 16, 0, 0);
      path.close();
    } else {
      // Left-side bubble tail
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
    return TextField(
      cursorColor: AppColors.primary,
      style: AppTextStyles.bodyMd,
      minLines: 1,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Write a message...',
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.brPill,
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brPill,
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brPill,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        prefixIcon: PopupMenuButton<String>(
          color: AppColors.surface,
          icon: const Icon(Iconsax.attach_square,
              size: 18, color: AppColors.textMuted),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'photo',
              child: Row(
                children: [
                  Icon(Iconsax.gallery, size: 16),
                  SizedBox(width: 10),
                  Text('Photo or video'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'camera',
              child: Row(
                children: [
                  Icon(Iconsax.camera, size: 16),
                  SizedBox(width: 10),
                  Text('Camera'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'file',
              child: Row(
                children: [
                  Icon(Iconsax.document, size: 16),
                  SizedBox(width: 10),
                  Text('File'),
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
              icon: const Icon(Iconsax.emoji_happy,
                  size: 18, color: AppColors.textMuted),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.microphone,
                  size: 18, color: AppColors.textMuted),
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
      {'label': 'Date / Time', 'value': '9am, 23-07-2024'},
      {'label': 'Location', 'value': 'Offline'},
      {'label': 'Address', 'value': 'Amadeo event center Enugu, Nigeria'},
      {'label': 'Attendance', 'value': '23 members'},
      {'label': 'Meeting files', 'value': '23 files'},
      {'label': 'Adjourned', 'value': 'Mrs. Jane Okoro'},
      {'label': 'End time', 'value': '3:30 PM'},
    ];

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.info_circle, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Meeting Info', style: AppTextStyles.h4),
              Spacer(),
              StatusChip(
                label: 'Completed',
                tone: StatusTone.success,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: infoItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      infoItems[index]['label']!,
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      infoItems[index]['value']!,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Meeting files', style: AppTextStyles.overline),
          const SizedBox(height: 12),
          const Row(
            children: [
              _FilePill(
                icon: Iconsax.document_text,
                label: '3 files',
              ),
              SizedBox(width: 12),
              _FilePill(
                icon: Iconsax.task_square,
                label: '3 files',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FilePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
