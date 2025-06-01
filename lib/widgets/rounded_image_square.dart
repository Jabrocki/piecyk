import 'package:flutter/material.dart';

class RoundedImageSquare extends StatelessWidget {
  final ImageProvider imageProvider;
  final double size;
  final double borderRadius;

  const RoundedImageSquare({
    super.key,
    required this.imageProvider,
    this.size = 160,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: Image(image: imageProvider, fit: BoxFit.cover),
      ),
    );
  }
}
