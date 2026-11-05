import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/services/league_service.dart';

void main() {
  group('LeagueService Tests', () {
    test('Sempre gera exatamente 30 competidores incluindo o usuário', () {
      final list = LeagueService.generateRankedList(100);
      expect(list.length, 30);
      expect(list.where((p) => p.isCurrentUser).length, 1);
    });

    test('Usuário com alto XP fica no Top 1 e na Zona de Promoção', () {
      final list = LeagueService.generateRankedList(1000);
      expect(list.first.isCurrentUser, true);
      expect(list.first.xp, 1000);

      final rank = LeagueService.getUserRank(1000);
      expect(rank, 1);
      expect(LeagueService.isPromotion(rank), true);
      expect(LeagueService.isRelegation(rank), false);
    });

    test('Usuário com 0 XP fica na Zona de Rebaixamento (últimos 5)', () {
      final rank = LeagueService.getUserRank(0);
      expect(rank, greaterThanOrEqualTo(26));
      expect(LeagueService.isPromotion(rank), false);
      expect(LeagueService.isRelegation(rank), true);
    });

    test('Desempate de XP prioriza o usuário atual', () {
      // 580 XP é a mesma pontuação de Lucas_Foco
      final list = LeagueService.generateRankedList(580);
      final userIndex = list.indexWhere((p) => p.isCurrentUser);
      final lucasIndex = list.indexWhere((p) => p.name.contains('Lucas_Foco'));

      expect(userIndex, lessThan(lucasIndex));
    });
  });
}
