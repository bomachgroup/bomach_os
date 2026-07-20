import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/text/row_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/pages/marketing/widget/detail_page_layout.dart';
import 'package:flutter/material.dart';

class CampaignDetailPage extends StatelessWidget {
  const CampaignDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPageLayout(
      title: 'PQ1 Land Survey Awareness',
      subtitle: 'Created 8/15/2023',
      actions: [
        MyElevatedButton(
          child: 'Edit',
          onTap: () {},
        ),
        MyElevatedButton(
          bgColor: AppColors.danger,
          child: 'Delete',
          onTap: () {},
        ),
      ],
      child: const Column(
        children: [
          RowText(label: "Campaign Number", value: "CAM-001"),
          RowText(label: "Campaign Name", value: "Q1 Land Survey Awareness"),
          RowText(label: "Type", value: "Social Media"),
          RowText(label: "Status", value: "Active"),
          RowText(label: "Budget (NGN)", value: "₦500,000.00"),
          RowText(label: "Start Date", value: "9/1/2023"),
          RowText(label: "End Date", value: "1/31/2024"),
          RowText(
              label: "Target Audience", value: "Property developers in Lagos"),
        ],
      ),
    );
  }
}
