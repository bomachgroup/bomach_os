import 'package:flutter/material.dart';

class RoutineBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Map<String, bool> checks;
  final String groupPrefix;
  final ValueChanged<String> onToggle;

  const RoutineBlock({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.checks,
    required this.groupPrefix,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = items.asMap().entries.where((e) => checks['$groupPrefix-${e.key}'] == true).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EE)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF1F3D7A)),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14162B),
                    ),
                  ),
                ],
              ),
              _PillActive('$done / ${items.length}'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: List.generate(items.length, (i) {
              return SizedBox(
                width: 280,
                child: _RoutineItem(
                  text: items[i],
                  isDone: checks['$groupPrefix-$i'] == true,
                  onTap: () => onToggle('$groupPrefix-$i'),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RoutineItem extends StatelessWidget {
  final String text;
  final bool isDone;
  final VoidCallback onTap;

  const _RoutineItem({
    required this.text,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFECFDF5) : const Color(0xFFF8F9FB),
          border: Border.all(
            color: isDone ? const Color(0xFFA7F3D0) : const Color(0xFFE5E7EE),
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        padding: const EdgeInsets.all(9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF0A6B3E) : Colors.transparent,
                border: Border.all(
                  color: isDone ? const Color(0xFF0A6B3E) : const Color(0xFFD3D7E1),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: const Color(0xFF14162B),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF14162B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Role-based routine · logged to performance history',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF8B90A5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillActive extends StatelessWidget {
  final String label;
  const _PillActive(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF065F46),
        ),
      ),
    );
  }
}