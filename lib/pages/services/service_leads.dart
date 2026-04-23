import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/permission_gate.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/lead_controller.dart';

// Legacy class for backward compatibility with invoice widgets
class ServiceLead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String property;
  final String status;
  final double estimatedValue;
  final DateTime dateCreated;
  final String? notes;

  ServiceLead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    required this.property,
    required this.status,
    required this.estimatedValue,
    required this.dateCreated,
    this.notes,
  });
}

class ServiceLeadsPage extends StatefulWidget {
  const ServiceLeadsPage({super.key});

  @override
  State<ServiceLeadsPage> createState() => _ServiceLeadsPageState();
}

class _ServiceLeadsPageState extends State<ServiceLeadsPage> {
  final TextEditingController _searchController = TextEditingController();
  final LeadController _controller = Get.put(LeadController());
  final _storage = const FlutterSecureStorage();

  String _mapStatusToTone(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'info';
      case 'qualified':
        return 'primary';
      case 'contacted':
        return 'warning';
      case 'converted':
        return 'success';
      default:
        return 'neutral';
    }
  }

  void _showAddLeadDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final interestedServicesController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h4(
                      'Add New Service Lead',
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 6),
                    AppText.bodySm(
                      'Fill in the lead details',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),

                    // First Name
                    MyTextFormField(
                      controller: firstNameController,
                      hintText: 'Enter first name',
                      title: 'First Name*',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    MyTextFormField(
                      controller: lastNameController,
                      hintText: 'Enter last name',
                      title: 'Last Name*',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    MyTextFormField(
                      controller: emailController,
                      hintText: 'Enter email address',
                      title: 'Email Address*',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    MyTextFormField(
                      controller: phoneController,
                      hintText: 'e.g., +2349012345678',
                      title: 'Phone Number*',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Interested Services
                    MyTextFormField(
                      controller: interestedServicesController,
                      hintText: 'e.g., Real Estate, Land Survey',
                      title: 'Interested Services*',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Interested services is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    const Divider(
                        height: 1, thickness: 1, color: Colors.black12),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MyElevatedButton(
                            child: 'Cancel',
                            bgColor: Colors.grey[200] ?? Colors.grey,
                            textColor: Colors.black87,
                            onTap: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isSubmitting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : MyElevatedButton(
                                  child: 'Add Lead',
                                  bgColor: AppColors.primary,
                                  onTap: () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() {
                                        isSubmitting = true;
                                      });

                                      try {
                                        // Get user ID from storage
                                        final userId =
                                            await _storage.read(key: 'user_id');
                                        final assignedToId =
                                            int.tryParse(userId ?? '0') ?? 0;

                                        final leadData = {
                                          'email': emailController.text.trim(),
                                          'first_name':
                                              firstNameController.text.trim(),
                                          'last_name':
                                              lastNameController.text.trim(),
                                          'phone_number':
                                              phoneController.text.trim(),
                                          'interested_services':
                                              interestedServicesController.text
                                                  .trim(),
                                          'assigned_to_id': assignedToId,
                                        };

                                        final success = await _controller
                                            .createLead(leadData);

                                        if (success && mounted) {
                                          Navigator.pop(context);
                                          AppToast.success(context,
                                              '${firstNameController.text} added successfully');
                                        } else if (mounted) {
                                          AppToast.error(context,
                                              'Failed to add lead. Please try again.');
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isSubmitting = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMd(
                  _controller.errorMessage.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchLeads(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3(
                      "Service Leads",
                    ),
                    const SizedBox(height: 6),
                    AppText.bodySm(
                      "Manage service leads and convert to clients",
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              PermissionGate(
                resource: 'leads',
                action: 'create',
                child: MyElevatedButton(
                  child: 'Add Lead',
                  bgColor: AppColors.primary,
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  onTap: _showAddLeadDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          MyTextFormField(
            controller: _searchController,
            hintText: "Search by client name...",
            leading: const Icon(Iconsax.search_normal),
            onChanged: (val) {
              // Debounce search to avoid too many API calls
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == val) {
                  _controller.fetchLeads(search: val.trim());
                }
              });
            },
          ),

          const SizedBox(height: 24),

          // Loading or empty state
          if (_controller.isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.leads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: AppText.bodySm(
                  'No leads available',
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                // Leads List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.leads.length,
                  itemBuilder: (context, index) {
                    final lead = _controller.leads[index];

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.h4(
                                      lead.fullName,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText.caption(
                                      lead.email,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText.caption(
                                      lead.phoneNumber,
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label:
                                    lead.status.capitalizeFirst ?? lead.status,
                                status: _mapStatusToTone(lead.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (lead.interestedServices.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Iconsax.building_4,
                                          size: 14,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppText.caption(
                                          lead.interestedServices,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (lead.assignedToName.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Iconsax.profile_circle,
                                          size: 14,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      AppText.caption(
                                        'Assigned to: ${lead.assignedToName}',
                                        color: AppColors.textPrimary,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (lead.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            AppText.bodySm(
                              'Notes: ${lead.notes}',
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (lead.status.toLowerCase() != 'converted')
                                MyElevatedButton(
                                  child: 'Convert to Client',
                                  bgColor: AppColors.primary,
                                  onTap: () async {
                                    // Show confirmation dialog
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: AppText.h4(
                                            'Convert Lead to Client'),
                                        content: AppText.bodyMd(
                                          'Are you sure you want to convert ${lead.fullName} to a client?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: AppText.bodyMd('Cancel',
                                                color: AppColors.textSecondary),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            child: const Text(
                                              'Convert',
                                              style: TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true && mounted) {
                                      final success = await _controller
                                          .convertLeadToClient(lead.id);

                                      if (success && mounted) {
                                        AppToast.success(
                                          context,
                                          '${lead.fullName} successfully converted to client',
                                        );
                                      } else if (mounted) {
                                        AppToast.error(
                                          context,
                                          'Failed to convert lead. Please try again.',
                                        );
                                      }
                                    }
                                  },
                                ),
                              if (lead.status.toLowerCase() == 'converted')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.success
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.tick_circle,
                                          size: 16, color: AppColors.success),
                                      const SizedBox(width: 8),
                                      AppText.bodySm(
                                        'Converted to Client',
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pagination Controls
                Obx(() {
                  final currentPage = _controller.currentPage.value;
                  final hasNextPage =
                      _controller.leads.length >= _controller.limit;

                  final totalPages =
                      hasNextPage ? currentPage + 1 : currentPage;
                  int endPage = totalPages.clamp(1, totalPages);
                  int startPage = (endPage - 4).clamp(1, endPage);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentPage > 1
                            ? () => _controller.previousPage(
                                  search: _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim(),
                                )
                            : null,
                        icon: const Icon(Iconsax.arrow_left_2, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: currentPage > 1
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ...List.generate(
                        endPage - startPage + 1,
                        (index) {
                          final pageNumber = startPage + index;
                          final isCurrentPage = pageNumber == currentPage;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => _controller.goToPage(
                                pageNumber,
                                search: _searchController.text.trim().isEmpty
                                    ? null
                                    : _searchController.text.trim(),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.primary
                                        : AppColors.neutral200,
                                  ),
                                  boxShadow: isCurrentPage
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: AppText.bodySm(
                                  '$pageNumber',
                                  color: isCurrentPage
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isCurrentPage
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextPage(
                                  search: _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim(),
                                )
                            : null,
                        icon: const Icon(Iconsax.arrow_right_3, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: hasNextPage
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: hasNextPage
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
