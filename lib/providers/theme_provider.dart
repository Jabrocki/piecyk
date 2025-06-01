import 'package:flutter/material.dart';
import 'package:piecyk/theme/dark_theme.dart';
import 'package:piecyk/theme/light_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkTheme; // Changed to darkTheme

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkTheme;

  void toggleTheme() {
    _themeData = _themeData == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }
}