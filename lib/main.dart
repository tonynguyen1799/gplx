import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'models/hive/quiz_progress.dart';
import 'models/hive/exam_progress.dart';
import 'router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gplx_vn/services/notification_service.dart';
import 'package:gplx_vn/services/hive_service.dart';

Future<void> rescheduleDailyReminderIfNeeded() async {
  final enabled = await getReminderEnabled();
  if (!enabled) return;
  final timeStr = await getReminderTime();
  final message = NotificationService.getRandomDailyMessage();
  await NotificationService.cancelReminder();
  await NotificationService.scheduleDailyReminder(timeStr, message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuizProgressAdapter());
  Hive.registerAdapter(ExamProgressAdapter());
  await Firebase.initializeApp();
  await NotificationService.init();
  await rescheduleDailyReminderIfNeeded();
  runApp(const ProviderScope(child: GPLXApp()));
}

class GPLXApp extends ConsumerStatefulWidget {
  const GPLXApp({super.key});
  @override
  ConsumerState<GPLXApp> createState() => _GPLXAppState();
}

class _GPLXAppState extends ConsumerState<GPLXApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      rescheduleDailyReminderIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(themeModeProvider);
    ThemeMode themeMode;
    switch (appThemeMode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: true,
      routerConfig: appRouter,
      theme: ThemeData(
        textTheme: GoogleFonts.mulishTextTheme().copyWith(
          bodySmall: GoogleFonts.mulishTextTheme().bodySmall?.copyWith(fontSize: 13),
          bodyLarge: GoogleFonts.mulishTextTheme().bodyLarge?.copyWith(fontSize: 15),
          titleLarge: GoogleFonts.mulishTextTheme().titleLarge?.copyWith(fontSize: 18),
        ),
        useMaterial3: false,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          toolbarHeight: 48
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
        dividerColor: Colors.grey[300],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.mulishTextTheme(ThemeData(brightness: Brightness.dark).textTheme).copyWith(
          bodySmall: GoogleFonts.mulishTextTheme(ThemeData(brightness: Brightness.dark).textTheme).bodySmall?.copyWith(fontSize: 13),
          bodyLarge: GoogleFonts.mulishTextTheme(ThemeData(brightness: Brightness.dark).textTheme).bodyLarge?.copyWith(fontSize: 15),
          titleLarge: GoogleFonts.mulishTextTheme(ThemeData(brightness: Brightness.dark).textTheme).titleLarge?.copyWith(fontSize: 18),
        ),
        useMaterial3: false,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          toolbarHeight: 48
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.grey[900],
        ),
        dividerColor: Colors.grey[700],
      ),
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      locale: const Locale('vi'),
    );
  }
}
