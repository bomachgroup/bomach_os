import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LeadSourceData {
  final String name;
  final double percent;
  final Color color;

  LeadSourceData(this.name, this.percent, this.color);
}

class PipelineStageData {
  final String stage;
  final int count;

  PipelineStageData(this.stage, this.count);
}

class MetricData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  MetricData(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color,
      required this.subtitle});
}

class ClientItem {
  final String name;
  final String contact;
  final String type;
  final String industry;
  final String status;
  final String value;
  final int projects;

  ClientItem(
      {required this.name,
      required this.contact,
      required this.type,
      required this.industry,
      required this.status,
      required this.value,
      required this.projects});
}

class InteractionItem {
  final String client;
  final String type;
  final String subject;
  final String priority;
  final String status;
  final String date;
  final String createdBy;

  InteractionItem(
      {required this.client,
      required this.type,
      required this.subject,
      required this.priority,
      required this.status,
      required this.date,
      required this.createdBy});
}

class DocumentItem {
  final String title;
  final String type;
  final String access;
  final String description;
  final String client;
  final String size;
  final String author;
  final String date;
  final int downloads;

  DocumentItem(
      {required this.title,
      required this.type,
      required this.access,
      required this.description,
      required this.client,
      required this.size,
      required this.author,
      required this.date,
      required this.downloads});
}

class SalesLead {
  final String leadName;
  final String leadRepresentative;
  final String contactEmail;
  final String contactPhone;
  final String company;
  final String source;
  final String status;
  final int score;
  final String value;
  final String nextFollowUp;

  SalesLead({
    required this.leadName,
    required this.leadRepresentative,
    required this.contactEmail,
    required this.contactPhone,
    required this.company,
    required this.source,
    required this.status,
    required this.score,
    required this.value,
    required this.nextFollowUp,
  });
}

class ClientInteraction {
  final String client;
  final String type;
  final String subject;
  final String details;
  final String priority;
  final String status;
  final String date;
  final String createdBy;

  ClientInteraction({
    required this.client,
    required this.type,
    required this.subject,
    required this.details,
    required this.priority,
    required this.status,
    required this.date,
    required this.createdBy,
  });
}

final List<ClientInteraction> interactionsMock = [
  ClientInteraction(
    client: 'Lagos State Government',
    type: 'Meeting',
    subject: 'Lagos-Ibadan Expressway Survey Planning',
    details: 'Discussed the scope and timeline for the comprehensive survey.',
    priority: 'High',
    status: 'Completed',
    date: '15 Jan 2024',
    createdBy: 'Sarah Okonkwo',
  ),
  ClientInteraction(
    client: 'Dangote Group',
    type: 'Call',
    subject: 'Refinery Complex Boundary Survey Update',
    details: 'Provided progress update on the ongoing boundary demarcation.',
    priority: 'Medium',
    status: 'Completed',
    date: '20 Jan 2024',
    createdBy: 'James Adebayo',
  ),
  ClientInteraction(
    client: 'Federal Capital Development Authority',
    type: 'Email',
    subject: 'FCDA District Master Plan Survey Requirements',
    details:
        'Received detailed requirements for the Central Business District.',
    priority: 'High',
    status: 'Pending',
    date: '22 Jan 2024',
    createdBy: 'Technical Director',
  ),
  ClientInteraction(
    client: 'Lekki Gardens Estate Limited',
    type: 'Site Visit',
    subject: 'Phase 3 Development Site Inspection',
    details: 'Conducted site inspection for the new Phase 3 development area.',
    priority: 'Medium',
    status: 'Completed',
    date: '18 Jan 2024',
    createdBy: 'Site Survey Team',
  ),
  ClientInteraction(
    client: 'Nigeria LNG Limited',
    type: 'Meeting',
    subject: 'Safety Protocol Review for Plant Survey',
    details: 'Mandatory safety briefing and protocol review for upcoming work.',
    priority: 'Critical',
    status: 'In Progress',
    date: '25 Jan 2024',
    createdBy: 'Safety Officer',
  ),
  ClientInteraction(
    client: 'University of Lagos',
    type: 'Call',
    subject: 'New Faculty Building Survey Quote Request',
    details: 'Received request for quotation for topographic survey work.',
    priority: 'Medium',
    status: 'Pending',
    date: '28 Jan 2024',
    createdBy: 'Business Development',
  ),
];

final List<SalesLead> leadsMock = [
  SalesLead(
    leadName: 'Port Harcourt Industrial Layout',
    leadRepresentative: 'Eng. David Okoro',
    contactEmail: 'david.okoro@phc-development.ng',
    contactPhone: '+234 807 890 1234',
    company: 'Port Harcourt Development Authority',
    source: 'Referral',
    status: 'qualified',
    score: 85,
    value: '₦45,000,000',
    nextFollowUp: '5 Feb 2024',
  ),
  SalesLead(
    leadName: 'Abuja Metro Rail Extension',
    leadRepresentative: 'Eng. Aisha Mahmoud',
    contactEmail: 'aisha.mahmoud@fcta.gov.ng',
    contactPhone: '+234 808 901 2345',
    company: 'Federal Capital Territory Administration',
    source: 'Website',
    status: 'proposal',
    score: 92,
    value: '₦125,000,000',
    nextFollowUp: '8 Feb 2024',
  ),
  SalesLead(
    leadName: 'Kano Agricultural Zone Survey',
    leadRepresentative: 'Dr. Ibrahim Musa',
    contactEmail: 'ibrahim.musa@kano-agric.gov.ng',
    contactPhone: '+234 809 012 3456',
    company: 'Kano State Agricultural Development Program',
    source: 'Event',
    status: 'new',
    score: 65,
    value: '₦18,000,000',
    nextFollowUp: '12 Feb 2024',
  ),
  SalesLead(
    leadName: 'Chevron Tank Farm Expansion',
    leadRepresentative: 'Mrs. Kate Williams',
    contactEmail: 'kate.williams@chevron.com',
    contactPhone: '+234 810 123 4567',
    company: 'Chevron Nigeria Limited',
    source: 'Cold Call',
    status: 'qualified',
    score: 78,
    value: '₦85,000,000',
    nextFollowUp: '3 Feb 2024',
  ),
  SalesLead(
    leadName: 'Ibadan Smart City Project',
    leadRepresentative: 'Arc. Tunde Bakare',
    contactEmail: 'tunde.bakare@oyostate.gov.ng',
    contactPhone: '+234 811 234 5678',
    company: 'Oyo State Government',
    source: 'Social Media',
    status: 'new',
    score: 55,
    value: '₦95,000,000',
    nextFollowUp: '15 Feb 2024',
  ),
];
final List<ClientItem> mockTopClients = [
  ClientItem(
      name: 'Nigeria LNG Limited',
      contact: '',
      type: '',
      industry: '',
      status: 'active',
      value: '₦180,000,000',
      projects: 6),
  ClientItem(
      name: 'Dangote Group',
      contact: '',
      type: '',
      industry: '',
      status: 'active',
      value: '₦125,000,000',
      projects: 18),
  ClientItem(
      name: 'Lagos State Government',
      contact: '',
      type: '',
      industry: '',
      status: 'active',
      value: '₦85,000,000',
      projects: 12),
  ClientItem(
      name: 'FCDA',
      contact: '',
      type: '',
      industry: '',
      status: 'active',
      value: '₦62,000,000',
      projects: 8),
  ClientItem(
      name: 'Lekki Gardens Estate',
      contact: '',
      type: '',
      industry: '',
      status: 'active',
      value: '₦45,000,000',
      projects: 15),
];

// CRM Metrics
final List<MetricData> crmMetrics = [
  MetricData(
      title: 'Total Clients',
      value: '84',
      icon: Iconsax.people,
      color: Colors.blue.shade600,
      subtitle: 'Active client base'),
  MetricData(
      title: 'Conversion Rate',
      value: '68.5%',
      icon: Iconsax.trend_up,
      color: Colors.green.shade600,
      subtitle: 'Lead to client conversion'),
  MetricData(
      title: 'Total Revenue',
      value: '₦525,000,000',
      icon: Iconsax.money_recive,
      color: Colors.purple.shade600,
      subtitle: 'Lifetime client value'),
  MetricData(
      title: 'Retention Rate',
      value: '89.2%',
      icon: Iconsax.star1,
      color: Colors.orange.shade600,
      subtitle: 'Client retention rate'),
];

// Clients Data
final List<ClientItem> mockClients = [
  ClientItem(
      name: 'Lagos State Government',
      contact: 'adebayo.olumide@lagosstate.gov.ng\n+234 801 234 5678',
      type: 'Government',
      industry: 'Government',
      status: 'active',
      value: '₦85,000,000',
      projects: 12),
  ClientItem(
      name: 'Dangote Group',
      contact: 'sarah.okonkwo@dangote.com\n+234 802 345 6789',
      type: 'Corporate',
      industry: 'Construction',
      status: 'active',
      value: '₦125,000,000',
      projects: 18),
  ClientItem(
      name: 'Federal Capital Development Authority',
      contact: 'm.aliyu@fcda.gov.ng\n+234 803 456 7890',
      type: 'Government',
      industry: 'Government',
      status: 'active',
      value: '₦62,000,000',
      projects: 8),
  ClientItem(
      name: 'Lekki Gardens Estate Limited',
      contact: 'funmi.adebayo@lekkigardens.com\n+234 804 567 8901',
      type: 'Corporate',
      industry: 'Real Estate',
      status: 'active',
      value: '₦45,000,000',
      projects: 15),
  ClientItem(
      name: 'Nigeria LNG Limited',
      contact: 'chima.nwosu@nlng.com\n+234 805 678 9012',
      type: 'Corporate',
      industry: 'Oil & Gas',
      status: 'active',
      value: '₦180,000,000',
      projects: 6),
  ClientItem(
      name: 'University of Lagos',
      contact: 'a.ogunleye@unilag.edu.ng\n+234 806 789 0123',
      type: 'Institution',
      industry: 'Education',
      status: 'active',
      value: '₦28,000,000',
      projects: 5),
];

// Portal Metrics
final List<MetricData> portalMetrics = [
  MetricData(
      title: 'Total Interactions',
      value: '6',
      icon: Iconsax.message_text,
      color: Colors.blue.shade600,
      subtitle: 'Total Interactions'),
  MetricData(
      title: 'This Week',
      value: '0',
      icon: Iconsax.calendar_1,
      color: Colors.green.shade600,
      subtitle: 'This Week'),
  MetricData(
      title: 'Pending Actions',
      value: '2',
      icon: Iconsax.clock,
      color: Colors.orange.shade600,
      subtitle: 'Pending Actions'),
  MetricData(
      title: 'High Priority',
      value: '3',
      icon: Iconsax.danger,
      color: Colors.red.shade600,
      subtitle: 'High Priority'),
];

// Documents
final List<DocumentItem> mockDocuments = [
  DocumentItem(
      title: 'Lekki Survey Final Report.pdf',
      type: 'Report',
      access: 'Available',
      description: 'Complete surveying report for Lekki Phase 2 residents',
      client: 'Lagos Property Development Ltd',
      size: '4.2 MB',
      author: 'John Doe',
      date: '5 Feb 2024',
      downloads: 8),
  DocumentItem(
      title: 'Environmental Assessment Guidelines.pdf',
      type: 'Other',
      access: 'Restricted',
      description: 'Environmental impact assessment guidelines and pro',
      client: 'Rivers State Development Company',
      size: '3.5 MB',
      author: 'Dr. Emeka Okafor',
      date: '4 Feb 2024',
      downloads: 1),
  DocumentItem(
      title: 'Project Contract - Highway Survey.pdf',
      type: 'Contract',
      access: 'Available',
      description: 'Signed contract for Abuja-Kaduna highway expansion',
      client: 'Abuja Infrastructure Company',
      size: '2.8 MB',
      author: 'Abuja Infrastructure Company',
      date: '28 Jan 2024',
      downloads: 5),
  DocumentItem(
      title: 'Monthly Invoice - January 2024.pdf',
      type: 'Invoice',
      access: 'Available',
      description: 'Invoice for services rendered in January 2024',
      client: 'Lagos Property Development Ltd',
      size: '0.8 MB',
      author: 'Grace Adebayo',
      date: '1 Feb 2024',
      downloads: 3),
];
