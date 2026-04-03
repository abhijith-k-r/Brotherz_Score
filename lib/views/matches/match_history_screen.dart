// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';
import '../../repositories/match_repository.dart';

class MatchHistoryScreen extends StatelessWidget {
  final bool isRoot;
  final bool isAdmin;
  const MatchHistoryScreen({super.key, this.isRoot = false, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isRoot
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.neutral400),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/admin');
                  }
                },
              ),
        title: const Text('MATCH HISTORY'),
      ),
      body: StreamBuilder<List<MatchModel>>(
        stream: context.read<MatchRepository>().watchMatches(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          
          final matches = isAdmin 
            ? snap.data! 
            : snap.data!.where((m) => m.status == 'completed').toList();
          
          if (matches.isEmpty) {
            return Center(
              child: Text(isAdmin ? 'No matches created yet' : 'No completed matches yet', style: const TextStyle(color: AppColors.neutral400)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final isCompleted = match.status == 'completed';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    if (isAdmin && !isCompleted) {
                      context.push('/live-scoring', extra: match.id);
                    } else {
                      context.push('/live-match', extra: match.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.background200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              match.createdAt.toLocal().toString().substring(0, 10).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.neutral400,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${match.overs} OVERS',
                                  style: const TextStyle(
                                    color: AppColors.neutral400,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isAdmin)
                                  PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'delete') {
                                        context.read<MatchRepository>().deleteMatch(match.id);
                                      }
                                    },
                                    icon: const Icon(Icons.more_vert, color: AppColors.neutral400),
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'delete', child: Text('Delete Match', style: TextStyle(color: AppColors.tertiary))),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.background300),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                match.teamAName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Inter'),
                              ),
                            ),
                            Text(
                               isAdmin && !isCompleted ? 'Continue Scoring' : 'Tap to view',
                              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              match.teamBName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    color: AppColors.neutral500,
                                  ),
                            ),
                            Text(
                              match.matchName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                         Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.primary.withOpacity(0.1) : AppColors.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCompleted ? 'MATCH COMPLETED' : match.status.toUpperCase(),
                            style: TextStyle(
                              color: isCompleted ? AppColors.primary : AppColors.tertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
