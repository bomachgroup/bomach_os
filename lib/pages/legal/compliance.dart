import 'package:bms_front_end/components/button/my_elevated_button.dart'
    show MyElevatedButton;
import 'package:bms_front_end/pages/legal/widgets/compliance_item_card.dart';
import 'package:flutter/material.dart';

import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/constants/spaces.dart';

class CompliancePageView extends StatelessWidget {
  const CompliancePageView({super.key});

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
                      const Text('Compliance Management',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      const Text(
                          'Track regulatory and legal compliance requirements',
                          style:
                              TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'Search compliance...',
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
                          Text('Compliance Management',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          MyText(
                              'Track regulatory and legal compliance requirements',
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
                                hintText: 'Search compliance...',
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
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  ComplianceItemCard(
                    actionsCompleted: '0%',
                    footerNote:
                        'Action Completion: Maintain current COREN registration for engineering staff.',
                    title: 'COREN Professional Registration',
                    authority:
                        'Council for the Regulation of Engineering in Nigeria (COREN)',
                    statusLabel: 'Compliant',
                    statusColor: Colors.black,
                    reviewStatus: 'Review 214 days overdue',
                    reviewColor: Colors.red,
                    complianceLabel: 'Regulatory',
                    levelLabel: 'Medium',
                    category: 'Data Protection',
                    requirements: '4',
                    lastReview: '10 Jan 2025',
                    nextReview: '10 Jan 2025',
                    actions: '2 open',
                  ),
                  ComplianceItemCard(
                    actionsCompleted: '0%',
                    footerNote:
                        'Action Completion: Maintain current COREN registration for engineering staff.',
                    title: 'Data Protection Compliance',
                    authority:
                        'National Information Technology Development Agency (NITDA)',
                    statusLabel: 'Partially Compliant',
                    statusColor: Colors.orange,
                    reviewStatus: 'Review 494 days overdue',
                    reviewColor: Colors.red,
                    complianceLabel: 'Legal',
                    levelLabel: 'High',
                    category: 'Data Protection',
                    requirements: '4',
                    lastReview: '10 Jan 2025',
                    nextReview: '10 Jan 2025',
                    actions: '2 open',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
