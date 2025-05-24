import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/game_state.dart';
import '../models/sentence.dart';
import '../services/course_service.dart';
import '../services/tts_service.dart';

class GameStatistics {
  final int sentencesCompleted;
  final int totalTaps;
  final double averageTimePerSentence;
  final int correctTaps;
  final int incorrectTaps;

  const GameStatistics({
    required this.sentencesCompleted,
    required this.totalTaps,
    required this.averageTimePerSentence,
    required this.correctTaps,
    required this.incorrectTaps,
  });
}

class GameProvider extends ChangeNotifier {
  final CourseService _courseService;
  final TTSService _ttsService;

  Course? _currentCourse;
  GameState? _gameState;
  int _currentSentenceIndex = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPaused = false;
  
  // Statistics tracking
  final List<double> _completionTimes = [];
  int _totalTaps = 0;
  int _correctTaps = 0;
  int _incorrectTaps = 0;

  GameProvider({
    CourseService? courseService,
    TTSService? ttsService,
  }) : _courseService = courseService ?? CourseService(),
       _ttsService = ttsService ?? TTSService();

  // Getters
  Course? get currentCourse => _currentCourse;
  GameState? get gameState => _gameState;
  int get currentSentenceIndex => _currentSentenceIndex;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isPaused => _isPaused;
  bool get isCourseCompleted => _currentSentenceIndex >= 20;

  /// Start a new game with the specified level
  Future<void> startNewGame({required int level}) async {
    _setLoading(true);
    _clearError();

    try {
      // Load a random course for the level
      _currentCourse = await _courseService.getRandomCourseForLevel(level);
      
      if (_currentCourse == null) {
        throw Exception('No courses available for level $level');
      }

      // Initialize game state with first sentence
      _currentSentenceIndex = 0;
      _resetStatistics();
      _startSentence();

      // Initialize TTS if not already done
      if (!_ttsService.isInitialized) {
        await _ttsService.initialize();
      }

      // Speak the first sentence
      await _speakCurrentSentence();

    } catch (e) {
      _setError('Failed to start game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Handle tapping an initial
  void tapInitial(String tappedInitial) {
    if (_gameState == null || _isPaused) return;

    _totalTaps++;
    
    final expectedInitial = _gameState!.getCurrentExpectedInitial();
    
    if (tappedInitial == expectedInitial) {
      // Correct tap
      _correctTaps++;
      _gameState = _gameState!.tapInitial(tappedInitial);
      
      // Check if sentence is completed
      if (_gameState!.isCompleted) {
        _completeSentence();
      }
    } else {
      // Incorrect tap - just track it, no state change
      _incorrectTaps++;
    }
    
    notifyListeners();
  }

  /// Complete current sentence and move to next
  void _completeSentence() {
    if (_gameState == null) return;

    // Record completion time
    final completionTime = _gameState!.getCompletionTimeInSeconds();
    _completionTimes.add(completionTime);

    // Move to next sentence
    _currentSentenceIndex++;
    
    if (!isCourseCompleted) {
      _startSentence();
      _speakCurrentSentence();
    }
  }

  /// Start a new sentence
  void _startSentence() {
    if (_currentCourse == null) return;

    final sentence = _currentCourse!.getSentence(_currentSentenceIndex);
    if (sentence != null) {
      _gameState = GameState.initial(sentence);
    }
  }

  /// Speak the current sentence
  Future<void> _speakCurrentSentence() async {
    if (_gameState != null) {
      await _ttsService.speak(_gameState!.currentSentence.text);
    }
  }

  /// Show hint by speaking the sentence again
  void showHint() {
    _speakCurrentSentence();
  }

  /// Get remaining initials for current sentence
  List<String> getRemainingInitials() {
    return _gameState?.getRemainingInitials() ?? [];
  }

  /// Get current expected initial
  String getCurrentExpectedInitial() {
    return _gameState?.getCurrentExpectedInitial() ?? '';
  }

  /// Get the shuffled letters for the current game
  List<String> getShuffledLetters() {
    return _gameState?.shuffledLetters ?? [];
  }

  /// Get last completion time
  double getLastCompletionTime() {
    return _completionTimes.isNotEmpty ? _completionTimes.last : 0.0;
  }

  /// Get game statistics
  GameStatistics getGameStatistics() {
    final averageTime = _completionTimes.isNotEmpty 
        ? _completionTimes.reduce((a, b) => a + b) / _completionTimes.length
        : 0.0;

    return GameStatistics(
      sentencesCompleted: _completionTimes.length,
      totalTaps: _totalTaps,
      averageTimePerSentence: averageTime,
      correctTaps: _correctTaps,
      incorrectTaps: _incorrectTaps,
    );
  }

  /// Pause the game
  void pauseGame() {
    _isPaused = true;
    _ttsService.pause();
    notifyListeners();
  }

  /// Resume the game
  void resumeGame() {
    _isPaused = false;
    _ttsService.resume();
    notifyListeners();
  }

  /// Reset the game
  void resetGame() {
    _currentCourse = null;
    _gameState = null;
    _currentSentenceIndex = 0;
    _isPaused = false;
    _clearError();
    _resetStatistics();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  /// Reset statistics
  void _resetStatistics() {
    _completionTimes.clear();
    _totalTaps = 0;
    _correctTaps = 0;
    _incorrectTaps = 0;
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}