// ignore_for_file: use_build_context_synchronously, deprecated_member_use

  import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/role-selection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              color: AppColors.background.withOpacity(0.8),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.background100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('🏏', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(letterSpacing: 2),
                    children: const [
                      TextSpan(text: 'BROTHERS '),
                      TextSpan(text: 'SCORE', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'YOUR MATCH. YOUR STATS.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 64,
            left: 48,
            right: 48,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.background300,
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: AppColors.background300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
