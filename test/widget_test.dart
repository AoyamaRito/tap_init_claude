import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/main.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App starts and shows home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Tap Init Claude'), findsOneWidget);
      expect(find.text('Claude Code による'), findsOneWidget);
      expect(find.text('自律的開発アプリ'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('FloatingActionButton shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Claude Code が開発を支援しています！'), findsOneWidget);
    });
  });
}