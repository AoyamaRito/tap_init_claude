import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/initial_button.dart';
import '../widgets/score_display.dart';
import '../widgets/floating_letters.dart';
import '../widgets/particle_background.dart';
import '../widgets/neon_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _startGame() {
    final progressProvider = context.read<ProgressProvider>();
    final gameProvider = context.read<GameProvider>();
    
    gameProvider.startNewGame(level: progressProvider.userProgress.currentLevel);
  }

  void _showHint() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.showHint();
  }

  void _pauseGame() {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.isPaused) {
      gameProvider.resumeGame();
    } else {
      gameProvider.pauseGame();
    }
  }

  void _onInitialTap(String initial) {
    final gameProvider = context.read<GameProvider>();
    final progressProvider = context.read<ProgressProvider>();
    
    final wasCompleted = gameProvider.gameState?.isCompleted ?? false;
    gameProvider.tapInitial(initial);
    
    // Check if sentence was just completed
    if (!wasCompleted && (gameProvider.gameState?.isCompleted ?? false)) {
      _triggerCelebration();
      
      // Update progress
      final completionTime = gameProvider.getLastCompletionTime();
      final sentence = gameProvider.gameState!.currentSentence;
      final timePerWord = completionTime / sentence.getWordCount();
      
      progressProvider.addCompletionTime(timePerWord);
      progressProvider.incrementConsecutiveCorrect();
      
      // Check if course is completed
      if (gameProvider.isCourseCompleted) {
        progressProvider.incrementCoursesCompleted();
        
        // Check for level adjustment
        if (progressProvider.shouldAdjustLevel()) {
          progressProvider.autoAdjustLevel();
        }
      }
    }
  }

  void _triggerCelebration() {
    setState(() {
      _showCelebration = true;
    });
    
    _celebrationController.forward().then((_) {
      setState(() {
        _showCelebration = false;
      });
      _celebrationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<GameProvider, ProgressProvider>(
        builder: (context, gameProvider, progressProvider, child) {
          return Stack(
            children: [
              // Background Effects
              const FloatingLetters(
                letterCount: 12,
                opacity: 0.1,
              ),
              
              // Particle Background
              ParticleBackground(
                particleCount: 30,
                triggerCelebration: _showCelebration,
                isPaused: gameProvider.isPaused,
              ),
              
              // Main Game Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    _buildTopBar(gameProvider, progressProvider),
                    
                    // Game Content
                    Expanded(
                      child: _buildGameContent(gameProvider, progressProvider),
                    ),
                  ],
                ),
              ),
              
              // Loading Overlay
              if (gameProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Course...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Error Overlay
              if (gameProvider.hasError)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${gameProvider.errorMessage}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        NeonButton(
                          text: 'TRY AGAIN',
                          onPressed: _startGame,
                          color: Colors.cyan,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(GameProvider gameProvider, ProgressProvider progressProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Score Display
          ScoreDisplay(
            score: progressProvider.userProgress.consecutiveCorrectCount,
            label: 'Score',
            icon: Icons.star,
            isGlowing: _showCelebration,
          ),
          
          const Spacer(),
          
          // Level Display
          ScoreDisplay(
            score: progressProvider.userProgress.currentLevel,
            label: 'Level',
            icon: Icons.trending_up,
            color: Colors.amber,
            fontSize: 20,
          ),
          
          const SizedBox(width: 16),
          
          // Pause/Resume Button
          if (gameProvider.gameState != null)
            IconButton(
              onPressed: _pauseGame,
              icon: Icon(
                gameProvider.isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameContent(GameProvider gameProvider, ProgressProvider progressProvider) {
    if (gameProvider.gameState == null) {
      return _buildWelcomeScreen(progressProvider);
    }

    if (gameProvider.isCourseCompleted) {
      return _buildCourseCompletedScreen(gameProvider, progressProvider);
    }

    return _buildActiveGameScreen(gameProvider);
  }

  Widget _buildWelcomeScreen(ProgressProvider progressProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 100,
            color: Colors.cyan,
            shadows: [
              Shadow(
                color: Colors.cyan,
                blurRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'TAP INITIALS',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.cyan,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'English Learning Game',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 48),
          NeonButton(
            text: 'START GAME',
            onPressed: _startGame,
            size: const Size(200, 60),
            fontSize: 20,
            icon: Icons.play_arrow,
            isPulsing: true,
          ),
          const SizedBox(height: 24),
          Text(
            'Level ${progressProvider.userProgress.currentLevel}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGameScreen(GameProvider gameProvider) {
    final gameState = gameProvider.gameState!;
    final sentence = gameState.currentSentence;
    final remainingInitials = gameProvider.getRemainingInitials();
    final currentExpected = gameProvider.getCurrentExpectedInitial();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: gameProvider.currentSentenceIndex / 20,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
          ),
          const SizedBox(height: 8),
          Text(
            'Sentence ${gameProvider.currentSentenceIndex + 1} of 20',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Current Sentence
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  sentence.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tap: ${remainingInitials.join(' → ')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.cyan.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _showHint,
                      icon: const Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Letter Buttons Grid
          Expanded(
            child: _buildLetterGrid(gameState, currentExpected),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterGrid(gameState, String currentExpected) {
    final letters = gameState.shuffledLetters;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final isCorrect = letter == currentExpected;
        
        return InitialButton(
          letter: letter,
          onTap: () => _onInitialTap(letter),
          size: 60,
          fontSize: 24,
          isHint: isCorrect && _showCelebration,
          isGlowing: isCorrect,
        );
      },
    );
  }

  Widget _buildCourseCompletedScreen(GameProvider gameProvider, ProgressProvider progressProvider) {
    final stats = gameProvider.getGameStatistics();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 100,
            color: Colors.amber,
            shadows: [
              Shadow(
                color: Colors.amber,
                blurRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'COURSE COMPLETED!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              shadows: [
                Shadow(
                  color: Colors.amber,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildStatRow('Sentences Completed', '${stats.sentencesCompleted}'),
                _buildStatRow('Total Taps', '${stats.totalTaps}'),
                _buildStatRow('Accuracy', '${((stats.correctTaps / stats.totalTaps) * 100).toStringAsFixed(1)}%'),
                _buildStatRow('Avg Time/Sentence', '${stats.averageTimePerSentence.toStringAsFixed(1)}s'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeonButton(
                text: 'PLAY AGAIN',
                onPressed: _startGame,
                color: Colors.cyan,
                icon: Icons.replay,
              ),
              const SizedBox(width: 16),
              NeonButton(
                text: 'HOME',
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.grey,
                style: NeonButtonStyle.outlined,
                icon: Icons.home,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }
}