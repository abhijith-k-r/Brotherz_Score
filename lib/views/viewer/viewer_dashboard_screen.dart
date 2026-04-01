// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ViewerDashboardScreen extends StatelessWidget {
  final bool isRoot;
  const ViewerDashboardScreen({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1),
            children: const [
              TextSpan(text: 'BROTHERS '),
              TextSpan(text: 'SCORE', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100'),
              radius: 16,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LIVE NOW', style: Theme.of(context).textTheme.titleMedium),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push('/live-match'),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.background300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('LIVE', style: TextStyle(color: AppColors.tertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text('T20 • 15.2 Overs', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Eagles CC', style: Theme.of(context).textTheme.titleSmall),
                        Text('145/4', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tigers', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.neutral400)),
                        Text('Yet to bat', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.neutral400)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOP PLAYERS', style: Theme.of(context).textTheme.titleMedium),
                const Text('VIEW ALL', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerCard(context, 'D. Warner', 'Batsman', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&h=100'),
                _buildPlayerCard(context, 'R. Sharma', 'All-rounder', initials: 'RS'),
                _buildPlayerCard(context, 'M. Khan', 'Bowler', imageUrl: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100'),
              ],
            ),
            const SizedBox(height: 24),
            Text('RECENT RESULTS', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Yesterday • Final', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lions CC', style: Theme.of(context).textTheme.titleSmall),
                        Text('180/6', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Panthers', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.neutral400)),
                        Text('175/9', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.neutral400)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Lions CC won by 5 runs', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, String name, String role, {String? imageUrl, String? initials}) {
    return GestureDetector(
      onTap: () => context.push('/player-profile'),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.background200),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.background200,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: initials != null ? Text(initials, style: const TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold)) : null,
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(role, style: const TextStyle(fontSize: 10, color: AppColors.neutral400)),
          ],
        ),
      ),
    );
  }
}
