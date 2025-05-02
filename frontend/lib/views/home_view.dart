import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/util/ki_service.dart';
import 'package:frontend/view_models/home_view_model.dart';

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
  // HIER DEIN OPENAI API-KEY EINTRAGEN (nur zu Testzwecken, nicht für Produktion! .env-Datei verwenden)
  static const String openAIApiKey = "";

  String greeting = "Hallo Schüler!";

  @override
  void initState() {
    super.initState();
    // Setze den KIService im ViewModel, falls noch nicht gesetzt
    final vm = ref.read(homeViewModelProvider.notifier);
    vm.setKIService(KIService(apiKey: openAIApiKey));
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
                // Header-Bereich
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "KI-School for Kids",
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
                        ],
                      ),
                    ),
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
                          if (!mounted) return;
                          showDialog(
                            // ignore: use_build_context_synchronously
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
                            // ignore: use_build_context_synchronously
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
                  ],
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
                                      child: Text(c, style: const TextStyle(fontSize: 16, color: Colors.white)),
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
                                      child: Text(l, style: const TextStyle(fontSize: 16, color: Colors.white)),
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
                    const SizedBox(width: 18),
                  ],
                ),
                const SizedBox(height: 36),
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
                                    return _AufgabenMitEingabe(
                                      tasks: state.generatedTasks!,
                                      accent: accent,
                                      cardColor: cardColor,
                                    );
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
                                      label: const Text("Aufgaben generieren"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed:
                                          state.isLoadingTasks
                                              ? null
                                              : () async {
                                                await vm.generateTasksWithKI(
                                                  subject: activeSubject,
                                                  topic: selectedTopic,
                                                  level: state.user.selectedLevel,
                                                  count: 3,
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
}

class _AufgabenMitEingabe extends ConsumerStatefulWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;

  const _AufgabenMitEingabe({required this.tasks, required this.accent, required this.cardColor});

  @override
  ConsumerState<_AufgabenMitEingabe> createState() => _AufgabenMitEingabeState();
}

class _AufgabenMitEingabeState extends ConsumerState<_AufgabenMitEingabe> {
  late List<TextEditingController> _controllers;
  bool _showResult = false;
  late List<bool> _isCorrect;
  List<String> _feedback = [];
  bool _isChecking = false;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(homeViewModelProvider.notifier);
    _controllers = vm.createControllers(widget.tasks.length);
    _isCorrect = List.generate(widget.tasks.length, (_) => false);
    _feedback = List.generate(widget.tasks.length, (_) => "");
    _canContinue = false;
    for (final c in _controllers) {
      c.addListener(_onInputChanged);
    }
  }

  @override
  void didUpdateWidget(covariant _AufgabenMitEingabe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks.length != widget.tasks.length || !_listEquals(oldWidget.tasks, widget.tasks)) {
      // Alte Controller entfernen
      for (final c in _controllers) {
        c.removeListener(_onInputChanged);
        c.dispose();
      }
      // Neue Controller erzeugen
      final vm = ref.read(homeViewModelProvider.notifier);
      _controllers = vm.createControllers(widget.tasks.length);
      _isCorrect = List.generate(widget.tasks.length, (_) => false);
      _feedback = List.generate(widget.tasks.length, (_) => "");
      _showResult = false;
      _canContinue = false;
      for (final c in _controllers) {
        c.addListener(_onInputChanged);
      }
      setState(() {}); // UI aktualisieren
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onInputChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  Future<void> _checkAnswers() async {
    setState(() {
      _showResult = false;
      _isChecking = true;
      _canContinue = false;
    });
    final vm = ref.read(homeViewModelProvider.notifier);
    final (feedback, isCorrect) = await vm.checkAnswersWithKIControllers(
      questions: widget.tasks,
      controllers: _controllers,
    );
    setState(() {
      _feedback = feedback;
      _isCorrect = isCorrect;
      _showResult = true;
      _isChecking = false;
      _canContinue = true;
    });
  }

  Future<void> _onContinue() async {
    // Neue Aufgaben generieren (mit KI, falls möglich)
    final vm = ref.read(homeViewModelProvider.notifier);
    final state = ref.read(homeViewModelProvider);
    final subject = state.user.selectedSubjects.isNotEmpty ? state.user.selectedSubjects.first : '';
    final topic = state.selectedTopic ?? '';
    final level = state.user.selectedLevel;

    setState(() {
      _showResult = false;
      _canContinue = false;
      for (final c in _controllers) {
        c.clear();
      }
      _isCorrect = List.generate(widget.tasks.length, (_) => false);
      _feedback = List.generate(widget.tasks.length, (_) => "");
      _isChecking = true;
    });

    await vm.generateTasksWithKI(subject: subject, topic: topic, level: level, count: 5);

    // Nach Generierung: UI zurücksetzen (neue Aufgaben werden durch Parent-Widget geladen)
    setState(() {
      _isChecking = false;
    });
  }

  // Beenden-Handler: Setzt alles zurück und zeigt keine Ergebnisse mehr an
  Future<void> _onFinish() async {
    ref.read(homeViewModelProvider.notifier).resetAll();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(homeViewModelProvider.notifier);
    final allFilled = vm.allFieldsFilled(_controllers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fragen:', style: TextStyle(fontWeight: FontWeight.bold, color: widget.accent, fontSize: 22)),
        const SizedBox(height: 18),
        ...List.generate(widget.tasks.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: widget.cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.accent.withOpacity(0.18)),
              boxShadow: [BoxShadow(color: widget.accent.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: widget.accent, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.tasks[i],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _controllers[i],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deine Antwort',
                      labelStyle: TextStyle(color: widget.accent, fontWeight: FontWeight.w400),
                      filled: true,
                      fillColor: widget.cardColor.withOpacity(0.85),
                      hintText: 'Antwort eingeben...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent.withOpacity(0.18)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showResult)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Icon(
                      _isCorrect[i] ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect[i] ? Colors.green : Colors.red,
                      size: 26,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (_isChecking)
          const Padding(
            padding: EdgeInsets.only(left: 60, bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text("Antworten werden geprüft...", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        if (_showResult)
          ...List.generate(widget.tasks.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(left: 60, bottom: 8),
              child: Text(
                _feedback[i],
                style: TextStyle(
                  color: _isCorrect[i] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            );
          }),
        if (!_showResult && allFilled && !_isChecking)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Ergebnisse anzeigen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _checkAnswers,
            ),
          ),
        if (_showResult)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _isCorrect.every((v) => v)
                  ? "Super, alle Fragen richtig beantwortet!"
                  : "Bitte überprüfe deine Antworten.",
              style: TextStyle(
                color: _isCorrect.every((v) => v) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        if (_showResult && _canContinue)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Weiter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _onContinue,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Beenden"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _onFinish,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
