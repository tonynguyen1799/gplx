import 'package:flutter/material.dart';
import 'package:gplx_vn/screens/home/home_screen.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';
import 'package:gplx_vn/screens/info_screen.dart';
import 'package:gplx_vn/widgets/bottom_navigation_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({super.key, required this.initialIndex});

  static void switchToTab(int tabIndex) {
    if (_MainNavigationScreenState._instance != null) {
      _MainNavigationScreenState._instance!._onTabChanged(tabIndex);
    }
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  static _MainNavigationScreenState? _instance;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _instance = this;
  }

  @override
  void dispose() {
    if (_instance == this) {
      _instance = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          SettingsScreen(),
          InfoScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        onTabChanged: _onTabChanged,
        currentIndex: _currentIndex,
      ),
    );
  }
} 