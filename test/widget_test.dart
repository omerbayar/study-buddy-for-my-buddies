import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bullet_list/main.dart';
import 'package:bullet_list/providers/theme_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
        child: const StudyBuddyApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
