// ignore_for_file: deprecated_member_use

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
  }

  @override
  void dispose() {
    _penaltyCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _recordBall(int runs, {bool isWicket = false}) async {
    if (_striker == null || _nonStriker == null || _bowler == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Striker, Non-Striker and Bowler first!')),
      );
      return;
    }

    final event = BallEvent(
      id: '',
      matchId: widget.matchId,
      battingTeam: 'A', // Should be dynamic based on current innings
      over: 0,
      ball: 0,
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

    setState(() {
      _isWide = false;
      _isNoBall = false;
      _penaltyCtrl.text = '1';
      if (isWicket) {
        _striker = null;
        _fielderId = null;
        _wicketType = null;
      }
      if (runs % 2 != 0 && !isWicket) {
        final temp = _striker;
        _striker = _nonStriker;
        _nonStriker = temp;
      }
    });
  }

  void _undo() async {
    await _repo.deleteLastBall(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invalid Match')),
        body: const Center(child: Text('No match selected.')),
      );
    }

    return StreamBuilder<MatchModel>(
      stream: _repo.watchMatch(widget.matchId),
      builder: (context, matchSnap) {
        if (!matchSnap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final match = matchSnap.data!;

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
            title: Text(
              match.matchName.toUpperCase(),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditMatchModal(match);
                  } else {
                    _repo.updateMatchStatus(widget.matchId, val);
                  }
                },
                icon: Icon(
                  match.status == 'live'
                      ? Icons.sensors
                      : match.status == 'break'
                          ? Icons.pause_circle
                          : match.status == 'completed'
                              ? Icons.check_circle
                              : Icons.settings,
                  color: match.status == 'live' ? AppColors.tertiary : Colors.white,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'setup', child: Text('Setup')),
                  const PopupMenuItem(value: 'live', child: Text('Live')),
                  const PopupMenuItem(value: 'break', child: Text('Break')),
                  const PopupMenuItem(value: 'completed', child: Text('Completed')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Match Details')),
                ],
              ),
              IconButton(onPressed: _undo, icon: const Icon(Icons.undo, color: AppColors.neutral300, size: 20)),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'SCORING'), Tab(text: 'LINEUPS')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildScoringTab(match), _buildLineupTab(match)],
          ),
        );
      },
    );
  }

  Widget _buildScoringTab(MatchModel match) {
    return StreamBuilder<List<BallEvent>>(
      stream: _repo.watchBallEvents(widget.matchId),
      builder: (context, runsSnap) {
        final events = runsSnap.data ?? [];
        int totalRuns = events.fold(0, (sum, e) => sum + e.totalRuns);
        int totalWickets = events.where((e) => e.isWicket).length;

        int legalBalls = events.where((e) => !e.isWide && !e.isNoBall).length;
        int overs = legalBalls ~/ 6;
        int balls = legalBalls % 6;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.secondary800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.teamAName} (BATTING)',
                        style: const TextStyle(
                          color: AppColors.secondary200,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$totalRuns',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 48,
                                  height: 1,
                                ),
                          ),
                          Text(
                            '/$totalWickets',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.secondary200,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'OVERS',
                        style: TextStyle(
                          color: AppColors.secondary200,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '$overs.$balls',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     children: [
                        _buildPlayerSelector(match),
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
                            decoration: const InputDecoration(
                              labelText: 'Penalty Runs (Dafault 1)',
                              filled: true,
                              fillColor: AppColors.background200,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.background),
                              onPressed: () => _recordBall(0),
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
                            _buildRunButton(context, '0', () => _recordBall(0)),
                            _buildRunButton(context, '1', () => _recordBall(1)),
                            _buildRunButton(context, '2', () => _recordBall(2)),
                            _buildRunButton(context, '3', () => _recordBall(3)),
                            _buildRunButton(context, '4', () => _recordBall(4), color: AppColors.primary, isOutlined: true),
                            _buildRunButton(context, '6', () => _recordBall(6), color: AppColors.primary),
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
                            onPressed: () => _showWicketModal(),
                            child: Text('WICKET', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.tertiary, letterSpacing: 2)),
                          ),
                        ),
                     ],
                   ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerSelector(MatchModel match) {
    return StreamBuilder<List<PlayerModel>>(
      stream: _repo.watchPlayers(widget.matchId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final players = snap.data!;
        final teamA = players.where((p) => p.teamId == 'A').toList(); 
        final teamB = players.where((p) => p.teamId == 'B').toList();

        final strikers = teamA.where((p) => p.status != 'out').toList();
        final bowlers = teamB.toList();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildPlayerPicker('Striker', _striker?.id, strikers, (p) => setState(() => _striker = p)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPlayerPicker('Non-Striker', _nonStriker?.id, strikers.where((p) => p.id != _striker?.id).toList(), (p) => setState(() => _nonStriker = p)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPlayerPicker('Bowler', _bowler?.id, bowlers, (p) => setState(() => _bowler = p)),
          ],
        );
      }
    );
  }

  Widget _buildPlayerPicker(String label, String? currentId, List<PlayerModel> options, Function(PlayerModel) onSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.background200, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
          value: currentId,
          items: options.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) { 
            if (v != null) {
              final player = options.firstWhere((p) => p.id == v);
              onSelected(player);
            }
          },
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
      backgroundColor: AppColors.background100,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('EDIT MATCH DETAILS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'MATCH NAME')),
            const SizedBox(height: 12),
            TextField(controller: teamACtrl, decoration: const InputDecoration(labelText: 'TEAM A')),
            const SizedBox(height: 12),
            TextField(controller: teamBCtrl, decoration: const InputDecoration(labelText: 'TEAM B')),
            const SizedBox(height: 12),
            TextField(controller: oversCtrl, decoration: const InputDecoration(labelText: 'OVERS'), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _repo.updateMatch(match.copyWith(
                    matchName: nameCtrl.text,
                    teamAName: teamACtrl.text,
                    teamBName: teamBCtrl.text,
                    overs: int.tryParse(oversCtrl.text) ?? match.overs,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('SAVE CHANGES'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showWicketModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background100,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('RECORD WICKET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'WICKET TYPE'),
                    value: _wicketType,
                    items: ['Bowled', 'Caught', 'Run Out', 'LBW', 'Stumped'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setModalState(() => _wicketType = v),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _recordBall(0, isWicket: true);
                      Navigator.pop(context);
                    },
                    child: const Text('CONFIRM WICKET'),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildLineupTab(MatchModel match) {
    return StreamBuilder<List<PlayerModel>>(
      stream: _repo.watchPlayers(widget.matchId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final players = snap.data!;
        final teamA = players.where((p) => p.teamId == 'A').toList();
        final teamB = players.where((p) => p.teamId == 'B').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTeamSection(match.teamAName, teamA),
            const SizedBox(height: 24),
            _buildTeamSection(match.teamBName, teamB),
          ],
        );
      },
    );
  }

  Widget _buildTeamSection(String teamName, List<PlayerModel> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...players.map((p) => _buildPlayerStatusTile(p)),
      ],
    );
  }

  Widget _buildPlayerStatusTile(PlayerModel player) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundImage: player.imageUrl != null ? NetworkImage(player.imageUrl!) : null,
        backgroundColor: AppColors.background200,
        child: player.imageUrl == null ? Text(player.name[0]) : null,
      ),
      title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(player.status.toUpperCase(), style: TextStyle(color: player.status == 'batting' || player.status == 'bowling' ? AppColors.tertiary : AppColors.neutral400, fontSize: 10, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            children: ['ready', 'batting', 'bowling', 'not_out', 'out', 'sub'].map((status) {
              final isSelected = player.status == status;
              return ChoiceChip(
                label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    _repo.updatePlayer(player.copyWith(status: status));
                  }
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildExtraToggle(String text, bool active, ValueChanged<bool> onToggle) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onToggle(!active),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.2) : AppColors.background200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.primary : AppColors.background300),
          ),
          alignment: Alignment.center,
          child: Text(text.toUpperCase(), style: TextStyle(color: active ? AppColors.primary : AppColors.neutral300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        ),
      ),
    );
  }

  Widget _buildRunButton(BuildContext context, String run, VoidCallback onTap, {Color? color, bool isOutlined = false}) {
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
          onTap: onTap,
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
