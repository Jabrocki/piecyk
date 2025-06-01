import 'package:flutter/material.dart';
import 'dart:math' as math;

// Helper class to store parameters for a single stripe
class StripePathParams {
  final double startX, startY;
  final double controlX, controlY;
  final double endX, endY;

  StripePathParams({
    required this.startX,
    required this.startY,
    required this.controlX,
    required this.controlY,
    required this.endX,
    required this.endY,
  });

  // For shouldRepaint comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StripePathParams &&
          runtimeType == other.runtimeType &&
          startX == other.startX &&
          startY == other.startY &&
          controlX == other.controlX &&
          controlY == other.controlY &&
          endX == other.endX &&
          endY == other.endY;

  @override
  int get hashCode =>
      startX.hashCode ^
      startY.hashCode ^
      controlX.hashCode ^
      controlY.hashCode ^
      endX.hashCode ^
      endY.hashCode;
}

class CurvedStripesBackground extends StatefulWidget {
  final Duration duration;
  final Color finalGradientColor;

  const CurvedStripesBackground({
    super.key,
    required this.finalGradientColor,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CurvedStripesBackground> createState() =>
      _CurvedStripesBackgroundState();
}

class _CurvedStripesBackgroundState extends State<CurvedStripesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientColorAnimation1;
  late Animation<Color?> _gradientColorAnimation2;
  late List<StripePathParams> _stripeParams;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _stripeParams = _generateStripeParams(); // Generate stripe paths once
    _initializeAnimations();
    _controller.repeat();
  }

  List<StripePathParams> _generateStripeParams() {
    final numStripes = 2 + _random.nextInt(2); // 2 or 3 stripes
    final params = <StripePathParams>[];
    final double sectionHeightFraction = 1.0 / numStripes;

    for (int i = 0; i < numStripes; i++) {
      double currentSectionMinY = i * sectionHeightFraction;

      double startX = -(_random.nextDouble() * 0.2 + 0.05); // Start slightly off-screen left
      double startY = currentSectionMinY + _random.nextDouble() * sectionHeightFraction;

      double endX = 1.0 + (_random.nextDouble() * 0.2 + 0.05); // End slightly off-screen right
      double endY = currentSectionMinY + _random.nextDouble() * sectionHeightFraction;

      double controlX = _random.nextDouble() * 0.4 + 0.3; // Control point somewhere in the middle X

      // Control Y: allow deviation to create curves, anchored within sections
      double sectionMidY = currentSectionMinY + sectionHeightFraction / 2;
      // Allow control point to deviate by up to 1.5 times the section height from the section's midpoint
      double controlYDeviation = (_random.nextDouble() - 0.5) * 2 * (sectionHeightFraction * 1.5);
      double controlY = (sectionMidY + controlYDeviation).clamp(0.0, 1.0); // Clamp within overall bounds

      params.add(StripePathParams(
        startX: startX,
        startY: startY,
        controlX: controlX,
        controlY: controlY,
        endX: endX,
        endY: endY,
      ));
    }
    return params;
  }

  void _initializeAnimations() {
    _gradientColorAnimation1 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: widget.finalGradientColor),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: widget.finalGradientColor, end: Colors.green),
          weight: 50.0,
        ),
      ],
    ).animate(_controller);

    _gradientColorAnimation2 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: Colors.green),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.yellow),
          weight: 50.0,
        ),
      ],
    ).animate(_controller);
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
        final color1 = _gradientColorAnimation1.value ?? Colors.transparent;
        final color2 = _gradientColorAnimation2.value ?? Colors.transparent;

        return CustomPaint(
          painter: _CurvedStripesPainter(
            gradientColors: [color1, color2],
            stripeParams: _stripeParams, // Pass generated params
          ),
          child: Container(), // Ensures the CustomPaint takes up space
        );
      },
    );
  }
}

class _CurvedStripesPainter extends CustomPainter {
  final List<Color> gradientColors;
  final List<StripePathParams> stripeParams;

  _CurvedStripesPainter({
    required this.gradientColors,
    required this.stripeParams,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: const Alignment(-1.0, 0.0),
        end: const Alignment(1.0, 0.0),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30; // Stripe thickness

    final path = Path();

    for (final params in stripeParams) {
      path.moveTo(params.startX * size.width, params.startY * size.height);
      path.quadraticBezierTo(
        params.controlX * size.width,
        params.controlY * size.height,
        params.endX * size.width,
        params.endY * size.height,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedStripesPainter oldDelegate) {
    // Compare gradient colors and stripe parameters
    // For lists, simple reference check might be insufficient if contents change,
    // but here stripeParams is generated once. Deep equality for lists can be complex.
    // Using ListEquality from collection package for deep list comparison if needed.
    // For now, assuming StripePathParams has a correct == operator.
    if (gradientColors.length != oldDelegate.gradientColors.length ||
        stripeParams.length != oldDelegate.stripeParams.length) {
      return true;
    }
    for (int i = 0; i < gradientColors.length; i++) {
      if (gradientColors[i] != oldDelegate.gradientColors[i]) return true;
    }
    for (int i = 0; i < stripeParams.length; i++) {
      if (stripeParams[i] != oldDelegate.stripeParams[i]) return true;
    }
    return false;
  }
}
