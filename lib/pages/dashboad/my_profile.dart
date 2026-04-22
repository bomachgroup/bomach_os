import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/auth/controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  static const _accentIndigo = Color(0xFF6366F1);
  static const _accentCyan = AppColors.info;
  static const _accentAmber = AppColors.warning;
  static const _accentGreen = AppColors.success;
  static const _accentRed = AppColors.danger;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;

      if (user == null) {
        return const Center(
          child: EmptyState(
            title: 'Profile not available',
            subtitle: 'Please log in to view your profile',
            icon: Iconsax.user_remove,
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'My Profile',
              subtitle:
                  'Your personal information and employment details',
            ),
            const SizedBox(height: 16),
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildPersonalInfoCard(user),
                            const SizedBox(height: 20),
                            _buildContactInfoCard(user),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildEmploymentCard(user),
                            const SizedBox(height: 20),
                            _buildAccountInfoCard(context, user, authController),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildPersonalInfoCard(user),
                    const SizedBox(height: 20),
                    _buildContactInfoCard(user),
                    const SizedBox(height: 20),
                    _buildEmploymentCard(user),
                    const SizedBox(height: 20),
                    _buildAccountInfoCard(context, user, authController),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  // ── Profile Header ────────────────────────────────────────────────────
  Widget _buildProfileHeader(User user) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryPressed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: AppRadii.brLg,
              border: Border.all(
                color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: user.profilePicture != null &&
                    user.profilePicture!.isNotEmpty
                ? ClipRRect(
                    borderRadius: AppRadii.brMd,
                    child: Image.network(
                      user.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarText(fullName),
                    ),
                  )
                : _buildAvatarText(fullName),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  fullName.isNotEmpty ? fullName : user.username,
                  style: AppText.h1.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                if (user.employeeId != null && user.employeeId!.isNotEmpty)
                  MyText(
                    user.employeeId!,
                    style: AppText.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildHeaderChip(
                      icon: Iconsax.record_circle,
                      iconSize: 8,
                      label: user.isActive ? 'Active' : 'Inactive',
                      color: user.isActive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFFCA5A5),
                    ),
                    const SizedBox(width: 10),
                    if (user.employmentType != null &&
                        user.employmentType!.isNotEmpty)
                      _buildHeaderChip(
                        icon: Iconsax.briefcase,
                        iconSize: 14,
                        label: user.employmentType!,
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.8),
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

  Widget _buildAvatarText(String name) {
    return Center(
      child: Text(
        _getInitials(name),
        style: AppText.displayMd.copyWith(
          fontSize: 28,
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required double iconSize,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.12),
        borderRadius: AppRadii.brPill,
        border:
            Border.all(color: AppColors.textOnPrimary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(User user) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Iconsax.user,
      color: _accentIndigo,
      children: [
        _buildFieldRow([
          _ProfileField('First Name', user.firstName),
          _ProfileField('Last Name', user.lastName),
        ]),
        _buildFieldRow([
          _ProfileField('Employee ID', user.employeeId ?? 'N/A'),
          _ProfileField('Date of Birth', _formatDate(user.dateOfBirth)),
        ]),
        _buildFieldRow([
          _ProfileField('Gender', _capitalize(user.gender)),
          _ProfileField('Marital Status', _capitalize(user.maritalStatus)),
        ]),
      ],
    );
  }

  Widget _buildContactInfoCard(User user) {
    return _buildSectionCard(
      title: 'Contact Information',
      icon: Iconsax.sms,
      color: _accentCyan,
      children: [
        _buildInfoTile(
            Iconsax.sms, 'Email Address', user.email, _accentRed),
        const SizedBox(height: 12),
        _buildInfoTile(
            Iconsax.call,
            'Phone Number',
            user.phoneNumber != null && user.phoneNumber!.isNotEmpty
                ? user.phoneNumber!
                : 'Not provided',
            _accentGreen),
        const SizedBox(height: 12),
        _buildInfoTile(
            Iconsax.location,
            'Address',
            user.address != null && user.address!.isNotEmpty
                ? user.address!
                : 'Not provided',
            _accentAmber),
      ],
    );
  }

  Widget _buildEmploymentCard(User user) {
    return _buildSectionCard(
      title: 'Employment',
      icon: Iconsax.briefcase,
      color: _accentGreen,
      children: [
        _buildFieldRow([
          _ProfileField('Employment Type', _capitalize(user.employmentType)),
          _ProfileField('Branch ID', '${user.branchId}'),
        ]),
        _buildFieldRow([
          _ProfileField('Department ID', '${user.departmentId}'),
          _ProfileField('Level ID', '${user.levelId}'),
        ]),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Start Date',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      _formatDate(user.startDate),
                      style: AppText.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Status',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusChip(
                      label: user.isActive ? 'Active' : 'Inactive',
                      tone: user.isActive
                          ? StatusTone.success
                          : StatusTone.danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(
      BuildContext context, User user, AuthController authController) {
    return _buildSectionCard(
      title: 'Account Information',
      icon: Iconsax.shield_tick,
      color: _accentAmber,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Username',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      user.username,
                      style: AppText.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Verified',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusChip(
                      label: user.isVerified ? 'Yes' : 'No',
                      tone: user.isVerified
                          ? StatusTone.success
                          : StatusTone.danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildFieldRow([
          _ProfileField('User ID', '${user.userId}'),
          _ProfileField('Created', _formatDate(user.createdAt)),
        ]),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              MyText(
                title,
                style: AppText.h4.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldRow(List<_ProfileField> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: fields.map((field) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  field.label,
                  style: AppText.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                MyText(
                  field.value.isNotEmpty ? field.value : 'N/A',
                  style: AppText.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: field.valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadii.brMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                label,
                style: AppText.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              MyText(
                value,
                style: AppText.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

class _ProfileField {
  final String label;
  final String value;
  final Color? valueColor;

  _ProfileField(this.label, this.value) : valueColor = null;
}
