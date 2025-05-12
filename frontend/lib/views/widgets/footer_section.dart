import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
// Für Web: html importieren
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  // Hilfsfunktion zum Öffnen von URLs (Web/Native)
  Future<void> _launchUrl(String urlString, {bool external = false}) async {
    final isWeb = kIsWeb;
    if (isWeb && !external) {
      // Interne Links im selben Tab öffnen
      html.window.location.assign(urlString);
      return;
    }
    final Uri url = Uri.parse(urlString);
    final mode = external ? LaunchMode.externalApplication : LaunchMode.platformDefault;
    if (!await launchUrl(url, mode: mode)) {
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
              const Text(
                "© 2025 KiForKids - Interaktive Lernplattform für Kinder",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  _launchUrl("https://marcogrimme.de", external: true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontSize: 12, decoration: TextDecoration.underline),
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                ).copyWith(
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.blueAccent.withValues(alpha: 0.16);
                    }
                    return null;
                  }),
                ),
                child: const Text(
                  "Entwickelt von Marco Grimme – Inspiriert von Jonas Grimme – KI-generierte Aufgaben",
                  textAlign: TextAlign.center,
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blueAccent.withValues(alpha: 0.16);
                        }
                        return null;
                      }),
                    ),
                    child: const Text(
                      "Datenschutz",
                      style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _launchUrl('/agb.html');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blueAccent.withValues(alpha: 0.16);
                        }
                        return null;
                      }),
                    ),
                    child: const Text(
                      "AGB",
                      style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _launchUrl('/impressum.html');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blueAccent.withValues(alpha: 0.16);
                        }
                        return null;
                      }),
                    ),
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
