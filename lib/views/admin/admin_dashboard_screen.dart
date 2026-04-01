// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/admin_nav_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  final bool isRoot;
  const AdminDashboardScreen({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary800,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADMIN PANEL', style: Theme.of(context).textTheme.titleLarge),
            const Text(
              'Super Admin Access',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.secondary200.withOpacity(0.2),
              child: const Icon(Icons.settings, color: AppColors.neutral),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Create Match (primary CTA) ──
            GestureDetector(
              onTap: () => context.push('/create-match'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: -4,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('🏏', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 12),
                        Text(
                          'CREATE MATCH',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.background),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start a new scoring session',
                          style: TextStyle(
                            color: AppColors.background.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -16,
                    top: -16,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Players & Live row ──
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    label: 'PLAYERS',
                    emoji: '👥',
                    color: AppColors.primary,
                    onTap: () => AdminNavController.switchTab(1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionCard(
                    context,
                    label: 'LIVE',
                    emoji: '📊',
                    color: AppColors.tertiary,
                    onTap: () => context.push('/live-scoring'),
                    badge: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Match History (wide) ──
            _buildActionCard(
              context,
              label: 'MATCH HISTORY',
              emoji: '📜',
              color: AppColors.secondary200,
              onTap: () => AdminNavController.switchTab(2),
              wide: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
    bool wide = false,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: wide ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: wide ? 20 : 24,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.background100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.background300),
        ),
        child: wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 28, color: color)),
                  const SizedBox(width: 12),
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                ],
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Text(emoji, style: TextStyle(fontSize: 32, color: color)),
                      const SizedBox(height: 10),
                      Text(label, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  if (badge)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
