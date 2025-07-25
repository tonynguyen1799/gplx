import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Container(
        height: 44,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.blue),
                SizedBox(height: 1),
                Text('Trang chủ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.blue)),
              ],
            ),
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey),
                  SizedBox(height: 1),
                  Text('Cài đặt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/info'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey),
                  SizedBox(height: 1),
                  Text('Thông tin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 