import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/player_model.dart';
import '../../repositories/match_repository.dart';

class AllPlayersScreen extends StatefulWidget {
  const AllPlayersScreen({super.key});

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MatchRepository>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('ALL PLAYERS', style: TextStyle(fontSize: 14, letterSpacing: 1.5)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search players...',
                prefixIcon: Icon(Icons.search, color: AppColors.neutral400),
                filled: true,
                // fillColor: AppColors.background100,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PlayerModel>>(
              stream: repo.watchGlobalPlayers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final players = snapshot.data!.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

                if (players.isEmpty) return const Center(child: Text('No players found.'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    return Card(
                      // color: AppColors.background100,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => context.push('/player-profile', extra: p),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.background300,
                          child: ClipOval(
                            child: p.imageUrl != null 
                              ? Image.network(p.imageUrl!, errorBuilder: (_,_,_) => Text(p.name[0]), fit: BoxFit.cover, width: 40, height: 40)
                              : Text(p.name[0]),
                          ),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p.role, style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.neutral400),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
