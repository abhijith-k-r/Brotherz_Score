// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class FullScorecardScreen extends StatelessWidget {
  const FullScorecardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        title: const Text('SCORECARD'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: DefaultTabController(
            length: 2,
            child: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral400,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'LIONS CC'),
                Tab(text: 'PANTHERS'),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.background100,
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'BATTER',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'R',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'B',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '4s',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '6s',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SR',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBatterRow(
            context,
            'A. Sharma',
            'c Smith b Johnson',
            '45',
            '32',
            '5',
            '1',
            '140.6',
          ),
          _buildBatterRow(
            context,
            'V. Singh*',
            'not out',
            '68',
            '40',
            '6',
            '3',
            '170.0',
            isHighlighted: true,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background100,
              border: Border(
                top: BorderSide(color: AppColors.background300, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      color: AppColors.neutral,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Text(
                  '180/6',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  '(20 OVERS)',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatterRow(
    BuildContext context,
    String name,
    String dismissal,
    String r,
    String b,
    String fours,
    String sixes,
    String sr, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        border: const Border(
          bottom: BorderSide(color: AppColors.background200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.neutral,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dismissal,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              r,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isHighlighted ? AppColors.primary : AppColors.neutral,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              fours,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              sixes,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sr,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
