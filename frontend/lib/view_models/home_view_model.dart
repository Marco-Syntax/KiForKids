import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/models/deutsch_model.dart';
import 'package:frontend/models/englisch_model.dart';
import 'package:frontend/models/mathe_model.dart';
import 'package:frontend/models/naturwissenschaften_model.dart';
import 'package:frontend/models/sachkunde_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/util/ki_service.dart';
import 'package:http/http.dart' as http;

part 'home_view_model.freezed.dart';

// Ergebnis-Eintrag für die Übersicht als @freezed-Klasse
@freezed
abstract class ResultsEntry with _$ResultsEntry {
  const factory ResultsEntry({
    required String fach,
    required String topic,
    required List<String> questions,
    required List<String> userAnswers,
    required List<String> feedback,
    required DateTime timestamp,
  }) = _ResultsEntry;
}

// HomeState als @freezed-Klasse
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required UserModel user,
    String? selectedTopic,
    @Default(false) bool showTasks,
    List<Map<String, String>>? generatedTasks,
    @Default(false) bool isLoadingTasks,
    String? taskError,
    List<String>? lastFeedback,
    @Default(false) bool isCheckingAnswers,
    String? activeSubject,
    @Default({}) Map<String, List<ResultsEntry>> resultsHistory,
    @Default("Bereit zum Lernen?") String greeting,
    @Default("bool") String testMode,
    @Default(false) bool testLocked,
    // Für alle Test-Typen gemeinsam
    @Default([]) List<String> currentTestTasks,
    @Default(false) bool showTestResult,
    @Default([]) List<bool> testIsCorrect,
    @Default([]) List<String> testFeedback,
    @Default(false) bool isCheckingTest,
    @Default(false) bool canContinueTest,

    // Spezifisch für Text-Eingabe Tests
    @Default([]) List<String> textInputAnswers,

    // Spezifisch für True/False Tests
    @Default([]) List<String?> trueFalseAnswers,

    // Spezifisch für MC Tests
    @Default([]) List<String?> mcAnswers,
  }) = _HomeState;
}

class HomeViewModel extends StateNotifier<HomeState> {
  // Statische Listen für die UI
  static const List<String> subjects = ['Mathematik', 'Deutsch', 'Englisch', 'Sachkunde', 'Naturwissenschaften'];
  static const List<String> classes = [
    'Klasse 5',
    'Klasse 6',
    'Klasse 7',
    'Klasse 8',
    'Klasse 9',
    'Klasse 10',
    'Klasse 11',
    'Klasse 12',
    'Klasse 13',
  ];
  static const List<String> levels = ['Einsteiger', 'Fortgeschritten', 'Experte'];

  HomeViewModel() : super(HomeState(user: UserModel(selectedClass: 'Klasse 5', selectedLevel: 'Einsteiger'))) {
    // Begrüßungstext beim Start laden
    loadGreeting();
  }

  KIService? _kiService;
  // Getter für Zugriff aus der View
  KIService? get kiService => _kiService;

  void setKIService(KIService service) {
    _kiService = service;
  }

  /// Gibt eine Liste von TextEditingControllern für die Aufgaben zurück.
  List<TextEditingController> createControllers(int count) {
    return List.generate(count, (_) => TextEditingController());
  }

  /// Prüft, ob alle Felder ausgefüllt sind.
  bool allFieldsFilled(List<TextEditingController> controllers) {
    return controllers.every((c) => c.text.trim().isNotEmpty);
  }

  /// Holt die Antworten aus den Controllern.
  List<String> getAnswers(List<TextEditingController> controllers) {
    return controllers.map((c) => c.text.trim()).toList();
  }

  /// Prüft die Antworten mit der KI und gibt Feedback + Korrektheit zurück.
  Future<(List<String> feedback, List<bool> isCorrect)> checkAnswersWithKIControllers({
    required List<String> questions,
    required List<TextEditingController> controllers,
  }) async {
    if (_kiService == null) {
      return (
        List.generate(questions.length, (_) => "Kein KI-Service."),
        List.generate(questions.length, (_) => false),
      );
    }
    final answers = getAnswers(controllers);
    // Nutze die lokal generierten Aufgaben und Lösungen
    final generatedTasks = state.generatedTasks ?? [];
    final feedback = _kiService!.checkAnswers(generatedTasks: generatedTasks, userAnswers: answers);
    final isCorrect = feedback.map((f) => f.toLowerCase().startsWith('richtig')).toList();
    return (feedback, isCorrect);
  }

  Future<void> generateTasksWithKI({
    required String subject,
    required String topic,
    required String level,
    int count = 3, // Standardwert auf 3 geändert (vorher 5)
    String testMode = "bool",
  }) async {
    if (_kiService == null) throw Exception("KIService nicht gesetzt");
    state = state.copyWith(
      isLoadingTasks: true,
      taskError: null,
      generatedTasks: null,
      lastFeedback: null,
      testLocked: true,
    );
    try {
      final randomSeed = "${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch % 1000}";
      final bool testModeBool = testMode == "bool";

      final tasks = await _kiService!.generateTasks(
        subject: subject,
        topic: topic,
        level: level,
        count: count,
        extraPrompt: "Seed: $randomSeed",
        testMode: testModeBool,
        usedQuestions: [],
        classTopics: [],
      );

      state = state.copyWith(generatedTasks: tasks, isLoadingTasks: false, showTasks: true, lastFeedback: null);
    } catch (e) {
      state = state.copyWith(
        taskError: e.toString(),
        isLoadingTasks: false,
        generatedTasks: null,
        lastFeedback: null,
        testLocked: false,
      );
    }
  }

  void selectClass(String selectedClass) {
    state = state.copyWith(user: state.user.copyWith(selectedClass: selectedClass));
  }

  void selectLevel(String selectedLevel) {
    state = state.copyWith(user: state.user.copyWith(selectedLevel: selectedLevel));
  }

  void toggleSubject(String subject) {
    // Den aktuellen Testmodus beibehalten
    final currentTestMode = state.testMode;

    // Alles zurücksetzen beim Fachwechsel UND Testmodus entsperren
    state = HomeState(
      user: state.user.copyWith(
        selectedSubjects: [subject],
        selectedClass: state.user.selectedClass,
        selectedLevel: state.user.selectedLevel,
      ),
      activeSubject: subject,
      testMode: currentTestMode, // Testmodus beibehalten!
      // alle anderen Felder bleiben auf Default-Werten
    );
  }

  void selectTopic(String? topic) {
    state = state.copyWith(selectedTopic: topic);
  }

  void resetTopicAndTasks() {
    state = state.copyWith(selectedTopic: null, showTasks: false, lastFeedback: null);
  }

  void showTasks() {
    state = state.copyWith(showTasks: true);
  }

  void hideTasks() {
    state = state.copyWith(showTasks: false, lastFeedback: null);
  }

  void resetAll() {
    state = HomeState(
      user: UserModel(selectedClass: 'Klasse 5', selectedLevel: 'Einsteiger'),
      testLocked: false, // Testmodus-Buttons entsperren
      // Andere Werte behalten ihre Default-Werte aus der @freezed-Definition
    );
  }

  List<String> getAufgabenbereiche(String fach, String klasse) {
    switch (fach) {
      case 'Mathematik':
        return MatheModel.aufgabenbereiche[klasse] ?? [];
      case 'Deutsch':
        return DeutschModel.aufgabenbereiche[klasse] ?? [];
      case 'Englisch':
        return EnglischModel.aufgabenbereiche[klasse] ?? [];
      case 'Sachkunde':
        return SachkundeModel.aufgabenbereiche[klasse] ?? [];
      case 'Naturwissenschaften':
        return NaturwissenschaftenModel.aufgabenbereiche[klasse] ?? [];
      default:
        return [];
    }
  }

  /// Prüft die Antworten mit der KI, speichert das Feedback UND die Ergebnisse im State und Backend.
  Future<void> checkAnswersWithKI({required List<String> questions, required List<String> answers}) async {
    if (_kiService == null) return;

    try {
      final subject = getActiveSubject() ?? '';
      final topic = state.selectedTopic ?? '';

      // Wenn Feedback bereits generiert wurde (z.B. vom TestViewModel), verwenden wir das
      List<String> feedback;
      if (state.lastFeedback != null && state.lastFeedback!.length == answers.length) {
        feedback = state.lastFeedback!;
      } else {
        // Nutze die lokal generierten Aufgaben und Lösungen
        final generatedTasks = state.generatedTasks ?? [];
        feedback = _kiService!.checkAnswers(generatedTasks: generatedTasks, userAnswers: answers);
      }

      // Ergebnisse speichern (lokal)
      final entry = ResultsEntry(
        fach: subject,
        topic: topic,
        questions: questions,
        userAnswers: answers,
        feedback: feedback,
        timestamp: DateTime.now(),
      );

      // Map kopieren und aktualisieren mit neuem Eintrag
      final currentHistory = state.resultsHistory;
      final List<ResultsEntry> subjectEntries = List.from(currentHistory[subject] ?? []);
      subjectEntries.add(entry);

      final newHistory = Map<String, List<ResultsEntry>>.from(currentHistory);
      newHistory[subject] = subjectEntries;

      state = state.copyWith(lastFeedback: feedback, resultsHistory: newHistory);

      // Lokale URL für lokale Entwicklung, ansonsten die Production-URL
      final baseUrl =
          const bool.fromEnvironment('dart.vm.product') ? "https://api.kiforkids.de" : "http://localhost:8000";

      final saveUrl = Uri.parse("$baseUrl/save_results/${state.user.id}");

      final response = await http.post(
        saveUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fach": subject,
          "topic": topic,
          "questions": questions,
          "userAnswers": answers,
          "feedback": feedback,
          "timestamp": entry.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        // Stille Fehlerbehandlung - keine Debug-Ausgaben
      }
    } catch (e) {
      // Stille Fehlerbehandlung - keine Debug-Ausgaben
    }
  }

  /// Lädt die Ergebnisse für das aktuelle Fach und User vom Backend.
  Future<List<Map<String, dynamic>>> getResultsFromBackend(String fach) async {
    try {
      // Lokale URL für lokale Entwicklung, ansonsten die Production-URL
      final baseUrl =
          const bool.fromEnvironment('dart.vm.product') ? "https://api.kiforkids.de" : "http://localhost:8000";

      final url = Uri.parse("$baseUrl/get_results/${state.user.id}/$fach");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isEmpty) return [];
        final List<dynamic> data = jsonDecode(body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Fehler beim Laden der Ergebnisse: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Fehler beim Laden der Ergebnisse: $e");
    }
  }

  /// Gibt die Ergebnis-Historie für ein Fach zurück.
  List<ResultsEntry> getResultsForSubject(String fach) {
    return state.resultsHistory[fach] ?? [];
  }

  // Hilfsfunktion: Gibt das aktuell aktive Fach zurück (oder das erste gewählte)
  String? getActiveSubject() {
    if (state.activeSubject != null && state.user.selectedSubjects.contains(state.activeSubject)) {
      return state.activeSubject;
    }
    if (state.user.selectedSubjects.isNotEmpty) {
      return state.user.selectedSubjects.first;
    }
    return null;
  }

  /// Gibt einen zufälligen motivierenden Begrüßungstext zurück.
  Future<String> getGreetingText() async {
    // Erweiterte Liste mit inspirierenden und motivierenden Sprüchen für Kinder
    const greetings = [
      "Schön, dass du da bist! Viel Spaß beim Lernen!",
      "Bereit für neue Herausforderungen? Los geht's!",
      "Willkommen zurück, du schaffst das!",
      "Super, dass du heute lernst!",
      "Lernen macht dich stark – leg los!",
      "Hallo! Heute wirst du wieder schlauer!",
      "Toll, schön dich wieder zu sehen!",
      "Auf geht's zu neuen Aufgaben!",
      "Jeder Tag ist ein Lerntag – viel Erfolg!",
      "Du bist spitze – viel Spaß mit den Aufgaben!",
      "Wissen ist wie ein Schatz - lass uns danach suchen!",
      "Dein Gehirn wird stärker mit jeder Aufgabe!",
      "Neugier ist der Schlüssel zum Lernen!",
      "Auch Einstein hat klein angefangen!",
      "Mit jedem Fehler wirst du besser!",
      "Übung macht den Meister - auf geht's!",
      "Glaube an dich selbst und deine Fähigkeiten!",
      "Kleine Schritte führen zu großen Erfolgen!",
      "Heute ist ein guter Tag zum Schlaumachen!",
      "Lerne mit Freude und vergiss die Zeit!",
      "Deine Zukunft beginnt mit dem, was du heute lernst!",
      "Entdecke die spannende Welt des Wissens!",
      "Jede richtige Antwort ist ein Erfolg!",
      "Dein Wissen ist deine Superkraft!",
      "Probiere es aus - du wirst überrascht sein!",
    ];
    final rnd = Random();
    return greetings[rnd.nextInt(greetings.length)];
  }

  // Begrüßungstext laden und im State speichern
  Future<void> loadGreeting() async {
    final newGreeting = await getGreetingText();
    state = state.copyWith(greeting: newGreeting);
  }

  // Diese Methode hinzufügen, um manuell einen neuen Spruch zu laden
  void refreshGreeting() {
    loadGreeting();
  }

  // Testmodus ändern
  void setTestMode(String mode) {
    state = state.copyWith(testMode: mode);
  }

  // Test-Sperrstatus ändern
  void setTestLocked(bool locked) {
    state = state.copyWith(testLocked: locked);
  }

  // Callback wenn Test beendet wurde
  void onTestFinished() {
    state = state.copyWith(testLocked: false);
    hideTasks();
  }

  // Wieder hinzugefügte Test-Methoden

  // Initialisierung für beide Test-Typen
  void initTest(List<String> tasks) {
    state = state.copyWith(
      currentTestTasks: tasks,
      showTestResult: false,
      testIsCorrect: List.generate(tasks.length, (_) => false),
      testFeedback: List.generate(tasks.length, (_) => ""),
      isCheckingTest: false,
      canContinueTest: false,
      textInputAnswers: List.generate(tasks.length, (_) => ""),
      trueFalseAnswers: List.generate(tasks.length, (_) => null),
      mcAnswers: List.generate(tasks.length, (_) => null),
    );
  }

  // Methoden für TestInput
  void setTestAnswer(int index, String answer) {
    final newAnswers = List<String>.from(state.textInputAnswers);
    newAnswers[index] = answer.trim();
    state = state.copyWith(textInputAnswers: newAnswers);
  }

  bool allTestAnswersFilled() {
    return state.textInputAnswers.every((a) => a.isNotEmpty);
  }

  // Methoden für True/False Test
  void setTrueFalseAnswer(int index, String answer) {
    // Wenn der Array noch nicht initialisiert oder zu klein ist
    List<String?> newAnswers;
    if (state.trueFalseAnswers.isEmpty || state.trueFalseAnswers.length <= index) {
      // Ein neues Array mit der benötigten Größe erstellen
      newAnswers = List<String?>.filled(max(state.currentTestTasks.length, index + 1), null);
      // Bestehende Antworten übernehmen
      for (int i = 0; i < state.trueFalseAnswers.length; i++) {
        newAnswers[i] = state.trueFalseAnswers[i];
      }
    } else {
      // Bestehenden Array kopieren
      newAnswers = List<String?>.from(state.trueFalseAnswers);
    }

    // Antwort setzen
    newAnswers[index] = answer;

    // State aktualisieren, aber keine anderen Flags ändern, die den Button beeinflussen könnten
    state = state.copyWith(
      trueFalseAnswers: newAnswers,
      // showTestResult und isCheckingTest bleiben unverändert
    );
  }

  // Methode für MC Test
  void setMCAnswer(int index, String option) {
    // Wenn der Array noch nicht initialisiert oder zu klein ist
    List<String?> newAnswers;
    if (state.mcAnswers.isEmpty || state.mcAnswers.length <= index) {
      // Ein neues Array mit der benötigten Größe erstellen
      newAnswers = List<String?>.filled(max(state.currentTestTasks.length, index + 1), null);
      // Bestehende Antworten übernehmen
      for (int i = 0; i < state.mcAnswers.length; i++) {
        newAnswers[i] = state.mcAnswers[i];
      }
    } else {
      // Bestehenden Array kopieren
      newAnswers = List<String?>.from(state.mcAnswers);
    }

    // Antwort setzen
    newAnswers[index] = option;

    // State aktualisieren, aber keine anderen Flags ändern
    state = state.copyWith(mcAnswers: newAnswers);
  }

  // Gemeinsame Test-Funktionen
  Future<void> checkTestAnswers() async {
    if (_kiService == null) {
      state = state.copyWith(
        testFeedback: List.generate(state.currentTestTasks.length, (_) => "KI-Service nicht verfügbar"),
        showTestResult: true,
        isCheckingTest: false,
      );
      return;
    }

    state = state.copyWith(showTestResult: false, isCheckingTest: true, canContinueTest: false);

    List<String> answers;
    // Antworten je nach Testtyp zusammenstellen
    if (state.trueFalseAnswers.any((a) => a != null)) {
      // True/False Test - Achtung: Null-Werte durch leere Strings ersetzen
      answers = state.trueFalseAnswers.map((a) => a ?? "").toList();
    } else if (state.mcAnswers.any((a) => a != null)) {
      // MC Test - Achtung: Null-Werte durch leere Strings ersetzen
      answers = state.mcAnswers.map((a) => a ?? "").toList();
    } else {
      // Input Test
      answers = state.textInputAnswers;
    }

    try {
      final generatedTasks = state.generatedTasks ?? [];
      final feedback = _kiService!.checkAnswers(generatedTasks: generatedTasks, userAnswers: answers);
      final isCorrect = feedback.map((f) => f.toLowerCase().startsWith('richtig')).toList();

      state = state.copyWith(
        testFeedback: feedback,
        testIsCorrect: isCorrect,
        showTestResult: true,
        isCheckingTest: false,
        canContinueTest: true,
      );

      // Auch für die Ergebnishistorie speichern
      checkAnswersWithKI(questions: state.currentTestTasks, answers: answers);
    } catch (e) {
      state = state.copyWith(
        testFeedback: List.generate(state.currentTestTasks.length, (_) => "Fehler bei der Überprüfung: $e"),
        isCheckingTest: false,
        showTestResult: true,
        canContinueTest: false,
      );
    }
  }

  Future<void> continueTest() async {
    state = state.copyWith(showTestResult: false, isCheckingTest: true, canContinueTest: false);

    final subject = state.user.selectedSubjects.isNotEmpty ? state.user.selectedSubjects.first : '';
    final topic = state.selectedTopic ?? '';
    final level = state.user.selectedLevel;

    // Hier explizit 3 Aufgaben anfordern
    await generateTasksWithKI(subject: subject, topic: topic, level: level, count: 3);

    final newTasks = state.generatedTasks?.map((t) => t['question'] ?? '').toList() ?? [];
    initTest(newTasks);

    state = state.copyWith(isCheckingTest: false);
  }

  void finishTest(VoidCallback onFinished) {
    resetAll();
    onFinished();
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) => HomeViewModel());
