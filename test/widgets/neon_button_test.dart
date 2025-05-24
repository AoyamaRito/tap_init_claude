import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/widgets/neon_button.dart';

void main() {
  group('NeonButton Widget Tests', () {
    testWidgets('should display button text correctly', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'START GAME';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      const buttonText = 'TAP ME';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should not respond to taps when disabled', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      const buttonText = 'DISABLED';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {
                wasPressed = true;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isFalse);
    });

    testWidgets('should show loading state correctly', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'LOADING';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should apply custom color correctly', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'COLORED';
      const customColor = Colors.red;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              color: customColor,
            ),
          ),
        ),
      );

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.color, equals(customColor));
    });

    testWidgets('should use custom size when provided', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'SIZED';
      const customSize = Size(200, 60);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              size: customSize,
            ),
          ),
        ),
      );

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.size, equals(customSize));
    });

    testWidgets('should animate on tap', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'ANIMATE';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Tap and let animation run
      await tester.tap(find.byType(NeonButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - should have animation controllers
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'WITH ICON';
      const icon = Icons.play_arrow;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              icon: icon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should handle different styles', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'OUTLINED';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              style: NeonButtonStyle.outlined,
            ),
          ),
        ),
      );

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.style, equals(NeonButtonStyle.outlined));
    });

    testWidgets('should show glow effect when enabled', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'GLOWING';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              enableGlow: true,
            ),
          ),
        ),
      );

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.enableGlow, isTrue);
    });

    testWidgets('should handle custom font size', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'BIG TEXT';
      const fontSize = 24.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              fontSize: fontSize,
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text(buttonText));
      expect(text.style?.fontSize, equals(fontSize));
    });

    testWidgets('should pulse when pulsing is enabled', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'PULSING';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              isPulsing: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.isPulsing, isTrue);
    });

    testWidgets('should handle accessibility correctly', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'ACCESSIBLE';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.bySemanticsLabel(buttonText), findsOneWidget);
    });

    testWidgets('should handle border radius customization', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'ROUNDED';
      const borderRadius = 20.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              borderRadius: borderRadius,
            ),
          ),
        ),
      );

      // Assert
      final neonButton = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(neonButton.borderRadius, equals(borderRadius));
    });

    testWidgets('should maintain state during updates', (WidgetTester tester) async {
      // Arrange
      const initialText = 'INITIAL';
      const updatedText = 'UPDATED';

      // Act - initial render
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: initialText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act - update text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: updatedText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(updatedText), findsOneWidget);
      expect(find.text(initialText), findsNothing);
    });

    testWidgets('should handle long press correctly', (WidgetTester tester) async {
      // Arrange
      bool wasLongPressed = false;
      const buttonText = 'LONG PRESS';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: buttonText,
              onPressed: () {},
              onLongPress: () {
                wasLongPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(NeonButton));
      await tester.pump();

      // Assert
      expect(wasLongPressed, isTrue);
    });
  });
}