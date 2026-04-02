import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String matchName;
  final String teamAName;
  final String teamBName;
  final int overs;
  final String status; // 'setup', 'live', 'break', 'completed'
  final DateTime createdAt;
  final String tossWinner; // 'A' or 'B'
  final String tossDecision; // 'bat' or 'bowl'
  final int currentInnings; // 1 or 2

  const MatchModel({
    required this.id,
    required this.matchName,
    required this.teamAName,
    required this.teamBName,
    required this.overs,
    this.status = 'setup',
    this.tossWinner = 'A',
    this.tossDecision = 'bat',
    this.currentInnings = 1,
    required this.createdAt,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      matchName: data['matchName'] ?? '',
      teamAName: data['teamAName'] ?? '',
      teamBName: data['teamBName'] ?? '',
      overs: data['overs'] ?? 10,
      status: data['status'] ?? 'setup',
      tossWinner: data['tossWinner'] ?? 'A',
      tossDecision: data['tossDecision'] ?? 'bat',
      currentInnings: data['currentInnings'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
      'matchName': matchName,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'overs': overs,
      'status': status,
      'tossWinner': tossWinner,
      'tossDecision': tossDecision,
      'currentInnings': currentInnings,
      'createdAt': Timestamp.fromDate(createdAt),
    };

  MatchModel copyWith({
    String? matchName,
    String? teamAName,
    String? teamBName,
    int? overs,
    String? status,
    String? tossWinner,
    String? tossDecision,
    int? currentInnings,
  }) {
    return MatchModel(
      id: id,
      matchName: matchName ?? this.matchName,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      overs: overs ?? this.overs,
      status: status ?? this.status,
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
      currentInnings: currentInnings ?? this.currentInnings,
      createdAt: createdAt,
    );
  }
}
