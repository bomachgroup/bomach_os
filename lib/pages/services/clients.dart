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
