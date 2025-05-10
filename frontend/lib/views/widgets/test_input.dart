import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';

class TestInput extends ConsumerWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;
  final VoidCallback onTestFinished;

  const TestInput({
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
    final List<String> answers = homeState.textInputAnswers;

    // Prüfen, ob alle Antworten ausgefüllt wurden (für Button-Anzeige)
    final bool allAnswered = homeViewModel.allTestAnswersFilled();

    // Farben für das verbesserte Layout
    final correctColor = Colors.green.shade400;
    final wrongColor = Colors.redAccent;
    final neutralColor = accent.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header mit Fortschrittsanzeige
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitte beantworte die Fragen:',
                style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 22, letterSpacing: 0.5),
              ),
              if (!showResult)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.playlist_add_check_rounded, size: 16, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        '${answers.where((a) => a.isNotEmpty).length}/${tasks.length}',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Beschreibungstext
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Beantworte die folgenden Fragen mit eigenen Worten.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),

        // Fragen und Eingabefelder - kompakter und stilvoller
        ...List.generate(tasks.length, (i) {
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
          } else if (answers.length > i && answers[i].isNotEmpty) {
            borderColor = accent.withValues(alpha: 0.4);
            statusIcon = Icons.edit;
            iconColor = accent;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16), // Reduzierter Abstand
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frage und Icon - kompakter
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(statusIcon, color: iconColor, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          tasks[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Eingabefeld mit optimiertem Layout
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: answers.length > i ? answers[i] : ''),
                      onChanged: (value) => homeViewModel.setTestAnswer(i, value),
                      enabled: !showResult,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      minLines: 1, // Reduziert
                      maxLines: 3, // Reduziert
                      decoration: InputDecoration(
                        labelText: 'Deine Antwort',
                        labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w400, fontSize: 14),
                        hintText: 'Hier deine Antwort eingeben...',
                        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon:
                            showResult && isCorrect.length > i
                                ? Icon(
                                  isCorrect[i] ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect[i] ? correctColor : wrongColor,
                                  size: 22,
                                )
                                : null,
                      ),
                    ),
                  ),
                ),

                // Feedback mit eleganterem Layout
                if (showResult && feedback.length > i)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
                    decoration: BoxDecoration(
                      color:
                          (isCorrect.length > i && isCorrect[i])
                              ? correctColor.withValues(alpha: 0.1)
                              : wrongColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            (isCorrect.length > i && isCorrect[i])
                                ? correctColor.withValues(alpha: 0.3)
                                : wrongColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      feedback[i],
                      style: TextStyle(
                        color: (isCorrect.length > i && isCorrect[i]) ? correctColor : wrongColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),

        // Lade-Anzeige - kompakter
        if (isChecking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(accent)),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Antworten werden überprüft...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
          ),

        // Ergebnisanzeige - kompakter und eleganter
        if (showResult)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isCorrect.every((v) => v) ? correctColor.withValues(alpha: 0.1) : accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isCorrect.every((v) => v)
                                ? correctColor.withValues(alpha: 0.2)
                                : accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect.every((v) => v) ? Icons.emoji_events_rounded : Icons.fitness_center_rounded,
                        size: 24,
                        color: isCorrect.every((v) => v) ? correctColor : accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect.every((v) => v) ? "Toll gemacht!" : "Guter Versuch!",
                            style: TextStyle(
                              color: isCorrect.every((v) => v) ? correctColor : accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isCorrect.every((v) => v)
                                ? "Du hast alle Fragen richtig beantwortet!"
                                : "Du hast ${isCorrect.where((v) => v).length} von ${isCorrect.length} Fragen richtig beantwortet.",
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (canContinue)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.exit_to_app, size: 18),
                          label: const Text("Beenden"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            side: BorderSide(color: accent.withValues(alpha: 0.6)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            homeViewModel.finishTest(onTestFinished);
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text("Weiter"),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

        // "Ergebnisse anzeigen" Button - kompakter und stilvoll
        if (!showResult && !isChecking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              label: Text(allAnswered ? "Antworten überprüfen" : "Bitte alle Fragen beantworten"),
              style: FilledButton.styleFrom(
                backgroundColor: allAnswered ? accent : Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: allAnswered ? () => homeViewModel.checkTestAnswers() : null,
            ),
          ),
      ],
    );
  }
}
