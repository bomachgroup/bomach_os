import 'dart:typed_data';
import 'package:iconsax/iconsax.dart';

import 'package:bms_front_end/src/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Circular avatar that displays the currently selected image (either a
/// remote URL already persisted on the server or a freshly-picked local
/// [XFile]) and opens the gallery picker on tap. When nothing is selected
/// it renders initials over a soft background.
///
/// Callers own the selected [XFile] state and pass it back via [onPicked].
class AvatarPicker extends StatefulWidget {
  final XFile? pickedFile;
  final String? currentImageUrl;
  final String? initials;
  final double size;
  final bool enabled;
  final String? label;
  final ValueChanged<XFile> onPicked;

  const AvatarPicker({
    super.key,
    required this.onPicked,
    this.pickedFile,
    this.currentImageUrl,
    this.initials,
    this.size = 96,
    this.enabled = true,
    this.label,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  Uint8List? _pickedBytes;
  String? _lastPickedPath;

  @override
  void initState() {
    super.initState();
    _syncBytes();
  }

  @override
  void didUpdateWidget(covariant AvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedFile?.path != _lastPickedPath) {
      _syncBytes();
    }
  }

  Future<void> _syncBytes() async {
    final file = widget.pickedFile;
    _lastPickedPath = file?.path;
    if (file == null) {
      if (mounted) setState(() => _pickedBytes = null);
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _pickedBytes = bytes);
  }

  Future<void> _pick() async {
    if (!widget.enabled) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked != null) widget.onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final hasPicked = _pickedBytes != null;
    final hasRemote =
        widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
        ],
        MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: _pick,
            child: Stack(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySubtle,
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPicked
                      ? Image.memory(_pickedBytes!, fit: BoxFit.cover)
                      : hasRemote
                          ? CachedNetworkImage(
                              imageUrl: widget.currentImageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initials(),
                              placeholder: (_, __) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : _initials(),
                ),
                if (widget.enabled)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Iconsax.camera,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _initials() {
    final text = (widget.initials ?? '').trim();
    return Center(
      child: Text(
        text.isEmpty ? '?' : text.toUpperCase(),
        style: TextStyle(
          fontSize: widget.size * 0.32,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral800,
        ),
      ),
    );
  }
}
