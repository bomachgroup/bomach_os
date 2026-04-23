import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/auth/controller.dart';
import 'package:bms_front_end/pages/dashboad/widget/edit_profile_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';

class UserProfileDialog extends StatelessWidget {
  final User user;
  const UserProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText("My Profile",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),

            // 2. Profile Image & Primary Info
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        image: (user.profilePicture != null &&
                                user.profilePicture!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(user.profilePicture!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: (user.profilePicture == null ||
                              user.profilePicture!.isEmpty)
                          ? const Icon(Iconsax.profile_circle,
                              size: 40, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    MyText("${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    MyText(user.email, color: Colors.grey),
                    const SizedBox(height: 24),

                    // 3. Detailed Information Grid
                    _buildSectionHeader("Personal Information"),
                    _buildDetailItem("Username", user.username),
                    _buildDetailItem("Phone", user.phoneNumber),
                    _buildDetailItem("Gender", user.gender),
                    _buildDetailItem("Marital Status", user.maritalStatus),
                    _buildDetailItem("Date of Birth", user.dateOfBirth),
                    _buildDetailItem("Address", user.address),

                    const SizedBox(height: 16),

                    // Employment Information
                    _buildSectionHeader("Employment Details"),
                    _buildDetailItem("Employee ID", user.employeeId),
                    _buildDetailItem("Employment Type", user.employmentType),
                    _buildDetailItem("Branch ID", user.branchId.toString()),
                    _buildDetailItem(
                        "Department ID", user.departmentId.toString()),
                    _buildDetailItem("Level ID", user.levelId.toString()),
                    _buildDetailItem("Start Date", user.startDate),

                    const SizedBox(height: 16),

                    // System Status
                    _buildSectionHeader("System Status"),
                    _buildStatusRow("Verified", user.isVerified),
                    _buildStatusRow("Active", user.isActive),

                    const SizedBox(height: 16),

                    // Security Settings
                    _buildSectionHeader("Security Settings"),
                    Obx(() {
                      final authController = Get.find<AuthController>();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const MyText('Two-Factor Authentication',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral800)),
                                const SizedBox(height: 2),
                                MyText(
                                    authController.is2FaEnabled.value
                                        ? 'Your account is secured with 2FA'
                                        : 'Enable 2FA for extra security',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.neutral400)),
                              ],
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: authController.is2FaEnabled.value,
                                activeTrackColor: AppColors.success,
                                onChanged: (val) {
                                  authController.toggle2Fa(context, val);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // 4. Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => EditProfileDialog(user: user),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Iconsax.edit, size: 16),
                    label: const Text("Edit Profile"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.find<AuthController>().logout().then((_) => context.go(RouteConstants.login));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Log Out"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              (value != null && value.isNotEmpty) ? value : "N/A",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4)),
            child: Text(
              isActive ? "Yes" : "No",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green : Colors.red),
            ),
          )
        ],
      ),
    );
  }
}
