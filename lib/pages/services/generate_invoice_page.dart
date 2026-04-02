import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'models/service_invoice_model.dart';
import 'service_leads.dart';

class GenerateInvoicePage extends StatefulWidget {
  final ServiceLead? initialLead;

  const GenerateInvoicePage({
    super.key,
    this.initialLead,
  });

  @override
  State<GenerateInvoicePage> createState() => _GenerateInvoicePageState();
}

class _GenerateInvoicePageState extends State<GenerateInvoicePage> {
  final formKey = GlobalKey<FormState>();

  // Client Information Controllers
  late TextEditingController clientNameController;
  late TextEditingController clientEmailController;
  late TextEditingController clientPhoneController;
  late TextEditingController clientAddressController;

  // Service Information
  String selectedServiceType = 'Real Estate';
  late TextEditingController propertyAddressController;
  late TextEditingController propertyDetailsController;

  // Invoice Items
  late List<ServiceInvoiceItem> invoiceItems;
  late TextEditingController itemDescriptionController;
  late TextEditingController itemQuantityController;
  late TextEditingController itemUnitPriceController;

  // Financial Details
  double taxRate = 7.5;
  double discount = 0;
  int daysUntilDue = 30;
  late TextEditingController notesController;

  // Form state
  String selectedLeadId = '';
  List<ServiceLead> availableLeads = [
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
    ),
  ];

  @override
  void initState() {
    super.initState();
    invoiceItems = [];

    // Initialize controllers
    clientNameController = TextEditingController();
    clientEmailController = TextEditingController();
    clientPhoneController = TextEditingController();
    clientAddressController = TextEditingController();
    propertyAddressController = TextEditingController();
    propertyDetailsController = TextEditingController();
    itemDescriptionController = TextEditingController();
    itemQuantityController = TextEditingController();
    itemUnitPriceController = TextEditingController();
    notesController = TextEditingController();

    // If initial lead provided, pre-fill the form
    if (widget.initialLead != null) {
      _populateFromLead(widget.initialLead!);
      selectedLeadId = widget.initialLead!.id;
    }
  }

  void _populateFromLead(ServiceLead lead) {
    clientNameController.text = lead.name;
    clientEmailController.text = lead.email;
    clientPhoneController.text = lead.phone;
    propertyAddressController.text = lead.property;
    selectedServiceType = lead.serviceType;

    // Clear existing items and add default
    invoiceItems.clear();
    invoiceItems.add(
      ServiceInvoiceItem(
        id: '1',
        description: '${lead.serviceType} Service - ${lead.property}',
        quantity: 1,
        unitPrice: lead.estimatedValue,
        unit: 'service',
      ),
    );
  }

  void _loadLeadData(ServiceLead lead) {
    setState(() {
      _populateFromLead(lead);
      selectedLeadId = lead.id;
    });
  }

  double get subtotal => ServiceInvoice.calculateSubtotal(invoiceItems);
  double get taxAmount => ServiceInvoice.calculateTax(subtotal, taxRate);
  double get total =>
      ServiceInvoice.calculateTotal(subtotal, taxAmount, discount);

  void _addInvoiceItem() {
    if (itemDescriptionController.text.isEmpty ||
        itemQuantityController.text.isEmpty ||
        itemUnitPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all item fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      invoiceItems.add(
        ServiceInvoiceItem(
          id: (invoiceItems.length + 1).toString(),
          description: itemDescriptionController.text,
          quantity: int.parse(itemQuantityController.text),
          unitPrice: double.parse(itemUnitPriceController.text),
        ),
      );
    });

    itemDescriptionController.clear();
    itemQuantityController.clear();
    itemUnitPriceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      invoiceItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _generateInvoice() {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final invoice = ServiceInvoice(
      id: UniqueKey().toString(),
      invoiceNumber: ServiceInvoice.generateInvoiceNumber(),
      leadId: selectedLeadId,
      clientName: clientNameController.text,
      clientEmail: clientEmailController.text,
      clientPhone: clientPhoneController.text,
      clientAddress: clientAddressController.text,
      serviceType: selectedServiceType,
      propertyAddress: propertyAddressController.text,
      propertyDetails: propertyDetailsController.text,
      items: invoiceItems,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      discount: discount,
      totalAmount: total,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: daysUntilDue)),
      createdBy: 'Current User',
      createdDate: DateTime.now(),
      notes: notesController.text,
      termsAndConditions:
          'Payment is due within $daysUntilDue days from the invoice date.\n'
          'Late payments may incur additional charges.\n'
          'All prices are in Nigerian Naira (₦).',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Invoice ${invoice.invoiceNumber} generated successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset form
    _resetForm();
  }

  void _resetForm() {
    formKey.currentState?.reset();
    setState(() {
      clientNameController.clear();
      clientEmailController.clear();
      clientPhoneController.clear();
      clientAddressController.clear();
      propertyAddressController.clear();
      propertyDetailsController.clear();
      notesController.clear();
      invoiceItems.clear();
      selectedServiceType = 'Real Estate';
      selectedLeadId = '';
      taxRate = 7.5;
      discount = 0;
      daysUntilDue = 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Generate Invoice",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a new invoice for your service",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Main Form Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Load from Lead
                  _buildSection(
                    title: 'Select Existing Lead (Optional)',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a lead to auto-fill the invoice form',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: List.generate(
                              availableLeads.length,
                              (index) {
                                final lead = availableLeads[index];
                                final isSelected = selectedLeadId == lead.id;
                                return GestureDetector(
                                  onTap: () => _loadLeadData(lead),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue[50]
                                          : Colors.white,
                                      border: index < availableLeads.length - 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[200]!,
                                              ),
                                            )
                                          : null,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        RadioGroup<String>(
                                          groupValue: selectedLeadId,
                                          onChanged: (value) =>
                                              _loadLeadData(lead),
                                          child: Radio<String>(value: lead.id),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lead.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${lead.serviceType} • ${lead.property}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '₦${(lead.estimatedValue / 1000000).toStringAsFixed(1)}M',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 2: Client Information
                  _buildSection(
                    title: 'Client Information',
                    child: Column(
                      children: [
                        MyTextFormField(
                          controller: clientNameController,
                          hintText: 'Enter client name',
                          title: 'Client Name',
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Client name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          controller: clientEmailController,
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
                        MyTextFormField(
                          controller: clientPhoneController,
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
                        MyTextFormField(
                          controller: clientAddressController,
                          hintText: 'Enter client address',
                          title: 'Address (Optional)',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 3: Service Information
                  _buildSection(
                    title: 'Service Information',
                    child: Column(
                      children: [
                        const MyText(
                          'Service Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            value: selectedServiceType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            items: [
                              'Real Estate',
                              'Land Survey',
                              'Property Management',
                              'Estate Management',
                              'Construction',
                            ].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedServiceType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          controller: propertyAddressController,
                          hintText: 'Enter property address',
                          title: 'Property Address',
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Property address is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          controller: propertyDetailsController,
                          hintText:
                              'Enter property details (size, location, etc.)',
                          title: 'Property Details (Optional)',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 4: Invoice Items
                  _buildSection(
                    title: 'Invoice Items',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (invoiceItems.isNotEmpty) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: List.generate(
                                invoiceItems.length,
                                (index) {
                                  final item = invoiceItems[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: index < invoiceItems.length - 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.description,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${item.quantity} × ₦${item.unitPrice.toStringAsFixed(2)} = ₦${item.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 20, color: Colors.red),
                                          onPressed: () =>
                                              _removeInvoiceItem(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Add Item Form
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText(
                                'Add Item',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              MyTextFormField(
                                controller: itemDescriptionController,
                                hintText: 'Item description',
                                title: 'Description',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: MyTextFormField(
                                      controller: itemQuantityController,
                                      hintText: '1',
                                      title: 'Quantity',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: MyTextFormField(
                                      controller: itemUnitPriceController,
                                      hintText: '0.00',
                                      title: 'Unit Price (₦)',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              MyElevatedButton(
                                child: 'Add Item',
                                bgColor: AppColors.blue,
                                onTap: _addInvoiceItem,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 5: Financial Details
                  _buildSection(
                    title: 'Financial Details',
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              _buildFinancialRow(
                                'Subtotal:',
                                '₦${subtotal.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 16),
                              _buildFinancialRow(
                                'Tax (${taxRate.toStringAsFixed(1)}%):',
                                '₦${taxAmount.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 16),
                              _buildFinancialRow(
                                'Discount:',
                                '₦${discount.toStringAsFixed(2)}',
                              ),
                              const Divider(height: 24),
                              _buildFinancialRow(
                                'Total:',
                                '₦${total.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                initialValue: taxRate.toString(),
                                hintText: '7.5',
                                title: 'Tax Rate (%)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      taxRate = double.tryParse(value) ?? 7.5;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MyTextFormField(
                                initialValue: discount.toString(),
                                hintText: '0',
                                title: 'Discount (₦)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      discount = double.tryParse(value) ?? 0;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MyTextFormField(
                                initialValue: daysUntilDue.toString(),
                                hintText: '30',
                                title: 'Days Until Due',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      daysUntilDue = int.tryParse(value) ?? 30;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 6: Additional Notes
                  _buildSection(
                    title: 'Additional Information',
                    child: MyTextFormField(
                      controller: notesController,
                      hintText: 'Add any notes for the invoice',
                      title: 'Notes (Optional)',
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Clear Form',
                          bgColor: Colors.grey[200] ?? Colors.grey,
                          textColor: Colors.black87,
                          onTap: _resetForm,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Generate Invoice',
                          bgColor: AppColors.blue,
                          onTap: _generateInvoice,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    clientNameController.dispose();
    clientEmailController.dispose();
    clientPhoneController.dispose();
    clientAddressController.dispose();
    propertyAddressController.dispose();
    propertyDetailsController.dispose();
    itemDescriptionController.dispose();
    itemQuantityController.dispose();
    itemUnitPriceController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
