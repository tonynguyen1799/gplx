import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizShortcut extends StatelessWidget {
  final Quiz quiz;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry contentPadding;
  final Color tileColor;
  final int totalQuizzes;
  final int originalIndex;
  final bool practiced;

  const QuizShortcut({
    Key? key,
    required this.quiz,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.totalQuizzes,
    required this.originalIndex,
    required this.practiced,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.tileColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: selected ? BoxDecoration(
        color: Colors.blue.shade100,
      ) : null,
      child: ListTile(
        onTap: onTap,
        contentPadding: contentPadding,
        tileColor: selected ? Colors.transparent : tileColor,
      title: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Câu ${index + 1}/${totalQuizzes} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '[${quiz.licenseTypeCode}.${originalIndex + 1}]',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (practiced) ...[
                  TextSpan(
                    text: ' | ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: 'đã học',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (practiced) ...[
            SizedBox(width: 4),
            Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ],
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
                  height: 60,
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
      selectedTileColor: Colors.blue,
      ),
    );
  }
} 