import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/test_input.dart';
import 'package:frontend/views/widgets/test_mc.dart';
import 'package:frontend/views/widgets/test_true_false.dart';

class ContentSection extends ConsumerWidget {
  final Color accent;
  final Color cardColor;
  final Color greetingColor;
  final Color fadedText;
  final String? activeSubject;
  final String? selectedTopic;
  final List<String> aufgabenbereiche;
  final bool showTasks;
  final bool testLocked;
  final List<dynamic> results;

  const ContentSection({
    super.key,
    required this.accent,
    required this.cardColor,
    required this.greetingColor,
    required this.fadedText,
    required this.activeSubject,
    required this.selectedTopic,
    required this.aufgabenbereiche,
    required this.showTasks,
    required this.testLocked,
    required this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(26)),
        boxShadow: [BoxShadow(color: accent.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header-Zeile mit Motivationsspruch und Reset-Button
          _buildHeaderRow(state.greeting, vm.refreshGreeting, vm.resetAll),

          const SizedBox(height: 24),

          // Aufforderungstext
          Text("Wähle bitte dein Unterrichtsfach aus.", style: TextStyle(fontSize: 18, color: fadedText)),

          // Aufgabenbereiche-Übersicht
          if (activeSubject != null && !showTasks) _buildTopicsSection(vm),

          // Test-Bereich
          if (showTasks && activeSubject != null) _buildTestSection(state, vm),

          // Button zum Generieren von Aufgaben
          if (!showTasks && activeSubject != null && selectedTopic != null) _buildGenerateTaskButton(state, vm),

          // Ergebnisbereich
          if (activeSubject != null && results.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: SizedBox(), // Platzhalter für Ergebnisse
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(String greeting, Function refreshGreeting, Function resetAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text mit Flexible für natürliche Größe und Animation
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accent.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.lightbulb_outline, color: greetingColor, size: 24),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motivationsspruch:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: greetingColor.withAlpha(179)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greeting,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: greetingColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: greetingColor.withAlpha(179), size: 20),
                onPressed: () => refreshGreeting(),
                tooltip: 'Neuen Spruch anzeigen',
                splashRadius: 20,
              ),
            ],
          ),
        ),

        // Button am rechten Rand
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Zurücksetzen"),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () => resetAll(),
        ),
      ],
    );
  }

  Widget _buildTopicsSection(HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Aufgabenbereiche für $activeSubject:',
          style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              aufgabenbereiche
                  .map(
                    (bereich) => Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(homeViewModelProvider);

                        return ChoiceChip(
                          label: Text(bereich),
                          selected: state.selectedTopic == bereich,
                          selectedColor: accent,
                          backgroundColor: cardColor,
                          labelStyle: TextStyle(
                            color: state.selectedTopic == bereich ? Colors.white : fadedText,
                            fontWeight: state.selectedTopic == bereich ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            vm.selectTopic(bereich);
                            vm.hideTasks();
                          },
                        );
                      },
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildTestSection(HomeState state, HomeViewModel vm) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 600),
      child: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            if (state.isLoadingTasks) {
              return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            }
            if (state.taskError != null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.taskError!, style: const TextStyle(color: Colors.red)),
              );
            }
            if (state.generatedTasks != null && state.generatedTasks!.isNotEmpty) {
              final questions = state.generatedTasks!.map((task) => task["question"] ?? "").toList();
              if (state.testMode == "bool") {
                return TestTrueFalse(
                  tasks: questions,
                  accent: accent,
                  cardColor: cardColor,
                  onTestFinished: () => vm.onTestFinished(),
                );
              } else if (state.testMode == "input") {
                return TestInput(
                  tasks: questions,
                  accent: accent,
                  cardColor: cardColor,
                  onTestFinished: () => vm.onTestFinished(),
                );
              } else if (state.testMode == "mc") {
                return TestMC(
                  tasks: questions,
                  accent: accent,
                  cardColor: cardColor,
                  onTestFinished: () => vm.onTestFinished(),
                );
              }
            }
            return const Text("Keine Aufgaben gefunden.");
          },
        ),
      ),
    );
  }

  Widget _buildGenerateTaskButton(HomeState state, HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Aufgabe generieren"),
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
            onPressed:
                state.isLoadingTasks || testLocked
                    ? null
                    : () async {
                      const int count = 3;
                      debugPrint('Generiere $count Fragen vom Typ: ${state.testMode}');

                      await vm.generateTasksWithKI(
                        subject: activeSubject!,
                        topic: selectedTopic!,
                        level: state.user.selectedLevel,
                        count: count,
                        testMode: state.testMode,
                      );
                    },
          ),
          if (state.isLoadingTasks)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (state.taskError != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  state.taskError!,
                  style: const TextStyle(color: Colors.red),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
