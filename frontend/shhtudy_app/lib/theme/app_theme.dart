import 'package:flutter/material.dart';

class AppTheme {
  // 색상 정의
  static const Color primaryColor = Color(0xFF7FB77E);  // 메인 녹색
  static const Color backgroundColor = Color(0xFFFFFFFF);  // 흰색 배경
  static const Color accentColor = Color(0xFFE4EEE0);  // 연한 녹색
  static const Color textColor = Color(0xFF464B46);  // 탁한 검은색

  // 소음 레벨 색상
  static const Color quietColor = Color(0xFF85D2E2);  // 조용
  static const Color normalColor = Color(0xFF7FB77E);  // 양호
  static const Color warningColor = Color(0xFFB77E7F);  // 주의

  // 버튼 스타일 기본값
  static final ButtonStyle defaultButtonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    shadowColor: MaterialStateProperty.all(Colors.transparent),
    splashFactory: NoSplash.splashFactory,
    surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
  );

  // 라이트 테마
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      background: backgroundColor,
      surface: backgroundColor,
      onPrimary: Colors.white,
      onBackground: textColor,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: defaultButtonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(primaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: defaultButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(primaryColor),
        side: MaterialStateProperty.all(
          const BorderSide(color: primaryColor),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: defaultButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(textColor),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: defaultButtonStyle.copyWith(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: accentColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
  );
} 