import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/dashboad/widget/edit_profile_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../pages/auth/controller.dart';
import '../../src/model/user_model.dart'; // Import your specific model

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      color: AppColors.white,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburger Menu (Small Screens)
          if (!isLargeScreen(context)) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
            ),
            kSizedBoxWidth,
          ],

          const Spacer(),

          // Notification Icon
          if (!isSmallScreen(context))
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset("assets/svg/notification.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            ),

          kSizedBoxWidth,

          // --- USER PROFILE WIDGET ---
          Obx(() {
            final User? user = authController.currentUser.value;

            // Fallbacks for loading state
            final String name = user != null
                ? "${user.firstName} ${user.lastName}"
                : "Loading...";

            // Using 'employmentType' as role/subtitle since 'role' field is missing in model
            final String subtitle = user?.employmentType ?? "Employee";
            final String? image = user?.profilePicture;

            return InkWell(
              onTap: () {
                if (user != null) {
                  showDialog(
                    context: context,
                    builder: (c) => UserProfileDialog(user: user),
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        image: (image != null && image.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(image), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (image == null || image.isEmpty)
                          ? const Icon(Icons.person, color: AppColors.blue)
                          : null,
                    ),

                    const SizedBox(width: 10),

                    // Name & Subtitle (Hidden on small screens)
                    if (!isSmallScreen(context))
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            name,
                            style: AppText.black_600_14,
                            maxLines: 1,
                          ),
                          MyText(
                            subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                          ),
                        ],
                      ),

                    if (!isSmallScreen(context)) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ]
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// --- FULL USER DETAILS DIALOG ---
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
                    icon: const Icon(Icons.close),
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
                        color: AppColors.blue.withValues(alpha: 0.1),
                        image: (user.profilePicture != null &&
                                user.profilePicture!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(user.profilePicture!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: (user.profilePicture == null ||
                              user.profilePicture!.isEmpty)
                          ? const Icon(Icons.person,
                              size: 40, color: AppColors.blue)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    MyText("${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    MyText(user.email, color: Colors.grey),
                    const SizedBox(height: 24),

                    // 3. Detailed Information Grid
                    // Personal Information
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
                                        color: Color(0xFF1E293B))),
                                const SizedBox(height: 2),
                                MyText(
                                    authController.is2FaEnabled.value
                                        ? 'Your account is secured with 2FA'
                                        : 'Enable 2FA for extra security',
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF94A3B8))),
                              ],
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: authController.is2FaEnabled.value,
                                activeTrackColor: const Color(0xFF10B981),
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
                      foregroundColor: AppColors.blue,
                      side: const BorderSide(color: AppColors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Edit Profile"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.find<AuthController>().logout();
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
              fontWeight: FontWeight.w600, color: AppColors.blue)),
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
