import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
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
    return DialogScaffold(
      title: 'Create Invoice',
      subtitle: 'Bill a client for services rendered.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'Service information',
              children: [
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
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Client information',
              children: [
                MyTextFormField(
                  controller: _clientNameController,
                  hintText: 'Enter client name',
                  title: 'Client Name*',
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        controller: _clientPhoneController,
                        hintText: '+234 XXX XXX XXXX',
                        title: 'Phone',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: _clientAddressController,
                  hintText: 'Enter client address',
                  title: 'Address',
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Invoice items',
              children: [
                ..._buildInvoiceItems(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAddLineItemButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add another line item to this invoice.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Invoice details',
              children: [
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
                        title: 'Discount (NGN)',
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
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummary(),
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
          onTap: () {
            Navigator.pop(context);
          },
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Create Invoice',
          onTap: _handleCreateInvoice,
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
            _items.add(InvoiceItem());
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
          child: const Icon(Iconsax.add, size: 20, color: AppColors.primary),
        ),
      ),
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
          color: AppColors.surface,
          borderRadius: AppRadii.brMd,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${index + 1}',
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 20),
                    color: AppColors.danger,
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            MyTextFormField(
              initialValue: item.description,
              hintText: 'Description of service/item',
              title: 'Description*',
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
                    title: 'Unit Price (NGN)*',
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
                      const Text('Total', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: AppRadii.brMd,
                          border: Border.all(color: AppColors.primarySoft),
                        ),
                        child: Text(
                          'NGN ${NumberFormat('#,###.##').format(item.total)}',
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
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
        Text(label, style: AppTextStyles.label),
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
          borderRadius: AppRadii.brMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadii.brMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: AppTextStyles.bodyMd,
                ),
                const Icon(Iconsax.calendar_1,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Invoice summary', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildSummaryRow(
              'Subtotal', 'NGN ${NumberFormat('#,###.##').format(_subtotal)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Discount',
              '-NGN ${NumberFormat('#,###.##').format(_discount)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax (${_taxRate.toStringAsFixed(1)}%)',
              'NGN ${NumberFormat('#,###.##').format(_taxAmount)}'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total',
            'NGN ${NumberFormat('#,###.##').format(_total)}',
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
