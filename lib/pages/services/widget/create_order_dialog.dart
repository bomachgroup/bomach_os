import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/models/client_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/service_controller.dart';
import '../models/service_model.dart';

class CreateOrderDialog extends StatefulWidget {
  const CreateOrderDialog({super.key});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  // Form controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _orderStatusController = TextEditingController();
  // final _paymentStatusController = TextEditingController();
  // final _assignedToController = TextEditingController();
  final _clientSearchController = TextEditingController();
  final _quoteSearchController = TextEditingController();

  // Client search state
  List<Client> _allClients = [];
  List<Client> _filteredClients = [];
  Client? _selectedClient;
  bool _isLoadingClients = true;
  bool _showClientDropdown = false;

  // Quote search state
  List<Quote> _filteredQuotes = [];
  Quote? _selectedQuote;
  bool _showQuoteDropdown = false;

  // Service selection
  Service? _selectedService;
  final _serviceController = TextEditingController();

  // Date
  DateTime? _validUntil;

  // Statuses
  String _selectedOrderStatus = 'pending';
  // final String _selectedPaymentStatus = 'unpaid';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _orderStatusController.text = 'Pending';
    // _paymentStatusController.text = 'Unpaid';
    _loadClients();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _orderStatusController.dispose();
    // _paymentStatusController.dispose();
    // _assignedToController.dispose();
    _clientSearchController.dispose();
    _quoteSearchController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;

      final clients = await _authService.getClients(token);
      if (mounted) {
        setState(() {
          _allClients = clients;
          _filteredClients = clients;
          _isLoadingClients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClients = false;
        });
      }
    }
  }

  void _filterClients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _allClients;
      } else {
        _filteredClients = _allClients
            .where((client) =>
                client.fullName.toLowerCase().contains(query.toLowerCase()) ||
                client.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showClientDropdown = true;
    });
  }

  void _selectClient(Client client) {
    setState(() {
      _selectedClient = client;
      _clientSearchController.text = client.fullName;
      _showClientDropdown = false;
    });
  }

  void _filterQuotes(String query) {
    final controller = Get.find<ServiceController>();
    setState(() {
      if (query.isEmpty) {
        _filteredQuotes = controller.quotes.toList();
      } else {
        _filteredQuotes = controller.quotes
            .where((quote) =>
                quote.quoteNumber.toLowerCase().contains(query.toLowerCase()) ||
                quote.service.name
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                quote.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showQuoteDropdown = true;
    });
  }

  void _selectQuote(Quote quote) {
    setState(() {
      _selectedQuote = quote;
      _quoteSearchController.text =
          '${quote.quoteNumber} - ${quote.service.name}';
      _showQuoteDropdown = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _validUntil = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClient == null) {
      _showErrorSnackbar('Please select a client');
      return;
    }

    if (_selectedService == null) {
      _showErrorSnackbar('Please select a service');
      return;
    }

    if (_validUntil == null) {
      _showErrorSnackbar('Please select a valid until date');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        _showErrorSnackbar('User ID not found. Please login again.');
        return;
      }

      final controller = Get.find<ServiceController>();

      final data = <String, dynamic>{
        'client_id': _selectedClient!.id.toString(),
        'service_id': _selectedService!.id,
        'description': _descriptionController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'order_status': _selectedOrderStatus,
        // 'payment_status': _selectedPaymentStatus,
        'valid_until': DateFormat('yyyy-MM-dd').format(_validUntil!),
        'created_by': userId,
        'assigned_to': userId,
      };

      if (_selectedQuote != null) {
        data['quote_id'] = _selectedQuote!.id;
      }

      final order = await controller.createOrder(data);

      if (order != null && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar('Order created successfully');
      } else if (mounted) {
        _showErrorSnackbar('Failed to create order. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    AppToast.error(context, message);
  }

  void _showSuccessSnackbar(String message) {
    AppToast.success(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final serviceController = Get.find<ServiceController>();

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
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
                      'Create New Order',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Search
                        _buildClientSearch(),
                        const SizedBox(height: 24),

                        // Quote Search
                        _buildQuoteSearch(serviceController),
                        const SizedBox(height: 24),

                        // Service Selection
                        Obx(() {
                          if (serviceController.isLoading.value) {
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'Service*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(child: CircularProgressIndicator()),
                              ],
                            );
                          }

                          final serviceItems = serviceController.services
                              .map((s) => s.name)
                              .toList();

                          return MyDropdown(
                            controller: _serviceController,
                            items: serviceItems,
                            hintText: 'Select a service',
                            spaceBetweenText: 10,
                            title: 'Service*',
                            onChanged: (value) {
                              if (value != null) {
                                final selected = serviceController.services
                                    .firstWhere((s) => s.name == value);
                                setState(() {
                                  _selectedService = selected;
                                });
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 24),

                        // Description
                        MyTextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          hintText: 'Enter order description',
                          spaceBetweenText: 10,
                          title: 'Description*',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Amount and Valid Until
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                controller: _amountController,
                                hintText: 'e.g., 50000',
                                spaceBetweenText: 10,
                                title: 'Amount (₦)*',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Amount is required';
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Valid Until*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppColors.neutral300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _validUntil != null
                                                  ? DateFormat('MMM dd, yyyy')
                                                      .format(_validUntil!)
                                                  : 'Select date',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _validUntil != null
                                                    ? Colors.black87
                                                    : AppColors.neutral500,
                                              ),
                                            ),
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

                        // Order Status and Payment Status
                        Row(
                          children: [
                            Expanded(
                              child: MyDropdown(
                                controller: _orderStatusController,
                                spaceBetweenText: 10,
                                hintText: 'Select order status',
                                items: const [
                                  'Pending',
                                  'In Progress',
                                  'Completed',
                                  'Cancelled',
                                ],
                                title: 'Order Status*',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOrderStatus =
                                        _orderStatusToApi(value ?? 'Pending');
                                  });
                                },
                              ),
                            ),
                            // const SizedBox(width: 16),
                            // Expanded(
                            //   child: MyDropdown(
                            //     controller: _paymentStatusController,
                            //     spaceBetweenText: 10,
                            //     hintText: 'Select payment status',
                            //     items: const [
                            //       'Unpaid',
                            //       'Partially Paid',
                            //       'Paid',
                            //       'Refunded',
                            //     ],
                            //     title: 'Payment Status*',
                            //     onChanged: (value) {
                            //       setState(() {
                            //         _selectedPaymentStatus =
                            //             _paymentStatusToApi(value ?? 'Unpaid');
                            //       });
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                        // const SizedBox(height: 24),

                        // Assigned To
                        // MyTextFormField(
                        //   controller: _assignedToController,
                        //   hintText: 'Enter employee ID (optional)',
                        //   spaceBetweenText: 10,
                        //   title: 'Assigned To',
                        // ),
                      ],
                    ),
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
                      textColor: AppColors.neutral500,
                      borderColor: null,
                      child: 'Cancel',
                      onTap: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                    const SizedBox(width: 16),
                    _isSubmitting
                        ? const SizedBox(
                            width: 120,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : MyElevatedButton(
                            icon: SvgPicture.asset(
                              "assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            child: 'Create Order',
                            onTap: _handleSubmit,
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

  String _orderStatusToApi(String display) {
    switch (display) {
      case 'Pending':
        return 'pending';
      case 'In Progress':
        return 'in_progress';
      case 'Completed':
        return 'completed';
      case 'Cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  Widget _buildClientSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Client*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        if (_isLoadingClients)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading clients...',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral500),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              TextFormField(
                controller: _clientSearchController,
                decoration: InputDecoration(
                  hintText: 'Search client by name or email...',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: AppColors.neutral500),
                  prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.neutral500),
                  suffixIcon: _selectedClient != null
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedClient = null;
                              _clientSearchController.clear();
                              _filteredClients = _allClients;
                              _showClientDropdown = false;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: _filterClients,
                onTap: () {
                  setState(() {
                    _showClientDropdown = true;
                  });
                },
              ),
              if (_showClientDropdown && _selectedClient == null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neutral300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _filteredClients.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No clients found',
                            style:
                                TextStyle(fontSize: 14, color: AppColors.neutral500),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredClients.length,
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            return InkWell(
                              onTap: () => _selectClient(client),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: index < _filteredClients.length - 1
                                      ? const Border(
                                          bottom: BorderSide(
                                              color: AppColors.neutral300,
                                              width: 0.5),
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.fullName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      client.email,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuoteSearch(ServiceController serviceController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Quote',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (serviceController.isLoadingQuotes.value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Loading quotes...',
                    style: TextStyle(fontSize: 14, color: AppColors.neutral500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TextFormField(
                controller: _quoteSearchController,
                decoration: InputDecoration(
                  hintText: 'Search by quote number or service name...',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: AppColors.neutral500),
                  prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.neutral500),
                  suffixIcon: _selectedQuote != null
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedQuote = null;
                              _quoteSearchController.clear();
                              _filteredQuotes =
                                  serviceController.quotes.toList();
                              _showQuoteDropdown = false;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: _filterQuotes,
                onTap: () {
                  if (_filteredQuotes.isEmpty) {
                    _filteredQuotes = serviceController.quotes.toList();
                  }
                  setState(() {
                    _showQuoteDropdown = true;
                  });
                },
              ),
              if (_showQuoteDropdown && _selectedQuote == null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neutral300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _filteredQuotes.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No quotes found',
                            style:
                                TextStyle(fontSize: 14, color: AppColors.neutral500),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredQuotes.length,
                          itemBuilder: (context, index) {
                            final quote = _filteredQuotes[index];
                            return InkWell(
                              onTap: () => _selectQuote(quote),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: index < _filteredQuotes.length - 1
                                      ? const Border(
                                          bottom: BorderSide(
                                              color: AppColors.neutral300,
                                              width: 0.5),
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${quote.quoteNumber} - ${quote.service.name}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₦${quote.amount} | ${quote.status.capitalizeFirst}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
