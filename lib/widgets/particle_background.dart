import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType {
  circles,
  stars,
  sparkles,
  dots,
}

enum ParticleMovement {
  linear,
  wave,
  spiral,
  random,
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;
  double life;
  double maxLife;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
    required this.life,
    required this.maxLife,
    required this.rotation,
    required this.rotationSpeed,
  });

  bool get isDead => life <= 0;
}

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final List<Color> colors;
  final double animationSpeed;
  final ParticleType particleType;
  final bool enableGlow;
  final bool triggerCelebration;
  final double intensity;
  final double minSize;
  final double maxSize;
  final bool isPaused;
  final BlendMode blendMode;
  final ParticleMovement movement;

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.colors = const [
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ],
    this.animationSpeed = 1.0,
    this.particleType = ParticleType.circles,
    this.enableGlow = true,
    this.triggerCelebration = false,
    this.intensity = 0.6,
    this.minSize = 2.0,
    this.maxSize = 6.0,
    this.isPaused = false,
    this.blendMode = BlendMode.plus,
    this.movement = ParticleMovement.linear,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Particle> _particles;
  late List<Particle> _celebrationParticles;
  final Random _random = Random();
  Size _screenSize = Size.zero;
  bool _celebrationTriggered = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _particles = [];
    _celebrationParticles = [];
    
    _animationController.repeat();
    _animationController.addListener(_updateParticles);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    _initializeParticles();
  }

  @override
  void didUpdateWidget(ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.particleCount != oldWidget.particleCount) {
      _initializeParticles();
    }
    
    if (widget.triggerCelebration && !oldWidget.triggerCelebration) {
      _triggerCelebrationBurst();
    }
    
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _animationController.stop();
      } else {
        _animationController.repeat();
      }
    }
  }

  void _initializeParticles() {
    if (_screenSize == Size.zero) return;
    
    _particles.clear();
    
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createRandomParticle());
    }
  }

  Particle _createRandomParticle() {
    final size = widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize);
    
    return Particle(
      x: _random.nextDouble() * _screenSize.width,
      y: _random.nextDouble() * _screenSize.height,
      vx: (_random.nextDouble() - 0.5) * 20 * widget.animationSpeed,
      vy: (_random.nextDouble() - 0.5) * 20 * widget.animationSpeed,
      size: size,
      opacity: widget.intensity * (0.3 + _random.nextDouble() * 0.7),
      color: widget.colors[_random.nextInt(widget.colors.length)],
      life: double.infinity, // Background particles live forever
      maxLife: double.infinity,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
    );
  }

  Particle _createCelebrationParticle(double centerX, double centerY) {
    final angle = _random.nextDouble() * 2 * pi;
    final speed = 50 + _random.nextDouble() * 100;
    final size = widget.maxSize + _random.nextDouble() * 10;
    
    return Particle(
      x: centerX,
      y: centerY,
      vx: cos(angle) * speed,
      vy: sin(angle) * speed,
      size: size,
      opacity: 1.0,
      color: widget.colors[_random.nextInt(widget.colors.length)],
      life: 2.0,
      maxLife: 2.0,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
    );
  }

  void _triggerCelebrationBurst() {
    if (_celebrationTriggered) return;
    _celebrationTriggered = true;
    
    final centerX = _screenSize.width / 2;
    final centerY = _screenSize.height / 2;
    
    for (int i = 0; i < 30; i++) {
      _celebrationParticles.add(_createCelebrationParticle(centerX, centerY));
    }
    
    // Reset flag after some time
    Future.delayed(const Duration(seconds: 3), () {
      _celebrationTriggered = false;
    });
  }

  void _updateParticles() {
    if (!mounted || widget.isPaused) return;
    
    setState(() {
      final deltaTime = 0.016; // 60fps
      
      // Update background particles
      for (final particle in _particles) {
        _updateParticlePosition(particle, deltaTime);
        _wrapParticlePosition(particle);
      }
      
      // Update celebration particles
      _celebrationParticles.removeWhere((particle) {
        _updateParticlePosition(particle, deltaTime);
        particle.life -= deltaTime;
        particle.opacity = (particle.life / particle.maxLife).clamp(0.0, 1.0);
        return particle.isDead;
      });
    });
  }

  void _updateParticlePosition(Particle particle, double deltaTime) {
    switch (widget.movement) {
      case ParticleMovement.linear:
        particle.x += particle.vx * deltaTime;
        particle.y += particle.vy * deltaTime;
        break;
      case ParticleMovement.wave:
        particle.x += particle.vx * deltaTime;
        particle.y += particle.vy * deltaTime + sin(particle.x * 0.01) * 10;
        break;
      case ParticleMovement.spiral:
        final angle = atan2(particle.vy, particle.vx);
        final radius = sqrt(particle.vx * particle.vx + particle.vy * particle.vy);
        particle.x += cos(angle + deltaTime) * radius * deltaTime;
        particle.y += sin(angle + deltaTime) * radius * deltaTime;
        break;
      case ParticleMovement.random:
        particle.vx += (_random.nextDouble() - 0.5) * 20 * deltaTime;
        particle.vy += (_random.nextDouble() - 0.5) * 20 * deltaTime;
        particle.x += particle.vx * deltaTime;
        particle.y += particle.vy * deltaTime;
        break;
    }
    
    particle.rotation += particle.rotationSpeed;
  }

  void _wrapParticlePosition(Particle particle) {
    if (particle.x < -particle.size) {
      particle.x = _screenSize.width + particle.size;
    } else if (particle.x > _screenSize.width + particle.size) {
      particle.x = -particle.size;
    }
    
    if (particle.y < -particle.size) {
      particle.y = _screenSize.height + particle.size;
    } else if (particle.y > _screenSize.height + particle.size) {
      particle.y = -particle.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ParticlePainter(
          particles: _particles,
          celebrationParticles: _celebrationParticles,
          particleType: widget.particleType,
          enableGlow: widget.enableGlow,
          blendMode: widget.blendMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateParticles);
    _animationController.dispose();
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<Particle> celebrationParticles;
  final ParticleType particleType;
  final bool enableGlow;
  final BlendMode blendMode;

  ParticlePainter({
    required this.particles,
    required this.celebrationParticles,
    required this.particleType,
    required this.enableGlow,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..blendMode = blendMode;

    // Draw background particles
    for (final particle in particles) {
      _drawParticle(canvas, particle, paint);
    }

    // Draw celebration particles
    for (final particle in celebrationParticles) {
      _drawParticle(canvas, particle, paint);
    }
  }

  void _drawParticle(Canvas canvas, Particle particle, Paint paint) {
    paint.color = particle.color.withOpacity(particle.opacity);

    if (enableGlow) {
      // Draw glow effect
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);
      _drawParticleShape(canvas, particle, paint);
      
      // Draw core
      paint.maskFilter = null;
      paint.color = particle.color.withOpacity(particle.opacity * 0.8);
    }

    _drawParticleShape(canvas, particle, paint);
  }

  void _drawParticleShape(Canvas canvas, Particle particle, Paint paint) {
    canvas.save();
    canvas.translate(particle.x, particle.y);
    canvas.rotate(particle.rotation);

    switch (particleType) {
      case ParticleType.circles:
        canvas.drawCircle(Offset.zero, particle.size, paint);
        break;
      case ParticleType.stars:
        _drawStar(canvas, particle.size, paint);
        break;
      case ParticleType.sparkles:
        _drawSparkle(canvas, particle.size, paint);
        break;
      case ParticleType.dots:
        canvas.drawCircle(Offset.zero, particle.size * 0.5, paint);
        break;
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final angle = 2 * pi / points;
    final radius = size;
    final innerRadius = radius * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final currentRadius = i % 2 == 0 ? radius : innerRadius;
      final x = cos(i * angle / 2) * currentRadius;
      final y = sin(i * angle / 2) * currentRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, double size, Paint paint) {
    final strokePaint = Paint()
      ..color = paint.color
      ..strokeWidth = size * 0.2
      ..strokeCap = StrokeCap.round;

    // Draw cross shape
    canvas.drawLine(Offset(-size, 0), Offset(size, 0), strokePaint);
    canvas.drawLine(Offset(0, -size), Offset(0, size), strokePaint);
    canvas.drawLine(Offset(-size * 0.7, -size * 0.7), Offset(size * 0.7, size * 0.7), strokePaint);
    canvas.drawLine(Offset(-size * 0.7, size * 0.7), Offset(size * 0.7, -size * 0.7), strokePaint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}