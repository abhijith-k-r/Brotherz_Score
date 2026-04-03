// ignore_for_file: deprecated_member_use, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/ball_event_model.dart';
import '../../models/player_model.dart';
import '../../repositories/match_repository.dart';

class LiveScoringScreen extends StatefulWidget {
  final String matchId;
  const LiveScoringScreen({super.key, required this.matchId});

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen>
    with SingleTickerProviderStateMixin {
  late MatchRepository _repo;
  late TabController _tabController;
  
  late Stream<MatchModel> _matchStream;
  late Stream<List<PlayerModel>> _playersStream;
  late Stream<List<BallEvent>> _eventsStream;

  bool _isWide = false;
  bool _isNoBall = false;
  final TextEditingController _penaltyCtrl = TextEditingController(text: '1');

  PlayerModel? _striker;
  PlayerModel? _nonStriker;
  PlayerModel? _bowler;
  String? _fielderId;
  String? _wicketType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = context.read<MatchRepository>();
    // Memoize streams to prevent excessive unmounting/rebuilding
    _matchStream = _repo.watchMatch(widget.matchId);
    _playersStream = _repo.watchPlayers(widget.matchId);
    _eventsStream = _repo.watchBallEvents(widget.matchId);
  }

  @override
  void dispose() {
    _penaltyCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _recordBall(int runs, MatchModel match, List<PlayerModel> players,
      List<BallEvent> currentEvents,
      {bool isWicket = false}) async {
    if (_striker == null || _nonStriker == null || _bowler == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select Striker, Non-Striker and Bowler first!')));
      return;
    }

    final battingTeam = match.battingTeam;
    final teamPlayers = players.where((p) => p.teamId == battingTeam).toList();

    final event = BallEvent(
      id: '',
      matchId: widget.matchId,
      battingTeam: battingTeam,
      over: currentEvents.where((e) => !e.isWide && !e.isNoBall).length ~/ 6,
      ball:
          (currentEvents.where((e) => !e.isWide && !e.isNoBall).length % 6) + 1,
      runs: runs,
      isWicket: isWicket,
      isWide: _isWide,
      isNoBall: _isNoBall,
      penaltyRuns: int.tryParse(_penaltyCtrl.text) ?? 1,
      strikerId: _striker!.id,
      nonStrikerId: _nonStriker!.id,
      bowlerId: _bowler!.id,
      globalStrikerId: _striker!.globalPlayerId,
      globalBowlerId: _bowler!.globalPlayerId,
      fielderId: isWicket ? _fielderId : null,
      wicketType: isWicket ? _wicketType : null,
      recordedAt: DateTime.now(),
    );

    await _repo.recordBallEvent(event);

    if (!mounted) return;

    final updatedEvents = [...currentEvents, event];
    final inningsEvents = updatedEvents.where((e) => e.battingTeam == battingTeam).toList();
    final totalRuns = inningsEvents.fold<int>(0, (sum, e) => sum + e.totalRuns);
    final legalBalls = inningsEvents.where((e) => !e.isWide && !e.isNoBall).length;
    final totalWickets = inningsEvents.where((e) => e.isWicket).length;

    bool inningDone = legalBalls >= match.overs * 6 || totalWickets >= teamPlayers.length - 1;

    if (match.currentInnings == 2 && match.targetRuns != null) {
      if (totalRuns >= match.targetRuns!) {
        inningDone = true;
      }
    }

    if (inningDone) {
      if (match.currentInnings == 1) {
        await _repo.updateMatch(match.copyWith(
          currentInnings: 2,
          targetRuns: totalRuns + 1,
          status: 'break',
        ));
        if (mounted) _showInningsCompleteModal(battingTeam == 'A' ? match.teamAName : match.teamBName, totalRuns);
      } else {
        if (mounted) _showMatchCompleteModal(match, totalRuns);
      }
      if (mounted) {
        setState(() {
          _striker = null;
          _nonStriker = null;
          _bowler = null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          if (isWicket) {
            _striker = null;
          } else if (runs % 2 != 0 && !_isWide && !_isNoBall) {
            final temp = _striker;
            _striker = _nonStriker;
            _nonStriker = temp;
          }
          _isWide = false;
          _isNoBall = false;
          _penaltyCtrl.text = '1';
          _fielderId = null;
          _wicketType = null;
        });
      }
    }
  }

  void _showInningsCompleteModal(String teamName, int totalRuns) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background200,
        title: const Text('Innings Complete'),
        content: Text('$teamName finished their innings with $totalRuns runs.\nTarget: ${totalRuns + 1}\nPlease switch status to LIVE when ready.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showMatchCompleteModal(MatchModel match, int totalRuns) {
    String winnerId = 'TIE';
    if (match.targetRuns != null) {
      if (totalRuns >= match.targetRuns!) {
        winnerId = match.battingTeam;
      } else if (totalRuns == match.targetRuns! - 1) {
        winnerId = 'TIE';
      } else {
        winnerId = match.battingTeam == 'A' ? 'B' : 'A';
      }
    }

    String selectedWinnerId = winnerId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          String resultText = selectedWinnerId == 'TIE' ? "MATCH DRAW / TIE" : "Winner: ${selectedWinnerId == 'A' ? match.teamAName : match.teamBName}";

          return AlertDialog(
            backgroundColor: AppColors.background200,
            title: const Text('Confirm Match Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(resultText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Manually adjust result if needed:', style: TextStyle(fontSize: 10, color: AppColors.neutral400)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resultOption(match.teamAName, 'A', selectedWinnerId, (id) => setModalState(() => selectedWinnerId = id)),
                    _resultOption('DRAW', 'TIE', selectedWinnerId, (id) => setModalState(() => selectedWinnerId = id)),
                    _resultOption(match.teamBName, 'B', selectedWinnerId, (id) => setModalState(() => selectedWinnerId = id)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () async {
                  await _repo.updateMatch(match.copyWith(
                    status: 'completed',
                    winnerTeamId: selectedWinnerId,
                  ));
                  if (mounted) {
                    Navigator.pop(ctx);
                    context.go('/admin');
                  }
                },
                child: const Text('FINISH MATCH'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _resultOption(String label, String id, String current, Function(String) onSelect) {
    bool isSelected = current == id;
    return GestureDetector(
      onTap: () => onSelect(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.background300),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.neutral400, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId.isEmpty) return const Scaffold(body: Center(child: Text('Invalid Match')));

    return StreamBuilder<MatchModel>(
      stream: _matchStream,
      builder: (context, matchSnap) {
        if (matchSnap.hasError) return Scaffold(body: Center(child: Text("Match Stream Error: ${matchSnap.error}")));
        if (matchSnap.connectionState == ConnectionState.waiting && !matchSnap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!matchSnap.hasData) return const Scaffold(body: Center(child: Text('Match not found')));
        final match = matchSnap.data!;

        return StreamBuilder<List<PlayerModel>>(
          stream: _playersStream,
          builder: (context, playersSnap) {
            return StreamBuilder<List<BallEvent>>(
              stream: _eventsStream,
              builder: (context, eventsSnap) {
                if (playersSnap.hasError) return Center(child: Text("Players Error: ${playersSnap.error}"));
                if (eventsSnap.hasError) return Center(child: Text("Events Error: ${eventsSnap.error}"));
                
                if (playersSnap.connectionState == ConnectionState.waiting && !playersSnap.hasData) {
                   return const Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Syncing Lineups...", style: TextStyle(color: AppColors.neutral400, fontSize: 10))])));
                }

                final players = playersSnap.data ?? [];
                final events = eventsSnap.data ?? [];

                return Scaffold(
                  backgroundColor: AppColors.background,
                  appBar: AppBar(
                    backgroundColor: AppColors.secondary800,
                    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/admin')),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.matchName.toUpperCase(), style: const TextStyle(fontSize: 14)),
                        Text(match.status.toUpperCase(), style: const TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        onSelected: (val) {
                           if (val == 'edit') {
                             _showEditMatchModal(match);
                           } else if (val == 'draw_tie') _repo.updateMatch(match.copyWith(status: 'completed', winnerTeamId: 'TIE'));
                           else _repo.updateMatchStatus(widget.matchId, val);
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'setup', child: Text('Setup')),
                          const PopupMenuItem(value: 'live', child: Text('Live')),
                          const PopupMenuItem(value: 'break', child: Text('Break')),
                          const PopupMenuItem(value: 'completed', child: Text('Completed')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'draw_tie', child: Text('Mark as Draw / Tie')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit Match')),
                        ],
                      ),
                      IconButton(onPressed: () => _repo.deleteLastBall(widget.matchId), icon: const Icon(Icons.undo, color: AppColors.neutral300, size: 20)),
                    ],
                    bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'SCORING'), Tab(text: 'LINEUPS')]),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScoringTab(match, players, events),
                      _buildLineupTab(match, players),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScoringTab(MatchModel match, List<PlayerModel> players, List<BallEvent> events) {
    final currentInningsEvents = events.where((e) => e.battingTeam == match.battingTeam).toList();
    int totalRuns = currentInningsEvents.fold<int>(0, (sum, e) => sum + e.totalRuns);
    int totalWickets = currentInningsEvents.where((e) => e.isWicket).length;
    int legalBalls = currentInningsEvents.where((e) => !e.isWide && !e.isNoBall).length;

    return Column(
      children: [
        _buildScoreHeader(match, totalRuns, totalWickets, legalBalls),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (match.status == 'setup') _buildTossCard(match),
                _buildPlayerSelector(match, players),
                const SizedBox(height: 16),
                const Divider(color: AppColors.background300),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildExtraToggle('Wide', _isWide, (v) => setState(() => _isWide = v)),
                    const SizedBox(width: 8),
                    _buildExtraToggle('No Ball', _isNoBall, (v) => setState(() => _isNoBall = v)),
                  ],
                ),
                if (_isWide || _isNoBall) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _penaltyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Penalty Runs', filled: true, fillColor: AppColors.background200),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                      onPressed: () => _recordBall(0, match, players, events),
                      child: const Text('SUBMIT EXTRA'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildRunButton('0', () => _recordBall(0, match, players, events)),
                    _buildRunButton('1', () => _recordBall(1, match, players, events)),
                    _buildRunButton('2', () => _recordBall(2, match, players, events)),
                    _buildRunButton('3', () => _recordBall(3, match, players, events)),
                    _buildRunButton('4', () => _recordBall(4, match, players, events), color: AppColors.primary, isOutlined: true),
                    _buildRunButton('6', () => _recordBall(6, match, players, events), color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.tertiary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () => _showWicketModal(match, players, events),
                    child: Text('WICKET', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.tertiary, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTossCard(MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background200, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
      child: Column(
        children: [
           const Text('TOSS RESULT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildTossButton(match.teamAName, match.tossWinner == 'A', () => _repo.updateMatch(match.copyWith(tossWinner: 'A')))),
               const SizedBox(width: 8),
               Expanded(child: _buildTossButton(match.teamBName, match.tossWinner == 'B', () => _repo.updateMatch(match.copyWith(tossWinner: 'B')))),
             ],
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildTossButton('BAT FIRST', match.tossDecision == 'bat', () => _repo.updateMatch(match.copyWith(tossDecision: 'bat')))),
               const SizedBox(width: 8),
               Expanded(child: _buildTossButton('BOWL FIRST', match.tossDecision == 'bowl', () => _repo.updateMatch(match.copyWith(tossDecision: 'bowl')))),
             ],
           ),
           const Divider(height: 24),
           ElevatedButton(onPressed: () => _repo.updateMatchStatus(match.id, 'live'), child: const Text('START MATCH')),
        ],
      ),
    );
  }

  Widget _buildTossButton(String lbl, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.background300, borderRadius: BorderRadius.circular(8)),
        child: Text(lbl, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.neutral400)),
      ),
    );
  }

  Widget _buildScoreHeader(MatchModel match, int runs, int wickets, int balls) {
    String battingTeamName = match.battingTeam == 'A' ? match.teamAName : match.teamBName;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.secondary800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$battingTeamName (BAT)', style: const TextStyle(color: AppColors.secondary200, fontSize: 12, fontWeight: FontWeight.bold)),
              Row( crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  Text('$runs', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('/$wickets', style: const TextStyle(fontSize: 20, color: AppColors.secondary200)),
              ]),
              if (match.currentInnings == 2 && match.targetRuns != null) Text('Target: ${match.targetRuns}', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('OVERS', style: TextStyle(color: AppColors.secondary200, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${balls ~/ 6}.${balls % 6}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelector(MatchModel match, List<PlayerModel> players) {
    final battingTeam = match.battingTeam;
    final bowlingTeam = battingTeam == 'A' ? 'B' : 'A';

    final strikers = players.where((p) => p.teamId == battingTeam && p.status != 'out').toList();
    final bowlers = players.where((p) => p.teamId == bowlingTeam).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPlayerPicker('Striker', _striker?.id, strikers, (p) => setState(() => _striker = p))),
            const SizedBox(width: 8),
            Expanded(child: _buildPlayerPicker('Non-Striker', _nonStriker?.id, strikers.where((p) => p.id != _striker?.id).toList(), (p) => setState(() => _nonStriker = p))),
          ],
        ),
        const SizedBox(height: 8),
        _buildPlayerPicker('Bowler', _bowler?.id, bowlers, (p) => setState(() => _bowler = p)),
      ],
    );
  }

  Widget _buildPlayerPicker(String label, String? currentId, List<PlayerModel> options, Function(PlayerModel) onSelected) {
    final safeValue = options.any((p) => p.id == currentId) ? currentId : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.background200, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
          value: safeValue,
          items: options.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) {
            if (v != null) onSelected(options.firstWhere((p) => p.id == v));
          },
        ),
      ),
    );
  }

  void _showWicketModal(MatchModel match, List<PlayerModel> players, List<BallEvent> events) {
    final options = ['Bowled', 'Caught', 'Run Out', 'LBW', 'Stumped'];
    if (!options.contains(_wicketType)) _wicketType = options.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background100,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('RECORD WICKET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'WICKET TYPE'),
                value: _wicketType,
                items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setModalState(() => _wicketType = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _recordBall(0, match, players, events, isWicket: true);
                  Navigator.pop(ctx);
                },
                child: const Text('CONFIRM WICKET'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMatchModal(MatchModel match) {
    final nameCtrl = TextEditingController(text: match.matchName);
    final teamACtrl = TextEditingController(text: match.teamAName);
    final teamBCtrl = TextEditingController(text: match.teamBName);
    final oversCtrl = TextEditingController(text: match.overs.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background200,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Match Name')),
            TextField(controller: teamACtrl, decoration: const InputDecoration(labelText: 'Team A')),
            TextField(controller: teamBCtrl, decoration: const InputDecoration(labelText: 'Team B')),
            TextField(controller: oversCtrl, decoration: const InputDecoration(labelText: 'Overs')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _repo.updateMatch(match.copyWith(matchName: nameCtrl.text, teamAName: teamACtrl.text, teamBName: teamBCtrl.text, overs: int.tryParse(oversCtrl.text) ?? match.overs));
                Navigator.pop(ctx);
              },
              child: const Text('Update'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLineupTab(MatchModel match, List<PlayerModel> players) {
    return FutureBuilder<List<PlayerModel>>(
      future: _repo.getPlayers(match.id),
      builder: (context, futSnap) {
        final currentPlayers = players.isEmpty ? (futSnap.data ?? []) : players;
        if (currentPlayers.isEmpty && (futSnap.connectionState == ConnectionState.waiting)) {
          return const Center(child: CircularProgressIndicator());
        }
        final teamA = currentPlayers.where((p) => p.teamId == 'A').toList();
        final teamB = currentPlayers.where((p) => p.teamId == 'B').toList();
        return ListView(children: [_buildTeamSection(match.teamAName, teamA), _buildTeamSection(match.teamBName, teamB)]);
      }
    );
  }

  Widget _buildTeamSection(String name, List<PlayerModel> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary))),
        ...players.map((p) => ExpansionTile(
              title: Text(p.name),
              subtitle: Text(p.status.toUpperCase()),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(spacing: 8, children: ['ready', 'batting', 'bowling', 'out', 'not_out'].map((s) => ChoiceChip(label: Text(s.toUpperCase()), selected: p.status == s, onSelected: (val) { if (val) _repo.updatePlayer(p.copyWith(status: s)); })).toList()),
                )
              ],
            )),
      ],
    );
  }

  Widget _buildExtraToggle(String text, bool active, ValueChanged<bool> onToggle) {
    return Expanded(child: ChoiceChip(label: Text(text), selected: active, onSelected: onToggle));
  }

  Widget _buildRunButton(String run, VoidCallback onTap, {Color? color, bool isOutlined = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: isOutlined ? Colors.transparent : (color ?? AppColors.background100), foregroundColor: isOutlined ? color : Colors.white),
      onPressed: onTap,
      child: Text(run, style: const TextStyle(fontSize: 18)),
    );
  }
}
