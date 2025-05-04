import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/util/ki_service.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'widgets/test_true_false.dart';
import 'widgets/test_input.dart';
import 'widgets/test_mc.dart';

part 'widgets/ergebnis_dialog.dart';
part 'widgets/fach_sidebar.dart';

/// HomeView: Strukturierte Lernplattform-UI.
/// Header mit Titel, Untertitel, Klassen- und Levelwahl.
/// Sidebar mit Fächern, Content-Bereich mit Aufgaben.

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String greeting = "Hallo Schüler!";

  // Testmodus: "bool" = Richtig/Falsch, "input" = Eingabe, "mc" = Multiple Choice
  String _testMode = "bool";
  bool _testLocked = false; // NEU: Buttons sperren, solange Test läuft

  @override
  void initState() {
    super.initState();
    // Setze den KIService im ViewModel, falls noch nicht gesetzt
    final vm = ref.read(homeViewModelProvider.notifier);
    vm.setKIService(KIService());
    // Begrüßungstext laden
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    final vm = ref.read(homeViewModelProvider.notifier);
    final newGreeting = await vm.getGreetingText();
    setState(() {
      greeting = newGreeting;
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.black;
    const cardColor = Color(0xFF16203A);
    const accent = Color(0xFF2196F3);
    const fadedText = Color(0xFF90A4AE);
    const greetingColor = Color(0xFF42A5F5);

    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    // Zugriff auf Listen über das ViewModel
    final subjects = HomeViewModel.subjects;
    final classes = HomeViewModel.classes;
    final levels = HomeViewModel.levels;

    // Hilfsvariablen
    final selectedSubjects = state.user.selectedSubjects;
    final activeSubject = state.activeSubject ?? (selectedSubjects.isNotEmpty ? selectedSubjects.first : null);
    final aufgabenbereiche =
        activeSubject != null ? vm.getAufgabenbereiche(activeSubject, state.user.selectedClass) : <String>[];
    final selectedTopic = state.selectedTopic;
    final showTasks = state.showTasks == true;
    final results = activeSubject != null ? vm.getResultsForSubject(activeSubject) : [];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              children: [
                // Header-Bereich (zentriert, Ergebnis-Button oben rechts)
                Stack(
                  children: [
                    // Zentrierter Header-Inhalt
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "KI---For---Kids",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: accent,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Finde spannende Aufgaben für jede Klassenstufe",
                            style: TextStyle(color: fadedText, fontSize: 18, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Klassen-Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: accent.withOpacity(0.15)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.user.selectedClass,
                                    items:
                                        classes
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(
                                                  c,
                                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      if (value != null) vm.selectClass(value);
                                    },
                                    dropdownColor: cardColor,
                                    iconEnabledColor: accent,
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              // Level-Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: accent.withOpacity(0.15)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.user.selectedLevel,
                                    items:
                                        levels
                                            .map(
                                              (l) => DropdownMenuItem(
                                                value: l,
                                                child: Text(
                                                  l,
                                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      if (value != null) vm.selectLevel(value);
                                    },
                                    dropdownColor: cardColor,
                                    iconEnabledColor: accent,
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Testmodus-Auswahl-Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    _testLocked
                                        ? null
                                        : () {
                                          setState(() {
                                            _testMode = "bool";
                                          });
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _testMode == "bool" ? accent : cardColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text("Richtig/Falsch"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed:
                                    _testLocked
                                        ? null
                                        : () {
                                          setState(() {
                                            _testMode = "input";
                                          });
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _testMode == "input" ? accent : cardColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text("Eingabe-Test"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed:
                                    _testLocked
                                        ? null
                                        : () {
                                          setState(() {
                                            _testMode = "mc";
                                          });
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _testMode == "mc" ? accent : cardColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text("Multiple Choice"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Ergebnis-Button oben rechts
                    Positioned(
                      right: 0,
                      top: 0,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text("Ergebnisse"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (activeSubject == null) return;
                          try {
                            final data = await vm.getResultsFromBackend(activeSubject);
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => ErgebnisDialog(
                                    activeSubject: activeSubject,
                                    accent: accent,
                                    fadedText: fadedText,
                                    data: data,
                                  ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text("Fehler"),
                                    content: Text("Fehler beim Laden der Ergebnisse: $e"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK")),
                                    ],
                                  ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Hauptbereich: Sidebar + Content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar
                    FachSidebar(
                      subjects: subjects,
                      selectedSubjects: selectedSubjects,
                      activeSubject: state.activeSubject,
                      accent: accent,
                      fadedText: fadedText,
                      onToggle: vm.toggleSubject,
                    ),
                    const SizedBox(width: 32),
                    // Content-Bereich
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: accent.withOpacity(0.07)),
                          boxShadow: [
                            BoxShadow(color: accent.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    greeting,
                                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: greetingColor),
                                  ),
                                ),
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
                                  onPressed: () {
                                    ref.read(homeViewModelProvider.notifier).resetAll();
                                    setState(() {
                                      _testLocked = false; // Testmodus-Buttons wieder aktivieren
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Wähle bitte dein Unterrichtsfach aus.",
                              style: TextStyle(fontSize: 18, color: fadedText),
                            ),
                            // Aufgabenbereiche-Übersicht (nur wenn Fach gewählt)
                            if (activeSubject != null && !showTasks)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aufgabenbereiche für $activeSubject (${state.user.selectedClass}):',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 18),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children:
                                        aufgabenbereiche
                                            .map(
                                              (bereich) => ChoiceChip(
                                                label: Text(bereich),
                                                selected: selectedTopic == bereich,
                                                selectedColor: accent,
                                                backgroundColor: cardColor,
                                                labelStyle: TextStyle(
                                                  color: selectedTopic == bereich ? Colors.white : fadedText,
                                                  fontWeight:
                                                      selectedTopic == bereich ? FontWeight.bold : FontWeight.normal,
                                                ),
                                                onSelected: (_) {
                                                  vm.selectTopic(bereich);
                                                  vm.hideTasks();
                                                },
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            // Aufgabenanzeige
                            if (showTasks && activeSubject != null)
                              Builder(
                                builder: (context) {
                                  if (state.isLoadingTasks) {
                                    return const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  if (state.taskError != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(state.taskError!, style: const TextStyle(color: Colors.red)),
                                    );
                                  }
                                  if (state.generatedTasks != null && state.generatedTasks!.isNotEmpty) {
                                    final questions =
                                        state.generatedTasks!.map((task) => task["question"] ?? "").toList();
                                    if (_testMode == "bool") {
                                      return TestTrueFalse(
                                        tasks: questions,
                                        accent: accent,
                                        cardColor: cardColor,
                                        onTestFinished: _onTestFinished,
                                      );
                                    } else if (_testMode == "input") {
                                      return TestInput(
                                        tasks: questions,
                                        accent: accent,
                                        cardColor: cardColor,
                                        onTestFinished: _onTestFinished,
                                      );
                                    } else if (_testMode == "mc") {
                                      return TestMC(
                                        tasks: questions,
                                        accent: accent,
                                        cardColor: cardColor,
                                        onTestFinished: _onTestFinished,
                                      );
                                    }
                                  }
                                  return const Text("Keine Aufgaben gefunden.");
                                },
                              ),
                            if (!showTasks && activeSubject != null && selectedTopic != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.auto_awesome),
                                      label: const Text("Aufgabe generieren"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed:
                                          state.isLoadingTasks || _testLocked
                                              ? null
                                              : () async {
                                                setState(() {
                                                  _testLocked = true;
                                                });
                                                // Anzahl Aufgaben je nach Testmodus
                                                int count = 1;
                                                if (_testMode == "input" || _testMode == "bool") {
                                                  count = 5;
                                                }
                                                await vm.generateTasksWithKI(
                                                  subject: activeSubject,
                                                  topic: selectedTopic,
                                                  level: state.user.selectedLevel,
                                                  count: count,
                                                  testMode: _testMode,
                                                );
                                              },
                                    ),
                                    if (state.isLoadingTasks)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    if (state.taskError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: Text(state.taskError!, style: const TextStyle(color: Colors.red)),
                                      ),
                                  ],
                                ),
                              ),
                            if (activeSubject != null && results.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ergebnisse werden nach Reset nicht mehr angezeigt
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEU: Callback wenn Test beendet wurde
  void _onTestFinished() {
    setState(() {
      _testLocked = false;
    });
    ref.read(homeViewModelProvider.notifier).hideTasks();
  }
}
