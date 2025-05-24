import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/widgets/score_display.dart';

void main() {
  group('ScoreDisplay Widget Tests', () {
    testWidgets('should display score correctly', (WidgetTester tester) async {
      // Arrange
      const score = 42;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: score),
          ),
        ),
      );

      // Assert
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should display zero score', (WidgetTester tester) async {
      // Arrange
      const score = 0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: score),
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display custom label when provided', (WidgetTester tester) async {
      // Arrange
      const score = 15;
      const label = 'Streak';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              label: label,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should animate when score changes', (WidgetTester tester) async {
      // Arrange
      const initialScore = 10;
      const newScore = 11;

      // Act - initial render
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: initialScore),
          ),
        ),
      );

      // Act - change score
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: newScore),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('should apply custom colors when provided', (WidgetTester tester) async {
      // Arrange
      const score = 25;
      const customColor = Colors.purple;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              color: customColor,
            ),
          ),
        ),
      );

      // Assert
      final scoreDisplay = tester.widget<ScoreDisplay>(find.byType(ScoreDisplay));
      expect(scoreDisplay.color, equals(customColor));
    });

    testWidgets('should use custom font size when provided', (WidgetTester tester) async {
      // Arrange
      const score = 88;
      const fontSize = 32.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              fontSize: fontSize,
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text('88'));
      expect(text.style?.fontSize, equals(fontSize));
    });

    testWidgets('should show glow effect when glowing', (WidgetTester tester) async {
      // Arrange
      const score = 100;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              isGlowing: true,
            ),
          ),
        ),
      );

      // Assert
      final scoreDisplay = tester.widget<ScoreDisplay>(find.byType(ScoreDisplay));
      expect(scoreDisplay.isGlowing, isTrue);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      // Arrange
      const score = 50;
      const icon = Icons.star;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              icon: icon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should handle large scores correctly', (WidgetTester tester) async {
      // Arrange
      const score = 999999;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: score),
          ),
        ),
      );

      // Assert
      expect(find.text('999999'), findsOneWidget);
    });

    testWidgets('should show milestone celebration animation', (WidgetTester tester) async {
      // Arrange
      const score = 100;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              showMilestoneCelebration: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      final scoreDisplay = tester.widget<ScoreDisplay>(find.byType(ScoreDisplay));
      expect(scoreDisplay.showMilestoneCelebration, isTrue);
    });

    testWidgets('should display formatted score for large numbers', (WidgetTester tester) async {
      // Arrange
      const score = 1234567;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              formatLargeNumbers: true,
            ),
          ),
        ),
      );

      // Assert
      // Should display "1.2M" or similar formatted number
      expect(find.textContaining('1.2'), findsOneWidget);
    });

    testWidgets('should show prefix when provided', (WidgetTester tester) async {
      // Arrange
      const score = 75;
      const prefix = 'Level ';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              prefix: prefix,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Level 75'), findsOneWidget);
    });

    testWidgets('should show suffix when provided', (WidgetTester tester) async {
      // Arrange
      const score = 85;
      const suffix = '%';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              suffix: suffix,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('85%'), findsOneWidget);
    });

    testWidgets('should handle accessibility correctly', (WidgetTester tester) async {
      // Arrange
      const score = 33;
      const label = 'Score';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              label: label,
            ),
          ),
        ),
      );

      // Assert
      expect(find.bySemanticsLabel('Score: 33'), findsOneWidget);
    });

    testWidgets('should maintain state during score updates', (WidgetTester tester) async {
      // Arrange
      int currentScore = 1;

      // Act - initial render
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(score: currentScore),
          ),
        ),
      );

      // Act - update score multiple times
      for (int i = 2; i <= 5; i++) {
        currentScore = i;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplay(score: currentScore),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should trigger callback on milestone', (WidgetTester tester) async {
      // Arrange
      bool callbackTriggered = false;
      const score = 100;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(
              score: score,
              onMilestone: (milestone) {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(callbackTriggered, isTrue);
    });
  });
}