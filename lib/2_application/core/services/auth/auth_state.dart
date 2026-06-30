part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState({this.currentUser, this.rememberMe = false});
  final User? currentUser;
  final bool rememberMe;

  bool get isAuthenticated => currentUser != null;

  @override
  List<Object?> get props => [currentUser?.id, rememberMe];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.rememberMe = false});
}

class AuthAuthenticating extends AuthState {
  const AuthAuthenticating({super.rememberMe = false});
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required User user,
    super.rememberMe = false,
  }) : super(currentUser: user);
}

class AuthError extends AuthState {
  const AuthError({required this.message, super.rememberMe = false});
  final String message;
  @override
  List<Object?> get props => [...super.props, message];
}
