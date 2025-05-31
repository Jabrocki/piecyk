import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../animations/text_gradient_animation.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextGradientAnimation(
      text: 'SUNSEER',
      style: GoogleFonts.robotoCondensed(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
      duration: const Duration(seconds: 3), // You can adjust the animation duration here
    );
  }
}
