import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PlayerManagementScreen extends StatelessWidget {
  final bool isRoot;
  const PlayerManagementScreen({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background100,
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
        title: const Text('MANAGE PLAYERS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: Icon(Icons.search, color: AppColors.neutral400),
                filled: true,
                fillColor: AppColors.background100,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildPlayerListItem(
                    context,
                    name: 'Rahul Sharma',
                    role: 'BATSMAN',
                    imageUrl: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100',
                  ),
                  const SizedBox(height: 12),
                  _buildPlayerListItem(
                    context,
                    name: 'David Warner',
                    role: 'ALL-ROUNDER',
                    initials: 'DW',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPlayerModal(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.background, size: 32),
      ),
    );
  }

  Widget _buildPlayerListItem(BuildContext context, {required String name, required String role, String? imageUrl, String? initials}) {
    return Container(
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
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: initials != null ? Text(initials, style: const TextStyle(color: AppColors.neutral400, fontWeight: FontWeight.bold)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.neutral400),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.tertiary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showAddPlayerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background100,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColors.background300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('ADD NEW PLAYER', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background200,
                  border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: AppColors.primary),
                    Text('UPLOAD', style: TextStyle(color: AppColors.primary, fontSize: 8)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(labelText: 'FULL NAME')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'ROLE'),
                items: ['Batsman', 'Bowler', 'All-rounder', 'Wicket Keeper']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('SAVE PLAYER'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}
