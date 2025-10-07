import 'package:flutter/material.dart';

import '../widgets/client_details_card.dart';
import '../widgets/client_tile.dart';

class ClientDetailsMobileScreen extends StatelessWidget {
  final Client client;

  const ClientDetailsMobileScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          spacing: 16,
          children: [
            CloseButton(),
            Text('Client Details'),
          ],
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ClientDetailsCard(client: client),
        ),
      ],
    );
  }
}
