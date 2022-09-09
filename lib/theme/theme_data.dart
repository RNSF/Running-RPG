import 'package:flutter/material.dart';
import 'package:running_game/theme/theme_constants.dart';

var standardTheme = ThemeData(
  primaryColor: Palette.primary,
  cardColor: Palette.button,
  backgroundColor: Palette.background1,
  accentColor: Palette.accent,
  textTheme: TextTheme(
    labelSmall: TextStyle(
      color: Palette.background3,
      fontSize: FontSize.body,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Palette.primary,
      fontSize: FontSize.mediumTitle,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      color: Palette.primary,
      fontSize: FontSize.smallTitle,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      color: Palette.primary,
      fontSize: FontSize.body,
      fontWeight: FontWeight.normal,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Palette.button),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      )),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      )),
      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
        fontSize: FontSize.smallTitle,
        fontWeight: FontWeight.bold,
      )),
      foregroundColor: MaterialStateProperty.all<Color>(Palette.buttonText),
      maximumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 2000))
    ),
  ),
  cardTheme: CardTheme(
    color: Palette.button,
    elevation: 0.0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Palette.background3,
    selectedItemColor: Palette.button,
    unselectedItemColor: Palette.background2,
  ),
  dialogTheme: DialogTheme(
    backgroundColor:  Palette.button,
    titleTextStyle: TextStyle(
      color: Palette.background3,
      fontSize: FontSize.smallTitle,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(
      color: Palette.background2,
      fontSize: FontSize.body,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: Palette.background3, // This is a custom color variable
    ),
  ),


);