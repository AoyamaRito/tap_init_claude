import 'dart:math';
import 'sentence.dart';

class GameState {
  final Sentence currentSentence;
  final int currentInitialIndex;
  final int consecutiveCorrectCount;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> shuffledLetters;

  const GameState({
    required this.currentSentence,
    required this.currentInitialIndex,
    required this.consecutiveCorrectCount,
    required this.startTime,
    required this.shuffledLetters,
    this.endTime,
  });

  /// Create initial game state for a sentence
  factory GameState.initial(Sentence sentence) {
    return GameState(
      currentSentence: sentence,
      currentInitialIndex: 0,
      consecutiveCorrectCount: 0,
      startTime: DateTime.now(),
      shuffledLetters: _generateShuffledLetters(sentence.getInitials()),
    );
  }

  /// Generate 15 letters (5x3 grid) with required initials plus random letters
  static List<String> _generateShuffledLetters(List<String> requiredInitials) {
    const int totalButtons = 15;
    final random = Random();
    final letters = <String>[];
    
    // Add required initials
    letters.addAll(requiredInitials);
    
    // Add random letters to fill the grid
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    while (letters.length < totalButtons) {
      final randomLetter = allLetters[random.nextInt(allLetters.length)];
      letters.add(randomLetter);
    }
    
    // Shuffle the list
    letters.shuffle(random);
    return letters;
  }

  /// Handle tapping an initial
  GameState tapInitial(String tappedInitial) {
    final expectedInitial = getCurrentExpectedInitial();
    
    if (tappedInitial != expectedInitial) {
      // Wrong tap - no state change
      return this;
    }
    
    final newIndex = currentInitialIndex + 1;
    final isNowCompleted = newIndex >= currentSentence.getInitials().length;
    
    return copyWith(
      currentInitialIndex: newIndex,
      endTime: isNowCompleted ? DateTime.now() : null,
      consecutiveCorrectCount: isNowCompleted ? consecutiveCorrectCount + 1 : consecutiveCorrectCount,
    );
  }

  /// Get the current expected initial
  String getCurrentExpectedInitial() {
    final initials = currentSentence.getInitials();
    if (currentInitialIndex >= initials.length) return '';
    return initials[currentInitialIndex];
  }

  /// Get remaining initials to tap
  List<String> getRemainingInitials() {
    final initials = currentSentence.getInitials();
    if (currentInitialIndex >= initials.length) return [];
    return initials.sublist(currentInitialIndex);
  }

  /// Check if the game is completed
  bool get isCompleted => currentInitialIndex >= currentSentence.getInitials().length;

  /// Get completion time in seconds
  double getCompletionTimeInSeconds() {
    if (endTime == null) return 0.0;
    return endTime!.difference(startTime).inMilliseconds / 1000.0;
  }

  /// Get time per word
  double getTimePerWord() {
    final completionTime = getCompletionTimeInSeconds();
    final wordCount = currentSentence.getWordCount();
    if (wordCount == 0) return 0.0;
    return completionTime / wordCount;
  }

  /// Reset for a new sentence while preserving consecutive count
  GameState resetForNewSentence(Sentence newSentence) {
    return GameState(
      currentSentence: newSentence,
      currentInitialIndex: 0,
      consecutiveCorrectCount: consecutiveCorrectCount,
      startTime: DateTime.now(),
      shuffledLetters: _generateShuffledLetters(newSentence.getInitials()),
    );
  }

  /// Create a copy with modified properties
  GameState copyWith({
    Sentence? currentSentence,
    int? currentInitialIndex,
    int? consecutiveCorrectCount,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? shuffledLetters,
  }) {
    return GameState(
      currentSentence: currentSentence ?? this.currentSentence,
      currentInitialIndex: currentInitialIndex ?? this.currentInitialIndex,
      consecutiveCorrectCount: consecutiveCorrectCount ?? this.consecutiveCorrectCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      shuffledLetters: shuffledLetters ?? this.shuffledLetters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.currentSentence == currentSentence &&
        other.currentInitialIndex == currentInitialIndex &&
        other.consecutiveCorrectCount == consecutiveCorrectCount &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(
        currentSentence,
        currentInitialIndex,
        consecutiveCorrectCount,
        startTime,
        endTime,
      );

  @override
  String toString() => 'GameState(sentence: ${currentSentence.text}, index: $currentInitialIndex, score: $consecutiveCorrectCount)';
}