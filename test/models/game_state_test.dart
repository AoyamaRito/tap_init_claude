import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/models/game_state.dart';
import 'package:tap_init_claude/models/sentence.dart';

void main() {
  group('GameState Model Tests', () {
    late Sentence testSentence;

    setUp(() {
      testSentence = const Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );
    });

    test('should create initial game state', () {
      // Act
      final gameState = GameState.initial(testSentence);

      // Assert
      expect(gameState.currentSentence, equals(testSentence));
      expect(gameState.currentInitialIndex, equals(0));
      expect(gameState.consecutiveCorrectCount, equals(0));
      expect(gameState.isCompleted, isFalse);
      expect(gameState.startTime, isNotNull);
      expect(gameState.endTime, isNull);
      expect(gameState.shuffledLetters, isNotEmpty);
    });

    test('should generate shuffled letters containing all initials', () {
      // Act
      final gameState = GameState.initial(testSentence);
      final initials = testSentence.getInitials();

      // Assert
      expect(gameState.shuffledLetters.length, equals(15)); // 5x3 grid
      
      // Check that all required initials are present
      for (final initial in initials) {
        expect(gameState.shuffledLetters.contains(initial), isTrue);
      }
    });

    test('should advance to next initial on correct tap', () {
      // Arrange
      final gameState = GameState.initial(testSentence);
      final correctInitial = testSentence.getInitials()[0];

      // Act
      final newState = gameState.tapInitial(correctInitial);

      // Assert
      expect(newState.currentInitialIndex, equals(1));
      expect(newState.isCompleted, isFalse);
      expect(newState.endTime, isNull);
    });

    test('should complete game when all initials are tapped', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      final initials = testSentence.getInitials();

      // Act - tap all initials in sequence
      for (final initial in initials) {
        gameState = gameState.tapInitial(initial);
      }

      // Assert
      expect(gameState.isCompleted, isTrue);
      expect(gameState.endTime, isNotNull);
      expect(gameState.currentInitialIndex, equals(initials.length));
    });

    test('should not advance on incorrect tap', () {
      // Arrange
      final gameState = GameState.initial(testSentence);
      const wrongInitial = 'X'; // Not the first initial 'T'

      // Act
      final newState = gameState.tapInitial(wrongInitial);

      // Assert
      expect(newState.currentInitialIndex, equals(0));
      expect(newState.isCompleted, isFalse);
    });

    test('should calculate completion time correctly', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      final initials = testSentence.getInitials();

      // Wait a bit to ensure time difference
      gameState = gameState.copyWith(
        startTime: DateTime.now().subtract(const Duration(seconds: 5)),
      );

      // Act - complete the game
      for (final initial in initials) {
        gameState = gameState.tapInitial(initial);
      }

      final completionTime = gameState.getCompletionTimeInSeconds();

      // Assert
      expect(completionTime, greaterThan(0));
      expect(completionTime, lessThan(10)); // Should be reasonable
    });

    test('should calculate time per word correctly', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      final initials = testSentence.getInitials();

      gameState = gameState.copyWith(
        startTime: DateTime.now().subtract(const Duration(seconds: 8)),
      );

      // Act - complete the game
      for (final initial in initials) {
        gameState = gameState.tapInitial(initial);
      }

      final timePerWord = gameState.getTimePerWord();

      // Assert
      expect(timePerWord, greaterThan(0));
      expect(timePerWord, equals(gameState.getCompletionTimeInSeconds() / testSentence.getWordCount()));
    });

    test('should get current expected initial correctly', () {
      // Arrange
      final gameState = GameState.initial(testSentence);

      // Act
      final expectedInitial = gameState.getCurrentExpectedInitial();

      // Assert
      expect(expectedInitial, equals('T')); // First initial of "This is a pen"
    });

    test('should get remaining initials correctly', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      
      // Tap first initial
      gameState = gameState.tapInitial('T');

      // Act
      final remaining = gameState.getRemainingInitials();

      // Assert
      expect(remaining, equals(['i', 'a', 'p']));
    });

    test('should increment consecutive correct count on completion', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      gameState = gameState.copyWith(consecutiveCorrectCount: 5);
      final initials = testSentence.getInitials();

      // Act - complete the game
      for (final initial in initials) {
        gameState = gameState.tapInitial(initial);
      }

      // Assert
      expect(gameState.consecutiveCorrectCount, equals(6));
    });

    test('should reset for new sentence', () {
      // Arrange
      var gameState = GameState.initial(testSentence);
      gameState = gameState.copyWith(
        currentInitialIndex: 2,
        consecutiveCorrectCount: 10,
      );

      const newSentence = Sentence(
        text: 'Hello world',
        level: 2,
        category: 'greeting',
      );

      // Act
      final newState = gameState.resetForNewSentence(newSentence);

      // Assert
      expect(newState.currentSentence, equals(newSentence));
      expect(newState.currentInitialIndex, equals(0));
      expect(newState.consecutiveCorrectCount, equals(10)); // Should preserve
      expect(newState.isCompleted, isFalse);
      expect(newState.endTime, isNull);
    });
  });
}