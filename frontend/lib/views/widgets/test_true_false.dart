import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/answer_button.dart';

class TestTrueFalse extends ConsumerWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;
  final VoidCallback onTestFinished;

  const TestTrueFalse({
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
    final List<String?> answers = homeState.trueFalseAnswers;

    // Prüfen, ob alle Antworten ausgewählt wurden (für Button-Anzeige)
    final bool hasEnoughAnswers = answers.length >= tasks.length;
    final bool allAnswered = hasEnoughAnswers && answers.take(tasks.length).every((answer) => answer != null);

    // Farben für das verbesserte Layout
    final correctColor = Colors.green.shade400;
    final wrongColor = Colors.redAccent;
    final neutralColor = accent.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Richtig oder Falsch?',
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
        Text(
          'Entscheide, ob die folgenden Aussagen richtig oder falsch sind.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
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
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: 0.2,
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
                // Buttons in unterer Leiste mit farblicher Hervorhebung
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.7),
                      border: Border(top: BorderSide(color: accent.withValues(alpha: 0.15), width: 1)),
                    ),
                    child: Row(
                      children: [
                        // RICHTIG-Button
                        Expanded(
                          child: AnswerButton(
                            label: "RICHTIG",
                            icon: Icons.check_rounded,
                            isSelected: hasAnswer && answers[i] == "richtig",
                            isCorrect:
                                showResult &&
                                isCorrect.length > i &&
                                ((answers[i] == "richtig" && isCorrect[i]) ||
                                    (answers[i] != "richtig" && !isCorrect[i] && feedback[i].contains("richtig"))),
                            accent: accent,
                            correctColor: correctColor,
                            wrongColor: wrongColor,
                            showResult: showResult,
                            onPressed: showResult ? null : () => homeViewModel.setTrueFalseAnswer(i, "richtig"),
                          ),
                        ),
                        // Trennlinie
                        Container(width: 1, color: accent.withValues(alpha: 0.2), height: double.infinity),
                        // FALSCH-Button
                        Expanded(
                          child: AnswerButton(
                            label: "FALSCH",
                            icon: Icons.close_rounded,
                            isSelected: hasAnswer && answers[i] == "falsch",
                            isCorrect:
                                showResult &&
                                isCorrect.length > i &&
                                ((answers[i] == "falsch" && isCorrect[i]) ||
                                    (answers[i] != "falsch" && !isCorrect[i] && feedback[i].contains("falsch"))),
                            accent: accent,
                            correctColor: correctColor,
                            wrongColor: wrongColor,
                            showResult: showResult,
                            onPressed: showResult ? null : () => homeViewModel.setTrueFalseAnswer(i, "falsch"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Feedback-Text unter dem Container
                if (showResult && feedback.length > i)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    margin: const EdgeInsets.only(top: 8),
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
                            isCorrect.every((v) => v) ? "Toll gemacht!" : "Guter versuch!",
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
