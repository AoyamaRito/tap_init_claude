import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/models/course.dart';
import 'package:tap_init_claude/models/sentence.dart';

void main() {
  group('Course Model Tests', () {
    test('should create course with basic properties', () {
      // Arrange
      const sentences = [
        Sentence(text: 'This is a pen', level: 1, category: 'daily'),
        Sentence(text: 'I am happy', level: 1, category: 'daily'),
      ];

      // Act
      const course = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 1,
        category: 'daily',
        sentences: sentences,
      );

      // Assert
      expect(course.id, equals('daily_001'));
      expect(course.title, equals('Daily Conversation 1'));
      expect(course.description, equals('Basic daily conversation phrases'));
      expect(course.level, equals(1));
      expect(course.category, equals('daily'));
      expect(course.sentences, equals(sentences));
    });

    test('should validate course has exactly 20 sentences', () {
      // Arrange
      final sentences = List.generate(20, (index) => 
        Sentence(text: 'Sentence $index', level: 1, category: 'test'));

      // Act
      final course = Course(
        id: 'test_001',
        title: 'Test Course',
        description: 'Test course with 20 sentences',
        level: 1,
        category: 'test',
        sentences: sentences,
      );

      // Assert
      expect(course.isValid(), isTrue);
      expect(course.sentences.length, equals(20));
    });

    test('should invalidate course with wrong number of sentences', () {
      // Arrange
      final sentences = List.generate(15, (index) => 
        Sentence(text: 'Sentence $index', level: 1, category: 'test'));

      // Act
      final course = Course(
        id: 'test_002',
        title: 'Invalid Course',
        description: 'Course with wrong number of sentences',
        level: 1,
        category: 'test',
        sentences: sentences,
      );

      // Assert
      expect(course.isValid(), isFalse);
    });

    test('should get sentence by index', () {
      // Arrange
      final sentences = List.generate(20, (index) => 
        Sentence(text: 'Sentence $index', level: 1, category: 'test'));
      
      final course = Course(
        id: 'test_003',
        title: 'Test Course',
        description: 'Test course',
        level: 1,
        category: 'test',
        sentences: sentences,
      );

      // Act
      final sentence = course.getSentence(5);

      // Assert
      expect(sentence?.text, equals('Sentence 5'));
    });

    test('should return null for invalid sentence index', () {
      // Arrange
      final sentences = List.generate(20, (index) => 
        Sentence(text: 'Sentence $index', level: 1, category: 'test'));
      
      final course = Course(
        id: 'test_004',
        title: 'Test Course',
        description: 'Test course',
        level: 1,
        category: 'test',
        sentences: sentences,
      );

      // Act & Assert
      expect(course.getSentence(-1), isNull);
      expect(course.getSentence(20), isNull);
      expect(course.getSentence(100), isNull);
    });

    test('should calculate average word count', () {
      // Arrange
      const sentences = [
        Sentence(text: 'This is', level: 1, category: 'test'), // 2 words
        Sentence(text: 'I am happy today', level: 1, category: 'test'), // 4 words
        Sentence(text: 'Hello', level: 1, category: 'test'), // 1 word
      ];
      
      final course = Course(
        id: 'test_005',
        title: 'Test Course',
        description: 'Test course',
        level: 1,
        category: 'test',
        sentences: sentences,
      );

      // Act
      final averageWordCount = course.getAverageWordCount();

      // Assert
      expect(averageWordCount, closeTo(2.33, 0.01)); // (2+4+1)/3 = 2.33
    });

    test('should convert to/from YAML correctly', () {
      // Arrange
      const sentences = [
        Sentence(text: 'This is a pen', level: 1, category: 'daily'),
        Sentence(text: 'I am happy', level: 1, category: 'daily'),
      ];

      const course = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 1,
        category: 'daily',
        sentences: sentences,
      );

      // Act
      final yamlString = course.toYaml();
      final fromYaml = Course.fromYaml(yamlString);

      // Assert
      expect(fromYaml, equals(course));
    });

    test('should parse valid YAML format', () {
      // Arrange
      const yamlContent = '''
course:
  id: daily_001
  title: Daily Conversation 1
  description: Basic daily conversation phrases
  level: 1
  category: daily
  sentences:
    - text: This is a pen
      level: 1
      category: daily
    - text: I am happy
      level: 1
      category: daily
''';

      // Act
      final course = Course.fromYaml(yamlContent);

      // Assert
      expect(course.id, equals('daily_001'));
      expect(course.title, equals('Daily Conversation 1'));
      expect(course.sentences.length, equals(2));
      expect(course.sentences[0].text, equals('This is a pen'));
    });

    test('should handle malformed YAML gracefully', () {
      // Arrange
      const invalidYaml = '''
invalid_yaml_content
  missing_structure
''';

      // Act & Assert
      expect(() => Course.fromYaml(invalidYaml), throwsA(isA<FormatException>()));
    });

    test('should validate course equality', () {
      // Arrange
      const sentences = [
        Sentence(text: 'This is a pen', level: 1, category: 'daily'),
      ];

      const course1 = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 1,
        category: 'daily',
        sentences: sentences,
      );

      const course2 = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 1,
        category: 'daily',
        sentences: sentences,
      );

      // Assert
      expect(course1 == course2, isTrue);
      expect(course1.hashCode == course2.hashCode, isTrue);
    });

    test('should validate filename generation', () {
      // Arrange
      const course = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 1,
        category: 'daily',
        sentences: [],
      );

      // Act
      final filename = course.getFilename();

      // Assert
      expect(filename, equals('daily_001.yaml'));
    });

    test('should validate course directory path', () {
      // Arrange
      const course = Course(
        id: 'daily_001',
        title: 'Daily Conversation 1',
        description: 'Basic daily conversation phrases',
        level: 3,
        category: 'daily',
        sentences: [],
      );

      // Act
      final directoryPath = course.getDirectoryPath();

      // Assert
      expect(directoryPath, equals('assets/courses/level3'));
    });
  });
}