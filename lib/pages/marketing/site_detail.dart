import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/text/row_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/pages/marketing/widget/detail_page_layout.dart';
import 'package:flutter/material.dart';

class SiteDetailPage extends StatelessWidget {
  const SiteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPageLayout(
      title: 'Port Harcourt Industrial Site Office',
      subtitle: 'Created 3/10/2024',
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
          RowText(label: "Site Name", value: "Port Harcourt Industrial Site Office"),
          RowText(label: "Worksite Number", value: "WS-003"),
          RowText(
              label: "Location",
              value: "Trans-Amadi Industrial Layout, Port Harcourt"),
          RowText(label: "Status", value: "qualified"),
          RowText(
              label: "Notes", value: "Interested in land survey services"),
        ],
      ),
    );
  }
}
