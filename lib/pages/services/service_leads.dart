import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:bms_front_end/components/permission_gate.dart';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'qualified':
        return Colors.purple;
      case 'contacted':
        return Colors.orange;
      case 'converted':
        return Colors.green;
      default:
        return Colors.grey;
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
                    const MyText(
                      'Add New Service Lead',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      'Fill in the lead details',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
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
                                  bgColor: AppColors.blue,
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${firstNameController.text} added successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to add lead. Please try again.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
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
    final theme = Theme.of(context);

    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
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
                    Text(
                      "Service Leads",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Manage service leads and convert to clients",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
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
                  bgColor: AppColors.blue,
                  icon: const Icon(Icons.add, color: Colors.white),
                  onTap: _showAddLeadDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) {
              // Debounce search to avoid too many API calls
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == val) {
                  _controller.fetchLeads(search: val.trim());
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Search by client name...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
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
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No leads available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
                    final statusColor = _getStatusColor(lead.status);

                    return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                  Text(
                                    lead.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lead.email,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lead.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lead.status.capitalizeFirst ?? lead.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lead.interestedServices.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.business,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        lead.interestedServices,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (lead.assignedToName.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Assigned to: ${lead.assignedToName}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (lead.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Notes: ${lead.notes}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (lead.status.toLowerCase() != 'converted')
                              MyElevatedButton(
                                child: 'Convert to Client',
                                bgColor: AppColors.blue,
                                onTap: () async {
                                  // Show confirmation dialog
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text('Convert Lead to Client'),
                                      content: Text(
                                        'Are you sure you want to convert ${lead.fullName} to a client?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.blue,
                                          ),
                                          child: const Text(
                                            'Convert',
                                            style: TextStyle(
                                                color: AppColors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true && mounted) {
                                    final success = await _controller
                                        .convertLeadToClient(lead.id);

                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${lead.fullName} successfully converted to client',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to convert lead. Please try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
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
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[300]!),
                                ),
                                child: Text(
                                  'Converted to Client',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pagination Controls
                Obx(() {
                  final currentPage = _controller.currentPage.value;
                  final hasNextPage = _controller.leads.length >= _controller.limit;

                  final totalPages = hasNextPage ? currentPage + 1 : currentPage;
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
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor: currentPage > 1
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
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
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.blue
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$pageNumber',
                                  style: TextStyle(
                                    color: isCurrentPage
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isCurrentPage
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextPage(
                                  search: _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim(),
                                )
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: hasNextPage
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor: hasNextPage
                              ? Colors.white
                              : Colors.grey[600],
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
