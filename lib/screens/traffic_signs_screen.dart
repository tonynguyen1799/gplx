import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_data_providers.dart';
import '../models/traffic_sign.dart';
import '../utils/app_colors.dart';
import 'dart:async';

class TrafficSignsScreen extends ConsumerStatefulWidget {
  const TrafficSignsScreen({super.key});

  @override
  ConsumerState<TrafficSignsScreen> createState() => _TrafficSignsScreenState();
}

class _TrafficSignsScreenState extends ConsumerState<TrafficSignsScreen> {
  static const int _chunkSize = 20;
  final Map<String, int> _loadedChunks = {};
  final Map<String, ScrollController> _controllers = {};
  PageController? _pageController;
  final ScrollController _tabScrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    _tabScrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(trafficSignCategoriesProvider);
    final trafficSignsAsync = ref.watch(trafficSignsProvider);
    
    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Initialize controllers if not already done
    if (_pageController == null) {
      _pageController = PageController();
      _pageController!.addListener(() {
        final page = _pageController!.page?.round() ?? 0;
        if (page != _currentIndex) {
          setState(() {
            _currentIndex = page;
          });
          // Scroll to selected tab
          _scrollToSelectedTab(page);
        }
      });
    }

    for (final cat in categories) {
      _loadedChunks.putIfAbsent(cat['key'] ?? '', () => 1);
      _controllers.putIfAbsent(cat['key'] ?? '', () => ScrollController());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Biển báo giao thông',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: theme.appBarBackground,
          foregroundColor: theme.appBarText,
          elevation: 0,
        ),
      body: Column(
        children: [
          _buildCustomTabBar(categories, theme),
          Expanded(
                          child: _pageController == null 
                ? const Center(child: CircularProgressIndicator())
                : trafficSignsAsync.when(
                    data: (signs) => PageView(
                      controller: _pageController!,
            children: [
              for (final cat in categories)
                _buildChunkedSignList(
                  signs.where((s) => s.categoryKey == cat['key']).toList(),
                  cat['key'] ?? '',
                  theme,
                ),
            ],
          ),
          loading: () => _SkeletonLoader(theme: theme),
          error: (e, st) => Center(child: Text('Lỗi khi tải biển báo: $e')),
        ),
          ),
        ],
        ),
        backgroundColor: theme.brightness == Brightness.dark ? Colors.grey[900] : null,
    );
  }

    void _scrollToSelectedTab(int index) {
    if (!_tabScrollController.hasClients) return;
    
    // Calculate the position to scroll to
    final itemWidth = 120.0; // Approximate width of each tab item
    final padding = 16.0;
    final targetPosition = (itemWidth + padding) * index;
    
    _tabScrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCustomTabBar(List<Map<String, dynamic>> categories, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 40,
      // No background color for tabs bar
      child: ListView.builder(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              _pageController?.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {
                _currentIndex = index;
              });
              _scrollToSelectedTab(index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              constraints: const BoxConstraints(minWidth: 80),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: isSelected
                    ? Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  cat['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? isDark
                            ? Colors.white
                            : Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChunkedSignList(List<TrafficSign> signs, String categoryKey, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final controller = _controllers[categoryKey]!;
    final loadedCount = (_loadedChunks[categoryKey] ?? 1) * _chunkSize;
    final visibleSigns = signs.take(loadedCount).toList();
    final hasMore = loadedCount < signs.length;

    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent - 200 && hasMore) {
        setState(() {
          _loadedChunks[categoryKey] = (_loadedChunks[categoryKey] ?? 1) + 1;
        });
      }
    });

    if (signs.isEmpty) {
      return const Center(child: Text('Không có biển báo nào trong nhóm này.'));
    }
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: visibleSigns.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(height: 10, color: theme.dividerColor),
      itemBuilder: (context, index) {
        if (index >= visibleSigns.length) {
          // Loader at the end
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sign = visibleSigns[index];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sign.image.isNotEmpty)
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.asset(
                    'assets' + sign.image,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sign.id} ${sign.name}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(sign.shortDescription, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 2),
                    Text(sign.description, style: TextStyle(fontSize: 14, color: theme.hintColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  final ThemeData theme;
  const _SkeletonLoader({required this.theme});
  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const Divider(height: 10),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    color: theme.cardColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 16,
                    color: theme.cardColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: theme.colorScheme.surface,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: theme.colorScheme.surface,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 