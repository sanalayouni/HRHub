import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/session_store.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

/// Whether a token is held. Drives the router's redirect to `/login`.
class AuthController extends StateNotifier<bool> {
  final Ref ref;

  AuthController(this.ref) : super(SessionStore.token != null) {
    // A 401 from any request logs us out, like the web client's interceptor.
    SessionStore.onUnauthorized = () {
      if (mounted) state = false;
    };
  }

  Future<void> login(String email, String password) async {
    final token = await ref.read(authRepositoryProvider).login(email, password);
    await SessionStore.saveToken(token);
    state = true;
  }

  Future<void> logout() async {
    await SessionStore.clearToken();
    state = false;
    ref.invalidate(meProvider);
  }

  @override
  void dispose() {
    SessionStore.onUnauthorized = null;
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthController, bool>(AuthController.new);

final meProvider = FutureProvider<MeOut>((ref) {
  // Re-fetch whenever we log back in.
  ref.watch(authProvider);
  return ref.watch(authRepositoryProvider).fetchMe();
});

/// Light/dark selection, persisted alongside the token.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController()
      : super(SessionStore.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light);

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await SessionStore.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) => ThemeController());
