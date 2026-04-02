// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/ball_event_model.dart';
import '../../models/player_model.dart';
import '../../repositories/match_repository.dart';

class LiveMatchScreen extends StatefulWidget {
  final String matchId;
  const LiveMatchScreen({super.key, required this.matchId});

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Match')),
        body: const Center(child: Text('Invalid Match ID')),
      );
    }
    final repo = context.read<MatchRepository>();

    return StreamBuilder<MatchModel>(
      stream: repo.watchMatch(widget.matchId),
      builder: (context, matchSnap) {
        if (!matchSnap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final match = matchSnap.data!;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
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
              title: Text(match.matchName.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: match.status == 'live' ? AppColors.tertiary.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: match.status == 'live' ? AppColors.tertiary : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        match.status.toUpperCase(),
                        style: TextStyle(
                          color: match.status == 'live' ? AppColors.tertiary : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'LIVE'),
                  Tab(text: 'LINEUPS'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveTab(context, repo, match),
                _buildLineupTab(context, repo, match),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildLiveTab(BuildContext context, MatchRepository repo, MatchModel match) {
    return StreamBuilder<List<BallEvent>>(
      stream: repo.watchBallEvents(widget.matchId),
      builder: (context, runsSnap) {
        final events = runsSnap.data ?? [];
        int totalRuns = events.fold(0, (sum, e) => sum + e.totalRuns);
        int totalWickets = events.where((e) => e.isWicket).length;
        
        int legalBalls = events.where((e) => !e.isWide && !e.isNoBall).length;
        int overs = legalBalls ~/ 6;
        int balls = legalBalls % 6;
        
        double crr = overs > 0 || balls > 0 ? (totalRuns / (overs + (balls / 6))) : 0.0;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.background100,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(match.teamAName, style: Theme.of(context).textTheme.titleLarge),
                      Text('$totalRuns/$totalWickets', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(match.teamBName, style: const TextStyle(color: AppColors.neutral500, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Yet to bat', style: TextStyle(color: AppColors.neutral500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.background300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OVERS: $overs.$balls / ${match.overs}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('CRR: ${crr.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('COMMENTARY', style: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold, letterSpacing: 1.5)));
                  final event = events[events.length - index];
                  return _buildCommentaryItem(context, event);
                },
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildLineupTab(BuildContext context, MatchRepository repo, MatchModel match) {
    return StreamBuilder<List<PlayerModel>>(
      stream: repo.watchPlayers(widget.matchId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final players = snap.data!;
        final teamA = players.where((p) => p.teamId == 'A').toList();
        final teamB = players.where((p) => p.teamId == 'B').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
             _buildTeamLineup(match.teamAName, teamA),
             const SizedBox(height: 24),
             _buildTeamLineup(match.teamBName, teamB),
          ],
        );
      },
    );
  }

  Widget _buildTeamLineup(String teamName, List<PlayerModel> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(teamName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary, letterSpacing: 1.5)),
            Text('${players.length} Players', style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        ...players.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.background100, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: p.imageUrl != null ? NetworkImage(p.imageUrl!) : null,
                child: p.imageUrl == null ? Text(p.name[0], style: const TextStyle(fontSize: 12)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(p.role, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _buildStatusBadge(p.status),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.neutral400;
    if (status == 'batting') color = AppColors.tertiary;
    if (status == 'bowling') color = AppColors.primary;
    if (status == 'out') color = Colors.red;
    if (status == 'not_out') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCommentaryItem(BuildContext context, BallEvent event) {
    String runText = event.isWicket ? 'W' : event.runs.toString();
    if (event.isWide) runText += 'wd';
    if (event.isNoBall) runText += 'nb';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: event.isWicket ? AppColors.tertiary.withOpacity(0.2) : (event.runs >= 4 ? AppColors.primary.withOpacity(0.2) : AppColors.background200),
              shape: BoxShape.circle,
              border: Border.all(color: event.isWicket ? AppColors.tertiary : (event.runs >= 4 ? AppColors.primary : Colors.transparent)),
            ),
            alignment: Alignment.center,
            child: Text(runText, style: TextStyle(fontWeight: FontWeight.bold, color: event.isWicket ? AppColors.tertiary : (event.runs >= 4 ? AppColors.primary : AppColors.neutral))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.isWicket ? 'WICKET!' : (event.runs == 6 ? 'SIX!!!' : (event.runs == 4 ? 'FOUR!!' : 'Delivery')), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${event.totalRuns} runs including extras', style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
