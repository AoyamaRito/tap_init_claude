import 'package:flutter/material.dart';

class InitialButton extends StatefulWidget {
  final String letter;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isCorrect;
  final bool isError;
  final bool isHint;
  final bool isDisabled;
  final bool isGlowing;
  final double size;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  const InitialButton({
    super.key,
    required this.letter,
    required this.onTap,
    this.onLongPress,
    this.isCorrect = false,
    this.isError = false,
    this.isHint = false,
    this.isDisabled = false,
    this.isGlowing = false,
    this.size = 50.0,
    this.fontSize = 20.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<InitialButton> createState() => _InitialButtonState();
}

class _InitialButtonState extends State<InitialButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(InitialButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger animations based on state changes
    if (widget.isError && !oldWidget.isError) {
      _triggerErrorAnimation();
    } else if (widget.isCorrect && !oldWidget.isCorrect) {
      _triggerCorrectAnimation();
    } else if (widget.isHint && !oldWidget.isHint) {
      _triggerHintAnimation();
    }
    
    // Handle glow animation
    if (widget.isGlowing && !oldWidget.isGlowing) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isGlowing && oldWidget.isGlowing) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  void _triggerErrorAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  void _triggerCorrectAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  void _triggerHintAnimation() {
    _glowController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _glowController.stop();
        _glowController.reset();
      }
    });
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    if (widget.isError) {
      return Colors.red.withOpacity(0.8);
    } else if (widget.isCorrect) {
      return Colors.green.withOpacity(0.8);
    } else if (widget.isHint) {
      return Colors.amber.withOpacity(0.8);
    } else if (widget.isDisabled) {
      return Colors.grey.withOpacity(0.5);
    } else {
      return const Color(0xFF2A2A2A); // Dark theme button
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) {
      return widget.textColor!;
    }
    
    if (widget.isDisabled) {
      return Colors.grey.shade600;
    } else {
      return Colors.white;
    }
  }

  BoxDecoration _getDecoration() {
    final baseColor = _getBackgroundColor();
    
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: widget.isGlowing || widget.isHint
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
        // Neon glow effect
        if (widget.isGlowing || widget.isHint || widget.isCorrect)
          BoxShadow(
            color: widget.isCorrect
                ? Colors.green.withOpacity(0.6)
                : Colors.cyan.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        // Error glow
        if (widget.isError)
          BoxShadow(
            color: Colors.red.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Letter ${widget.letter} button',
      button: true,
      enabled: !widget.isDisabled,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: widget.isDisabled ? null : widget.onTap,
              onLongPress: widget.isDisabled ? null : widget.onLongPress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.size,
                height: widget.size,
                constraints: BoxConstraints(
                  minWidth: widget.size,
                  minHeight: widget.size,
                ),
                decoration: _getDecoration(),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                      shadows: [
                        if (widget.isGlowing || widget.isHint)
                          Shadow(
                            color: Colors.cyan.withOpacity(0.8),
                            blurRadius: 10,
                          ),
                      ],
                    ),
                    child: Text(
                      widget.letter,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}