import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

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
      columnGap: kDefaultSpaceTiny,
      rowGap: kDefaultSpaceTiny,
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
        Text(title),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(),
          ),
          // color: AppColors.secondaryColor,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(10)),
                width: 40,
                height: 40,
              ),
              const Text('Drag & Drop or choose file to upload'),
              const Text('Supported formats : Jpeg, pdf')
            ],
          ),
        ),
      ],
    );
  }
}
