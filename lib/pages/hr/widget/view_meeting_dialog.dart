import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/meeting_model.dart';

class ViewMeetingDialog extends StatelessWidget {
  final Meeting meeting;

  const ViewMeetingDialog({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: meeting.title,
      subtitle: meeting.agenda.isNotEmpty ? meeting.agenda : 'Meeting details',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(meeting),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Meeting Information',
            children: [
              _detailRow('Date', meeting.meetingDate.isNotEmpty ? meeting.meetingDate : '—'),
              _detailRow('Time', meeting.meetingTime.isNotEmpty ? _formatTime(meeting.meetingTime) : '—'),
              _detailRow('Duration', meeting.durationDisplay.isNotEmpty ? meeting.durationDisplay : '${meeting.durationMinutes} min'),
              _detailRow('Location Type', meeting.locationTypeDisplay.isNotEmpty ? meeting.locationTypeDisplay : meeting.locationType),
              _detailRow('Location', meeting.location?.isNotEmpty == true ? meeting.location! : '—'),
              _detailRow('Organizer', meeting.organizerName?.isNotEmpty == true ? meeting.organizerName! : '—'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Agenda',
            children: [
              Text(
                meeting.agenda.isNotEmpty ? meeting.agenda : 'No agenda provided',
                style: AppTextStyles.bodyMd,
              ),
            ],
          ),
          if (meeting.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notes',
              children: [
                Text(
                  meeting.notes!,
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          ],
          if (meeting.attendees.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Attendees (${meeting.attendees.length})',
              children: [
                ...meeting.attendees.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: AppRadii.brPill,
                        ),
                        child: Center(
                          child: Text(
                            a.fullName.isNotEmpty ? a.fullName[0].toUpperCase() : '?',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.fullName,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (a.email.isNotEmpty)
                              Text(
                                a.email,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Close',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(Meeting m) {
    final statusLabel = m.statusDisplay.isNotEmpty ? m.statusDisplay : m.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.calendar_1, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: statusLabel,
                      tone: _statusTone(m.status),
                      icon: Iconsax.record_circle,
                    ),
                    _metaChip(
                      icon: Iconsax.people,
                      label: '${m.attendeeCount} attendee${m.attendeeCount == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '—';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return StatusTone.primary;
      case 'ongoing':
      case 'in_progress':
        return StatusTone.warning;
      case 'completed':
        return StatusTone.success;
      case 'cancelled':
        return StatusTone.danger;
      case 'postponed':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
