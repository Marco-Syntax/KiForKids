/// KIService ruft Aufgaben und Korrekturen über eigene Backend-API-Endpunkte ab.
/// Aufgaben werden über /generate_tasks, Korrekturen über /check_answers geholt.
/// Der OpenAI-Key wird nicht mehr direkt verwendet.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class KIService {
  // Backend-Basis-URL für alle API-Aufrufe (anpassen je nach Umgebung)
  static const String backendBaseUrl = "https://api.kiforkids.de";

  final String backendUrl;

  KIService({this.backendUrl = backendBaseUrl});

  /// Generiert Aufgaben mit Lösungen über den eigenen Backend-Endpunkt.
  Future<List<Map<String, String>>> generateTasks({
    required String subject,
    required String topic,
    required String level,
    int count = 3,
    String? extraPrompt,
    List<String>? classTopics,
    List<String>? usedQuestions,
    bool testMode = false,
  }) async {
    final url = Uri.parse('$backendUrl/generate_tasks');
    final body = {
      "subject": subject,
      "topic": topic,
      "level": level,
      "testMode": testMode,
      "usedQuestions": usedQuestions ?? [],
      "classTopics": classTopics ?? [],
    };
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasks =
          (data['tasks'] as List).map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
      return tasks;
    } else {
      throw Exception('Aufgaben konnten nicht geladen werden: ${response.body}');
    }
  }

  /// Kontrolliert Antworten zu Aufgaben lokal anhand der mitgelieferten Lösungen.
  List<String> checkAnswers({required List<Map<String, String>> generatedTasks, required List<String> userAnswers}) {
    final feedback = <String>[];
    for (var i = 0; i < generatedTasks.length; i++) {
      final solution = (generatedTasks[i]["answer"] ?? "").trim().toLowerCase();
      final user = (i < userAnswers.length ? userAnswers[i] : "").trim().toLowerCase();
      if (solution.isEmpty) {
        feedback.add("Keine Lösung vorhanden.");
      } else if (solution == user) {
        feedback.add("richtig");
      } else {
        feedback.add("falsch (richtige Lösung: $solution)");
      }
    }
    return feedback;
  }

  /// Prüft die Erreichbarkeit des Backends über den /ping-Endpunkt.
  Future<bool> pingBackend() async {
    try {
      final response = await http.get(Uri.parse("$backendUrl/ping"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == "pong";
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
