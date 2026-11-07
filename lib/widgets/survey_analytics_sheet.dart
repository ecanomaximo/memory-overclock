import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/onboarding_survey.dart';
import '../services/progress_service.dart';
import '../services/survey_analytics_service.dart';
import '../theme/app_theme.dart';

class SurveyAnalyticsSheet extends StatelessWidget {
  final ProgressService progressService;

  const SurveyAnalyticsSheet({super.key, required this.progressService});

  static void show(BuildContext context, ProgressService progressService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 620),
      builder: (ctx) => SurveyAnalyticsSheet(progressService: progressService),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Agrega o formulário do usuário atual com a base amostral para o estudo
    final dataset = <OnboardingSurveyData>[
      ...SurveyAnalyticsService.getSampleResearchDataset(),
    ];

    if (progressService.progress.surveyData != null) {
      dataset.add(progressService.progress.surveyData!);
    }

    final report = SurveyAnalyticsService.generateReport(dataset);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 600,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.focusCyan.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
          // Barra de arrasto
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabeçalho
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTUDO NEUROCOGNITIVO',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Extração Analítica (${report.totalCount} respondentes)',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppTheme.focusCyan,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.surfaceBorder),

          // Lista de Seções com Porcentagens
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: '1. Motivação Principal (Por que baixou o app?)',
                    icon: Icons.flag_rounded,
                    color: AppTheme.focusCyan,
                    data: report.goalPercentages,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: '2. Sintomas Mais Intensos Sentidos',
                    icon: Icons.psychology_rounded,
                    color: AppTheme.alertPink,
                    data: report.symptomPercentages,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: '3. Prevalência de Ansiedade e Sobrecarga',
                    icon: Icons.spa_rounded,
                    color: AppTheme.prestigeGold,
                    data: report.stressFrequencyPercentages,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: '4. Meta Diária de Treino Escolhida',
                    icon: Icons.timer_rounded,
                    color: AppTheme.rewardGreen,
                    data: report.commitmentPercentages,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botão Inferior de Extração
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceElevated,
              border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.focusCyan,
                  foregroundColor: const Color(0xFF0A0F1D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  final jsonString = SurveyAnalyticsService.exportDatasetJson(dataset);
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '📋 Dados brutos em JSON copiados para a área de transferência!',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      backgroundColor: AppTheme.rewardGreen,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.file_download_rounded, size: 20),
                label: Text(
                  'EXTRAIR DATASET DO ESTUDO (JSON)',
                  style: GoogleFonts.orbitron(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, double> data,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.isEmpty)
            Text(
              'Nenhum dado registrado nesta categoria ainda.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
            )
          else
            ...data.entries.map((entry) {
              final percent = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: AppTheme.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
