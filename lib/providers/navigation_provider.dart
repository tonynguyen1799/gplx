import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/navigation_constants.dart';

final tabProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(MainNav.TAB_HOME);

  void navigateToTab(int index) {
    if (index < 0 || index >= MainNav.tabCount) {
      throw ArgumentError('Tab index must be between 0 and ${MainNav.tabCount - 1}, got $index');
    }
    
    if (state != index) {
      state = index;
    }
  }
}
