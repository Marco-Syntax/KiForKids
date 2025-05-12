import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  // Hilfsfunktion zum Öffnen von URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Konnte URL nicht öffnen: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.grey, thickness: 0.3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  _launchUrl("https://marcogrimme.de");
                },
                child: const Text(
                  "© 2025 KiForKids - Interaktive Lernplattform für Kinder\nEntwickelt von Marco Grimme – Inspiriert von Jonas Grimme – KI-generierte Aufgaben",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12, decoration: TextDecoration.underline),
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
                      style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _launchUrl('/agb.html');
                    },
                    child: const Text(
                      "AGB",
                      style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _launchUrl('/impressum.html');
                    },
                    child: const Text(
                      "Impressum",
                      style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
