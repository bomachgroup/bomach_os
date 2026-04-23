import 'package:bms_front_end/components/button/in_button.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/widget/invoice_list.dart';
import 'package:flutter/material.dart';

class ServiceOrder extends StatefulWidget {
  const ServiceOrder({super.key});

  @override
  State<ServiceOrder> createState() => _ServiceOrderState();
}

class _ServiceOrderState extends State<ServiceOrder> {
  final List<Widget> _pages = [
    const InvoiceList(),
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
  ];
  int serviceOrderState = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.displayLg(
          'Service Order',
        ),
        AppText.h4(
          'Service Order',
        ),
        const SizedBox(
          height: 21,
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              InButton(
                title: 'Invoice',
                onTap: () {
                  setState(() {
                    serviceOrderState = 0;
                  });
                },
                isSelected: serviceOrderState == 0,
              ),
              const SizedBox(
                width: 10,
              ),
              InButton(
                title: 'New',
                onTap: () {
                  setState(() {
                    serviceOrderState = 1;
                  });
                },
                isSelected: serviceOrderState == 1,
              ),
              const SizedBox(
                width: 10,
              ),
              InButton(
                title: 'In Progress',
                onTap: () {
                  setState(() {
                    serviceOrderState = 2;
                  });
                },
                isSelected: serviceOrderState == 2,
              ),
              const SizedBox(
                width: 10,
              ),
              InButton(
                title: 'Completed',
                onTap: () {
                  setState(() {
                    serviceOrderState = 3;
                  });
                },
                isSelected: serviceOrderState == 3,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 23,
        ),
        Container(child: _pages[serviceOrderState])
      ],
    );
  }
}
