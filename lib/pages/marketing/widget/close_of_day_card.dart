import 'package:flutter/material.dart';

class CloseOfDayCard extends StatefulWidget {
  final String text;
  final bool isSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const CloseOfDayCard({
    super.key,
    required this.text,
    this.isSubmitted = false,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<CloseOfDayCard> createState() => _CloseOfDayCardState();
}

class _CloseOfDayCardState extends State<CloseOfDayCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                'Close-of-day summary',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14162B),
                ),
              ),
              if (widget.isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Submitted',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Wins, blockers and tomorrow\'s priorities',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF535870),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            maxLines: 4,
            onChanged: widget.onChanged,
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Summarise outcomes, blockers, revenue movement and next actions...',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF8B90A5),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFE5E7EE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFE5E7EE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFF1F3D7A), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(11),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3D7A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Submit daily report',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}