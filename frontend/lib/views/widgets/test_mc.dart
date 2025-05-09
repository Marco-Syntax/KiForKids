import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';

class TestMC extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    // Initialisiere Test beim ersten Build über einen PostFrameCallback,
    // aber nur wenn die Aufgaben noch nicht initialisiert wurden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeState.currentTestTasks.isEmpty || homeState.currentTestTasks.length != tasks.length) {
        homeViewModel.initTest(tasks);
      }
    });

    // State aus dem ViewModel
    final bool showResult = homeState.showTestResult;
    final bool isChecking = homeState.isCheckingTest;
    final bool canContinue = homeState.canContinueTest;
    final List<bool> isCorrect = homeState.testIsCorrect;
    final List<String> feedback = homeState.testFeedback;
    final List<String?> answers = homeState.mcAnswers;

    // Prüfen, ob alle Antworten ausgewählt wurden (für Button-Anzeige)
    final bool hasEnoughAnswers = answers.length >= tasks.length;
    final bool allAnswered = hasEnoughAnswers && answers.take(tasks.length).every((answer) => answer != null);

    // Farben für das verbesserte Layout
    final correctColor = Colors.green.shade400;
    final wrongColor = Colors.redAccent;
    final neutralColor = accent.withValues(alpha: 0.7);

    // Multiple-Choice Optionen generieren (A, B, C, D)
    final mcOptions = ['A', 'B', 'C', 'D'];

    // Direkt die generierten Aufgaben aus dem State verwenden
    final generatedTasks = homeState.generatedTasks ?? [];

    // Multiple-Choice Optionen für jede Frage laden
    List<List<String>> optionTexts = List.generate(tasks.length, (index) {
      if (index < generatedTasks.length) {
        final task = generatedTasks[index];

        // Versuche, die Optionen zu finden
        final List<String> options = [];

        // Option A-D direkt extrahieren
        for (String option in mcOptions) {
          final optionKey = 'option$option';
          if (task.containsKey(optionKey)) {
            options.add(task[optionKey]!);
          } else if (task.containsKey('option_$option')) {
            options.add(task['option_$option']!);
          } else if (task.containsKey('option_${option.toLowerCase()}')) {
            options.add(task['option_${option.toLowerCase()}']!);
          }
        }

        // Falls wir noch nicht alle Optionen haben, schauen wir nach anderen Formaten
        if (options.isEmpty && task.containsKey('options')) {
          // Versuch, options als komma-separierte Liste zu parsen
          final optionsStr = task['options']!;
          return optionsStr.split(',').map((o) => o.trim()).toList();
        }

        // Falls wir Optionen gefunden haben, geben wir sie zurück
        if (options.isNotEmpty) {
          return options;
        }
      }

      // Fallback: Generiere Dummy-Optionen
      return mcOptions.map((o) => 'Option $o').toList();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Multiple-Choice Test',
              style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 24, letterSpacing: 0.5),
            ),
            if (!showResult)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '${answers.where((a) => a != null).length}/${tasks.length} beantwortet',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Wähle die richtige Antwort für jede Frage.', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 24),
        ...List.generate(tasks.length, (i) {
          // Stelle sicher, dass wir gültige Indizes für answers haben
          final bool hasAnswer = answers.length > i && answers[i] != null;

          // Status-abhängige Farben und Icons
          Color borderColor = accent.withValues(alpha: 0.18);
          Color bgColor = cardColor.withValues(alpha: 0.95);
          IconData statusIcon = Icons.help_outline;
          Color iconColor = neutralColor;

          if (showResult && isCorrect.length > i) {
            if (isCorrect[i]) {
              borderColor = correctColor.withValues(alpha: 0.5);
              bgColor = correctColor.withValues(alpha: 0.05);
              statusIcon = Icons.check_circle_outline;
              iconColor = correctColor;
            } else {
              borderColor = wrongColor.withValues(alpha: 0.5);
              bgColor = wrongColor.withValues(alpha: 0.05);
              statusIcon = Icons.cancel_outlined;
              iconColor = wrongColor;
            }
          } else if (hasAnswer) {
            borderColor = accent.withValues(alpha: 0.4);
            statusIcon = Icons.check_box;
            iconColor = accent;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frage und Icon in der oberen Zeile
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(statusIcon, color: iconColor, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tasks[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // Feedback-Icon nur bei Ergebnisanzeige
                      if (showResult && isCorrect.length > i)
                        Icon(
                          isCorrect[i] ? Icons.check_circle : Icons.cancel,
                          color: isCorrect[i] ? correctColor : wrongColor,
                          size: 26,
                        ),
                    ],
                  ),
                ),

                // Multiple-Choice Optionen
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    children: List.generate(mcOptions.length, (optionIndex) {
                      final option = mcOptions[optionIndex];

                      // Hole den Optionstext für diese Option - sicher gegen Out-of-Bounds
                      final String optionText =
                          i < optionTexts.length && optionIndex < optionTexts[i].length
                              ? optionTexts[i][optionIndex]
                              : "Option $option";

                      final bool isSelected = hasAnswer && answers[i] == option;
                      final bool isCorrectAnswer =
                          showResult && feedback.length > i && feedback[i].toLowerCase().contains('richtig: $option');

                      Color optionColor = cardColor.withValues(alpha: 0.7);
                      Color textColor = Colors.white;
                      Color borderColor = accent.withValues(alpha: 0.15);
                      IconData optionIcon = Icons.circle_outlined;

                      if (showResult) {
                        if (isCorrectAnswer) {
                          optionColor = correctColor.withValues(alpha: 0.15);
                          borderColor = correctColor.withValues(alpha: 0.5);
                          optionIcon = Icons.check_circle;
                        } else if (isSelected && !isCorrectAnswer) {
                          optionColor = wrongColor.withValues(alpha: 0.15);
                          borderColor = wrongColor.withValues(alpha: 0.5);
                          optionIcon = Icons.cancel;
                        }
                      } else if (isSelected) {
                        optionColor = accent.withValues(alpha: 0.2);
                        borderColor = accent.withValues(alpha: 0.5);
                        optionIcon = Icons.check_circle_outline;
                      }

                      return GestureDetector(
                        onTap: showResult ? null : () => homeViewModel.setMCAnswer(i, option),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: optionColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? accent.withValues(alpha: 0.2) : Colors.transparent,
                                ),
                                child: Center(
                                  child: Icon(
                                    optionIcon,
                                    color:
                                        showResult
                                            ? (isCorrectAnswer
                                                ? correctColor
                                                : (isSelected ? wrongColor : Colors.white54))
                                            : (isSelected ? accent : Colors.white54),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    // Zeige Option (A, B, C, D) mit besserem Styling
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Zeige den eigentlichen Antworttext
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight:
                                              isSelected || isCorrectAnswer ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Feedback-Text unter dem Container
                if (showResult && feedback.length > i)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    margin: const EdgeInsets.only(bottom: 18, left: 18, right: 18),
                    decoration: BoxDecoration(
                      color:
                          (isCorrect.length > i && isCorrect[i])
                              ? correctColor.withValues(alpha: 0.1)
                              : wrongColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            (isCorrect.length > i && isCorrect[i])
                                ? correctColor.withValues(alpha: 0.3)
                                : wrongColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      feedback[i],
                      style: TextStyle(
                        color: (isCorrect.length > i && isCorrect[i]) ? correctColor : wrongColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        // Lade-Anzeige während der Prüfung
        if (isChecking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(accent)),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Antworten werden überprüft...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
          ),

        // Ergebnisanzeige am Ende des Tests
        if (showResult)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isCorrect.every((v) => v) ? correctColor.withValues(alpha: 0.1) : accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect.every((v) => v) ? correctColor.withValues(alpha: 0.3) : accent.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isCorrect.every((v) => v)
                                ? correctColor.withValues(alpha: 0.2)
                                : accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect.every((v) => v) ? Icons.emoji_events_rounded : Icons.fitness_center_rounded,
                        size: 28,
                        color: isCorrect.every((v) => v) ? correctColor : accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect.every((v) => v) ? "Toll gemacht!" : "Guter Versuch!",
                            style: TextStyle(
                              color: isCorrect.every((v) => v) ? correctColor : accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCorrect.every((v) => v)
                                ? "Du hast alle Fragen richtig beantwortet!"
                                : "Du hast ${isCorrect.where((v) => v).length} von ${isCorrect.length} Fragen richtig beantwortet.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (canContinue)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text("Beenden"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            side: BorderSide(color: accent.withValues(alpha: 0.6)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            homeViewModel.finishTest(onTestFinished);
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text("Weiter"),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => homeViewModel.continueTest(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        // "Ergebnisse anzeigen" Button - Nur anzeigen wenn Antworten da UND nicht in anderen Zuständen
        if (!showResult && !isChecking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20),
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(allAnswered ? "Antworten überprüfen" : "Bitte alle Fragen beantworten"),
              style: FilledButton.styleFrom(
                backgroundColor: allAnswered ? accent : Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: allAnswered ? () => homeViewModel.checkTestAnswers() : null,
            ),
          ),
      ],
    );
  }
}
