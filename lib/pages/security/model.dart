import 'package:flutter/material.dart';

class SecurityCode {
  final String name;
  final String code;
  final String accessType;
  final String status;
  final String assignedTo;
  final String expires;

  SecurityCode({
    required this.name,
    required this.code,
    required this.accessType,
    required this.status,
    required this.assignedTo,
    required this.expires,
  });
}

class MetricCard {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String subtitle;

  MetricCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.subtitle,
  });
}

class SecurityAlert {
  final String title;
  final String description;
  final String priority;
  final String date;

  SecurityAlert(
      {required this.title,
      required this.description,
      required this.priority,
      required this.date});
}

class SecurityLog {
  final String title;
  final String metadata;
  final String status;

  SecurityLog(
      {required this.title, required this.metadata, required this.status});
}

class ApprovalWorkflow {
  final String name;
  final String status;
  final String description;
  final String approver;
  final String condition;
  final String createdDate;

  ApprovalWorkflow({
    required this.name,
    required this.status,
    required this.description,
    required this.approver,
    required this.condition,
    required this.createdDate,
  });
}

class DetailedSecurityAlert {
  final String title;
  final String description;
  final String priority;
  final String status;
  final String type;
  final String time;
  final String assignedTo;
  final String affectedSystems;

  DetailedSecurityAlert(
      {required this.title,
      required this.description,
      required this.priority,
      required this.status,
      required this.type,
      required this.time,
      required this.assignedTo,
      required this.affectedSystems});
}

class SecurityAuditLog {
  final String title;
  final String user;
  final String ipAddress;
  final String status;
  final String timestamp;

  SecurityAuditLog({
    required this.title,
    required this.user,
    required this.ipAddress,
    required this.status,
    required this.timestamp,
  });
}

final List<SecurityAuditLog> mockAuditLogs = [
  SecurityAuditLog(
    title: 'User login successful',
    user: 'John Adebayo',
    ipAddress: '192.168.1.100',
    status: 'Success',
    timestamp: '8/15/2024 11:30 AM',
  ),
  SecurityAuditLog(
    title: 'Client attempted file upload',
    user: 'Sarah Okwu',
    ipAddress: '10.0.0.5',
    status: 'Failure',
    timestamp: '8/15/2024 09:15 AM',
  ),
  SecurityAuditLog(
    title: 'System configuration change',
    user: 'System Admin',
    ipAddress: 'N/A',
    status: 'Success',
    timestamp: '8/14/2024 04:00 PM',
  ),
  SecurityAuditLog(
    title: 'Password reset initiated',
    user: 'Emeka Nwosu',
    ipAddress: '203.0.113.1',
    status: 'Warning',
    timestamp: '8/14/2024 02:00 PM',
  ),
];

final List<DetailedSecurityAlert> mockDetailedAlerts = [
  DetailedSecurityAlert(
    title: 'Multiple Failed Login Attempts',
    description: 'User attempted to login 5 times with incorrect credentials',
    priority: 'Medium',
    status: 'Investigating',
    type: 'suspicious',
    time: '8/15/2024 03:30 PM',
    assignedTo: 'Security Team',
    affectedSystems: 'Authentication System',
  ),
  DetailedSecurityAlert(
    title: 'Unauthorized File Access',
    description: 'Attempt to access restricted financial documents',
    priority: 'High',
    status: 'Open',
    type: 'violation',
    time: '8/15/2024 01:15 PM',
    assignedTo: 'IT Administrator',
    affectedSystems: 'File System, Document Management',
  ),
  DetailedSecurityAlert(
    title: 'Expired Access Code Used',
    description:
        'An attempt was made to use an access code that expired last month.',
    priority: 'Medium',
    status: 'Resolved',
    type: 'procedural',
    time: '8/14/2024 10:00 AM',
    assignedTo: 'Security Team',
    affectedSystems: 'Access Control',
  ),
];

final List<ApprovalWorkflow> mockWorkflows = [
  ApprovalWorkflow(
    name: 'High-Value Transaction Approval',
    status: 'Active',
    description: 'Approval workflow for transactions above ₦1,000,000',
    approver: 'Finance Manager',
    condition: 'Transaction amount > 1000000',
    createdDate: '1/15/2024 01:00 AM',
  ),
  ApprovalWorkflow(
    name: 'New Client Onboarding Review',
    status: 'Pending',
    description: 'Review of new client profile and initial contract documents.',
    approver: 'Legal Team',
    condition: 'Client profile created',
    createdDate: '2/20/2024 09:30 AM',
  ),
  ApprovalWorkflow(
    name: 'Document Finalization Signoff',
    status: 'Active',
    description: 'Final signoff before documents are shared with clients.',
    approver: 'Project Director',
    condition: 'Document marked "Final"',
    createdDate: '3/10/2024 02:00 PM',
  ),
];

final List<SecurityAlert> mockAlerts = [
  SecurityAlert(
    title: 'Multiple Failed Login Attempts',
    description: 'User attempted to login 5 times with incorrect credentials',
    priority: 'Medium',
    date: '8/15/2024 03:30 PM',
  ),
  SecurityAlert(
    title: 'Unauthorized File Access',
    description: 'Attempt to access restricted financial documents',
    priority: 'High',
    date: '8/15/2024 01:15 PM',
  ),
  SecurityAlert(
    title: 'Brute Force Attempt',
    description: '100 login attempts detected from a single IP address',
    priority: 'High',
    date: '8/15/2024 10:00 AM',
  ),
  SecurityAlert(
    title: 'Password Expiring',
    description: 'Password for a key account is due to expire tomorrow',
    priority: 'Medium',
    date: '8/14/2024 09:00 AM',
  ),
];

final List<SecurityLog> mockLogs = [
  SecurityLog(
    title: 'User login successful',
    metadata: 'by John Adebayo • 8/15/2024 11:30 AM',
    status: 'Success',
  ),
  SecurityLog(
    title: 'Document download by Sarah Okwu',
    metadata: 'by Sarah Okwu • 8/15/2024 08:00 AM',
    status: 'Success',
  ),
  SecurityLog(
    title: 'Project update published',
    metadata: 'by Admin • 8/14/2024 05:00 PM',
    status: 'Success',
  ),
  SecurityLog(
    title: 'Client created new account',
    metadata: 'by System • 8/14/2024 04:00 PM',
    status: 'Success',
  ),
  SecurityLog(
    title: 'Portal access revoked',
    metadata: 'by System • 8/14/2024 03:00 PM',
    status: 'Success',
  ),
];

final List<SecurityCode> mockSecurityCodes = [
  SecurityCode(
    name: 'Emergency access code for data center',
    code: 'SEC-2024-001',
    accessType: 'Access',
    status: 'Active',
    assignedTo: 'IT Administrator',
    expires: '1/1/2025 12:59 AM',
  ),
  SecurityCode(
    name: 'Temporary API key for billing system',
    code: 'API-2024-042',
    accessType: 'API Key',
    status: 'Active',
    assignedTo: 'Finance Team',
    expires: '12/31/2024 11:59 PM',
  ),
  SecurityCode(
    name: 'Guest access token for visitors',
    code: 'TKN-2024-100',
    accessType: 'Token',
    status: 'Inactive',
    assignedTo: 'Receptionist',
    expires: '10/30/2024 05:00 PM',
  ),
];
