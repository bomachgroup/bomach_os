import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/service_invoice_model.dart';
import '../service_leads.dart';

class InvoiceFromLeadDialog extends StatefulWidget {
  final ServiceLead lead;

  const InvoiceFromLeadDialog({
    super.key,
    required this.lead,
  });

  @override
  State<InvoiceFromLeadDialog> createState() => _InvoiceFromLeadDialogState();
}

class _InvoiceFromLeadDialogState extends State<InvoiceFromLeadDialog> {
  final formKey = GlobalKey<FormState>();
  late List<ServiceInvoiceItem> invoiceItems;
  late TextEditingController itemDescriptionController;
  late TextEditingController itemQuantityController;
  late TextEditingController itemUnitPriceController;
  late TextEditingController notesController;

  double taxRate = 7.5;
  double discount = 0;
  int daysUntilDue = 30;

  bool _showAddItemForm = false;

  @override
  void initState() {
    super.initState();
    invoiceItems = [];
    itemDescriptionController = TextEditingController();
    itemQuantityController = TextEditingController();
    itemUnitPriceController = TextEditingController();
    notesController = TextEditingController();

    // Add default item based on service type
    _addDefaultItem();
  }

  void _addDefaultItem() {
    String defaultDescription = '';
    double defaultPrice = 0;

    switch (widget.lead.serviceType) {
      case 'Real Estate':
        defaultDescription = 'Land Purchase - ${widget.lead.property}';
        defaultPrice = widget.lead.estimatedValue;
        break;
      case 'Land Survey':
        defaultDescription = 'Land Survey Service - ${widget.lead.property}';
        defaultPrice = widget.lead.estimatedValue;
        break;
      case 'Property Management':
        defaultDescription =
            'Property Management Service - ${widget.lead.property}';
        defaultPrice = widget.lead.estimatedValue / 12; // Monthly
        break;
      default:
        defaultDescription = 'Service - ${widget.lead.property}';
        defaultPrice = widget.lead.estimatedValue;
    }

    invoiceItems.add(
      ServiceInvoiceItem(
        id: '1',
        description: defaultDescription,
        quantity: 1,
        unitPrice: defaultPrice,
        unit: 'service',
      ),
    );
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
      _showAddItemForm = false;
    });

    itemDescriptionController.clear();
    itemQuantityController.clear();
    itemUnitPriceController.clear();
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      invoiceItems.removeAt(index);
    });
  }

  void _generateInvoice() {
    if (invoiceItems.isEmpty) {
      AppToast.error(context, 'Please add at least one item');
      return;
    }

    final invoice = ServiceInvoice(
      id: UniqueKey().toString(),
      invoiceNumber: ServiceInvoice.generateInvoiceNumber(),
      leadId: widget.lead.id,
      clientName: widget.lead.name,
      clientEmail: widget.lead.email,
      clientPhone: widget.lead.phone,
      serviceType: widget.lead.serviceType,
      propertyAddress: widget.lead.property,
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
      termsAndConditions:
          'Payment is due within $daysUntilDue days from the invoice date.\n'
          'Late payments may incur additional charges.\n'
          'All prices are in Nigerian Naira (NGN).',
    );

    // Show success message
    AppToast.success(
        context, 'Invoice ${invoice.invoiceNumber} generated successfully');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Generate Invoice from Lead',
      subtitle: 'Create an invoice for ${widget.lead.name}.',
      size: DialogSize.lg,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadSummary(),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Invoice items',
              children: [
                if (invoiceItems.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: AppRadii.brMd,
                    ),
                    child: Column(
                      children: List.generate(
                        invoiceItems.length,
                        (index) {
                          final item = invoiceItems[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: index < invoiceItems.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderSubtle),
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
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantity} x NGN ${item.unitPrice.toStringAsFixed(2)} = NGN ${item.amount.toStringAsFixed(2)}',
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.trash,
                                      size: 20, color: AppColors.danger),
                                  splashRadius: 20,
                                  onPressed: () => _removeInvoiceItem(index),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAddLineItemButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _showAddItemForm
                            ? 'Fill out details for the new line item.'
                            : 'Add another line item to this invoice.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                if (_showAddItemForm) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.brMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
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
                                title: 'Unit Price (NGN)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyOutlinedButton(
                              child: 'Cancel',
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              textColor: AppColors.textSecondary,
                              borderColor: AppColors.borderStrong,
                              onTap: () {
                                setState(() {
                                  _showAddItemForm = false;
                                });
                                itemDescriptionController.clear();
                                itemQuantityController.clear();
                                itemUnitPriceController.clear();
                              },
                            ),
                            const SizedBox(width: 8),
                            MyElevatedButton(
                              child: 'Add Item',
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              onTap: _addInvoiceItem,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Payment terms',
              children: [
                Row(
                  children: [
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
                    const SizedBox(width: 12),
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
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: notesController,
                  hintText: 'Add any notes for the invoice',
                  title: 'Notes (Optional)',
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFinancialSummary(),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.pop(context),
        ),
        MyElevatedButton(
          child: 'Generate Invoice',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.document_text,
              size: 18, color: AppColors.textOnPrimary),
          onTap: _generateInvoice,
        ),
      ],
    );
  }

  Widget _buildAddLineItemButton() {
    return Material(
      color: AppColors.primarySubtle,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () {
          setState(() {
            _showAddItemForm = !_showAddItemForm;
          });
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.primarySoft),
          ),
          alignment: Alignment.center,
          child: Icon(
            _showAddItemForm ? Iconsax.minus : Iconsax.add,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLeadSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.user,
                    color: AppColors.textOnPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.lead.name, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.lead.email} | ${widget.lead.phone}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service: ${widget.lead.serviceType}',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Value: NGN ${widget.lead.estimatedValue.toStringAsFixed(0)}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial summary', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', 'NGN ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _summaryRow('Tax (${taxRate.toStringAsFixed(1)}%)',
              'NGN ${taxAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _summaryRow('Discount', 'NGN ${discount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),
          _summaryRow(
            'Total',
            'NGN ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h4
              : AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h4.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMd
                  .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    itemDescriptionController.dispose();
    itemQuantityController.dispose();
    itemUnitPriceController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
