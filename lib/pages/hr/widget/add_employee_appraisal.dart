import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';

class EmployeeAppraisalDialog extends StatefulWidget {
  const EmployeeAppraisalDialog({super.key});

  @override
  State<EmployeeAppraisalDialog> createState() => _EmployeeAppraisalDialogState();
}

class _EmployeeAppraisalDialogState extends State<EmployeeAppraisalDialog> {
  // Ratings State
  int jobKnowledge = 0;
  int communication = 0;
  int problemSolving = 0;
  int teamwork = 0;
  int initiative = 0;
  int qualityOfWork = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600, // Wider for form
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText('Employee Appraisal Form', size: 18, weight: 700),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                )
              ],
            ),
            const Divider(height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Employee & Period
                    Row(
                      children: [
                        Expanded(child: _buildDropdownField("Employee", "Select")),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdownField("Review Period", "Q4 2025")),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const MyText('Performance Ratings', size: 14, weight: 600),
                    const SizedBox(height: 16),
                    _buildRatingRow("Job Knowledge", jobKnowledge, (v) => setState(() => jobKnowledge = v)),
                    _buildRatingRow("Communication", communication, (v) => setState(() => communication = v)),
                    _buildRatingRow("Problem Solving", problemSolving, (v) => setState(() => problemSolving = v)),
                    _buildRatingRow("Teamwork", teamwork, (v) => setState(() => teamwork = v)),
                    _buildRatingRow("Initiative", initiative, (v) => setState(() => initiative = v)),
                    _buildRatingRow("Quality of Work", qualityOfWork, (v) => setState(() => qualityOfWork = v)),

                    const SizedBox(height: 24),
                    _buildTextArea("Key Achievements", "Write the details here"),
                    const SizedBox(height: 16),
                    _buildTextArea("Areas for Improvement", "Write the details here"),
                    const SizedBox(height: 16),
                    _buildTextArea("Development Plan", "Write the details here"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Footer Buttons
            Row(
              children: [
                Expanded(
                  child: MyOutlinedButton(
                    child: 'Cancel',
                    textColor: const Color(0xFF0055FF),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyElevatedButton(
                    child: 'Add Review',
                    bgColor: const Color(0xFF0055FF),
                    onTap: () {
                      // TODO: Submit Review Logic
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, weight: 600, color: Colors.black87),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 13)),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRatingRow(String label, int currentRating, Function(int) onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 140, child: MyText(label, size: 13, weight: 500)),
          Row(
            children: List.generate(5, (index) {
              return InkWell(
                onTap: () => onRate(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    index < currentRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildTextArea(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 13, weight: 600),
        const SizedBox(height: 8),
        Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            maxLines: null,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}