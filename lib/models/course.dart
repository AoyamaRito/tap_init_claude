import 'package:yaml/yaml.dart';
import 'sentence.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final int level;
  final String category;
  final List<Sentence> sentences;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    required this.sentences,
  });

  /// Validate that course has exactly 20 sentences
  bool isValid() {
    return sentences.length == 20;
  }

  /// Get sentence by index
  Sentence? getSentence(int index) {
    if (index < 0 || index >= sentences.length) return null;
    return sentences[index];
  }

  /// Calculate average word count across all sentences
  double getAverageWordCount() {
    if (sentences.isEmpty) return 0.0;
    
    final totalWords = sentences
        .map((sentence) => sentence.getWordCount())
        .reduce((a, b) => a + b);
    
    return totalWords / sentences.length;
  }

  /// Generate filename for this course
  String getFilename() {
    return '$id.yaml';
  }

  /// Get directory path for this course level
  String getDirectoryPath() {
    return 'assets/courses/level$level';
  }

  /// Get full file path
  String getFullPath() {
    return '${getDirectoryPath()}/${getFilename()}';
  }

  /// Convert to YAML string
  String toYaml() {
    final data = {
      'course': {
        'id': id,
        'title': title,
        'description': description,
        'level': level,
        'category': category,
        'sentences': sentences.map((sentence) => {
          'text': sentence.text,
          'level': sentence.level,
          'category': sentence.category,
        }).toList(),
      }
    };

    return _encodeYaml(data);
  }

  /// Create from YAML string
  factory Course.fromYaml(String yamlContent) {
    try {
      final dynamic yamlData = loadYaml(yamlContent);
      
      if (yamlData is! Map || !yamlData.containsKey('course')) {
        throw const FormatException('Invalid YAML structure: missing course key');
      }
      
      final courseData = yamlData['course'] as Map;
      
      final sentencesData = courseData['sentences'] as List;
      final sentences = sentencesData.map((sentenceData) {
        final data = sentenceData as Map;
        return Sentence(
          text: data['text'] as String,
          level: data['level'] as int,
          category: data['category'] as String,
        );
      }).toList();

      return Course(
        id: courseData['id'] as String,
        title: courseData['title'] as String,
        description: courseData['description'] as String,
        level: courseData['level'] as int,
        category: courseData['category'] as String,
        sentences: sentences,
      );
    } catch (e) {
      throw FormatException('Failed to parse YAML: $e');
    }
  }

  /// Simple YAML encoder (since yaml package doesn't include encoder)
  String _encodeYaml(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    _encodeYamlMap(data, buffer, 0);
    return buffer.toString();
  }

  void _encodeYamlMap(Map<String, dynamic> map, StringBuffer buffer, int indent) {
    map.forEach((key, value) {
      buffer.write('  ' * indent);
      buffer.write('$key:');
      
      if (value is Map) {
        buffer.writeln();
        _encodeYamlMap(value as Map<String, dynamic>, buffer, indent + 1);
      } else if (value is List) {
        buffer.writeln();
        _encodeYamlList(value, buffer, indent + 1);
      } else {
        buffer.writeln(' $value');
      }
    });
  }

  void _encodeYamlList(List<dynamic> list, StringBuffer buffer, int indent) {
    for (final item in list) {
      buffer.write('  ' * indent);
      buffer.write('- ');
      
      if (item is Map) {
        final mapItem = item as Map<String, dynamic>;
        bool first = true;
        mapItem.forEach((key, value) {
          if (!first) {
            buffer.write('  ' * (indent + 1));
          }
          buffer.write('$key: $value');
          if (!first || mapItem.length > 1) {
            buffer.writeln();
          }
          first = false;
        });
        if (mapItem.length == 1) {
          buffer.writeln();
        }
      } else {
        buffer.writeln(item);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.level == level &&
        other.category == category &&
        _listEquals(other.sentences, sentences);
  }

  bool _listEquals(List<Sentence> a, List<Sentence> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        level,
        category,
        Object.hashAll(sentences),
      );

  @override
  String toString() => 'Course(id: $id, title: $title, level: $level, sentences: ${sentences.length})';
}