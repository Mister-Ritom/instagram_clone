import 'dart:developer';
import 'package:flutter_riverpod/legacy.dart';
import 'package:instagram_clone/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotifier extends StateNotifier<User?> {
  final auth = Database.client.auth;

  UserNotifier() : super(Database.client.auth.currentUser);

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      final res = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        state = res.user;
        log('User logged in: ${res.user!.email}', name: 'UserNotifier');
        return true;
      } else {
        log(
          'Login failed: user not returned, maybe email not confirmed',
          name: 'UserNotifier',
        );
        return false;
      }
    } on AuthException catch (e) {
      log('Login error: ${e.message}', name: 'UserNotifier', error: e);
      return false;
    } catch (e) {
      log('Unexpected login error', name: 'UserNotifier', error: e);
      return false;
    }
  }

  /// Signup user
  Future<User?> createUser(String email, String password) async {
    try {
      final res = await auth.signUp(email: email, password: password);
      if (res.session != null) {
        state = res.user;
        log('User signed up: ${res.user!.email}', name: 'UserNotifier');
      } else {
        log(
          'Signup complete, email confirmation may be required',
          name: 'UserNotifier',
        );
      }
      return res.user;
    } on AuthException catch (e) {
      log('Signup error: ${e.message}', name: 'UserNotifier', error: e);
      return null;
    } catch (e) {
      log('Unexpected signup error', name: 'UserNotifier', error: e);
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await auth.signOut();
      state = null;
      log('User logged out', name: 'UserNotifier');
    } catch (e) {
      log('Logout error', name: 'UserNotifier', error: e);
    }
  }
}

/// Riverpod provider
final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);
