import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  String _getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return '/home';
    if (location.startsWith('/settings')) return '/settings';
    if (location.startsWith('/info')) return '/info';
    return '/home'; // default
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = _getCurrentRoute(context);
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(currentRoute),
      onTap: (index) => _navigateToIndex(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.amber 
          : Colors.blue,
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.white70 
          : Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'Thông tin',
        ),
      ],
    );
  }

  int _getCurrentIndex(String route) {
    switch (route) {
      case '/home':
        return 0;
      case '/settings':
        return 1;
      case '/info':
        return 2;
      default:
        return 0;
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    final currentRoute = _getCurrentRoute(context);
    final targetRoute = _getRouteFromIndex(index);
    
    if (currentRoute != targetRoute) {
      context.go(targetRoute);
    }
  }

  String _getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/settings';
      case 2:
        return '/info';
      default:
        return '/home';
    }
  }
} 