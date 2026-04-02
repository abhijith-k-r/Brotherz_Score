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

import '../../viewmodels/auth/auth_cubit.dart';
import '../../models/player_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Shared Transition Builders ─────────────────────────────────────────────

Widget _fadeSlide(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
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
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _slideFromBottom(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
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
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthAuthenticated && authState.role == 'admin';
      final goingToAdmin =
          state.matchedLocation.startsWith('/admin') ||
          state.matchedLocation.startsWith('/create-match') ||
          state.matchedLocation.startsWith('/live-scoring');
      final goingToAdminLogin = state.matchedLocation == '/admin-login';

      if (!isLoggedIn && goingToAdmin) {
        return '/admin-login';
      }
      if (isLoggedIn && goingToAdminLogin) {
        return '/admin';
      }
      return null;
    },
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
        pageBuilder: (context, state) {
          final matchId = state.extra as String?;
          return CustomTransitionPage(
            child: LiveScoringScreen(matchId: matchId ?? ''),
            transitionsBuilder: _slideFromRight,
          );
        },
      ),

      // ── Viewer deep pages ──
      GoRoute(
        path: '/live-match',
        name: 'liveMatch',
        pageBuilder: (context, state) {
          final matchId = state.extra as String?;
          if (matchId == null) {
            return CustomTransitionPage(
              child: const Scaffold(body: Center(child: Text("Invalid Route: Missing Match ID"))),
              transitionsBuilder: _slideFromRight,
            );
          }
          return CustomTransitionPage(
            child: LiveMatchScreen(matchId: matchId),
            transitionsBuilder: _slideFromRight,
          );
        },
      ),
      GoRoute(
        path: '/player-profile',
        name: 'playerProfile',
        pageBuilder: (context, state) {
          final player = state.extra as PlayerModel?;
          return CustomTransitionPage(
            child: PlayerProfileScreen(player: player ?? const PlayerModel(id: '', matchId: '', teamId: 'A', name: 'Unknown', role: 'Batsman', isStarting11: true, jerseyNumber: 0)),
            transitionsBuilder: _slideFromRight,
          );
        }
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
