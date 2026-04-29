import 'dart:developer';

import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  ImageCarouselState createState() => ImageCarouselState();
}

class ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<List<String>> imagePairs = [
    ['assets/image/man-demo.png', 'assets/image/man-demo.png'],
    ['assets/image/man-demo.png', 'assets/image/man-demo.png'],
    ['assets/image/man-demo.png', 'assets/image/man-demo.png'],
    ['assets/image/man-demo.png', 'assets/image/man-demo.png'],
    ['assets/image/man-demo.png', 'assets/image/man-demo.png'],
  ];
  late List<String> flatList;

  @override
  void initState() {
    flatList = imagePairs.expand((i) => i).toList();

    super.initState();
  }

  void _goToPage(int index) {
    if (index >= 0 && index < imagePairs.length) {
      _controller.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 114,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => kSizedBoxWidth,
            itemCount: flatList.length,
            itemBuilder: (context, index) {
              int pageIndex = index ~/ 2;
              log("pageIndex $pageIndex");

              return InkWell(
                onTap: () {
                  setState(() {
                    _controller.animateToPage(
                      index ~/ 2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    log("_currentPage $_currentPage");
                    _currentPage = index ~/ 2;
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    flatList[index],
                    fit: BoxFit.cover,
                    width: 102,
                    height: 68,
                    opacity: (_currentPage == pageIndex)
                        ? const AlwaysStoppedAnimation(1)
                        : const AlwaysStoppedAnimation(0.5),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: imagePairs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          imagePairs[index][0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          imagePairs[index][1],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Navigation & Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor:
                    _currentPage != 0 ? AppColors.primary : AppColors.transparent,
                side: BorderSide(
                  color: _currentPage != 0
                      ? AppColors.transparent
                      : AppColors.primary,
                ),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              icon: SvgPicture.asset(
                "assets/svg/arrow-left.svg",
                colorFilter: ColorFilter.mode(
                  _currentPage != 0 ? AppColors.white : AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _goToPage(_currentPage - 1),
              iconSize: 30,
            ),
            kSizedBoxWidthBG,
            SmoothPageIndicator(
              controller: _controller,
              count: imagePairs.length,
              effect: const ExpandingDotsEffect(
                expansionFactor: 2.5,
                dotWidth: 7,
                dotHeight: 7,
                radius: 7,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.neutral300,
              ),
              onDotClicked: (index) {
                _controller.animateToPage(index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
            kSizedBoxWidthBG,
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: _currentPage < imagePairs.length - 1
                    ? AppColors.primary
                    : AppColors.transparent,
                side: BorderSide(
                  color: _currentPage < imagePairs.length - 1
                      ? AppColors.transparent
                      : AppColors.primary,
                ),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              icon: SvgPicture.asset(
                "assets/svg/arrow-right.svg",
                colorFilter: ColorFilter.mode(
                  _currentPage < imagePairs.length - 1
                      ? AppColors.white
                      : AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _goToPage(_currentPage + 1),
              color: AppColors.primary,
              iconSize: 30,
            ),
          ],
        ),
      ],
    );
  }
}
