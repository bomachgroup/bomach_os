import 'package:flutter/material.dart';

class ObligationList extends StatelessWidget {
  final List<String> obligations;

  static const _colors = [
    Color(0xFF1F3D7A),
    Color(0xFF0A6B3E),
    Color(0xFFB87D00),
  ];

  const ObligationList({super.key, required this.obligations});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(17),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Role obligations',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14162B),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View role →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F3D7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ...obligations.asMap().entries.map((entry) {
            final i = entry.key;
            final obligation = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _colors[i % _colors.length],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      obligation,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14162B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}