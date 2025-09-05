import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gplx_vn/screens/home/home_screen.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';
import 'package:gplx_vn/screens/info_screen.dart';
import 'package:gplx_vn/widgets/animated_bottom_navigation_bar.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/providers/navigation_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({super.key, required this.initialIndex}) 
    : assert(initialIndex >= 0 && initialIndex < MainNav.tabCount, 
             'initialIndex must be between 0 and ${MainNav.tabCount - 1}');

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tabProvider.notifier).navigateToTab(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current tab index from the provider
    final currentTabIndex = ref.watch(tabProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: const [
          HomeScreen(),      // MainNav.TAB_HOME
          SettingsScreen(),  // MainNav.TAB_SETTINGS
          InfoScreen(),      // MainNav.TAB_INFO
        ],
      ),
      bottomNavigationBar: const AnimatedBottomNavigationBar(),
    );
  }
}



 