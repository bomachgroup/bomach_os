import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
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
        const UploadFile(),
      ],
    );
  }
}
