import 'package:flutter/material.dart';

extension AppColors on ThemeData {
  // Bottom Navigation Bar Colors
  Color get bottomNavBackground => brightness == Brightness.dark ? Colors.grey[900]! : Colors.white;
  Color get bottomNavSelected => Colors.blue;
  Color get bottomNavUnselected => Colors.grey;
  
  // Text Colors
  Color get primaryText => brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get secondaryText => brightness == Brightness.dark ? Colors.grey : Colors.grey[600]!;
  Color get tertiaryText => brightness == Brightness.dark ? Colors.grey : Colors.grey;
  
  // Background Colors
  Color get cardBackground => brightness == Brightness.dark ? Colors.grey[800]! : Colors.white;
  Color get surfaceBackground => brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[50]!;
  
  // Status Colors (Material Design)
  Color get successColor => brightness == Brightness.dark ? Colors.green : Colors.green[700]!;
  Color get errorColor => brightness == Brightness.dark ? Colors.red : Colors.red[700]!;
  Color get warningColor => brightness == Brightness.dark ? Colors.orange : Colors.orange[700]!;
  Color get infoColor => brightness == Brightness.dark ? Colors.blue : Colors.blue[700]!;
  Color get amberColor => brightness == Brightness.dark ? Colors.amber : Colors.amber[700]!;
  
  // Exam Quiz Jump Button Colors (M3 Compliant)
  Color get examJumpUnansweredBackground => brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[200]!;
  Color get examJumpUnansweredText => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get examJumpUnansweredBorder => brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey;
  Color get examJumpCorrectBackground => brightness == Brightness.dark ? Colors.green[900]! : Colors.green[100]!;
  Color get examJumpCorrectText => brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
  Color get examJumpCorrectBorder => brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
  Color get examJumpIncorrectBackground => brightness == Brightness.dark ? Colors.red[900]! : Colors.red[100]!;
  Color get examJumpIncorrectText => brightness == Brightness.dark ? Colors.redAccent : Colors.red;
  Color get examJumpIncorrectBorder => brightness == Brightness.dark ? Colors.redAccent : Colors.red;
  Color get examJumpAnsweredBackground => brightness == Brightness.dark ? Colors.blue[900]! : Colors.blue[100]!;
  Color get examJumpAnsweredText => brightness == Brightness.dark ? Colors.blueAccent : Colors.blue;
  Color get examJumpAnsweredBorder => brightness == Brightness.dark ? Colors.blueAccent : Colors.blue;
  Color get examJumpCurrentText => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get examJumpCurrentBorder => brightness == Brightness.dark ? Colors.white : Colors.grey;
  

  // Interactive Colors
  Color get primaryColor => brightness == Brightness.dark ? Colors.blue : Colors.blue[700]!;
  Color get secondaryColor => brightness == Brightness.dark ? Colors.teal : Colors.teal[700]!;
  
  // Surface Colors
  Color get surfaceVariant => brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[100]!;
  Color get outline => brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[400]!;
  
  // Study Progress & Topic Widget Colors (M3 Compliant)
  Color get studyProgressBackground => brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[50]!;
  Color get studyProgressTitle => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get studyProgressText => brightness == Brightness.dark ? Colors.grey[300]! : Colors.grey[700]!;
  Color get studyProgressStats => brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[500]!;
  Color get studyProgressPercentage => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get studyProgressBarBackground => brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get studyProgressBarColor => brightness == Brightness.dark ? Colors.amber[400]! : Colors.blue[600]!;
  
  // Real Exam Widget Colors (M3 Compliant)
  Color get realExamBackground => brightness == Brightness.dark ? Colors.deepPurple[900]! : Colors.indigo[50]!;
  Color get realExamIcon => brightness == Brightness.dark ? Colors.amberAccent : Colors.indigo;
  Color get realExamTitle => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get realExamDescription => brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[500]!;
  
  // Shortcuts Widget Colors (M3 Compliant)
  Color get shortcutsBackground => brightness == Brightness.dark ? Colors.grey[800]! : Colors.white;
  Color get shortcutsText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get shortcutsCountText => brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[500]!;
  
  // Quiz Screen Colors (M3 Compliant)
  Color get quizAppBarBackground => brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[50]!;
  Color get quizAppBarText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get quizFilterBackground => brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[50]!;
  Color get quizFilterText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get quizFilterGroupBackground => brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!;
  Color get quizFilterCheckIcon => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get quizFilterButtonText => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get quizFilterButtonIcon => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get quizBottomSheetBackground => brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[50]!;
  Color get quizBottomSheetText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get quizEmptyStateIcon => brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get quizEmptyStateText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  
  // Global AppBar Colors (M3 Compliant)
  Color get appBarBackground => brightness == Brightness.dark ? Colors.grey[850]! : Colors.white;
  Color get appBarText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  
  // Quiz Content Widget Colors (M3 Compliant)
  Color get quizContentHeader => brightness == Brightness.dark ? Colors.grey[300]! : Colors.grey[700]!;
  Color get quizContentText => brightness == Brightness.dark ? Colors.white : Colors.grey[900]!;
  Color get quizContentPracticed => brightness == Brightness.dark ? Colors.grey[300]! : Colors.grey[700]!;
  Color get quizContentCheckIcon => successColor;
  
  // Answer Options Widget Colors (M3 Compliant)
  Color get answerOptionBackground => brightness == Brightness.dark ? Colors.grey[800]! : Colors.white;
  Color get answerOptionSelected => brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[300]!;
  Color get answerOptionCorrect => brightness == Brightness.dark ? Colors.green[900]! : Colors.green[100]!;
  Color get answerOptionIncorrect => brightness == Brightness.dark ? Colors.red[900]! : Colors.red[100]!;
  Color get answerOptionIcon => brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get answerOptionIconCorrect => successColor;
  Color get answerOptionIconIncorrect => errorColor;
  Color get answerOptionText => primaryText;
  Color get answerExplanationBackground => brightness == Brightness.dark ? Colors.grey[900]! : Colors.blue[50]!;
  Color get answerExplanationText => brightness == Brightness.dark ? Colors.white : Colors.black;
} 