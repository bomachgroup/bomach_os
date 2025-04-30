import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class EmployeeInfoStepper extends StatefulWidget {
  final String title;
  final bool isActive;
  final Widget icon;
  final Widget activeIcon;
  final VoidCallback onTap;

  const EmployeeInfoStepper({
    super.key,
    required this.title,
    this.isActive = false,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  State<EmployeeInfoStepper> createState() => _EmployeeInfoStepperState();
}

class _EmployeeInfoStepperState extends State<EmployeeInfoStepper> {
  final GlobalKey _textKey = GlobalKey();
  double _textWidth = 0;

  @override
  void initState() {
    super.initState();
    // Wait for layout to finish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _textWidth = box.size.width + 35;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant EmployeeInfoStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate if title changes
    if (oldWidget.title != widget.title) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? box =
            _textKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          setState(() {
            _textWidth = box.size.width + 35;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              widget.isActive ? widget.activeIcon : widget.icon,
              kSizedBoxWidthSM,
              MyText(
                widget.title,
                isSelectable: false,
                key: _textKey,
                weight: widget.isActive ? 600 : 300,
                size: 16,
                color: widget.isActive ? AppColors.blue : AppColors.darkGrey3,
              ),
            ],
          ),
          kSizedBoxTiny,
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isActive ? AppColors.blue : AppColors.darkGrey3,
            ),
            width: _textWidth,
            height: 3,
          ),
        ],
      ),
    );
  }
}
