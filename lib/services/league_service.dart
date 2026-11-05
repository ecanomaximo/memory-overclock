import '../models/league_player.dart';

class LeagueService {
  static const int totalPlayers = 30;
  static const int promotionThreshold = 7;
  static const int relegationThreshold = 25; // 26 a 30 são rebaixados

  static final List<LeaguePlayer> _baseOpponents = [
    const LeaguePlayer(id: 'p1', name: 'Lucas_Foco 🔥', xp: 580, avatarEmoji: '⚡'),
    const LeaguePlayer(id: 'p2', name: 'Ana_Neuro 🧠', xp: 520, avatarEmoji: '🔮'),
    const LeaguePlayer(id: 'p3', name: 'CyberSamurai', xp: 480, avatarEmoji: '🥷'),
    const LeaguePlayer(id: 'p4', name: 'Beatriz_Gamer', xp: 440, avatarEmoji: '🎮'),
    const LeaguePlayer(id: 'p5', name: 'Pedro_Overclock', xp: 410, avatarEmoji: '🚀'),
    const LeaguePlayer(id: 'p6', name: 'Larissa_Mind', xp: 390, avatarEmoji: '🦊'),
    const LeaguePlayer(id: 'p7', name: 'Gabriel_Fast', xp: 350, avatarEmoji: '🐯'),
    const LeaguePlayer(id: 'p8', name: 'Camila_Zen', xp: 320, avatarEmoji: '🌸'),
    const LeaguePlayer(id: 'p9', name: 'Matheus_99', xp: 300, avatarEmoji: '👾'),
    const LeaguePlayer(id: 'p10', name: 'Juliana_Focus', xp: 280, avatarEmoji: '🦁'),
    const LeaguePlayer(id: 'p11', name: 'Rafael_Pro', xp: 260, avatarEmoji: '🎯'),
    const LeaguePlayer(id: 'p12', name: 'Mariana_Tech', xp: 240, avatarEmoji: '💻'),
    const LeaguePlayer(id: 'p13', name: 'Felipe_Speed', xp: 210, avatarEmoji: '⚡'),
    const LeaguePlayer(id: 'p14', name: 'Bruna_Synapse', xp: 190, avatarEmoji: '✨'),
    const LeaguePlayer(id: 'p15', name: 'Diego_Runner', xp: 170, avatarEmoji: '🏃'),
    const LeaguePlayer(id: 'p16', name: 'Sophia_Spark', xp: 150, avatarEmoji: '💥'),
    const LeaguePlayer(id: 'p17', name: 'Enzo_Gamer', xp: 130, avatarEmoji: '🕹️'),
    const LeaguePlayer(id: 'p18', name: 'Isabela_Mind', xp: 120, avatarEmoji: '🦄'),
    const LeaguePlayer(id: 'p19', name: 'Thiago_Neo', xp: 100, avatarEmoji: '🤖'),
    const LeaguePlayer(id: 'p20', name: 'Helena_Star', xp: 90, avatarEmoji: '⭐'),
    const LeaguePlayer(id: 'p21', name: 'Nicolas_Bot', xp: 80, avatarEmoji: '🪐'),
    const LeaguePlayer(id: 'p22', name: 'Luiza_Pixel', xp: 70, avatarEmoji: '🎨'),
    const LeaguePlayer(id: 'p23', name: 'Guilherme_X', xp: 60, avatarEmoji: '🦖'),
    const LeaguePlayer(id: 'p24', name: 'Alice_Memory', xp: 50, avatarEmoji: '🎈'),
    const LeaguePlayer(id: 'p25', name: 'Arthur_Flash', xp: 40, avatarEmoji: '🔥'),
    const LeaguePlayer(id: 'p26', name: 'Manuela_Vibe', xp: 30, avatarEmoji: '🎧'),
    const LeaguePlayer(id: 'p27', name: 'Bernardo_9', xp: 20, avatarEmoji: '⚽'),
    const LeaguePlayer(id: 'p28', name: 'Valentina_Go', xp: 10, avatarEmoji: '🚀'),
    const LeaguePlayer(id: 'p29', name: 'Davi_Sleepy', xp: 0, avatarEmoji: '💤'),
  ];

  static List<LeaguePlayer> generateRankedList(int userWeeklyXp) {
    final list = <LeaguePlayer>[
      ..._baseOpponents,
      LeaguePlayer(
        id: 'current_user',
        name: 'Você (Operador)',
        xp: userWeeklyXp,
        isCurrentUser: true,
        avatarEmoji: '👑',
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

  static int getUserRank(int userWeeklyXp) {
    final ranked = generateRankedList(userWeeklyXp);
    return ranked.indexWhere((p) => p.isCurrentUser) + 1;
  }

  static bool isPromotion(int rank) => rank >= 1 && rank <= promotionThreshold;
  static bool isRelegation(int rank) => rank > relegationThreshold;
}
