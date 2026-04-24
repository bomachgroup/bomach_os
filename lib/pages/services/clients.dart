import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/client_controller.dart';
import 'models/client_model.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ClientController _controller = Get.put(ClientController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Client List',
        subtitle: 'View and manage all clients across your services',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(
            Iconsax.add_circle,
            color: AppColors.textOnPrimary,
            size: 18,
          ),
          child: 'Add Client',
          onTap: _showAddClientDialog,
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          if (_controller.errorMessage.isNotEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Unable to load clients',
                subtitle: _controller.errorMessage.value,
                action: MyElevatedButton(
                  child: 'Retry',
                  icon: const Icon(
                    Iconsax.refresh,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  onTap: () => _controller.fetchClients(),
                ),
              ),
            );
          }

          final loading =
              _controller.isLoading.value && _controller.clients.isEmpty;
          final isEmpty =
              !_controller.isLoading.value && _controller.clients.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            body: _buildClientTable(_controller.clients),
            footer: (!loading && _controller.clients.isNotEmpty)
                ? _tablePaginator(
                    Obx(() {
                      final currentPage = _controller.currentPage.value;
                      final hasNextPage =
                          _controller.clients.length >= _controller.limit;
                      final derivedTotal = hasNextPage
                          ? currentPage * _controller.limit + 1
                          : (currentPage - 1) * _controller.limit +
                              _controller.clients.length;

                      return PaginatorFooter(
                        totalItems: derivedTotal,
                        limit: _controller.limit,
                        currentPage: currentPage,
                        onPageChanged: (page) => _controller.goToPage(
                          page,
                          search: _searchController.text.trim().isEmpty
                              ? null
                              : _searchController.text.trim(),
                        ),
                      );
                    }),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search by client name, email or phone',
        height: 48,
        leading: const Icon(
          Iconsax.search_normal,
          size: 18,
          color: AppColors.textMuted,
        ),
        onChanged: (val) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == val) {
              _controller.fetchClients(search: val.trim());
            }
          });
        },
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required Widget body,
    Widget? footer,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Client directory', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading clients...'
                            : '${_controller.clients.length} client${_controller.clients.length == 1 ? '' : 's'} on this page',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Active clients',
                  tone: StatusTone.primary,
                  icon: Iconsax.profile_2user,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.profile_2user,
                title: 'No clients yet',
                subtitle: 'Add your first client to start tracking services.',
                action: MyElevatedButton(
                  child: 'Add Client',
                  icon: const Icon(
                    Iconsax.add_circle,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  onTap: _showAddClientDialog,
                ),
              ),
            )
          else
            body,
          if (footer != null) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _tablePaginator(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: child,
    );
  }

  Widget _buildClientTable(List<Client> clients) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Client', flex: 4),
              _buildHeaderCell('Contact', flex: 3),
              _buildHeaderCell('Address', flex: 3),
              _buildHeaderCell('Balance', flex: 2),
              _buildHeaderCell('Status', flex: 2),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...clients.map((c) => _buildClientRow(c)),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildClientRow(Client client) {
    final hasPicture = client.profilePicture != null &&
        client.profilePicture!.isNotEmpty &&
        client.profilePicture != 'string';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primarySubtle,
                  backgroundImage:
                      hasPicture ? NetworkImage(client.profilePicture!) : null,
                  child: !hasPicture
                      ? Text(
                          client.firstName.isNotEmpty
                              ? client.firstName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.email.isEmpty ? '—' : client.email,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              client.phoneNumber.isEmpty ? '—' : client.phoneNumber,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              client.address.isEmpty ? '—' : client.address,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₦${_formatCurrency(client.balance)}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: client.balance > 0 ? 'Active' : 'Prospect',
                tone: client.balance > 0
                    ? StatusTone.success
                    : StatusTone.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    DialogScaffold.show(
      context,
      title: 'Add New Client',
      subtitle: 'Fill in the client details below',
      size: DialogSize.md,
      body: _AddClientForm(
        formKey: formKey,
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        phoneController: phoneController,
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(() => MyElevatedButton(
              child: 'Add Client',
              width: 160,
              height: 44,
              isLoading: _controller.isSaving.value,
              onTap: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  final clientData = {
                    'email': emailController.text.trim(),
                    'first_name': firstNameController.text.trim(),
                    'last_name': lastNameController.text.trim(),
                    'phone_number': phoneController.text.trim(),
                  };

                  final success = await _controller.createClient(clientData);

                  if (!mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    AppToast.success(
                      context,
                      '${firstNameController.text} added successfully',
                    );
                  } else {
                    AppToast.error(
                      context,
                      'Failed to add client. Please try again.',
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  AppToast.error(context, 'Error: ${e.toString()}');
                }
              },
            )),
      ],
    );
  }
}

class _AddClientForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _AddClientForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyTextFormField(
            controller: firstNameController,
            hintText: 'Enter first name',
            title: 'First Name*',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: lastNameController,
            hintText: 'Enter last name',
            title: 'Last Name*',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: emailController,
            hintText: 'Enter email address',
            title: 'Email Address*',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: phoneController,
            hintText: 'e.g., +2349012345678',
            title: 'Phone Number*',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

