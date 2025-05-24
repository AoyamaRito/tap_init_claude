import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/providers/game_provider.dart';
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
  bool _speakCalled = false;
  String? _lastSpokenText;

  @override
  Future<bool> speak(String? text) async {
    _speakCalled = true;
    _lastSpokenText = text;
    return true;
  }

  bool get speakCalled => _speakCalled;
  String? get lastSpokenText => _lastSpokenText;

  void reset() {
    _speakCalled = false;
    _lastSpokenText = null;
  }
}

void main() {
  group('GameProvider Tests', () {
    late GameProvider gameProvider;
    late MockCourseService mockCourseService;
    late MockTTSService mockTTSService;

    setUp(() {
      mockCourseService = MockCourseService();
      mockTTSService = MockTTSService();
      gameProvider = GameProvider(
        courseService: mockCourseService,
        ttsService: mockTTSService,
      );
    });

    test('should initialize with default state', () {
      // Assert
      expect(gameProvider.gameState, isNull);
      expect(gameProvider.currentCourse, isNull);
      expect(gameProvider.currentSentenceIndex, equals(0));
      expect(gameProvider.isLoading, isFalse);
      expect(gameProvider.hasError, isFalse);
      expect(gameProvider.errorMessage, isEmpty);
    });

    test('should start new game successfully', () async {
      // Act
      await gameProvider.startNewGame(level: 1);

      // Assert
      expect(gameProvider.currentCourse, isNotNull);
      expect(gameProvider.gameState, isNotNull);
      expect(gameProvider.currentSentenceIndex, equals(0));
      expect(gameProvider.isLoading, isFalse);
      expect(gameProvider.hasError, isFalse);
      expect(mockTTSService.speakCalled, isTrue);
    });

    test('should handle tap initial correctly', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final initialState = gameProvider.gameState!;
      final expectedInitial = initialState.getCurrentExpectedInitial();

      // Act
      gameProvider.tapInitial(expectedInitial);

      // Assert
      expect(gameProvider.gameState!.currentInitialIndex, 
             equals(initialState.currentInitialIndex + 1));
    });

    test('should handle wrong tap initial', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final initialState = gameProvider.gameState!;

      // Act
      gameProvider.tapInitial('Z'); // Wrong initial

      // Assert
      expect(gameProvider.gameState!.currentInitialIndex, 
             equals(initialState.currentInitialIndex)); // No change
    });

    test('should advance to next sentence when current is completed', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();

      // Act - complete current sentence
      for (final initial in initials) {
        gameProvider.tapInitial(initial);
      }

      // Assert
      expect(gameProvider.currentSentenceIndex, equals(1));
      expect(gameProvider.gameState!.currentInitialIndex, equals(0));
    });

    test('should complete course when all sentences are finished', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act - complete all 20 sentences
      for (int sentenceIndex = 0; sentenceIndex < 20; sentenceIndex++) {
        final sentence = gameProvider.gameState!.currentSentence;
        final initials = sentence.getInitials();
        
        for (final initial in initials) {
          gameProvider.tapInitial(initial);
        }
      }

      // Assert
      expect(gameProvider.isCourseCompleted, isTrue);
      expect(gameProvider.currentSentenceIndex, equals(20));
    });

    test('should calculate completion time correctly', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();

      // Wait a bit to ensure time passes
      await Future.delayed(const Duration(milliseconds: 10));

      // Act - complete sentence
      for (final initial in initials) {
        gameProvider.tapInitial(initial);
      }

      // Assert
      final completionTime = gameProvider.getLastCompletionTime();
      expect(completionTime, greaterThan(0));
    });

    test('should provide hint correctly', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      mockTTSService.reset();

      // Act
      gameProvider.showHint();

      // Assert
      expect(mockTTSService.speakCalled, isTrue);
      expect(mockTTSService.lastSpokenText, 
             equals(gameProvider.gameState!.currentSentence.text));
    });

    test('should get remaining initials', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();

      // Act - tap first initial
      gameProvider.tapInitial(initials[0]);

      // Assert
      final remaining = gameProvider.getRemainingInitials();
      expect(remaining.length, equals(initials.length - 1));
      expect(remaining, equals(initials.sublist(1)));
    });

    test('should get current expected initial', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();

      // Act
      final expected = gameProvider.getCurrentExpectedInitial();

      // Assert
      expect(expected, equals(initials[0]));
    });

    test('should handle loading state', () async {
      // Act
      final future = gameProvider.startNewGame(level: 1);
      
      // Assert - should be loading
      expect(gameProvider.isLoading, isTrue);
      
      await future;
      
      // Assert - should not be loading
      expect(gameProvider.isLoading, isFalse);
    });

    test('should handle error state when course loading fails', () async {
      // Arrange - create provider with service that fails
      final failingService = MockCourseService();
      final failingProvider = GameProvider(
        courseService: failingService,
        ttsService: mockTTSService,
      );

      // Override to return null (simulating failure)
      failingService.getRandomCourseForLevel(1).then((_) => null);

      try {
        // Act
        await failingProvider.startNewGame(level: 1);
      } catch (e) {
        // Expected to fail
      }

      // Assert
      expect(failingProvider.hasError, isTrue);
      expect(failingProvider.errorMessage, isNotEmpty);
    });

    test('should reset game state', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      gameProvider.tapInitial(gameProvider.getCurrentExpectedInitial());

      // Act
      gameProvider.resetGame();

      // Assert
      expect(gameProvider.gameState, isNull);
      expect(gameProvider.currentCourse, isNull);
      expect(gameProvider.currentSentenceIndex, equals(0));
      expect(gameProvider.hasError, isFalse);
      expect(gameProvider.errorMessage, isEmpty);
    });

    test('should notify listeners on state change', () async {
      // Arrange
      int notificationCount = 0;
      gameProvider.addListener(() {
        notificationCount++;
      });

      // Act
      await gameProvider.startNewGame(level: 1);
      gameProvider.tapInitial(gameProvider.getCurrentExpectedInitial());

      // Assert
      expect(notificationCount, greaterThan(0));
    });

    test('should handle pause and resume game', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);

      // Act
      gameProvider.pauseGame();
      expect(gameProvider.isPaused, isTrue);

      gameProvider.resumeGame();
      expect(gameProvider.isPaused, isFalse);
    });

    test('should get game statistics', () async {
      // Arrange
      await gameProvider.startNewGame(level: 1);
      
      // Complete one sentence
      final sentence = gameProvider.gameState!.currentSentence;
      final initials = sentence.getInitials();
      for (final initial in initials) {
        gameProvider.tapInitial(initial);
      }

      // Act
      final stats = gameProvider.getGameStatistics();

      // Assert
      expect(stats.sentencesCompleted, equals(1));
      expect(stats.totalTaps, greaterThan(0));
      expect(stats.averageTimePerSentence, greaterThan(0));
    });
  });
}