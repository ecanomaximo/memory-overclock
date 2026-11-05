import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cadence_service.dart';
import '../theme/app_theme.dart';

class ActivityCadenceBar extends StatefulWidget {
  final CadenceService cadenceService;
  final VoidCallback? onCadenceExhaustedTap;

  const ActivityCadenceBar({
    super.key,
    required this.cadenceService,
    this.onCadenceExhaustedTap,
  });

  @override
  State<ActivityCadenceBar> createState() => _ActivityCadenceBarState();
}

class _ActivityCadenceBarState extends State<ActivityCadenceBar> {
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          widget.cadenceService.checkCycleRefresh();
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cadenceService,
      builder: (context, _) {
        final available = widget.cadenceService.availableActivities;
        final maxSlots = widget.cadenceService.maxActivities;
        final isVip = widget.cadenceService.isVip;
        final timeString = widget.cadenceService.formatTimeRemaining();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: Row(
            children: [
              // Ícone e Slots
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppTheme.focusCyan, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isVip ? 'ATIVIDADES (VIP)' : 'ATIVIDADES DO CICLO',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isVip)
                    Text(
                      'Ilimitadas',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.rewardGreen,
                      ),
                    )
                  else
                    Row(
                      children: List.generate(maxSlots, (index) {
                        final isAvailable = index < available;
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 20,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isAvailable ? AppTheme.focusCyan : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isAvailable
                                ? [
                                    BoxShadow(
                                      color: AppTheme.focusCyan.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                ],
              ),
              const Spacer(),
              // Timer regressivo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: available == 0 ? AppTheme.alertPink.withValues(alpha: 0.5) : AppTheme.surfaceBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: available == 0 ? AppTheme.alertPink : AppTheme.habitAmber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeString,
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: available == 0 ? AppTheme.alertPink : AppTheme.textPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
