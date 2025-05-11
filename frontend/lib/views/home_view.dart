import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/util/ki_service.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/background_image.dart';
import 'package:frontend/views/widgets/content_section.dart';
import 'package:frontend/views/widgets/fach_sidebar.dart';
import 'package:frontend/views/widgets/footer_section.dart';
import 'package:frontend/views/widgets/header_section.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const background = Colors.black;
    const cardColor = Color(0xFF16203A);
    const accent = Color(0xFF2196F3);
    const fadedText = Color(0xFF90A4AE);
    const greetingColor = Color(0xFF42A5F5);

    // Initialisiere KI-Service, falls noch nicht geschehen
    final vm = ref.read(homeViewModelProvider.notifier);
    if (vm.kiService == null) {
      vm.setKIService(KIService());
      // Begrüßungstext wird automatisch im ViewModel-Konstruktor geladen
    }

    final state = ref.watch(homeViewModelProvider);

    // Hilfsvariablen
    final selectedSubjects = state.user.selectedSubjects;
    final activeSubject = state.activeSubject ?? (selectedSubjects.isNotEmpty ? selectedSubjects.first : null);
    final aufgabenbereiche =
        activeSubject != null ? vm.getAufgabenbereiche(activeSubject, state.user.selectedClass) : <String>[];
    final selectedTopic = state.selectedTopic;
    final showTasks = state.showTasks == true;
    final results = activeSubject != null ? vm.getResultsForSubject(activeSubject) : [];

    // Testmodus und Sperrstatus aus dem State
    final testLocked = state.testLocked;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Hintergrundbild
          const BackgroundImage(),

          // Hauptinhalt
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header-Sektion
                        HeaderSection(
                          accent: accent,
                          greetingColor: greetingColor,
                          fadedText: fadedText,
                          greeting: state.greeting,
                          refreshGreeting: () => vm.refreshGreeting(),
                          resetAll: () => vm.resetAll(),
                          activeSubject: activeSubject ?? '',
                        ),

                        const SizedBox(height: 20),

                        // Hauptbereich: Sidebar + Content
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sidebar
                            FachSidebar(
                              subjects: HomeViewModel.subjects,
                              selectedSubjects: selectedSubjects,
                              activeSubject: state.activeSubject,
                              accent: accent,
                              fadedText: fadedText,
                              onToggle: (subject) {
                                // Immer alles zurücksetzen beim Fachwechsel UND Testmodus entsperren
                                vm.toggleSubject(subject);
                                vm.setTestLocked(false);
                              },
                            ),

                            const SizedBox(width: 32),

                            // Mittlere Box: Content-Bereich
                            Flexible(
                              child: ContentSection(
                                accent: accent,
                                cardColor: cardColor,
                                greetingColor: greetingColor,
                                fadedText: fadedText,
                                activeSubject: activeSubject,
                                selectedTopic: selectedTopic,
                                aufgabenbereiche: aufgabenbereiche,
                                showTasks: showTasks,
                                testLocked: testLocked,
                                results: results,
                              ),
                            ),
                          ],
                        ),

                        // Footer-Bereich
                        const SizedBox(height: 30),
                        const FooterSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
