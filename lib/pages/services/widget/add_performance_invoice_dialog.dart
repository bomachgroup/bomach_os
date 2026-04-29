import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/input/upload_file.dart';
import 'package:bomach_os/components/text/app_text.dart';
import 'package:bomach_os/pages/services/models/estate_models.dart';
import 'package:bomach_os/pages/services/models/performance_invoice_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846, maxHeight: 800),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.h3('Add Performance Invoice'),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Invoice Number and Date
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _invoiceNumberController,
                                    hintText: 'Enter invoice number',
                                    spaceBetweenText: 10,
                                    title: 'Invoice Number*',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter invoice number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.bodySm(
                                        'Transaction Date*',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: _selectDate,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.neutral300),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppText.bodySm(
                                                '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                                              ),
                                              const Icon(
                                                Iconsax.calendar_1,
                                                size: 18,
                                                color: AppColors.neutral500,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Service Type
                            MyDropdown(
                              items: const [
                                'Real Estate',
                                'Land Survey',
                                'Property Management',
                                'Estate Management'
                              ],
                              hintText: 'Select service type',
                              spaceBetweenText: 10,
                              title: 'Service Type*',
                              onChanged: (value) {
                                setState(() {
                                  _selectedServiceType =
                                      value ?? 'Real Estate';
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Estate and Transaction Type
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
                                          spaceBetweenText: 10,
                                          title: 'Estate*',
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedEstate = value ?? '';
                                            });
                                          },
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppText.bodySm(
                                              'Estate',
                                              fontWeight: FontWeight.w500,
                                            ),
                                            const SizedBox(height: 10),
                                            AppText.bodyMd(
                                              widget.estate!.name,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ],
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
                                    spaceBetweenText: 10,
                                    title: 'Transaction Type*',
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTransactionType =
                                            value ?? 'Sale';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Amount and Amount Paid
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _amountController,
                                    hintText: 'Enter amount',
                                    spaceBetweenText: 10,
                                    title: 'Amount (₦)*',
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
                                    spaceBetweenText: 10,
                                    hintText: 'Enter amount paid',
                                    title: 'Amount Paid (₦)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Payment Method and Status
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
                                    spaceBetweenText: 10,
                                    title: 'Payment Method*',
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
                                    spaceBetweenText: 10,
                                    title: 'Payment Status*',
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentStatus =
                                            value ?? 'Paid';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Client Name and Phone
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _clientNameController,
                                    hintText: 'Enter client name',
                                    spaceBetweenText: 10,
                                    title: 'Client Name',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _clientPhoneController,
                                    spaceBetweenText: 10,
                                    hintText: 'Enter phone number',
                                    title: 'Client Phone',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Plot Number and Description
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _plotNumberController,
                                    hintText: 'e.g., Plot 001',
                                    spaceBetweenText: 10,
                                    title: 'Plot Number',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _clientEmailController,
                                    spaceBetweenText: 10,
                                    hintText: 'Enter email',
                                    title: 'Client Email',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Description
                            MyTextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              hintText: 'Enter transaction description',
                              spaceBetweenText: 10,
                              title: 'Description',
                            ),
                          ],
                        ),
                      ),

                      // Optional Section
                      const Divider(
                        color: AppColors.neutral200,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showOptionalFields = !_showOptionalFields;
                                });
                              },
                              child: Row(
                                children: [
                                  AppText.bodyLg(
                                    'Agent & Commission Details (Optional)',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _showOptionalFields
                                        ? Iconsax.arrow_up_3
                                        : Iconsax.arrow_down_1,
                                    size: 20,
                                    color: AppColors.neutral700,
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
                                      spaceBetweenText: 10,
                                      title: 'Agent Name',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: MyTextFormField(
                                      controller:
                                          _commissionPercentageController,
                                      spaceBetweenText: 10,
                                      hintText: 'Commission %',
                                      title: 'Commission Percentage',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AppText.bodySm(
                                'Upload Attachments (Receipt, Agreement, etc.)',
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: 8),
                              const UploadFile(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.neutral300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                      child: 'Save Invoice',
                      onTap: _saveInvoice,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
