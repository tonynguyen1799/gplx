import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_data_providers.dart';
import '../models/traffic_sign.dart';
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

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(trafficSignCategoriesProvider);
    final trafficSignsAsync = ref.watch(trafficSignsProvider);
    if (categories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    for (final cat in categories) {
      _loadedChunks.putIfAbsent(cat['key'] ?? '', () => 1);
      _controllers.putIfAbsent(cat['key'] ?? '', () => ScrollController());
    }
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Biển báo giao thông',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey,
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            tabs: [
              for (final cat in categories)
                Tab(text: cat['name'] ?? ''),
            ],
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : null,
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
        ),
        body: trafficSignsAsync.when(
          data: (signs) => TabBarView(
            children: [
              for (final cat in categories)
                _buildChunkedSignList(
                  signs.where((s) => s.categoryKey == cat['key']).toList(),
                  cat['key'] ?? '',
                ),
            ],
          ),
          loading: () => _SkeletonLoader(),
          error: (e, st) => Center(child: Text('Lỗi khi tải biển báo: $e')),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : null,
      ),
    );
  }

  Widget _buildChunkedSignList(List<TrafficSign> signs, String categoryKey) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: visibleSigns.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(height: 10, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null,
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
                    Text('${sign.id} ${sign.name}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null)),
                    const SizedBox(height: 4),
                    Text(sign.shortDescription, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 2),
                    Text(sign.description, style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w600)),
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
  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
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