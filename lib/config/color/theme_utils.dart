import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import 'app_colors.dart';

class ThemeUtils {
  ThemeUtils._();

  static bool get dark =>
      (MediaQuery.of(navigatorKey.currentContext!).platformBrightness ==
      Brightness.dark);

  static ThemeData get theme {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
