/// Awards & Recognition data models
class Award {
  final String id;
  final String awardName;
  final String
      awardCategory; // Employee of the Month, Excellence Winner, Team Player, etc.
  final String awardIcon; // Unicode emoji or icon
  final String description;
  final DateTime awardDate;
  final String? awardedBy;
  final String? location; // Branch or location name
  final String color; // Hex color for the award card

  Award({
    required this.id,
    required this.awardName,
    required this.awardCategory,
    required this.awardIcon,
    required this.description,
    required this.awardDate,
    this.awardedBy,
    this.location,
    required this.color,
  });

  /// Format award date as "Month Year"
  String getFormattedDate() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[awardDate.month - 1]} ${awardDate.year}';
  }

  /// Get month name only
  String getMonth() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[awardDate.month - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'awardName': awardName,
      'awardCategory': awardCategory,
      'awardIcon': awardIcon,
      'description': description,
      'awardDate': awardDate.toIso8601String(),
      'awardedBy': awardedBy,
      'location': location,
      'color': color,
    };
  }
}

/// Employee awards profile
class EmployeeAwardsProfile {
  final String employeeId;
  final String employeeEmail;
  final String employeeRole;
  final String? profileImageUrl;
  final List<Award> awards;
  final int totalAwards;

  EmployeeAwardsProfile({
    required this.employeeId,
    required this.employeeEmail,
    required this.employeeRole,
    this.profileImageUrl,
    required this.awards,
    required this.totalAwards,
  });

  /// Get recent awards (last 3)
  List<Award> getRecentAwards() {
    final sorted = List<Award>.from(awards)
      ..sort((a, b) => b.awardDate.compareTo(a.awardDate));
    return sorted.take(3).toList();
  }

  /// Get awards grouped by month
  Map<String, List<Award>> getAwardsByMonth() {
    final map = <String, List<Award>>{};
    for (var award in awards) {
      final month = award.getMonth();
      if (!map.containsKey(month)) {
        map[month] = [];
      }
      map[month]!.add(award);
    }
    return map;
  }

  /// Get awards by category
  Map<String, List<Award>> getAwardsByCategory() {
    final map = <String, List<Award>>{};
    for (var award in awards) {
      if (!map.containsKey(award.awardCategory)) {
        map[award.awardCategory] = [];
      }
      map[award.awardCategory]!.add(award);
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeEmail': employeeEmail,
      'employeeRole': employeeRole,
      'profileImageUrl': profileImageUrl,
      'awards': awards.map((a) => a.toJson()).toList(),
      'totalAwards': totalAwards,
    };
  }
}

/// Award categories enum
enum AwardCategory {
  employeeOfMonth('Employee of the Month', '🏆', '#F4C430'),
  stateExcellence('State Excellence Winner', '👑', '#E74C3C'),
  dependableTeamPlayer('Dependable Team Player', '👥', '#3498DB'),
  innovationLeader('Innovation Leader', '💡', '#9B59B6'),
  customerChampion('Customer Champion', '⭐', '#2ECC71'),
  safetyExcel('Safety Excel Award', '🛡️', '#E67E22'),
  leadershipExcellence('Leadership Excellence', '🎖️', '#34495E'),
  communityChampion('Community Champion', '🤝', '#16A34A');

  final String displayName;
  final String icon;
  final String color;

  const AwardCategory(this.displayName, this.icon, this.color);
}

/// Award recognition summary
class AwardsRecognitionSummary {
  final int totalEmployeesWithAwards;
  final int totalAwardsGiven;
  final List<Award> topAwards; // Most common awards
  final Map<String, int> awardDistribution;
  final int currentMonthAwards;

  AwardsRecognitionSummary({
    required this.totalEmployeesWithAwards,
    required this.totalAwardsGiven,
    required this.topAwards,
    required this.awardDistribution,
    required this.currentMonthAwards,
  });

  double getAverageAwardsPerEmployee() {
    if (totalEmployeesWithAwards == 0) return 0;
    return totalAwardsGiven / totalEmployeesWithAwards;
  }
}
