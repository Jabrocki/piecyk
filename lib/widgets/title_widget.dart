import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:forui/forui.dart'; // Import FTheme
import '../animations/text_gradient_animation.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final isDarkMode = colors.brightness == Brightness.dark;

    return TextGradientAnimation(
      text: 'SUNSEER',
      style: GoogleFonts.robotoCondensed(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        // The color property of TextStyle is used by ShaderMask, but the gradient will override it.
        // We set it to the theme's foreground color as a fallback or if ShaderMask is disabled.
        color: colors.foreground,
      ),
      duration: const Duration(seconds: 3),
      finalGradientColor: isDarkMode ? Colors.white : Colors.black, // Set finalGradientColor based on theme
    );
  }
}
