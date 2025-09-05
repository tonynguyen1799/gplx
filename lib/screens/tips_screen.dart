import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gplx_vn/constants/ui_constants.dart';
import '../models/riverpod/data/tip.dart';
import '../providers/app_data_providers.dart';
import '../constants/app_colors.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  final Map<String, bool> _expandedTopics = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipsAsync = ref.watch(tipsProvider);

    return tipsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
      data: (tips) => _buildContent(tips, theme),
    );
  }

  Widget _buildContent(Tips tips, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: NAVIGATION_HEIGHT,
        title: Text(
          'Mẹo thi',
          style: const TextStyle(
            fontSize: APP_BAR_FONT_SIZE,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CONTENT_PADDING),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.BLUE_COLOR.withValues(alpha: 0.2),
                  theme.BLUE_COLOR.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(height: SECTION_SPACING),
                Container(
                  padding: const EdgeInsets.all(CONTENT_PADDING),
                  decoration: BoxDecoration(
                    color: theme.BLUE_COLOR.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(BORDER_RADIUS),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: theme.BLUE_COLOR,
                  ),
                ),
                const SizedBox(width: SECTION_SPACING),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mẹo thi hiệu quả',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: SUB_SECTION_SPACING),
                      Text(
                        'Học thuộc các mẹo này để tăng khả năng đỗ thi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...tips.examTips.map((topic) => _buildTopicTips(topic, theme)).toList(),
          const SizedBox(height: SECTION_SPACING),
        ],
      ),
    );
  }

  Widget _buildTopicTips(TipTopic topic, ThemeData theme) {
    final isExpanded = _expandedTopics[topic.topicId] ?? false;
    
    return Container(
      child: Column(
        children: [
          const SizedBox(height: SECTION_SPACING),
          Container(
            decoration: BoxDecoration(
              color: theme.SURFACE_VARIANT,
            ),
            child: InkWell(
              onTap: () => _toggleTopic(topic.topicId),
              child: Padding(
                padding: const EdgeInsets.all(CONTENT_PADDING),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(CONTENT_PADDING),
                      decoration: BoxDecoration(
                        color: _getTopicColor(topic.topicId, theme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      ),
                      child: Icon(
                        _getTopicIcon(topic.topicId),
                        color: _getTopicColor(topic.topicId, theme),
                      ),
                    ),
                    const SizedBox(width: SECTION_SPACING),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.topicName,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: SUB_SECTION_SPACING),
                          Text(
                            topic.topicDescription,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING / 2, vertical: SUB_SECTION_SPACING),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? theme.BLUE_COLOR.withValues(alpha: 0.4) : theme.BLUE_COLOR.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Mẹo ${index + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.BLUE_COLOR,
                ),
              ),
            ),
            const Spacer(),
            if (tip.relatedQuestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING / 2, vertical: SUB_SECTION_SPACING),
                decoration: BoxDecoration(
                  color: theme.WARNING_COLOR.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.question_answer,
                      size: 12,
                      color: theme.WARNING_COLOR,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${tip.relatedQuestions.length} câu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.WARNING_COLOR,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: SECTION_SPACING),
        Text(
          tip.tipTitle,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: SUB_SECTION_SPACING),
        Html(
          data: tip.tipContent,
          style: {
            "body": Style(
              fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
              color: theme.textTheme.bodyLarge?.color,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              lineHeight: LineHeight(1.5),
            ),
            "b": Style(
              fontWeight: FontWeight.w600,
              color: theme.BLUE_COLOR,
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
                size: 18,
                color: theme.WARNING_COLOR,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Câu hỏi liên quan: ${tip.relatedQuestions.join(", ")}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.WARNING_COLOR,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: SECTION_SPACING),
      ],
    );
  }

  void _toggleTopic(String topicId) {
    setState(() {
      _expandedTopics[topicId] = !(_expandedTopics[topicId] ?? false);
    });
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