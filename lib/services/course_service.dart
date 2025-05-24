import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class CourseStatistics {
  final int totalCourses;
  final Map<int, int> coursesByLevel;
  final Map<String, int> coursesByCategory;
  final double averageSentencesPerCourse;

  const CourseStatistics({
    required this.totalCourses,
    required this.coursesByLevel,
    required this.coursesByCategory,
    required this.averageSentencesPerCourse,
  });
}

class CourseService {
  final Map<String, Course> _courseCache = {};
  
  // Pre-defined course files for each level
  static const Map<int, List<String>> _coursePaths = {
    1: [
      'assets/courses/level1/daily_001.yaml',
      'assets/courses/level1/greeting_001.yaml',
    ],
    2: [
      'assets/courses/level2/story_001.yaml',
    ],
    3: [
      'assets/courses/level3/business_001.yaml',
    ],
  };

  /// Load a course from YAML file
  Future<Course> loadCourse(String assetPath) async {
    // Check cache first
    if (_courseCache.containsKey(assetPath)) {
      return _courseCache[assetPath]!;
    }

    try {
      final yamlString = await rootBundle.loadString(assetPath);
      final course = Course.fromYaml(yamlString);
      
      // Cache the loaded course
      _courseCache[assetPath] = course;
      
      return course;
    } catch (e) {
      throw Exception('Failed to load course from $assetPath: $e');
    }
  }

  /// Get all courses for a specific level
  Future<List<Course>> getCoursesByLevel(int level) async {
    final coursePaths = _coursePaths[level] ?? [];
    final courses = <Course>[];
    
    for (final path in coursePaths) {
      try {
        final course = await loadCourse(path);
        courses.add(course);
      } catch (e) {
        // Log error but continue loading other courses
        print('Error loading course $path: $e');
      }
    }
    
    return courses;
  }

  /// Get all courses for a specific category
  Future<List<Course>> getCoursesByCategory(String category) async {
    final allCourses = <Course>[];
    
    for (final level in _coursePaths.keys) {
      final levelCourses = await getCoursesByLevel(level);
      allCourses.addAll(levelCourses.where((course) => course.category == category));
    }
    
    return allCourses;
  }

  /// Get a random course for a specific level
  Future<Course?> getRandomCourseForLevel(int level) async {
    final courses = await getCoursesByLevel(level);
    if (courses.isEmpty) return null;
    
    courses.shuffle();
    return courses.first;
  }

  /// Get all available levels
  Future<List<int>> getAvailableLevels() async {
    return _coursePaths.keys.toList()..sort();
  }

  /// Get all available categories
  Future<List<String>> getAvailableCategories() async {
    final categories = <String>{};
    
    for (final level in _coursePaths.keys) {
      final courses = await getCoursesByLevel(level);
      categories.addAll(courses.map((course) => course.category));
    }
    
    return categories.toList()..sort();
  }

  /// Validate all courses
  Future<Map<String, bool>> validateAllCourses() async {
    final validationResults = <String, bool>{};
    
    for (final level in _coursePaths.keys) {
      final coursePaths = _coursePaths[level]!;
      for (final path in coursePaths) {
        try {
          final course = await loadCourse(path);
          validationResults[path] = course.isValid();
        } catch (e) {
          validationResults[path] = false;
        }
      }
    }
    
    return validationResults;
  }

  /// Clear the course cache
  void clearCache() {
    _courseCache.clear();
  }

  /// Get cache size for testing
  int getCacheSize() {
    return _courseCache.length;
  }

  /// Get course statistics
  Future<CourseStatistics> getCourseStatistics() async {
    final allCourses = <Course>[];
    final coursesByLevel = <int, int>{};
    final coursesByCategory = <String, int>{};
    
    for (final level in _coursePaths.keys) {
      final courses = await getCoursesByLevel(level);
      allCourses.addAll(courses);
      coursesByLevel[level] = courses.length;
      
      for (final course in courses) {
        coursesByCategory[course.category] = (coursesByCategory[course.category] ?? 0) + 1;
      }
    }
    
    final totalSentences = allCourses.fold<int>(
      0, 
      (sum, course) => sum + course.sentences.length,
    );
    
    final averageSentencesPerCourse = allCourses.isEmpty 
        ? 0.0 
        : totalSentences / allCourses.length;
    
    return CourseStatistics(
      totalCourses: allCourses.length,
      coursesByLevel: coursesByLevel,
      coursesByCategory: coursesByCategory,
      averageSentencesPerCourse: averageSentencesPerCourse,
    );
  }

  /// Search courses by title or description
  Future<List<Course>> searchCourses(String query) async {
    final allCourses = <Course>[];
    final lowerQuery = query.toLowerCase();
    
    for (final level in _coursePaths.keys) {
      final courses = await getCoursesByLevel(level);
      allCourses.addAll(courses);
    }
    
    return allCourses.where((course) =>
      course.title.toLowerCase().contains(lowerQuery) ||
      course.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get recommended courses based on user progress
  Future<List<Course>> getRecommendedCourses(
    int userLevel, 
    List<String> completedCourseIds,
  ) async {
    final targetLevels = [userLevel - 1, userLevel, userLevel + 1]
        .where((level) => level >= 1 && level <= 9)
        .toList();
    
    final recommendations = <Course>[];
    
    for (final level in targetLevels) {
      final courses = await getCoursesByLevel(level);
      recommendations.addAll(
        courses.where((course) => !completedCourseIds.contains(course.id))
      );
    }
    
    // Prioritize current level courses
    recommendations.sort((a, b) {
      final aDiff = (a.level - userLevel).abs();
      final bDiff = (b.level - userLevel).abs();
      return aDiff.compareTo(bDiff);
    });
    
    return recommendations;
  }

  /// Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    for (final level in _coursePaths.keys) {
      final courses = await getCoursesByLevel(level);
      try {
        return courses.firstWhere((course) => course.id == courseId);
      } catch (e) {
        // Continue searching in other levels
      }
    }
    return null;
  }

  /// Add new course path dynamically (for future expansion)
  void addCoursePath(int level, String assetPath) {
    if (_coursePaths.containsKey(level)) {
      _coursePaths[level]!.add(assetPath);
    } else {
      _coursePaths[level] = [assetPath];
    }
  }
}