import 'package:flutter/material.dart';
import 'package:gplx_vn/screens/home/home_screen.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';
import 'package:gplx_vn/screens/info_screen.dart';
import 'package:gplx_vn/widgets/bottom_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_data_providers.dart';

class MainNavigationScreen extends ConsumerWidget {
  final int initialIndex;
  
  const MainNavigationScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(),
          const SettingsScreen(),
          const InfoScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        onTabChanged: (index) => ref.read(mainNavIndexProvider.notifier).state = index,
        currentIndex: currentIndex,
      ),
    );
  }
} 