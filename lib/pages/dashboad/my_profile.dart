import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/auth/controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;

      if (user == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_off_rounded,
                    size: 48, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              const MyText('Profile not available',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              const MyText('Please log in to view your profile',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            _buildAccountInfoCard(user),
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
                    _buildAccountInfoCard(user),
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
          colors: [Color(0xFF0055FF), Color(0xFF1A3FCC), Color(0xFF0D2B99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0055FF).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: user.profilePicture != null &&
                    user.profilePicture!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      user.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarText(fullName),
                    ),
                  )
                : _buildAvatarText(fullName),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  fullName.isNotEmpty ? fullName : user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                if (user.employeeId != null && user.employeeId!.isNotEmpty)
                  MyText(
                    user.employeeId!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildHeaderChip(
                      icon: Icons.circle,
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
                        icon: Icons.work_outline_rounded,
                        iconSize: 14,
                        label: user.employmentType!,
                        color: Colors.white.withValues(alpha: 0.8),
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
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  // ── Personal Information ──────────────────────────────────────────────
  Widget _buildPersonalInfoCard(User user) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_rounded,
      color: const Color(0xFF6366F1),
      children: [
        _buildFieldRow(
          [
            _ProfileField('First Name', user.firstName),
            _ProfileField('Last Name', user.lastName),
          ],
        ),
        _buildFieldRow(
          [
            _ProfileField('Employee ID', user.employeeId ?? 'N/A'),
            _ProfileField('Date of Birth', _formatDate(user.dateOfBirth)),
          ],
        ),
        _buildFieldRow(
          [
            _ProfileField('Gender', _capitalize(user.gender)),
            _ProfileField('Marital Status', _capitalize(user.maritalStatus)),
          ],
        ),
      ],
    );
  }

  // ── Contact Information ───────────────────────────────────────────────
  Widget _buildContactInfoCard(User user) {
    return _buildSectionCard(
      title: 'Contact Information',
      icon: Icons.contact_mail_rounded,
      color: const Color(0xFF0EA5E9),
      children: [
        _buildInfoTile(Icons.email_rounded, 'Email Address', user.email,
            const Color(0xFFEF4444)),
        const SizedBox(height: 12),
        _buildInfoTile(
            Icons.phone_rounded,
            'Phone Number',
            user.phoneNumber != null && user.phoneNumber!.isNotEmpty
                ? user.phoneNumber!
                : 'Not provided',
            const Color(0xFF10B981)),
        const SizedBox(height: 12),
        _buildInfoTile(
            Icons.location_on_rounded,
            'Address',
            user.address != null && user.address!.isNotEmpty
                ? user.address!
                : 'Not provided',
            const Color(0xFFF59E0B)),
      ],
    );
  }

  // ── Employment ────────────────────────────────────────────────────────
  Widget _buildEmploymentCard(User user) {
    return _buildSectionCard(
      title: 'Employment',
      icon: Icons.business_center_rounded,
      color: const Color(0xFF10B981),
      children: [
        _buildFieldRow(
          [
            _ProfileField('Employment Type', _capitalize(user.employmentType)),
            _ProfileField('Branch ID', '${user.branchId}'),
          ],
        ),
        _buildFieldRow(
          [
            _ProfileField('Department ID', '${user.departmentId}'),
            _ProfileField('Level ID', '${user.levelId}'),
          ],
        ),
        _buildFieldRow(
          [
            _ProfileField('Start Date', _formatDate(user.startDate)),
            _ProfileField('Status', user.isActive ? 'Active' : 'Inactive',
                valueColor: user.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444)),
          ],
        ),
      ],
    );
  }

  // ── Account Info ──────────────────────────────────────────────────────
  Widget _buildAccountInfoCard(User user) {
    return _buildSectionCard(
      title: 'Account Information',
      icon: Icons.shield_rounded,
      color: const Color(0xFFF59E0B),
      children: [
        _buildFieldRow(
          [
            _ProfileField('Username', user.username),
            _ProfileField('Verified', user.isVerified ? 'Yes' : 'No',
                valueColor: user.isVerified
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444)),
          ],
        ),
        _buildFieldRow(
          [
            _ProfileField('User ID', '${user.userId}'),
            _ProfileField('Created', _formatDate(user.createdAt)),
          ],
        ),
      ],
    );
  }

  // ── Shared Builders ───────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              MyText(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
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
                MyText(field.label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                MyText(
                  field.value.isNotEmpty ? field.value : 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: field.valueColor ?? const Color(0xFF1E293B),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              MyText(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
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

  _ProfileField(this.label, this.value, {this.valueColor});
}
