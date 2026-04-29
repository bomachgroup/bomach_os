import 'package:bomach_os/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for [UploadFile] that actually opens a file picker.
/// Displays a dashed-border drop zone that swaps to a filename + thumbnail
/// once a file is selected. Caller owns the [PlatformFile] state.
class FilePickerField extends StatelessWidget {
  final String? title;
  final String hint;
  final PlatformFile? file;
  final ValueChanged<PlatformFile> onPicked;
  final List<String> allowedExtensions;
  final FileType fileType;
  final double height;

  const FilePickerField({
    super.key,
    required this.onPicked,
    this.title,
    this.hint = 'Click to choose a file to upload',
    this.file,
    this.fileType = FileType.any,
    this.allowedExtensions = const [],
    this.height = 120,
  });

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions.isEmpty ? fileType : FileType.custom,
      allowedExtensions:
          allowedExtensions.isEmpty ? null : allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      onPicked(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
        ],
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pick,
            child: Container(
              width: double.infinity,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: file != null ? AppColors.primary : AppColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      file == null
                          ? Iconsax.document_upload
                          : Iconsax.document,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          file?.name ?? hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          file != null
                              ? _formatBytes(file!.size)
                              : (allowedExtensions.isEmpty
                                  ? 'Any file type'
                                  : 'Allowed: ${allowedExtensions.join(", ")}'),
                          size: 11,
                          weight: 300,
                          color: AppColors.neutral400,
                          isSelectable: false,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pick,
                    child: Text(file == null ? 'Browse' : 'Change'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
