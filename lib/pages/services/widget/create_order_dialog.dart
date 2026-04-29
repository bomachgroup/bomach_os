import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/pages/services/models/client_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

    return DialogScaffold(
      title: 'Create New Order',
      subtitle: 'Convert an opportunity into a priced, scheduled order.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'Client & quote',
              children: [
                _buildClientSearch(),
                const SizedBox(height: 16),
                _buildQuoteSearch(serviceController),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Order details',
              children: [
                Obx(() {
                  if (serviceController.isLoading.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service*', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.brMd,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading services...',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  hintText: 'Enter order description',
                  title: 'Description*',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        controller: _amountController,
                        hintText: 'e.g., 50000',
                        title: 'Amount (NGN)*',
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
                      child: _buildDatePickerField(
                        title: 'Valid Until*',
                        date: _validUntil,
                        onTap: _pickDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyDropdown(
                  controller: _orderStatusController,
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
              ],
            ),
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
          onTap: _isSubmitting
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isLoading: _isSubmitting,
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Create Order',
          onTap: _handleSubmit,
        ),
      ],
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

  Widget _buildDatePickerField({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadii.brMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select date',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Iconsax.calendar_1,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Client*', style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (_isLoadingClients)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadii.brMd,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading clients...',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              TextFormField(
                controller: _clientSearchController,
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Search client by name or email...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(Iconsax.search_normal,
                      size: 18, color: AppColors.textMuted),
                  suffixIcon: _selectedClient != null
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 18),
                          color: AppColors.textSecondary,
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
                  filled: true,
                  fillColor: AppColors.surface,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: AppColors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _filteredClients.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No clients found',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
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
                                              color: AppColors.borderSubtle,
                                              width: 0.5),
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.fullName,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      client.email,
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
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
        const Text('Quote', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Obx(() {
          if (serviceController.isLoadingQuotes.value) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: AppRadii.brMd,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading quotes...',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TextFormField(
                controller: _quoteSearchController,
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Search by quote number or service name...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(Iconsax.search_normal,
                      size: 18, color: AppColors.textMuted),
                  suffixIcon: _selectedQuote != null
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 18),
                          color: AppColors.textSecondary,
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
                  filled: true,
                  fillColor: AppColors.surface,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    color: AppColors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _filteredQuotes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No quotes found',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
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
                                              color: AppColors.borderSubtle,
                                              width: 0.5),
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${quote.quoteNumber} - ${quote.service.name}',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      quote.description,
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
}
