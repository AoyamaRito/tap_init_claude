import 'package:flutter_test/flutter_test.dart';
import 'package:tap_init_claude/models/sentence.dart';

void main() {
  group('Sentence Model Tests', () {
    test('should create sentence with basic properties', () {
      // Arrange
      const text = 'This is a pen';
      const level = 1;
      const category = 'daily';

      // Act
      final sentence = Sentence(
        text: text,
        level: level,
        category: category,
      );

      // Assert
      expect(sentence.text, equals(text));
      expect(sentence.level, equals(level));
      expect(sentence.category, equals(category));
    });

    test('should extract initials correctly', () {
      // Arrange
      const sentence = Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );

      // Act
      final initials = sentence.getInitials();

      // Assert
      expect(initials, equals(['T', 'i', 'a', 'p']));
    });

    test('should extract initials from complex sentence', () {
      // Arrange
      const sentence = Sentence(
        text: 'The quick brown fox jumps',
        level: 2,
        category: 'story',
      );

      // Act
      final initials = sentence.getInitials();

      // Assert
      expect(initials, equals(['T', 'q', 'b', 'f', 'j']));
    });

    test('should handle single word sentence', () {
      // Arrange
      const sentence = Sentence(
        text: 'Hello',
        level: 1,
        category: 'greeting',
      );

      // Act
      final initials = sentence.getInitials();

      // Assert
      expect(initials, equals(['H']));
    });

    test('should handle empty sentence gracefully', () {
      // Arrange
      const sentence = Sentence(
        text: '',
        level: 1,
        category: 'test',
      );

      // Act
      final initials = sentence.getInitials();

      // Assert
      expect(initials, isEmpty);
    });

    test('should trim whitespace and handle multiple spaces', () {
      // Arrange
      const sentence = Sentence(
        text: '  This   is    a   pen  ',
        level: 1,
        category: 'daily',
      );

      // Act
      final initials = sentence.getInitials();

      // Assert
      expect(initials, equals(['T', 'i', 'a', 'p']));
    });

    test('should get word count correctly', () {
      // Arrange
      const sentence = Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );

      // Act
      final wordCount = sentence.getWordCount();

      // Assert
      expect(wordCount, equals(4));
    });

    test('should validate sentence equality', () {
      // Arrange
      const sentence1 = Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );
      
      const sentence2 = Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );

      // Assert
      expect(sentence1 == sentence2, isTrue);
      expect(sentence1.hashCode == sentence2.hashCode, isTrue);
    });

    test('should validate sentence inequality', () {
      // Arrange
      const sentence1 = Sentence(
        text: 'This is a pen',
        level: 1,
        category: 'daily',
      );
      
      const sentence2 = Sentence(
        text: 'This is a book',
        level: 1,
        category: 'daily',
      );

      // Assert
      expect(sentence1 == sentence2, isFalse);
    });
  });
}