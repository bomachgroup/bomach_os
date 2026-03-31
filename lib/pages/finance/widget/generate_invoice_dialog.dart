import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/models/invoice_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GenerateInvoiceDialog extends StatefulWidget {
  final String? serviceType;
  final String? serviceId;
  final String? projectId;
  final Function(Invoice) onInvoiceGenerated;

  const GenerateInvoiceDialog({
    super.key,
    this.serviceType,
    this.serviceId,
    this.projectId,
    required this.onInvoiceGenerated,
  });

  @override
  State<GenerateInvoiceDialog> createState() => _GenerateInvoiceDialogState();
}

class _GenerateInvoiceDialogState extends State<GenerateInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  String _selectedServiceType = 'Real Estate';
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _taxRate = 7.5;
  double _discount = 0;

  // Invoice items
  final List<InvoiceItemInput> _items = [
    InvoiceItemInput(
      descriptionController: TextEditingController(),
      quantityController: TextEditingController(text: '1'),
      unitPriceController: TextEditingController(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.serviceType != null) {
      _selectedServiceType = widget.serviceType!;
    }

    // Set default terms and conditions
    _termsController.text =
        '''Payment is due within 30 days from the invoice date.
Late payments may incur additional charges.
All prices are in Nigerian Naira (₦).''';
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItemInput(
        descriptionController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        unitPriceController: TextEditingController(),
      ));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in _items) {
      final qty = double.tryParse(item.quantityController.text) ?? 0;
      final price = double.tryParse(item.unitPriceController.text) ?? 0;
      subtotal += qty * price;
    }
    return subtotal;
  }

  double _calculateTax(double subtotal) {
    return subtotal * (_taxRate / 100);
  }

  double _calculateTotal(double subtotal, double tax) {
    return subtotal + tax - _discount;
  }

  Future<void> _selectDate(bool isIssueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _generateInvoice() {
    if (_formKey.currentState?.validate() ?? false) {
      // Generate invoice number
      final now = DateTime.now();
      final invoiceNumber =
          'INV-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

      // Create invoice items
      final items = _items.map((item) {
        final qty = int.tryParse(item.quantityController.text) ?? 1;
        final price = double.tryParse(item.unitPriceController.text) ?? 0;
        return InvoiceItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: item.descriptionController.text,
          quantity: qty,
          unitPrice: price,
          amount: qty * price,
          unit: item.unit,
        );
      }).toList();

      final subtotal = _calculateSubtotal();
      final taxAmount = _calculateTax(subtotal);
      final total = _calculateTotal(subtotal, taxAmount);

      final invoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceNumber: invoiceNumber,
        clientId: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text.isEmpty
            ? null
            : _clientEmailController.text,
        clientPhone: _clientPhoneController.text.isEmpty
            ? null
            : _clientPhoneController.text,
        clientAddress: _clientAddressController.text.isEmpty
            ? null
            : _clientAddressController.text,
        serviceType: _selectedServiceType,
        serviceId: widget.serviceId,
        projectId: widget.projectId,
        items: items,
        subtotal: subtotal,
        taxRate: _taxRate,
        taxAmount: taxAmount,
        discount: _discount,
        totalAmount: total,
        issueDate: _issueDate,
        dueDate: _dueDate,
        status: InvoiceStatus.draft,
        paymentStatus: PaymentStatus.unpaid,
        amountPaid: 0,
        balance: total,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        termsAndConditions:
            _termsController.text.isEmpty ? null : _termsController.text,
        createdBy: 'Current User', // Replace with actual user
        createdDate: DateTime.now(),
      );

      widget.onInvoiceGenerated(invoice);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final tax = _calculateTax(subtotal);
    final total = _calculateTotal(subtotal, tax);

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
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
                    const MyText(
                      'Generate Invoice',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

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
                            // Service Type and Dates
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyDropdown(
                                        items: const [
                                          'Real Estate',
                                          'Land Survey',
                                          'Property Management',
                                          'Estate Management',
                                          'Construction',
                                          'Consulting',
                                          'Other'
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Issue and Due Dates
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const MyText(
                                        'Issue Date*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () => _selectDate(true),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.grey4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MyText(_formatDate(_issueDate)),
                                              const Icon(Icons.calendar_today,
                                                  size: 18),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const MyText(
                                        'Due Date*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () => _selectDate(false),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.grey4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MyText(_formatDate(_dueDate)),
                                              const Icon(Icons.calendar_today,
                                                  size: 18),
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

                            // Client Information
                            const MyText(
                              'Client Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            MyTextFormField(
                              controller: _clientNameController,
                              hintText: 'Enter client name',
                              spaceBetweenText: 10,
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
                                    hintText: 'Enter email',
                                    spaceBetweenText: 10,
                                    title: 'Email',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: MyTextFormField(
                                    controller: _clientPhoneController,
                                    hintText: 'Enter phone number',
                                    spaceBetweenText: 10,
                                    title: 'Phone',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            MyTextFormField(
                              controller: _clientAddressController,
                              hintText: 'Enter client address',
                              spaceBetweenText: 10,
                              title: 'Address',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),

                            // Invoice Items
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const MyText(
                                  'Invoice Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                MyOutlinedButton(
                                  textColor: AppColors.blue,
                                  borderColor: AppColors.blue,
                                  child: 'Add Item',
                                  onTap: _addItem,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            ..._items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _buildInvoiceItem(item, index);
                            }),

                            const SizedBox(height: 24),

                            // Financial Summary
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.grey4),
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow('Subtotal', subtotal),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          'Tax Rate (%)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: MyTextFormField(
                                          hintText: '7.5',
                                          onChanged: (value) {
                                            setState(() {
                                              _taxRate = double.tryParse(
                                                      value) ??
                                                  7.5;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow('Tax Amount', tax),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          'Discount',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: MyTextFormField(
                                          hintText: '0.00',
                                          onChanged: (value) {
                                            setState(() {
                                              _discount = double.tryParse(
                                                      value) ??
                                                  0;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 32),
                                  _buildSummaryRow('Total Amount', total,
                                      isTotal: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Notes
                            MyTextFormField(
                              controller: _notesController,
                              hintText: 'Additional notes or comments',
                              spaceBetweenText: 10,
                              title: 'Notes',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Terms and Conditions
                            MyTextFormField(
                              controller: _termsController,
                              hintText: 'Terms and conditions',
                              spaceBetweenText: 10,
                              title: 'Terms & Conditions',
                              maxLines: 4,
                            ),
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
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.darkGrey1,
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
                      child: 'Generate Invoice',
                      onTap: _generateInvoice,
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

  Widget _buildInvoiceItem(InvoiceItemInput item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: MyTextFormField(
                  controller: item.descriptionController,
                  hintText: 'Item description',
                  spaceBetweenText: 10,
                  title: 'Description*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyTextFormField(
                  controller: item.quantityController,
                  hintText: '1',
                  spaceBetweenText: 10,
                  title: 'Qty*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MyTextFormField(
                  controller: item.unitPriceController,
                  hintText: '0.00',
                  spaceBetweenText: 10,
                  title: 'Unit Price*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              if (_items.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeItem(index),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        MyText(
          '₦${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.blue : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class InvoiceItemInput {
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  String? unit;

  InvoiceItemInput({
    required this.descriptionController,
    required this.quantityController,
    required this.unitPriceController,
    this.unit,
  });

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}
