// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/player_model.dart';
import '../../models/ball_event_model.dart';
import '../../repositories/match_repository.dart';

class ViewerDashboardScreen extends StatelessWidget {
  final bool isRoot;
  const ViewerDashboardScreen({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MatchRepository>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        title: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(letterSpacing: 1),
            children: const [
              TextSpan(text: 'BROTHERS '),
              TextSpan(
                text: 'SCORE',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100',
              ),
              radius: 16,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<MatchModel>>(
        stream: repo.watchMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data!;
          // active matches
          final activeMatch = matches.where((m) => m.status != 'completed').firstOrNull;
          // recent matches
          final recentMatches = matches.where((m) => m.status == 'completed').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeMatch != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LIVE NOW',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: activeMatch.status == 'live' ? AppColors.tertiary : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/live-match', extra: activeMatch.id),
                    child: Container(
                      width: double.infinity,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: activeMatch.status == 'live' ? AppColors.tertiary.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activeMatch.status.toUpperCase(),
                                  style: TextStyle(
                                    color: activeMatch.status == 'live' ? AppColors.tertiary : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${activeMatch.overs} Overs Match',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          StreamBuilder<List<BallEvent>>(
                            stream: repo.watchBallEvents(activeMatch.id),
                            builder: (context, runsSnap) {
                              final events = runsSnap.data ?? [];
                              final battingTeam = events.isEmpty ? 'A' : events.last.battingTeam;
                              final totalRuns = events.fold<int>(0, (sum, e) => sum + e.totalRuns);
                              final totalWickets = events.where((e) => e.isWicket).length;

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        activeMatch.teamAName + (battingTeam == 'A' ? ' (BATTING)' : ''),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: battingTeam == 'A' ? AppColors.primary : AppColors.neutral,
                                          fontWeight: battingTeam == 'A' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (battingTeam == 'A') Text('$totalRuns/$totalWickets', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        activeMatch.teamBName + (battingTeam == 'B' ? ' (BATTING)' : ''),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: battingTeam == 'B' ? AppColors.primary : AppColors.neutral,
                                          fontWeight: battingTeam == 'B' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (battingTeam == 'B') Text('$totalRuns/$totalWickets', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (activeMatch != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MATCH PLAYERS',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<PlayerModel>>(
                    stream: repo.watchPlayers(activeMatch.id),
                    builder: (context, playersSnap) {
                       final players = playersSnap.data ?? [];
                       if (players.isEmpty) {
                         return const Text('No players added yet.', style: TextStyle(color: AppColors.neutral400));
                       }
                       // Show first 3 for UI compactness
                       return SingleChildScrollView(
                         scrollDirection: Axis.horizontal,
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: players.map((p) {
                             return Padding(
                               padding: const EdgeInsets.only(right: 8.0),
                               child: GestureDetector(
                                 onTap: () => context.push('/player-profile', extra: p),
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
                                         backgroundImage: p.imageUrl != null && p.imageUrl!.startsWith('http') ? NetworkImage(p.imageUrl!) : null,
                                         child: p.imageUrl == null ? Text(p.name[0].toUpperCase(), style: const TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold)) : null,
                                       ),
                                       const SizedBox(height: 8),
                                       Text(
                                         p.name,
                                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                       Text(
                                         p.role,
                                         style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             );
                           }).toList(),
                         ),
                       );
                    }
                  ),
                  const SizedBox(height: 24),
                ],

                if (recentMatches.isNotEmpty) ...[
                  Text(
                    'RECENT RESULTS',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  ...recentMatches.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => context.push('/live-match', extra: m.id),
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
                            Text(
                              m.matchName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  m.teamAName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  m.teamBName,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: AppColors.neutral400),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Match Completed',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ],
            ),
          );
        }
      ),
    );
  }
}
