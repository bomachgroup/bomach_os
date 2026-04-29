import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
      AppToast.error(context, 'Please fill all item fields');
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

    AppToast.success(context, 'Item added successfully');
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      invoiceItems.removeAt(index);
    });
    AppToast.warning(context, 'Item removed');
  }

  void _generateInvoice() {
    if (!formKey.currentState!.validate()) {
      AppToast.error(context, 'Please fill all required fields');
      return;
    }

    if (invoiceItems.isEmpty) {
      AppToast.error(context, 'Please add at least one item');
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
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

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

  String _formatCurrency(double amount) => '₦${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Generate Invoice',
        subtitle: 'Create a new invoice for your service.',
      ),
      children: [
        Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 960;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormColumn()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildPreviewColumn()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormColumn(),
                  const SizedBox(height: 24),
                  _buildPreviewColumn(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeadSelectorCard(),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Client Information',
          subtitle: 'Who the invoice is being issued to.',
          icon: Iconsax.user,
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
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              MyTextFormField(
                controller: clientAddressController,
                hintText: 'Enter client address',
                title: 'Address (Optional)',
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Service Information',
          subtitle: 'The service being billed.',
          icon: Iconsax.briefcase,
          child: Column(
            children: [
              MyDropdown(
                title: 'Service Type',
                hintText: selectedServiceType,
                initialSelection: selectedServiceType,
                items: const [
                  'Real Estate',
                  'Land Survey',
                  'Property Management',
                  'Estate Management',
                  'Construction',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedServiceType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
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
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Invoice Items',
          subtitle: 'Line items included on this invoice.',
          icon: Iconsax.box,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (invoiceItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: EmptyState(
                    icon: Iconsax.box,
                    title: 'No items added yet',
                    subtitle: 'Use the form below to add your first line item.',
                    compact: true,
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSubtle),
                    borderRadius: AppRadii.brMd,
                  ),
                  child: Column(
                    children: List.generate(invoiceItems.length, (index) {
                      final item = invoiceItems[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: index < invoiceItems.length - 1
                              ? const Border(
                                  bottom:
                                      BorderSide(color: AppColors.borderSubtle),
                                )
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} × ${_formatCurrency(item.unitPrice)} = ${_formatCurrency(item.amount)}',
                                    style: AppTextStyles.bodySm,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: AppRadii.brSm,
                                onTap: () => _removeInvoiceItem(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.dangerSubtle,
                                    borderRadius: AppRadii.brSm,
                                  ),
                                  child: const Icon(
                                    Iconsax.trash,
                                    size: 16,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brMd,
                  border: Border.all(color: AppColors.primarySoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Item',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      icon: const Icon(Iconsax.add_circle,
                          size: 18, color: AppColors.textOnPrimary),
                      child: 'Add Item',
                      onTap: _addInvoiceItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Financial Details',
          subtitle: 'Tax, discount, and payment terms.',
          icon: Iconsax.money_recive,
          child: Column(
            children: [
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
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Additional Information',
          subtitle: 'Any extra notes to include on the invoice.',
          icon: Iconsax.note_2,
          child: MyTextFormField(
            controller: notesController,
            hintText: 'Add any notes for the invoice',
            title: 'Notes (Optional)',
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: MyOutlinedButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                icon: const Icon(Iconsax.refresh,
                    size: 18, color: AppColors.primary),
                child: 'Clear Form',
                onTap: _resetForm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyElevatedButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                icon: const Icon(Iconsax.document_text,
                    size: 18, color: AppColors.textOnPrimary),
                child: 'Generate Invoice',
                onTap: _generateInvoice,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeadSelectorCard() {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: const Icon(
                    Iconsax.user_search,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Existing Lead',
                        style: AppTextStyles.h4,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Optional — auto-fills client + service details.',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          ...List.generate(availableLeads.length, (index) {
            final lead = availableLeads[index];
            final isSelected = selectedLeadId == lead.id;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _loadLeadData(lead),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySubtle
                        : AppColors.surface,
                    border: index < availableLeads.length - 1
                        ? const Border(
                            bottom:
                                BorderSide(color: AppColors.borderSubtle),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Iconsax.tick_circle
                            : Iconsax.record_circle,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lead.serviceType} · ${lead.property}',
                              style: AppTextStyles.bodySm,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: AppRadii.brPill,
                        ),
                        child: Text(
                          '₦${(lead.estimatedValue / 1000000).toStringAsFixed(1)}M',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewColumn() {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: const Icon(
                    Iconsax.document_text,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invoice Preview', style: AppTextStyles.h4),
                      SizedBox(height: 2),
                      Text(
                        'Live calculation of totals.',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPreviewRow(
                  label: 'Bill To',
                  value: clientNameController.text.isEmpty
                      ? '—'
                      : clientNameController.text,
                ),
                const SizedBox(height: 10),
                _buildPreviewRow(
                  label: 'Service Type',
                  value: selectedServiceType,
                ),
                const SizedBox(height: 10),
                _buildPreviewRow(
                  label: 'Property',
                  value: propertyAddressController.text.isEmpty
                      ? '—'
                      : propertyAddressController.text,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadii.brMd,
                  ),
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        'Subtotal',
                        _formatCurrency(subtotal),
                      ),
                      const SizedBox(height: 10),
                      _buildFinancialRow(
                        'Tax (${taxRate.toStringAsFixed(1)}%)',
                        _formatCurrency(taxAmount),
                      ),
                      const SizedBox(height: 10),
                      _buildFinancialRow(
                        'Discount',
                        '- ${_formatCurrency(discount)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                            height: 1, color: AppColors.borderSubtle),
                      ),
                      _buildFinancialRow(
                        'Total',
                        _formatCurrency(total),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'} after issue.',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.h4),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTextStyles.h4 : AppTextStyles.bodyMd).copyWith(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: (isTotal ? AppTextStyles.h4 : AppTextStyles.bodyMd).copyWith(
            color: isTotal ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
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
