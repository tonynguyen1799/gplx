import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:gplx_vn/models/hive_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/quiz_practice_status.dart';
import 'router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';

Future<void> printHiveBoxKeys() async {
  // Remove this function or refactor to use hive_service.dart if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuizPracticeStatusAdapter());
  runApp(const ProviderScope(child: GPLXApp()));
}

class GPLXApp extends ConsumerWidget {
  const GPLXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        textTheme: GoogleFonts.mulishTextTheme(),
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
        textTheme: GoogleFonts.mulishTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
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
