import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:tap_init_claude/services/course_service.dart';
import 'package:tap_init_claude/models/course.dart';

void main() {
  group('CourseService Tests', () {
    late CourseService courseService;

    setUp(() {
      courseService = CourseService();
    });

    test('should load course from YAML file', () async {
      // Arrange
      const testYaml = '''
course:
  id: test_001
  title: Test Course
  description: A test course
  level: 1
  category: test
  sentences:
    - text: This is test
      level: 1
      category: test
    - text: Another test sentence
      level: 1
      category: test
''';

      // Mock asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final key = const StandardMessageCodec().decodeMessage(message) as String;
        if (key == 'assets/courses/level1/test_001.yaml') {
          return const StandardMessageCodec().encodeMessage(testYaml.codeUnits);
        }
        return null;
      });

      // Act
      final course = await courseService.loadCourse('assets/courses/level1/test_001.yaml');

      // Assert
      expect(course.id, equals('test_001'));
      expect(course.title, equals('Test Course'));
      expect(course.sentences.length, equals(2));
    });

    test('should get courses by level', () async {
      // Arrange & Act
      final courses = await courseService.getCoursesByLevel(1);

      // Assert
      expect(courses, isNotEmpty);
      expect(courses.every((course) => course.level == 1), isTrue);
    });

    test('should get courses by category', () async {
      // Arrange & Act
      final courses = await courseService.getCoursesByCategory('daily');

      // Assert
      expect(courses, isNotEmpty);
      expect(courses.every((course) => course.category == 'daily'), isTrue);
    });

    test('should get random course for level', () async {
      // Arrange & Act
      final course = await courseService.getRandomCourseForLevel(1);

      // Assert
      expect(course, isNotNull);
      expect(course!.level, equals(1));
      expect(course.isValid(), isTrue);
    });

    test('should return null for non-existent level', () async {
      // Arrange & Act
      final course = await courseService.getRandomCourseForLevel(99);

      // Assert
      expect(course, isNull);
    });

    test('should get all available levels', () async {
      // Arrange & Act
      final levels = await courseService.getAvailableLevels();

      // Assert
      expect(levels, contains(1));
      expect(levels, contains(2));
      expect(levels, contains(3));
      expect(levels.every((level) => level >= 1 && level <= 9), isTrue);
    });

    test('should get all available categories', () async {
      // Arrange & Act
      final categories = await courseService.getAvailableCategories();

      // Assert
      expect(categories, contains('daily'));
      expect(categories, contains('greeting'));
      expect(categories, contains('story'));
      expect(categories, contains('business'));
    });

    test('should validate course files', () async {
      // Arrange & Act
      final validationResults = await courseService.validateAllCourses();

      // Assert
      expect(validationResults, isNotEmpty);
      expect(validationResults.values.every((isValid) => isValid == true), isTrue);
    });

    test('should cache loaded courses', () async {
      // Arrange
      const coursePath = 'assets/courses/level1/daily_001.yaml';

      // Act - load same course twice
      final course1 = await courseService.loadCourse(coursePath);
      final course2 = await courseService.loadCourse(coursePath);

      // Assert - should be same instance (cached)
      expect(identical(course1, course2), isTrue);
    });

    test('should clear cache', () async {
      // Arrange
      const coursePath = 'assets/courses/level1/daily_001.yaml';
      await courseService.loadCourse(coursePath);

      // Act
      courseService.clearCache();
      final courseAfterClear = await courseService.loadCourse(coursePath);

      // Assert - should be different instance after cache clear
      expect(courseService.getCacheSize(), equals(1));
    });

    test('should get course statistics', () async {
      // Arrange & Act
      final stats = await courseService.getCourseStatistics();

      // Assert
      expect(stats.totalCourses, greaterThan(0));
      expect(stats.coursesByLevel, isNotEmpty);
      expect(stats.coursesByCategory, isNotEmpty);
      expect(stats.averageSentencesPerCourse, equals(20.0));
    });

    test('should search courses by title', () async {
      // Arrange & Act
      final courses = await courseService.searchCourses('Daily');

      // Assert
      expect(courses, isNotEmpty);
      expect(courses.every((course) => 
        course.title.toLowerCase().contains('daily') ||
        course.description.toLowerCase().contains('daily')
      ), isTrue);
    });

    test('should get course recommendations based on progress', () async {
      // Arrange
      const userLevel = 2;
      const completedCourseIds = ['daily_001', 'greeting_001'];

      // Act
      final recommendations = await courseService.getRecommendedCourses(
        userLevel,
        completedCourseIds,
      );

      // Assert
      expect(recommendations, isNotEmpty);
      expect(recommendations.every((course) => 
        !completedCourseIds.contains(course.id)
      ), isTrue);
    });

    tearDown(() {
      // Clean up mock handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });
}