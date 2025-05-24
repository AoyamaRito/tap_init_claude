import 'package:flutter/material.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final String label;
  final IconData? icon;
  final Color? color;
  final double fontSize;
  final bool isGlowing;
  final bool showMilestoneCelebration;
  final bool formatLargeNumbers;
  final String prefix;
  final String suffix;
  final Function(int)? onMilestone;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.label = 'Score',
    this.icon,
    this.color,
    this.fontSize = 24.0,
    this.isGlowing = false,
    this.showMilestoneCelebration = false,
    this.formatLargeNumbers = false,
    this.prefix = '',
    this.suffix = '',
    this.onMilestone,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _celebrationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.color ?? Colors.white,
      end: Colors.amber,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));

    _previousScore = widget.score;
  }

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle glow animation
    if (widget.isGlowing && !oldWidget.isGlowing) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isGlowing && oldWidget.isGlowing) {
      _glowController.stop();
      _glowController.reset();
    }

    // Handle milestone celebration
    if (widget.score != oldWidget.score) {
      _checkMilestone(oldWidget.score, widget.score);
      _previousScore = oldWidget.score;
    }

    if (widget.showMilestoneCelebration && !oldWidget.showMilestoneCelebration) {
      _triggerCelebration();
    }
  }

  void _checkMilestone(int oldScore, int newScore) {
    // Check for milestone achievements (every 10, 50, 100, etc.)
    final milestones = [10, 25, 50, 100, 250, 500, 1000];
    
    for (final milestone in milestones) {
      if (oldScore < milestone && newScore >= milestone) {
        widget.onMilestone?.call(milestone);
        _triggerCelebration();
        break;
      }
    }
  }

  void _triggerCelebration() {
    _celebrationController.forward().then((_) {
      _celebrationController.reverse();
    });
  }

  String _formatScore() {
    if (!widget.formatLargeNumbers) {
      return '${widget.prefix}${widget.score}${widget.suffix}';
    }

    final score = widget.score;
    String formattedScore;

    if (score >= 1000000) {
      formattedScore = '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      formattedScore = '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      formattedScore = score.toString();
    }

    return '${widget.prefix}$formattedScore${widget.suffix}';
  }

  Color _getTextColor() {
    return widget.color ?? Colors.white;
  }

  List<Shadow> _getTextShadows() {
    final shadows = <Shadow>[];
    
    // Base shadow
    shadows.add(
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 2,
        offset: const Offset(1, 1),
      ),
    );

    // Glow effect
    if (widget.isGlowing) {
      shadows.add(
        Shadow(
          color: (_colorAnimation.value ?? _getTextColor()).withOpacity(0.8),
          blurRadius: 15,
          offset: Offset.zero,
        ),
      );
    }

    return shadows;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.label}: ${widget.score}',
      value: widget.score.toString(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _glowAnimation,
          _scaleAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isGlowing
                      ? Colors.cyan.withOpacity(0.8)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  // Glow effect
                  if (widget.isGlowing)
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _colorAnimation.value ?? _getTextColor(),
                      size: widget.fontSize * 0.8,
                      shadows: _getTextShadows(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.label.isNotEmpty)
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: widget.fontSize * 0.6,
                            color: (_colorAnimation.value ?? _getTextColor())
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            shadows: _getTextShadows(),
                          ),
                        ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _formatScore(),
                          key: ValueKey(widget.score),
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.bold,
                            color: _colorAnimation.value ?? _getTextColor(),
                            shadows: _getTextShadows(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}