import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';

class EmployeInfoStepper extends StatelessWidget {
  const EmployeInfoStepper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BlackCommunity(
            title: Text('Personal Information'),
            icon: Icon(Icons.person),
            selectes: true),
        SizedBox(
          width: 32,
        ),
        BlackCommunity(
            title: Text('Professional Information'),
            icon: Icon(Icons.person),
            selectes: true),
        SizedBox(
          width: 32,
        ),
        BlackCommunity(
            title: Text('Documents'),
            icon: Icon(Icons.person),
            selectes: true),
      ],
    );
  }
}

class BlackCommunity extends StatelessWidget {
  final VoidCallback? onTap;
  final Text title;
  final bool selectes;
  final Widget icon;
  const BlackCommunity({
    super.key,
    required this.title,
    required this.icon,
    required this.selectes, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(
                width: 8,
              ),
              title,
            ],
          ),
          Visibility(
            visible: selectes,
            child: Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(12)),
                height: 3,
                // width: 210,
              ),
            ),
          )
        ],
      ),
    );
  }
}