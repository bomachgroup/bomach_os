import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';

class AllActivities extends StatelessWidget {
  const AllActivities({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        // scrollDirection: Axis.horizontal,
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 235,
            mainAxisExtent: 132,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16),
        itemBuilder: (contex, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0XFFE0E0E0))),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('67'), Icon(Icons.people)],
                ),
                Text('Activities')
              ],
            ),
          );
        });
  }
}