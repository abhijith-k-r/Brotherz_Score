// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

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
        title: const Text('PLAYER PROFILE'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background100,
                border: Border(bottom: BorderSide(color: AppColors.background200)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15)
                      ],
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=150&h=150'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('RAHUL SHARMA', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('RIGHT-HAND BATSMAN', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'MATCHES', '42')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'RUNS', '1,245', isHighlighted: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'WICKETS', '3')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.background200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BATTING STATS', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.background300),
                        const SizedBox(height: 12),
                        _buildListStatRow(context, 'Highest Score', '112*'),
                        const SizedBox(height: 12),
                        _buildListStatRow(context, 'Average', '35.57'),
                        const SizedBox(height: 12),
                        _buildListStatRow(context, 'Strike Rate', '142.8'),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.background300),
                        const SizedBox(height: 12),
                        const Text('PERFORMANCE GRAPH', style: TextStyle(color: AppColors.neutral400, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar(12, 0.3),
                              _buildBar(45, 0.6),
                              _buildBar(4, 0.1),
                              _buildBar(82, 1.0, isHighlighted: true),
                              _buildBar(65, 0.8),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlighted ? AppColors.primary.withOpacity(0.3) : AppColors.background200),
        boxShadow: isHighlighted ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 15)] : null,
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: isHighlighted ? AppColors.primary : AppColors.neutral400, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isHighlighted ? AppColors.primary : AppColors.neutral)),
        ],
      ),
    );
  }

  Widget _buildListStatRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.neutral400, fontSize: 12, letterSpacing: 1.0)),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildBar(int value, double heightPercentage, {bool isHighlighted = false}) {
    const double maxBarHeight = 72.0;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: isHighlighted ? AppColors.primary : AppColors.neutral400,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: maxBarHeight * heightPercentage,
              decoration: BoxDecoration(
                color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: isHighlighted
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
