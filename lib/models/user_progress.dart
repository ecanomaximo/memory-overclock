class UserProgress {
  static const int freeDailyLimit = 3;
  static const int vipDailyLimit = 10;

  int streak;
  DateTime? lastPlayedDate;
  int dailyChallengesLeft;
  String lastResetDate; // Formato YYYY-MM-DD
  bool isVip;
  bool isDevUnlimited;
  int currentLevel;
  int weeklyXp;
  String leagueTier;

  UserProgress({
    this.streak = 0,
    this.lastPlayedDate,
    this.dailyChallengesLeft = freeDailyLimit,
    required this.lastResetDate,
    this.isVip = false,
    this.isDevUnlimited = false,
    this.currentLevel = 1,
    this.weeklyXp = 0,
    this.leagueTier = 'Liga Bronze',
  });

  int get maxChallenges => isDevUnlimited
      ? 999
      : isVip
          ? vipDailyLimit
          : freeDailyLimit;

  Map<String, dynamic> toJson() => {
        'streak': streak,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
        'dailyChallengesLeft': dailyChallengesLeft,
        'lastResetDate': lastResetDate,
        'isVip': isVip,
        'isDevUnlimited': isDevUnlimited,
        'currentLevel': currentLevel,
        'weeklyXp': weeklyXp,
        'leagueTier': leagueTier,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      streak: json['streak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.tryParse(json['lastPlayedDate'] as String)
          : null,
      dailyChallengesLeft: json['dailyChallengesLeft'] as int? ?? freeDailyLimit,
      lastResetDate: json['lastResetDate'] as String? ?? '',
      isVip: json['isVip'] as bool? ?? false,
      isDevUnlimited: json['isDevUnlimited'] as bool? ?? false,
      currentLevel: json['currentLevel'] as int? ?? 1,
      weeklyXp: json['weeklyXp'] as int? ?? 0,
      leagueTier: json['leagueTier'] as String? ?? 'Liga Bronze',
    );
  }
}
