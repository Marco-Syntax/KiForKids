/// Widget für Aufgaben mit Freitext-Eingabe.
/// Prüft Antworten per KI und zeigt Feedback an.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/home_view_model.dart';

class TestInput extends ConsumerStatefulWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;
  final VoidCallback onTestFinished;

  const TestInput({
    super.key,
    required this.tasks,
    required this.accent,
    required this.cardColor,
    required this.onTestFinished,
  });

  @override
  ConsumerState<TestInput> createState() => _TestInputState();
}

class _TestInputState extends ConsumerState<TestInput> {
  late List<TextEditingController> _controllers;
  bool _showResult = false;
  late List<bool> _isCorrect;
  List<String> _feedback = [];
  bool _isChecking = false;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(homeViewModelProvider.notifier);
    _controllers = vm.createControllers(widget.tasks.length);
    _isCorrect = List.generate(widget.tasks.length, (_) => false);
    _feedback = List.generate(widget.tasks.length, (_) => "");
    _canContinue = false;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TestInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks.length != widget.tasks.length) {
      final vm = ref.read(homeViewModelProvider.notifier);
      _controllers = vm.createControllers(widget.tasks.length);
      _isCorrect = List.generate(widget.tasks.length, (_) => false);
      _feedback = List.generate(widget.tasks.length, (_) => "");
      _showResult = false;
      _canContinue = false;
      setState(() {});
    }
  }

  bool _allFilled() => _controllers.every((c) => c.text.trim().isNotEmpty);

  Future<void> _checkAnswers() async {
    setState(() {
      _showResult = false;
      _isChecking = true;
      _canContinue = false;
    });
    final vm = ref.read(homeViewModelProvider.notifier);
    final generatedTasks = ref.read(homeViewModelProvider).generatedTasks ?? [];
    final answers = _controllers.map((c) => c.text.trim()).toList();
    final feedback =
        vm.kiService?.checkAnswers(generatedTasks: generatedTasks, userAnswers: answers) ??
        List.generate(widget.tasks.length, (_) => "Keine Lösung vorhanden.");
    setState(() {
      _feedback = feedback;
      _isCorrect = feedback.map((f) => f.toLowerCase().startsWith('richtig')).toList();
      _showResult = true;
      _isChecking = false;
      _canContinue = true;
    });
  }

  Future<void> _onContinue() async {
    final vm = ref.read(homeViewModelProvider.notifier);
    final state = ref.read(homeViewModelProvider);
    final subject = state.user.selectedSubjects.isNotEmpty ? state.user.selectedSubjects.first : '';
    final topic = state.selectedTopic ?? '';
    final level = state.user.selectedLevel;

    setState(() {
      _showResult = false;
      _canContinue = false;
      final vm = ref.read(homeViewModelProvider.notifier);
      _controllers = vm.createControllers(widget.tasks.length);
      _isCorrect = List.generate(widget.tasks.length, (_) => false);
      _feedback = List.generate(widget.tasks.length, (_) => "");
      _isChecking = true;
    });

    await vm.generateTasksWithKI(subject: subject, topic: topic, level: level, count: 5);

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _onFinish() async {
    ref.read(homeViewModelProvider.notifier).resetAll();
    widget.onTestFinished();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enableButton = _allFilled() && !_isChecking && !_showResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fragen:', style: TextStyle(fontWeight: FontWeight.bold, color: widget.accent, fontSize: 22)),
        const SizedBox(height: 18),
        ...List.generate(widget.tasks.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: widget.cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.accent.withOpacity(0.18)),
              boxShadow: [BoxShadow(color: widget.accent.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: widget.accent, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.tasks[i],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _controllers[i],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deine Antwort',
                      labelStyle: TextStyle(color: widget.accent, fontWeight: FontWeight.w400),
                      filled: true,
                      fillColor: widget.cardColor.withOpacity(0.85),
                      hintText: 'Antwort eingeben...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent.withOpacity(0.18)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_showResult)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Icon(
                      _isCorrect[i] ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect[i] ? Colors.green : Colors.red,
                      size: 26,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (_isChecking)
          const Padding(
            padding: EdgeInsets.only(left: 60, bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text("Antworten werden geprüft...", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        if (_showResult)
          ...List.generate(widget.tasks.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(left: 60, bottom: 8),
              child: Text(
                _feedback[i],
                style: TextStyle(
                  color: _isCorrect[i] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            );
          }),
        if (!_showResult && enableButton)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Ergebnisse anzeigen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _checkAnswers,
            ),
          ),
        if (_showResult)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _isCorrect.every((v) => v)
                  ? "Super, alle Fragen richtig beantwortet!"
                  : "Bitte überprüfe deine Antworten.",
              style: TextStyle(
                color: _isCorrect.every((v) => v) ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        if (_showResult && _canContinue)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Weiter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _onContinue,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Beenden"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _onFinish,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
