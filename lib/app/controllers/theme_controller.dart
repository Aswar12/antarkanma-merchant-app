import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _box.read(_key);
    if (savedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    if (mode == ThemeMode.dark) {
      _box.write(_key, 'dark');
    } else if (mode == ThemeMode.light) {
      _box.write(_key, 'light');
    } else {
      _box.remove(_key);
    }
    Get.changeThemeMode(mode);
    update();
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  bool get isLightMode => themeMode.value == ThemeMode.light;
  bool get isSystemMode => themeMode.value == ThemeMode.system;

  String get currentThemeName {
    if (isDarkMode) return 'Dark';
    if (isLightMode) return 'Light';
    return 'System';
  }
}
