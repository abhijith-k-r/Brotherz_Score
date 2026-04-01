// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral400),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/viewer');
            }
          },
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('LIVE', style: TextStyle(color: AppColors.tertiary, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.neutral400),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Eagles CC', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Inter')),
                    Text('145/4', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text('Tigers', style: TextStyle(color: AppColors.neutral500, fontSize: 16, fontWeight: FontWeight.bold)),
                     Text('Yet to bat', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.neutral500)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.background300),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.neutral400, fontSize: 12, letterSpacing: 1.0),
                        children: [
                          TextSpan(text: 'OVERS: '),
                          TextSpan(text: '15.2', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          TextSpan(text: '/20'),
                        ],
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.neutral400, fontSize: 12, letterSpacing: 1.0),
                        children: [
                          TextSpan(text: 'CRR: '),
                          TextSpan(text: '9.54', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('COMMENTARY', style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildCommentaryItem(context, '15.2', '4', 'M. Khan to R. Sharma', 'FOUR runs!', 'Short and wide outside off, Sharma cuts it fiercely past point for a boundary. Beautiful shot!', isBoundary: true),
                const SizedBox(height: 16),
                _buildCommentaryItem(context, '15.1', '1', 'M. Khan to V. Kohli', '1 run', 'Tucked away to deep square leg for a single.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryItem(BuildContext context, String over, String run, String bowlerToBatter, String shortDesc, String longDesc, {bool isBoundary = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(over, style: const TextStyle(color: AppColors.neutral300, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isBoundary ? AppColors.primary.withOpacity(0.2) : AppColors.background200,
            shape: BoxShape.circle,
            border: Border.all(color: isBoundary ? AppColors.primary : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: Text(run, style: TextStyle(color: isBoundary ? AppColors.primary : AppColors.neutral300, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.background200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.neutral, fontSize: 14),
                    children: [
                      TextSpan(text: '$bowlerToBatter, ', style: TextStyle(fontWeight: FontWeight.bold, color: isBoundary ? AppColors.primary : AppColors.neutral)),
                      TextSpan(text: shortDesc),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(longDesc, style: const TextStyle(color: AppColors.neutral400, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
