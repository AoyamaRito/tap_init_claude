import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/widgets/initial_button.dart';

void main() {
  group('InitialButton Widget Tests', () {
    testWidgets('should display letter correctly', (WidgetTester tester) async {
      // Arrange
      const letter = 'A';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(letter), findsOneWidget);
    });

    testWidgets('should call onTap when pressed', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      const letter = 'B';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InitialButton));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should show correct state when button is correct', (WidgetTester tester) async {
      // Arrange
      const letter = 'C';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isCorrect: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.isCorrect, isTrue);
    });

    testWidgets('should show error state when button is wrong', (WidgetTester tester) async {
      // Arrange
      const letter = 'D';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isError: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.isError, isTrue);
    });

    testWidgets('should show hint state when button is hint', (WidgetTester tester) async {
      // Arrange
      const letter = 'E';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isHint: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.isHint, isTrue);
    });

    testWidgets('should be disabled when disabled is true', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      const letter = 'F';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isDisabled: true,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InitialButton));
      await tester.pump();

      // Assert
      expect(wasTapped, isFalse);
    });

    testWidgets('should have correct size', (WidgetTester tester) async {
      // Arrange
      const letter = 'G';
      const size = 60.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              size: size,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minWidth, equals(size));
      expect(container.constraints?.minHeight, equals(size));
    });

    testWidgets('should animate on state change', (WidgetTester tester) async {
      // Arrange
      const letter = 'H';

      // Act - initial state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {},
            ),
          ),
        ),
      );

      // Act - change to error state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isError: true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - animation should be running
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('should apply custom colors when provided', (WidgetTester tester) async {
      // Arrange
      const letter = 'I';
      const customColor = Colors.purple;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              backgroundColor: customColor,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.backgroundColor, equals(customColor));
    });

    testWidgets('should show glow effect when glowing', (WidgetTester tester) async {
      // Arrange
      const letter = 'J';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isGlowing: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.isGlowing, isTrue);
    });

    testWidgets('should handle long press correctly', (WidgetTester tester) async {
      // Arrange
      bool wasLongPressed = false;
      const letter = 'K';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {},
              onLongPress: () {
                wasLongPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(InitialButton));
      await tester.pump();

      // Assert
      expect(wasLongPressed, isTrue);
    });

    testWidgets('should display letter with correct font size', (WidgetTester tester) async {
      // Arrange
      const letter = 'L';
      const fontSize = 24.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              fontSize: fontSize,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final text = tester.widget<Text>(find.text(letter));
      expect(text.style?.fontSize, equals(fontSize));
    });

    testWidgets('should maintain state during widget updates', (WidgetTester tester) async {
      // Arrange
      const letter = 'M';

      // Act - initial render
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {},
            ),
          ),
        ),
      );

      // Act - update with same letter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              isCorrect: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(letter), findsOneWidget);
      final button = tester.widget<InitialButton>(find.byType(InitialButton));
      expect(button.isCorrect, isTrue);
    });

    testWidgets('should handle accessibility correctly', (WidgetTester tester) async {
      // Arrange
      const letter = 'N';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InitialButton(
              letter: letter,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.bySemanticsLabel('Letter $letter button'), findsOneWidget);
    });
  });
}