import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/app_routes.dart';
import '../../core/services/auth/auth_cubit.dart';
import '../../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<AuthCubit>().login(
          username: _usernameCtrl.text,
          password: _passwordCtrl.text,
          rememberMe: _rememberMe,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthAuthenticated && prev is! AuthAuthenticated,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Welcome back, ${state.currentUser!.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.orderAdd);
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 28),
                    _LoginCard(
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      obscure: _obscure,
                      rememberMe: _rememberMe,
                      onObscureToggle: () =>
                          setState(() => _obscure = !_obscure),
                      onRememberMe: (v) => setState(() => _rememberMe = v),
                      onSubmit: () => _submit(context),
                    ),
                    const SizedBox(height: 16),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Brand header ──────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandAmber, AppColors.brandAmberDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandAmber.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'A',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'ArchiePOS',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to your store',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

// ─── Login form card ───────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.rememberMe,
    required this.onObscureToggle,
    required this.onRememberMe,
    required this.onSubmit,
  });

  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final bool rememberMe;
  final VoidCallback onObscureToggle;
  final ValueChanged<bool> onRememberMe;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final loading = state is AuthAuthenticating;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state is AuthError) ...[
                _ErrorBanner(message: state.message),
                const SizedBox(height: 14),
              ],
              const Text(
                'Username',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: usernameCtrl,
                enabled: !loading,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) => context.read<AuthCubit>().clearError(),
                decoration: const InputDecoration(
                  hintText: 'admin / nena / cashier',
                  prefixIcon: Icon(Icons.person_outline,
                      color: AppColors.textTertiary, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Forgot password — ask the store owner for a reset code'),
                          backgroundColor: AppColors.darkSurfaceElevated,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandAmber,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passwordCtrl,
                enabled: !loading,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                onChanged: (_) => context.read<AuthCubit>().clearError(),
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: 'Your password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textTertiary, size: 20),
                  suffixIcon: IconButton(
                    onPressed: onObscureToggle,
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: loading
                          ? null
                          : (v) => onRememberMe(v ?? false),
                      activeColor: AppColors.brandAmber,
                      side: const BorderSide(color: AppColors.textTertiary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Keep me signed in on this device',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              const _Hint(),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: AppColors.brandAmber, size: 14),
              SizedBox(width: 6),
              Text(
                'DEV MODE',
                style: TextStyle(
                  color: AppColors.brandAmber,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Click Sign In with empty fields to log in as admin.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Or use a demo cred:  admin / admin123  ·  nena / 1234  ·  cashier / 1234',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'v1.0.0  ·  Device POS-A8F2-3C91',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
