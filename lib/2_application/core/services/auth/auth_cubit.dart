import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../1_domain/entities/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthUnauthenticated());

  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    emit(AuthAuthenticating(rememberMe: rememberMe));
    await Future<void>.delayed(const Duration(milliseconds: 350));

    // Dev shortcut: empty form → log in as the default admin user.
    if (username.trim().isEmpty && password.isEmpty) {
      emit(AuthAuthenticated(
          user: kSeedUsers.first, rememberMe: rememberMe));
      return;
    }

    final u = username.trim().toLowerCase();
    final expected = kSeedCredentials[u];
    if (expected == null || expected != password) {
      emit(AuthError(
        message: 'Invalid username or password',
        rememberMe: rememberMe,
      ));
      return;
    }
    final user = kSeedUsers.firstWhere((x) => x.username == u);
    emit(AuthAuthenticated(user: user, rememberMe: rememberMe));
  }

  void logout() {
    emit(AuthUnauthenticated(rememberMe: state.rememberMe));
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated(rememberMe: state.rememberMe));
    }
  }
}
