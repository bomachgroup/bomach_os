import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/client_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchClients(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Client List",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "View and manage all clients",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              MyElevatedButton(
                child: 'Add Client',
                bgColor: AppColors.blue,
                icon: const Icon(Icons.add, color: Colors.white),
                onTap: _showAddClientDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) {
              // Debounce search to avoid too many API calls
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == val) {
                  _controller.fetchClients(search: val.trim());
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Search by client name...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Loading or empty state
          if (_controller.isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.clients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No clients available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            )
          else
            Column(
              children: [
                // Client List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.clients.length,
                  itemBuilder: (context, index) {
                    final client = _controller.clients[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                          backgroundImage: client.profilePicture != null &&
                                  client.profilePicture!.isNotEmpty &&
                                  client.profilePicture != 'string'
                              ? NetworkImage(client.profilePicture!)
                              : null,
                          child: client.profilePicture == null ||
                                  client.profilePicture!.isEmpty ||
                                  client.profilePicture == 'string'
                              ? Text(
                                  client.firstName.isNotEmpty
                                      ? client.firstName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blue,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          client.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              client.email,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              client.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            if (client.address.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                client.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₦${client.balance.toString().replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]},',
                                    )}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pagination Controls
                Obx(() {
                  final currentPage = _controller.currentPage.value;
                  final hasNextPage = _controller.clients.length >= _controller.limit;

                  // Calculate page range to show
                  final totalPages = hasNextPage ? currentPage + 1 : currentPage;
                  int endPage = totalPages.clamp(1, totalPages);
                  int startPage = (endPage - 4).clamp(1, endPage);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Button
                      IconButton(
                        onPressed: currentPage > 1
                            ? () => _controller.previousPage(
                                  search: _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim(),
                                )
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor: currentPage > 1
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Page Numbers
                      ...List.generate(
                        endPage - startPage + 1,
                        (index) {
                          final pageNumber = startPage + index;
                          final isCurrentPage = pageNumber == currentPage;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => _controller.goToPage(
                                pageNumber,
                                search: _searchController.text.trim().isEmpty
                                    ? null
                                    : _searchController.text.trim(),
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.blue
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$pageNumber',
                                  style: TextStyle(
                                    color: isCurrentPage
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isCurrentPage
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Next Button
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextPage(
                                  search: _searchController.text.trim().isEmpty
                                      ? null
                                      : _searchController.text.trim(),
                                )
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: hasNextPage
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor: hasNextPage
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      );
    });
  }

  void _showAddClientDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
                    const MyText(
                      'Add New Client',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      'Fill in the client details below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // First Name Field
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

                    // Last Name Field
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

                    // Email Field
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

                    // Phone Number Field
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
                    const SizedBox(height: 28),

                    // Action Buttons
                    const Divider(
                        height: 1, thickness: 1, color: Colors.black12),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MyElevatedButton(
                            child: 'Cancel',
                            bgColor: Colors.grey[200] ?? Colors.grey,
                            textColor: Colors.black87,
                            onTap: isSubmitting
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isSubmitting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : MyElevatedButton(
                                  child: 'Add Client',
                                  bgColor: AppColors.blue,
                                  onTap: () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() {
                                        isSubmitting = true;
                                      });

                                      try {
                                        final clientData = {
                                          'email': emailController.text.trim(),
                                          'first_name':
                                              firstNameController.text.trim(),
                                          'last_name':
                                              lastNameController.text.trim(),
                                          'phone_number':
                                              phoneController.text.trim(),
                                        };

                                        final success = await _controller
                                            .createClient(clientData);

                                        if (success && mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${firstNameController.text} added successfully'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to add client. Please try again.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Error: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isSubmitting = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
