import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/widgets/floating_letters.dart';

void main() {
  group('FloatingLetters Widget Tests', () {
    testWidgets('should display floating letters', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(FloatingLetters), findsOneWidget);
    });

    testWidgets('should animate letters continuously', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      
      // Let animation run for a bit
      await tester.pump(const Duration(milliseconds: 500));
      
      // Assert - should have animated widgets
      expect(find.byType(AnimatedPositioned), findsWidgets);
    });

    testWidgets('should create multiple letter widgets', (WidgetTester tester) async {
      // Arrange
      const letterCount = 10;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              letterCount: letterCount,
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.letterCount, equals(letterCount));
    });

    testWidgets('should use custom speed when provided', (WidgetTester tester) async {
      // Arrange
      const animationSpeed = 2.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              animationSpeed: animationSpeed,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.animationSpeed, equals(animationSpeed));
    });

    testWidgets('should apply custom opacity when provided', (WidgetTester tester) async {
      // Arrange
      const opacity = 0.3;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              opacity: opacity,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.opacity, equals(opacity));
    });

    testWidgets('should use custom colors when provided', (WidgetTester tester) async {
      // Arrange
      const colors = [Colors.red, Colors.blue, Colors.green];

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              colors: colors,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.colors, equals(colors));
    });

    testWidgets('should handle different font sizes', (WidgetTester tester) async {
      // Arrange
      const minFontSize = 12.0;
      const maxFontSize = 48.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              minFontSize: minFontSize,
              maxFontSize: maxFontSize,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.minFontSize, equals(minFontSize));
      expect(floatingLetters.maxFontSize, equals(maxFontSize));
    });

    testWidgets('should enable or disable glow effect', (WidgetTester tester) async {
      // Arrange
      const enableGlow = false;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              enableGlow: enableGlow,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.enableGlow, equals(enableGlow));
    });

    testWidgets('should pause and resume animation', (WidgetTester tester) async {
      // Arrange
      const isPaused = true;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              isPaused: isPaused,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.isPaused, equals(isPaused));
    });

    testWidgets('should handle custom letter set', (WidgetTester tester) async {
      // Arrange
      const customLetters = 'HELLO';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              letters: customLetters,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.letters, equals(customLetters));
    });

    testWidgets('should respect blur intensity setting', (WidgetTester tester) async {
      // Arrange
      const blurIntensity = 5.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              blurIntensity: blurIntensity,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.blurIntensity, equals(blurIntensity));
    });

    testWidgets('should maintain state when widget updates', (WidgetTester tester) async {
      // Act - initial render
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(letterCount: 5),
          ),
        ),
      );

      await tester.pump();

      // Act - update widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(letterCount: 8),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(FloatingLetters), findsOneWidget);
    });

    testWidgets('should handle direction changes', (WidgetTester tester) async {
      // Arrange
      const direction = FloatingDirection.upward;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              direction: direction,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.direction, equals(direction));
    });

    testWidgets('should apply density factor correctly', (WidgetTester tester) async {
      // Arrange
      const density = 1.5;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(
              density: density,
            ),
          ),
        ),
      );

      // Assert
      final floatingLetters = tester.widget<FloatingLetters>(find.byType(FloatingLetters));
      expect(floatingLetters.density, equals(density));
    });

    testWidgets('should handle dispose correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLetters(),
          ),
        ),
      );

      await tester.pump();

      // Act - remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      // Assert - should not throw errors
      expect(tester.takeException(), isNull);
    });
  });
}