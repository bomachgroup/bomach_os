import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';
import '../../components/text/my_text.dart';
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
                children: const [
                  Expanded(
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
                  SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 24),
              if (_currentIndex == 0)
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: BackendCapabilityUnavailable(
                    featureName:
                        'Employee Platforms Verification and Device Whitelisting',
                    explanation:
                        'The current backend does not publish platform verification or device registration APIs, so access cannot be safely enforced from this client.',
                    contractRequirement:
                        'Required contract: BOMACH OS shell, Mobile client, and Embedded BOMACH OS Services with allowed, pending, blocked, and unknown states; plus device registration, approval, revocation, replacement, and access-denial reasons.',
                  ),
                ),
              const BackendCapabilityUnavailable(
                featureName: 'Security Metrics and Access Codes',
                explanation:
                    'The published backend contract does not provide security-code or security-metric endpoints. The dashboard does not display invented counts.',
                contractRequirement:
                    'Required contract: security metrics and code lifecycle endpoints with permission-controlled access.',
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
}
