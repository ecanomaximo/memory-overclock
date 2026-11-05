class LeaguePlayer {
  final String name;
  final int xp;
  final bool isCurrentUser;
  final String avatarEmoji;

  LeaguePlayer({
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
    required this.avatarEmoji,
  });
}

class LeagueManager {
  static List<LeaguePlayer> generateLeague(int userXp) {
    // 29 adversários simulados com pontuações realistas da semana
    final baseOpponents = [
      LeaguePlayer(name: 'Lucas_Foco 🔥', xp: 580, avatarEmoji: '⚡'),
      LeaguePlayer(name: 'Ana_Neuro 🧠', xp: 520, avatarEmoji: '🔮'),
      LeaguePlayer(name: 'CyberSamurai', xp: 480, avatarEmoji: '🥷'),
      LeaguePlayer(name: 'Beatriz_Gamer', xp: 440, avatarEmoji: '🎮'),
      LeaguePlayer(name: 'Pedro_Overclock', xp: 410, avatarEmoji: '🚀'),
      LeaguePlayer(name: 'Larissa_Mind', xp: 390, avatarEmoji: '🦊'),
      LeaguePlayer(name: 'Gabriel_Fast', xp: 350, avatarEmoji: '🐯'),
      LeaguePlayer(name: 'Camila_Zen', xp: 320, avatarEmoji: '🌸'),
      LeaguePlayer(name: 'Matheus_99', xp: 300, avatarEmoji: '👾'),
      LeaguePlayer(name: 'Juliana_Focus', xp: 280, avatarEmoji: '🦁'),
      LeaguePlayer(name: 'Rafael_Pro', xp: 260, avatarEmoji: '🎯'),
      LeaguePlayer(name: 'Mariana_Tech', xp: 240, avatarEmoji: '💻'),
      LeaguePlayer(name: 'Felipe_Speed', xp: 210, avatarEmoji: '⚡'),
      LeaguePlayer(name: 'Bruna_Synapse', xp: 190, avatarEmoji: '✨'),
      LeaguePlayer(name: 'Diego_Runner', xp: 170, avatarEmoji: '🏃'),
      LeaguePlayer(name: 'Sophia_Spark', xp: 150, avatarEmoji: '💥'),
      LeaguePlayer(name: 'Enzo_Gamer', xp: 130, avatarEmoji: '🕹️'),
      LeaguePlayer(name: 'Isabela_Mind', xp: 120, avatarEmoji: '🦄'),
      LeaguePlayer(name: 'Thiago_Neo', xp: 100, avatarEmoji: '🤖'),
      LeaguePlayer(name: 'Helena_Star', xp: 90, avatarEmoji: '⭐'),
      LeaguePlayer(name: 'Nicolas_Bot', xp: 80, avatarEmoji: '🪐'),
      LeaguePlayer(name: 'Luiza_Pixel', xp: 70, avatarEmoji: '🎨'),
      LeaguePlayer(name: 'Guilherme_X', xp: 60, avatarEmoji: '🦖'),
      LeaguePlayer(name: 'Alice_Memory', xp: 50, avatarEmoji: '🎈'),
      LeaguePlayer(name: 'Arthur_Flash', xp: 40, avatarEmoji: '🔥'),
      LeaguePlayer(name: 'Manuela_Vibe', xp: 30, avatarEmoji: '🎧'),
      LeaguePlayer(name: 'Bernardo_9', xp: 20, avatarEmoji: '⚽'),
      LeaguePlayer(name: 'Valentina_Go', xp: 10, avatarEmoji: '🚀'),
      LeaguePlayer(name: 'Davi_Sleepy', xp: 0, avatarEmoji: '💤'),
    ];

    // Adiciona o jogador atual
    final all = <LeaguePlayer>[
      ...baseOpponents,
      LeaguePlayer(
        name: 'Você (Jogador)',
        xp: userXp,
        isCurrentUser: true,
        avatarEmoji: '👑',
      ),
    ];

    // Ordena do maior XP para o menor
    all.sort((a, b) => b.xp.compareTo(a.xp));
    return all;
  }
}
