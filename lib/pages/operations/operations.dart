import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/dashboard_controller.dart';
import 'models/models.dart';
import 'widget/add_project_dialog.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final DashboardController controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText('Operations Dashboard', style: AppText.black_500_32),
                        SizedBox(height: 8),
                        MyText('Overview & Projects', style: AppText.black_400_14),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white),
                      child: "Add Project",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddProjectDialog(),
                        ).then((_) => controller.fetchDashboardData(context));
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          kSizedBox,

          // --- Stats Section ---
          Obx(() {
            if (controller.isLoadingStats.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
            }
            final stats = controller.stats.value;
            if (stats == null) return const SizedBox();

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard("Active Projects", stats.activeProjects.toString(), Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Total Budget", "₦${stats.totalBudget}", Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Budget Util.", "${stats.budgetUtilization}%", Colors.orange)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard("Worksites", stats.totalWorksites.toString(), Colors.purple)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Contracts", stats.totalContracts.toString(), Colors.teal)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("Timelines", stats.totalTimelines.toString(), Colors.red)),
                  ],
                ),
              ],
            );
          }),
          
          kSizedBoxBG,
          const Divider(),
          kSizedBox,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MyText('Recent Projects', style: AppText.black_500_20),
              SizedBox(
                width: 200,
                child: MyTextFormField(
                  hintText: 'Search Projects...',
                  leading: Icon(Icons.search, color: AppColors.grey1.withValues(alpha: 0.5)),
                  onChanged: (val) => controller.fetchProjects(context, search: val),
                ),
              ),
            ],
          ),
          kSizedBox,

          Obx(() {
            if (controller.isLoadingProjects.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (controller.projects.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("No projects found"),
              ));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = controller.projects[index];
                return _buildProjectItem(context, project);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          MyText(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, Project project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.folder, color: AppColors.blue)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(project.name, style: AppText.black_500_16),
                const SizedBox(height: 4),
                MyText("${project.shortCode} • ${project.status}", style: AppText.black_400_14),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyText("Budget: ₦${project.budget}", style: AppText.black_500_20),
              const SizedBox(height: 4),
              MyText(project.deadline, style: AppText.black_400_14),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => controller.deleteProject(context, project.id),
          ),
        ],
      ),
    );
  }
}