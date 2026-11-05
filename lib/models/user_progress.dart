class UserProgress {
  static const int freeDailyLimit = 3;
  static const int vipDailyLimit = 10;

  bool isLoggedIn;
  String userName;
  String userEmail;
  String userPhotoUrl;
  String authProvider; // 'google', 'apple', 'guest'

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
    this.isLoggedIn = false,
    this.userName = 'Alexandre Silva',
    this.userEmail = 'alexandre@gmail.com',
    this.userPhotoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    this.authProvider = 'google',
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
        'isLoggedIn': isLoggedIn,
        'userName': userName,
        'userEmail': userEmail,
        'userPhotoUrl': userPhotoUrl,
        'authProvider': authProvider,
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
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      userName: json['userName'] as String? ?? 'Alexandre Silva',
      userEmail: json['userEmail'] as String? ?? 'alexandre@gmail.com',
      userPhotoUrl: json['userPhotoUrl'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      authProvider: json['authProvider'] as String? ?? 'google',
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
