import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/svg.dart';

class EmployeeDocumentation extends StatelessWidget {
  const EmployeeDocumentation({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: isSmallScreen(context)
          ? [
              auto,
              auto,
              auto,
              auto,
            ]
          : const [
              auto,
              auto,
            ],
      columnGap: kDefaultSpace,
      rowGap: kDefaultSpace,
      children: [
        DocumentUpload(
          title: 'Upload Appointment Letter',
          upload: () {},
        ),
        DocumentUpload(
          title: 'Upload Salary Slips',
          upload: () {},
        ),
        DocumentUpload(
          title: 'Upload Reliving Letter',
          upload: () {},
        ),
        DocumentUpload(
          title: 'Upload Experience Letter',
          upload: () {},
        ),
      ],
    );
  }
}

class DocumentUpload extends StatelessWidget {
  final String title;
  final VoidCallback upload;
  const DocumentUpload({
    super.key,
    required this.title,
    required this.upload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title),
        kSizedBoxSM,
        DottedBorder(
          color: AppColors.blue,
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  width: 40,
                  height: 40,
                  child: SvgPicture.asset(
                    "assets/svg/upload.svg",
                  ),
                ),
                kSizedBoxSM,
                const MyText(
                  'Drag & Drop or choose file to upload',
                  textAlign: TextAlign.center,
                ),
                const MyText(
                  'Supported formats : Jpeg, pdf',
                  textAlign: TextAlign.center,
                  size: 11,
                  weight: 300,
                  color: AppColors.darkGrey2,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
