import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProjectFiles extends StatelessWidget {
  const ProjectFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      width: 293,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText("No file found "),
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
                    'Supported formats :doc, pdf',
                    size: 11,
                    weight: 300,
                    color: AppColors.darkGrey2,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
