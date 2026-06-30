import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:archie_pos/2_application/core/services/auth/auth_cubit.dart';
import 'package:archie_pos/2_application/core/services/go_router_service.dart';
import 'package:archie_pos/main.dart';

void main() {
  testWidgets('App boots and renders router', (WidgetTester tester) async {
    final auth = AuthCubit();
    GoRouterService.init(auth);
    await tester.pumpWidget(ArchiePosApp(authCubit: auth));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
