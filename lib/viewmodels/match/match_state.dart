import 'package:equatable/equatable.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchSetupStep1Complete extends MatchState {
  final String matchName;
  final String teamAName;
  final String teamBName;
  final int overs;

  const MatchSetupStep1Complete({
    required this.matchName,
    required this.teamAName,
    required this.teamBName,
    required this.overs,
  });

  @override
  List<Object?> get props => [matchName, teamAName, teamBName, overs];
}

class MatchSetupStep2Complete extends MatchState {
  final MatchSetupStep1Complete step1Data;

  const MatchSetupStep2Complete(this.step1Data);

  @override
  List<Object?> get props => [step1Data];
}

class MatchCreated extends MatchState {
  final String matchId;

  const MatchCreated(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class MatchError extends MatchState {
  final String message;

  const MatchError(this.message);

  @override
  List<Object?> get props => [message];
}
