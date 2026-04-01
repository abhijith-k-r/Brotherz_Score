import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void loginAdmin(String username, String password) async {
    emit(AuthLoading());
    // Simulate API call / Firebase integration here later
    await Future.delayed(const Duration(seconds: 1));
    if (username.isNotEmpty && password.isNotEmpty) {
      emit(const AuthAuthenticated(role: 'admin'));
    } else {
      emit(const AuthError('Invalid credentials'));
    }
  }

  void loginViewer() {
    emit(const AuthAuthenticated(role: 'viewer'));
  }

  void logout() {
    emit(AuthInitial());
  }
}
