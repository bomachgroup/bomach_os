import 'package:flutter/material.dart';

class OpsHeroBanner extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final Widget? scoreBox;

  const OpsHeroBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.scoreBox,
  });

  static const _navy = Color(0xFF1F3D7A);
  static const _navyDark = Color(0xFF152C5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navyDark, _navy, Color(0xFF3C6BCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 16),
      child: scoreBox != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeft()),
                const SizedBox(width: 18),
                SizedBox(width: 240, child: scoreBox!),
              ],
            )
          : _buildLeft(),
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Color(0xB3FFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            height: 1.65,
            color: Color(0xC7FFFFFF),
          ),
        ),
      ],
    );
  }
}

class OpsScoreBox extends StatelessWidget {
  final String score;
  final String rank;
  final String tasksDone;
  final String tasksTotal;
  final String reportStatus;

  const OpsScoreBox({
    super.key,
    required this.score,
    required this.rank,
    required this.tasksDone,
    required this.tasksTotal,
    required this.reportStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's role performance",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xB3FFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Divider(color: Color(0x1FFFFFFF), height: 1),
          _scoreRow('Department ranking', rank),
          const Divider(color: Color(0x1FFFFFFF), height: 1),
          _scoreRow('Tasks completed', '$tasksDone / $tasksTotal'),
          const Divider(color: Color(0x1FFFFFFF), height: 1),
          _scoreRow('Close-of-day report', reportStatus),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xB8FFFFFF),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}