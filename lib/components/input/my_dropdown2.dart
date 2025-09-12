import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyDropdown2 extends StatefulWidget {
  const MyDropdown2({super.key});

  @override
  _MyDropdown2State createState() => _MyDropdown2State();
}

class _MyDropdown2State extends State<MyDropdown2> {
  String selectedValue = 'Pending';

  final List<String> statusOptions = [
    'Pending',
    'Approved',
    'Rejected',
    'In Progress',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.grey1,
        ),
        iconSize: 20,
        elevation: 0,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        underline: const SizedBox(), // Remove default underline
        dropdownColor: Colors.white,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
          });
        },
        items: statusOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
