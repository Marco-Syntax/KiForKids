import 'package:flutter/material.dart';

class ErgebnisDialog extends StatelessWidget {
  final String activeSubject;
  final Color accent;
  final Color fadedText;
  final List<Map<String, dynamic>> data;

  const ErgebnisDialog({
    required this.activeSubject,
    required this.accent,
    required this.fadedText,
    required this.data,
    super.key,
  });

  /// Hilfsfunktion: Ersetzt typische Encoding-Fehler für deutsche Umlaute.
  String fixUmlauts(String input) {
    return input
        .replaceAll('Ã¤', 'ä')
        .replaceAll('Ã¶', 'ö')
        .replaceAll('Ã¼', 'ü')
        .replaceAll('Ã', 'ß')
        .replaceAll('Ã„', 'Ä')
        .replaceAll('Ã–', 'Ö')
        .replaceAll('Ãœ', 'Ü')
        .replaceAll('â€“', '–')
        .replaceAll('â€œ', '„')
        .replaceAll('â€', '“')
        .replaceAll('â€ž', '„')
        .replaceAll('â€˜', '‚')
        .replaceAll('â€™', '’')
        .replaceAll('â€', '”')
        .replaceAll('Â', '');
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF16203A);
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ergebnisse für $activeSubject",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: accent,
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 18),
            if (data.isEmpty)
              const Text(
                "Keine gespeicherten Ergebnisse gefunden.",
                style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Roboto'),
              )
            else
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        data.reversed.map((entry) {
                          return Card(
                            color: cardColor.withValues(alpha: 0.95),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            margin: const EdgeInsets.only(bottom: 18),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fixUmlauts("${entry['topic']} (${entry['timestamp'].toString().substring(0, 16)})"),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    (entry['questions'] as List).length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${i + 1}. ", style: TextStyle(color: fadedText, fontFamily: 'Roboto')),
                                          Expanded(
                                            child: Text(
                                              fixUmlauts(entry['questions'][i]),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...List.generate((entry['userAnswers'] as List).length, (i) {
                                    final answer = fixUmlauts(entry['userAnswers'][i]);
                                    final feedback = fixUmlauts(entry['feedback'][i]);
                                    final isCorrect = feedback.toLowerCase().startsWith('richtig');
                                    String? correct;
                                    if (!isCorrect) {
                                      final match = RegExp(r'richtige[r]? Lösung: (.+?)\)?$').firstMatch(feedback);
                                      correct = match?.group(1);
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 24, bottom: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isCorrect ? Icons.check_circle : Icons.cancel,
                                            color: isCorrect ? Colors.green : Colors.red,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            answer,
                                            style: TextStyle(
                                              color: isCorrect ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          if (!isCorrect && correct != null) ...[
                                            const SizedBox(width: 10),
                                            Text(
                                              "→ ",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            Text(
                                              correct,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Roboto'),
                ),
                child: const Text("Schließen"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
