// import 'package:bms_front_end/firebase_options.dart';
import 'package:bms_front_end/src/app_routes/app_router.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/controller.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  prefs = await SharedPreferences.getInstance();
  // Initialize AuthController globally
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GetMaterialApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'Bomach OS',
        theme: _buildTheme(),
        routerDelegate: goRouter.routerDelegate,
        routeInformationParser: goRouter.routeInformationParser,
        routeInformationProvider: goRouter.routeInformationProvider,
      ),
    );
  }
}

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: AppColors.textOnPrimary,
  );

  const textTheme = TextTheme(
    displayLarge: AppText.displayLg,
    displayMedium: AppText.displayMd,
    displaySmall: AppText.h1,
    headlineLarge: AppText.h1,
    headlineMedium: AppText.h2,
    headlineSmall: AppText.h3,
    titleLarge: AppText.h3,
    titleMedium: AppText.h4,
    titleSmall: AppText.label,
    bodyLarge: AppText.bodyLg,
    bodyMedium: AppText.bodyMd,
    bodySmall: AppText.bodySm,
    labelLarge: AppText.label,
    labelMedium: AppText.caption,
    labelSmall: AppText.overline,
  );

  return ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    dividerColor: AppColors.borderSubtle,
    textTheme: textTheme,
    dataTableTheme: const DataTableThemeData(
      decoration: BoxDecoration(color: Colors.transparent),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.primary.withValues(alpha: 0.2),
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        textStyle: AppText.label.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderSubtle),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        textStyle: AppText.label.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppText.label.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: AppText.bodyMd.copyWith(color: AppColors.textMuted),
      labelStyle: AppText.label.copyWith(color: AppColors.textSecondary),
      border: const OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      margin: EdgeInsets.zero,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.brLg),
      titleTextStyle: AppText.h3,
      contentTextStyle: AppText.bodyMd,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: AppText.bodyMd.copyWith(color: AppColors.white),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surfaceMuted,
      labelStyle: AppText.caption,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.brPill),
      side: BorderSide(color: AppColors.borderSubtle),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: AppRadii.brSm,
      ),
      textStyle: AppText.caption.copyWith(color: AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );
}
