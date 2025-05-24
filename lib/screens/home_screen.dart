import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/floating_letters.dart';
import '../widgets/neon_button.dart';
import '../widgets/score_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          return Stack(
            children: [
              // Background Effects
              const FloatingLetters(
                letterCount: 20,
                opacity: 0.15,
                direction: FloatingDirection.random,
              ),
              
              // Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // App Title
                      const Icon(
                        Icons.auto_awesome,
                        size: 120,
                        color: Colors.cyan,
                        shadows: [
                          Shadow(
                            color: Colors.cyan,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'TAP INITIALS',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.cyan,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const Text(
                        'English Learning Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Progress Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ScoreDisplay(
                            score: progressProvider.userProgress.currentLevel,
                            label: 'Level',
                            icon: Icons.trending_up,
                            color: Colors.amber,
                            fontSize: 24,
                          ),
                          ScoreDisplay(
                            score: progressProvider.userProgress.consecutiveCorrectCount,
                            label: 'Best Streak',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                            fontSize: 24,
                          ),
                          ScoreDisplay(
                            score: progressProvider.userProgress.coursesCompleted,
                            label: 'Courses',
                            icon: Icons.school,
                            color: Colors.green,
                            fontSize: 24,
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Play Button
                      NeonButton(
                        text: 'START GAME',
                        onPressed: () {
                          Navigator.pushNamed(context, '/game');
                        },
                        size: const Size(250, 70),
                        fontSize: 24,
                        icon: Icons.play_arrow,
                        isPulsing: true,
                        enableGlow: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Secondary Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          NeonButton(
                            text: 'STATISTICS',
                            onPressed: () {
                              _showStatistics(context, progressProvider);
                            },
                            size: const Size(120, 45),
                            fontSize: 14,
                            style: NeonButtonStyle.outlined,
                            icon: Icons.analytics,
                          ),
                          NeonButton(
                            text: 'SETTINGS',
                            onPressed: () {
                              _showSettings(context);
                            },
                            size: const Size(120, 45),
                            fontSize: 14,
                            style: NeonButtonStyle.outlined,
                            icon: Icons.settings,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Footer
                      const Text(
                        'Powered by Claude Code AI',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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

  void _showStatistics(BuildContext context, ProgressProvider progressProvider) {
    final progress = progressProvider.getAchievementProgress();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Statistics',
          style: TextStyle(color: Colors.cyan),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Current Level', '${progress.currentLevel}'),
            _buildStatRow('Consecutive Correct', '${progress.consecutiveCorrectCount}'),
            _buildStatRow('Courses Completed', '${progress.coursesCompleted}'),
            _buildStatRow('Average Time/Word', '${progressProvider.getWeightedAverageTime().toStringAsFixed(2)}s'),
            const SizedBox(height: 16),
            const Text(
              'Recent Achievements:',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...progress.achievements
                .where((achievement) => achievement.isUnlocked)
                .take(3)
                .map((achievement) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.cyan),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings will be available in future updates.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}