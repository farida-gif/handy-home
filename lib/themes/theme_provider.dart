
import 'package:flutter/material.dart';
import 'package:handy_home2/themes/dark_mode.dart';
import 'package:handy_home2/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {

  //light mode as default theme
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  void toggleTheme() {
    _themeData = _themeData == lightMode ? darkMode : lightMode;

  // Notify listeners when theme changes
    notifyListeners(); 
  }
}
