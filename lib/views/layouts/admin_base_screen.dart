// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/admin_nav_controller.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/player_management_screen.dart';
import '../matches/match_history_screen.dart';
import '../admin/admin_settings_screen.dart';

class AdminBaseScreen extends StatefulWidget {
  const AdminBaseScreen({super.key});

  @override
  State<AdminBaseScreen> createState() => _AdminBaseScreenState();
}

class _AdminBaseScreenState extends State<AdminBaseScreen> {
  static final List<Widget> _screens = const [
    AdminDashboardScreen(isRoot: true),
    PlayerManagementScreen(isRoot: true),
    MatchHistoryScreen(isRoot: true, isAdmin: true),
    AdminSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Reset to home tab on mount
    AdminNavController.tabIndex.value = 0;
    // Listen to external tab-switch requests (e.g. from AdminDashboard cards)
    AdminNavController.tabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    AdminNavController.tabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  int get _currentIndex => AdminNavController.tabIndex.value;

  void _setTab(int index) => AdminNavController.switchTab(index);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          _setTab(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background100,
        border: const Border(
          top: BorderSide(color: AppColors.background300, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.dashboard_rounded, 'Home'),
              _buildNavItem(context, 1, Icons.people_alt_rounded, 'Players'),
              _buildNavItem(context, 2, Icons.history_rounded, 'History'),
              _buildNavItem(context, 3, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.neutral400,
                size: isSelected ? 26 : 22,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
