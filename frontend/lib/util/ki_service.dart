/// KIService ruft Aufgaben ab und kontrolliert Ein-Wort-Antworten mit der OpenAI API (Modell GPT-4.1-nano).
/// Der API-Key wird als Parameter übergeben.

import 'dart:convert';
import 'package:http/http.dart' as http;

class KIService {
  final String apiKey;
  final String endpoint;

  KIService({required this.apiKey, this.endpoint = "https://api.openai.com/v1/chat/completions"});

  /// Gibt je nach Fach einen spezifischen Systemprompt zurück.
  String _getSystemPrompt(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathe':
      case 'mathematik':
        return "Du bist ein herausragender, empathischer KI-Mathelehrer für Gymnasien in Deutschland. "
            "Du stellst abwechslungsreiche, kurze Rechenaufgaben, die eindeutig mit einer Zahl beantwortet werden können. "
            "Keine Einleitung, keine Tipps, keine Erklärungen, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
      case 'deutsch':
        return "Du bist ein kreativer, empathischer KI-Deutschlehrer für Gymnasien in Deutschland. "
            "Du stellst sehr kurze, altersgerechte Aufgaben zu Grammatik, Rechtschreibung, Leseverständnis oder Satzbau. "
            "Jede Aufgabe kann eindeutig mit einem Wort beantwortet werden. Keine Einleitung, keine Tipps, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
      case 'englisch':
        return "Du bist ein motivierender, empathischer KI-Englischlehrer für Gymnasien in Deutschland. "
            "Du stellst sehr kurze, altersgerechte Aufgaben zu Vokabeln, Grammatik oder Leseverständnis. "
            "Jede Aufgabe kann eindeutig mit einem Wort beantwortet werden. Keine Einleitung, keine Tipps, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
      case 'sachkunde':
        return "Du bist ein freundlicher, empathischer KI-Sachkundelehrer für Gymnasien in Deutschland. "
            "Du stellst sehr kurze, altersgerechte Aufgaben zu Natur, Umwelt, Klima oder Tieren. "
            "Jede Aufgabe kann eindeutig mit einem Wort beantwortet werden. Keine Einleitung, keine Tipps, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
      case 'naturwissenschaften':
        return "Du bist ein neugieriger, empathischer KI-Lehrer für Naturwissenschaften an Gymnasien in Deutschland. "
            "Du stellst sehr kurze, altersgerechte Aufgaben zu Biologie, Chemie oder Physik. "
            "Jede Aufgabe kann eindeutig mit einem Wort beantwortet werden. Keine Einleitung, keine Tipps, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
      default:
        return "Du bist ein herausragender, empathischer KI-Lehrer für Gymnasien in Deutschland. "
            "Du stellst sehr kurze, altersgerechte Aufgaben, die eindeutig mit einem Wort beantwortet werden können. "
            "Keine Einleitung, keine Tipps, keine Überschriften. Nur die Aufgaben als nummerierte Liste.";
    }
  }

  /// Gibt je nach Fach einen spezifischen Aufgabenprompt zurück.
  String _getTaskPrompt({
    required String subject,
    required String topic,
    required String level,
    required int count,
    required String uniqueSeed,
  }) {
    count = 10;
    switch (subject.toLowerCase()) {
      case 'mathe':
      case 'mathematik':
        return "Erstelle einen Test mit 3 abwechslungsreichen, nicht wiederholenden, kurzen Rechenaufgaben für das Fach Mathematik zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen und für die angegebene Klassenstufe geeignet sein. "
            "Jede Aufgabe soll möglichst nur aus einer Rechenaufgabe bestehen (z.B. '12 + 7 = ?'). "
            "Die Aufgaben müssen so gestellt sein, dass sie eindeutig mit nur einer Zahl beantwortet werden können. "
            "Vermeide Wiederholungen und variiere die Zahlen und Aufgabentypen. "
            "Keine Einleitung, keine Tipps, keine Erklärungen, keine Überschriften. Gib die Aufgaben als nummerierte Liste zurück. "
            "(Variations-Seed: $uniqueSeed)";
      case 'deutsch':
        return "Erstelle einen Test mit 3 sehr kurzen, altersgerechten Aufgaben für das Fach Deutsch zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen. "
            "Jede Aufgabe muss so gestellt sein, dass sie eindeutig mit nur einem Wort beantwortet werden kann (z.B. ein Begriff, Name, Wortart). "
            "Formuliere jede Aufgabe als möglichst kurzen Fragesatz, ohne Einleitung, Tipps oder Überschriften. "
            "Gib die Aufgaben als nummerierte Liste zurück, ohne Lösungen, ohne weitere Erklärungen. "
            "(Variations-Seed: $uniqueSeed)";
      case 'englisch':
        return "Erstelle einen Test mit 3 sehr kurzen, altersgerechten Aufgaben für das Fach Englisch zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen. "
            "Jede Aufgabe muss so gestellt sein, dass sie eindeutig mit nur einem Wort beantwortet werden kann (z.B. Vokabel, Zeitform, Begriff). "
            "Formuliere jede Aufgabe als möglichst kurzen Fragesatz, ohne Einleitung, Tipps oder Überschriften. "
            "Gib die Aufgaben als nummerierte Liste zurück, ohne Lösungen, ohne weitere Erklärungen. "
            "(Variations-Seed: $uniqueSeed)";
      case 'sachkunde':
        return "Erstelle einen Test mit 3 sehr kurzen, altersgerechten Aufgaben für das Fach Sachkunde zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen. "
            "Jede Aufgabe muss so gestellt sein, dass sie eindeutig mit nur einem Wort beantwortet werden kann (z.B. Tiername, Pflanzenname, Begriff). "
            "Formuliere jede Aufgabe als möglichst kurzen Fragesatz, ohne Einleitung, Tipps oder Überschriften. "
            "Gib die Aufgaben als nummerierte Liste zurück, ohne Lösungen, ohne weitere Erklärungen. "
            "(Variations-Seed: $uniqueSeed)";
      case 'naturwissenschaften':
        return "Erstelle einen Test mit 3 sehr kurzen, altersgerechten Aufgaben für das Fach Naturwissenschaften zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen. "
            "Jede Aufgabe muss so gestellt sein, dass sie eindeutig mit nur einem Wort beantwortet werden kann (z.B. Fachbegriff, Name, Zahl). "
            "Formuliere jede Aufgabe als möglichst kurzen Fragesatz, ohne Einleitung, Tipps oder Überschriften. "
            "Gib die Aufgaben als nummerierte Liste zurück, ohne Lösungen, ohne weitere Erklärungen. "
            "(Variations-Seed: $uniqueSeed)";
      default:
        return "Erstelle einen Test mit 3 sehr kurzen, altersgerechten Übungsaufgaben für das Fach $subject zum Thema '$topic' auf dem Schwierigkeitsgrad '$level'. "
            "Die Aufgaben müssen dem aktuellen Lehrplan eines Gymnasiums in Deutschland entsprechen und für die angegebene Klassenstufe geeignet sein. "
            "Jede Aufgabe muss so gestellt sein, dass sie eindeutig mit nur einem Wort beantwortet werden kann (z.B. ein Begriff, Name, Zahl). "
            "Formuliere jede Aufgabe als möglichst kurzen Fragesatz, ohne Einleitung, Tipps oder Überschriften. "
            "Gib die Aufgaben als nummerierte Liste zurück, ohne Lösungen, ohne weitere Erklärungen. "
            "(Variations-Seed: $uniqueSeed)";
    }
  }

  /// Generiert Aufgaben, die mit nur einem Wort beantwortet werden können.
  Future<List<String>> generateTasks({
    required String subject,
    required String topic,
    required String level,
    int count = 3,
    String? extraPrompt, // NEU: für Seed oder Variation
  }) async {
    // Immer 10 Aufgaben generieren
    count = 5;
    final uniqueSeed = DateTime.now().microsecondsSinceEpoch.toString();
    final systemPrompt = _getSystemPrompt(subject);
    final prompt = _getTaskPrompt(subject: subject, topic: topic, level: level, count: count, uniqueSeed: uniqueSeed);

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "gpt-4.1-nano",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1000,
        "temperature": 0.3, // Temperatur erhöht für mehr Variation
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      final String content = data['choices'][0]['message']['content'];
      // Extrahiere Aufgaben aus der nummerierten Liste, ignoriere mögliche Markdown-Formatierung
      final lines =
          content
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty && (RegExp(r'^\d+[\.\)]\s').hasMatch(l) || RegExp(r'^[-*]\s').hasMatch(l)))
              .toList();
      // Fasse ggf. mehrere Zeilen zu einer Aufgabe zusammen, falls Aufgaben über mehrere Zeilen gehen
      List<String> tasks = [];
      String buffer = '';
      for (final line in lines) {
        if (RegExp(r'^\d+[\.\)]\s').hasMatch(line) || RegExp(r'^[-*]\s').hasMatch(line)) {
          if (buffer.isNotEmpty) tasks.add(buffer.trim());
          buffer = line.replaceFirst(RegExp(r'^(\d+[\.\)]|[-*])\s*'), '').trim();
        } else {
          buffer += ' $line';
        }
      }
      if (buffer.isNotEmpty) tasks.add(buffer.trim());
      // Fallback: Falls keine Aufgaben gefunden wurden, nimm alle nicht-leeren Zeilen
      if (tasks.isEmpty) {
        return content.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      }
      return tasks;
    } else {
      throw Exception('KI-Aufgaben konnten nicht geladen werden: ${response.body}');
    }
  }

  /// Kontrolliert Ein-Wort-Antworten zu Aufgaben mit der KI.
  /// Gibt eine Liste mit Feedback ("richtig" oder "falsch" + ggf. ein Wort als richtige Lösung) zurück.
  Future<List<String>> checkAnswers({
    required String subject,
    required String topic,
    required String level,
    required List<String> questions,
    required List<String> answers,
  }) async {
    final prompt = StringBuffer();
    prompt.writeln(
      "Du bist ein herausragender, empathischer KI-Lehrer, besser als jeder menschliche Lehrer, und kontrollierst die Antworten von Schülern. "
      "Jede Aufgabe kann eindeutig mit nur einem Wort beantwortet werden. "
      "Vergleiche die Schülerantworten mit der richtigen Lösung. "
      "Beurteile jede Antwort als 'richtig' oder 'falsch' und gib, falls falsch, das richtige Wort als Lösung an. "
      "Antworte als nummerierte Liste, jede Zeile im Format: 'richtig' oder 'falsch (richtige Lösung: ... )'. ",
    );
    for (int i = 0; i < questions.length; i++) {
      prompt.writeln("${i + 1}. Aufgabe: ${questions[i]}");
      prompt.writeln("   Schülerantwort: ${answers[i]}");
    }

    final systemPrompt = () {
      switch (subject.toLowerCase()) {
        case 'mathe':
        case 'mathematik':
          return "Du bist ein KI-Mathelehrer, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Vergleiche Zahlenantworten exakt (z.B. 100 == 100 ist richtig, 100 != 110 ist falsch). "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, die richtige Zahl als Lösung.";
        case 'deutsch':
          return "Du bist ein KI-Deutschlehrer, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, das richtige Wort als Lösung.";
        case 'englisch':
          return "Du bist ein KI-Englischlehrer, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, das richtige Wort als Lösung.";
        case 'sachkunde':
          return "Du bist ein KI-Sachkundelehrer, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, das richtige Wort als Lösung.";
        case 'naturwissenschaften':
          return "Du bist ein KI-Lehrer für Naturwissenschaften, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, das richtige Wort als Lösung.";
        default:
          return "Du bist ein KI-Lehrer, der Schülerantworten freundlich, motivierend und fachlich korrekt kontrolliert. "
              "Du gibst für jede Aufgabe eine Rückmeldung, ob die Antwort richtig oder falsch ist, und falls falsch, das richtige Wort als Lösung.";
      }
    }();

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "gpt-4.1-nano",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": prompt.toString()},
        ],
        "max_tokens": 512,
        "temperature": 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      final String content = data['choices'][0]['message']['content'];
      // Extrahiere Rückmeldungen aus der nummerierten Liste
      final lines =
          content
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty && RegExp(r'^\d+[\.\)]\s').hasMatch(l))
              .toList();
      List<String> feedback = [];
      for (final line in lines) {
        feedback.add(line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim());
      }
      // Fallback: Falls keine nummerierten Zeilen gefunden wurden, nimm alle nicht-leeren Zeilen
      if (feedback.isEmpty) {
        return content.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      }
      return feedback;
    } else {
      throw Exception('KI-Korrektur konnte nicht geladen werden: ${response.body}');
    }
  }
}
