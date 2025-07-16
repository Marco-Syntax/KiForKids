import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/view_models/home_view_model.dart';
import 'package:frontend/views/widgets/answer_button.dart';

class TestTrueFalse extends ConsumerStatefulWidget {
  final List<String> tasks;
  final Color accent;
  final Color cardColor;
  final VoidCallback onTestFinished;

  const TestTrueFalse({
    super.key,
    required this.tasks,
    required this.accent,
    required this.cardColor,
    required this.onTestFinished,
  });

  @override
  ConsumerState<TestTrueFalse> createState() => _TestTrueFalseState();
}

class _TestTrueFalseState extends ConsumerState<TestTrueFalse> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _resultController;
  late AnimationController _navigationController;
  late Animation<double> _headerSlide;
  late Animation<double> _cardSlide;
  late Animation<double> _resultBounce;
  late Animation<double> _cardFade;
  final ScrollController scrollController = ScrollController();

  int currentCardIndex = 0;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _cardController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _resultController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _navigationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _headerSlide = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.elasticOut));

    _cardSlide = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    _cardFade = Tween<double>(begin: 0, end: 1).animate(_cardController);

    _resultBounce = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _resultController, curve: Curves.elasticOut));

    _headerController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _resultController.dispose();
    _navigationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _navigateToCard(int index) {
    if (index >= 0 && index < widget.tasks.length) {
      _cardController.reverse().then((_) {
        setState(() {
          currentCardIndex = index;
        });
        _cardController.forward();
      });
    }
  }

  void _nextCard() {
    if (currentCardIndex < widget.tasks.length - 1) {
      _navigateToCard(currentCardIndex + 1);
    }
  }

  void _previousCard() {
    if (currentCardIndex > 0) {
      _navigateToCard(currentCardIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeState.currentTestTasks.isEmpty || homeState.currentTestTasks.length != widget.tasks.length) {
        homeViewModel.initTest(widget.tasks);
      }

      if (homeState.showTestResult && scrollController.hasClients) {
        _resultController.forward();
        scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });

    final bool showResult = homeState.showTestResult;
    final bool isChecking = homeState.isCheckingTest;
    final bool canContinue = homeState.canContinueTest;
    final List<bool> isCorrect = homeState.testIsCorrect;
    final List<String> feedback = homeState.testFeedback;
    final List<String?> answers = homeState.trueFalseAnswers;

    final bool hasEnoughAnswers = answers.length >= widget.tasks.length;
    final bool allAnswered = hasEnoughAnswers && answers.take(widget.tasks.length).every((answer) => answer != null);

    final correctColor = Colors.green.shade400;
    final wrongColor = Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.accent.withOpacity(0.05), widget.accent.withOpacity(0.02), Colors.transparent],
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animierter Header mit Glasmorphismus
            AnimatedBuilder(
              animation: _headerSlide,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlide.value),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.accent.withOpacity(0.15), widget.accent.withOpacity(0.08)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                      boxShadow: [
                        BoxShadow(color: widget.accent.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [widget.accent, widget.accent.withOpacity(0.7)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accent.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback:
                                    (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                                    ).createShader(bounds),
                                child: const Text(
                                  'Richtig oder Falsch?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Frage ${currentCardIndex + 1} von ${widget.tasks.length}',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        if (!showResult)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.psychology_rounded, size: 16, color: widget.accent),
                                const SizedBox(width: 6),
                                Text(
                                  '${answers.where((a) => a != null).length}/${widget.tasks.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Fortschrittsbalken
            if (!showResult)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Lineare Fortschrittsanzeige
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LinearProgressIndicator(
                        value: (currentCardIndex + 1) / widget.tasks.length,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Punkte-Indikator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.tasks.length, (index) {
                        bool isAnswered = answers.length > index && answers[index] != null;
                        bool isCurrent = index == currentCardIndex;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isCurrent ? 12 : 8,
                          height: isCurrent ? 12 : 8,
                          decoration: BoxDecoration(
                            color:
                                isAnswered
                                    ? widget.accent
                                    : isCurrent
                                    ? widget.accent.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow:
                                isCurrent
                                    ? [
                                      BoxShadow(
                                        color: widget.accent.withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

            // Ergebnisanzeige mit Hero-Animation
            if (showResult)
              AnimatedBuilder(
                animation: _resultBounce,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _resultBounce.value,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              isCorrect.every((v) => v)
                                  ? [correctColor.withOpacity(0.2), correctColor.withOpacity(0.1)]
                                  : [widget.accent.withOpacity(0.2), widget.accent.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isCorrect.every((v) => v)
                                  ? correctColor.withOpacity(0.4)
                                  : widget.accent.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCorrect.every((v) => v) ? correctColor : widget.accent).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        isCorrect.every((v) => v)
                                            ? [correctColor, correctColor.withOpacity(0.7)]
                                            : [widget.accent, widget.accent.withOpacity(0.7)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isCorrect.every((v) => v) ? correctColor : widget.accent).withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isCorrect.every((v) => v) ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback:
                                          (bounds) => LinearGradient(
                                            colors: [Colors.white, Colors.white.withOpacity(0.9)],
                                          ).createShader(bounds),
                                      child: Text(
                                        isCorrect.every((v) => v) ? "🎉 Perfekt!" : "💪 Gut gemacht!",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isCorrect.every((v) => v)
                                          ? "Du bist ein wahres Genie! Alle Antworten richtig! 🚀"
                                          : "Du hast ${isCorrect.where((v) => v).length} von ${isCorrect.length} Fragen richtig! 🎯",
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (canContinue)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                                      label: const Text("Beenden"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {
                                        homeViewModel.finishTest(widget.onTestFinished);
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [widget.accent, widget.accent.withOpacity(0.8)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.accent.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: FilledButton.icon(
                                        icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                                        label: const Text("Weiter"),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        onPressed: () => homeViewModel.continueTest(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Aktuelle Aufgaben-Card (nur eine zur Zeit)
            if (!showResult)
              AnimatedBuilder(
                animation: _cardController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_cardSlide.value, 0),
                    child: Opacity(
                      opacity: _cardFade.value,
                      child: _buildTaskCard(
                        currentCardIndex,
                        answers,
                        isCorrect,
                        feedback,
                        showResult,
                        correctColor,
                        wrongColor,
                        homeViewModel,
                      ),
                    ),
                  );
                },
              ),

            // Navigation Buttons
            if (!showResult && !isChecking)
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  children: [
                    // Zurück Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                        label: const Text("Zurück"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: currentCardIndex > 0 ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                            width: 2,
                          ),
                          foregroundColor: currentCardIndex > 0 ? Colors.white : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: currentCardIndex > 0 ? _previousCard : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Weiter Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient:
                              currentCardIndex < widget.tasks.length - 1
                                  ? LinearGradient(colors: [widget.accent, widget.accent.withOpacity(0.8)])
                                  : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade700]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              currentCardIndex < widget.tasks.length - 1
                                  ? [
                                    BoxShadow(
                                      color: widget.accent.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          label: const Text("Weiter"),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: currentCardIndex < widget.tasks.length - 1 ? _nextCard : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Animierte Lade-Anzeige
            if (isChecking)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [widget.accent.withOpacity(0.15), widget.accent.withOpacity(0.08)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [Colors.white, Colors.white.withOpacity(0.8)],
                          ).createShader(bounds),
                      child: const Text(
                        "🤖 KI analysiert deine Antworten...",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

            // Futuristischer Submit-Button
            if (!showResult && !isChecking)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        allAnswered
                            ? LinearGradient(colors: [widget.accent, widget.accent.withOpacity(0.8)])
                            : LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade600]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        allAnswered
                            ? [
                              BoxShadow(
                                color: widget.accent.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                            : [],
                  ),
                  child: FilledButton.icon(
                    icon: Icon(allAnswered ? Icons.auto_awesome_rounded : Icons.pending_actions_rounded, size: 20),
                    label: Text(
                      allAnswered ? "🚀 Antworten prüfen!" : "⏳ Alle Fragen beantworten",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: allAnswered ? () => homeViewModel.checkTestAnswers() : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    int i,
    List<String?> answers,
    List<bool> isCorrect,
    List<String> feedback,
    bool showResult,
    Color correctColor,
    Color wrongColor,
    homeViewModel,
  ) {
    final bool hasAnswer = answers.length > i && answers[i] != null;

    Color borderColor = widget.accent.withOpacity(0.2);
    List<Color> gradientColors = [widget.cardColor.withOpacity(0.9), widget.cardColor.withOpacity(0.7)];
    IconData statusIcon = Icons.help_outline_rounded;
    Color iconColor = widget.accent.withOpacity(0.7);

    if (showResult && isCorrect.length > i) {
      if (isCorrect[i]) {
        borderColor = correctColor.withOpacity(0.6);
        gradientColors = [correctColor.withOpacity(0.1), correctColor.withOpacity(0.05)];
        statusIcon = Icons.check_circle_rounded;
        iconColor = correctColor;
      } else {
        borderColor = wrongColor.withOpacity(0.6);
        gradientColors = [wrongColor.withOpacity(0.1), wrongColor.withOpacity(0.05)];
        statusIcon = Icons.cancel_rounded;
        iconColor = wrongColor;
      }
    } else if (hasAnswer) {
      borderColor = widget.accent.withOpacity(0.5);
      gradientColors = [widget.accent.withOpacity(0.08), widget.accent.withOpacity(0.04)];
      statusIcon = Icons.check_circle_outline_rounded;
      iconColor = widget.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header mit Frage
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor.withOpacity(0.3)),
                  ),
                  child: Icon(statusIcon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.tasks[i],
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
                if (showResult && isCorrect.length > i)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isCorrect[i] ? correctColor : wrongColor).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect[i] ? Icons.star_rounded : Icons.close_rounded,
                      color: isCorrect[i] ? correctColor : wrongColor,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),

          // Answer Buttons Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: widget.cardColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnswerButton(
                    label: "RICHTIG",
                    icon: Icons.check_rounded,
                    isSelected: hasAnswer && answers[i] == "richtig",
                    isCorrect:
                        showResult &&
                        isCorrect.length > i &&
                        ((answers[i] == "richtig" && isCorrect[i]) ||
                            (answers[i] != "richtig" &&
                                !isCorrect[i] &&
                                feedback.length > i &&
                                feedback[i].contains("richtig"))),
                    accent: widget.accent,
                    correctColor: correctColor,
                    wrongColor: wrongColor,
                    showResult: showResult,
                    onPressed: showResult ? null : () => homeViewModel.setTrueFalseAnswer(i, "richtig"),
                  ),
                ),
                Container(width: 1, color: Colors.white.withOpacity(0.1), height: 48),
                Expanded(
                  child: AnswerButton(
                    label: "FALSCH",
                    icon: Icons.close_rounded,
                    isSelected: hasAnswer && answers[i] == "falsch",
                    isCorrect:
                        showResult &&
                        isCorrect.length > i &&
                        ((answers[i] == "falsch" && isCorrect[i]) ||
                            (answers[i] != "falsch" &&
                                !isCorrect[i] &&
                                feedback.length > i &&
                                feedback[i].contains("falsch"))),
                    accent: widget.accent,
                    correctColor: correctColor,
                    wrongColor: wrongColor,
                    showResult: showResult,
                    onPressed: showResult ? null : () => homeViewModel.setTrueFalseAnswer(i, "falsch"),
                  ),
                ),
              ],
            ),
          ),

          // Feedback
          if (showResult && feedback.length > i)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      (isCorrect.length > i && isCorrect[i])
                          ? [correctColor.withOpacity(0.15), correctColor.withOpacity(0.08)]
                          : [wrongColor.withOpacity(0.15), wrongColor.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      (isCorrect.length > i && isCorrect[i])
                          ? correctColor.withOpacity(0.4)
                          : wrongColor.withOpacity(0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: (isCorrect.length > i && isCorrect[i]) ? correctColor : wrongColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feedback[i],
                      style: TextStyle(
                        color: (isCorrect.length > i && isCorrect[i]) ? correctColor : wrongColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
