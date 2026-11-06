import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/onboarding_survey.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class OnboardingSurveyScreen extends StatefulWidget {
  final ProgressService progressService;
  final VoidCallback onFinished;

  const OnboardingSurveyScreen({
    super.key,
    required this.progressService,
    required this.onFinished,
  });

  @override
  State<OnboardingSurveyScreen> createState() => _OnboardingSurveyScreenState();
}

class _OnboardingSurveyScreenState extends State<OnboardingSurveyScreen> {
  int _currentStep = 0;
  static const int _totalQuestionSteps = 4;

  String? _selectedGoal;
  String? _selectedSymptom;
  String? _selectedStress;
  int _selectedMinutes = 10;

  bool _isCalibrating = false;

  void _nextStep() {
    if (_currentStep < _totalQuestionSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Avança para tela final de diagnóstico
      setState(() {
        _isCalibrating = true;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0 && !_isCalibrating) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _finishSurvey() {
    final surveyData = OnboardingSurveyData(
      primaryGoal: _selectedGoal ?? 'anxiety_relief',
      dominantSymptom: _selectedSymptom ?? 'racing_thoughts',
      stressFrequency: _selectedStress ?? 'daily',
      dailyCommitmentMinutes: _selectedMinutes,
      completedAt: DateTime.now(),
    );

    widget.progressService.completeOnboarding(surveyData);
    widget.onFinished();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedGoal != null;
      case 1:
        return _selectedSymptom != null;
      case 2:
        return _selectedStress != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCalibrating) {
      return _buildDiagnosticResultView();
    }

    final double progressPercent = (_currentStep + 1) / _totalQuestionSteps;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: AppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              leading: _currentStep > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                      onPressed: _prevStep,
                    )
                  : null,
              title: Text(
                'ANAMNESE NEURAL',
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Center(
                    child: Text(
                      '${_currentStep + 1} de $_totalQuestionSteps',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.focusCyan,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Column(
                children: [
                  // Barra de Progresso do Questionário
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.focusCyan),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Conteúdo da Etapa
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildCurrentQuestionContent(),
                    ),
                  ),

                  // Botão Inferior de Próximo
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed ? AppTheme.focusCyan : AppTheme.surfaceElevated,
                        foregroundColor: _canProceed ? AppTheme.background : AppTheme.textMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _canProceed ? 4 : 0,
                      ),
                      onPressed: _canProceed ? _nextStep : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == _totalQuestionSteps - 1
                                ? 'GERAR MEU DIAGNÓSTICO'
                                : 'CONTINUAR',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentQuestionContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Goal();
      case 1:
        return _buildStep2Symptoms();
      case 2:
        return _buildStep3Stress();
      case 3:
        return _buildStep4Commitment();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Goal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que te motivou a baixar o Memory Overclock?',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalizaremos seus treinos cerebrais de acordo com o que você mais precisa desenvolver.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSelectableCard(
          id: 'anxiety_relief',
          currentSelected: _selectedGoal,
          icon: Icons.spa_rounded,
          title: 'Aliviar Ansiedade & Sobrecarga',
          subtitle: 'Desacelerar mente agitada, evitar Burnout e clarear pensamentos.',
          onTap: () => setState(() => _selectedGoal = 'anxiety_relief'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'focus_productivity',
          currentSelected: _selectedGoal,
          icon: Icons.bolt_rounded,
          title: 'Aumentar Foco & Produtividade',
          subtitle: 'Reter atenção por mais tempo sem procrastinar ou abrir abas.',
          onTap: () => setState(() => _selectedGoal = 'focus_productivity'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'memory_improvement',
          currentSelected: _selectedGoal,
          icon: Icons.psychology_rounded,
          title: 'Melhorar Memória & Evitar Falhas',
          subtitle: 'Lembrar de nomes, conversas e tarefas do dia a dia com facilidade.',
          onTap: () => setState(() => _selectedGoal = 'memory_improvement'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'prevent_decline',
          currentSelected: _selectedGoal,
          icon: Icons.shield_rounded,
          title: 'Vencer o Brain Rot & Proteger a Mente',
          subtitle: 'Blindar o cérebro contra o esgotamento causado por telas e dopamina rápida.',
          onTap: () => setState(() => _selectedGoal = 'prevent_decline'),
        ),
      ],
    );
  }

  Widget _buildStep2Symptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que você tem sentido com mais intensidade?',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Identificar seus gargalos cognitivos atuais ajuda a dosar a dificuldade dos desafios.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSelectableCard(
          id: 'racing_thoughts',
          currentSelected: _selectedSymptom,
          icon: Icons.cyclone_rounded,
          title: 'Pensamentos Acelerados',
          subtitle: 'Dificuldade para relaxar à noite ou mente sempre pensando em tudo ao mesmo tempo.',
          onTap: () => setState(() => _selectedSymptom = 'racing_thoughts'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'digital_distraction',
          currentSelected: _selectedSymptom,
          icon: Icons.phone_android_rounded,
          title: 'Distração Crônica com Celular',
          subtitle: 'Troca constante de estímulos e perda de atenção em tarefas que exigem esforço.',
          onTap: () => setState(() => _selectedSymptom = 'digital_distraction'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'brain_fog',
          currentSelected: _selectedSymptom,
          icon: Icons.cloud_queue_rounded,
          title: 'Névoa Mental (Brain Fog)',
          subtitle: 'Sensação de cansaço mental, lentidão para pensar ou esgotamento na metade do dia.',
          onTap: () => setState(() => _selectedSymptom = 'brain_fog'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'forgetfulness',
          currentSelected: _selectedSymptom,
          icon: Icons.help_outline_rounded,
          title: 'Esquecimentos no Cotidiano',
          subtitle: 'Entrar num cômodo e esquecer o que ia fazer, ou perder objetos rotineiramente.',
          onTap: () => setState(() => _selectedSymptom = 'forgetfulness'),
        ),
      ],
    );
  }

  Widget _buildStep3Stress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Com que frequência o estresse ou ansiedade afeta seu dia?',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Neurocientistas comprovam que o cortisol elevado reduz temporariamente a memória de trabalho.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSelectableCard(
          id: 'constant',
          currentSelected: _selectedStress,
          icon: Icons.sentiment_very_dissatisfied_rounded,
          title: 'O tempo todo / Sobrecarga alta',
          subtitle: 'Sensação de estar no limite físico ou mental quase diariamente.',
          onTap: () => setState(() => _selectedStress = 'constant'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'daily',
          currentSelected: _selectedStress,
          icon: Icons.sentiment_dissatisfied_rounded,
          title: 'Quase todos os dias',
          subtitle: 'Picos de ansiedade recorrentes durante jornadas de trabalho ou estudo.',
          onTap: () => setState(() => _selectedStress = 'daily'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'sometimes',
          currentSelected: _selectedStress,
          icon: Icons.sentiment_neutral_rounded,
          title: 'Às vezes (1 a 2 vezes por semana)',
          subtitle: 'Acontece em momentos pontuais de prazos ou imprevistos.',
          onTap: () => setState(() => _selectedStress = 'sometimes'),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: 'rarely',
          currentSelected: _selectedStress,
          icon: Icons.sentiment_satisfied_alt_rounded,
          title: 'Raramente',
          subtitle: 'Meu equilíbrio emocional está estável, busco apenas alta performance cognitiva.',
          onTap: () => setState(() => _selectedStress = 'rarely'),
        ),
      ],
    );
  }

  Widget _buildStep4Commitment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quanto tempo por dia você pretende treinar?',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A consistência diária é até 4x mais eficaz que treinos longos e esporádicos.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        _buildSelectableCard(
          id: '5',
          currentSelected: '$_selectedMinutes',
          icon: Icons.timer_outlined,
          title: '5 Minutos / Dia (Micro-doses)',
          subtitle: '1 sessão de 3 desafios para despertar e resetar o foco rapidamente.',
          onTap: () => setState(() => _selectedMinutes = 5),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: '10',
          currentSelected: '$_selectedMinutes',
          icon: Icons.stars_rounded,
          title: '10 Minutos / Dia (Ritmo Recomendado 🔥)',
          subtitle: '2 sessões espaçadas para consolidar a plasticidade neural e reter XP.',
          onTap: () => setState(() => _selectedMinutes = 10),
        ),
        const SizedBox(height: 12),
        _buildSelectableCard(
          id: '15',
          currentSelected: '$_selectedMinutes',
          icon: Icons.military_tech_rounded,
          title: '15+ Minutos / Dia (Modo Overclock VIP)',
          subtitle: 'Imersão profunda para competir no topo das ligas semanais.',
          onTap: () => setState(() => _selectedMinutes = 15),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String id,
    required String? currentSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentSelected == id;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceElevated : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.focusCyan : AppTheme.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.focusCyan.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.focusCyan.withValues(alpha: 0.2)
                    : AppTheme.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.focusCyan : AppTheme.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppTheme.focusCyan : AppTheme.surfaceBorder,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticResultView() {
    final tempSurvey = OnboardingSurveyData(
      primaryGoal: _selectedGoal ?? 'anxiety_relief',
      dominantSymptom: _selectedSymptom ?? 'racing_thoughts',
      stressFrequency: _selectedStress ?? 'daily',
      dailyCommitmentMinutes: _selectedMinutes,
      completedAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.focusCyan.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.focusCyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.focusCyan.withValues(alpha: 0.4),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.focusCyan,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'CALIBRAÇÃO CONCLUÍDA',
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mapeamos seus pontos de sobrecarga e criamos um plano sob medida.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 28),

                  // Card de Diagnóstico Gerado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.focusCyan.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_rounded, color: AppTheme.focusCyan, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Seu Perfil Cognitivo:',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tempSurvey.profileTitle,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Divider(height: 24, color: AppTheme.surfaceBorder),
                        Row(
                          children: [
                            const Icon(Icons.track_changes_rounded, color: AppTheme.rewardGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Foco de Treino Neural:',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tempSurvey.recommendedFocusDomain,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.rewardGreen,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.alarm_on_rounded, color: AppTheme.habitAmber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Meta Diária: ${tempSurvey.dailyCommitmentMinutes} minutos de overclock',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.habitAmber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.rewardGreen,
                        foregroundColor: const Color(0xFF0A0F1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _finishSurvey,
                      child: Text(
                        'COMEÇAR MEU OVERCLOCK',
                        style: GoogleFonts.orbitron(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
