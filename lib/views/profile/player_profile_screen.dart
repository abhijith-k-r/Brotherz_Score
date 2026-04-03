// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/match_model.dart';
import '../../models/ball_event_model.dart';
import '../../repositories/match_repository.dart';

class PlayerProfileScreen extends StatefulWidget {
  final PlayerModel player;
  const PlayerProfileScreen({super.key, required this.player});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  String _matchFilter = 'CAREER'; 
  Map<String, List<BallEvent>>? _globalStats;
  List<MatchModel> _availableMatches = [];
  // ignore: unused_field
  bool _isLoadingAvailableMatches = true;

  @override
  void initState() {
    super.initState();
    _matchFilter = widget.player.matchId.isNotEmpty ? 'THIS MATCH' : 'CAREER';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // We try to load global stats silently
    _loadGlobalStats();
  }

  Future<void> _loadGlobalStats() async {
    try {
      final repo = context.read<MatchRepository>();
      final globalId = widget.player.globalPlayerId ?? widget.player.id;
      
      final stats = await repo.getGlobalPlayerStats(globalId);
      final matchIds = {
        ...stats['batting']!.map((e) => e.matchId), 
         ...stats['bowling']!.map((e) => e.matchId), 
         ...stats['fielding']!.map((e) => e.matchId),
         ...stats['outs']!.map((e) => e.matchId)
      }.toList();
      
      final matches = await repo.getMatchesByIds(matchIds);
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _globalStats = stats;
          _availableMatches = matches;
          _isLoadingAvailableMatches = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAvailableMatches = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MatchRepository>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('PLAYER PROFILE', style: TextStyle(fontSize: 14, letterSpacing: 1.5)),
        actions: [
          _buildFilterDropdown(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(widget.player),
          Expanded(
            child: _matchFilter == 'THIS MATCH' 
                ? _buildLiveMatchBody(repo)
                : _buildGlobalBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _matchFilter,
      dropdownColor: AppColors.background100,
      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      underline: const SizedBox.shrink(),
      onChanged: (v) {
        setState(() => _matchFilter = v!);
        if (v != 'THIS MATCH' && _globalStats == null) {
          _loadGlobalStats();
        }
      },
      items: [
        if (widget.player.matchId.isNotEmpty) const DropdownMenuItem(value: 'THIS MATCH', child: Text('THIS MATCH')),
        const DropdownMenuItem(value: 'CAREER', child: Text('CAREER STATS')),
        ..._availableMatches.map((m) {
           final date = DateFormat('dd MMM yyyy').format(m.createdAt);
           return DropdownMenuItem(value: m.id, child: Text("${m.teamAName} VS ${m.teamBName} ($date)".toUpperCase()));
        }),
      ],
    );
  }

  Widget _buildLiveMatchBody(MatchRepository repo) {
    return StreamBuilder<List<BallEvent>>(
      stream: repo.watchBallEvents(widget.player.matchId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final allEvents = snap.data ?? [];
        
        final bat = allEvents.where((e) => e.strikerId == widget.player.id).toList();
        final bowl = allEvents.where((e) => e.bowlerId == widget.player.id).toList();
        final field = allEvents.where((e) => e.fielderId == widget.player.id || e.fielderId == widget.player.globalPlayerId).toList();
        final outs = allEvents.where((e) => e.isWicket && (e.strikerId == widget.player.id || e.globalWicketPlayerId == widget.player.globalPlayerId)).toList();

        return _buildScrollableContent(bat, bowl, field, outs, isGlobal: false);
      }
    );
  }

  Widget _buildGlobalBody() {
    if (_globalStats == null) return const Center(child: CircularProgressIndicator());

    final bool isAll = _matchFilter == 'CAREER';
    final bat = isAll ? _globalStats!['batting']! : _globalStats!['batting']!.where((e) => e.matchId == _matchFilter).toList();
    final bowl = isAll ? _globalStats!['bowling']! : _globalStats!['bowling']!.where((e) => e.matchId == _matchFilter).toList();
    final field = isAll ? _globalStats!['fielding']! : _globalStats!['fielding']!.where((e) => e.matchId == _matchFilter).toList();
    final outs = isAll ? _globalStats!['outs']! : _globalStats!['outs']!.where((e) => e.matchId == _matchFilter).toList();

    return _buildScrollableContent(bat, bowl, field, outs, isGlobal: isAll);
  }

  Widget _buildScrollableContent(
    List<BallEvent> bat,
    List<BallEvent> bowl,
    List<BallEvent> field,
    List<BallEvent> outs, {
    required bool isGlobal,
  }) {
    // ─── Batting Calculations ───────────────────────────────────────────────
    final batByMatch = _groupByMatch(bat);
    final outsByMatch = _groupByMatch(outs);

    int totalRuns = bat.fold<int>(0, (s, e) => s + e.runs);
    int ballsFaced = bat.where((e) => !e.isWide && !e.isNoBall).length;
    int inningsPlayed = batByMatch.keys.length;
    int notOuts = inningsPlayed - outs.length;
    int ducks = batByMatch.entries.where((entry) {
      final matchRuns = entry.value.fold<int>(0, (s, e) => s + e.runs);
      final isOut = outsByMatch.containsKey(entry.key);
      return matchRuns == 0 && isOut;
    }).length;

    int fours = bat.where((e) => e.runs == 4).length;
    int sixes = bat.where((e) => e.runs == 6).length;

    int highestScore = 0;
    int fifties = 0;
    int hundreds = 0;
    for (var matchBat in batByMatch.values) {
      int runs = matchBat.fold<int>(0, (s, e) => s + e.runs);
      if (runs > highestScore) highestScore = runs;
      if (runs >= 100) {
        hundreds++;
      } else if (runs >= 50) {
        fifties++;
      }
    }

    double batAvg = (inningsPlayed - notOuts) > 0
        ? totalRuns / (inningsPlayed - notOuts)
        : totalRuns.toDouble();
    double strikeRate = ballsFaced > 0 ? (totalRuns / ballsFaced) * 100 : 0.0;

    // ─── Bowling Calculations ───────────────────────────────────────────────
    final bowlByMatch = _groupByMatch(bowl);
    int totalWickets = bowl.where((e) => e.isWicket && e.wicketType != 'Run Out').length;
    int runsConceded = bowl.fold<int>(0, (s, e) => s + e.totalRuns);
    int ballsBowled = bowl.where((e) => !e.isWide && !e.isNoBall).length;
    double bowlAvg = totalWickets > 0 ? runsConceded / totalWickets : 0.0;
    double econ = (ballsBowled / 6) > 0 ? runsConceded / (ballsBowled / 6) : 0.0;

    String bestBowling = "0/0";
    int maxWickets = -1;
    int minRunsForMaxWickets = 999;
    int fiveWicketsHauls = 0;

    for (var entry in bowlByMatch.entries) {
      final matchBowl = entry.value;
      int w = matchBowl.where((e) => e.isWicket && e.wicketType != 'Run Out').length;
      int r = matchBowl.fold<int>(0, (s, e) => s + e.totalRuns);
      if (w >= 5) fiveWicketsHauls++;
      if (w > maxWickets || (w == maxWickets && r < minRunsForMaxWickets)) {
        maxWickets = w;
        minRunsForMaxWickets = r;
        bestBowling = "$w/$r";
      }
    }

    int maidens = 0;
    for (var matchBowl in bowlByMatch.values) {
      final overs = _groupByOver(matchBowl);
      for (var overBalls in overs.values) {
        if (overBalls.length == 6 && overBalls.fold<int>(0, (s, e) => s + e.totalRuns) == 0) {
          maidens++;
        }
      }
    }

    // ─── Fielding Calculations ──────────────────────────────────────────────
    int catches = field.where((e) => e.wicketType == 'Caught').length;
    int runOuts = field.where((e) => e.wicketType == 'Run Out').length;
    int stumpings = field.where((e) => e.wicketType == 'Stumped').length;

    // ─── Match Summary ──────────────────────────────────────────────────────
    int totalMatches = _availableMatches.length;
    int matchesWon = 0;
    int matchesLost = 0;

    if (isGlobal) {
      for (var m in _availableMatches) {
        if (m.status == 'completed') {
           // We need to know which team the player was on. 
           // In this simplified app, we'll check any ball event from this match for this player.
           final pBat = bat.where((e) => e.matchId == m.id).firstOrNull;
           final pBowl = bowl.where((e) => e.matchId == m.id).firstOrNull;
           String? playerTeam;
           if (pBat != null) {
             playerTeam = pBat.battingTeam;
           } else if (pBowl != null) playerTeam = pBowl.battingTeam == 'A' ? 'B' : 'A';

           if (playerTeam != null && m.winnerTeamId != null) {
              if (m.winnerTeamId == playerTeam) matchesWon++;
              else if (m.winnerTeamId != 'TIE') matchesLost++;
           }
        }
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ─── Top Level Stats ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _buildStatCard('RUNS', '$totalRuns', color: AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('AVG', batAvg.toStringAsFixed(1), color: Colors.amber)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('WICKETS', '$totalWickets', color: AppColors.tertiary)),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Match Summary ───────────────────────────────────────────────
          if (isGlobal) _buildSection('📊 MATCH SUMMARY', [
            _buildStatRow('Total Matches', '$totalMatches'),
            _buildStatRow('Matches Won', '$matchesWon'),
            _buildStatRow('Matches Lost', '$matchesLost'),
          ]),
          const SizedBox(height: 16),

          // ─── Batting Stats ───────────────────────────────────────────────
          _buildSection('🏏 BATTING STATS', [
            _buildStatRow('Innings Played', '$inningsPlayed'),
            _buildStatRow('Total Runs', '$totalRuns'),
            _buildStatRow('Highest Score', '$highestScore'),
            _buildStatRow('Average', batAvg.toStringAsFixed(2)),
            _buildStatRow('Strike Rate', strikeRate.toStringAsFixed(2)),
            _buildStatRow('4s / 6s', '$fours / $sixes'),
            _buildStatRow('Not Outs', '$notOuts'),
            _buildStatRow('Ducks', '$ducks'),
            _buildStatRow('50s / 100s', '$fifties / $hundreds'),
          ]),
          const SizedBox(height: 16),

          // ─── Bowling Stats ───────────────────────────────────────────────
          _buildSection('🎯 BOWLING STATS', [
            _buildStatRow('Wickets', '$totalWickets'),
            _buildStatRow('Overs Bowled', (ballsBowled / 6).toStringAsFixed(1)),
            _buildStatRow('Runs Conceded', '$runsConceded'),
            _buildStatRow('Economy', econ.toStringAsFixed(2)),
            _buildStatRow('Bowling Avg', bowlAvg.toStringAsFixed(2)),
            _buildStatRow('Best Bowling', bestBowling),
            _buildStatRow('Maidens', '$maidens'),
            _buildStatRow('5-Wicket Hauls', '$fiveWicketsHauls'),
          ]),
          const SizedBox(height: 16),

          // ─── Fielding Stats ──────────────────────────────────────────────
          _buildSection('🧤 FIELDING STATS', [
            _buildStatRow('Catches', '$catches'),
            _buildStatRow('Run Outs', '$runOuts'),
            _buildStatRow('Stumpings', '$stumpings'),
          ]),
          const SizedBox(height: 16),

          _buildPerformanceGraph(bat),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Map<String, List<BallEvent>> _groupByMatch(List<BallEvent> events) {
    final Map<String, List<BallEvent>> map = {};
    for (var e in events) {
      map.putIfAbsent(e.matchId, () => []).add(e);
    }
    return map;
  }

  Map<int, List<BallEvent>> _groupByOver(List<BallEvent> events) {
    final Map<int, List<BallEvent>> map = {};
    for (var e in events) {
      if (!e.isWide && !e.isNoBall) {
        map.putIfAbsent(e.over, () => []).add(e);
      }
    }
    return map;
  }

  Widget _buildHeader(PlayerModel player) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.background200, width: 1)),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'player-${player.id}',
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.background300,
              child: ClipOval(
                child: player.imageUrl != null 
                  ? Image.network(player.imageUrl!, errorBuilder: (_,_,_) => Text(player.name[0], style: const TextStyle(fontSize: 32)), fit: BoxFit.cover, width: 90, height: 90)
                  : Text(player.name[0], style: const TextStyle(fontSize: 32)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(player.name.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(player.role.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(width: 8),
              if (player.jerseyNumber > 0) Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text("#${player.jerseyNumber}", style: const TextStyle(fontSize: 10, color: AppColors.tertiary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color?.withOpacity(0.3) ?? AppColors.background200, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, color: AppColors.neutral400, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.background200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 12, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(label, style: const TextStyle(color: AppColors.neutral400, fontSize: 13)), 
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
        ]
      ),
    );
  }

  Widget _buildPerformanceGraph(List<BallEvent> events) {
    final recentEvents = events.length > 20 ? events.sublist(events.length - 20) : events;
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.background100, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.background200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BATTING TREND (LAST 20 BALLS)', style: TextStyle(fontSize: 9, color: AppColors.neutral400, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            child: Row(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: recentEvents.map((e) => Expanded(
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 2),
                   height: (e.runs + 0.5) * 10.0,
                   decoration: BoxDecoration(
                     color: e.runs >= 4 ? AppColors.primary : (e.runs == 0 ? AppColors.background300 : AppColors.secondary200), 
                     borderRadius: BorderRadius.circular(3)
                   ),
                 ),
               )).toList(),
            ),
          )
        ],
      ),
    );
  }
}
