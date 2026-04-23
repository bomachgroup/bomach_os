import 'package:bms_front_end/components/image/my_image.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileIconsStack extends StatelessWidget {
  final List<String> imagesPath;
  const ProfileIconsStack({super.key, required this.imagesPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: ((imagesPath.length + 1) * 18) + 6,
      child: Stack(
        children: List.generate(imagesPath.length + 1, (index) {
          return Positioned(
            height: 24,
            width: 24,
            left: (18 * index).toDouble(),
            child: index < imagesPath.length
                ? profileIconWidget(imagesPath[index])
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral300),
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const MyText(
                      '+1',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  Container profileIconWidget(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral300),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: MyImage(
          imagePath,
          fit: BoxFit.cover,
          height: 24,
          width: 24,
        ),
      ),
    );
  }
}
