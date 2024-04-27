import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mcnd_mobile/services/shared_pref_manager.dart';

enum AppFontSize { small, medium, large }

class ThemeManager extends StateNotifier<AppFontSize> {
  final SharedPrefManager _prefManager = SharedPrefManager();

  AppFontSize getFontSize() => state;

  ThemeManager() : super(AppFontSize.medium) {
    state = _prefManager.getFontSize();
  }

  void changeFontSize(AppFontSize fontSize) {
    state = fontSize;
    print("))))))))))))))");
    print(state);
    _prefManager.setFontSize(fontSize);
  }
}
