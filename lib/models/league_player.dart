class LeaguePlayer {
  final String id;
  final String name;
  final int xp;
  final bool isCurrentUser;
  final String avatarEmoji;

  const LeaguePlayer({
    required this.id,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
    required this.avatarEmoji,
  });

  LeaguePlayer copyWith({
    String? id,
    String? name,
    int? xp,
    bool? isCurrentUser,
    String? avatarEmoji,
  }) {
    return LeaguePlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}
