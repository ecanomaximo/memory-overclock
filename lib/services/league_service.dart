import '../models/league_player.dart';

class LeagueService {
  static const int totalPlayers = 30;
  static const int promotionThreshold = 7;
  static const int relegationThreshold = 25; // 26 a 30 são rebaixados

  // Lista limpa para participantes reais (bots simulados removidos)
  static final List<LeaguePlayer> _realOpponents = [];

  static List<LeaguePlayer> generateRankedList(int userWeeklyXp, {String userName = 'Você (Operador)'}) {
    final list = <LeaguePlayer>[
      ..._realOpponents,
      LeaguePlayer(
        id: 'current_user',
        name: userName,
        xp: userWeeklyXp,
        isCurrentUser: true,
        avatarEmoji: '⚡',
      ),
    ];

    list.sort((a, b) {
      final comp = b.xp.compareTo(a.xp);
      if (comp != 0) return comp;
      // Se empatar, usuário atual fica à frente
      if (a.isCurrentUser) return -1;
      if (b.isCurrentUser) return 1;
      return a.name.compareTo(b.name);
    });

    return list;
  }

  static int getUserRank(int userWeeklyXp, {String userName = 'Você (Operador)'}) {
    final ranked = generateRankedList(userWeeklyXp, userName: userName);
    return ranked.indexWhere((p) => p.isCurrentUser) + 1;
  }

  static bool isPromotion(int rank) => rank >= 1 && rank <= promotionThreshold;
  static bool isRelegation(int rank) => rank > relegationThreshold;
}
