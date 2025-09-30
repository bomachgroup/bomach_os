import 'package:flutter/material.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/constants/spaces.dart';
import 'widgets/status_tag.dart';

class ContractsPageView extends StatelessWidget {
  const ContractsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contract Management",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      const Text(
                          "Manage contracts, agreements, and legal documents",
                          style:
                              TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'Search for contracts...',
                              leading: Icon(
                                Icons.search,
                                color: AppColors.grey1.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MyElevatedButton(
                            child: 'Filter',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contract Management",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          MyText(
                              "Manage contracts, agreements, and legal documents",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 250,
                              child: MyTextFormField(
                                hintText: 'Search for contracts...',
                                leading: Icon(
                                  Icons.search,
                                  color: AppColors.grey1.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            MyElevatedButton(
                              child: 'Filter',
                              onTap: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
            kSizedBoxBG,
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return ContractsCard(isMobile: isMobile);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ContractsCard extends StatelessWidget {
  final bool isMobile;
  const ContractsCard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(
                    "Land Survey Services Agreement - ABC Construction",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      StatusTag(text: "Active", color: Colors.black),
                      SizedBox(width: 8),
                      StatusTag(text: "Service Agreement", color: Colors.grey),
                      SizedBox(width: 8),
                      StatusTag(text: "High", color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Contract No: CTR-2024-001"),
                  const Text("Value: ₦2,500,000.00"),
                  const Text("Parties: 1"),
                  const SizedBox(height: 8),
                  const Text(
                    "Created: 17 Aug 2025  •  Lawyer: Legal Manager  •  Deliverables: 3",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text("Effective: 1 Jan 2024"),
                  const Text("Expires: 31 Dec 2024"),
                  const Text("Payment Terms: Net 30 days"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            color: Colors.black),
                        label: const Text("View",
                            style: TextStyle(color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.black),
                        label: const Text("Edit",
                            style: TextStyle(color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  const Row(
                    children: [
                      MyText(
                          "Land Survey Services Agreement - ABC Construction",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      StatusTag(text: "Active", color: Colors.black),
                      SizedBox(width: 8),
                      StatusTag(text: "Service Agreement", color: Colors.grey),
                      SizedBox(width: 8),
                      StatusTag(text: "High", color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Contract No: CTR-2024-001"),
                            Text("Value: ₦2,500,000.00"),
                            Text("Parties: 1"),
                            SizedBox(height: 8),
                            Text(
                                "Created: 17 Aug 2025  •  Lawyer: Legal Manager  •  Deliverables: 3",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Effective: 1 Jan 2024"),
                            Text("Expires: 31 Dec 2024"),
                            Text("Payment Terms: Net 30 days"),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.remove_red_eye_outlined,
                                  color: Colors.black),
                              label: const Text("View",
                                  style: TextStyle(color: Colors.black)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.black),
                              label: const Text("Edit",
                                  style: TextStyle(color: Colors.black)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
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
