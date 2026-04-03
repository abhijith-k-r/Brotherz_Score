// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/player_model.dart';
import '../../models/ball_event_model.dart';
import '../../repositories/match_repository.dart';
import '../../viewmodels/theme_cubit.dart';
import 'theme_switch_animation.dart';

class ViewerDashboardScreen extends StatefulWidget {
  final bool isRoot;
  const ViewerDashboardScreen({super.key, this.isRoot = false});

  @override
  State<ViewerDashboardScreen> createState() => _ViewerDashboardScreenState();
}

class _ViewerDashboardScreenState extends State<ViewerDashboardScreen> {
  late Stream<List<MatchModel>> _matchesStream;
  late MatchRepository _repo;
  bool _showCelebration = false;
  String? _lastCompletedMatchId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = context.read<MatchRepository>();
    _matchesStream = _repo.watchMatches();
  }

  void _triggerCelebration() {
    if (!mounted) return;
    setState(() => _showCelebration = true);
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(letterSpacing: 1),
            children: const [
              TextSpan(text: 'Br⭕ther💤 '),
              TextSpan(
                text: 'SCORE',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark
                      ? Icons.wb_sunny_rounded
                      : Icons.nights_stay_rounded,
                  size: 20,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ThemeSwitchAnimation(
        child: Stack(
          children: [
            StreamBuilder<List<MatchModel>>(
              stream: _matchesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No matches found."));
                }

                final matches = snapshot.data!;
                final activeMatch = matches.first;
                final recentMatches = matches.length > 1
                    ? matches.sublist(1)
                    : <MatchModel>[];

                // Check if a match just completed to trigger celebration
                if (activeMatch.status == 'completed' &&
                    _lastCompletedMatchId != activeMatch.id) {
                  _lastCompletedMatchId = activeMatch.id;
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _triggerCelebration(),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activeMatch.status == 'completed'
                                ? 'LATEST RESULT'
                                : 'LIVE MATCH',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          _buildStatusPill(activeMatch.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLiveCard(context, activeMatch),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOP PLAYERS',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton(
                            onPressed: () => context.push('/all-players'),
                            child: const Text(
                              'VIEW ALL',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTopPlayers(context, activeMatch.id),

                      const SizedBox(height: 24),
                      if (recentMatches.isNotEmpty) ...[
                        Text(
                          'RECENT HISTORY',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ...recentMatches.map(
                          (m) => _buildRecentMatchCard(context, m),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            if (_showCelebration) _buildCelebrationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Match Completed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('🎉 🎊 🏆 🎊 🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 32),
            IconButton(
              onPressed: () => setState(() => _showCelebration = false),
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = AppColors.primary;
    if (status == 'live') color = AppColors.tertiary;
    if (status == 'break') color = Colors.orange;
    if (status == 'completed') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLiveCard(BuildContext context, MatchModel match) {
    return StreamBuilder<List<BallEvent>>(
      stream: _repo.watchBallEvents(match.id),
      builder: (context, eventsSnap) {
        final allEvents = eventsSnap.data ?? [];
        final teamAEvents = allEvents
            .where((e) => e.battingTeam == 'A')
            .toList();
        final teamBEvents = allEvents
            .where((e) => e.battingTeam == 'B')
            .toList();

        return StreamBuilder<List<PlayerModel>>(
          stream: _repo.watchPlayers(match.id),
          builder: (context, playersSnap) {
            final players = playersSnap.data ?? [];
            final lastBall = allEvents.isNotEmpty ? allEvents.last : null;

            PlayerModel? striker;
            PlayerModel? bowler;
            int sr = 0, sb = 0, bw = 0, br = 0;

            if (lastBall != null) {
              striker = players
                  .where((p) => p.id == lastBall.strikerId)
                  .firstOrNull;
              bowler = players
                  .where((p) => p.id == lastBall.bowlerId)
                  .firstOrNull;
              if (striker != null) {
                sr = allEvents
                    .where((e) => e.strikerId == striker!.id)
                    .fold(0, (sum, e) => sum + e.runs);
                sb = allEvents
                    .where((e) => e.strikerId == striker!.id && !e.isWide)
                    .length;
              }
              if (bowler != null) {
                bw = allEvents
                    .where((e) => e.bowlerId == bowler!.id && e.isWicket)
                    .length;
                br = allEvents
                    .where((e) => e.bowlerId == bowler!.id)
                    .fold(0, (sum, e) => sum + e.totalRuns);
              }
            }

            return GestureDetector(
              onTap: () => context.push('/live-match', extra: match.id),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: AppColors.background100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.background300),
                ),
                child: Column(
                  children: [
                    _buildTeamSummaryLine(
                      match.teamAName,
                      match.battingTeam == 'A',
                      teamAEvents,
                    ),
                    const SizedBox(height: 12),
                    _buildTeamSummaryLine(
                      match.teamBName,
                      match.battingTeam == 'B',
                      teamBEvents,
                    ),
                    const Divider(height: 32, color: AppColors.background300),
                    if (match.status != 'completed')
                      Row(
                        children: [
                          if (striker != null)
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sports_cricket,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${striker.name} $sr($sb)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          if (bowler != null)
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${bowler.name} $bw-$br',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    else
                      Text(
                        (match.winnerTeamId == 'TIE' || match.winnerTeamId == 'DRAW')
                            ? 'MATCH TIED'
                            : (match.winnerTeamId != null
                                ? 'WINNER: ${match.winnerTeamId == 'A' ? match.teamAName : match.teamBName}'
                                : 'MATCH DRAW'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamSummaryLine(
    String name,
    bool isBatting,
    List<BallEvent> events,
  ) {
    int r = events.fold<int>(0, (sum, e) => sum + e.totalRuns);
    int w = events.where((e) => e.isWicket).length;
    int balls = events.where((e) => !e.isWide && !e.isNoBall).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBatting ? AppColors.primary : AppColors.neutral500,
              ),
            ),
            if (isBatting) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BATTING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$r/$w',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${balls ~/ 6}.${balls % 6} Overs',
              style: const TextStyle(fontSize: 8, color: AppColors.neutral400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPlayers(BuildContext context, String matchId) {
    return StreamBuilder<List<PlayerModel>>(
      stream: _repo.watchPlayers(matchId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final players = snap.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: players.map((p) {
              final isTeamA = p.teamId == 'A';
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => context.push('/player-profile', extra: p),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isTeamA
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTeamA
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.tertiary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSafeAvatar(p),
                        const SizedBox(height: 8),
                        Text(
                          p.name.split(' ').first,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSafeAvatar(PlayerModel p) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: p.teamId == 'A' ? AppColors.primary : AppColors.tertiary,
      child: ClipOval(
        child: p.imageUrl != null
            ? Image.network(
                p.imageUrl!,
                errorBuilder: (context, error, stackTrace) => Text(
                  p.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              )
            : Text(p.name[0], style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRecentMatchCard(BuildContext context, MatchModel m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/live-match', extra: m.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // color: AppColors.background100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.background200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.matchName,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.neutral400,
                    ),
                  ),
                  Text(
                    '${m.teamAName} vs ${m.teamBName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
