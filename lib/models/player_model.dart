import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel {
  final String id;
  final String matchId;
  final String teamId; // 'A' or 'B'
  final String name;
  final String role; // Batsman | Bowler | All-rounder | Wicket Keeper
  final String? imageUrl;
  final bool isStarting11;
  final int jerseyNumber;
  final String status; // 'ready', 'batting', 'bowling', 'not_out', 'out', 'sub'
  final String? globalPlayerId; // Links to the global registry

  const PlayerModel({
    required this.id,
    required this.matchId,
    required this.teamId,
    required this.name,
    required this.role,
    this.imageUrl,
    required this.isStarting11,
    required this.jerseyNumber,
    this.status = 'ready',
    this.globalPlayerId,
  });

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      teamId: data['teamId'] ?? 'A',
      name: data['name'] ?? '',
      role: data['role'] ?? 'Batsman',
      imageUrl: data['imageUrl'],
      isStarting11: data['isStarting11'] ?? false,
      jerseyNumber: data['jerseyNumber'] ?? 0,
      status: data['status'] ?? 'ready',
      globalPlayerId: data['globalPlayerId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'matchId': matchId,
    'teamId': teamId,
    'name': name,
    'role': role,
    'imageUrl': imageUrl,
    'isStarting11': isStarting11,
    'jerseyNumber': jerseyNumber,
    'status': status,
    'globalPlayerId': globalPlayerId,
  };

  PlayerModel copyWith({
    String? id,
    String? matchId,
    String? teamId,
    String? name,
    String? role,
    String? imageUrl,
    bool? isStarting11,
    String? status,
    String? globalPlayerId,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      isStarting11: isStarting11 ?? this.isStarting11,
      jerseyNumber: jerseyNumber,
      status: status ?? this.status,
      globalPlayerId: globalPlayerId ?? this.globalPlayerId,
    );
  }
}
