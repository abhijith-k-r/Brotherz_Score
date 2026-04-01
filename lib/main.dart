import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth/auth_cubit.dart';

void main() {
  runApp(const BrothersScoreApp());
}

class BrothersScoreApp extends StatelessWidget {
  const BrothersScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        // Add MatchCubit and other viewmodels here later
      ],
      child: MaterialApp.router(
        title: 'Brothers Score',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
