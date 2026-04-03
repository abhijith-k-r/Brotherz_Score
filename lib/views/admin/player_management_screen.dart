// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../repositories/match_repository.dart';

class PlayerManagementScreen extends StatefulWidget {
  final bool isRoot;
  const PlayerManagementScreen({super.key, this.isRoot = false});

  @override
  State<PlayerManagementScreen> createState() => _PlayerManagementScreenState();
}

class _PlayerManagementScreenState extends State<PlayerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MatchRepository>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
        leading: widget.isRoot
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
        title: const Text('MANAGE PLAYERS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search players...',
                prefixIcon: Icon(Icons.search, color: AppColors.neutral400),
                filled: true,
                fillColor: AppColors.background100,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<PlayerModel>>(
                stream: repo.watchGlobalPlayers(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final players = snap.data!.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

                  if (players.isEmpty) {
                    return const Center(child: Text('No players found.', style: TextStyle(color: AppColors.neutral400)));
                  }

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPlayerListItem(context, repo, p),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPlayerModal(context, repo);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background, size: 32),
      ),
    );
  }

  Widget _buildPlayerListItem(BuildContext context, MatchRepository repo, PlayerModel player) {
    return GestureDetector(
      onTap: () => context.push('/player-profile', extra: player),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.background200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.background300,
              backgroundImage: player.imageUrl != null ? NetworkImage(player.imageUrl!) : null,
              child: player.imageUrl == null
                  ? Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.role,
                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.neutral400),
              onPressed: () {
                _showAddPlayerModal(context, repo, player: player);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.tertiary),
              onPressed: () {
                repo.deleteGlobalPlayer(player.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlayerModal(BuildContext context, MatchRepository repo, {PlayerModel? player}) {
    final nameCtrl = TextEditingController(text: player?.name);
    final jerseyCtrl = TextEditingController(text: player?.jerseyNumber.toString() ?? '');
    String role = player?.role ?? 'Batsman';
    String? imageUrl = player?.imageUrl;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background100,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final roles = ['Batsman', 'Bowler', 'Pace Bowler', 'Spin Bowler', 'All-rounder', 'Wicket Keeper', 'WK/Batsman'];
            if (!roles.contains(role)) role = roles.first;

            Future<void> pickAndUploadImage() async {
              final picker = ImagePicker();
              final file = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 512,
                maxHeight: 512,
                imageQuality: 70,
              );
              if (file == null) return;

              setModalState(() => isUploading = true);
              try {
                final cloudUrl = await CloudinaryService.uploadImage(File(file.path));
                if (cloudUrl != null) {
                  setModalState(() => imageUrl = cloudUrl);
                }
              } catch (_) {
              } finally {
                setModalState(() => isUploading = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColors.background300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text(player == null ? 'ADD NEW PLAYER' : 'EDIT PLAYER', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: isUploading ? null : pickAndUploadImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background200,
                          border: Border.all(color: AppColors.primary),
                          image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null,
                        ),
                        child: isUploading
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : (imageUrl == null ? const Icon(Icons.camera_alt, color: AppColors.primary) : null),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'FULL NAME')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'ROLE'),
                            value: role,
                            items: roles
                                .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (v) { if (v != null) role = v; },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: jerseyCtrl,
                            decoration: const InputDecoration(labelText: 'JERSEY NO.'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty) return;
                          final newPlayer = PlayerModel(
                            id: player?.id ?? '',
                            matchId: player?.matchId ?? '',
                            teamId: player?.teamId ?? '',
                            name: nameCtrl.text.trim(),
                            role: role,
                            imageUrl: imageUrl,
                            isStarting11: player?.isStarting11 ?? false,
                            jerseyNumber: int.tryParse(jerseyCtrl.text) ?? 0,
                          );
                          if (player == null) {
                            await repo.addGlobalPlayer(newPlayer);
                          } else {
                            await repo.updateGlobalPlayer(newPlayer);
                          }
                          if (context.mounted) context.pop();
                        },
                        child: const Text('SAVE PLAYER'),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
