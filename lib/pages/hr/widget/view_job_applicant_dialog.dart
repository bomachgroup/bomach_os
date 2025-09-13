import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/file_view_download.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewJobPostDialog extends StatefulWidget {
  const ViewJobPostDialog({super.key});

  @override
  State<ViewJobPostDialog> createState() => _ViewJobPostDialogState();
}

class _ViewJobPostDialogState extends State<ViewJobPostDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),

        // width: MediaQuery.of(context).size.width * 0.9,
        // height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'John Michael',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E5E5)),

            // Scrollable Content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Job ID', 'JKJS2ww'),
                      _buildDetailRow('Job Title', 'Operations Manager'),
                      _buildDetailRow('First Name', 'John'),
                      _buildDetailRow('Last Name', 'Ben'),
                      _buildDetailRow('Email', 'johnben@gmail.com'),
                      _buildDetailRow('Phone', '+234 812 365 4789'),

                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: MyText(
                              "Uploaded Resume",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: FileViewDownloadCard(
                              fileName: 'John Michael Resume',
                              fileType: 'PDF',
                              fileSize: '0.23KB',
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: MyText(
                              "Uploaded Cover Letter",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: FileViewDownloadCard(
                              fileName: 'John Michael Resume',
                              fileType: 'PDF',
                              fileSize: '0.23KB',
                            ),
                          ),
                        ],
                      ),
                      _buildDetailRow('Linkedin Profilie',
                          'https://linkedin.com/in/johnmichael5'),
                      _buildDetailRow(
                          'Application Deadline', 'www.johnmichael.com'),
                      _buildDetailRow('Status', 'New'),

                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.end,
                      children: [
                        MyElevatedButton(
                          bgColor: AppColors.red,
                          child: 'Delete',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        MyElevatedButton(
                          child: 'Edit',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
