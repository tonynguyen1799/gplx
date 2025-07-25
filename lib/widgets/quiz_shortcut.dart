import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizShortcut extends StatelessWidget {
  final Quiz quiz;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry contentPadding;
  final Color tileColor;

  const QuizShortcut({
    Key? key,
    required this.quiz,
    required this.index,
    required this.selected,
    required this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.tileColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: contentPadding,
      tileColor: tileColor,
      title: Text(
        'Câu ${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  quiz.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: Image.asset(
                    'assets/images/' + quiz.imageUrl!,
                    fit: BoxFit.fitHeight, // Height is fixed, width scales with aspect ratio
                  ),
                ),
            ],
          ),
          if (quiz.topicIds.any((id) => id.endsWith('-fatal')))
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                'Câu điểm liệt',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      trailing: null,
      selected: selected,
      selectedTileColor: Colors.blue.shade50,
    );
  }
} 