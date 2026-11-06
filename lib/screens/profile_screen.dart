import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cadence_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/survey_analytics_sheet.dart';
import 'onboarding_survey_screen.dart';
import 'paywall_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ProgressService progressService;
  final CadenceService? cadenceService;
  final VoidCallback onGoToTrack;

  const ProfileScreen({
    super.key,
    required this.progressService,
    this.cadenceService,
    required this.onGoToTrack,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressService,
      builder: (context, _) {
        final progress = progressService.progress;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AppBar(
                  title: Text(
                    'PAINEL COGNITIVO',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Ver / Refazer Formulário',
                      icon: const Icon(Icons.assignment_turned_in_outlined, size: 20, color: AppTheme.focusCyan),
                      onPressed: () => _openSurvey(context),
                    ),
                    IconButton(
                      tooltip: 'Extração Analítica de Formulários',
                      icon: const Icon(Icons.analytics_outlined, size: 20, color: AppTheme.focusCyan),
                      onPressed: () => SurveyAnalyticsSheet.show(context, progressService),
                    ),
                    IconButton(
                      tooltip: 'Sair da Conta',
                      icon: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.textMuted),
                      onPressed: () => progressService.logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(context, progress),
                      const SizedBox(height: 18),
                      _buildCognitiveDiagnosisCard(context, progress),
                      const SizedBox(height: 18),
                      _buildPlayActionCard(context),
                      const SizedBox(height: 18),
                      _buildDailyBattery(context, progress),
                      const SizedBox(height: 18),
                      _buildCognitiveMetrics(progress),
                      const SizedBox(height: 18),
                      _buildDailyMissionCard(progress),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(BuildContext context, dynamic progress) {
    final bool isVip = progress.isVip;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVip
              ? AppTheme.prestigeGold.withValues(alpha: 0.5)
              : AppTheme.surfaceBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Avatar com anel de status neuroergonômico
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isVip ? AppTheme.prestigeGold : AppTheme.focusCyan,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isVip ? AppTheme.prestigeGold : AppTheme.focusCyan)
                      .withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.surfaceElevated,
              child: Icon(
                isVip ? Icons.workspace_premium : Icons.person_rounded,
                color: isVip ? AppTheme.prestigeGold : AppTheme.focusCyan,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Informações do Usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        progress.userName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isVip)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.prestigeGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.prestigeGold, width: 0.8),
                        ),
                        child: Text(
                          'VIP',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.prestigeGold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fase ${progress.currentLevel} • Neuroplasticidade Ativa',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppTheme.rewardGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Botão Sair da Conta
          IconButton(
            tooltip: 'Sair da Conta (Trocar de Usuário)',
            icon: const Icon(Icons.logout_rounded, color: AppTheme.alertPink, size: 22),
            onPressed: () => progressService.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayActionCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.focusCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.explore_rounded, size: 22),
        label: Text(
          'CONTINUAR NA TRILHA',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        onPressed: onGoToTrack,
      ),
    );
  }

  Widget _buildDailyBattery(BuildContext context, dynamic progress) {
    final int left = progress.dailyChallengesLeft;
    final int max = progress.maxChallenges;
    final double percent = progress.isDevUnlimited ? 1.0 : (left / max).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.battery_charging_full_rounded, color: AppTheme.focusCyan, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Bateria de Foco (5 Atividades)',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                progress.isDevUnlimited ? 'ILIMITADO' : '$left / $max slots',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: left > 0 ? AppTheme.focusCyan : AppTheme.alertPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppTheme.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                left > 0 ? AppTheme.rewardGreen : AppTheme.alertPink,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recarrega 5 atividades a cada 5 horas',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!progress.isVip) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaywallScreen(progressService: progressService),
                      ),
                    );
                  },
                  child: Text(
                    'Obter 10/dia (VIP) →',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.prestigeGold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (cadenceService != null) ...[
            const Divider(color: AppTheme.surfaceBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: AppTheme.focusCyan, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Ciclo de 5 Horas:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  cadenceService!.isVip
                      ? 'Ilimitadas'
                      : '${cadenceService!.availableActivities} / ${cadenceService!.maxActivities} Atividades',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.focusCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Recarga de 5 atividades em: ${cadenceService!.formatTimeRemaining()}',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.habitAmber),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCognitiveMetrics(dynamic progress) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.local_fire_department_rounded,
            color: AppTheme.habitAmber,
            label: 'Ofensiva',
            value: '${progress.streak} dias',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.psychology_rounded,
            color: AppTheme.rewardGreen,
            label: 'XP Semanal',
            value: '${progress.weeklyXp}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.military_tech_rounded,
            color: AppTheme.prestigeGold,
            label: 'Divisão',
            value: progress.leagueTier.replaceAll('Liga ', ''),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMissionCard(dynamic progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.calmIndigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.track_changes_rounded, color: AppTheme.calmIndigo, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meta de Treino Diário',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mantenha 3 sessões diárias para desacelerar o esquecimento cognitivo.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveDiagnosisCard(BuildContext context, dynamic progress) {
    final survey = progress.surveyData;
    final title = survey?.profileTitle ?? 'Alívio de Ansiedade & Clareza Mental';
    final domain = survey?.recommendedFocusDomain ?? 'Controle Inibitório & Atenção Sustentada';
    final commitment = survey?.dailyCommitmentMinutes ?? 10;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.focusCyan.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.focusCyan.withValues(alpha: 0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.focusCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: AppTheme.focusCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEU PERFIL NEUROCOGNITIVO',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.focusCyan,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Foco Primário: $domain • Meta: $commitment min/dia',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.focusCyan,
                    foregroundColor: const Color(0xFF0A0F1D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () => _openSurvey(context),
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                  label: Text(
                    'Ver / Refazer Formulário',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.focusCyan,
                side: const BorderSide(color: AppTheme.focusCyan, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => SurveyAnalyticsSheet.show(context, progressService),
              icon: const Icon(Icons.bar_chart_rounded, size: 18),
              label: Text(
                'Ver Estudo de Porcentagens & Extrair Dados',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSurvey(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingSurveyScreen(
          progressService: progressService,
          onFinished: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
