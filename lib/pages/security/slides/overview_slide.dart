import 'package:bomach_os/pages/company/audit_log.dart';
import 'package:flutter/material.dart';

/// The security overview uses the supported audit-log API instead of local
/// security event fixtures.
class OverviewLogsRow extends StatelessWidget {
  final bool isMobile;

  const OverviewLogsRow({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) => const AuditLogPage();
}
