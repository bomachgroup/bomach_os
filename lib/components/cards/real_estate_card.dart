import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../src/constants/colors.dart';

class RealEstateCard extends StatelessWidget {
  final String image, title, details, buttonText;
  const RealEstateCard(
      {super.key,
      required this.image,
      required this.title,
      required this.details,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          width: 0.6,
          color: AppColors.border,
        ),
        color: const Color(0XFFF5F6FA),
      ),
      width: 400,
      child: Column(
        children: [
          Image.asset(
            image,
            width: 400,
            height: 200,
            fit: BoxFit.fill,
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ReadMoreText(
              details,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: "Read more",
              trimExpandedText: "Less",
              style: const TextStyle(
                  fontSize: 12, overflow: TextOverflow.ellipsis),
              moreStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis),
              lessStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    elevation: 4,
                    fixedSize: const Size(400, 50),
                    backgroundColor: const Color(0xFF0055FF)),
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  buttonText,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
