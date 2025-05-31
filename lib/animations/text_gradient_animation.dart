import 'package:flutter/material.dart';

class TextGradientAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Color finalGradientColor; // Added finalGradientColor

  const TextGradientAnimation({
    super.key,
    required this.text,
    required this.style,
    required this.finalGradientColor, // Make it required
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<TextGradientAnimation> createState() => _TextGradientAnimationState();
}

class _TextGradientAnimationState extends State<TextGradientAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientColorAnimation1;
  late Animation<Color?> _gradientColorAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _gradientColorAnimation1 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.yellow),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: widget.finalGradientColor),
          weight: 50.0,
        ),
      ],
    ).animate(_controller);

    _gradientColorAnimation2 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: widget.finalGradientColor),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: widget.finalGradientColor, end: widget.finalGradientColor),
          weight: 50.0,
        ),
      ],
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(TextGradientAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.finalGradientColor != oldWidget.finalGradientColor) {
      // Re-initialize animations with the new finalGradientColor
      _initializeAnimations();
      // Restart the animation
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Ensure colors are not null, defaulting to transparent if they are.
        // Though, with the current setup, they should be non-null after animation starts.
        final color1 = _gradientColorAnimation1.value ?? Colors.transparent;
        final color2 = _gradientColorAnimation2.value ?? Colors.transparent;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [color1, color2],
            begin: const Alignment(-1.0, 0.0), // Explicitly horizontal
            end: const Alignment(1.0, 0.0),   // Explicitly horizontal
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
}
