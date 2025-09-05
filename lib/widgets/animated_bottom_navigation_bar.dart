import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/navigation_constants.dart';
import '../providers/navigation_provider.dart';

class AnimatedBottomNavigationBar extends ConsumerStatefulWidget {
  const AnimatedBottomNavigationBar({super.key});

  @override
  ConsumerState<AnimatedBottomNavigationBar> createState() => _AnimatedBottomNavigationBarState();
}

class _AnimatedBottomNavigationBarState extends ConsumerState<AnimatedBottomNavigationBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _previousIndex = MainNav.TAB_HOME;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTabIndex = ref.watch(tabProvider);
    
    ref.listen(tabProvider, (previous, next) {
      if (previous != null && previous != next) {
        _previousIndex = previous;
        _animationController.forward(from: 0.0);
      }
    });
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.NAVIGATION_BG,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              _buildTabItem(context, MainNav.TAB_HOME, Icons.home, 'Ôn luyện', currentTabIndex),
              _buildTabItem(context, MainNav.TAB_SETTINGS, Icons.settings, 'Cài đặt', currentTabIndex),
              _buildTabItem(context, MainNav.TAB_INFO, Icons.info, 'Thông tin', currentTabIndex),
            ],
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              final itemWidth = MediaQuery.of(context).size.width / MainNav.tabCount;
              final startPosition = itemWidth * _previousIndex;
              final endPosition = itemWidth * currentTabIndex;
              final currentPosition = startPosition + (endPosition - startPosition) * _slideAnimation.value;
              
              return Positioned(
                top: 0,
                left: currentPosition,
                child: Container(
                  width: itemWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: theme.NAVIGATION_FG,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.NAVIGATION_FG.withOpacity(0.3),
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

  Widget _buildTabItem(BuildContext context, int tabIndex, IconData icon, String label, int currentTabIndex) {
    final theme = Theme.of(context);
    final isSelected = tabIndex == currentTabIndex;
    
    return Expanded(
      child: InkWell(
        onTap: () => _navigateToIndex(context, tabIndex),
        child: Semantics(
          label: label,
          selected: isSelected,
          button: true,
          child: Container(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: isSelected ? theme.NAVIGATION_FG : theme.NAVIGATION_FG.withValues(alpha: 0.6)),
                Text(
                  label,
                  style: theme.textTheme.bodySmall!.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.NAVIGATION_FG,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index < 0 || index >= MainNav.tabCount) return;
    
    final currentTabIndex = ref.read(tabProvider);
    
    if (currentTabIndex != index) {
      _animationController.forward(from: 0.0);
      ref.read(tabProvider.notifier).navigateToTab(index);
    }
  }
}
