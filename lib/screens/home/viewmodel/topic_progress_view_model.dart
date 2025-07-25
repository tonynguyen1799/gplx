import 'package:flutter/material.dart';

class TopicProgressViewModel {
  final String id;
  final String title;
  final int done;
  final int total;
  final IconData icon;
  final Color color;
  const TopicProgressViewModel({required this.id, required this.title, required this.done, required this.total, required this.icon, required this.color});
} 