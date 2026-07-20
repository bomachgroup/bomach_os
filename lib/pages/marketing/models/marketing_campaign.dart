import 'marketing_lead.dart';

enum CampaignStatus {
  draft,
  pendingApproval,
  planned,
  active,
  paused,
  completed;

  String get label {
    switch (this) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.pendingApproval:
        return 'Pending Approval';
      case CampaignStatus.planned:
        return 'Planned';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
    }
  }

  static CampaignStatus fromString(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '');
    return CampaignStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => CampaignStatus.draft,
    );
  }
}

class MarketingCampaignV2 {
  final int? id;
  final String name;
  final MarketingDivision division;
  final CampaignStatus status;
  final double budget;
  final double spent;
  final int leads;
  final String costPerLead;
  final String conversionRate;
  final int? daysActive;
  final String channels;
  final String? description;
  final String? owner;

  const MarketingCampaignV2({
    this.id,
    required this.name,
    required this.division,
    required this.status,
    this.budget = 0,
    this.spent = 0,
    this.leads = 0,
    this.costPerLead = '—',
    this.conversionRate = '—',
    this.daysActive,
    this.channels = '',
    this.description,
    this.owner,
  });

  factory MarketingCampaignV2.fromJson(Map<String, dynamic> json) {
    return MarketingCampaignV2(
      id: json['id'],
      name: json['name'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      status: CampaignStatus.fromString(json['status'] ?? 'draft'),
      budget: (json['budget'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      leads: json['leads'] ?? 0,
      costPerLead: json['cpl'] ?? '—',
      conversionRate: json['conv'] ?? '—',
      daysActive: json['days'],
      channels: json['channels'] ?? '',
      description: json['description'],
      owner: json['owner'],
    );
  }

  double get progressPercentage =>
      budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0;

  bool get isOverBudget => spent > budget;

  String get budgetFormatted {
    if (budget >= 1000000) {
      return '₦${(budget / 1000000).toStringAsFixed(1)}M';
    } else if (budget >= 1000) {
      return '₦${(budget / 1000).toStringAsFixed(0)}K';
    }
    return '₦${budget.toStringAsFixed(0)}';
  }

  String get spentFormatted {
    if (spent >= 1000000) {
      return '₦${(spent / 1000000).toStringAsFixed(1)}M';
    } else if (spent >= 1000) {
      return '₦${(spent / 1000).toStringAsFixed(0)}K';
    }
    return '₦${spent.toStringAsFixed(0)}';
  }
}

class CampaignRequest {
  final String id;
  final String title;
  final String requestedBy;
  final MarketingDivision division;
  final String status;
  final String date;

  const CampaignRequest({
    required this.id,
    required this.title,
    required this.requestedBy,
    required this.division,
    required this.status,
    required this.date,
  });

  factory CampaignRequest.fromJson(Map<String, dynamic> json) {
    return CampaignRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      requestedBy: json['requested_by'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      status: json['status'] ?? 'pending',
      date: json['date'] ?? '',
    );
  }
}

class CampaignTemplate {
  final String name;
  final String icon;
  final String description;

  const CampaignTemplate({
    required this.name,
    required this.icon,
    required this.description,
  });
}

class CampaignUpdate {
  final String author;
  final String time;
  final String body;
  final bool isUrgent;

  const CampaignUpdate({
    required this.author,
    required this.time,
    required this.body,
    this.isUrgent = false,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) {
    return CampaignUpdate(
      author: json['author'] ?? '',
      time: json['time'] ?? '',
      body: json['body'] ?? '',
      isUrgent: json['is_urgent'] ?? false,
    );
  }
}
