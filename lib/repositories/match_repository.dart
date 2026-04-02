import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/player_model.dart';
import '../models/ball_event_model.dart';

class MatchRepository {
  final _db = FirebaseFirestore.instance;

  // ── Match CRUD ─────────────────────────────────────────────────────────────

  Future<String> createMatch(MatchModel match) async {
    final ref = await _db.collection('matches').add(match.toFirestore());
    return ref.id;
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    await _db.collection('matches').doc(matchId).update({'status': status});
  }

  Future<void> updateMatch(MatchModel match) async {
    await _db.collection('matches').doc(match.id).update(match.toFirestore());
  }

  Future<void> deleteMatch(String matchId) async {
    await _db.collection('matches').doc(matchId).delete();
  }

  Stream<MatchModel> watchMatch(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .map((snap) => MatchModel.fromFirestore(snap));
  }

  Future<List<MatchModel>> getMatches() async {
    final snap = await _db
        .collection('matches')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(MatchModel.fromFirestore).toList();
  }

  Stream<List<MatchModel>> watchMatches() {
    return _db
        .collection('matches')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MatchModel.fromFirestore).toList());
  }

  // --- Global Players ---
  Stream<List<PlayerModel>> watchGlobalPlayers() {
    return _db.collection('players').snapshots().map((snap) {
      return snap.docs.map((doc) => PlayerModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addGlobalPlayer(PlayerModel player) async {
    final docRef = _db.collection('players').doc();
    await docRef.set(player.copyWith(id: docRef.id).toFirestore());
  }

  Future<void> updateGlobalPlayer(PlayerModel player) async {
    await _db.collection('players').doc(player.id).update(player.toFirestore());
  }

  Future<void> deleteGlobalPlayer(String playerId) async {
    await _db.collection('players').doc(playerId).delete();
  }

  // --- Players (Per Match Details) ---

  Future<String> addPlayer(PlayerModel player) async {
    final ref = await _db
        .collection('matches')
        .doc(player.matchId)
        .collection('players')
        .add(player.toFirestore());
    return ref.id;
  }

  Future<void> updatePlayer(PlayerModel player) async {
    await _db
        .collection('matches')
        .doc(player.matchId)
        .collection('players')
        .doc(player.id)
        .update(player.toFirestore());
  }

  Future<void> deletePlayer(String matchId, String playerId) async {
    await _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .doc(playerId)
        .delete();
  }

  Future<List<PlayerModel>> getPlayers(String matchId, {String? teamId}) async {
    Query<Map<String, dynamic>> query = _db
        .collection('matches')
        .doc(matchId)
        .collection('players');
    if (teamId != null) {
      query = query.where('teamId', isEqualTo: teamId);
    }
    final snap = await query.orderBy('jerseyNumber').get();
    return snap.docs.map(PlayerModel.fromFirestore).toList();
  }

  Stream<List<PlayerModel>> watchPlayers(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .orderBy('jerseyNumber')
        .snapshots()
        .map((snap) => snap.docs.map(PlayerModel.fromFirestore).toList());
  }

  // ── Ball Events ────────────────────────────────────────────────────────────

  Future<void> recordBallEvent(BallEvent event) async {
    await _db
        .collection('matches')
        .doc(event.matchId)
        .collection('ballEvents')
        .add(event.toFirestore());
  }

  Future<void> deleteLastBall(String matchId) async {
    final snap = await _db
        .collection('matches')
        .doc(matchId)
        .collection('ballEvents')
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.delete();
    }
  }

  Stream<List<BallEvent>> watchBallEvents(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('ballEvents')
        .orderBy('recordedAt')
        .snapshots()
        .map((snap) => snap.docs.map(BallEvent.fromFirestore).toList());
  }

  Stream<List<BallEvent>> watchGlobalPlayerStats(String globalPlayerId) {
    return _db
        .collectionGroup('ballEvents')
        .where('globalStrikerId', isEqualTo: globalPlayerId)
        .snapshots()
        .map((snap) => snap.docs.map(BallEvent.fromFirestore).toList());
  }

  Stream<List<BallEvent>> watchGlobalBowlerStats(String globalPlayerId) {
    return _db
        .collectionGroup('ballEvents')
        .where('globalBowlerId', isEqualTo: globalPlayerId)
        .snapshots()
        .map((snap) => snap.docs.map(BallEvent.fromFirestore).toList());
  }
}
