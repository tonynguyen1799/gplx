import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gplx_vn/constants/ui_constants.dart';

import '../models/riverpod/data/road_diagram.dart';
import '../providers/app_data_providers.dart';
import '../constants/app_colors.dart';

class RoadDiagramScreen extends ConsumerStatefulWidget {
  const RoadDiagramScreen({super.key});

  @override
  ConsumerState<RoadDiagramScreen> createState() => _RoadDiagramScreenState();
}

class _RoadDiagramScreenState extends ConsumerState<RoadDiagramScreen> {
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
        toolbarHeight: NAVIGATION_HEIGHT,
        title: Text('Sa hình',
          style: const TextStyle(
            fontSize: APP_BAR_FONT_SIZE,
            fontWeight: FontWeight.w600,
        )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
      ),
      body: asyncDiagram.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
        data: (diagram) {
          final sectionColors = [
            theme.BLUE_COLOR,
            theme.ERROR_COLOR,
            theme.SUCCESS_COLOR,
            Colors.indigo,
          ];
          final sectionIcons = [
            Icons.info,
            Icons.warning,
            Icons.map,
            Icons.signpost,
          ];
          return ListView(
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
                    Container(
                      padding: const EdgeInsets.all(CONTENT_PADDING),
                      decoration: BoxDecoration(
                        color: theme.BLUE_COLOR.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: theme.BLUE_COLOR,
                      ),
                    ),
                    const SizedBox(width: SECTION_SPACING),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagram.title,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: SUB_SECTION_SPACING),
                          Text(
                            'Hướng dẫn chi tiết các bài thi Sa hình B2',
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
              ...diagram.sections.asMap().entries.map((entry) => _buildSection(context, entry.value, theme, entry.key, sectionColors, sectionIcons)).toList(),
              const SizedBox(height: SECTION_SPACING * 2),
              if (diagram.closingRemark.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(CONTENT_PADDING),
                  child: Text(
                    diagram.closingRemark,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: SECTION_SPACING),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, RoadDiagramSection section, ThemeData theme, int idx, List<Color> sectionColors, List<IconData> sectionIcons) {
    final isExpanded = _expandedSectionIndex == idx;
    return Container(
      child: Column(
        children: [
          const SizedBox(height: SECTION_SPACING),
          Container(
            decoration: BoxDecoration(
              color: theme.SURFACE_VARIANT,
            ),
            child: InkWell(
              onTap: () => _toggleSection(idx),
              child: Padding(
                padding: const EdgeInsets.all(CONTENT_PADDING),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(CONTENT_PADDING),
                      decoration: BoxDecoration(
                        color: sectionColors[idx].withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      ),
                      child: Icon(sectionIcons[idx], color: sectionColors[idx]),
                    ),
                    const SizedBox(width: SECTION_SPACING),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.heading,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (section.content != null && section.content!.isNotEmpty)
                            Text(
                              _stripHtmlTags(section.content!.split('\n').first),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING, vertical: SECTION_SPACING),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.content != null && section.content!.isNotEmpty)
                    Html(
                      data: section.content!,
                      style: {
                        "body": Style(
                          fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
                          color: theme.textTheme.bodyLarge?.color,
                          lineHeight: LineHeight(1.5),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "ul": Style(
                          margin: Margins.only(left: CONTENT_PADDING, top: SUB_SECTION_SPACING, right: 0, bottom: 0),
                          padding: HtmlPaddings.only(left: 0),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: SUB_SECTION_SPACING),
                          padding: HtmlPaddings.zero,
                        ),
                        "b": Style(
                          fontWeight: FontWeight.w600,
                          color: theme.BLUE_COLOR,
                        ),
                      },
                    ),
                  if (section.youtube != null && section.youtube!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: SECTION_SPACING),
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(section.youtube!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(CONTENT_PADDING),
                          decoration: BoxDecoration(
                            color: theme.BLUE_COLOR.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill, color: Colors.red, size: LARGE_ICON_SIZE),
                              const SizedBox(width: SUB_SECTION_SPACING),
                              Text('Xem video hướng dẫn', style: theme.textTheme.bodyLarge?.copyWith(color: theme.ERROR_COLOR, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (section.subSections != null && section.subSections!.isNotEmpty)
                    ...section.subSections!.expand((sub) => [
                      const SizedBox(height: SECTION_SPACING),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING, vertical: SUB_SECTION_SPACING),
                        decoration: BoxDecoration(
                          color: theme.BLUE_COLOR.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.label_important, color: theme.textTheme.bodyLarge?.color, size: SMALL_ICON_SIZE),
                            const SizedBox(width: SUB_SECTION_SPACING),
                            Expanded(
                              child: Text(
                                sub.subHeading,
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SUB_SECTION_SPACING),
                      ...sub.listItems.map((item) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Html(
                              data: item,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
                                  color: theme.textTheme.bodyLarge?.color,
                                  lineHeight: LineHeight(1.5),
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                                "b": Style(
                                  fontWeight: FontWeight.w600,
                                  color: theme.BLUE_COLOR,
                                ),
                              },
                            ),
                          ),
                        ],
                      )),
                    ]),
                  if (section.lessons != null && section.lessons!.isNotEmpty)
                    ...section.lessons!.map((lesson) => _buildLessonTile(context, lesson, theme)),
                  if (section.listItems != null && section.listItems!.isNotEmpty)
                    ...section.listItems!.asMap().entries.map((entry) {
                      final isLast = entry.key == section.listItems!.length - 1;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(child: Icon(Icons.tips_and_updates, color: theme.WARNING_COLOR, size: SMALL_ICON_SIZE)),
                              const SizedBox(width: SUB_SECTION_SPACING),
                              Expanded(
                                child: Html(
                                  data: entry.value,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
                                      color: theme.BLUE_COLOR,
                                      lineHeight: LineHeight(1.5),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "ul": Style(
                                      margin: Margins.only(left: CONTENT_PADDING, top: SUB_SECTION_SPACING, right: 0, bottom: 0),
                                      padding: HtmlPaddings.only(left: 0),
                                    ),
                                    "li": Style(
                                      margin: Margins.only(bottom: SUB_SECTION_SPACING),
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "b": Style(
                                      fontWeight: FontWeight.bold,
                                      color: theme.brightness == Brightness.dark ? Colors.blue[100]! : theme.BLUE_COLOR,
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (!isLast) const SizedBox(height: SUB_SECTION_SPACING),
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
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(SUB_SECTION_SPACING),
        decoration: BoxDecoration(
          color: theme.BLUE_COLOR.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
        ),
        child: Text(
          lesson.lessonNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.BLUE_COLOR,
          ),
        ),
      ),
      title: Text(
        lesson.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Mục tiêu: ${lesson.objective}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
        ),
      ),
      children: [
        if (lesson.howToDo.isNotEmpty) ...[
          ...lesson.howToDo.map((step) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('– ', style: theme.textTheme.bodyLarge),
              Expanded(
                child: Html(
                  data: step,
                  style: {
                    "body": Style(
                      fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
                      color: theme.textTheme.bodyLarge?.color,
                      lineHeight: LineHeight(1.5),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "b": Style(
                      fontWeight: FontWeight.w600,
                      color: theme.BLUE_COLOR,
                    ),
                  },
                ),
              ),
            ],
          )),
        ],
        if (lesson.tips.isNotEmpty) ...[
          const SizedBox(height: SUB_SECTION_SPACING),
          Container(
            padding: const EdgeInsets.all(CONTENT_PADDING),
            decoration: BoxDecoration(
              color: theme.WARNING_COLOR.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: theme.WARNING_COLOR, size: MEDIUM_ICON_SIZE),
                const SizedBox(width: SUB_SECTION_SPACING),
                Expanded(
                  child: Html(
                    data: '<b>Mẹo:</b> ${lesson.tips}',
                    style: {
                      "body": Style(
                        fontSize: FontSize(theme.textTheme.bodyLarge?.fontSize ?? 15),
                        color: theme.textTheme.bodyLarge?.color,
                        lineHeight: LineHeight(1.5),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "b": Style(
                        fontWeight: FontWeight.w600,
                        color: theme.BLUE_COLOR,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SECTION_SPACING),
        ],
      ],
    );
  }
}

String _stripHtmlTags(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
} 