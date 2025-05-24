import 'dart:convert';

enum LevelChangeDirection {
  increase,
  decrease,
  none,
}

class UserProgress {
  final int currentLevel;
  final int consecutiveCorrectCount;
  final List<double> completionTimes; // Recent 7 completion times (time per word)
  final int coursesCompleted;

  const UserProgress({
    required this.currentLevel,
    required this.consecutiveCorrectCount,
    required this.completionTimes,
    required this.coursesCompleted,
  });

  /// Create initial user progress
  factory UserProgress.initial() {
    return const UserProgress(
      currentLevel: 1,
      consecutiveCorrectCount: 0,
      completionTimes: [],
      coursesCompleted: 0,
    );
  }

  /// Add a new completion time (keeps only recent 7)
  UserProgress addCompletionTime(double timePerWord) {
    final updatedTimes = List<double>.from(completionTimes);
    updatedTimes.add(timePerWord);
    
    // Keep only the most recent 7 times
    if (updatedTimes.length > 7) {
      updatedTimes.removeAt(0);
    }
    
    return copyWith(completionTimes: updatedTimes);
  }

  /// Calculate weighted average of completion times
  /// More recent times have higher weight
  double getWeightedAverageTime() {
    if (completionTimes.isEmpty) return 0.0;
    
    double totalWeightedTime = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < completionTimes.length; i++) {
      final weight = i + 1; // Weight increases for more recent times
      totalWeightedTime += completionTimes[i] * weight;
      totalWeight += weight;
    }
    
    return totalWeightedTime / totalWeight;
  }

  /// Suggest level change based on weighted average performance
  LevelChangeDirection suggestLevelChange() {
    final averageTime = getWeightedAverageTime();
    
    // Thresholds for level adjustment (seconds per word)
    const fastThreshold = 1.0;
    const slowThreshold = 3.0;
    
    if (averageTime < fastThreshold) {
      return LevelChangeDirection.increase;
    } else if (averageTime > slowThreshold) {
      return LevelChangeDirection.decrease;
    }
    
    return LevelChangeDirection.none;
  }

  /// Check if level should be adjusted (every 20 courses)
  bool shouldAdjustLevel() {
    return coursesCompleted > 0 && coursesCompleted % 20 == 0;
  }

  /// Increment consecutive correct count
  UserProgress incrementConsecutiveCorrect() {
    return copyWith(consecutiveCorrectCount: consecutiveCorrectCount + 1);
  }

  /// Increment courses completed count
  UserProgress incrementCoursesCompleted() {
    return copyWith(coursesCompleted: coursesCompleted + 1);
  }

  /// Update level with bounds checking (1-9)
  UserProgress updateLevel(int newLevel) {
    final clampedLevel = newLevel.clamp(1, 9);
    return copyWith(currentLevel: clampedLevel);
  }

  /// Create a copy with modified properties
  UserProgress copyWith({
    int? currentLevel,
    int? consecutiveCorrectCount,
    List<double>? completionTimes,
    int? coursesCompleted,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      consecutiveCorrectCount: consecutiveCorrectCount ?? this.consecutiveCorrectCount,
      completionTimes: completionTimes ?? this.completionTimes,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'consecutiveCorrectCount': consecutiveCorrectCount,
      'completionTimes': completionTimes,
      'coursesCompleted': coursesCompleted,
    };
  }

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentLevel: json['currentLevel'] as int,
      consecutiveCorrectCount: json['consecutiveCorrectCount'] as int,
      completionTimes: (json['completionTimes'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      coursesCompleted: json['coursesCompleted'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress &&
        other.currentLevel == currentLevel &&
        other.consecutiveCorrectCount == consecutiveCorrectCount &&
        other.coursesCompleted == coursesCompleted &&
        _listEquals(other.completionTimes, completionTimes);
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        currentLevel,
        consecutiveCorrectCount,
        coursesCompleted,
        Object.hashAll(completionTimes),
      );

  @override
  String toString() => 'UserProgress(level: $currentLevel, score: $consecutiveCorrectCount, courses: $coursesCompleted)';
}