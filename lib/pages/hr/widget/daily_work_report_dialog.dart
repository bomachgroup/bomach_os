import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/work_report_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class DailyWorkReportDialog extends StatefulWidget {
  final DailyWorkReport? existingReport;
  final Function(DailyWorkReport)? onSubmit;

  const DailyWorkReportDialog({
    super.key,
    this.existingReport,
    this.onSubmit,
  });

  @override
  State<DailyWorkReportDialog> createState() => _DailyWorkReportDialogState();
}

class _DailyWorkReportDialogState extends State<DailyWorkReportDialog> {
  late TextEditingController _challengesController;
  late TextEditingController _achievementsController;
  late TextEditingController _nextDayPlanController;
  late List<WorkActivity> _activities;

  String _selectedMood = 'Neutral';
  bool _isLoading = false;
  DateTime _reportDate = DateTime.now();

  final List<String> _moodOptions = ['Happy', 'Neutral', 'Tired', 'Frustrated'];

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      _challengesController =
          TextEditingController(text: widget.existingReport!.challenges);
      _achievementsController =
          TextEditingController(text: widget.existingReport!.achievements);
      _nextDayPlanController =
          TextEditingController(text: widget.existingReport!.nextDayPlan);
      _selectedMood = widget.existingReport!.mood;
      _activities = List.from(widget.existingReport!.activities);
      _reportDate = widget.existingReport!.reportDate;
    } else {
      _challengesController = TextEditingController();
      _achievementsController = TextEditingController();
      _nextDayPlanController = TextEditingController();
      _activities = [];
    }
  }

  @override
  void dispose() {
    _challengesController.dispose();
    _achievementsController.dispose();
    _nextDayPlanController.dispose();
    super.dispose();
  }

  void _addActivity() {
    showDialog(
      context: context,
      builder: (context) {
        return _ActivityDialog(
          onAdd: (activity) {
            setState(() {
              _activities.add(activity);
            });
          },
        );
      },
    );
  }

  void _editActivity(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return _ActivityDialog(
          activity: _activities[index],
          onAdd: (activity) {
            setState(() {
              _activities[index] = activity;
            });
          },
        );
      },
    );
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }

  void _handleSubmit() {
    // Validate inputs
    if (_activities.isEmpty) {
      _showErrorMessage('Add at least one activity');
      return;
    }

    if (_challengesController.text.isEmpty) {
      _showErrorMessage('Please describe challenges faced');
      return;
    }

    if (_achievementsController.text.isEmpty) {
      _showErrorMessage('Please describe achievements');
      return;
    }

    if (_nextDayPlanController.text.isEmpty) {
      _showErrorMessage('Please describe next day plan');
      return;
    }

    setState(() => _isLoading = true);

    // Create work report
    final report = DailyWorkReport(
      id: widget.existingReport?.id ?? _generateId(),
      employeeId: 'EMP001', // Should come from logged-in user
      employeeName: 'Current Employee',
      employeeEmail: 'employee@company.com',
      reportDate: _reportDate,
      activities: _activities,
      hoursWorked: _activities.fold(0.0, (sum, a) => sum + a.hoursSpent),
      mood: _selectedMood,
      challenges: _challengesController.text,
      achievements: _achievementsController.text,
      nextDayPlan: _nextDayPlanController.text,
      submitted: true,
      submittedAt: DateTime.now(),
      status: 'Submitted',
    );

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onSubmit?.call(report);
        Navigator.of(context).pop(report);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: MyText(
              'Work report submitted successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.green,
          ),
        );
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.red,
      ),
    );
  }

  String _generateId() {
    return 'WR_${DateTime.now().millisecondsSinceEpoch}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Development':
        return AppColors.blue;
      case 'Testing':
        return const Color(0xFF9B59B6);
      case 'Bug Fix':
        return AppColors.red;
      case 'Documentation':
        return const Color(0xFFF39C12);
      case 'Meeting':
        return AppColors.green;
      case 'Research':
        return const Color(0xFF3B82F6);
      case 'Code Review':
        return const Color(0xFF8B5CF6);
      case 'Deployment':
        return const Color(0xFFD97706);
      default:
        return AppColors.grey1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assessment,
                          color: AppColors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const MyText(
                        'Daily Work Report',
                        style: AppText.black_500_20,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Mood Section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const MyText(
                                  'Report Date',
                                  style: AppText.black_600_14,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0XFFD5D5D5),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: MyText(
                                    DateFormat('MMM dd, yyyy')
                                        .format(_reportDate),
                                    style: AppText.black_400_14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  title: 'How are you feeling? 😊',
                                  items: _moodOptions,
                                  hintText: _selectedMood,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMood = value ?? 'Neutral';
                                    });
                                  },
                                  spaceBetweenText: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Challenges Section
                      MyTextFormField(
                        title: 'Challenges Faced *',
                        hintText: 'Describe any challenges you faced today',
                        controller: _challengesController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      kSizedBox,

                      // Achievements Section
                      MyTextFormField(
                        title: 'Achievements & Accomplishments *',
                        hintText: 'What did you accomplish today?',
                        controller: _achievementsController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      kSizedBox,

                      // Next Day Plan Section
                      MyTextFormField(
                        title: 'Plan for Next Day *',
                        hintText: 'What will you work on tomorrow?',
                        controller: _nextDayPlanController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: _isLoading
                        ? null
                        : SvgPicture.asset(
                            "assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn),
                          ),
                    child: _isLoading ? 'Submitting...' : 'Submit Report',
                    onTap: _isLoading ? null : _handleSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyText(
          value,
          style: AppText.black_600_16,
        ),
        const SizedBox(height: 4),
        MyText(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

/// Activity Dialog for adding/editing activities
class _ActivityDialog extends StatefulWidget {
  final WorkActivity? activity;
  final Function(WorkActivity) onAdd;

  const _ActivityDialog({
    this.activity,
    required this.onAdd,
  });

  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hoursController;

  String _selectedCategory = 'Development';
  bool _isCompleted = false;

  final List<String> _categories = [
    'Development',
    'Testing',
    'Bug Fix',
    'Documentation',
    'Meeting',
    'Research',
    'Code Review',
    'Deployment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _titleController =
          TextEditingController(text: widget.activity!.taskTitle);
      _descriptionController =
          TextEditingController(text: widget.activity!.description);
      _hoursController =
          TextEditingController(text: widget.activity!.hoursSpent.toString());
      _selectedCategory = widget.activity!.taskCategory;
      _isCompleted = widget.activity!.completed;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _hoursController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: MyText('Task title is required')),
      );
      return;
    }

    if (_hoursController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: MyText('Hours spent is required')),
      );
      return;
    }

    final activity = WorkActivity(
      id: widget.activity?.id ?? 'ACT_${DateTime.now().millisecondsSinceEpoch}',
      taskTitle: _titleController.text,
      description: _descriptionController.text,
      taskCategory: _selectedCategory,
      hoursSpent: double.tryParse(_hoursController.text) ?? 0,
      completed: _isCompleted,
    );

    widget.onAdd(activity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add Work Activity',
                    style: AppText.black_500_20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextFormField(
                    title: 'Task Title *',
                    hintText: 'What did you work on?',
                    controller: _titleController,
                    spaceBetweenText: 8,
                  ),
                  kSizedBox,
                  MyDropdown(
                    title: 'Category *',
                    items: _categories,
                    hintText: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'Development';
                      });
                    },
                    spaceBetweenText: 8,
                  ),
                  kSizedBox,
                  MyTextFormField(
                    title: 'Description',
                    hintText: 'Details about this activity',
                    controller: _descriptionController,
                    spaceBetweenText: 8,
                    maxLines: 2,
                  ),
                  kSizedBox,
                  MyTextFormField(
                    title: 'Hours Spent *',
                    hintText: 'e.g., 2.5',
                    controller: _hoursController,
                    spaceBetweenText: 8,
                    keyboardType: TextInputType.number,
                  ),
                  kSizedBox,
                  Row(
                    children: [
                      Checkbox(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value ?? false;
                          });
                        },
                      ),
                      const MyText('Mark as completed'),
                    ],
                  ),
                ],
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    child: 'Add Activity',
                    onTap: _handleAdd,
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
