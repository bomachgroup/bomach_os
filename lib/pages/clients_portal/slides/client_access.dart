import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import '../dialog/new_client.dart';
import '../widgets/client_details_card.dart';
import '../widgets/client_tile.dart';
import 'mobile_details_view.dart';

class ClientAcessSlide extends StatefulWidget {
  final bool isMobile;

  const ClientAcessSlide({super.key, this.isMobile = false});

  @override
  ClientAcessSlideState createState() => ClientAcessSlideState();
}

class ClientAcessSlideState extends State<ClientAcessSlide> {
  Client? _selectedClient;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!widget.isMobile) {
      _selectedClient = mockClients.first;
    }
  }

  void _selectClient(Client client) {
    setState(() {
      _selectedClient = client;
    });
    if (widget.isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientDetailsMobileScreen(client: client),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortalUsersHeader(),
            const SizedBox(height: 8),
            _buildSearchAndActions(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: mockClients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) => Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(8),
                  child: ClientTile(
                    client: mockClients[idx],
                    isSelected: _selectedClient == mockClients[idx],
                    onTap: () => _selectClient(mockClients[idx]),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFF7F8FA),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortalUsersHeader(),
                    const SizedBox(height: 12),
                    _buildSearchAndActions(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: scrollController,
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: mockClients.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, idx) => Material(
                            elevation:
                                _selectedClient == mockClients[idx] ? 2 : 0,
                            borderRadius: BorderRadius.circular(8),
                            child: ClientTile(
                              client: mockClients[idx],
                              isSelected: _selectedClient == mockClients[idx],
                              onTap: () => _selectClient(mockClients[idx]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _selectedClient != null
                    ? ClientDetailsCard(client: _selectedClient!)
                    : const Center(
                        child: Text(
                          'Click on a user to view info',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPortalUsersHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portal Users',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Clients and partners with portal access',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search clients..',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF0F0F0),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Text('All Status',
                  style: TextStyle(color: Colors.black, fontSize: 13)),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            AddPortalClientDialog.show(context);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Client', style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            minimumSize: const Size(0, 40),
          ),
        ),
      ],
    );
  }
}

final List<Client> mockClients = [
  Client(
    initials: 'AO',
    name: 'Adebayo Ogundimu',
    company: 'Lagos Property Development Ltd',
    email: 'adebayo@lagospropertydevelopment.com',
    status: 'Active',
    accessType: 'full',
    projects: 3,
    lastLogin: '7 Feb 2024',
    joined: '15 Jan 2024',
    permissions: ['documents', 'communications', 'project updates'],
  ),
  Client(
    initials: 'SO',
    name: 'Sarah Okwu',
    company: 'Abuja Infrastructure Company',
    email: 'sarah.okwu@abujainfra.ng',
    status: 'Active',
    accessType: 'standard',
    projects: 2,
    lastLogin: '6 Feb 2024',
    permissions: ['documents', 'communications'],
  ),
  Client(
    initials: 'EN',
    name: 'Emeka Nwosu',
    company: 'Rivers State Development Company',
    email: 'emeka@riversdev.gov.ng',
    status: 'Pending',
    accessType: 'limited',
    projects: 1,
    lastLogin: 'N/A',
    permissions: ['documents'],
  ),
  Client(
    initials: 'FA',
    name: 'Fatima Aliyu',
    company: 'Kano State Housing Corporation',
    email: 'fatima@kanohousing.gov.ng',
    status: 'Active',
    accessType: 'full',
    projects: 4,
    lastLogin: '5 Feb 2024',
    permissions: ['documents', 'communications', 'project updates'],
  ),
  Client(
    initials: 'CE',
    name: 'Chinedu Eze',
    company: 'Enugu State Government',
    email: 'chinedu@enuguinfa.gov.ng',
    status: 'Inactive',
    accessType: 'standard',
    projects: 1,
    lastLogin: '28 Jan 2024',
    permissions: ['documents', 'communications'],
  ),
];
