import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  //scaffoldBackgroundColor: AppColors.surface,
  appBarTheme: AppBarTheme(
    elevation: 6,
    centerTitle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    backgroundColor: AppColors.purple.withValues(alpha: 0.05),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    shadowColor: AppColors.white.withValues(alpha: 0.2),
    iconTheme: IconThemeData(color: AppColors.primary),
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.white,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF222A36),
    elevation: 3,
    shadowColor: Color(0xFF11151A),
    margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  ),
  // floatingActionButtonTheme: const FloatingActionButtonThemeData(
  //   backgroundColor: AppColors.primary,
  //   foregroundColor: Color(0xFF222A36),
  // ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 48),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(AppColors.white),
      foregroundColor: WidgetStateProperty.all<Color>(AppColors.surface),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
  ),
  dividerTheme: DividerThemeData(color: AppColors.gray.withValues(alpha: 0.5)),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      color: AppColors.white,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      fontFamily: "PressStart2P",
    ),
    // titleLarge: TextStyle(
    //   color: AppColors.surface,
    //   fontSize: 22,
    //   fontWeight: FontWeight.bold,
    // ),
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    iconColor: AppColors.primary,
    tileColor: Color(0xFF222A36),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    textColor: Colors.yellow,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF181D23),
    elevation: 10,
    selectedItemColor: Colors.yellow,
    unselectedItemColor: Colors.grey,
    selectedIconTheme: IconThemeData(color: Colors.yellow),
    unselectedIconTheme: IconThemeData(color: Colors.grey),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // inputDecorationTheme: InputDecorationTheme(
  //   fillColor: AppColors.surface,
  //   filled: true,
  //   border: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(8.0),
  //     borderSide: BorderSide(color: AppColors.gray),
  //   ),
  //   enabledBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12.0),
  //     borderSide: BorderSide(color: AppColors.gray),
  //   ),
  //   focusedBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(12.0),
  //     borderSide: BorderSide(color: AppColors.primary),
  //   ),
  //   contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //   hintStyle: const TextStyle(
  //     fontSize: 14,
  //     fontWeight: FontWeight.w400,
  //     color: AppColors.gray,
  //   ),
  //   labelStyle: TextStyle(
  //     fontSize: 14,
  //     fontWeight: FontWeight.w400,
  //     color: AppColors.purple,
  //   ),
  // ),
);
