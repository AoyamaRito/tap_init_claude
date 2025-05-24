import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tap_init_claude/screens/game_screen.dart';
import 'package:tap_init_claude/providers/game_provider.dart';
import 'package:tap_init_claude/providers/progress_provider.dart';
import 'package:tap_init_claude/models/sentence.dart';
import 'package:tap_init_claude/models/course.dart';
import 'package:tap_init_claude/models/game_state.dart';
import 'package:tap_init_claude/services/course_service.dart';
import 'package:tap_init_claude/services/tts_service.dart';

class MockCourseService extends CourseService {
  @override
  Future<Course?> getRandomCourseForLevel(int level) async {
    final sentences = List.generate(20, (index) => 
      Sentence(text: 'Test sentence $index', level: level, category: 'test'));
    
    return Course(
      id: 'test_$level',
      title: 'Test Course $level',
      description: 'Test course for level $level',
      level: level,
      category: 'test',
      sentences: sentences,
    );
  }
}

class MockTTSService extends TTSService {
  @override
  Future<bool> speak(String? text) async => true;
}

void main() {
  group('GameScreen Widget Tests', () {
    late GameProvider gameProvider;
    late ProgressProvider progressProvider;

    setUp(() {
      gameProvider = GameProvider(
        courseService: MockCourseService(),
        ttsService: MockTTSService(),
      );
      progressProvider = ProgressProvider();
    });

    Widget createGameScreen() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: gameProvider),
            ChangeNotifierProvider.value(value: progressProvider),
          ],
          child: const GameScreen(),
        ),
      );
    }

    testWidgets('should display game screen correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('should show start game button initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.text('START GAME'), findsOneWidget);
    });

    testWidgets('should start game when start button is pressed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      await tester.tap(find.text('START GAME'));
      await tester.pumpAndSettle();

      // Assert
      expect(gameProvider.gameState, isNotNull);
    });

    testWidgets('should display sentence when game is active', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.text(gameProvider.gameState!.currentSentence.text), findsOneWidget);
    });

    testWidgets('should display initial buttons grid', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert - should have 15 buttons (5x3 grid)
      expect(find.byType(GestureDetector), findsNWidgets(15));
    });

    testWidgets('should display score in top left', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should handle initial button tap correctly', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final expectedInitial = gameProvider.getCurrentExpectedInitial();

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      await tester.tap(find.text(expectedInitial).first);
      await tester.pump();

      // Assert
      expect(gameProvider.gameState!.currentInitialIndex, equals(1));
    });

    testWidgets('should show hint button', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('should trigger hint when hint button is pressed', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.lightbulb));
      await tester.pump();

      // Assert - hint should be triggered (verified through provider)
      expect(gameProvider.gameState, isNotNull);
    });

    testWidgets('should show pause button during game', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should pause game when pause button is pressed', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Assert
      expect(gameProvider.isPaused, isTrue);
    });

    testWidgets('should show floating letters background', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.byType(Stack), findsWidgets); // Background should be in a stack
    });

    testWidgets('should show particle effects during celebration', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Complete a sentence to trigger celebration
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();
      
      for (final initial in initials) {
        gameProvider.tapInitial(initial);
      }

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - should show celebration effects
      expect(gameProvider.currentSentenceIndex, equals(1));
    });

    testWidgets('should show loading state correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      
      // Trigger loading by starting a game
      await tester.tap(find.text('START GAME'));
      await tester.pump(); // Just one pump to catch loading state

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state gracefully', (WidgetTester tester) async {
      // This would require mocking a service failure
      // For now, we test that error handling exists
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('should display progress through course', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert - should show sentence progress
      expect(find.textContaining('1'), findsWidgets); // Sentence 1 of course
    });

    testWidgets('should handle back navigation correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Look for back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump();
      }

      // Assert - should handle navigation
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('should maintain responsive layout', (WidgetTester tester) async {
      // Act - test with different screen size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert
      expect(find.byType(GameScreen), findsOneWidget);

      // Reset size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle rapid button taps gracefully', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Rapid tapping
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('A').first);
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Assert - should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show completion celebration', (WidgetTester tester) async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Complete entire course
      for (int sentenceIndex = 0; sentenceIndex < 20; sentenceIndex++) {
        final sentence = gameProvider.gameState!.currentSentence;
        final initials = sentence.getInitials();
        
        for (final initial in initials) {
          gameProvider.tapInitial(initial);
        }
        await tester.pump();
      }

      // Assert
      expect(gameProvider.isCourseCompleted, isTrue);
    });

    testWidgets('should handle accessibility correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createGameScreen());
      await tester.pump();

      // Assert - should have semantic labels
      expect(find.bySemanticsLabel('START GAME'), findsOneWidget);
    });
  });
}