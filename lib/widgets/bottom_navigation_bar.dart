import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final Function(int)? onTabChanged;
  final int? currentIndex;
  
  const AppBottomNavigationBar({
    super.key, 
    this.onTabChanged,
    this.currentIndex,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _currentIndex = 0;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return '/home';
    if (location.startsWith('/settings')) return '/settings';
    if (location.startsWith('/info')) return '/info';
    return '/home'; // default
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
    // If we have a callback, use it (for MainNavigationScreen)
    if (widget.onTabChanged != null) {
      // Set target index for animation
      _currentIndex = widget.currentIndex ?? 0;
      _targetIndex = index;
      
      // Start indicator animation immediately
      _animationController.forward(from: 0.0);
      
      // Call the callback immediately
      widget.onTabChanged!(index);
      return;
    }
    
    // Otherwise, use the original navigation logic
    final currentRoute = _getCurrentRoute(context);
    final currentIndex = _getCurrentIndex(currentRoute);
    
    // Set target index for animation
    _currentIndex = currentIndex;
    _targetIndex = index;
    
    // Start indicator animation with a slight delay for better visual effect
    _animationController.forward(from: 0.0);
    
    // Navigate after a short delay to sync with indicator animation
    Future.delayed(const Duration(milliseconds: 50), () {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/settings');
          break;
        case 2:
          context.go('/info');
          break;
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != null && widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = oldWidget.currentIndex ?? 0;
      _targetIndex = widget.currentIndex ?? 0;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoute = _getCurrentRoute(context);
    final currentIndex = widget.currentIndex ?? _getCurrentIndex(currentRoute);
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.bottomNavBackground,
      ),
      child: Stack(
          children: [
          Row(
              children: [
              _buildTabItem(context, 0, Icons.home, 'Ôn luyện', currentIndex),
              _buildTabItem(context, 1, Icons.settings, 'Cài đặt', currentIndex),
              _buildTabItem(context, 2, Icons.info, 'Thông tin', currentIndex),
              ],
            ),
          // Animated slide indicator
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              final itemWidth = MediaQuery.of(context).size.width / 3;
              final startPosition = itemWidth * _currentIndex;
              final endPosition = itemWidth * _targetIndex;
              final currentPosition = startPosition + (endPosition - startPosition) * _slideAnimation.value;
              
              return Positioned(
                top: 0,
                left: currentPosition,
                child: Container(
                  width: itemWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: theme.bottomNavSelected,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.bottomNavSelected.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                ],
              ),
            ),
              );
            },
          ),
        ],
      ),
    );
  }



  Widget _buildTabItem(BuildContext context, int index, IconData icon, String label, int currentIndex) {
    final theme = Theme.of(context);
    final isSelected = index == currentIndex;
    final color = isSelected 
      ? theme.bottomNavSelected
      : theme.bottomNavUnselected;
    
    return Expanded(
      child: InkWell(
        onTap: () => _navigateToIndex(context, index),
        child: Container(
          padding: EdgeInsets.zero,
              child: Column(
            mainAxisSize: MainAxisSize.min,
                children: [
              Icon(icon, size: 32, color: color),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
} 