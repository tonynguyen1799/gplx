import 'package:flutter/material.dart';
import '../models/riverpod/data/quiz.dart';
import '../models/hive/quiz_progress.dart';
import '../constants/ui_constants.dart';
import 'quiz_content.dart';
import 'answer_options.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  final QuizProgress? progress;
  final int quizIndex;
  final int totalQuizzes;
  final int? selectedIdx;
  final bool isViewed;
  final bool lockAnswer;
  final void Function(int)? onAnswer;

  const QuizPage({
    super.key,
    required this.quiz,
    required this.progress,
    required this.quizIndex,
    required this.totalQuizzes,
    this.selectedIdx,
    this.isViewed = false,
    this.lockAnswer = false,
    this.onAnswer,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: SECTION_SPACING),
          QuizContent(
            quiz: widget.quiz,
            quizIndex: widget.quizIndex,
            totalQuizzes: widget.totalQuizzes,
            quizProgress: widget.progress,
          ),
          const SizedBox(height: SECTION_SPACING),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: SUB_SECTION_SPACING),
          AnswerOptions(
            key: ValueKey(widget.quiz.id),
            quiz: widget.quiz,
            selectedIdx: widget.selectedIdx,
            isViewed: widget.isViewed,
            lockAnswer: widget.lockAnswer,
            onSelect: widget.onAnswer,
          ),
          const SizedBox(height: SECTION_SPACING),
        ],
      ),
    );
  }
}
