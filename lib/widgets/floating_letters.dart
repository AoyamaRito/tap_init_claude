import 'dart:math';
import 'package:flutter/material.dart';

enum FloatingDirection {
  upward,
  downward,
  leftward,
  rightward,
  random,
}

class FloatingLetter {
  String letter;
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Color color;
  double rotation;
  double rotationSpeed;

  FloatingLetter({
    required this.letter,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class FloatingLetters extends StatefulWidget {
  final int letterCount;
  final double animationSpeed;
  final double opacity;
  final List<Color> colors;
  final double minFontSize;
  final double maxFontSize;
  final bool enableGlow;
  final bool isPaused;
  final String letters;
  final double blurIntensity;
  final FloatingDirection direction;
  final double density;

  const FloatingLetters({
    super.key,
    this.letterCount = 15,
    this.animationSpeed = 1.0,
    this.opacity = 0.3,
    this.colors = const [
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ],
    this.minFontSize = 20.0,
    this.maxFontSize = 60.0,
    this.enableGlow = true,
    this.isPaused = false,
    this.letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    this.blurIntensity = 8.0,
    this.direction = FloatingDirection.upward,
    this.density = 1.0,
  });

  @override
  State<FloatingLetters> createState() => _FloatingLettersState();
}

class _FloatingLettersState extends State<FloatingLetters>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<FloatingLetter> _floatingLetters;
  final Random _random = Random();
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _floatingLetters = [];
    
    // Start animation
    _animationController.repeat();
    _animationController.addListener(_updateLetters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    _initializeLetters();
  }

  @override
  void didUpdateWidget(FloatingLetters oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.letterCount != oldWidget.letterCount) {
      _initializeLetters();
    }
    
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _animationController.stop();
      } else {
        _animationController.repeat();
      }
    }
  }

  void _initializeLetters() {
    if (_screenSize == Size.zero) return;
    
    _floatingLetters.clear();
    
    final count = (widget.letterCount * widget.density).round();
    
    for (int i = 0; i < count; i++) {
      _floatingLetters.add(_createRandomLetter());
    }
  }

  FloatingLetter _createRandomLetter() {
    final letter = widget.letters[_random.nextInt(widget.letters.length)];
    final size = widget.minFontSize + 
        _random.nextDouble() * (widget.maxFontSize - widget.minFontSize);
    
    return FloatingLetter(
      letter: letter,
      x: _random.nextDouble() * _screenSize.width,
      y: _screenSize.height + size, // Start below screen
      size: size,
      speed: (20 + _random.nextDouble() * 30) * widget.animationSpeed,
      opacity: widget.opacity * (0.5 + _random.nextDouble() * 0.5),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
    );
  }

  void _updateLetters() {
    if (!mounted || widget.isPaused) return;
    
    setState(() {
      for (int i = 0; i < _floatingLetters.length; i++) {
        final letter = _floatingLetters[i];
        
        // Update position based on direction
        switch (widget.direction) {
          case FloatingDirection.upward:
            letter.y -= letter.speed * 0.016; // 60fps
            break;
          case FloatingDirection.downward:
            letter.y += letter.speed * 0.016;
            break;
          case FloatingDirection.leftward:
            letter.x -= letter.speed * 0.016;
            break;
          case FloatingDirection.rightward:
            letter.x += letter.speed * 0.016;
            break;
          case FloatingDirection.random:
            letter.x += ((_random.nextDouble() - 0.5) * letter.speed * 0.008);
            letter.y -= letter.speed * 0.016;
            break;
        }
        
        // Update rotation
        letter.rotation += letter.rotationSpeed;
        
        // Reset letter if it goes off screen
        if (_isLetterOffScreen(letter)) {
          _floatingLetters[i] = _createRandomLetter();
        }
      }
    });
  }

  bool _isLetterOffScreen(FloatingLetter letter) {
    switch (widget.direction) {
      case FloatingDirection.upward:
        return letter.y < -letter.size;
      case FloatingDirection.downward:
        return letter.y > _screenSize.height + letter.size;
      case FloatingDirection.leftward:
        return letter.x < -letter.size;
      case FloatingDirection.rightward:
        return letter.x > _screenSize.width + letter.size;
      case FloatingDirection.random:
        return letter.y < -letter.size || 
               letter.x < -letter.size || 
               letter.x > _screenSize.width + letter.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: _floatingLetters.map((letter) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 16),
            left: letter.x,
            top: letter.y,
            child: Transform.rotate(
              angle: letter.rotation,
              child: IgnorePointer(
                child: Text(
                  letter.letter,
                  style: TextStyle(
                    fontSize: letter.size,
                    fontWeight: FontWeight.bold,
                    color: letter.color.withOpacity(letter.opacity),
                    shadows: widget.enableGlow
                        ? [
                            Shadow(
                              color: letter.color.withOpacity(letter.opacity * 0.8),
                              blurRadius: widget.blurIntensity,
                            ),
                            Shadow(
                              color: letter.color.withOpacity(letter.opacity * 0.4),
                              blurRadius: widget.blurIntensity * 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateLetters);
    _animationController.dispose();
    super.dispose();
  }
}