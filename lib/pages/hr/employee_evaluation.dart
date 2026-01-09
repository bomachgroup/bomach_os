import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'models/employee_evaluation_models.dart';

class EmployeeEvaluationPage extends StatefulWidget {
  const EmployeeEvaluationPage({super.key});

  @override
  State<EmployeeEvaluationPage> createState() =>
      _EmployeeEvaluationPageState();
}

class _EmployeeEvaluationPageState extends State<EmployeeEvaluationPage> {
  String selectedDepartment = 'Engineering';
  String selectedPeriod = 'Q1 2025';
  late EmployeeEvaluationForm evaluationForm;

  @override
  void initState() {
    super.initState();
    evaluationForm = _getMockEvaluationForm();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText(
            'Employee Evaluation Form',
            style: AppText.black_500_32,
          ),
          const MyText(
            'Quarterly Evaluation',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          kSizedBox,

          // Filters
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Department',
                  value: selectedDepartment,
                  items: ['Engineering', 'Sales', 'HR', 'Finance'],
                  onChanged: (value) =>
                      setState(() => selectedDepartment = value),
                ),
              ),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Period',
                  value: selectedPeriod,
                  items: ['Q1 2025', 'Q4 2024', 'Q3 2024'],
                  onChanged: (value) =>
                      setState(() => selectedPeriod = value),
                ),
              ),
            ],
          ),
          kSizedBox,

          // Employee Info Card
          _buildEmployeeInfoCard(),
          kSizedBox,

          // Core Competencies Section
          _buildCoreCompetenciesSection(),
          kSizedBox,

          // KPI Review Section
          _buildKPIReviewSection(),
          kSizedBox,

          // Manager's Comments
          _buildManagerCommentsSection(),
          kSizedBox,

          // Recommendation & Decision
          _buildRecommendationSection(),
          kSizedBox,

          // Action Buttons
          _buildActionButtons(),
          kSizedBox,
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, size: 18),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: MyText(item, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: AppColors.blue),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      evaluationForm.employeeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MyText(
                      'Department: ${evaluationForm.department}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    MyText(
                      'Role: ${evaluationForm.role} | Branch: ${evaluationForm.branch}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          evaluationForm.getPerformanceColor()
                              .replaceFirst('#', '0xff'),
                        ),
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Color(
                          int.parse(
                            evaluationForm.getPerformanceColor()
                                .replaceFirst('#', '0xff'),
                          ),
                        ),
                      ),
                    ),
                    child: MyText(
                      'Average Score',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  MyText(
                    '${evaluationForm.averageScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                  MyText(
                    'Total ${evaluationForm.totalScore}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoreCompetenciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Core Competence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: evaluationForm.coreCompetencies
                .map((competency) =>
                    _buildCompetencyRow(competency))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyRow(CompetencyRating competency) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                competency.competencyName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      competency.getRatingColor().replaceFirst('#', '0xff'),
                    ),
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(
                      int.parse(
                        competency.getRatingColor()
                            .replaceFirst('#', '0xff'),
                      ),
                    ),
                  ),
                ),
                child: MyText(
                  '${competency.rating}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      int.parse(
                        competency.getRatingColor()
                            .replaceFirst('#', '0xff'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Rating bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: competency.rating / 5,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(
                  int.parse(
                    competency.getRatingColor().replaceFirst('#', '0xff'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'KPIs Review',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: evaluationForm.kpiReviews.asMap().entries.map((entry) {
              final isLast = entry.key == evaluationForm.kpiReviews.length - 1;
              return Column(
                children: [
                  _buildKPIRow(entry.value),
                  if (!isLast)
                    Divider(
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIRow(KPIReview kpi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                MyText(
                  kpi.kpiName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MyText(
                  '${kpi.achievedValue ?? '-'}${kpi.unit} / ${kpi.targetValue}${kpi.unit}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Color(
                int.parse(kpi.getStatusColor().replaceFirst('#', '0xff')),
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color(
                  int.parse(kpi.getStatusColor().replaceFirst('#', '0xff')),
                ),
              ),
            ),
            child: MyText(
              kpi.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(
                  int.parse(kpi.getStatusColor().replaceFirst('#', '0xff')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          "Manager's Comments",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            maxLines: 4,
            controller: TextEditingController(
              text: evaluationForm.managerComments ?? '',
            ),
            decoration: InputDecoration(
              hintText: 'Enter manager comments...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    final rec = evaluationForm.recommendation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Recommendation & Decision',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            spacing: 12,
            children: [
              _buildCheckboxRow(
                label: 'Promotion Required',
                value: rec.promotionRecommended,
              ),
              _buildCheckboxRow(
                label: 'Training Required',
                value: rec.trainingRequired,
              ),
              _buildCheckboxRow(
                label: 'Salary Increase',
                value: rec.increaseRequired,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) {},
          activeColor: AppColors.blue,
        ),
        MyText(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const MyText(
              'Save Draft',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const MyText(
              'Submit Evaluation',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: const MyText(
              'Generate PDF',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mock evaluation form data
  EmployeeEvaluationForm _getMockEvaluationForm() {
    return EmployeeEvaluationForm(
      evaluationId: 'eval-001',
      employeeId: 'emp-001',
      employeeName: 'Engr. Tochukwu David',
      employeeEmail: 'tochukwu@company.com',
      department: selectedDepartment,
      role: 'Project Manager',
      branch: 'Enugu',
      evaluationPeriod: selectedPeriod,
      evaluationDate: DateTime.now(),
      evaluatorName: 'John Doe',
      averageScore: 91,
      totalScore: 27,
      coreCompetencies: [
        CompetencyRating(competencyName: 'Technical Skill', rating: 5),
        CompetencyRating(competencyName: 'Communication', rating: 5),
        CompetencyRating(competencyName: 'Teamwork', rating: 5),
        CompetencyRating(competencyName: 'Innovation', rating: 5),
        CompetencyRating(competencyName: 'Timeliness', rating: 4),
      ],
      kpiReviews: [
        KPIReview(
          kpiName: 'Tasks Completed',
          achievedValue: 95,
          targetValue: 100,
          unit: '%',
          status: 'On Target',
        ),
        KPIReview(
          kpiName: 'Attendance Rate',
          achievedValue: 95,
          targetValue: 100,
          unit: '%',
          status: 'On Target',
        ),
        KPIReview(
          kpiName: 'Training Hours',
          achievedValue: 40,
          targetValue: 30,
          unit: 'hrs',
          status: 'Exceeded',
        ),
        KPIReview(
          kpiName: 'Reports Submitted',
          achievedValue: 12,
          targetValue: 12,
          unit: '',
          status: 'On Target',
        ),
      ],
      managerComments:
          'Excellent performance this quarter. Shows strong leadership and technical expertise. Recommended for advancement.',
      recommendation: RecommendationDecision(
        promotionRecommended: true,
        trainingRequired: false,
        increaseRequired: true,
      ),
      status: 'Draft',
    );
  }
}
