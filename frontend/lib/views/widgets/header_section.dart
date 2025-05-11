import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/ergebnis_dialog.dart';

class HeaderSection extends ConsumerWidget {
  final Color accent;
  final Color greetingColor;
  final Color fadedText;
  final String greeting;
  final Function refreshGreeting;
  final Function resetAll;
  final String activeSubject;

  const HeaderSection({
    super.key,
    required this.accent,
    required this.greetingColor,
    required this.fadedText,
    required this.greeting,
    required this.refreshGreeting,
    required this.resetAll,
    required this.activeSubject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(homeViewModelProvider.notifier);

    return Stack(
      children: [
        // Logo/Maskottchen links-oben im Header
        Positioned(left: 0, top: 0, child: _buildAvatarSection(accent)),

        // Zentrierter Header-Inhalt
        Align(alignment: Alignment.center, child: _buildCenterContent(accent, fadedText)),

        // Ergebnis-Button oben rechts mit Proxy-Bild
        Positioned(
          right: 0,
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ergebnis-Button
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
                  if (activeSubject.isEmpty) return;
                  try {
                    final data = await vm.getResultsFromBackend(activeSubject);
                    if (!context.mounted) return;
                    showDialog(
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
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Fehler"),
                            content: Text("Fehler beim Laden der Ergebnisse: $e"),
                            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))],
                          ),
                    );
                  }
                },
              ),
              // Proxy-Bild unter dem Ergebnis-Button
              Transform.translate(
                offset: const Offset(-100, 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Image.asset('assets/images/proxy.png', width: 280, height: 280, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar/Maskottchen mit Punktestand
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16203A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withAlpha(51)),
          ),
          child: Row(
            children: [
              // Maskottchen/Avatar Image
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: accent.withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2),
                ),
                child: Icon(Icons.emoji_emotions_rounded, color: accent, size: 35),
              ),
              const SizedBox(width: 12),
              // Name und Punkte
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Willkommen Punktejäger!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  // Punktestand mit Animation
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '0 Punkte', // Wird dynamisch aktualisiert
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tipp des Tages
        Container(
          width: 200,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withAlpha(200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '✨ Tipp des Tages:',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Mache regelmäßig Pausen beim Lernen, um besser zu verstehen!',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent(Color accent, Color fadedText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/bg_3.png', height: 200, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(
          "Finde spannende Aufgaben für jede Klassenstufe",
          style: TextStyle(color: fadedText, fontSize: 18, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _buildSelectors(accent),
      ],
    );
  }

  Widget _buildSelectors(Color accent) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(homeViewModelProvider);
        final vm = ref.read(homeViewModelProvider.notifier);

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Klassen-Dropdown
                _buildDropdown(
                  value: state.user.selectedClass,
                  items: HomeViewModel.classes,
                  onChanged: (value) {
                    if (value != null) vm.selectClass(value);
                  },
                  accent: accent,
                ),
                const SizedBox(width: 18),
                // Level-Dropdown
                _buildDropdown(
                  value: state.user.selectedLevel,
                  items: HomeViewModel.levels,
                  onChanged: (value) {
                    if (value != null) vm.selectLevel(value);
                  },
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Testmodus-Auswahl-Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTestModeButton(
                  mode: "bool",
                  label: "Richtig/Falsch",
                  current: state.testMode,
                  locked: state.testLocked,
                  accent: accent,
                ),
                const SizedBox(width: 16),
                _buildTestModeButton(
                  mode: "input",
                  label: "Eingabe-Test",
                  current: state.testMode,
                  locked: state.testLocked,
                  accent: accent,
                ),
                const SizedBox(width: 16),
                _buildTestModeButton(
                  mode: "mc",
                  label: "Multiple Choice",
                  current: state.testMode,
                  locked: state.testLocked,
                  accent: accent,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF16203A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withAlpha(38)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF16203A),
          iconEnabledColor: accent,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTestModeButton({
    required String mode,
    required String label,
    required String current,
    required bool locked,
    required Color accent,
  }) {
    // Zugriff auf Methoden

    return Consumer(
      builder: (context, ref, child) {
        final vm = ref.read(homeViewModelProvider.notifier);

        return ElevatedButton(
          onPressed: locked ? null : () => vm.setTestMode(mode),
          style: ElevatedButton.styleFrom(
            backgroundColor: current == mode ? accent : const Color(0xFF16203A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(label),
        );
      },
    );
  }
}
