import 'package:flutter/material.dart';

extension AppColors on ThemeData {
  Color get APP_BAR_BG => brightness == Brightness.dark ? Colors.grey[850]! : Colors.white;
  Color get APP_BAR_FG => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;

  Color get LIGHT_SURFACE_VARIANT => brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[50]!;
  Color get SURFACE_VARIANT => brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[100]!;
  Color get DARK_SURFACE_VARIANT => brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!;

  Color get PROGRESS_BAR_BG => brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get PROGRESS_BAR_FG => brightness == Brightness.dark ? Colors.amber[400]! : Colors.blue[900]!;

  Color get EXAM_WIDGET_BG => brightness == Brightness.dark ? Colors.indigo[900]! : Colors.indigo[50]!;
  Color get EXAM_WIDGET_ICON => brightness == Brightness.dark ? Colors.indigo[50]! : Colors.indigo;

  Color get NAVIGATION_BG => brightness == Brightness.dark ? Colors.grey[900]! : Colors.white;
  Color get NAVIGATION_FG => brightness == Brightness.dark ? Colors.indigo[100]! : Colors.blue[800]!;

  Color get SUCCESS_COLOR => brightness == Brightness.dark ? Colors.green[800]! : Colors.green[800]!;
  Color get WARNING_COLOR => brightness == Brightness.dark ? Colors.orange[900]! : Colors.orange[800]!;
  Color get ERROR_COLOR => brightness == Brightness.dark ? Colors.red[800]! : Colors.red[900]!;
  Color get FALTA_COLOR => brightness == Brightness.dark ? WARNING_COLOR : ERROR_COLOR;
  Color get BLUE_COLOR => brightness == Brightness.dark ? Colors.blue[800]! : Colors.blue[800]!;
  Color get AMBER_COLOR => brightness == Brightness.dark ? Colors.amber : Colors.amber[700]!;
}
