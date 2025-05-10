import 'package:flutter/material.dart';

/// Ein wiederverwendbares Button-Widget für Antwortoptionen in Tests.
///
/// Dieses Widget wird für die Darstellung von Antwortmöglichkeiten verwendet
/// und kann verschiedene Zustände visualisieren (ausgewählt, korrekt, falsch).
class AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isCorrect;
  final Color accent;
  final Color correctColor;
  final Color wrongColor;
  final bool showResult;
  final VoidCallback? onPressed;

  const AnswerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isCorrect,
    required this.accent,
    required this.correctColor,
    required this.wrongColor,
    required this.showResult,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Bestimme Farben basierend auf Zustand
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white70;
    Color iconColor = Colors.white70;

    if (showResult) {
      if (isCorrect) {
        bgColor = correctColor.withValues(alpha: 0.15);
        textColor = correctColor;
        iconColor = correctColor;
      } else if (isSelected) {
        bgColor = wrongColor.withValues(alpha: 0.15);
        textColor = wrongColor;
        iconColor = wrongColor;
      }
    } else if (isSelected) {
      bgColor = accent.withValues(alpha: 0.2);
      textColor = Colors.white;
      iconColor = accent;
    }

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onPressed,
        splashColor: accent.withValues(alpha: 0.2),
        highlightColor: accent.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14), // Leicht reduziert von 16 auf 14
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20), // Kleineres Icon (von 22 auf 20)
              const SizedBox(width: 6), // Kleinerer Abstand (von 8 auf 6)
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15, // Kleinere Schrift (von 16 auf 15)
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
