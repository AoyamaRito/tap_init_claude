class Sentence {
  final String text;
  final int level;
  final String category;

  const Sentence({
    required this.text,
    required this.level,
    required this.category,
  });

  /// Extract the first letter of each word in the sentence
  List<String> getInitials() {
    if (text.trim().isEmpty) return [];
    
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .toList();
  }

  /// Get the number of words in the sentence
  int getWordCount() {
    if (text.trim().isEmpty) return 0;
    
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sentence &&
        other.text == text &&
        other.level == level &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(text, level, category);

  @override
  String toString() => 'Sentence(text: $text, level: $level, category: $category)';
}