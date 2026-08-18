import 'package:bomach_os/pages/marketing/models/marketing_misc.dart';
import 'package:flutter/material.dart';

class UnitGrid extends StatelessWidget {
  final List<FiveUnit> units;

  static const _topColors = [
    Color(0xFF1F3D7A),
    Color(0xFF7C3AED),
    Color(0xFFB87D00),
    Color(0xFF0A6B3E),
    Color(0xFFCC0000),
  ];

  const UnitGrid({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: units.map((u) {
        final idx = units.indexOf(u);
        return SizedBox(
          width: 200,
          child: _UnitCard(unit: u, topColor: _topColors[idx % _topColors.length]),
        );
      }).toList(),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final FiveUnit unit;
  final Color topColor;

  const _UnitCard({required this.unit, required this.topColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EE)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A14162B),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: topColor),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.num,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B90A5),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unit.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14162B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.kpi,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: Color(0xFF8B90A5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}