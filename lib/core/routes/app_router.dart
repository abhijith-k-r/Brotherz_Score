import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../views/splash_screen.dart';
import '../../views/auth/role_selection_screen.dart';
import '../../views/auth/admin_login_screen.dart';
import '../../views/layouts/viewer_base_screen.dart';
import '../../views/layouts/admin_base_screen.dart';
import '../../views/viewer/live_match_screen.dart';
import '../../views/admin/create_match_screen.dart';
import '../../views/admin/live_scoring_screen.dart';
import '../../views/profile/player_profile_screen.dart';
import '../../views/matches/full_scorecard_screen.dart';

// ─── Shared Transition Builders ─────────────────────────────────────────────

Widget _fadeSlide(
    BuildContext context, Animation<double> animation,
    Animation<double> secondary, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

Widget _slideFromRight(
    BuildContext context, Animation<double> animation,
    Animation<double> secondary, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _slideFromBottom(
    BuildContext context, Animation<double> animation,
    Animation<double> secondary, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

// ─── Router ─────────────────────────────────────────────────────────────────

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── App entry ──
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RoleSelectionScreen(),
          transitionsBuilder: _fadeSlide,
        ),
      ),

      // ── Auth ──
      GoRoute(
        path: '/admin-login',
        name: 'adminLogin',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AdminLoginScreen(),
          transitionsBuilder: _slideFromRight,
        ),
      ),

      // ── Main shells (Bottom NavBar) ──
      GoRoute(
        path: '/viewer',
        name: 'viewerBase',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ViewerBaseScreen(),
          transitionsBuilder: _fadeSlide,
        ),
      ),
      GoRoute(
        path: '/admin',
        name: 'adminBase',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AdminBaseScreen(),
          transitionsBuilder: _fadeSlide,
        ),
      ),

      // ── Admin deep pages ──
      GoRoute(
        path: '/create-match',
        name: 'createMatch',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CreateMatchScreen(),
          transitionsBuilder: _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/live-scoring',
        name: 'liveScoring',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LiveScoringScreen(),
          transitionsBuilder: _slideFromRight,
        ),
      ),

      // ── Viewer deep pages ──
      GoRoute(
        path: '/live-match',
        name: 'liveMatch',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LiveMatchScreen(),
          transitionsBuilder: _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/player-profile',
        name: 'playerProfile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PlayerProfileScreen(),
          transitionsBuilder: _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/full-scorecard',
        name: 'fullScorecard',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const FullScorecardScreen(),
          transitionsBuilder: _slideFromBottom,
        ),
      ),
    ],
  );
}
