import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/models/performance_invoice_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddPerformanceInvoiceDialog extends StatefulWidget {
  final Estate? estate;
  final Function(PerformanceInvoice) onInvoiceAdded;

  const AddPerformanceInvoiceDialog({
    super.key,
    this.estate,
    required this.onInvoiceAdded,
  });

  @override
  State<AddPerformanceInvoiceDialog> createState() =>
      _AddPerformanceInvoiceDialogState();
}

class _AddPerformanceInvoiceDialogState
    extends State<AddPerformanceInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;

  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _plotNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _agentNameController = TextEditingController();
  final _commissionPercentageController = TextEditingController();

  String _selectedEstate = '';
  String _selectedServiceType = 'Real Estate';
  String _selectedTransactionType = 'Sale';
  String _selectedPaymentMethod = 'Bank Transfer';
  String _selectedPaymentStatus = 'Paid';
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.estate != null) {
      _selectedEstate = widget.estate!.name;
    }

    // Generate invoice number
    final now = DateTime.now();
    _invoiceNumberController.text =
        'INV-${now.year}-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _amountController.dispose();
    _amountPaidController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _plotNumberController.dispose();
    _descriptionController.dispose();
    _agentNameController.dispose();
    _commissionPercentageController.dispose();
    super.dispose();
  }

  void _saveInvoice() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
      final commissionPercentage =
          double.tryParse(_commissionPercentageController.text);

      final invoice = PerformanceInvoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        estateId: widget.estate?.id.toString() ?? '1',
        estateName: _selectedEstate,
        plotNumber: _plotNumberController.text.isEmpty
            ? null
            : _plotNumberController.text,
        serviceType: _selectedServiceType,
        transactionType: _selectedTransactionType,
        amount: amount,
        transactionDate: _transactionDate,
        clientName: _clientNameController.text.isEmpty
            ? null
            : _clientNameController.text,
        clientPhone: _clientPhoneController.text.isEmpty
            ? null
            : _clientPhoneController.text,
        clientEmail: _clientEmailController.text.isEmpty
            ? null
            : _clientEmailController.text,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: _selectedPaymentStatus,
        amountPaid: amountPaid > 0 ? amountPaid : null,
        balance: amountPaid > 0 ? amount - amountPaid : amount,
        invoiceNumber: _invoiceNumberController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        agentName: _agentNameController.text.isEmpty
            ? null
            : _agentNameController.text,
        commissionAmount: commissionPercentage != null
            ? amount * (commissionPercentage / 100)
            : null,
        commissionPercentage: commissionPercentage,
        createdDate: DateTime.now(),
      );

      widget.onInvoiceAdded(invoice);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _transactionDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Performance Invoice',
      subtitle: 'Record a new transaction or invoice for an estate.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Invoice Details',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _invoiceNumberController,
                          hintText: 'Enter invoice number',
                          title: 'Invoice Number *',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter invoice number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDateField()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MyDropdown(
                    items: const [
                      'Real Estate',
                      'Land Survey',
                      'Property Management',
                      'Estate Management'
                    ],
                    hintText: 'Select service type',
                    title: 'Service Type *',
                    initialSelection: _selectedServiceType,
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceType = value ?? 'Real Estate';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: widget.estate == null
                            ? MyDropdown(
                                items: const [
                                  'Aso Villa Estate',
                                  'Fortress City Estate',
                                  'Victoria Gardens',
                                  'Diamond Heights'
                                ],
                                hintText: 'Select estate',
                                title: 'Estate *',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEstate = value ?? '';
                                  });
                                },
                              )
                            : _buildReadOnlyField(
                                label: 'Estate',
                                value: widget.estate!.name,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                          items: const [
                            'Sale',
                            'Reservation',
                            'Payment',
                            'Commission'
                          ],
                          hintText: 'Select type',
                          title: 'Transaction Type *',
                          initialSelection: _selectedTransactionType,
                          onChanged: (value) {
                            setState(() {
                              _selectedTransactionType = value ?? 'Sale';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Payment',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _amountController,
                          hintText: 'Enter amount',
                          title: 'Amount (₦) *',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: _amountPaidController,
                          hintText: 'Enter amount paid',
                          title: 'Amount Paid (₦)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MyDropdown(
                          items: const [
                            'Cash',
                            'Bank Transfer',
                            'Card',
                            'Cheque',
                            'Installment'
                          ],
                          hintText: 'Select method',
                          title: 'Payment Method *',
                          initialSelection: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod =
                                  value ?? 'Bank Transfer';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                          items: const [
                            'Paid',
                            'Pending',
                            'Partial',
                            'Failed'
                          ],
                          hintText: 'Select status',
                          title: 'Payment Status *',
                          initialSelection: _selectedPaymentStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentStatus = value ?? 'Paid';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Client & Property',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _clientNameController,
                          hintText: 'Enter client name',
                          title: 'Client Name',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: _clientPhoneController,
                          hintText: 'Enter phone number',
                          title: 'Client Phone',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _plotNumberController,
                          hintText: 'e.g., Plot 001',
                          title: 'Plot Number',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: _clientEmailController,
                          hintText: 'Enter email',
                          title: 'Client Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    hintText: 'Enter transaction description',
                    title: 'Description',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionalSection(),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          height: 44,
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: const Icon(Iconsax.tick_circle,
              color: AppColors.white, size: 16),
          child: 'Save Invoice',
          onTap: _saveInvoice,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Date *',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDate,
            borderRadius: AppRadii.brMd,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.brMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                  const Icon(
                    Iconsax.calendar_1,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.bodyMd
                .copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showOptionalFields = !_showOptionalFields;
              });
            },
            borderRadius: AppRadii.brSm,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Agent & Commission Details (Optional)',
                    style: AppTextStyles.h4,
                  ),
                ),
                Icon(
                  _showOptionalFields
                      ? Iconsax.arrow_up_3
                      : Iconsax.arrow_down_1,
                  size: 18,
                  color: AppColors.textSecondary,
                )
              ],
            ),
          ),
          if (_showOptionalFields) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: _agentNameController,
                    hintText: 'Agent name',
                    title: 'Agent Name',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: _commissionPercentageController,
                    hintText: 'Commission %',
                    title: 'Commission Percentage',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Attachments (Receipt, Agreement, etc.)',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            const UploadFile(),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
