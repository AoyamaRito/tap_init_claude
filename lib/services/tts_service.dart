import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  
  String _currentLanguage = 'en-US';
  double _speechRate = 0.5;
  double _volume = 0.8;
  double _pitch = 1.0;
  
  final List<String> _speechQueue = [];
  final Set<String> _preloadedPhrases = {};
  
  Function()? _completionHandler;
  Function(String)? _errorHandler;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get currentLanguage => _currentLanguage;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  List<String> get speechQueue => List.unmodifiable(_speechQueue);
  Set<String> get preloadedPhrases => Set.unmodifiable(_preloadedPhrases);

  /// Initialize the TTS service
  Future<void> initialize() async {
    try {
      _flutterTts = FlutterTts();
      
      // Set default values
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      
      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
      });
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _completionHandler?.call();
        _processQueue();
      });
      
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        _isPaused = false;
        _errorHandler?.call(message);
      });
      
      _flutterTts.setPauseHandler(() {
        _isPaused = true;
      });
      
      _flutterTts.setContinueHandler(() {
        _isPaused = false;
      });
      
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      _errorHandler?.call('Failed to initialize TTS: $e');
    }
  }

  /// Speak the given text
  Future<bool> speak(String? text) async {
    if (!_isInitialized || text == null || text.trim().isEmpty) {
      return false;
    }

    try {
      if (_isSpeaking) {
        // Add to queue if already speaking
        _speechQueue.add(text);
        return true;
      }
      
      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      _errorHandler?.call('Failed to speak: $e');
      return false;
    }
  }

  /// Stop speaking
  Future<bool> stop() async {
    if (!_isInitialized) return false;

    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      _speechQueue.clear();
      return true;
    } catch (e) {
      _errorHandler?.call('Failed to stop TTS: $e');
      return false;
    }
  }

  /// Pause speaking
  Future<bool> pause() async {
    if (!_isInitialized || !_isSpeaking) return false;

    try {
      await _flutterTts.pause();
      return true;
    } catch (e) {
      _errorHandler?.call('Failed to pause TTS: $e');
      return false;
    }
  }

  /// Resume speaking
  Future<bool> resume() async {
    if (!_isInitialized || !_isPaused) return false;

    try {
      await _flutterTts.speak('');
      return true;
    } catch (e) {
      _errorHandler?.call('Failed to resume TTS: $e');
      return false;
    }
  }

  /// Set speech rate (0.1 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    _speechRate = rate.clamp(0.1, 1.0);
    try {
      await _flutterTts.setSpeechRate(_speechRate);
    } catch (e) {
      _errorHandler?.call('Failed to set speech rate: $e');
    }
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double vol) async {
    if (!_isInitialized) return;

    _volume = vol.clamp(0.0, 1.0);
    try {
      await _flutterTts.setVolume(_volume);
    } catch (e) {
      _errorHandler?.call('Failed to set volume: $e');
    }
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitchValue) async {
    if (!_isInitialized) return;

    _pitch = pitchValue.clamp(0.5, 2.0);
    try {
      await _flutterTts.setPitch(_pitch);
    } catch (e) {
      _errorHandler?.call('Failed to set pitch: $e');
    }
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) return;

    try {
      final result = await _flutterTts.setLanguage(language);
      if (result == 1) {
        _currentLanguage = language;
      }
    } catch (e) {
      _errorHandler?.call('Failed to set language: $e');
    }
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) return [];

    try {
      final languages = await _flutterTts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      _errorHandler?.call('Failed to get languages: $e');
      return [];
    }
  }

  /// Set completion handler
  void setCompletionHandler(Function() handler) {
    _completionHandler = handler;
  }

  /// Set error handler
  void setErrorHandler(Function(String) handler) {
    _errorHandler = handler;
  }

  /// Clear speech queue
  void clearQueue() {
    _speechQueue.clear();
  }

  /// Check if TTS is available
  Future<bool> isTTSAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Preload common phrases for better performance
  Future<void> preloadPhrases(List<String> phrases) async {
    if (!_isInitialized) return;

    for (final phrase in phrases) {
      _preloadedPhrases.add(phrase);
      // Pre-speak at very low volume to cache
      final originalVolume = _volume;
      await setVolume(0.01);
      await _flutterTts.speak(phrase);
      await setVolume(originalVolume);
    }
  }

  /// Process queued speech
  Future<void> _processQueue() async {
    if (_speechQueue.isNotEmpty && !_isSpeaking) {
      final nextText = _speechQueue.removeAt(0);
      await speak(nextText);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await stop();
      _flutterTts.stop();
      _isInitialized = false;
      _speechQueue.clear();
      _preloadedPhrases.clear();
    }
  }
}