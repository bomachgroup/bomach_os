import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  const EmployeeDirectoryPage({super.key});

  @override
  State<EmployeeDirectoryPage> createState() => _EmployeeDirectoryPageState();
}

class _EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Employee Directory',
                style: AppText.black_600_32,
              ),
              SizedBox(height: 8),
              MyText(
                'Complete list of all employees',
                style: AppText.black_600_14,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              MyElevatedButton(
                child: 'Add Employee',
                onTap: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.grey7),
                      ),
                    ),
                    child: const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: MyText(
                              'Name',
                              style: AppText.black_600_14,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 150,
                            child: MyText(
                              'Department',
                              style: AppText.black_600_14,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 150,
                            child: MyText(
                              'Position',
                              style: AppText.black_600_14,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: MyText(
                              'Status',
                              style: AppText.black_600_14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Empty State
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: AppColors.grey4,
                          ),
                          SizedBox(height: 16),
                          MyText(
                            'No employees found',
                            style: AppText.black_400_14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
