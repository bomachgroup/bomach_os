import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';

import '../../src/constants/textstyle.dart';

class Meetings extends StatelessWidget {
  const Meetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Meetings',
          style: AppText.black_500_32,
        ),
        TextButton(
            style: TextButton.styleFrom(
                elevation: 3, fixedSize: const Size(105, 30)),
            onPressed: () {},
            child: const Row(
              children: [
                MyText(
                  "Meeting",
                  style: AppText.black_400_14,
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ],
            ))
      ],
    );
  }
}
