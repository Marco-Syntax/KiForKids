import 'package:flutter/material.dart';

class FachSidebar extends StatelessWidget {
  final List<String> subjects;
  final List<String> selectedSubjects;
  final String? activeSubject;
  final Color accent;
  final Color fadedText;
  final void Function(String) onToggle;

  const FachSidebar({
    required this.subjects,
    required this.selectedSubjects,
    required this.activeSubject,
    required this.accent,
    required this.fadedText,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2337),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fächer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: accent)),
          const SizedBox(height: 16),
          ...subjects.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: activeSubject == s ? accent.withValues(alpha: 0.35) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                leading: Icon(
                  activeSubject == s ? Icons.check_circle : Icons.circle_outlined,
                  color: activeSubject == s ? Colors.amber : fadedText,
                  size: 22,
                ),
                title: Text(
                  s,
                  style: TextStyle(
                    fontSize: 16,
                    color: activeSubject == s ? Colors.amber : Colors.white,
                    fontWeight: activeSubject == s ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () => onToggle(s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
