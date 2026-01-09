import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'models/service_invoice_model.dart';
import 'widgets/invoice_from_lead_dialog.dart';

class ServiceLead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String serviceType; // 'Real Estate', 'Land Survey', etc.
  final String property; // Property address or details
  final String status; // 'New', 'Qualified', 'Negotiating', 'Converted'
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
  String _searchQuery = "";

  final List<ServiceLead> _leads = [
    ServiceLead(
      id: 'SL-001',
      name: 'John Okafor',
      email: 'john.okafor@example.com',
      phone: '+234 803 456 7890',
      serviceType: 'Real Estate',
      property: 'Land at Enugu - Independence Layout, 1500 sqm',
      status: 'Qualified',
      estimatedValue: 25000000,
      dateCreated: DateTime(2025, 1, 15),
      notes: 'Interested in bulk purchase',
    ),
    ServiceLead(
      id: 'SL-002',
      name: 'Ngozi Adeyemi',
      email: 'ngozi.adeyemi@example.com',
      phone: '+234 801 234 5678',
      serviceType: 'Land Survey',
      property: 'Plot 23, Lekki Phase 1, Lagos',
      status: 'New',
      estimatedValue: 500000,
      dateCreated: DateTime(2025, 1, 20),
    ),
    ServiceLead(
      id: 'SL-003',
      name: 'Michael Eze',
      email: 'michael.eze@example.com',
      phone: '+234 802 789 1234',
      serviceType: 'Property Management',
      property: 'Ikeja - 3 Bedroom Apartment',
      status: 'Negotiating',
      estimatedValue: 15000000,
      dateCreated: DateTime(2025, 1, 10),
      notes: 'Needs property valuation first',
    ),
    ServiceLead(
      id: 'SL-004',
      name: 'Chioma Nwankwo',
      email: 'chioma.nwankwo@example.com',
      phone: '+234 705 345 6789',
      serviceType: 'Real Estate',
      property: 'Victoria Island - Commercial Property',
      status: 'Converted',
      estimatedValue: 80000000,
      dateCreated: DateTime(2024, 12, 20),
      notes: 'Invoice generated - INV-2025-01-12345',
    ),
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'Qualified':
        return Colors.purple;
      case 'Negotiating':
        return Colors.orange;
      case 'Converted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    return '₦${(amount / 1000000).toStringAsFixed(1)}M';
  }

  void _showAddLeadDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final propertyController = TextEditingController();
    final valueController = TextEditingController();
    String selectedServiceType = 'Real Estate';
    String selectedStatus = 'New';

    showDialog(
      context: context,
      builder: (context) => Dialog(
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

                  // Client Name
                  MyTextFormField(
                    controller: nameController,
                    hintText: 'Enter client name',
                    title: 'Client Name',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  MyTextFormField(
                    controller: emailController,
                    hintText: 'Enter email address',
                    title: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  MyTextFormField(
                    controller: phoneController,
                    hintText: 'Enter phone number',
                    title: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Service Type
                  MyText(
                    'Service Type',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.card),
                    ),
                    child: DropdownButton<String>(
                      value: selectedServiceType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      items: ['Real Estate', 'Land Survey', 'Property Management']
                          .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedServiceType = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Property
                  MyTextFormField(
                    controller: propertyController,
                    hintText: 'Enter property address/details',
                    title: 'Property',
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Property is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Estimated Value
                  MyTextFormField(
                    controller: valueController,
                    hintText: 'Enter estimated value in naira',
                    title: 'Estimated Value (₦)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Value is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Cancel',
                          bgColor: Colors.grey[200] ?? Colors.grey,
                          textColor: Colors.black87,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Add Lead',
                          bgColor: AppColors.blue,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                _leads.add(
                                  ServiceLead(
                                    id: 'SL-${_leads.length + 1}'.padRight(5, '0'),
                                    name: nameController.text,
                                    email: emailController.text,
                                    phone: phoneController.text,
                                    serviceType: selectedServiceType,
                                    property: propertyController.text,
                                    status: 'New',
                                    estimatedValue:
                                        double.parse(valueController.text),
                                    dateCreated: DateTime.now(),
                                  ),
                                );
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${nameController.text} added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredLeads = _leads
        .where((lead) => lead.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

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
                    "Manage service leads and generate invoices",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            MyElevatedButton(
              child: 'Add Lead',
              bgColor: AppColors.blue,
              icon: const Icon(Icons.add, color: Colors.white),
              onTap: _showAddLeadDialog,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
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

        // Leads List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredLeads.length,
          itemBuilder: (context, index) {
            final lead = filteredLeads[index];
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
                                lead.name,
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
                                lead.phone,
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
                            lead.status,
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
                          Row(
                            children: [
                              const Icon(Icons.home, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lead.property,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.business, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    lead.serviceType,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatCurrency(lead.estimatedValue),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (lead.notes != null)
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
                        if (lead.status != 'Converted')
                          MyElevatedButton(
                            child: 'Generate Invoice',
                            bgColor: AppColors.blue,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    InvoiceFromLeadDialog(lead: lead),
                              );
                            },
                          ),
                        if (lead.status == 'Converted')
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
                              'Invoice Generated',
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
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
