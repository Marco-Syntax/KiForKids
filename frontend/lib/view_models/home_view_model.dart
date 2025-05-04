import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/mathe_model.dart';
import '../models/deutsch_model.dart';
import '../models/englisch_model.dart';
import '../models/sachkunde_model.dart';
import '../models/naturwissenschaften_model.dart';
import '../util/ki_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

// HomeState speichert UserModel (Klasse, Level, Fächer)
class HomeState {
  final UserModel user;
  final String? selectedTopic;
  final bool showTasks;
  final List<Map<String, String>>? generatedTasks;
  final bool isLoadingTasks;
  final String? taskError;
  final List<String>? lastFeedback; // Feedback der KI-Korrektur
  final bool isCheckingAnswers; // Status für Antwortprüfung
  final String? activeSubject; // NEU: aktuell aktives Fach
  final Map<String, List<ResultsEntry>> resultsHistory; // NEU: Ergebnisse pro Fach

  const HomeState({
    required this.user,
    this.selectedTopic,
    this.showTasks = false,
    this.generatedTasks,
    this.isLoadingTasks = false,
    this.taskError,
    this.lastFeedback,
    this.isCheckingAnswers = false,
    this.activeSubject, // NEU
    this.resultsHistory = const {},
  });

  HomeState copyWith({
    UserModel? user,
    String? selectedTopic,
    bool? showTasks,
    List<Map<String, String>>? generatedTasks,
    bool? isLoadingTasks,
    String? taskError,
    List<String>? lastFeedback,
    bool? isCheckingAnswers,
    String? activeSubject, // NEU
    Map<String, List<ResultsEntry>>? resultsHistory,
  }) => HomeState(
    user: user ?? this.user,
    selectedTopic: selectedTopic ?? this.selectedTopic,
    showTasks: showTasks ?? this.showTasks,
    generatedTasks: generatedTasks,
    isLoadingTasks: isLoadingTasks ?? this.isLoadingTasks,
    taskError: taskError,
    lastFeedback: lastFeedback ?? this.lastFeedback,
    isCheckingAnswers: isCheckingAnswers ?? this.isCheckingAnswers,
    activeSubject: activeSubject ?? this.activeSubject, // NEU
    resultsHistory: resultsHistory ?? this.resultsHistory,
  );
}

// Ergebnis-Eintrag für die Übersicht
class ResultsEntry {
  final String fach;
  final String topic;
  final List<String> questions;
  final List<String> userAnswers;
  final List<String> feedback;
  final DateTime timestamp;

  ResultsEntry({
    required this.fach,
    required this.topic,
    required this.questions,
    required this.userAnswers,
    required this.feedback,
    required this.timestamp,
  });
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
  HomeViewModel()
    : super(
        HomeState(
          user: const UserModel(
            userId: 'demo_user', // Standard-UserId
            selectedClass: 'Klasse 5',
            selectedLevel: 'Einsteiger',
          ),
        ),
      );
  KIService? _kiService;

  // Getter für Zugriff aus der View
  KIService? get kiService => _kiService;

  void setKIService(KIService service) {
    _kiService = service;
  }

  // --- UI-Logik auslagern: TextEditingController-Handling, Aufgabenprüfung, etc. ---

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
    int count = 3,
    String testMode = "bool", // NEU
  }) async {
    if (_kiService == null) throw Exception("KIService nicht gesetzt");
    state = state.copyWith(isLoadingTasks: true, taskError: null, generatedTasks: null, lastFeedback: null);
    try {
      final randomSeed = "${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch % 1000}";
      print("DEBUG: ViewModel ruft KIService.generateTasks auf mit testMode: $testMode");
      final bool testModeBool = testMode == "bool";
      final tasks = await _kiService!.generateTasks(
        subject: subject,
        topic: topic,
        level: level,
        count: count,
        extraPrompt: "Seed: $randomSeed",
        testMode: testModeBool,
      );
      state = state.copyWith(generatedTasks: tasks, isLoadingTasks: false, showTasks: true, lastFeedback: null);
    } catch (e) {
      state = state.copyWith(taskError: e.toString(), isLoadingTasks: false, generatedTasks: null, lastFeedback: null);
    }
  }

  void selectClass(String selectedClass) {
    state = state.copyWith(user: state.user.copyWith(selectedClass: selectedClass));
  }

  void selectLevel(String selectedLevel) {
    state = state.copyWith(user: state.user.copyWith(selectedLevel: selectedLevel));
  }

  void toggleSubject(String subject) {
    final subjects = [...state.user.selectedSubjects];
    if (subjects.contains(subject)) {
      subjects.remove(subject);
    } else {
      subjects.add(subject);
    }
    // Setze das zuletzt angeklickte Fach als aktiv
    state = state.copyWith(
      user: state.user.copyWith(selectedSubjects: subjects),
      activeSubject: subject,
      selectedTopic: null,
      showTasks: false,
      generatedTasks: null,
      lastFeedback: null,
      taskError: null,
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
      user: const UserModel(selectedClass: 'Klasse 5', selectedLevel: 'Einsteiger', userId: ''),
      selectedTopic: null,
      showTasks: false,
      generatedTasks: null,
      isLoadingTasks: false,
      taskError: null,
      lastFeedback: null,
      isCheckingAnswers: false,
      activeSubject: null,
      resultsHistory: const {},
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
    state = state.copyWith(isCheckingAnswers: true, lastFeedback: null);
    try {
      final subject = getActiveSubject() ?? '';
      final topic = state.selectedTopic ?? '';
      // Nutze die lokal generierten Aufgaben und Lösungen
      final generatedTasks = state.generatedTasks ?? [];
      final feedback = _kiService!.checkAnswers(generatedTasks: generatedTasks, userAnswers: answers);
      // Ergebnisse speichern (lokal)
      final entry = ResultsEntry(
        fach: subject,
        topic: topic,
        questions: questions,
        userAnswers: answers,
        feedback: feedback,
        timestamp: DateTime.now(),
      );
      final newHistory = Map<String, List<ResultsEntry>>.from(state.resultsHistory);
      newHistory.putIfAbsent(subject, () => []);
      newHistory[subject] = [...newHistory[subject]!, entry];
      state = state.copyWith(isCheckingAnswers: false, lastFeedback: feedback, resultsHistory: newHistory);

      // Ergebnisse im Backend speichern
      final userId = state.user.userId;
      final url = Uri.parse("http://localhost:8000/save_results/$userId");
      await http.post(
        url,
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
    } catch (e) {
      state = state.copyWith(
        isCheckingAnswers: false,
        lastFeedback: List.generate(questions.length, (_) => "Konnte nicht geprüft werden."),
      );
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

  /// Lädt die Ergebnisse für das aktuelle Fach und User vom Backend.
  Future<List<Map<String, dynamic>>> getResultsFromBackend(String fach) async {
    // Fallback für userId, falls leer
    final userId = (state.user.userId.isNotEmpty ? state.user.userId : "demo_user");
    final url = Uri.parse("http://localhost:8000/get_results/$userId/$fach");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.isEmpty) return [];
      final List<dynamic> data = jsonDecode(body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Fehler beim Laden der Ergebnisse: ${response.statusCode}");
    }
  }

  /// Gibt einen zufälligen motivierenden Begrüßungstext zurück.
  Future<String> getGreetingText() async {
    // Du kannst diese Liste beliebig erweitern oder später KI-basiert machen
    const greetings = [
      "Schön, dass du da bist! Viel Spaß beim Lernen!",
      "Bereit für neue Herausforderungen? Los geht's!",
      "Willkommen zurück, du schaffst das!",
      "Super, dass du heute lernst!",
      "Lernen macht dich stark – leg los!",
      "Hallo! Heute wirst du wieder schlauer!",
      "Toll, dass du dich wieder zu sehen!",
      "Auf geht's zu neuen Aufgaben!",
      "Jeder Tag ist ein Lerntag – viel Erfolg!",
      "Du bist spitze – viel Spaß mit den Aufgaben!",
    ];
    final rnd = Random();
    return greetings[rnd.nextInt(greetings.length)];
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) => HomeViewModel());
