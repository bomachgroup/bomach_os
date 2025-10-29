import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _clients = [
    {
      "name": "John Okafor",
      "email": "john.okafor@example.com",
      "property": "Land at Enugu - Independence Layout",
      "status": "Verified"
    },
    {
      "name": "Ngozi Adeyemi",
      "email": "ngozi.adeyemi@example.com",
      "property": "Plot 23, Lekki Phase 1, Lagos",
      "status": "Pending"
    },
    {
      "name": "Michael Eze",
      "email": "michael.eze@example.com",
      "property": "Survey Plan - Nsukka",
      "status": "Verified"
    },
  ];

  String _searchQuery = "";

  void _showAddClientDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final propertyController = TextEditingController();
    String selectedStatus = "Pending";

    showDialog(
      context: context,
      builder: (context) => Dialog(
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

                  // Client Name Field
                  MyTextFormField(
                    controller: nameController,
                    hintText: 'Enter client name',
                    title: 'Client Name',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Client name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  MyTextFormField(
                    controller: emailController,
                    hintText: 'Enter email address',
                    title: 'Email Address',
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

                  // Status Dropdown
                  const MyText(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.card),
                    ),
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      items: ['Verified', 'Pending'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedStatus = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Cancel',
                          bgColor: Colors.grey[200] ?? Colors.grey,
                          textColor: Colors.black87,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyElevatedButton(
                          child: 'Add Client',
                          bgColor: AppColors.blue,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                _clients.add({
                                  "name": nameController.text,
                                  "email": emailController.text,
                                  "property": propertyController.text,
                                  "status": selectedStatus,
                                });
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${nameController.text} added successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredClients = _clients
        .where((client) => client["name"]
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

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
                    "View and manage all land purchase clients.",
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
          onChanged: (val) => setState(() => _searchQuery = val),
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

        // Client List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredClients.length,
          itemBuilder: (context, index) {
            final client = filteredClients[index];
            final status = client["status"] as String;
            final isVerified = status.toLowerCase() == "verified";

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
                leading: CircleAvatar(
                  backgroundColor:
                      isVerified ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    isVerified ? Icons.check_circle : Icons.hourglass_top,
                    color: isVerified ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                title: Text(
                  client["name"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client["email"],
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text(
                      client["property"],
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color:
                          isVerified ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
