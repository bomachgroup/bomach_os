import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
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
    // Add more pairs if needed
  ];

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(imagePairs[index][0],
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(imagePairs[index][1],
                            fit: BoxFit.cover),
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
                    _currentPage != 0 ? AppColors.blue : AppColors.transparent,
                side: BorderSide(
                  color: _currentPage != 0
                      ? AppColors.transparent
                      : AppColors.blue,
                ),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              icon: SvgPicture.asset(
                "assets/svg/arrow-left.svg",
                colorFilter: ColorFilter.mode(
                  _currentPage != 0 ? AppColors.white : AppColors.blue,
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
                activeDotColor: AppColors.blue,
                dotColor: AppColors.grey4,
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
                    ? AppColors.blue
                    : AppColors.transparent,
                side: BorderSide(
                  color: _currentPage < imagePairs.length - 1
                      ? AppColors.transparent
                      : AppColors.blue,
                ),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              icon: SvgPicture.asset(
                "assets/svg/arrow-right.svg",
                colorFilter: ColorFilter.mode(
                  _currentPage < imagePairs.length - 1
                      ? AppColors.white
                      : AppColors.blue,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _goToPage(_currentPage + 1),
              color: AppColors.blue,
              iconSize: 30,
            ),
          ],
        ),
      ],
    );
  }
}
