import 'package:mcnd_mobile/services/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static late SharedPreferences _prefs;
  static const String _fontSizeKey = 'FontSize';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void setFontSize(AppFontSize fontSize) {
    _prefs.setInt(_fontSizeKey, fontSize.index);
  }

  AppFontSize getFontSize() {
    final int? index = _prefs.getInt(_fontSizeKey);
    return AppFontSize.values.firstWhere((e) => e.index == index, orElse: () => AppFontSize.medium);
  }
}

extension FontSizeExtension on AppFontSize {
  String get name {
    switch (this) {
      case AppFontSize.small:
        return 'Small';
      case AppFontSize.medium:
        return 'Medium';
      case AppFontSize.large:
        return 'Large';
    }
  }
}