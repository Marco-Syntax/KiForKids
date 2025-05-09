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
    // Initialisiere Logger, falls nicht bereits geschehen
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
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

    // Debug-Ausgabe der Anfrage
    _logger.info('Sende Aufgabenanfrage an $url');
    _logger.info('Anfragedaten: ${jsonEncode(body)}');

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    _logger.info('Statuscode: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      _logger.info('Antwort vom Server: $data');

      try {
        if (data['tasks'] is List) {
          final tasks =
              (data['tasks'] as List)
                  .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
                  .toList();

          _logger.info('Extrahierte Aufgaben: $tasks');
          _logger.info('Anzahl der Aufgaben: ${tasks.length}');

          // Sicherstellen, dass immer genau die angeforderte Anzahl (count) an Aufgaben zurückgegeben wird
          if (tasks.length < count) {
            _logger.warning('Weniger als $count Aufgaben erhalten! Fülle mit Platzhaltern auf.');
            while (tasks.length < count) {
              tasks.add({
                "question": "Zusatzfrage zum Thema $topic?",
                "answer": "Diese Frage konnte nicht generiert werden. Bitte generiere neue Aufgaben.",
              });
            }
          } else if (tasks.length > count) {
            _logger.warning('Mehr als $count Aufgaben erhalten! Beschränke auf die ersten $count.');
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
      _logger.severe('HTTP-Fehler: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Aufgaben konnten nicht geladen werden: ${response.body}');
    }
  }

  /// Kontrolliert Antworten zu Aufgaben lokal anhand der mitgelieferten Lösungen.
  List<String> checkAnswers({required List<Map<String, String>> generatedTasks, required List<String> userAnswers}) {
    _logger.info('Prüfe Antworten: ${userAnswers.length} Benutzerantworten für ${generatedTasks.length} Aufgaben');
    _logger.info('Aufgaben mit Lösungen: $generatedTasks');
    _logger.info('Benutzerantworten: $userAnswers');

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

    _logger.info('Generiertes Feedback: $feedback');
    return feedback;
  }

  /// Prüft die Erreichbarkeit des Backends über den /ping-Endpunkt.
  Future<bool> pingBackend() async {
    try {
      final url = Uri.parse("$backendUrl/ping");
      _logger.info('Ping an Backend: $url');

      final response = await http.get(url);
      _logger.info('Ping-Statuscode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.info('Ping-Antwort: $data');
        return data["status"] == "pong";
      }
      return false;
    } catch (e) {
      _logger.severe('Ping-Fehler: $e');
      return false;
    }
  }
}
