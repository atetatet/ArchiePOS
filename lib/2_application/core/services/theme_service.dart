import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  ThemeData get dark => AppTheme.dark();
  ThemeData get light => AppTheme.dark();

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
