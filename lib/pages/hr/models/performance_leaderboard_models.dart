/// Performance Leaderboard data models
class LeaderboardEntry {
  final int rank;
  final String employeeId;
  final String employeeName;
  final String branch;
  final double performanceScore;
  final List<String> achievements; // Awards/achievements
  final String status; // Consistent Performer, Employee of the Month, etc.
  final String? profileImageUrl;

  LeaderboardEntry({
    required this.rank,
    required this.employeeId,
    required this.employeeName,
    required this.branch,
    required this.performanceScore,
    required this.achievements,
    required this.status,
    this.profileImageUrl,
  });

  /// Get medal emoji based on rank
  String getMedalEmoji() {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  /// Get rank color
  String getRankColor() {
    switch (rank) {
      case 1:
        return '#FFD700'; // Gold
      case 2:
        return '#C0C0C0'; // Silver
      case 3:
        return '#CD7F32'; // Bronze
      default:
        return '#E0E0E0'; // Gray
    }
  }

  /// Get status color
  String getStatusColor() {
    switch (status) {
      case 'Consistent Performer':
        return '#3498DB'; // Blue
      case 'Employee of the Month':
        return '#F39C12'; // Orange
      case 'Best Branch Rep':
        return '#2ECC71'; // Green
      case 'Rising Star':
        return '#9B59B6'; // Purple
      default:
        return '#95A5A6'; // Gray
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'branch': branch,
      'performanceScore': performanceScore,
      'achievements': achievements,
      'status': status,
      'profileImageUrl': profileImageUrl,
    };
  }
}

/// Top performers (top 3)
class TopPerformer {
  final int rank;
  final String employeeName;
  final String branch;
  final double score;
  final String medal; // 🥇 🥈 🥉

  TopPerformer({
    required this.rank,
    required this.employeeName,
    required this.branch,
    required this.score,
    required this.medal,
  });

  /// Get medal color
  String getMedalColor() {
    switch (rank) {
      case 1:
        return '#FFD700'; // Gold
      case 2:
        return '#C0C0C0'; // Silver
      case 3:
        return '#CD7F32'; // Bronze
      default:
        return '#E0E0E0';
    }
  }
}

/// Performance leaderboard summary
class PerformanceLeaderboardSummary {
  final String filterMonth; // Month filter
  final String filterBranch; // Branch filter
  final List<TopPerformer> topThree; // Top 3 performers
  final List<LeaderboardEntry> fullLeaderboard; // All entries
  final double averageScore;
  final int totalParticipants;
  final List<double> performanceTrend; // Last 12 months trend

  PerformanceLeaderboardSummary({
    required this.filterMonth,
    required this.filterBranch,
    required this.topThree,
    required this.fullLeaderboard,
    required this.averageScore,
    required this.totalParticipants,
    required this.performanceTrend,
  });

  /// Get top performer
  TopPerformer? getTopPerformer() {
    return topThree.isNotEmpty ? topThree.first : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'filterMonth': filterMonth,
      'filterBranch': filterBranch,
      'topThree': topThree.map((t) {
        return {
          'rank': t.rank,
          'employeeName': t.employeeName,
          'branch': t.branch,
          'score': t.score,
          'medal': t.medal,
        };
      }).toList(),
      'fullLeaderboard': fullLeaderboard.map((e) => e.toJson()).toList(),
      'averageScore': averageScore,
      'totalParticipants': totalParticipants,
      'performanceTrend': performanceTrend,
    };
  }
}

/// Performance status enum
enum PerformanceStatus {
  consistentPerformer('Consistent Performer', '✓', '#3498DB'),
  employeeOfTheMonth('Employee of the Month', '⭐', '#F39C12'),
  bestBranchRep('Best Branch Rep', '🏆', '#2ECC71'),
  risingStar('Rising Star', '📈', '#9B59B6'),
  newbie('Newbie', '🌱', '#95A5A6');

  final String displayName;
  final String icon;
  final String color;

  const PerformanceStatus(this.displayName, this.icon, this.color);
}
