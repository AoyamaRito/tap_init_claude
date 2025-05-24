import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

class AchievementProgress {
  final int consecutiveCorrectCount;
  final int coursesCompleted;
  final int currentLevel;
  final List<Achievement> achievements;

  const AchievementProgress({
    required this.consecutiveCorrectCount,
    required this.coursesCompleted,
    required this.currentLevel,
    required this.achievements,
  });
}

class ProgressProvider extends ChangeNotifier {
  static const String _progressKey = 'user_progress';
  
  UserProgress _userProgress = UserProgress.initial();
  SharedPreferences? _prefs;

  UserProgress get userProgress => _userProgress;

  /// Initialize the provider and load saved progress
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
  }

  /// Update user level
  Future<void> updateLevel(int newLevel) async {
    _userProgress = _userProgress.updateLevel(newLevel);
    await _saveProgress();
    notifyListeners();
  }

  /// Increment consecutive correct count
  Future<void> incrementConsecutiveCorrect() async {
    _userProgress = _userProgress.incrementConsecutiveCorrect();
    await _saveProgress();
    notifyListeners();
  }

  /// Increment courses completed count
  Future<void> incrementCoursesCompleted() async {
    _userProgress = _userProgress.incrementCoursesCompleted();
    await _saveProgress();
    notifyListeners();
  }

  /// Add a completion time
  Future<void> addCompletionTime(double timePerWord) async {
    _userProgress = _userProgress.addCompletionTime(timePerWord);
    await _saveProgress();
    notifyListeners();
  }

  /// Get level change suggestion
  LevelChangeDirection suggestLevelChange() {
    return _userProgress.suggestLevelChange();
  }

  /// Check if level should be adjusted
  bool shouldAdjustLevel() {
    return _userProgress.shouldAdjustLevel();
  }

  /// Auto-adjust level based on performance
  Future<void> autoAdjustLevel() async {
    final suggestion = suggestLevelChange();
    
    switch (suggestion) {
      case LevelChangeDirection.increase:
        await updateLevel(_userProgress.currentLevel + 1);
        break;
      case LevelChangeDirection.decrease:
        await updateLevel(_userProgress.currentLevel - 1);
        break;
      case LevelChangeDirection.none:
        // No change needed
        break;
    }
  }

  /// Get weighted average completion time
  double getWeightedAverageTime() {
    return _userProgress.getWeightedAverageTime();
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    _userProgress = UserProgress.initial();
    await _saveProgress();
    notifyListeners();
  }

  /// Get achievement progress
  AchievementProgress getAchievementProgress() {
    final achievements = _calculateAchievements();
    
    return AchievementProgress(
      consecutiveCorrectCount: _userProgress.consecutiveCorrectCount,
      coursesCompleted: _userProgress.coursesCompleted,
      currentLevel: _userProgress.currentLevel,
      achievements: achievements,
    );
  }

  /// Calculate unlocked achievements
  List<Achievement> _calculateAchievements() {
    final achievements = <Achievement>[];
    
    // Consecutive correct achievements
    achievements.add(Achievement(
      id: 'first_correct',
      title: 'First Success',
      description: 'Complete your first sentence',
      isUnlocked: _userProgress.consecutiveCorrectCount >= 1,
    ));
    
    achievements.add(Achievement(
      id: 'streak_10',
      title: 'Getting Started',
      description: 'Reach 10 consecutive correct answers',
      isUnlocked: _userProgress.consecutiveCorrectCount >= 10,
    ));
    
    achievements.add(Achievement(
      id: 'streak_50',
      title: 'On Fire',
      description: 'Reach 50 consecutive correct answers',
      isUnlocked: _userProgress.consecutiveCorrectCount >= 50,
    ));
    
    achievements.add(Achievement(
      id: 'streak_100',
      title: 'Unstoppable',
      description: 'Reach 100 consecutive correct answers',
      isUnlocked: _userProgress.consecutiveCorrectCount >= 100,
    ));
    
    // Course completion achievements
    achievements.add(Achievement(
      id: 'first_course',
      title: 'Course Complete',
      description: 'Complete your first course',
      isUnlocked: _userProgress.coursesCompleted >= 1,
    ));
    
    achievements.add(Achievement(
      id: 'courses_10',
      title: 'Dedicated Learner',
      description: 'Complete 10 courses',
      isUnlocked: _userProgress.coursesCompleted >= 10,
    ));
    
    achievements.add(Achievement(
      id: 'courses_50',
      title: 'English Master',
      description: 'Complete 50 courses',
      isUnlocked: _userProgress.coursesCompleted >= 50,
    ));
    
    // Level achievements
    achievements.add(Achievement(
      id: 'level_5',
      title: 'Intermediate',
      description: 'Reach level 5',
      isUnlocked: _userProgress.currentLevel >= 5,
    ));
    
    achievements.add(Achievement(
      id: 'level_9',
      title: 'Expert',
      description: 'Reach the maximum level',
      isUnlocked: _userProgress.currentLevel >= 9,
    ));
    
    // Speed achievements
    final averageTime = getWeightedAverageTime();
    achievements.add(Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Average less than 1 second per word',
      isUnlocked: averageTime > 0 && averageTime < 1.0,
    ));
    
    return achievements;
  }

  /// Export progress data for backup
  Map<String, dynamic> exportProgress() {
    return _userProgress.toJson();
  }

  /// Import progress data from backup
  Future<void> importProgress(Map<String, dynamic> data) async {
    try {
      _userProgress = UserProgress.fromJson(data);
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to import progress: $e');
    }
  }

  /// Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    if (_prefs == null) return;
    
    try {
      final progressJson = jsonEncode(_userProgress.toJson());
      await _prefs!.setString(_progressKey, progressJson);
    } catch (e) {
      // Log error but don't throw - we don't want to break the app
      debugPrint('Failed to save progress: $e');
    }
  }

  /// Load progress from SharedPreferences
  Future<void> _loadProgress() async {
    if (_prefs == null) return;
    
    try {
      final progressJson = _prefs!.getString(_progressKey);
      if (progressJson != null) {
        final progressData = jsonDecode(progressJson) as Map<String, dynamic>;
        _userProgress = UserProgress.fromJson(progressData);
      }
    } catch (e) {
      // If loading fails, use default progress
      debugPrint('Failed to load progress, using defaults: $e');
      _userProgress = UserProgress.initial();
    }
  }
}