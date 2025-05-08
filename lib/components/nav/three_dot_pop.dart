import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThreeDotPop extends StatefulWidget {
  final void Function()? onTapView;
  final void Function()? onTapEdit;
  final void Function()? onTapDelete;
  const ThreeDotPop({
    super.key,
    this.onTapView,
    this.onTapEdit,
    this.onTapDelete,
  });

  @override
  State<ThreeDotPop> createState() => _ThreeDotPopState();
}

class _ThreeDotPopState extends State<ThreeDotPop> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isMenuOpen = false;
  }

  void _showMenu(BuildContext context) {
    // Close if already open
    if (_isMenuOpen) {
      _removeOverlay();
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 240,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            color: AppColors.greyBg,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.card,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    svgPath: "assets/svg/eye.svg",
                    title: 'View',
                    onTap: () {
                      _removeOverlay();
                      if (widget.onTapView != null) {
                        widget.onTapView!();
                      }
                    },
                  ),
                  _buildMenuItem(
                    svgPath: "assets/svg/edit-pencil.svg",
                    title: 'Edit',
                    onTap: () {
                      _removeOverlay();
                      if (widget.onTapEdit != null) {
                        widget.onTapEdit!();
                      }
                    },
                  ),
                  _buildMenuItem(
                    svgPath: "assets/svg/trash-can.svg",
                    title: 'Delete',
                    onTap: () {
                      _removeOverlay();
                      if (widget.onTapDelete != null) {
                        widget.onTapDelete!();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isMenuOpen = true;
  }

  Widget _buildMenuItem({
    required String svgPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter:
                  const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _showMenu(context),
        child: Container(
            padding: const EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.card,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset("assets/svg/three-dot.svg")),
      ),
    );
  }
}
