import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/theme_cubit.dart';

class ThemeSwitchAnimation extends StatefulWidget {
  final Widget child;
  const ThemeSwitchAnimation({super.key, required this.child});

  @override
  State<ThemeSwitchAnimation> createState() => _ThemeSwitchAnimationState();
}

class _ThemeSwitchAnimationState extends State<ThemeSwitchAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;
  ThemeMode? _prevMode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThemeCubit, ThemeMode>(
      listener: (context, mode) {
        if (_prevMode != null && _prevMode != mode) {
          _controller.forward(from: 0).then((_) {
            if (mounted) setState(() => _isAnimating = false);
          });
          setState(() => _isAnimating = true);
        }
        _prevMode = mode;
      },
      child: Stack(
        children: [
          widget.child,
          if (_isAnimating) 
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Determine overlay color (color of the mode we ARE switching to)
                Color overlayColor = _prevMode == ThemeMode.dark ? Colors.white : const Color(0xFF0F172A);
                return ClipPath(
                  clipper: WaveClipper(_controller.value),
                  child: Container(
                    color: overlayColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double progress;
  WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Wave sweeping from top-right to bottom-left
    // Center of expansion is Top-Right (size.width, 0)
    
    double diagonal = sqrt(size.width * size.width + size.height * size.height);
    double radius = diagonal * progress * 1.2;
    
    path.moveTo(size.width, 0);
    
    // Create a wavy arc/shore line
    for (double i = 0; i <= 100; i++) {
        double angle = (pi / 2) + (pi / 2) * (i / 100);
        // Add some noise/wave to the radius
        double waveProgress = progress < 0.5 ? progress : (1 - progress);
        double distort = 40 * waveProgress * sin(i * 0.15 + progress * 10);
        
        double x = size.width + (radius + distort) * cos(angle);
        double y = (radius + distort) * sin(angle);
        
        path.lineTo(x.clamp(0, size.width), y.clamp(0, size.height));
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
