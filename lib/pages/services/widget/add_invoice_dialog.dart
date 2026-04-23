import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class InvoiceItem {
  String description;
  int quantity;
  double unitPrice;

  InvoiceItem({
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
  });

  double get total => quantity * unitPrice;
}

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({super.key});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  // Form values
  String? _selectedServiceType;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _taxRate = 7.5;

  // Invoice items
  final List<InvoiceItem> _items = [InvoiceItem()];

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  double get _discount {
    return double.tryParse(_discountController.text) ?? 0;
  }

  double get _taxAmount {
    return (_subtotal - _discount) * (_taxRate / 100);
  }

  double get _total {
    return _subtotal - _discount + _taxAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.h3('Create Invoice'),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Service Information'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MyDropdown(
                              items: const [
                                'Real Estate',
                                'Land Survey',
                                'Property Management',
                                'Estate Management',
                              ],
                              hintText: 'Select service type',
                              title: 'Service Type*',
                              spaceBetweenText: 8,
                              onChanged: (value) {
                                setState(() {
                                  _selectedServiceType = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              items: const [],
                              hintText: 'Select order (optional)',
                              title: 'Link to Order',
                              spaceBetweenText: 8,
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Client Information'),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: _clientNameController,
                        hintText: 'Enter client name',
                        title: 'Client Name*',
                        spaceBetweenText: 8,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _clientEmailController,
                              hintText: 'client@example.com',
                              title: 'Email',
                              spaceBetweenText: 8,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _clientPhoneController,
                              hintText: '+234 XXX XXX XXXX',
                              title: 'Phone',
                              spaceBetweenText: 8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: _clientAddressController,
                        hintText: 'Enter client address',
                        title: 'Address',
                        spaceBetweenText: 8,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Invoice Items'),
                      const SizedBox(height: 16),
                      ..._buildInvoiceItems(),
                      const SizedBox(height: 12),
                      MyOutlinedButton(
                        textColor: AppColors.primary,
                        borderColor: AppColors.primary,
                        icon: const Icon(Iconsax.add,
                            size: 18, color: AppColors.primary),
                        child: 'Add Item',
                        onTap: () {
                          setState(() {
                            _items.add(InvoiceItem());
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Invoice Details'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Issue Date*',
                              _issueDate,
                              (date) => setState(() => _issueDate = date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              'Due Date*',
                              _dueDate,
                              (date) => setState(() => _dueDate = date),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _discountController,
                              hintText: '0',
                              title: 'Discount (₦)',
                              spaceBetweenText: 8,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              initialValue: _taxRate.toString(),
                              hintText: '7.5',
                              title: 'Tax Rate (%)',
                              spaceBetweenText: 8,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _taxRate = double.tryParse(value) ?? 7.5;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: _notesController,
                        hintText: 'Add any additional notes or terms',
                        title: 'Notes',
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _buildSummary(),
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
                  top: BorderSide(color: AppColors.neutral300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.h4(
                    'Total: ₦${NumberFormat('#,###.##').format(_total)}',
                    color: AppColors.primary,
                  ),
                  Row(
                    children: [
                      MyOutlinedButton(
                        textColor: AppColors.neutral500,
                        borderColor: null,
                        child: 'Cancel',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      MyElevatedButton(
                        icon: SvgPicture.asset(
                          "assets/svg/check.svg",
                          colorFilter: const ColorFilter.mode(
                              AppColors.white, BlendMode.srcIn),
                        ),
                        child: 'Create Invoice',
                        onTap: _handleCreateInvoice,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText.bodyLg(
      title,
      fontWeight: FontWeight.w600,
      color: AppColors.neutral700,
    );
  }

  List<Widget> _buildInvoiceItems() {
    return _items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.bodyMd(
                    'Item ${index + 1}',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 20),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            MyTextFormField(
              initialValue: item.description,
              hintText: 'Description of service/item',
              title: 'Description*',
              spaceBetweenText: 8,
              onChanged: (value) {
                setState(() {
                  item.description = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MyTextFormField(
                    initialValue: item.quantity.toString(),
                    hintText: '1',
                    title: 'Quantity*',
                    spaceBetweenText: 8,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        item.quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: MyTextFormField(
                    initialValue: item.unitPrice.toString(),
                    hintText: '0.00',
                    title: 'Unit Price (₦)*',
                    spaceBetweenText: 8,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.unitPrice = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodySm(
                        'Total',
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText.bodyMd(
                          '₦${NumberFormat('#,###.##').format(item.total)}',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodySm(
          label,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bodySm(
                  DateFormat('dd MMM yyyy').format(date),
                ),
                const Icon(Iconsax.calendar_1, size: 18, color: AppColors.neutral500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.bodyMd(
            'Invoice Summary',
            fontWeight: FontWeight.w600,
            color: AppColors.neutral700,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
              'Subtotal:', '₦${NumberFormat('#,###.##').format(_subtotal)}'),
          const SizedBox(height: 12),
          _buildSummaryRow(
              'Discount:', '-₦${NumberFormat('#,###.##').format(_discount)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax ($_taxRate%):',
              '₦${NumberFormat('#,###.##').format(_taxAmount)}'),
          const SizedBox(height: 16),
          Divider(color: AppColors.neutral300),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total:',
            '₦${NumberFormat('#,###.##').format(_total)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isTotal
            ? AppText.h4(label, color: AppColors.neutral700)
            : AppText.bodyMd(label, color: AppColors.neutral500),
        isTotal
            ? AppText.h4(value, color: AppColors.primary)
            : AppText.bodyMd(value, fontWeight: FontWeight.w600, color: AppColors.neutral700),
      ],
    );
  }

  void _handleCreateInvoice() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedServiceType == null) {
        AppToast.error(context, 'Please select a service type');
        return;
      }

      if (_items.isEmpty || _items.every((item) => item.description.isEmpty)) {
        AppToast.error(context, 'Please add at least one invoice item');
        return;
      }

      Navigator.pop(context);
      AppToast.success(context, 'Invoice created successfully');
    }
  }
}
