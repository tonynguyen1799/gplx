import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/riverpod/data/tip.dart';
import '../providers/app_data_providers.dart';
import '../utils/app_colors.dart';
import 'package:flutter_html/flutter_html.dart';

class TipsScreen extends ConsumerWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncTips = ref.watch(tipsProvider);

    return asyncTips.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Mẹo thi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: theme.appBarBackground,
          foregroundColor: theme.appBarText,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(
          title: const Text('Mẹo thi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: theme.appBarBackground,
          foregroundColor: theme.appBarText,
          elevation: 0,
        ),
        body: Center(child: Text('Lỗi khi tải dữ liệu: $e')),
      ),
      data: (tips) => _TipsScreenContent(tips: tips, theme: theme),
    );
  }
}

class _TipsScreenContent extends StatefulWidget {
  final Tips tips;
  final ThemeData theme;

  const _TipsScreenContent({required this.tips, required this.theme});

  @override
  State<_TipsScreenContent> createState() => _TipsScreenContentState();
}

class _TipsScreenContentState extends State<_TipsScreenContent> {
  final Map<String, bool> _expandedTopics = {};

  void _toggleTopic(String topicId) {
    setState(() {
      _expandedTopics[topicId] = !(_expandedTopics[topicId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final tips = widget.tips;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mẹo thi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.appBarText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarText,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.brightness == Brightness.dark
                          ? [
                              Colors.blue.withValues(alpha: 0.3),
                              Colors.blue.withValues(alpha: 0.15),
                            ]
                          : [
                              theme.primaryColor.withValues(alpha: 0.1),
                              theme.primaryColor.withValues(alpha: 0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.blue.withValues(alpha: 0.4)
                              : theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: theme.brightness == Brightness.dark
                              ? Colors.blue[100]!
                              : theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mẹo thi hiệu quả',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Học thuộc các mẹo này để tăng khả năng đỗ thi',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Topics list
                ...tips.examTips.map((topic) => _buildTopicCard(topic, theme)),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildTopicCard(TipTopic topic, ThemeData theme) {
    final isExpanded = _expandedTopics[topic.topicId] ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleTopic(topic.topicId),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTopicColor(topic.topicId, theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTopicIcon(topic.topicId),
                      color: _getTopicColor(topic.topicId, theme),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.topicName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topic.topicDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Column(
                children: topic.tips.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tip = entry.value;
                  return _buildTipTile(tip, theme, index);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipTile(Tip tip, ThemeData theme, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.blue.withValues(alpha: 0.3)
                      : theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Mẹo ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.blue[100]!
                        : theme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              if (tip.relatedQuestions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.orange.withValues(alpha: 0.3)
                        : theme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 12,
                        color: theme.brightness == Brightness.dark
                            ? Colors.orange[100]!
                            : theme.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tip.relatedQuestions.length} câu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.brightness == Brightness.dark
                              ? Colors.orange[100]!
                              : theme.warningColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip.tipTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Html(
            data: tip.tipContent,
            style: {
              "body": Style(
                fontSize: FontSize(15),
                color: theme.primaryText,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                lineHeight: LineHeight(1.5),
              ),
              "b": Style(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.blue[100]!
                    : theme.primaryColor,
              ),
              "br": Style(
                margin: Margins.zero,
              ),
            },
          ),
          if (tip.relatedQuestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 14,
                  color: theme.warningColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Câu hỏi liên quan: ${tip.relatedQuestions.join(", ")}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.warningColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTopicColor(String topicId, ThemeData theme) {
    switch (topicId) {
      case 'critical_questions':
        return theme.brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.8) : Colors.red;
      case 'keyword_tricks':
        return theme.brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.8) : Colors.blue;
      case 'traffic_scenarios':
        return theme.brightness == Brightness.dark ? Colors.green.withValues(alpha: 0.8) : Colors.green;
      case 'traffic_signs':
        return theme.brightness == Brightness.dark ? Colors.orange.withValues(alpha: 0.8) : Colors.orange;
      case 'numbers_tricks':
        return theme.brightness == Brightness.dark ? Colors.purple.withValues(alpha: 0.8) : Colors.purple;
      case 'driving_techniques':
        return theme.brightness == Brightness.dark ? Colors.teal.withValues(alpha: 0.8) : Colors.teal;
      case 'structure_repair':
        return theme.brightness == Brightness.dark ? Colors.indigo.withValues(alpha: 0.8) : Colors.indigo;
      default:
        return theme.brightness == Brightness.dark ? Colors.purple.withValues(alpha: 0.8) : Colors.purple;
    }
  }

  IconData _getTopicIcon(String topicId) {
    switch (topicId) {
      case 'critical_questions':
        return Icons.warning;
      case 'keyword_tricks':
        return Icons.psychology;
      case 'traffic_scenarios':
        return Icons.map;
      case 'traffic_signs':
        return Icons.signpost;
      case 'numbers_tricks':
        return Icons.calculate;
      case 'driving_techniques':
        return Icons.drive_eta;
      case 'structure_repair':
        return Icons.build;
      default:
        return Icons.lightbulb_outline;
    }
  }
} 