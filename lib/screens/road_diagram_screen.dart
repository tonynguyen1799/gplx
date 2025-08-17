import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../providers/app_data_providers.dart';
import '../models/riverpod/data/road_diagram.dart';
import '../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';

class RoadDiagramScreen extends ConsumerStatefulWidget {
  const RoadDiagramScreen({super.key});

  @override
  ConsumerState<RoadDiagramScreen> createState() => _RoadDiagramScreenState();
}

class _RoadDiagramScreenState extends ConsumerState<RoadDiagramScreen> {
  // Replace the expanded sections map with a single index
  int? _expandedSectionIndex;

  void _toggleSection(int index) {
    setState(() {
      if (_expandedSectionIndex == index) {
        _expandedSectionIndex = null;
      } else {
        _expandedSectionIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncDiagram = ref.watch(roadDiagramsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sa hình', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.appBarText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarText,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: asyncDiagram.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi khi tải dữ liệu: $e', style: theme.textTheme.bodyLarge)),
        data: (diagram) {
          final sectionColors = [
            theme.brightness == Brightness.dark ? Colors.blue.withOpacity(0.8) : Colors.blue,
            theme.brightness == Brightness.dark ? Colors.red.withOpacity(0.8) : Colors.red,
            theme.brightness == Brightness.dark ? Colors.green.withOpacity(0.8) : Colors.green,
            theme.brightness == Brightness.dark ? Colors.orange.withOpacity(0.8) : Colors.orange,
          ];
          final sectionIcons = [
            Icons.info,
            Icons.warning,
            Icons.map,
            Icons.signpost,
          ];
          return ListView(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.dark
                        ? [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.15),
                          ]
                        : [
                            theme.primaryColor.withOpacity(0.1),
                            theme.primaryColor.withOpacity(0.05),
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
                            ? Colors.blue.withOpacity(0.4)
                            : theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: theme.brightness == Brightness.dark
                            ? Colors.blue[100]!
                            : theme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagram.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hướng dẫn chi tiết các bài thi Sa hình B2',
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
              ...diagram.sections.asMap().entries.map((entry) => _buildSection(context, entry.value, theme, entry.key, sectionColors, sectionIcons)).toList(),
              // const SizedBox(height: 20),
              if (diagram.closingRemark.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    diagram.closingRemark,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.primaryText),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, RoadDiagramSection section, ThemeData theme, int idx, List<Color> sectionColors, List<IconData> sectionIcons) {
    final isExpanded = _expandedSectionIndex == idx;
    return Container(
      // Full width: no margin left/right, no border radius, no boxShadow
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection(idx),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sectionColors[idx].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(sectionIcons[idx], color: sectionColors[idx], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.heading,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.primaryText),
                        ),
                        if (section.content != null && section.content!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _stripHtmlTags(section.content!.split('\n').first),
                              style: TextStyle(fontSize: 14, color: theme.secondaryText, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.secondaryText),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.content != null && section.content!.isNotEmpty)
                    Html(
                      data: section.content!,
                      style: {
                        "body": Style(
                          fontSize: FontSize(15),
                          color: theme.primaryText,
                          lineHeight: LineHeight(1.5),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "ul": Style(
                          margin: Margins.only(left: 16, top: 4, right: 0, bottom: 0),
                          padding: HtmlPaddings.only(left: 0),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 4),
                          padding: HtmlPaddings.zero,
                        ),
                        "b": Style(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.primaryColor,
                        ),
                      },
                    ),
                  if (section.youtube != null && section.youtube!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(section.youtube!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
                              const SizedBox(width: 8),
                              Text('Xem video hướng dẫn', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (section.subSections != null && section.subSections!.isNotEmpty)
                    ...section.subSections!.expand((sub) => [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.label_important, color: theme.primaryText, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sub.subHeading,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: theme.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...sub.listItems.map((item) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Html(
                              data: item,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(15),
                                  color: theme.primaryText,
                                  lineHeight: LineHeight(1.5),
                                  margin: Margins.only(left: 4, top: 8, right: 4, bottom: 8),
                                  padding: HtmlPaddings.zero,
                                ),
                                "b": Style(
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.primaryColor,
                                ),
                              },
                            ),
                          ),
                        ],
                      )),
                    ]),
                  if (section.lessons != null && section.lessons!.isNotEmpty)
                    ...section.lessons!.map((lesson) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildLessonTile(context, lesson, theme),
                    )),
                  if (section.listItems != null && section.listItems!.isNotEmpty)
                    ...section.listItems!.asMap().entries.map((entry) {
                      final isLast = entry.key == section.listItems!.length - 1;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(child: Icon(Icons.tips_and_updates, color: theme.warningColor, size: 18)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Html(
                                  data: entry.value,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(15),
                                      color: theme.primaryText,
                                      lineHeight: LineHeight(1.5),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "ul": Style(
                                      margin: Margins.only(left: 16, top: 4, right: 0, bottom: 0),
                                      padding: HtmlPaddings.only(left: 0),
                                    ),
                                    "li": Style(
                                      margin: Margins.only(bottom: 4),
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "b": Style(
                                      fontWeight: FontWeight.bold,
                                      color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.primaryColor,
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (!isLast) const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, RoadDiagramLesson lesson, ThemeData theme) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lesson.lessonNumber.replaceAll('Bài ', ''),
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryText, fontSize: 15),
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.primaryText),
        ),
        subtitle: Text(
          'Mục tiêu: ${lesson.objective}',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: theme.secondaryText,
          ),
        ),
        children: [
          if (lesson.howToDo.isNotEmpty) ...[
            const SizedBox(height: 4),
            // Text('Cách thực hiện:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: theme.primaryText)),
            ...lesson.howToDo.map((step) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('– ', style: TextStyle(fontSize: 15)),
                Expanded(
                  child: Html(
                    data: step,
                    style: {
                      "body": Style(
                        fontSize: FontSize(15),
                        color: theme.primaryText,
                        lineHeight: LineHeight(1.5),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "b": Style(
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.primaryText,
                      ),
                    },
                  ),
                ),
              ],
            )),
          ],
          if (lesson.tips.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.yellow.withOpacity(0.28)
                    : Colors.yellow[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: theme.warningColor, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Html(
                      data: '<b>Mẹo:</b> ${lesson.tips}',
                      style: {
                        "body": Style(
                          fontSize: FontSize(15),
                          color: theme.primaryText,
                          lineHeight: LineHeight(1.5),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "b": Style(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.primaryColor,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Expanded lesson background for dark mode consistency
          Container(
            color: theme.scaffoldBackgroundColor,
            height: 0.1, // Just to ensure background is set if needed
          ),
        ],
      ),
    );
  }
}

String _stripHtmlTags(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
} 