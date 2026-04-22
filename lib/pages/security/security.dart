import 'package:bms_front_end/pages/analytics/widgets/metrics_card.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import '../../components/text/my_text.dart';
import 'dialogs/generate_code.dart';
import 'model.dart';
import 'slides/alerts.dart';
import 'slides/codes.dart';
import 'slides/logs.dart';
import 'slides/overview_slide.dart';
import 'slides/workflow.dart';

class SecurityPage extends StatefulWidget {
  final int page;
  const SecurityPage({super.key, this.page = 0});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.page;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant SecurityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page != _currentIndex) {
      _currentIndex = widget.page;
      _pageController.jumpToPage(_currentIndex);
    }
  }

  void showSecurityCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const GenerateSecurityCodeDialog();
      },
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth < 1000 && constraints.maxWidth >= 600;
        final double pageViewHeight = isMobile ? 600 : (isTablet ? 650 : 700);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText("Security & Authorization",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        MyText(
                            "Manage security codes, approval workflows, and access control ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      _buildActionButton(
                          icon: Iconsax.setting_2,
                          label: 'Security Settings',
                          onPressed: () {},
                          isWide: !isMobile),
                      if (_currentIndex == 0)
                        _buildActionButton(
                            icon: Iconsax.key,
                            label: 'Generate code',
                            onPressed: showSecurityCodeDialog,
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                            isWide: !isMobile)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  int crossAxisCount;
                  if (isMobile) {
                    crossAxisCount = 1;
                  } else if (isTablet) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 3;
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: securityMetrics.length,
                    itemBuilder: (context, i) {
                      final metric = securityMetrics[i];
                      return AnalyticsMetricCard(
                        title: metric.title,
                        icon: metric.icon,
                        value: metric.value,
                        subtitle: metric.subtitle,
                        showtrend: false,
                        color: metric.iconColor,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: pageViewHeight,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    OverviewLogsRow(isMobile: isMobile),
                    SecurityCodes(isMobile: isMobile),
                    Workflows(isMobile: isMobile),
                    SecurityAlerts(isMobile: isMobile),
                    SecurityLogs(isMobile: isMobile),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isWide,
    void Function()? onPressed,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    if (isWide) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: foregroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onPressed,
      );
    } else {
      return IconButton(
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: foregroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
      );
    }
  }
}

List<MetricCard> securityMetrics = [
  MetricCard(
    title: 'Active Codes',
    icon: Iconsax.key,
    iconColor: Colors.blue,
    value: '1',
    subtitle: 'Security codes',
  ),
  MetricCard(
    title: 'Active Workflows',
    icon: Iconsax.routing_2,
    iconColor: Colors.green,
    value: '1',
    subtitle: 'Approval processes',
  ),
  MetricCard(
    title: 'Open Alerts',
    icon: Iconsax.warning_2,
    iconColor: Colors.red,
    value: '2',
    subtitle: 'Require attention',
  ),
  MetricCard(
    title: 'Successful Logins',
    icon: Iconsax.tick_circle,
    iconColor: Colors.green,
    value: '1',
    subtitle: 'This week',
  ),
  MetricCard(
    title: 'Failed Attempts',
    icon: Iconsax.close_circle,
    iconColor: Colors.red,
    value: '0',
    subtitle: 'Security events',
  ),
  MetricCard(
    title: 'Critical Alerts',
    icon: Iconsax.shield_cross,
    iconColor: Colors.red,
    value: '0',
    subtitle: 'High priority',
  ),
];
