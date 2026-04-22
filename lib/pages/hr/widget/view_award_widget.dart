import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/awards_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/awards_controller.dart';
import 'add_award_widget.dart';

class ViewAwardDialog extends StatelessWidget {
  final Award award;
  final String token;

  const ViewAwardDialog({
    super.key,
    required this.award,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final AwardsController controller = Get.find();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.neutral200, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MyText(award.title, size: 20, weight: 600),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Category', award.category),
                    const SizedBox(height: 12),
                    _buildInfoRow('Rank / Level', award.rankLevel),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Date Awarded',
                        award.dateAwarded != null
                            ? DateFormat('MMMM dd, yyyy')
                                .format(award.dateAwarded!)
                            : 'N/A'),
                    const Divider(height: 32),
                    const MyText('Description',
                        size: 14, weight: 600, color: Colors.grey),
                    const SizedBox(height: 8),
                    MyText(award.description, size: 16),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.danger,
                      child: 'Delete',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Delete Award"),
                            content: const Text("Are you sure?"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text("No")),
                              TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text("Yes")),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await controller.deleteAward(token, award.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            AppToast.error(context, 'Award Deleted');
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    MyElevatedButton(
                      icon: SvgPicture.asset("assets/svg/edit-pencil.svg",
                          colorFilter: const ColorFilter.mode(
                              AppColors.white, BlendMode.srcIn)),
                      child: 'Edit',
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (c) =>
                              AddAwardDialog(token: token, awardToEdit: award),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: MyText(label,
              size: 14, weight: 400, color: AppColors.neutral500),
        ),
        Expanded(
          child: MyText(value, size: 14, weight: 500),
        ),
      ],
    );
  }
}
