import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UploadFile extends StatelessWidget {
  const UploadFile({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: AppColors.blue,
      dashPattern: const [5, 5],
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
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
            const Text(
              'Drag & Drop or choose files to upload',
              textAlign: TextAlign.center,
            ),
            const MyText(
              'Supported formats :doc, pdf',
              textAlign: TextAlign.center,
              size: 11,
              weight: 300,
              color: AppColors.darkGrey2,
              isSelectable: false,
            ),
          ],
        ),
      ),
    );
  }
}
