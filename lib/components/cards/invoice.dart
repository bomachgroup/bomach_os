import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: kDefaultSpace, horizontal: kDefaultSpace),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description, color: Colors.red),
          kSizedBoxWidthSM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Invoice #1273636'), Text('Chijiokeugo@nggs')],
          ),
          Spacer(),
          Icon(Icons.download),
          kSizedBoxWidthSM,
          Icon(Icons.share)
        ],
      ),
    );
  }
}
