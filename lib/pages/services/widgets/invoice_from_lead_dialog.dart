import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
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
          'All prices are in Nigerian Naira (₦).',
    );

    // Show success message
    AppToast.success(context, 'Invoice ${invoice.invoiceNumber} generated successfully');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
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
                // Header
                const MyText(
                  'Generate Invoice from Lead',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                MyText(
                  'Create an invoice for: ${widget.lead.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Lead Summary
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
                      MyText(
                        widget.lead.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.lead.email} | ${widget.lead.phone}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service: ${widget.lead.serviceType}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Value: ₦${widget.lead.estimatedValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Invoice Items Section
                const MyText(
                  'Invoice Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Items List
                if (invoiceItems.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
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
                                  ? Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!),
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
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
                                IconButton(
                                  icon: const Icon(Iconsax.close_circle,
                                      size: 20, color: Colors.red),
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

                const SizedBox(height: 16),

                // Add Item Section
                ExpansionTile(
                  title: const Text('Add Another Item'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
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
                                  title: 'Unit Price (₦)',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          MyElevatedButton(
                            child: 'Add Item',
                            bgColor: AppColors.primary,
                            onTap: _addInvoiceItem,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Financial Details
                const MyText(
                  'Financial Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(
                            '₦${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax (${taxRate.toStringAsFixed(1)}%):'),
                          Text(
                            '₦${taxAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:'),
                          Text(
                            '₦${discount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const MyText(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          MyText(
                            '₦${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Terms
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

                const SizedBox(height: 28),

                // Action Buttons
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
                        child: 'Generate Invoice',
                        bgColor: AppColors.primary,
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
