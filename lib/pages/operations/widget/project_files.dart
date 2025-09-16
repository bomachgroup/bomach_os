import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ProjectFiles extends StatelessWidget {
  const ProjectFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      width: 293,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText("No file found "),
          kSizedBoxSM,
          UploadFile(),
        ],
      ),
    );
  }
}
