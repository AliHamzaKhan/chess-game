import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onReady() {
    super.onReady();
    loadTheme();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode.value);
  }
}
