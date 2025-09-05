import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_data_providers.dart';
import '../models/riverpod/data/traffic_sign.dart';
import '../models/riverpod/data/traffic_sign_category.dart';
import '../constants/app_colors.dart';
import 'package:gplx_vn/constants/ui_constants.dart';

class TrafficSignsScreen extends ConsumerStatefulWidget {
  const TrafficSignsScreen({super.key});

  @override
  ConsumerState<TrafficSignsScreen> createState() => _TrafficSignsScreenState();
}

class _TrafficSignsScreenState extends ConsumerState<TrafficSignsScreen> {
  static const int _chunkSize = 20;
  static const double _tabHeight = 42.0;
  static const double _tabItemWidth = 120.0;
  static const double _tabPadding = CONTENT_PADDING;
  static const double _imageSize = 128.0;
  static const double _scrollThreshold = 200.0;
  
  final Map<String, int> _loadedChunks = {};
  final Map<String, ScrollController> _controllers = {};
  PageController? _pageController;
  final ScrollController _tabScrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController!.addListener(() {
      final page = _pageController!.page?.round() ?? 0;
      if (page != _currentIndex) {
        setState(() {
          _currentIndex = page;
        });
        _scrollToTab(page);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoriesAsync = ref.read(trafficSignCategoriesProvider);
    if (categoriesAsync.hasValue && categoriesAsync.value!.isNotEmpty && _controllers.isEmpty) {
      _initializeControllers(categoriesAsync.value!);
    }
  }



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
    final categoriesAsync = ref.watch(trafficSignCategoriesProvider);
    
    return categoriesAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text('Không có dữ liệu biển báo.', style: theme.textTheme.bodyMedium));
        }
        if (_controllers.isEmpty) {
          _initializeControllers(categories);
        }
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 48,
            title: Text(
              'Biển báo giao thông',
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
          body: Column(
            children: [
              _buildTabBars(categories, theme),
              Expanded(
                child: _pageController == null 
                    ? const Center(child: CircularProgressIndicator())
                    : PageView(
                        controller: _pageController!,
                        children: [
                          for (final category in categories)
                            _buildChunkedSigns(
                              category.signs,
                              category.key,
                              theme,
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initializeControllers(List<TrafficSignCategory> categories) {
    for (final category in categories) {
      if (!_controllers.containsKey(category.key)) {
        _loadedChunks.putIfAbsent(category.key, () => 1);
        final controller = ScrollController();
        controller.addListener(() {
          if (controller.position.pixels >= controller.position.maxScrollExtent - _scrollThreshold) {
            final currentChunks = _loadedChunks[category.key] ?? 1;
            if (currentChunks * _chunkSize < category.signs.length) {
              setState(() {
                _loadedChunks[category.key] = currentChunks + 1;
              });
            }
          }
        });
        _controllers[category.key] = controller;
      }
    }
  }

  void _scrollToTab(int index) {
    if (!_tabScrollController.hasClients) return;
    
    final targetPosition = (_tabItemWidth + _tabPadding) * index;
    
    _tabScrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildTabBars(List<TrafficSignCategory> categories, ThemeData theme) {
    return SizedBox(
      height: _tabHeight,
      child: ListView.builder(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final category = categories[index];
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
              _scrollToTab(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: isSelected
                    ? Border(
                        bottom: BorderSide(
                          color: theme.BLUE_COLOR,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge!.color!.withValues(alpha: isSelected ? 1.0 : 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChunkedSigns(List<TrafficSign> signs, String categoryKey, ThemeData theme) {
    final controller = _controllers[categoryKey];
    if (controller == null) return const Center(child: CircularProgressIndicator());
    
    final loadedCount = (_loadedChunks[categoryKey] ?? 1) * _chunkSize;
    final visibleSigns = signs.take(loadedCount).toList();
    final hasMore = loadedCount < signs.length;

    if (signs.isEmpty) {
      return Center(child: Text('Không có biển báo nào trong nhóm này.', style: theme.textTheme.bodyMedium));
    }
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: visibleSigns.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= visibleSigns.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: CONTENT_PADDING),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sign = visibleSigns[index];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CONTENT_PADDING),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sign.image.isNotEmpty)
                SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: Image.asset(
                    'assets${sign.image}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: _imageSize,
                        height: _imageSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: SECTION_SPACING),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${sign.id} ${sign.name}',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SUB_SECTION_SPACING),
                    Text(
                      sign.shortDescription,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      sign.description,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.8),
                      ),
                    ),
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