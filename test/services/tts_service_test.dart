import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tap_init_claude/services/tts_service.dart';

void main() {
  group('TTSService Tests', () {
    late TTSService ttsService;

    setUp(() {
      ttsService = TTSService();
    });

    test('should initialize TTS service correctly', () async {
      // Act
      await ttsService.initialize();

      // Assert
      expect(ttsService.isInitialized, isTrue);
      expect(ttsService.currentLanguage, equals('en-US'));
      expect(ttsService.speechRate, equals(0.5));
      expect(ttsService.volume, equals(0.8));
      expect(ttsService.pitch, equals(1.0));
    });

    test('should speak text successfully', () async {
      // Arrange
      await ttsService.initialize();
      const testText = 'This is a test sentence';

      // Act
      final result = await ttsService.speak(testText);

      // Assert
      expect(result, isTrue);
    });

    test('should stop speaking', () async {
      // Arrange
      await ttsService.initialize();
      await ttsService.speak('This is a long sentence for testing stop functionality');

      // Act
      final result = await ttsService.stop();

      // Assert
      expect(result, isTrue);
      expect(ttsService.isSpeaking, isFalse);
    });

    test('should pause and resume speaking', () async {
      // Arrange
      await ttsService.initialize();
      await ttsService.speak('This is a long sentence for testing pause functionality');

      // Act - pause
      final pauseResult = await ttsService.pause();
      expect(pauseResult, isTrue);
      expect(ttsService.isPaused, isTrue);

      // Act - resume
      final resumeResult = await ttsService.resume();
      expect(resumeResult, isTrue);
      expect(ttsService.isPaused, isFalse);
    });

    test('should set speech rate within valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      await ttsService.setSpeechRate(0.3);

      // Assert
      expect(ttsService.speechRate, equals(0.3));
    });

    test('should clamp speech rate to valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act - test below minimum
      await ttsService.setSpeechRate(0.0);
      expect(ttsService.speechRate, equals(0.1));

      // Act - test above maximum
      await ttsService.setSpeechRate(2.0);
      expect(ttsService.speechRate, equals(1.0));
    });

    test('should set volume within valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      await ttsService.setVolume(0.5);

      // Assert
      expect(ttsService.volume, equals(0.5));
    });

    test('should clamp volume to valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act - test below minimum
      await ttsService.setVolume(-0.1);
      expect(ttsService.volume, equals(0.0));

      // Act - test above maximum
      await ttsService.setVolume(1.5);
      expect(ttsService.volume, equals(1.0));
    });

    test('should set pitch within valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      await ttsService.setPitch(1.5);

      // Assert
      expect(ttsService.pitch, equals(1.5));
    });

    test('should clamp pitch to valid range', () async {
      // Arrange
      await ttsService.initialize();

      // Act - test below minimum
      await ttsService.setPitch(0.4);
      expect(ttsService.pitch, equals(0.5));

      // Act - test above maximum
      await ttsService.setPitch(3.0);
      expect(ttsService.pitch, equals(2.0));
    });

    test('should change language', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      await ttsService.setLanguage('en-GB');

      // Assert
      expect(ttsService.currentLanguage, equals('en-GB'));
    });

    test('should get available languages', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      final languages = await ttsService.getAvailableLanguages();

      // Assert
      expect(languages, isNotEmpty);
      expect(languages, contains('en-US'));
    });

    test('should handle speech completion callback', () async {
      // Arrange
      await ttsService.initialize();
      bool callbackCalled = false;

      ttsService.setCompletionHandler(() {
        callbackCalled = true;
      });

      // Act
      await ttsService.speak('Short text');
      
      // Wait for speech to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(callbackCalled, isTrue);
    });

    test('should handle speech error callback', () async {
      // Arrange
      await ttsService.initialize();
      String? errorMessage;

      ttsService.setErrorHandler((error) {
        errorMessage = error;
      });

      // Act - try to speak empty text (should cause error)
      await ttsService.speak('');

      // Assert
      expect(errorMessage, isNotNull);
    });

    test('should queue multiple speech requests', () async {
      // Arrange
      await ttsService.initialize();
      const texts = ['First sentence', 'Second sentence', 'Third sentence'];

      // Act
      for (final text in texts) {
        await ttsService.speak(text);
      }

      // Assert
      expect(ttsService.speechQueue.length, equals(3));
    });

    test('should clear speech queue', () async {
      // Arrange
      await ttsService.initialize();
      await ttsService.speak('First sentence');
      await ttsService.speak('Second sentence');

      // Act
      ttsService.clearQueue();

      // Assert
      expect(ttsService.speechQueue, isEmpty);
    });

    test('should validate TTS availability', () async {
      // Act
      final isAvailable = await ttsService.isTTSAvailable();

      // Assert
      expect(isAvailable, isA<bool>());
    });

    test('should dispose resources properly', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      await ttsService.dispose();

      // Assert
      expect(ttsService.isInitialized, isFalse);
    });

    test('should not speak when not initialized', () async {
      // Arrange - do not initialize

      // Act
      final result = await ttsService.speak('This should not work');

      // Assert
      expect(result, isFalse);
    });

    test('should handle empty text gracefully', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      final result = await ttsService.speak('');

      // Assert
      expect(result, isFalse);
    });

    test('should handle null text gracefully', () async {
      // Arrange
      await ttsService.initialize();

      // Act
      final result = await ttsService.speak(null);

      // Assert
      expect(result, isFalse);
    });

    test('should preload common phrases', () async {
      // Arrange
      await ttsService.initialize();
      const phrases = ['Good morning', 'Hello', 'Thank you'];

      // Act
      await ttsService.preloadPhrases(phrases);

      // Assert
      expect(ttsService.preloadedPhrases.length, equals(3));
    });
  });
}