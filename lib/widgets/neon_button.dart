import 'package:flutter/material.dart';

enum NeonButtonStyle {
  filled,
  outlined,
  text,
}

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isEnabled;
  final bool isLoading;
  final Color color;
  final Size? size;
  final IconData? icon;
  final NeonButtonStyle style;
  final bool enableGlow;
  final double fontSize;
  final bool isPulsing;
  final double borderRadius;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.isEnabled = true,
    this.isLoading = false,
    this.color = Colors.cyan,
    this.size,
    this.icon,
    this.style = NeonButtonStyle.filled,
    this.enableGlow = true,
    this.fontSize = 16.0,
    this.isPulsing = false,
    this.borderRadius = 12.0,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late AnimationController _glowController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    if (widget.enableGlow != oldWidget.enableGlow) {
      if (widget.enableGlow) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = true;
    });
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _tapController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = false;
    });
    _tapController.reverse();
  }

  void _handleTap() {
    if (!widget.isEnabled || widget.isLoading) return;
    widget.onPressed?.call();
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) {
      return Colors.grey.withOpacity(0.3);
    }

    switch (widget.style) {
      case NeonButtonStyle.filled:
        return widget.color.withOpacity(0.2);
      case NeonButtonStyle.outlined:
        return Colors.transparent;
      case NeonButtonStyle.text:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (!widget.isEnabled) {
      return Colors.grey.withOpacity(0.5);
    }

    return widget.color;
  }

  Color _getTextColor() {
    if (!widget.isEnabled) {
      return Colors.grey;
    }

    return widget.color;
  }

  List<BoxShadow> _getBoxShadows() {
    if (!widget.enableGlow || !widget.isEnabled) {
      return [];
    }

    final glowIntensity = _glowAnimation.value;
    
    return [
      BoxShadow(
        color: widget.color.withOpacity(0.3 * glowIntensity),
        blurRadius: 15 * glowIntensity,
        spreadRadius: 2 * glowIntensity,
      ),
      BoxShadow(
        color: widget.color.withOpacity(0.1 * glowIntensity),
        blurRadius: 30 * glowIntensity,
        spreadRadius: 5 * glowIntensity,
      ),
    ];
  }

  List<Shadow> _getTextShadows() {
    if (!widget.enableGlow || !widget.isEnabled) {
      return [];
    }

    final glowIntensity = _glowAnimation.value;
    
    return [
      Shadow(
        color: widget.color.withOpacity(0.8 * glowIntensity),
        blurRadius: 10 * glowIntensity,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? const Size(120, 45);
    
    return Semantics(
      label: widget.text,
      button: true,
      enabled: widget.isEnabled,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _scaleAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              onLongPress: widget.onLongPress,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 2,
                  ),
                  boxShadow: _getBoxShadows(),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    onTap: widget.isEnabled && !widget.isLoading ? _handleTap : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTextColor(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: _getTextColor(),
                              size: widget.fontSize,
                              shadows: _getTextShadows(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(),
                              shadows: _getTextShadows(),
                            ),
                          ),
                        ],
                      ),
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
    _tapController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}