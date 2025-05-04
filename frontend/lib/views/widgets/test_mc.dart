/// Platzhalter-Widget für Multiple-Choice-Aufgaben.
/// Zeigt Aufgaben als Textliste an.

import 'package:flutter/material.dart';

class TestMC extends StatelessWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;
  final VoidCallback onTestFinished;

  const TestMC({
    super.key,
    required this.tasks,
    required this.accent,
    required this.cardColor,
    required this.onTestFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Multiple Choice Test (in Entwicklung)", style: TextStyle(color: accent, fontSize: 20)),
        ...tasks.map(
          (t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(t, style: const TextStyle(color: Colors.white)),
          ),
        ),
        ElevatedButton(onPressed: onTestFinished, child: const Text("Test beenden")),
      ],
    );
  }
}

// Hinweis: Für Multiple Choice muss bei der Auswertung analog zu den anderen Widgets
// die Lösung aus generatedTasks verwendet werden, sobald Antwortauswahl und Auswertung implementiert werden.
