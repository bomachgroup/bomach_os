import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class DetailPageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;

  const DetailPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => context.pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/arrow-left.svg",
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              kSizedBoxWidthSM,
                              const MyText(
                                'Back',
                                style: AppTextStyles.h2,
                                isSelectable: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      kSizedBoxWidth,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            title,
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            subtitle,
                            style: AppTextStyles.bodyLg,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (actions.isNotEmpty)
                    Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    ),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
