import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/clients_portal/controller/client_portal_controller.dart';
import 'package:bms_front_end/pages/clients_portal/slides/client_access.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Using similar stat card from services
import '../services/services.dart';
import 'dialog/new_client.dart';
import 'slides/analytics.dart';
import 'slides/communications.dart';
import 'slides/shared_documents.dart';

class ClientsPortal extends StatefulWidget {
  final int page;
  const ClientsPortal({super.key, required this.page});

  @override
  State<ClientsPortal> createState() => _ClientsPortalState();
}

class _ClientsPortalState extends State<ClientsPortal> {
  final controller = Get.put(ClientPortalController());
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.page;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant ClientsPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page != _currentIndex) {
      _currentIndex = widget.page;
      _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      final isTablet =
          constraints.maxWidth < 1000 && constraints.maxWidth >= 600;
      final isMobile = width < 700;
      final double pageViewHeight = isMobile ? 600 : (isTablet ? 650 : 700);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isMobile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          'Client & Partner Portal',
                          style: AppText.black_500_32,
                        ),
                        MyText(
                          'Manage client access and self-service portal',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.white,
                      ),
                      child: "View Portal",
                      onTap: () {
                        AddPortalClientDialog.show(context);
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              'Client & Partner Portal',
                              style: AppText.black_500_32,
                            ),
                            MyText(
                              'Manage client access and self-service portal',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        MyElevatedButton(
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.white,
                          ),
                          child: "View Portal",
                          onTap: () {
                            AddPortalClientDialog.show(context);
                          },
                        )
                      ],
                    ),
                  ],
                ),
          kSizedBox,
          _buildTopStats(context, isMobile: isMobile),
          const SizedBox(height: 18),
          SizedBox(
            height: pageViewHeight,
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                ClientAcessSlide(isMobile: isMobile),
                SharedDocumentsScreen(isMobile: isMobile),
                const ClientCommunicationsScreen(),
                const PortalUsageDashboard(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTopStats(BuildContext context, {required bool isMobile}) {
    return Obx(() {
      final items = [
        {
          'label': 'Active Clients',
          'value': controller.isLoading.value
              ? '...'
              : '${controller.activeClients.value}',
        },
        {'label': 'Total Documents', 'value': '\u2014'},
        {'label': 'Downloads', 'value': '\u2014'},
        {'label': 'Unread Messages', 'value': '\u2014'},
      ];

      if (!isMobile) {
        return Row(
          spacing: 12,
          children: items
              .map((it) => Expanded(
                    child: StatsHeaderCard(
                      label: it['label']!,
                      count: it['value']!,
                      icon: Icons.person,
                    ),
                  ))
              .toList(),
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: items
              .map(
                  (it) => StatsCard(label: it['label']!, count: it['value']!))
              .toList(),
        );
      }
    });
  }
}
