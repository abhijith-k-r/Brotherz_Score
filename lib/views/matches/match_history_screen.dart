// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class MatchHistoryScreen extends StatelessWidget {
  final bool isRoot;
  const MatchHistoryScreen({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        leading: isRoot
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.neutral400),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/admin');
                  }
                },
              ),
        title: const Text('MATCH HISTORY'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => context.push('/full-scorecard'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.background200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('12 OCT 2023 • FINAL', style: TextStyle(color: AppColors.neutral400, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      Text('CENTRAL STADIUM', style: TextStyle(color: AppColors.neutral400, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.background300),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lions CC', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Inter')),
                      Text('180/6', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Panthers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: AppColors.neutral500)),
                      Text('175/9', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('LIONS CC WON BY 5 RUNS', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5), textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
