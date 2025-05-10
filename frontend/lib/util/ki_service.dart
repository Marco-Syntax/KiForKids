import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class KIService {
  // Backend-Basis-URL für alle API-Aufrufe (anpassen je nach Umgebung)
  static const String backendBaseUrl = "https://api.kiforkids.de";
  final Logger _logger = Logger('KIService');

  final String backendUrl;

  KIService({this.backendUrl = backendBaseUrl}) {
    // Logger nur für schwerwiegende Fehler einrichten
    Logger.root.level = kDebugMode ? Level.SEVERE : Level.OFF;
    Logger.root.onRecord.listen((record) {
      // Nur bei schwerwiegenden Fehlern ausgeben
      if (record.level >= Level.SEVERE) {
        debugPrint('${record.level.name}: ${record.time}: ${record.message}');
      }
    });
  }

  /// Generiert Aufgaben mit Lösungen über den eigenen Backend-Endpunkt.
  Future<List<Map<String, String>>> generateTasks({
    required String subject,
    required String topic,
    required String level,
    int count = 3, // Standardwert auf 3 gesetzt (vorher 5)
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
      "count": count,
      "testMode": testMode,
      "usedQuestions": usedQuestions ?? [],
      "classTopics": classTopics ?? [],
    };

    // Alle Debug-Ausgaben entfernt
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      try {
        if (data['tasks'] is List) {
          final tasks =
              (data['tasks'] as List)
                  .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
                  .toList();

          // Sicherstellen, dass immer genau die angeforderte Anzahl (count) an Aufgaben zurückgegeben wird
          if (tasks.length < count) {
            while (tasks.length < count) {
              tasks.add({
                "question": "Zusatzfrage zum Thema $topic?",
                "answer": "Diese Frage konnte nicht generiert werden. Bitte generiere neue Aufgaben.",
              });
            }
          } else if (tasks.length > count) {
            return tasks.take(count).toList();
          }

          return tasks;
        } else {
          throw Exception("Unerwartetes Format: tasks ist kein List-Objekt");
        }
      } catch (e) {
        _logger.severe('Fehler beim Parsen der Aufgaben: $e');
        throw Exception('Fehler beim Parsen der Aufgaben: $e');
      }
    } else {
      _logger.severe('HTTP-Fehler: ${response.statusCode}');
      throw Exception('Aufgaben konnten nicht geladen werden');
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
      final url = Uri.parse("$backendUrl/ping");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == "pong";
      }
      return false;
    } catch (e) {
      _logger.severe('Ping-Fehler: $e');
      return false;
    }
  }
}
