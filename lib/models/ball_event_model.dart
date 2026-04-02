import 'package:cloud_firestore/cloud_firestore.dart';

class BallEvent {
  final String id;
  final String matchId;
  final String battingTeam; // 'A' or 'B'
  final int over;
  final int ball;
  final int runs;
  final bool isWicket;
  final bool isWide;
  final bool isNoBall;
  final bool isLegBye;
  final bool isBye;
  final int penaltyRuns;
  final String strikerId;
  final String nonStrikerId;
  final String bowlerId;
  final String? globalStrikerId;
  final String? globalBowlerId;
  final String? fielderId; // For catches/run outs
  final String? wicketType; // bowled, caught, etc.
  final DateTime recordedAt;

  const BallEvent({
    required this.id,
    required this.matchId,
    required this.battingTeam,
    required this.over,
    required this.ball,
    required this.runs,
    this.isWicket = false,
    this.isWide = false,
    this.isNoBall = false,
    this.isLegBye = false,
    this.isBye = false,
    this.penaltyRuns = 1,
    required this.strikerId,
    required this.nonStrikerId,
    required this.bowlerId,
    this.globalStrikerId,
    this.globalBowlerId,
    this.fielderId,
    this.wicketType,
    required this.recordedAt,
  });

  int get totalRuns {
    int extra = (isWide || isNoBall) ? penaltyRuns : 0;
    return runs + extra;
  }

  factory BallEvent.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BallEvent(
      id: doc.id,
      matchId: d['matchId'] ?? '',
      battingTeam: d['battingTeam'] ?? 'A',
      over: d['over'] ?? 0,
      ball: d['ball'] ?? 0,
      runs: d['runs'] ?? 0,
      isWicket: d['isWicket'] ?? false,
      isWide: d['isWide'] ?? false,
      isNoBall: d['isNoBall'] ?? false,
      isLegBye: d['isLegBye'] ?? false,
      isBye: d['isBye'] ?? false,
      penaltyRuns: d['penaltyRuns'] ?? 1,
      strikerId: d['strikerId'] ?? '',
      nonStrikerId: d['nonStrikerId'] ?? '',
      bowlerId: d['bowlerId'] ?? '',
      globalStrikerId: d['globalStrikerId'],
      globalBowlerId: d['globalBowlerId'],
      fielderId: d['fielderId'],
      wicketType: d['wicketType'],
      recordedAt: (d['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'matchId': matchId,
    'battingTeam': battingTeam,
    'over': over,
    'ball': ball,
    'runs': runs,
    'isWicket': isWicket,
    'isWide': isWide,
    'isNoBall': isNoBall,
    'isLegBye': isLegBye,
    'isBye': isBye,
    'penaltyRuns': penaltyRuns,
    'strikerId': strikerId,
    'nonStrikerId': nonStrikerId,
    'bowlerId': bowlerId,
    'globalStrikerId': globalStrikerId,
    'globalBowlerId': globalBowlerId,
    'fielderId': fielderId,
    'wicketType': wicketType,
    'recordedAt': Timestamp.fromDate(recordedAt),
  };
}
