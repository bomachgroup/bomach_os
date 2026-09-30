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
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/service_controller.dart';
import '../models/service_model.dart';

class CreateQuoteDialog extends StatefulWidget {
  const CreateQuoteDialog({super.key});

  @override
  State<CreateQuoteDialog> createState() => _CreateQuoteDialogState();
}

class _CreateQuoteDialogState extends State<CreateQuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  // Form controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _statusController = TextEditingController();
  final _clientSearchController = TextEditingController();

  // Client search state
  List<Client> _allClients = [];
  List<Client> _filteredClients = [];
  Client? _selectedClient;
  bool _isLoadingClients = true;
  bool _showClientDropdown = false;

  // Service selection
  Service? _selectedService;
  final _serviceController = TextEditingController();

  // Date
  DateTime? _validUntil;

  // Status
  String _selectedStatus = 'draft';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _statusController.text = 'Draft';
    _loadClients();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _statusController.dispose();
    _clientSearchController.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePopover(
      context,
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

      final data = {
        'client_id': _selectedClient!.id.toString(),
        'service_id': _selectedService!.id,
        'description': _descriptionController.text.trim(),
        'amount': double.parse(_amountController.text.replaceAll(',', '').trim()),
        'valid_until': DateFormat('yyyy-MM-dd').format(_validUntil!),
        'status': _selectedStatus,
        'created_by': userId,
      };

      final success = await controller.createQuote(data);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar('Quote created successfully');
      } else if (mounted) {
        _showErrorSnackbar('Failed to create quote. Please try again.');
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
      title: 'Create New Quote',
      subtitle: 'Draft a priced quote and send it to a client.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'Client & service',
              children: [
                _buildClientSearch(),
                const SizedBox(height: 16),
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
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Quote details',
              children: [
                MyTextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  hintText: 'Enter quote description',
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
                        hintText: 'e.g., 50,000',
                        title: 'Amount (NGN)*',
                        isFormattedNumber: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(value.replaceAll(',', '')) == null) {
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
                  controller: _statusController,
                  hintText: 'Select status',
                  items: const [
                    'Draft',
                    'Sent',
                    'Accepted',
                    'Rejected',
                    'Expired',
                  ],
                  title: 'Status*',
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value?.toLowerCase() ?? 'draft';
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
          child: 'Create Quote',
          onTap: _handleSubmit,
        ),
      ],
    );
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
                        ? DateFormat('dd-MM-yyyy').format(date)
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
