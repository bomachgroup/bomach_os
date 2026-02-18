class LeaderboardEntry {
  final int rank;
  final String employeeId;
  final String employeeName;
  final String branch;
  final double score;
  final String? award;

  LeaderboardEntry({
    required this.rank,
    required this.employeeId,
    required this.employeeName,
    required this.branch,
    required this.score,
    this.award,
  });

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

  String getMedalColor() {
    switch (rank) {
      case 1:
        return '#FFD700';
      case 2:
        return '#C0C0C0';
      case 3:
        return '#CD7F32';
      default:
        return '#E0E0E0';
    }
  }

  String getStatusColor() {
    if (award == null || award!.isEmpty) return '#3498DB';
    final a = award!.toLowerCase();
    if (a.contains('month')) return '#F39C12';
    if (a.contains('branch')) return '#2ECC71';
    if (a.contains('star')) return '#9B59B6';
    return '#3498DB';
  }

  String get statusLabel => award ?? 'Participant';

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      employeeId: json['employee_id']?.toString() ?? '',
      employeeName: json['employee_name'] ?? '',
      branch: json['branch'] ?? '',
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0,
      award: json['award'],
    );
  }
}

class LeaderboardResponse {
  final int month;
  final int year;
  final List<LeaderboardEntry> entries;
  final double avgScore;
  final int totalParticipants;

  LeaderboardResponse({
    required this.month,
    required this.year,
    required this.entries,
    required this.avgScore,
    required this.totalParticipants,
  });

  List<LeaderboardEntry> get topThree =>
      entries.where((e) => e.rank <= 3).toList();

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      month: json['month'] is int
          ? json['month']
          : int.tryParse(json['month']?.toString() ?? '1') ?? 1,
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e))
              .toList() ??
          [],
      avgScore:
          double.tryParse(json['avg_score']?.toString() ?? '0') ?? 0,
      totalParticipants: json['total_participants'] is int
          ? json['total_participants']
          : int.tryParse(json['total_participants']?.toString() ?? '0') ?? 0,
    );
  }
}
