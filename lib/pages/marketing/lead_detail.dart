import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/text/row_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/pages/marketing/widget/detail_page_layout.dart';
import 'package:flutter/material.dart';

class LeadDetailPage extends StatelessWidget {
  const LeadDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPageLayout(
      title: 'Adebayo Johnson',
      subtitle: 'Created 28-01-2025',
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
          RowText(label: "Lead Number", value: "LEAD-001"),
          RowText(label: "Full Name", value: "Adebayo Johnson"),
          RowText(label: "Email", value: "adebayo.johnson@example.com"),
          RowText(label: "Phone", value: "+234 803 123 4567"),
          RowText(label: "Company", value: "Johnson Properties Ltd"),
          RowText(label: "Source", value: "LinkedIn"),
          RowText(label: "Status", value: "qualified"),
          RowText(label: "Lead Score", value: "85"),
          RowText(label: "Notes", value: "Interested in land survey services"),
        ],
      ),
    );
  }
}
