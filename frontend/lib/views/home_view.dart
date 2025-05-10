import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/util/ki_service.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/ergebnis_dialog.dart';
import 'package:frontend/views/widgets/fach_sidebar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/test_true_false.dart';
import 'widgets/test_input.dart';
import 'widgets/test_mc.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  // Hilfsfunktion zum Öffnen von URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Konnte URL nicht öffnen: $urlString');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const background = Colors.black;
    const cardColor = Color(0xFF16203A);
    const accent = Color(0xFF2196F3);
    const fadedText = Color(0xFF90A4AE);
    const greetingColor = Color(0xFF42A5F5);

    // Initialisiere KI-Service, falls noch nicht geschehen
    final vm = ref.read(homeViewModelProvider.notifier);
    if (vm.kiService == null) {
      vm.setKIService(KIService());
      // Begrüßungstext wird automatisch im ViewModel-Konstruktor geladen
    }

    final state = ref.watch(homeViewModelProvider);

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

    // Testmodus und Sperrstatus aus dem State
    final testMode = state.testMode;
    final testLocked = state.testLocked;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        // Logo links-mittig (anpassbare Position)

                        // Zentrierter Header-Inhalt
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/bg_3.png', height: 200, fit: BoxFit.contain),
                              const SizedBox(height: 8),
                              Text(
                                "Finde spannende Aufgaben für jede Klassenstufe",
                                style: TextStyle(color: fadedText, fontSize: 18, fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Klassen-Dropdown
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: accent.withValues(alpha: 0.15)),
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
                                      border: Border.all(color: accent.withValues(alpha: 0.15)),
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
                                    onPressed: testLocked ? null : () => vm.setTestMode("bool"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: testMode == "bool" ? accent : cardColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text("Richtig/Falsch"),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: testLocked ? null : () => vm.setTestMode("input"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: testMode == "input" ? accent : cardColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text("Eingabe-Test"),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: testLocked ? null : () => vm.setTestMode("mc"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: testMode == "mc" ? accent : cardColor,
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
                        // Ergebnis-Button oben rechts mit Proxy-Bild
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Ergebnis-Button
                              ElevatedButton.icon(
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
                                    if (!context.mounted) return;
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
                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: const Text("Fehler"),
                                            content: Text("Fehler beim Laden der Ergebnisse: $e"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
                              ),
                              // Proxy-Bild unter dem Ergebnis-Button, etwas nach links versetzt
                              Transform.translate(
                                offset: const Offset(-100, 0), // 60 Pixel nach links versetzt
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: Image.asset(
                                    'assets/images/proxy.png',
                                    width: 280, // Etwas kleinere Breite
                                    height: 280, // Entsprechend angepasste Höhe
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Hauptbereich: Sidebar + Content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar - keine Expanded-Nutzung, damit die Sidebar ihre natürliche Größe behält
                        FachSidebar(
                          subjects: subjects,
                          selectedSubjects: selectedSubjects,
                          activeSubject: state.activeSubject,
                          accent: accent,
                          fadedText: fadedText,
                          onToggle: (subject) {
                            // Immer alles zurücksetzen beim Fachwechsel UND Testmodus entsperren
                            vm.toggleSubject(subject);
                            vm.setTestLocked(false);
                          },
                        ),
                        const SizedBox(width: 32),
                        // Mittlere Box: Flexible statt Expanded verwenden
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: accent.withValues(alpha: 0.07)),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header-Zeile mit Text links und Button ganz am rechten Rand
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween, // Maximaler Abstand zwischen Elementen
                                  children: [
                                    // Text mit Flexible für natürliche Größe
                                    Flexible(
                                      child: Text(
                                        state.greeting,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: greetingColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                      onPressed: () {
                                        vm.resetAll();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Aufforderungstext - kein Expanded nötig
                                Text(
                                  "Wähle bitte dein Unterrichtsfach aus.",
                                  style: TextStyle(fontSize: 18, color: fadedText),
                                ),

                                // Aufgabenbereiche-Übersicht mit flexiblem Layout ohne Expanded
                                if (activeSubject != null && !showTasks)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Vermeidet unnötige Ausdehnung
                                    children: [
                                      Text(
                                        'Aufgabenbereiche für $activeSubject (${state.user.selectedClass}):',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 18),
                                      ),
                                      const SizedBox(height: 12),
                                      // Wrap ist bereits flexibel, kein Expanded notwendig
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
                                                          selectedTopic == bereich
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
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

                                // Test-Bereich - keine Expanded-Nutzung, sondern in einen anpassungsfähigen Container verpacken
                                if (showTasks && activeSubject != null)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 200, // Mindesthöhe für den Test-Bereich
                                      maxHeight: 600, // Maximalhöhe, kann angepasst werden
                                    ),
                                    child: SingleChildScrollView(
                                      child: Builder(
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
                                            if (testMode == "bool") {
                                              return TestTrueFalse(
                                                tasks: questions,
                                                accent: accent,
                                                cardColor: cardColor,
                                                onTestFinished: () => vm.onTestFinished(),
                                              );
                                            } else if (testMode == "input") {
                                              return TestInput(
                                                tasks: questions,
                                                accent: accent,
                                                cardColor: cardColor,
                                                onTestFinished: () => vm.onTestFinished(),
                                              );
                                            } else if (testMode == "mc") {
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
                                  ),

                                // Button zum Generieren von Aufgaben
                                if (!showTasks && activeSubject != null && selectedTopic != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min, // Nur so breit wie nötig
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.auto_awesome),
                                          label: const Text("Aufgabe generieren"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accent,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed:
                                              state.isLoadingTasks || testLocked
                                                  ? null
                                                  : () async {
                                                    // Anzahl der Fragen auf 3 reduzieren
                                                    const int count = 3;
                                                    debugPrint('Generiere $count Fragen vom Typ: $testMode');

                                                    await vm.generateTasksWithKI(
                                                      subject: activeSubject,
                                                      topic: selectedTopic,
                                                      level: state.user.selectedLevel,
                                                      count: count,
                                                      testMode: testMode,
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
                                          Flexible(
                                            // Hier Flexible für Fehlertext
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
                                  ),

                                // Ergebnisbereich - kein Expanded nötig
                                if (activeSubject != null && results.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 32),
                                    child: SizedBox(), // Platzhalter für Ergebnisse
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // --- Footer ---
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey, thickness: 0.3),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "© 2025 KiForKids - Interaktive Lernplattform für Kinder",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              _launchUrl("https://marcogrimme.de");
                            },
                            child: const Text(
                              "Entwickelt von Marco Grimme – Inspiriert von Jonas Grimme – KI-generierte Aufgaben",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _launchUrl('/datenschutz.html');
                                },
                                child: const Text(
                                  "Datenschutz",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _launchUrl('/agb.html');
                                },
                                child: const Text(
                                  "AGB",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _launchUrl('/impressum.html');
                                },
                                child: const Text(
                                  "Impressum",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
