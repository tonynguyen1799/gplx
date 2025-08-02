import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/app_colors.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin', style: TextStyle(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarBackground,
        foregroundColor: Theme.of(context).appBarText,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      body: const SizedBox.expand(),
    );
  }
} 