import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/models/user_progress.dart';

void main() {
  group('UserProgress Model Tests', () {
    test('should create initial user progress', () {
      // Act
      final progress = UserProgress.initial();

      // Assert
      expect(progress.currentLevel, equals(1));
      expect(progress.consecutiveCorrectCount, equals(0));
      expect(progress.completionTimes, isEmpty);
      expect(progress.coursesCompleted, equals(0));
    });

    test('should add completion time and maintain recent times only', () {
      // Arrange
      var progress = UserProgress.initial();

      // Act - add more than 7 completion times
      for (int i = 1; i <= 10; i++) {
        progress = progress.addCompletionTime(i.toDouble());
      }

      // Assert
      expect(progress.completionTimes.length, equals(7)); // Only keep recent 7
      expect(progress.completionTimes, equals([4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]));
    });

    test('should calculate weighted average correctly', () {
      // Arrange
      var progress = UserProgress.initial();
      
      // Add times: 2.0, 4.0, 6.0
      progress = progress.addCompletionTime(2.0);
      progress = progress.addCompletionTime(4.0);
      progress = progress.addCompletionTime(6.0);

      // Act
      final weightedAverage = progress.getWeightedAverageTime();

      // Assert
      // Expected: (2*1 + 4*2 + 6*3) / (1+2+3) = (2+8+18) / 6 = 28/6 ≈ 4.67
      expect(weightedAverage, closeTo(4.67, 0.01));
    });

    test('should return 0 for weighted average when no completion times', () {
      // Arrange
      final progress = UserProgress.initial();

      // Act
      final weightedAverage = progress.getWeightedAverageTime();

      // Assert
      expect(weightedAverage, equals(0.0));
    });

    test('should increment consecutive correct count', () {
      // Arrange
      final progress = UserProgress.initial();

      // Act
      final newProgress = progress.incrementConsecutiveCorrect();

      // Assert
      expect(newProgress.consecutiveCorrectCount, equals(1));
    });

    test('should increment courses completed', () {
      // Arrange
      final progress = UserProgress.initial();

      // Act
      final newProgress = progress.incrementCoursesCompleted();

      // Assert
      expect(newProgress.coursesCompleted, equals(1));
    });

    test('should update level', () {
      // Arrange
      final progress = UserProgress.initial();

      // Act
      final newProgress = progress.updateLevel(5);

      // Assert
      expect(newProgress.currentLevel, equals(5));
    });

    test('should determine if level adjustment is needed after course completion', () {
      // Arrange
      var progress = UserProgress.initial();
      
      // Complete first 19 courses (no adjustment yet)
      for (int i = 0; i < 19; i++) {
        progress = progress.incrementCoursesCompleted();
      }

      // Act & Assert
      expect(progress.shouldAdjustLevel(), isFalse);

      // Complete 20th course
      progress = progress.incrementCoursesCompleted();
      expect(progress.shouldAdjustLevel(), isTrue);

      // Complete 21st course (not a multiple of 20)
      progress = progress.incrementCoursesCompleted();
      expect(progress.shouldAdjustLevel(), isFalse);
    });

    test('should suggest level increase for fast completion times', () {
      // Arrange
      var progress = UserProgress.initial();
      
      // Add fast completion times (0.5 seconds per word)
      for (int i = 0; i < 7; i++) {
        progress = progress.addCompletionTime(0.5);
      }

      // Act
      final suggestion = progress.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.increase));
    });

    test('should suggest level decrease for slow completion times', () {
      // Arrange
      var progress = UserProgress.initial();
      
      // Add slow completion times (5.0 seconds per word)
      for (int i = 0; i < 7; i++) {
        progress = progress.addCompletionTime(5.0);
      }

      // Act
      final suggestion = progress.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.decrease));
    });

    test('should suggest no change for moderate completion times', () {
      // Arrange
      var progress = UserProgress.initial();
      
      // Add moderate completion times (2.0 seconds per word)
      for (int i = 0; i < 7; i++) {
        progress = progress.addCompletionTime(2.0);
      }

      // Act
      final suggestion = progress.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.none));
    });

    test('should not adjust level beyond bounds', () {
      // Arrange
      var progress = UserProgress.initial();

      // Act - try to go below minimum
      var newProgress = progress.updateLevel(0);
      expect(newProgress.currentLevel, equals(1));

      // Act - try to go above maximum
      newProgress = progress.updateLevel(10);
      expect(newProgress.currentLevel, equals(9));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final progress = UserProgress.initial();

      // Act
      final newProgress = progress.copyWith(
        currentLevel: 5,
        consecutiveCorrectCount: 10,
        coursesCompleted: 3,
      );

      // Assert
      expect(newProgress.currentLevel, equals(5));
      expect(newProgress.consecutiveCorrectCount, equals(10));
      expect(newProgress.coursesCompleted, equals(3));
      expect(newProgress.completionTimes, equals(progress.completionTimes));
    });

    test('should validate equality', () {
      // Arrange
      final progress1 = UserProgress.initial();
      final progress2 = UserProgress.initial();

      // Assert
      expect(progress1 == progress2, isTrue);
      expect(progress1.hashCode == progress2.hashCode, isTrue);
    });

    test('should convert to/from JSON correctly', () {
      // Arrange
      var progress = UserProgress.initial();
      progress = progress.copyWith(
        currentLevel: 3,
        consecutiveCorrectCount: 15,
        coursesCompleted: 5,
        completionTimes: [1.0, 2.0, 3.0],
      );

      // Act
      final json = progress.toJson();
      final fromJson = UserProgress.fromJson(json);

      // Assert
      expect(fromJson, equals(progress));
    });
  });
}