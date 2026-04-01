import 'package:flutter/material.dart';

/// Shared tab controller for the Admin bottom navigation.
/// AdminDashboardScreen can call [AdminNavController.switchTab] to jump tabs.
class AdminNavController {
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  static void switchTab(int index) {
    tabIndex.value = index;
  }
}
