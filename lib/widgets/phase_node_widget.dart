import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/phase_node.dart';
import '../theme/app_theme.dart';

class PhaseNodeWidget extends StatelessWidget {
  final PhaseNode node;
  final VoidCallback onTap;

  const PhaseNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color nodeColor;
    Color glowColor;
    IconData iconData;

    if (node.isCompleted) {
      nodeColor = AppTheme.neonGreen;
      glowColor = AppTheme.neonGreen.withValues(alpha: 0.5);
      iconData = Icons.check;
    } else if (node.isCurrent) {
      nodeColor = AppTheme.neonCyan;
      glowColor = AppTheme.neonCyan.withValues(alpha: 0.6);
      iconData = node.isBoss ? Icons.workspace_premium : Icons.play_arrow_rounded;
    } else {
      nodeColor = AppTheme.surfaceElevated;
      glowColor = Colors.transparent;
      iconData = Icons.lock_outline_rounded;
    }

    final double nodeSize = node.isBoss ? 76.0 : 66.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: node.isCurrent ? nodeColor : AppTheme.surface,
              border: Border.all(
                color: nodeColor,
                width: node.isCurrent ? 3.5 : 2.5,
              ),
              boxShadow: (node.isCurrent || node.isCompleted)
                  ? [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: node.isBoss ? 20 : 14,
                        spreadRadius: node.isCurrent ? 3 : 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                iconData,
                color: node.isCurrent
                    ? Colors.black
                    : node.isCompleted
                        ? AppTheme.neonGreen
                        : Colors.white38,
                size: node.isBoss ? 36 : 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: node.isCurrent ? nodeColor : Colors.white12,
              ),
            ),
            child: Text(
              node.isBoss ? '👑 CHEFE ${node.id}' : 'FASE ${node.id}',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: node.isLocked ? Colors.white38 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
