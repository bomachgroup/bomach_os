import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/widget/edit_company_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyController controller = Get.put(CompanyController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Company Profile',
          style: AppText.black_600_32,
        ),
        kSizedBox,

        // const Row(
        //   children: [
        //     Expanded(
        //       child: StatsCard(
        //         number: '452',
        //         label: 'Assets',
        //         subtitle: '2 new assets added!',
        //         icon: Icons.people_outline,
        //         subtitleColor: Colors.green,
        //       ),
        //     ),
        //     SizedBox(width: 16),
        //     Expanded(
        //       child: StatsCard(
        //         number: '20',
        //         label: 'Active Branches',
        //         subtitle: '2 new Branches added!',
        //         icon: Icons.account_tree_outlined,
        //         subtitleColor: Colors.green,
        //       ),
        //     ),
        //   ],
        // ),

        // const SizedBox(height: 24),

        // Card(
        //   color: AppColors.white,
        //   elevation: 2,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: const Padding(
        //     padding: EdgeInsets.all(20),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           'Recent Activity',
        //           style: TextStyle(
        //             fontSize: 18,
        //             fontWeight: FontWeight.w600,
        //             color: Color(0xFF1A202C),
        //           ),
        //         ),
        //         SizedBox(height: 16),
        //         ActivityItem(
        //           name: 'Karen',
        //           action: 'leave some comments on',
        //           target: 'Konsep Ilustrasi',
        //           date: 'Aug 10',
        //           color: Colors.green,
        //         ),
        //         // ... you can add more items here
        //       ],
        //     ),
        //   ),
        // ),

        // const SizedBox(height: 24),

        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.hasError.value ||
              controller.companySettings.value == null) {
            return Center(
              child: Column(
                children: [
                  const Text("Failed to load company profile"),
                  TextButton(
                      onPressed: controller.fetchCompanyProfile,
                      child: const Text("Retry"))
                ],
              ),
            );
          }

          final data = controller.companySettings.value!;

          return Card(
            color: AppColors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                            Text(
                              data.companyName, // DYNAMIC
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A202C),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            MyElevatedButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.white,
                              ),
                              child: 'Edit Profile',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const EditCompanyDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Logo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          // Check if logo URL exists, else show asset
                          child: data.companyLogo != null &&
                                  data.companyLogo!.isNotEmpty
                              ? Image.network(
                                  data.companyLogo!,
                                  height: 80,
                                  width: 80,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset("assets/logo/bomach.png",
                                          height: 80),
                                )
                              : Image.asset(
                                  "assets/logo/bomach.png",
                                  height: 80,
                                  width: 80,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Name',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            data.companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CompanyDetailItem(
                    label: 'Company Email',
                    value: data.companyEmail,
                  ),
                  CompanyDetailItem(
                    label: 'Company Phone',
                    value: data.companyPhone,
                  ),
                  CompanyDetailItem(
                    label: 'Company Addresses',
                    value: data.companyAddresses,
                  ),
                  CompanyDetailItem(
                    label: 'RC Number',
                    value: data.rcNumber,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Primary Color Code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    // Use Controller helper to parse hex
                                    color: controller
                                        .getColorFromHex(data.primaryColorCode),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  data.primaryColorCode,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Secondary Color Code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    // Use Controller helper to parse hex
                                    color: controller.getColorFromHex(
                                        data.secondaryColorCode),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  data.secondaryColorCode,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CompanyDetailItem(
                          label: 'Default Currency',
                          value: data.defaultCurrency,
                        ),
                      ),
                      Expanded(
                        child: CompanyDetailItem(
                          label: 'Language Preference',
                          value: data.languagePreference,
                        ),
                      ),
                    ],
                  ),
                  CompanyDetailItem(
                    label: 'Business Rules',
                    value: data.businessRules,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color subtitleColor;

  const StatsCard({
    super.key,
    required this.number,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                Icon(
                  icon,
                  color: const Color(0xFF3B82F6),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: subtitleColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String target;
  final String date;
  final Color color;

  const ActivityItem({
    super.key,
    required this.name,
    required this.action,
    required this.target,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A202C),
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' $action '),
                      TextSpan(
                        text: target,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const CompanyDetailItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }
}
