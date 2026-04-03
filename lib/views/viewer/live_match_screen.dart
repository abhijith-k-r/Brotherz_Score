// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
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
  bool _showCelebration = false;
  Timer? _celebrationTimer;
  late Stream<MatchModel> _matchStream;
  late Stream<List<BallEvent>> _eventsStream;
  late Stream<List<PlayerModel>> _playersStream;
  late MatchRepository _repo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = context.read<MatchRepository>();
    _matchStream = _repo.watchMatch(widget.matchId);
    _eventsStream = _repo.watchBallEvents(widget.matchId);
    _playersStream = _repo.watchPlayers(widget.matchId);
  }

  void _triggerCelebration() {
    if (!_showCelebration) {
       setState(() => _showCelebration = true);
       _celebrationTimer?.cancel();
       _celebrationTimer = Timer(const Duration(seconds: 5), () {
         if (mounted) setState(() => _showCelebration = false);
       });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _celebrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId.isEmpty) return const Scaffold(body: Center(child: Text('Invalid Match')));

    return StreamBuilder<MatchModel>(
      stream: _matchStream,
      builder: (context, matchSnap) {
        if (matchSnap.hasError) return Scaffold(body: Center(child: Text("Viewer Match Error: ${matchSnap.error}")));
        if (!matchSnap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final match = matchSnap.data!;

        if (match.status == 'completed' && _celebrationTimer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _triggerCelebration());
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.neutral400), onPressed: () => context.canPop() ? context.pop() : context.go('/viewer')),
                title: Text(match.matchName.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                actions: [_buildStatusBadge(match)],
                bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'LIVE'), Tab(text: 'LINEUPS')]),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [_buildLiveTab(context, match), _buildLineupTab(context, match)],
              ),
            ),
            if (_showCelebration && match.status == 'completed') _buildWinnerOverlay(match),
          ],
        );
      }
    );
  }

  Widget _buildStatusBadge(MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: match.status == 'live' ? AppColors.tertiary.withOpacity(0.2) : Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: match.status == 'live' ? AppColors.tertiary : Colors.orange, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(match.status.toUpperCase(), style: TextStyle(color: match.status == 'live' ? AppColors.tertiary : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildWinnerOverlay(MatchModel match) {
    bool isTie = match.winnerTeamId == 'TIE' || match.winnerTeamId == 'DRAW' || match.winnerTeamId == null;
    String msg = isTie ? 'MATCH TIED / DRAW!' : '${match.winnerTeamId == 'A' ? match.teamAName : match.teamBName} WON!';
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 🎊 🏏', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(msg, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const Text('Congratulations!', style: TextStyle(color: AppColors.primary, fontSize: 16)),
              ],
            ),
          ),
          Positioned(
            top: 48,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => setState(() => _showCelebration = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab(BuildContext context, MatchModel match) {
    return StreamBuilder<List<PlayerModel>>(
      stream: _playersStream,
      builder: (context, playersSnap) {
        final players = playersSnap.data ?? [];
        return StreamBuilder<List<BallEvent>>(
          stream: _eventsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Ball Events Error: ${snapshot.error}"));
            final events = snapshot.data ?? [];
            final teamAEvents = events.where((e) => e.battingTeam == 'A').toList();
            final teamBEvents = events.where((e) => e.battingTeam == 'B').toList();

            final currentEvents = match.battingTeam == 'A' ? teamAEvents : teamBEvents;
            int legalBalls = currentEvents.where((e) => !e.isWide && !e.isNoBall).length;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInningsRow(match.teamAName, match.battingTeam == 'A', teamAEvents),
                      const SizedBox(height: 12),
                      _buildInningsRow(match.teamBName, match.battingTeam == 'B', teamBEvents),
                      const Divider(height: 32, color: AppColors.background300),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('OVERS: ${legalBalls ~/ 6}.${legalBalls % 6} / ${match.overs}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          if (match.currentInnings == 2 && match.targetRuns != null)
                            Text('TARGET: ${match.targetRuns}', style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
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
                      if (index == 0) return const Text('COMMENTARY', style: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold, fontSize: 10));
                      final event = events[events.length - index];
                      return _buildCommentaryRow(event, players);
                    },
                  ),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildInningsRow(String name, bool isBatting, List<BallEvent> teamEvents) {
    int r = teamEvents.fold<int>(0, (sum, e) => sum + e.totalRuns);
    int w = teamEvents.where((e) => e.isWicket).length;
    int b = teamEvents.where((e) => !e.isWide && !e.isNoBall).length;
    String ov = '${b ~/ 6}.${b % 6}';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isBatting ? AppColors.primary.withOpacity(0.05) : AppColors.background200.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isBatting ? AppColors.primary.withOpacity(0.3) : AppColors.background300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            if (isBatting) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.sports_cricket, size: 14, color: AppColors.primary)),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isBatting ? AppColors.primary : Colors.white)),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$r / $w', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('$ov Overs', style: const TextStyle(fontSize: 10, color: AppColors.neutral400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryRow(BallEvent event, List<PlayerModel> players) {
    String t = event.isWicket ? 'W' : event.runs.toString();
    if (event.isWide) t += 'wd';
    if (event.isNoBall) t += 'nb';

    final striker = players.where((p) => p.id == event.strikerId || p.globalPlayerId == event.strikerId).firstOrNull;
    final bowler = players.where((p) => p.id == event.bowlerId || p.globalPlayerId == event.bowlerId).firstOrNull;
    final fielder = event.fielderId != null ? players.where((p) => p.id == event.fielderId || p.globalPlayerId == event.fielderId).firstOrNull : null;

    String playerDetails = '';
    if (striker != null && bowler != null) {
      playerDetails = '${striker.name} (Bat) vs ${bowler.name} (Bowl)';
    }

    String desc = '';
    if (event.isWicket) {
      desc = '${striker?.name ?? "Batsman"} got OUT (${event.wicketType ?? "Dismissed"})';
      if (fielder != null) desc += ' by ${fielder.name}';
      desc += ' off ${bowler?.name ?? "Bowler"}';
    } else {
      desc = '${striker?.name ?? "Batsman"} scored ${event.runs} ';
      if (event.isWide) desc += '(Wide)';
      if (event.isNoBall) desc += '(No Ball)';
      desc += 'off ${bowler?.name ?? "Bowler"}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.background200.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: event.isWicket ? Colors.red : (event.runs >= 4 ? AppColors.primary : AppColors.background100), 
              radius: 18, 
              child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(event.wicketType != null ? 'WICKET!' : (event.runs >= 4 ? 'BOUNDARY!' : 'RUNS'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                      Text('Over ${event.over}.${event.ball}', style: const TextStyle(fontSize: 8, color: AppColors.neutral400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (playerDetails.isNotEmpty) Text(playerDetails, style: const TextStyle(fontSize: 9, color: AppColors.neutral400, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineupTab(BuildContext context, MatchModel match) {
    return FutureBuilder<List<PlayerModel>>(
      future: _repo.getPlayers(match.id),
      builder: (context, futSnap) {
        return StreamBuilder<List<PlayerModel>>(
          stream: _playersStream,
          builder: (context, snap) {
            if (snap.hasError) return Center(child: Text("Lineup Error: ${snap.error}"));
            
            final players = snap.hasData ? snap.data! : (futSnap.data ?? []);
            if (players.isEmpty && snap.connectionState == ConnectionState.waiting && !futSnap.hasData) {
               return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Fetching rosters...", style: TextStyle(color: AppColors.neutral400, fontSize: 10))]));
            }
            
            if (players.isEmpty) return const Center(child: Text("No players in lineup"));
            final teamA = players.where((p) => p.teamId == 'A').toList();
            final teamB = players.where((p) => p.teamId == 'B').toList();

            return StreamBuilder<List<BallEvent>>(
              stream: _eventsStream,
              builder: (context, evSnap) {
                final evs = evSnap.data ?? [];
                final teamAEvs = evs.where((e) => e.battingTeam == 'A').toList();
                final teamBEvs = evs.where((e) => e.battingTeam == 'B').toList();
                
                return ListView(children: [
                  _buildLiveScoreHeader(match, teamAEvs, teamBEvs),
                  const Divider(height: 1),
                  _buildTeamRoster(match.teamAName, teamA), 
                  _buildTeamRoster(match.teamBName, teamB)
                ]);
              }
            );
          },
        );
      },
    );
  }

  Widget _buildLiveScoreHeader(MatchModel match, List<BallEvent> aEvs, List<BallEvent> bEvs) {
    int rA = aEvs.fold<int>(0, (sum, e) => sum + e.totalRuns);
    int wA = aEvs.where((e) => e.isWicket).length;
    int rB = bEvs.fold<int>(0, (sum, e) => sum + e.totalRuns);
    int wB = bEvs.where((e) => e.isWicket).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniScore(match.teamAName, rA, wA, match.battingTeam == 'A'),
          const Text('VS', style: TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold)),
          _miniScore(match.teamBName, rB, wB, match.battingTeam == 'B'),
        ],
      ),
    );
  }

  Widget _miniScore(String name, int r, int w, bool isBatting) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isBatting ? AppColors.primary : AppColors.neutral400)),
        Text('$r / $w', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTeamRoster(String name, List<PlayerModel> players) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
        ...players.map((p) => ListTile(
          onTap: () => context.push('/player-profile', extra: p),
          leading: CircleAvatar(
            backgroundColor: AppColors.background300,
            child: ClipOval(
                child: p.imageUrl != null 
                  ? Image.network(p.imageUrl!, errorBuilder: (_,_,_) => Text(p.name[0]), fit: BoxFit.cover, width: 40, height: 40)
                  : Text(p.name[0]),
              ),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(p.role),
          trailing: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: _getStatusColor(p.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(p.status.toUpperCase(), style: TextStyle(color: _getStatusColor(p.status), fontSize: 8, fontWeight: FontWeight.bold))),
        ))
    ]);
  }

  Color _getStatusColor(String s) {
    if (s == 'batting') return AppColors.tertiary;
    if (s == 'bowling') return AppColors.primary;
    if (s == 'out') return Colors.red;
    return AppColors.neutral400;
  }
}
