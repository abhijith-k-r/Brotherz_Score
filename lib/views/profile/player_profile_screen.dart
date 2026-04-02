// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/ball_event_model.dart';
import '../../repositories/match_repository.dart';

class PlayerProfileScreen extends StatelessWidget {
  final PlayerModel player;
  const PlayerProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MatchRepository>();
    final globalId = player.globalPlayerId ?? player.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral400),
          onPressed: () => context.pop(),
        ),
        title: const Text('PLAYER PROFILE'),
      ),
      body: StreamBuilder<List<BallEvent>>(
        stream: repo.watchGlobalPlayerStats(globalId),
        builder: (context, batSnap) {
          return StreamBuilder<List<BallEvent>>(
            stream: repo.watchGlobalBowlerStats(globalId),
            builder: (context, bowlSnap) {
              final batEvents = batSnap.data ?? [];
              final bowlEvents = bowlSnap.data ?? [];
              
              int totalRuns = batEvents.fold(0, (sum, e) => sum + e.runs);
              int totalBalls = batEvents.length;
              int totalWickets = bowlEvents.where((e) => e.isWicket).length;
              
              double avg = batEvents.where((e) => e.isWicket).isEmpty ? totalRuns.toDouble() : totalRuns / batEvents.where((e) => e.isWicket).length;
              double sr = totalBalls > 0 ? (totalRuns / totalBalls) * 100 : 0.0;

              return SingleChildScrollView(
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
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: player.imageUrl != null ? NetworkImage(player.imageUrl!) : null,
                            child: player.imageUrl == null ? Text(player.name[0], style: const TextStyle(fontSize: 32)) : null,
                          ),
                          const SizedBox(height: 16),
                          Text(player.name.toUpperCase(), style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(player.role.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(context, 'MATCHES', 'TBD')), 
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(context, 'RUNS', '$totalRuns', isHighlighted: true)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(context, 'WICKETS', '$totalWickets')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.background100, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.background200)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BATTING STATS', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.background300),
                                const SizedBox(height: 12),
                                _buildListStatRow(context, 'Average', avg.toStringAsFixed(2)),
                                const SizedBox(height: 12),
                                _buildListStatRow(context, 'Strike Rate', sr.toStringAsFixed(1)),
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
                                      _buildBar(totalRuns, 1.0, isHighlighted: true),
                                      _buildBar(65, 0.8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        }
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
            Text(value.toString(), style: TextStyle(color: isHighlighted ? AppColors.primary : AppColors.neutral400, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              height: maxBarHeight * heightPercentage,
              decoration: BoxDecoration(
                color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
