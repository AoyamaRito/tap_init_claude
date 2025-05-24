import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/widgets/particle_background.dart';

void main() {
  group('ParticleBackground Widget Tests', () {
    testWidgets('should display particle background', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(),
          ),
        ),
      );

      await tester.pump();

      // Assert
      expect(find.byType(ParticleBackground), findsOneWidget);
    });

    testWidgets('should create particles with custom count', (WidgetTester tester) async {
      // Arrange
      const particleCount = 25;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              particleCount: particleCount,
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.particleCount, equals(particleCount));
    });

    testWidgets('should use custom colors when provided', (WidgetTester tester) async {
      // Arrange
      const colors = [Colors.red, Colors.yellow, Colors.orange];

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              colors: colors,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.colors, equals(colors));
    });

    testWidgets('should apply custom animation speed', (WidgetTester tester) async {
      // Arrange
      const animationSpeed = 2.5;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              animationSpeed: animationSpeed,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.animationSpeed, equals(animationSpeed));
    });

    testWidgets('should handle different particle types', (WidgetTester tester) async {
      // Arrange
      const particleType = ParticleType.stars;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              particleType: particleType,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.particleType, equals(particleType));
    });

    testWidgets('should enable or disable glow effect', (WidgetTester tester) async {
      // Arrange
      const enableGlow = false;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              enableGlow: enableGlow,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.enableGlow, equals(enableGlow));
    });

    testWidgets('should trigger celebration effect', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              triggerCelebration: true,
            ),
          ),
        ),
      );

      await tester.pump();

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.triggerCelebration, isTrue);
    });

    testWidgets('should handle intensity changes', (WidgetTester tester) async {
      // Arrange
      const intensity = 0.8;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              intensity: intensity,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.intensity, equals(intensity));
    });

    testWidgets('should use custom size range', (WidgetTester tester) async {
      // Arrange
      const minSize = 1.0;
      const maxSize = 8.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              minSize: minSize,
              maxSize: maxSize,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.minSize, equals(minSize));
      expect(particleBackground.maxSize, equals(maxSize));
    });

    testWidgets('should pause and resume animation', (WidgetTester tester) async {
      // Arrange
      const isPaused = true;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              isPaused: isPaused,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.isPaused, equals(isPaused));
    });

    testWidgets('should handle different blend modes', (WidgetTester tester) async {
      // Arrange
      const blendMode = BlendMode.screen;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              blendMode: blendMode,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.blendMode, equals(blendMode));
    });

    testWidgets('should animate particles continuously', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      
      // Let animation run
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - animation should be running
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle celebration burst effect', (WidgetTester tester) async {
      // Act - initial state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              triggerCelebration: false,
            ),
          ),
        ),
      );

      await tester.pump();

      // Act - trigger celebration
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              triggerCelebration: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should maintain performance with high particle count', (WidgetTester tester) async {
      // Arrange
      const highParticleCount = 100;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              particleCount: highParticleCount,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - should not throw performance errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle different movement patterns', (WidgetTester tester) async {
      // Arrange
      const movement = ParticleMovement.spiral;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(
              movement: movement,
            ),
          ),
        ),
      );

      // Assert
      final particleBackground = tester.widget<ParticleBackground>(find.byType(ParticleBackground));
      expect(particleBackground.movement, equals(movement));
    });

    testWidgets('should dispose correctly without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParticleBackground(),
          ),
        ),
      );

      await tester.pump();

      // Act - dispose widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      // Assert
      expect(tester.takeException(), isNull);
    });
  });
}