import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      setTheme(ThemeData.light());
    } else {
      setTheme(ThemeData.dark());
    }
  }
}
