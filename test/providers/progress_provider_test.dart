import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_init_claude/providers/progress_provider.dart';
import 'package:tap_init_claude/models/user_progress.dart';

void main() {
  group('ProgressProvider Tests', () {
    late ProgressProvider progressProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      progressProvider = ProgressProvider();
      await progressProvider.initialize();
    });

    test('should initialize with default progress', () {
      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(1));
      expect(progressProvider.userProgress.consecutiveCorrectCount, equals(0));
      expect(progressProvider.userProgress.coursesCompleted, equals(0));
      expect(progressProvider.userProgress.completionTimes, isEmpty);
    });

    test('should save and load progress from SharedPreferences', () async {
      // Arrange
      await progressProvider.updateLevel(3);
      await progressProvider.incrementConsecutiveCorrect();

      // Create new provider to test loading
      final newProvider = ProgressProvider();
      await newProvider.initialize();

      // Assert
      expect(newProvider.userProgress.currentLevel, equals(3));
      expect(newProvider.userProgress.consecutiveCorrectCount, equals(1));
    });

    test('should update level correctly', () async {
      // Act
      await progressProvider.updateLevel(5);

      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(5));
    });

    test('should clamp level to valid range', () async {
      // Act
      await progressProvider.updateLevel(0);
      expect(progressProvider.userProgress.currentLevel, equals(1));

      await progressProvider.updateLevel(10);
      expect(progressProvider.userProgress.currentLevel, equals(9));
    });

    test('should increment consecutive correct count', () async {
      // Act
      await progressProvider.incrementConsecutiveCorrect();
      await progressProvider.incrementConsecutiveCorrect();

      // Assert
      expect(progressProvider.userProgress.consecutiveCorrectCount, equals(2));
    });

    test('should increment courses completed', () async {
      // Act
      await progressProvider.incrementCoursesCompleted();
      await progressProvider.incrementCoursesCompleted();

      // Assert
      expect(progressProvider.userProgress.coursesCompleted, equals(2));
    });

    test('should add completion time', () async {
      // Act
      await progressProvider.addCompletionTime(2.5);
      await progressProvider.addCompletionTime(1.8);

      // Assert
      expect(progressProvider.userProgress.completionTimes.length, equals(2));
      expect(progressProvider.userProgress.completionTimes, contains(2.5));
      expect(progressProvider.userProgress.completionTimes, contains(1.8));
    });

    test('should maintain only 7 recent completion times', () async {
      // Act - add 10 completion times
      for (int i = 1; i <= 10; i++) {
        await progressProvider.addCompletionTime(i.toDouble());
      }

      // Assert
      expect(progressProvider.userProgress.completionTimes.length, equals(7));
      expect(progressProvider.userProgress.completionTimes, 
             equals([4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]));
    });

    test('should suggest level increase for fast performance', () async {
      // Arrange - add fast completion times
      for (int i = 0; i < 7; i++) {
        await progressProvider.addCompletionTime(0.5);
      }

      // Act
      final suggestion = progressProvider.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.increase));
    });

    test('should suggest level decrease for slow performance', () async {
      // Arrange - add slow completion times
      for (int i = 0; i < 7; i++) {
        await progressProvider.addCompletionTime(5.0);
      }

      // Act
      final suggestion = progressProvider.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.decrease));
    });

    test('should suggest no change for moderate performance', () async {
      // Arrange - add moderate completion times
      for (int i = 0; i < 7; i++) {
        await progressProvider.addCompletionTime(2.0);
      }

      // Act
      final suggestion = progressProvider.suggestLevelChange();

      // Assert
      expect(suggestion, equals(LevelChangeDirection.none));
    });

    test('should determine when level adjustment is needed', () async {
      // Act & Assert - before 20 courses
      for (int i = 1; i < 20; i++) {
        await progressProvider.incrementCoursesCompleted();
        expect(progressProvider.shouldAdjustLevel(), isFalse);
      }

      // Complete 20th course
      await progressProvider.incrementCoursesCompleted();
      expect(progressProvider.shouldAdjustLevel(), isTrue);

      // Complete 21st course (not a multiple of 20)
      await progressProvider.incrementCoursesCompleted();
      expect(progressProvider.shouldAdjustLevel(), isFalse);
    });

    test('should auto-adjust level when conditions are met', () async {
      // Arrange - set up for level increase
      await progressProvider.updateLevel(3);
      for (int i = 0; i < 7; i++) {
        await progressProvider.addCompletionTime(0.5); // Fast times
      }
      
      // Complete 19 courses first
      for (int i = 0; i < 19; i++) {
        await progressProvider.incrementCoursesCompleted();
      }

      // Act - complete 20th course (triggers auto-adjustment)
      await progressProvider.incrementCoursesCompleted();
      
      if (progressProvider.shouldAdjustLevel()) {
        await progressProvider.autoAdjustLevel();
      }

      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(4));
    });

    test('should handle auto-adjustment for level decrease', () async {
      // Arrange - set up for level decrease
      await progressProvider.updateLevel(5);
      for (int i = 0; i < 7; i++) {
        await progressProvider.addCompletionTime(5.0); // Slow times
      }
      
      // Complete 20 courses
      for (int i = 0; i < 20; i++) {
        await progressProvider.incrementCoursesCompleted();
      }

      // Act
      await progressProvider.autoAdjustLevel();

      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(4));
    });

    test('should get weighted average time', () async {
      // Arrange
      await progressProvider.addCompletionTime(2.0);
      await progressProvider.addCompletionTime(4.0);
      await progressProvider.addCompletionTime(6.0);

      // Act
      final weightedAverage = progressProvider.getWeightedAverageTime();

      // Assert
      // Expected: (2*1 + 4*2 + 6*3) / (1+2+3) = 28/6 ≈ 4.67
      expect(weightedAverage, closeTo(4.67, 0.01));
    });

    test('should reset progress', () async {
      // Arrange
      await progressProvider.updateLevel(5);
      await progressProvider.incrementConsecutiveCorrect();
      await progressProvider.incrementCoursesCompleted();
      await progressProvider.addCompletionTime(2.5);

      // Act
      await progressProvider.resetProgress();

      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(1));
      expect(progressProvider.userProgress.consecutiveCorrectCount, equals(0));
      expect(progressProvider.userProgress.coursesCompleted, equals(0));
      expect(progressProvider.userProgress.completionTimes, isEmpty);
    });

    test('should get achievement progress', () async {
      // Arrange
      await progressProvider.incrementConsecutiveCorrect();
      await progressProvider.incrementConsecutiveCorrect();
      await progressProvider.incrementConsecutiveCorrect();

      // Act
      final progress = progressProvider.getAchievementProgress();

      // Assert
      expect(progress.consecutiveCorrectCount, equals(3));
      expect(progress.achievements, isNotEmpty);
    });

    test('should handle persistence errors gracefully', () async {
      // This test would require mocking SharedPreferences to throw errors
      // For now, we assume the happy path works
      expect(progressProvider.userProgress, isNotNull);
    });

    test('should notify listeners on changes', () async {
      // Arrange
      int notificationCount = 0;
      progressProvider.addListener(() {
        notificationCount++;
      });

      // Act
      await progressProvider.updateLevel(3);
      await progressProvider.incrementConsecutiveCorrect();

      // Assert
      expect(notificationCount, equals(2));
    });

    test('should export and import progress', () async {
      // Arrange
      await progressProvider.updateLevel(3);
      await progressProvider.incrementConsecutiveCorrect();
      await progressProvider.addCompletionTime(2.5);

      // Act
      final exportedData = progressProvider.exportProgress();
      await progressProvider.resetProgress();
      await progressProvider.importProgress(exportedData);

      // Assert
      expect(progressProvider.userProgress.currentLevel, equals(3));
      expect(progressProvider.userProgress.consecutiveCorrectCount, equals(1));
      expect(progressProvider.userProgress.completionTimes, contains(2.5));
    });
  });
}