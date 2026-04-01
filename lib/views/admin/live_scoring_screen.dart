// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class LiveScoringScreen extends StatelessWidget {
  const LiveScoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral400),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        title: const Text('LIVE SCORING'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('↺ UNDO', style: TextStyle(color: AppColors.neutral300, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondary800,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EAGLES CC', style: TextStyle(color: AppColors.secondary200, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('145', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, height: 1)),
                            Text('/4', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondary200)),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('OVERS', style: TextStyle(color: AppColors.secondary200, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text('15.2', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background100,
              border: Border(bottom: BorderSide(color: AppColors.background200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BATTERS', style: TextStyle(color: AppColors.neutral400, fontSize: 10, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background200,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(left: BorderSide(color: AppColors.primary, width: 2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('R. Sharma*', style: TextStyle(color: AppColors.neutral, fontSize: 14, fontWeight: FontWeight.bold)),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '45 ', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                                  const TextSpan(text: '(28)', style: TextStyle(color: AppColors.neutral400, fontSize: 10)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                         padding: const EdgeInsets.all(8),
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('V. Kohli', style: TextStyle(color: AppColors.neutral, fontSize: 14, fontWeight: FontWeight.bold)),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '12 ', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.neutral)),
                                  const TextSpan(text: '(8)', style: TextStyle(color: AppColors.neutral400, fontSize: 10)),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('BOWLER', style: TextStyle(color: AppColors.neutral400, fontSize: 10, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background200,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(left: BorderSide(color: AppColors.secondary, width: 2)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('M. Khan', style: TextStyle(color: AppColors.neutral, fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('O: 2.2', style: TextStyle(color: AppColors.neutral400, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('R: 18', style: TextStyle(color: AppColors.neutral400, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('W: 1', style: TextStyle(color: AppColors.neutral400, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _buildExtraButton('Wide'),
                      const SizedBox(width: 8),
                      _buildExtraButton('No Ball'),
                      const SizedBox(width: 8),
                      _buildExtraButton('Leg Bye'),
                      const SizedBox(width: 8),
                      _buildExtraButton('Bye'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildRunButton(context, '0'),
                      _buildRunButton(context, '1'),
                      _buildRunButton(context, '2'),
                      _buildRunButton(context, '3'),
                      _buildRunButton(context, '4', color: AppColors.primary, isOutlined: true),
                      _buildRunButton(context, '6', color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.tertiary),
                        backgroundColor: AppColors.tertiary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {},
                      child: Text('WICKET', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.tertiary, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraButton(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.background300),
        ),
        alignment: Alignment.center,
        child: Text(text.toUpperCase(), style: const TextStyle(color: AppColors.neutral300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _buildRunButton(BuildContext context, String run, {Color? color, bool isOutlined = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined ? color?.withOpacity(0.2) : (color ?? AppColors.background100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOutlined ? (color ?? AppColors.background300) : (color == null ? AppColors.background300 : Colors.transparent)),
        boxShadow: (color != null && !isOutlined) ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Center(
            child: Text(
              run,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isOutlined ? color : (color != null ? AppColors.background : AppColors.neutral),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
