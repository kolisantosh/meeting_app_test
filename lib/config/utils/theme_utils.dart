import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../constants/app_colors.dart';

class ThemeUtils {
  ThemeUtils._();

  static bool get dark =>
      (MediaQuery.of(navigatorKey.currentContext!).platformBrightness ==
      Brightness.dark);

  static ThemeData get theme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        toolbarTextStyle: ThemeData.light().textTheme.displayMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:
              Colors.black, // <- Set your desired status bar color here
          statusBarIconBrightness:
              Brightness.light, // For black icons on light background
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      primarySwatch: AppColors.primerColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ), //33
        bodySmall: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textDisableColor,
        ),
        displayLarge: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        labelLarge: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        labelSmall: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textDisableColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        titleLarge: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'DMSans-Medium',
          color: AppColors.textColor,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
    );
  }
}

ThemeData lightTheme = ThemeData.light().copyWith(
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white, // <- Set your desired status bar color here
      statusBarIconBrightness:
          Brightness.dark, // For black icons on light background
      statusBarBrightness: Brightness.light,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  colorScheme: ThemeData.light().colorScheme.copyWith(
    secondary: const Color(0xffa1a1a1),
    primary: const Color(0xff0F0425),
    onPrimary: const Color(0xff9694B8),
    outline: const Color(0xfff0f0f0),
    onBackground: const Color(0xfff6f8f8),
    background: const Color(0xffDCE8E8),
    primaryContainer: Colors.white,
    onPrimaryContainer: const Color(0xffd8d8da),
  ),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
  scaffoldBackgroundColor: Colors.white,
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    linearTrackColor: Color(0xffECEAEA),
    color: AppColors.primaryColor,
  ),
  primaryColor: AppColors.primaryColor,
  radioTheme: RadioThemeData(
    fillColor: MaterialStateColor.resolveWith(
      (states) => Colors.black.withOpacity(.4),
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ), //33
    bodySmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textDisableColor,
    ),
    displayLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    displayMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    displaySmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textDisableColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
  ) /*
  textTheme: ThemeData.light().textTheme.copyWith(
    titleMedium: GoogleFonts.dmSans(color: Colors.black),
    titleSmall: GoogleFonts.dmSans(color: Colors.black.withOpacity(.5)),
    displayLarge: GoogleFonts.dmSans(color: Colors.black),
    displayMedium: GoogleFonts.dmSans(
      color: Colors.black,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.dmSans(color: AppColors.textColor),
    displaySmall: GoogleFonts.dmSans(
      color: Colors.black,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.dmSans(color: AppColors.textDisableColor),
  ),*/,
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  appBarTheme: AppBarTheme(
    toolbarTextStyle: ThemeData.light().textTheme.displayMedium!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // <- Set your desired status bar color here
      statusBarIconBrightness:
          Brightness.light, // For black icons on light background
      statusBarBrightness: Brightness.dark,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ), //33
    bodySmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textDisableColor,
    ),
    displayLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    displayMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    displaySmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    labelSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textDisableColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleLarge: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleMedium: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
    titleSmall: TextStyle(
      fontFamily: 'DMSans-Medium',
      color: AppColors.textColor,
    ),
  ),
  /*textTheme: ThemeData.dark().textTheme.copyWith(
    titleMedium: GoogleFonts.dmSans(color: Colors.white),
    titleSmall: GoogleFonts.dmSans(color: Colors.white.withOpacity(.5)),
    displayLarge: GoogleFonts.dmSans(color: Colors.white),
    displayMedium: GoogleFonts.dmSans(
      color: Colors.white,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.dmSans(color: AppColors.textColor),
    displaySmall: GoogleFonts.dmSans(
      color: Colors.white,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.dmSans(color: AppColors.textDisableColor),
  ),*/
  radioTheme: RadioThemeData(
    fillColor: MaterialStateColor.resolveWith(
      (states) => Colors.white.withOpacity(.3),
    ),
  ),
  colorScheme: const ColorScheme.dark().copyWith(
    secondary: const Color(0xff73777a),
    primary: Colors.white,
    onPrimary: const Color(0xffA0A0A0),
    outline: Colors.black,
    onBackground: const Color(0xff202934),
    brightness: Brightness.dark,
    background: const Color(0xff202934),
    primaryContainer: const Color(0xff2d3236),
    onPrimaryContainer: const Color(0xff5a5f62),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    linearTrackColor: Colors.white,
    color: AppColors.primaryColor,
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.black,
);
