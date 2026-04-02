import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth/auth_cubit.dart';
import 'viewmodels/match/match_cubit.dart';
import 'repositories/match_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Silent creation of default credentials in Firestore on first run
    await AuthCubit.ensureAdminCredentials();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const BrothersScoreApp());
}

class BrothersScoreApp extends StatelessWidget {
  const BrothersScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MatchRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit()..checkCurrentUser()),
          BlocProvider(create: (context) => MatchCubit(context.read<MatchRepository>())),
        ],
        child: MaterialApp.router(
          title: 'Brothers Score',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
