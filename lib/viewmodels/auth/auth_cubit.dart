import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // ── One-time silent bootstrap ──────────────────────────────────────────────

  /// Called once at startup. Creates the admin credentials in Firestore 
  /// if it doesn't already exist.
  static Future<void> ensureAdminCredentials() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('admin_credentials').doc('admin');
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'username': 'BrotherzzAdmin',
          'password': 'bradmin@124',
        });
      }
    } catch (_) {
      // Ignore initial setup errors (e.g. offline)
    }
  }

  // ── Auth state on app resume ───────────────────────────────────────────────

  /// Re-hydrates auth state from local SharedPreferences.
  Future<void> checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdminLogged = prefs.getBool('is_admin') ?? false;
    if (isAdminLogged) {
      emit(const AuthAuthenticated(role: 'admin'));
    } else {
      emit(AuthInitial());
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> loginAdmin(String username, String password) async {
    emit(AuthLoading());
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('admin_credentials').limit(1).get();
      
      if (querySnapshot.docs.isEmpty) {
        emit(const AuthError('Database error: credentials not set up.'));
        return;
      }

      final data = querySnapshot.docs.first.data();
      final correctUser = data['username'] as String?;
      final correctPass = data['password'] as String?;

      if (username == correctUser && password == correctPass) {
        // Save local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_admin', true);
        
        emit(const AuthAuthenticated(role: 'admin'));
      } else {
        emit(const AuthError('Incorrect username or password.'));
      }
    } catch (_) {
      emit(const AuthError('Login failed. Check your connection.'));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin');
    emit(AuthInitial());
  }
}
