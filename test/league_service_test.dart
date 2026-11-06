import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/services/league_service.dart';

void main() {
  group('LeagueService Tests', () {
    test('Gera ranking com competidores reais incluindo o usuário atual', () {
      final list = LeagueService.generateRankedList(100, userName: 'Novo Jogador');
      expect(list.isNotEmpty, true);
      expect(list.where((p) => p.isCurrentUser).length, 1);
      expect(list.firstWhere((p) => p.isCurrentUser).name, 'Novo Jogador');
      expect(list.firstWhere((p) => p.isCurrentUser).xp, 100);
    });

    test('Usuário fica no Top 1 e na Zona de Promoção', () {
      final list = LeagueService.generateRankedList(1000);
      expect(list.first.isCurrentUser, true);
      expect(list.first.xp, 1000);

      final rank = LeagueService.getUserRank(1000);
      expect(rank, 1);
      expect(LeagueService.isPromotion(rank), true);
      expect(LeagueService.isRelegation(rank), false);
    });

    test('Limiares de Promoção e Rebaixamento', () {
      expect(LeagueService.isPromotion(1), true);
      expect(LeagueService.isPromotion(7), true);
      expect(LeagueService.isPromotion(8), false);

      expect(LeagueService.isRelegation(25), false);
      expect(LeagueService.isRelegation(26), true);
    });
  });
}
