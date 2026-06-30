import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '2_application/core/services/auth/auth_cubit.dart';
import '2_application/core/services/go_router_service.dart';
import '2_application/core/services/theme_service.dart';

void main() {
  final authCubit = AuthCubit();
  GoRouterService.init(authCubit);
  runApp(ArchiePosApp(authCubit: authCubit));
}

class ArchiePosApp extends StatelessWidget {
  const ArchiePosApp({super.key, required this.authCubit});
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: Consumer<ThemeService>(
          builder: (context, themeService, _) {
            return MaterialApp.router(
              title: 'ArchiePOS',
              debugShowCheckedModeBanner: false,
              theme: themeService.dark,
              darkTheme: themeService.dark,
              themeMode: themeService.mode,
              routerConfig: GoRouterService.router,
            );
          },
        ),
      ),
    );
  }
}
